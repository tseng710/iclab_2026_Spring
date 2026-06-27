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
// Input & Output Declaration
// ========================================
output reg clk, rst_n, in_valid, out_mode;
output reg [2:0] in_weight;

input out_valid, out_code;

// ========================================
// Parameter & Integer Declaration
// ========================================
integer PATNUM = 1000;
integer pat_count;
integer i, j, p, latency, total_latency;

// 測資變數
integer pat_weight [0:7];
integer pat_mode;

// 霍夫曼樹結構變數 (0~7為原字元, 8~14為合併後的子樹)
integer weight [0:14];
integer is_char [0:14]; // 1: 字元, 0: 子樹
integer char_id [0:14]; // 優先權 ID (A=7, B=6... V=0)
integer time_stamp [0:14]; // 記錄產生順序 (越小越舊)
integer left_ch [0:14];
integer right_ch [0:14];
integer active [0:14];

// 編碼結果
reg [19:0] huff_code [0:7];
integer huff_len [0:7];

// 目標輸出字串
reg [100:0] target_bitstream;
integer target_len;

// ========================================
// Clock Generation
// ========================================
always #(`CYCLE_TIME/2.0) clk = ~clk;

// ========================================
// Main Execution Block
// ========================================
initial begin
    // 初始化腳位
    rst_n = 1;
    in_valid = 0;
    in_weight = 0;
    out_mode = 1'bx;
    clk = 0;
    total_latency = 0;

    // 系統重置
    force clk = 0;
    reset_task;
    release clk;

    // 開始測資迴圈
    for (pat_count = 0; pat_count < PATNUM; pat_count = pat_count + 1) begin
        generate_input;
        compute_huffman_tree;
        build_target_string;

        drive_input;
        check_output;

        // 測資間的隨機延遲 (2~4 cycles)
        delay_task;
    end

    // 順利通過測試
    $display("\n========================================================");
    $display("   Congratulations! All %0d patterns passed!", PATNUM);
    $display("   Total Latency: %0d", total_latency);
    $display("========================================================\n");
    $finish;
end

// ========================================
// Tasks
// ========================================
task reset_task;
    begin
        #(10);
        rst_n = 0;
        #(10);
        rst_n = 1;
    end
endtask

task delay_task;
    begin
        integer delay_cycles;
        delay_cycles = $urandom_range(2, 4);
        for(i=0; i<delay_cycles; i=i+1)
            @(negedge clk);
    end
endtask

task generate_input;
    begin
        for(i=0; i<8; i=i+1) begin
            pat_weight[i] = $urandom_range(1, 7); // 3-bit 權重
        end
        pat_mode = $urandom_range(0, 1);
    end
endtask

task drive_input;
    begin
        @(negedge clk);
        in_valid = 1;
        out_mode = pat_mode;
        // 依序輸入 8 個字元 (A, B, C, E, I, L, O, V) 的權重
        for(i=0; i<8; i=i+1) begin
            in_weight = pat_weight[i];

            @(negedge clk);
            out_mode = 1'bx;
        end

        in_weight = 3'b0;



        // 輸入結束
        in_valid = 0;
        out_mode = 1'bx;
    end
endtask

task check_output;
    begin
        latency = 0;
        // 等待 out_valid 拉高
        while (!out_valid) begin
            if (latency > 2000) begin
                $display("========================================================");
                $display("   [Error] Execution latency exceeded 2000 cycles!");
                $display("========================================================");
                $finish;
            end
            latency = latency + 1;
            @(negedge clk);
        end

        total_latency = total_latency + latency;

        // 檢查連續輸出
        for(i=0; i<target_len; i=i+1) begin
            if (!out_valid) begin
                $display("========================================================");
                $display("   [Error] out_valid fell to 0 too early at pattern %0d!", pat_count);
                $display("========================================================");
                $finish;
            end
            if (out_code !== target_bitstream[i]) begin
                $display("========================================================");
                $display("   [Error] Output mismatch at pattern %0d!", pat_count);
                $display("   Expected bit: %b, Got: %b", target_bitstream[i], out_code);
                $display("========================================================");
                $finish;
            end
            @(negedge clk);
        end

        // 檢查輸出是否確實降回 0
        if (out_valid !== 0) begin
            $display("========================================================");
            $display("   [Error] out_valid should go low immediately after outputting!");
            $display("========================================================");
            $finish;
        end
    end
endtask

// ========================================
// Golden Model: Huffman Tree Builder
// ========================================
// 判斷優先權 Function (回傳 1 代表 n1 > n2)
function integer is_greater;
    input integer n1, n2;
    begin
        if (weight[n1] != weight[n2]) begin
            is_greater = (weight[n1] > weight[n2]) ? 1 : 0;
        end
        else if (is_char[n1] != is_char[n2]) begin
            is_greater = (is_char[n1] > is_char[n2]) ? 1 : 0; // 字元 > 子樹
        end
        else if (is_char[n1] == 1) begin
            is_greater = (char_id[n1] > char_id[n2]) ? 1 : 0; // 字元編號順序
        end
        else begin
            is_greater = (time_stamp[n1] < time_stamp[n2]) ? 1 : 0; // 舊子樹 > 新子樹
        end
    end
endfunction

task compute_huffman_tree;
    integer k, min1, min2, found;
    integer curr, bit_val;
    reg [19:0] temp_code;
    begin
        // 1. 初始化節點 (A=0, B=1, C=2, E=3, I=4, L=5, O=6, V=7)
        for(i=0; i<8; i=i+1) begin
            weight[i] = pat_weight[i];
            is_char[i] = 1;
            char_id[i] = 7 - i; // A(7) 優先權最大, V(0) 最小
            time_stamp[i] = 0;
            left_ch[i] = -1;
            right_ch[i] = -1;
            active[i] = 1;
        end

        // 2. 建樹 (需合併 7 次)
        for(k=8; k<15; k=k+1) begin
            min1 = -1;
            min2 = -1;
            // 找出最小與次小的兩個節點
            for(i=0; i<k; i=i+1) begin
                if(active[i]) begin
                    if(min1 == -1 || is_greater(min1, i)) begin
                        min2 = min1;
                        min1 = i;
                    end
                    else if(min2 == -1 || is_greater(min2, i)) begin
                        min2 = i;
                    end
                end
            end

            // 組合新節點 (較大的放左邊, 較小的放右邊)
            weight[k] = weight[min1] + weight[min2];
            is_char[k] = 0;
            time_stamp[k] = k;
            left_ch[k] = min2;  // min2 > min1
            right_ch[k] = min1;
            active[min1] = 0;
            active[min2] = 0;
            active[k] = 1;
        end

        // 3. 追蹤產生每個字元的編碼
        for(i=0; i<8; i=i+1) begin
            curr = i;
            huff_len[i] = 0;
            temp_code = 0;
            // 從葉節點往上爬到根節點 (Index 14)
            while(curr != 14) begin
                found = 0;
                for(p=8; p<15; p=p+1) begin
                    if(!found) begin
                        if(left_ch[p] == curr) begin
                            temp_code[huff_len[i]] = 0; // 左分支為 '0'
                            huff_len[i] = huff_len[i] + 1;
                            curr = p;
                            found = 1;
                        end
                        else if(right_ch[p] == curr) begin
                            temp_code[huff_len[i]] = 1; // 右分支為 '1'
                            huff_len[i] = huff_len[i] + 1;
                            curr = p;
                            found = 1;
                        end
                    end
                end
            end

            // 將向上爬得到的編碼反轉，得到正確的 Prefix Code
            huff_code[i] = 0;
            for(p=0; p<huff_len[i]; p=p+1) begin
                huff_code[i][p] = temp_code[huff_len[i]-1-p];
            end
        end
    end
endtask

// ========================================
// Golden Model: Build Target Bitstream
// ========================================
task build_target_string;
    integer char_seq [0:4];
    integer idx;
    begin
        if (pat_mode == 0) begin
            // 模式 0 輸出 "ILOVE" (對應 Index: 4, 5, 6, 7, 3)
            char_seq[0] = 4;
            char_seq[1] = 5;
            char_seq[2] = 6;
            char_seq[3] = 7;
            char_seq[4] = 3;
        end
        else begin
            // 模式 1 輸出 "ICLAB" (對應 Index: 4, 2, 5, 0, 1)
            char_seq[0] = 4;
            char_seq[1] = 2;
            char_seq[2] = 5;
            char_seq[3] = 0;
            char_seq[4] = 1;
        end

        target_len = 0;
        target_bitstream = 0;
        for(i=0; i<5; i=i+1) begin
            idx = char_seq[i];
            for(j=0; j<huff_len[idx]; j=j+1) begin
                target_bitstream[target_len] = huff_code[idx][j];
                target_len = target_len + 1;
            end
        end
    end
endtask

endmodule
