`ifdef RTL
    `define CYCLE_TIME 6.0
`endif
`ifdef GATE
    `define CYCLE_TIME 6.0
`endif

module PATTERN(
    // Output signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Input signals
    out_valid, 
	out_code
);
// ========================================
// Input & Output
// ========================================
output reg clk, rst_n, in_valid, out_mode;
output reg [2:0] in_weight;

input out_valid, out_code;
// ========================================
// 變數宣告
// ========================================
integer pat_idx;
integer total_patterns = 2000;
integer wrong_count;
integer delay_cycles; 

// Golden Model 用的資料結構
integer in_weight_array [0:7];
integer current_mode;

integer left_child  [8:14];
integer right_child [8:14];

integer weights [0:14];
integer priority_val [0:14];
integer active [0:14];
integer parent [0:14];
integer is_right [0:14]; // 0 代表左邊 (0), 1 代表右邊 (1)

integer out_code_bits [0:100];
integer out_code_len;
integer out_idx;
integer total_latency = 0;
// 供 Debug 印出字元名稱用的陣列
reg [7:0] char_name [0:7];

// ========================================
// Clock Generation
// ========================================
initial clk = 0;
always #(`CYCLE_TIME / 2.0) clk = ~clk;

// ========================================
// Pattern Start
// ========================================
integer seed;
integer dummy; // 用來接 $urandom 的回傳值以避免 warning

// ========================================
// Pattern Start
// ========================================
initial begin
    // 🌟 [Seed 導入] 嘗試從終端機指令讀取 SEED，若沒給則預設為 123
    if (!$value$plusargs("SEED=%d", seed)) begin
        seed = 123; 
    end
    
    $display("===========================================================");
    $display("   [PATTERN] Simulation running with SEED = %0d", seed);
    $display("===========================================================");
    
    // 🌟 初始化亂數產生器
    dummy = $urandom(seed);

    // 字元對應: A=0, B=1, C=2, E=3, I=4, L=5, O=6, V=7
    char_name[0] = "A"; char_name[1] = "B"; char_name[2] = "C"; char_name[3] = "E";
    char_name[4] = "I"; char_name[5] = "L"; char_name[6] = "O"; char_name[7] = "V";

    // 1. 初始化訊號
    rst_n = 1;
    in_valid = 0;
    in_weight = 3'bx; 
    out_mode = 1'bx;
    wrong_count = 0;

    // 將 clock 強制停在 0，確保接下來的動作「沒有 clock edge」
    force clk = 0;
    #10;
    
    // --- 【開始加嚴 Reset 檢查】 ---
    rst_n = 0; // 觸發非同步 Reset
    
    #(`CYCLE_TIME / 2.0);
    
    // 🌟 檢查點 1：在 rst_n = 0 的「期間」，且「沒有 clock edge」，輸出必須立刻為 0 (驗證非同步特性)
    if (out_valid !== 0 || out_code !== 0) begin
        $display("\n\033[1;31m===========================================================\033[0m");
        $display("\033[1;31m[FAIL]\033[0m Reset Check Failed!");
        $display("       Outputs must be 0 IMMEDIATELY when rst_n is 0.");
        $display("       (Your design might be using Synchronous Reset instead of Asynchronous!)");
        $display("\033[1;31m===========================================================\033[0m");
        $finish;
    end

    // 等待剩下的 Reset 時間
    #(`CYCLE_TIME * 2 - 1); 
    rst_n = 1; // 釋放 Reset

    // 🌟 檢查點 2：釋放 Reset 後，且在任何 input 進來之前，輸出必須乖乖維持 0
    #(`CYCLE_TIME);
    if (out_valid !== 0 || out_code !== 0) begin
        $display("\n\033[1;31m===========================================================\033[0m");
        $display("\033[1;31m[FAIL]\033[0m Reset Check Failed!");
        $display("       Outputs must remain 0 after rst_n is released.");
        $display("\033[1;31m===========================================================\033[0m");
        $finish;
    end
    // --- 【加嚴 Reset 檢查結束】 ---

    #(`CYCLE_TIME);
    release clk; // 恢復 clock 運作

    for (pat_idx = 0; pat_idx < total_patterns; pat_idx = pat_idx + 1) begin
        generate_random_data();
        calculate_golden_tree();
        
        feed_inputs();
        wait_and_check_outputs();
        
        delay_cycles = $urandom_range(0, 2);
        repeat(delay_cycles) @(negedge clk);
    end

    if (wrong_count == 0) begin
        $display("-----------------------------------------------------------");
         $display("---------------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █      Congratulations !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭   ");
        $display("    █ ▀▄▄▄▄▀                 █  ╭ ");
        $display("    ▀▄                       █     You have passed all patterns !");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █      ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("---------------------------------------------------------------------------------------------"); 
        $display("   All %d patterns simulated successfully.", total_patterns);
        $display("   Total Latency: %0d cycles", total_latency); 
        $display("-----------------------------------------------------------");
    end
    $finish;
end
// ========================================
// Protocol Checks (Spec 11)
// ========================================
always @(posedge clk) begin
    #1;
    if (in_valid === 1 && out_valid === 1) begin
        $display("\n\033[1;31m===========================================================\033[0m");
        $display("\033[1;31m[FAIL]\033[0m Protocol Violation (Spec 11)!");
        $display("       out_valid should NOT be high when in_valid is high.");
        $display("       (Your out_valid goes high at the last cycle of in_valid!)");
        $display("\033[1;31m===========================================================\033[0m");
        $finish;
    end
end
task generate_random_data;
    integer i;
    begin
        if (pat_idx == 5) begin
            // Corner Case 1: 所有權重皆為 0
            for (i = 0; i < 8; i = i + 1) in_weight_array[i] = 0;
            current_mode = 0;
        end else if (pat_idx == 6) begin
            // Corner Case 2: 所有權重皆為 7
            for (i = 0; i < 8; i = i + 1) in_weight_array[i] = 7;
            current_mode = 1;
        end else if (pat_idx == 7) begin
            // Corner Case 3: 嚴格遞增
            for (i = 0; i < 8; i = i + 1) in_weight_array[i] = i;
            current_mode = 0;
        end else begin
            // Normal Random
            for (i = 0; i < 8; i = i + 1) begin
                in_weight_array[i] = $urandom_range(0, 7);
            end
            current_mode = $urandom_range(0, 1);
        end
    end
endtask

task feed_inputs;
    integer i;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            in_valid = 1;
            in_weight = in_weight_array[i];
            
            if (i == 0) out_mode = current_mode;
            else out_mode = 1'bx;
            // 這裡原本的 if (out_valid === 1) 已經刪除了
        end
        
        @(negedge clk);
        in_valid = 0;
        in_weight = 3'bx; 
        out_mode  = 1'bx; 
    end
endtask

task wait_and_check_outputs;
    integer latency;
    integer k; // 用於迴圈列印
    begin
        latency = 0;
        out_idx = 0;

        while (out_valid === 0) begin
            latency = latency + 1;
            if (latency > 2000) begin
                $display("\n\033[1;31m===========================================================\033[0m");
                $display("\033[1;31m[FAIL]\033[0m Pattern %0d | Latency > 2000 cycles (Spec 3 violation)", pat_idx);
                $display("\033[1;31m===========================================================\033[0m");
                $finish;
            end
            @(negedge clk);
        end
        
        while (out_valid === 1) begin
            // 防呆檢查：防止學生 out_valid 拉過長
            if (out_idx >= out_code_len) begin
                $display("\n\033[1;31m===========================================================\033[0m");
                $display("\033[1;31m[FAIL]\033[0m Pattern %0d", pat_idx);
                $display("       out_valid stays high for too many cycles!");
                $display("       Expected length was %0d bits.", out_code_len);
                print_calculation_trace();
                $display("\033[1;31m===========================================================\033[0m");
                $finish;
            end

            if (out_code !== out_code_bits[out_idx]) begin
                $display("\n\033[1;31m===========================================================\033[0m");
                $display("\033[1;31m[FAIL]\033[0m Pattern %0d", pat_idx);
                $display("-----------------------------------------------------------");
                $display("Mismatch at Output Index [%0d] (0-based)!", out_idx);
                $display("  => Expected bit : \033[1;32m%0b\033[0m", out_code_bits[out_idx]);
                $display("  => Your OUT bit : \033[1;31m%b\033[0m", out_code); // out_code 本身是 1 bit，不用改
                
                // 顯示完整預期序列，方便核對波形
                $write("\n[Expected Full Sequence]: ");
                for (k = 0; k < out_code_len; k = k + 1) begin
                    // 🔽 這裡的 %b 也改成 %0b
                    if (k == out_idx) $write("\033[1;31m%0b\033[0m", out_code_bits[k]); 
                    else              $write("%0b", out_code_bits[k]);
                end
                $display("\n");
                
                print_calculation_trace();
                $display("\033[1;31m===========================================================\033[0m");
                wrong_count = wrong_count + 1;
                $display("-----------------------------------------------------------");
                $display("               HUFFMAN TREE STRUCTURE                    ");
                $display("-----------------------------------------------------------");
                print_tree(14, 0, 0); // 從 Root Node 14 開始畫樹，初始深度 0
                $display("-----------------------------------------------------------");
                $finish;
            end
            out_idx = out_idx + 1;
            @(negedge clk);
        end
        
        if (out_idx !== out_code_len) begin
            $display("\n\033[1;31m===========================================================\033[0m");
            $display("\033[1;31m[FAIL]\033[0m Pattern %0d | Length mismatch!", pat_idx);
            $display("       Expected %0d bits, but out_valid dropped after %0d bits.", out_code_len, out_idx);
            print_calculation_trace();
            $display("\033[1;31m===========================================================\033[0m");
            $finish;
        end
        
        // 🌟 成功時印出資訊，並包含 Expected 與 Output 序列
        $display("\033[1;32m[PASS]\033[0m Pattern %3d | Mode: %0d (%-5s) | Latency: %4d cycles", 
                 pat_idx, current_mode, (current_mode==0)?"ILOVE":"ICLAB", latency);
        // 🔽 新增：印出 Input Weights
        $display("       Input    : [A]:%-2d [B]:%-2d [C]:%-2d [E]:%-2d [I]:%-2d [L]:%-2d [O]:%-2d [V]:%-2d",
                 in_weight_array[0], in_weight_array[1], in_weight_array[2], in_weight_array[3],
                 in_weight_array[4], in_weight_array[5], in_weight_array[6], in_weight_array[7]);
                 
        // 印出 Expected 序列
        $write("       Expected : ");
        for (k = 0; k < out_code_len; k = k + 1) $write("%0b", out_code_bits[k]);
        $display(""); // 換行
        
        // 印出 Output 序列 (因為已經 PASS，所以 Output 一定與 Expected 相同)
        $write("       Output   : ");
        for (k = 0; k < out_code_len; k = k + 1) $write("%0b", out_code_bits[k]); 
        $display(""); // 換行
        $display("-----------------------------------------------------------");
        
        // 累加總 Latency
        total_latency = total_latency + latency; 
    end
endtask

task calculate_golden_tree;
    integer i, step, min1_idx, min2_idx;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            weights[i] = in_weight_array[i];
            priority_val[i] = 15 - i;  // A=15, B=14... V=8
            active[i] = 1;
        end
        for (i = 8; i < 15; i = i + 1) begin
            priority_val[i] = 15 - i;  // Old=7 ... New=1
            active[i] = 0;
        end

        for (step = 0; step < 7; step = step + 1) begin
            min1_idx = -1; // 小 (右 1)
            min2_idx = -1; // 大 (左 0)

            // 尋找絕對最小 (min1)
            for (i = 0; i < 8 + step; i = i + 1) begin
                if (active[i]) begin
                    if (min1_idx == -1) begin
                        min1_idx = i;
                    end else if ( (weights[i] < weights[min1_idx]) || 
                                  (weights[i] == weights[min1_idx] && priority_val[i] < priority_val[min1_idx]) ) begin
                        min1_idx = i;
                    end
                end
            end

            // 尋找第二小 (min2)
            for (i = 0; i < 8 + step; i = i + 1) begin
                if (active[i] && i != min1_idx) begin
                    if (min2_idx == -1) begin
                        min2_idx = i;
                    end else if ( (weights[i] < weights[min2_idx]) || 
                                  (weights[i] == weights[min2_idx] && priority_val[i] < priority_val[min2_idx]) ) begin
                        min2_idx = i;
                    end
                end
            end

            parent[min2_idx] = 8 + step;
            is_right[min2_idx] = 0; 
            
            parent[min1_idx] = 8 + step;
            is_right[min1_idx] = 1;

            active[min1_idx] = 0;
            active[min2_idx] = 0;
            weights[8+step] = weights[min1_idx] + weights[min2_idx];
            active[8+step] = 1;
        end

        out_code_len = 0;
        if (current_mode == 0) begin
            trace_path_and_append(4); trace_path_and_append(5); trace_path_and_append(6);
            trace_path_and_append(7); trace_path_and_append(3);
        end else begin
            trace_path_and_append(4); trace_path_and_append(2); trace_path_and_append(5);
            trace_path_and_append(0); trace_path_and_append(1);
        end
    end
endtask

task trace_path_and_append(input integer node_idx);
    integer curr, sp;
    integer stack [0:15];
    begin
        curr = node_idx;
        sp = 0;
        while (curr != 14) begin
            stack[sp] = is_right[curr];
            sp = sp + 1;
            curr = parent[curr];
        end
        while (sp > 0) begin
            sp = sp - 1;
            out_code_bits[out_code_len] = stack[sp];
            out_code_len = out_code_len + 1;
        end
    end
endtask

// 🌟 [除錯神器] 表格化的 Huffman Tree Construction 紀錄
task print_calculation_trace;
    integer i, step;
    integer curr_node, bit_idx;
    integer code_array [0:15];
    begin
        $display("-----------------------------------------------------------");
        $display("               HUFFMAN TREE CALCULATION TRACE              ");
        $display("-----------------------------------------------------------");
        $display(" Target String : %s (out_mode = %0d)", current_mode == 0 ? "ILOVE" : "ICLAB", current_mode);
        $display(" Initial Weights:");
        $display("  [A]:%-2d  [B]:%-2d  [C]:%-2d  [E]:%-2d  [I]:%-2d  [L]:%-2d  [O]:%-2d  [V]:%-2d",
                 in_weight_array[0], in_weight_array[1], in_weight_array[2], in_weight_array[3],
                 in_weight_array[4], in_weight_array[5], in_weight_array[6], in_weight_array[7]);
        $display("-----------------------------------------------------------");
        $display(" Step | Min1 (Right '1') | Min2 (Left '0')  | Merged New Node");
        $display("-----------------------------------------------------------");
        
        // 重新模擬一次 Tree 並印出過程
        for (i = 0; i < 8; i = i + 1) begin
            weights[i] = in_weight_array[i];
            priority_val[i] = 15 - i;  
            active[i] = 1;
        end
        for (i = 8; i < 15; i = i + 1) begin
            priority_val[i] = 15 - i;
            active[i] = 0;
        end

        for (step = 0; step < 7; step = step + 1) begin
            integer m1, m2;
            m1 = -1; m2 = -1;
            for (i = 0; i < 8 + step; i = i + 1) begin
                if (active[i]) begin
                    if (m1 == -1) m1 = i;
                    else if ((weights[i] < weights[m1]) || (weights[i] == weights[m1] && priority_val[i] < priority_val[m1])) m1 = i;
                end
            end
            for (i = 0; i < 8 + step; i = i + 1) begin
                if (active[i] && i != m1) begin
                    if (m2 == -1) m2 = i;
                    else if ((weights[i] < weights[m2]) || (weights[i] == weights[m2] && priority_val[i] < priority_val[m2])) m2 = i;
                end
            end
            
            // 格式化輸出，讓欄位對齊
            $write("   %0d  | ", step);
            
            // 印出 Min 1
            if (m1 < 8) $write("Char %s (W:%-2d)  | ", char_name[m1], weights[m1]); 
            else        $write("Node%0d (W:%-2d)  | ", m1, weights[m1]);
            
            // 印出 Min 2
            if (m2 < 8) $write("Char %s (W:%-2d)  | ", char_name[m2], weights[m2]); 
            else        $write("Node%0d (W:%-2d)  | ", m2, weights[m2]);
            
            // 印出結果 Node
            $display("Node%0d (W:%-2d)", 8+step, weights[m1]+weights[m2]);
            left_child[8+step]  = m2; // Left '0'
            right_child[8+step] = m1; // Right '1'
            active[m1] = 0; active[m2] = 0; weights[8+step] = weights[m1] + weights[m2]; active[8+step] = 1;
            
        end
        $display("-----------------------------------------------------------");
        $display("-----------------------------------------------------------");
        $display(" Final Character Dictionary:");
        for (i = 0; i < 8; i = i + 1) begin
            curr_node = i;
            bit_idx = 0;
            // 往上找 parent 直到 root (Node 14)
            while (curr_node != 14) begin
                code_array[bit_idx] = is_right[curr_node];
                bit_idx = bit_idx + 1;
                curr_node = parent[curr_node];
            end
            
            $write("  [%s] : ", char_name[i]);
            // 因為是從 leaf 往 root 找，所以要反過來印
            while (bit_idx > 0) begin
                bit_idx = bit_idx - 1;
                $write("%0b", code_array[bit_idx]);
            end
            $display(""); // 換行
        end
        $display("-----------------------------------------------------------");
        
    end
endtask
// =======================================
// 終端機 Tree 視覺化工具
// =======================================
function [7:0] get_char_string;
    input integer id;
    begin
        case(id)
            0: get_char_string = "A";
            1: get_char_string = "B";
            2: get_char_string = "C";
            3: get_char_string = "E";
            4: get_char_string = "I";
            5: get_char_string = "L";
            6: get_char_string = "O";
            7: get_char_string = "V";
            default: get_char_string = "?";
        endcase
    end
endfunction

task automatic print_tree;
    input integer node;
    input integer depth;
    input integer is_last_mask; // 記錄前面的縮排是否需要畫直線
    integer i;
    begin
        // 1. 印出前面的樹枝結構
        for (i=0; i<depth; i=i+1) begin
            if (i == depth-1) begin
                if ((is_last_mask >> i) & 1) $write("└── ");
                else                         $write("├── ");
            end else begin
                if ((is_last_mask >> i) & 1) $write("    ");
                else                         $write("│   ");
            end
        end

        // 2. 印出節點資訊
        if (node < 8) begin
            $display("Char %s (W:%-2d) [Bit: %s]", get_char_string(node), weights[node], is_right[node] ? "1" : "0");
        end else begin
            if (node == 14)
                $display("Node%0d (W:%-2d) [ROOT]", node, weights[node]);
            else
                $display("Node%0d (W:%-2d) [Bit: %s]", node, weights[node], is_right[node] ? "1" : "0");

            // 3. 遞迴印出左子樹與右子樹
            print_tree(left_child[node], depth+1, is_last_mask & ~(1 << depth));
            print_tree(right_child[node], depth+1, is_last_mask | (1 << depth));
        end
    end
endtask
endmodule