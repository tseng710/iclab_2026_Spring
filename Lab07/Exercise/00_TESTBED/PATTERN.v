`ifdef RTL
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_1
    `define CYCLE_TIME_clk1 34.7
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 11.3
`endif
`ifdef Period_2
    `define CYCLE_TIME_clk1 11.3
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_3
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif

`ifdef GATE
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif

// ===============================================================
// Terminal Color Defines
// ===============================================================
`define C_RST "\033[0m"
`define C_GRN "\033[1;32m"
`define C_RED "\033[1;31m"
`define C_YEL "\033[1;33m"
`define C_CYA "\033[1;36m"
`define C_WHT "\033[1;37m"

module PATTERN(
    output reg      clk1,
    output reg      clk2,
    output reg      clk3,

    output reg      rst_n,
    // AXI4-Lite Master
    input      [31:0]  ar_addr_clk2, 
    input              ar_valid_clk2, 
    input              ar_ready_clk2,
    input       [63:0] r_data_clk2,  
    // input       [1:0]  r_resp_clk2,  // 恢復註解，避免 Testbed 沒接線產生 Z
    input              r_valid_clk2, 
    input              r_ready_clk2,

    input      [31:0]  ar_addr_clk3, 
    input              ar_valid_clk3, 
    input              ar_ready_clk3,
    input       [63:0] r_data_clk3,  
    // input       [1:0]  r_resp_clk3,  // 恢復註解，避免 Testbed 沒接線產生 Z
    input              r_valid_clk3, 
    input              r_ready_clk3,

    output reg       in_mode_valid,
    output reg       in_mode,
    output reg       in_valid,
    output reg [1:0] in_bank,
    output reg [5:0] in_src_row,
    
    input             out_valid,
    input [63:0]      out_data
);
real    CYCLE_clk1 = `CYCLE_TIME_clk1;
real    CYCLE_clk2 = `CYCLE_TIME_clk2;
real    CYCLE_clk3 = `CYCLE_TIME_clk3;

//================================================================
// Parameters & Variables
//================================================================
parameter PAT_NUM = 30; 

// AXI Address Shift for Snoop Queue checking
// If your AR_ADDR is a Byte Address (addr*8), set this to 3. 
// If it is directly the Word Index (0~65535), keep it at 0.
parameter AXI_ADDR_SHIFT = 0; 

reg error_dump_en; 

integer pat_cnt;
integer total_latency, current_latency;
integer seed;

// Statistics & Coverage Tracking Variables
integer total_latency_calc, total_latency_gauss;
integer count_calc, count_gauss;
integer min_latency_calc, max_latency_calc;
integer min_latency_gauss, max_latency_gauss;
integer global_max_depth; 

// Golden Memory Array
reg [63:0] golden_dram [0:65535]; 
reg [63:0] golden_ans_queue [0:1024]; // Max size 1024 for GAUSS
integer ans_head, ans_tail;

// Input tracking for 4 cycles
reg [1:0] pat_bank [0:3];
reg [5:0] pat_row  [0:3];
reg       pat_mode;

// Output state tracking flag
reg is_waiting_output;
reg is_waiting_output_d1;
reg is_waiting_output_d2; 

//================================================================
// AXI Checker Variables (Unrolled)
//================================================================
// --- clk2 variables ---
integer ar_timeout_cnt_clk2;
integer r_timeout_cnt_clk2;
integer ar_to_r_timeout_cnt_clk2;
integer outstanding_cnt_clk2;
reg [31:0] snoop_addr_queue_clk2 [0:2047];
reg [31:0] snoop_head_clk2, snoop_tail_clk2;

reg [31:0] past_ar_addr_clk2;
reg past_ar_valid_clk2;
reg past_ar_ready_clk2;
reg [63:0] past_r_data_clk2;
reg past_r_valid_clk2;
reg past_r_ready_clk2;

wire ar_fire_clk2 = (ar_valid_clk2 === 1'b1 && ar_ready_clk2 === 1'b1);
wire r_fire_clk2  = (r_valid_clk2 === 1'b1 && r_ready_clk2 === 1'b1);
wire [15:0] snoop_word_addr_clk2 = snoop_addr_queue_clk2[snoop_head_clk2[10:0]] >> AXI_ADDR_SHIFT;

// --- clk3 variables ---
integer ar_timeout_cnt_clk3;
integer r_timeout_cnt_clk3;
integer ar_to_r_timeout_cnt_clk3;
integer outstanding_cnt_clk3;
reg [31:0] snoop_addr_queue_clk3 [0:2047];
reg [31:0] snoop_head_clk3, snoop_tail_clk3; 

reg [31:0] past_ar_addr_clk3;
reg past_ar_valid_clk3;
reg past_ar_ready_clk3;
reg [63:0] past_r_data_clk3;
reg past_r_valid_clk3;
reg past_r_ready_clk3;

wire ar_fire_clk3 = (ar_valid_clk3 === 1'b1 && ar_ready_clk3 === 1'b1);
wire r_fire_clk3  = (r_valid_clk3 === 1'b1 && r_ready_clk3 === 1'b1);
wire [15:0] snoop_word_addr_clk3 = snoop_addr_queue_clk3[snoop_head_clk3[10:0]] >> AXI_ADDR_SHIFT;

//================================================================
// Clock Generation
//================================================================
initial clk1 = 0; always #(CYCLE_clk1/2.0) clk1 = ~clk1;
initial clk2 = 0; always #(CYCLE_clk2/2.0) clk2 = ~clk2;
initial clk3 = 0; always #(CYCLE_clk3/2.0) clk3 = ~clk3;

//================================================================
// Background strict out_valid check (Idle Purity Check)
//================================================================
always @(negedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        is_waiting_output_d1 <= 1'b0;
        is_waiting_output_d2 <= 1'b0;
    end else begin
        is_waiting_output_d1 <= is_waiting_output;
        is_waiting_output_d2 <= is_waiting_output_d1;
    end
end

always @(negedge clk1) begin
    if (rst_n === 1'b1 && $time > 100) begin 
        if (!is_waiting_output && !is_waiting_output_d1 && !is_waiting_output_d2 && out_valid !== 1'b0) begin
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] Specifications: The out_valid must be asserted in specified cycles.");
            $display("        (Detected out_valid high or X during IDLE/INPUT phase)");
            $display("=======================================================\n");
            FAIL_DOG_task;
        end
    end
end

//================================================================
// Main Test Flow
//================================================================
initial begin
    `ifdef SEED
        seed = `SEED;
    `else
        seed = 30; 
    `endif
    
    $display("\n%s========================================================%s", `C_CYA, `C_RST);
    $display("%s   [INFO] Pattern Initialization                        %s", `C_CYA, `C_RST);
    $display("%s   [INFO] Seed value used: %0d %s", `C_CYA, seed, `C_RST);
    $display("%s   (To reproduce a fail, add +define+SEED=%0d) %s", `C_WHT, seed, `C_RST);
    $display("%s========================================================%s\n", `C_CYA, `C_RST);

    error_dump_en = 0;
    $readmemh("../00_TESTBED/DRAM_init.dat", golden_dram);

    for (integer j = 0; j <= 1024; j = j + 1) begin
        golden_ans_queue[j] = 64'b0;
    end
    
    // Initialize Statistics
    total_latency = 0;
    total_latency_calc = 0; total_latency_gauss = 0;
    count_calc = 0; count_gauss = 0;
    min_latency_calc = 999999; max_latency_calc = 0;
    min_latency_gauss = 999999; max_latency_gauss = 0;
    global_max_depth = 0; 

    reset_task;

    for (pat_cnt = 0; pat_cnt < PAT_NUM; pat_cnt = pat_cnt + 1) begin
        drive_input_task;
        calculate_golden_task; 
        wait_and_check_output_task;
        
        // Update Statistics for current pattern
        if (pat_mode == 1'b0) begin // CALC
            total_latency_calc = total_latency_calc + current_latency;
            count_calc = count_calc + 1;
            if (current_latency < min_latency_calc) min_latency_calc = current_latency;
            if (current_latency > max_latency_calc) max_latency_calc = current_latency;
        end else begin // GAUSS
            total_latency_gauss = total_latency_gauss + current_latency;
            count_gauss = count_gauss + 1;
            if (current_latency < min_latency_gauss) min_latency_gauss = current_latency;
            if (current_latency > max_latency_gauss) max_latency_gauss = current_latency;
        end

        $display("\033[1;32m=== Pass Pattern %3d | Mode: %s | Latency: %5d cycles ===\033[0m", pat_cnt, pat_mode == 1'b0 ? "CALC " : "GAUSS", current_latency);
    end

    YOU_PASS_task;
end

//================================================================
// Tasks
//================================================================
task reset_task;
begin
    rst_n = 1'b1;
    in_mode_valid = 1'b0;
    in_mode = 1'b0;
    in_valid = 1'b0;
    in_bank = 2'b0;
    in_src_row = 6'b0;
    is_waiting_output = 1'b0; 
    
    force clk1 = 0;
    force clk2 = 0;
    force clk3 = 0;

    // 根據討論串修改：使用固定時間 #(50) 來避免 03_GATE 中
    // Handshake_syn_A1_reg 的 setup/hold 違規誤判
    #(50);
    rst_n = 1'b0;
    #(50);
    rst_n = 1'b1;
    
    release clk1;
    release clk2;
    release clk3;

    @(negedge clk1);

    if (out_valid !== 0 || out_data !== 0) begin
        $display("\n===================== ERROR DUMP ======================");
        $display("[Error] Specifications: All output signals should be reset after the reset signal is asserted.");
        $display("=======================================================\n");
        FAIL_DOG_task;
    end

    if (ar_valid_clk2 !== 0 || ar_addr_clk2 !== 0 || r_valid_clk2 !== 0 || r_data_clk2 !== 0) begin
        $display("\n===================== ERROR DUMP ======================");
        $display("[Error] AXI Spec: VALID, ADDR, and DATA signals should be reset (clk2).");
        $display("=======================================================\n");
        FAIL_DOG_task;
    end
    if (ar_valid_clk3 !== 0 || ar_addr_clk3 !== 0 || r_valid_clk3 !== 0 || r_data_clk3 !== 0) begin
        $display("\n===================== ERROR DUMP ======================");
        $display("[Error] AXI Spec: VALID, ADDR, and DATA signals should be reset (clk3).");
        $display("=======================================================\n");
        FAIL_DOG_task;
    end
end endtask

task drive_input_task; 
    integer i, swap_idx;
    reg [1:0] bank_pool [0:3];
    reg [1:0] temp_bank;
begin
    @(negedge clk1);
    
    in_mode_valid = 1'b1;
    pat_mode = {$random(seed)} % 2;
    in_mode = pat_mode;
    
    // 初始化 Bank Pool
    bank_pool[0] = 2'd0;
    bank_pool[1] = 2'd1;
    bank_pool[2] = 2'd2;
    bank_pool[3] = 2'd3;

    // 洗牌演算法 (Shuffle)：保證 4 個 Bank 出現順序隨機，且「不重複」
    for (i = 3; i > 0; i = i - 1) begin
        swap_idx = {$random(seed)} % (i + 1);
        temp_bank = bank_pool[i];
        bank_pool[i] = bank_pool[swap_idx];
        bank_pool[swap_idx] = temp_bank;
    end

    @(negedge clk1);
    in_mode_valid = 1'b0;
    for (i = 0; i < 4; i = i + 1) begin
        in_valid = 1'b1;
        pat_bank[i] = bank_pool[i];
        pat_row[i]  = {$random(seed)} % 64;
        in_bank = pat_bank[i];
        in_src_row = pat_row[i];
        @(negedge clk1);
    end
    
    in_valid = 1'b0;
    in_bank = 2'b0;
    in_src_row = 6'b0;
end endtask

// --- Tree Traversal Recursive Function ---
function automatic signed [63:0] calc_tree;
    input [15:0] node_addr;
    input integer depth;
    reg [63:0] node_data;
    reg signed [63:0] left_val, right_val, res;
begin
    if (depth > global_max_depth) global_max_depth = depth;

    // Depth constraint strictly checks for infinite loops
    if (depth > 32) begin
        $display("\n%s[FATAL] Tree recursion depth exceeded 32. The test data might contain an infinite loop!%s", `C_RED, `C_RST);
        $finish;
    end

    node_data = golden_dram[node_addr];
    if (node_data[63] == 1'b0) begin // Number Node
        res = $signed({ {33{node_data[62]}}, node_data[62:32] });
        if (error_dump_en) $display("    [Depth %0d] LEAF @ %h | Value = %0d", depth, node_addr, res);
        calc_tree = res;
    end else begin // Operator Node
        if (error_dump_en) begin
            case (node_data[33:32])
                2'b00: $display("    [Depth %0d] OP   @ %h | (+) Left: %h, Right: %h", depth, node_addr, node_data[31:16], node_data[15:0]);
                2'b01: $display("    [Depth %0d] OP   @ %h | (-) Left: %h, Right: %h", depth, node_addr, node_data[31:16], node_data[15:0]);
                2'b10: $display("    [Depth %0d] OP   @ %h | (*) Left: %h, Right: %h", depth, node_addr, node_data[31:16], node_data[15:0]);
                2'b11: $display("    [Depth %0d] OP   @ %h | (>>>) Left: %h, Right: %h", depth, node_addr, node_data[31:16], node_data[15:0]);
            endcase
        end

        left_val  = calc_tree(node_data[31:16], depth + 1);
        right_val = calc_tree(node_data[15:0], depth + 1);

        case (node_data[33:32])
            2'b00: res = left_val + right_val;
            2'b01: res = left_val - right_val;
            2'b10: res = left_val * right_val;
            2'b11: res = $signed(left_val) >>> right_val[5:0]; // Arithmetic right shift
        endcase
        
        if (error_dump_en) $display("    [Depth %0d] RTN  @ %h | Result = %0d", depth, node_addr, res);
        calc_tree = res;
    end
end
endfunction

task calculate_golden_task; 
    integer i, c;
    reg [15:0] target_addr;
    reg [63:0] raw_data;
    // For GAUSS: Precision safety margins
    reg [127:0] val_128;
    reg [127:0] sum, sum_sq;
    reg [127:0] N;
    reg signed [127:0] diff_128;
    reg signed [127:0] variance_scaled;
begin
    ans_head = 0;
    ans_tail = 0;

    if (!error_dump_en) begin
        $display("-------------------------------------------------------");
        $display("[Pattern %3d] Mode: %s", pat_cnt, pat_mode == 1'b0 ? "CALC (Prefix Tree)" : "GAUSS (Statistical Filtering)");
        $display("  [Input] Bank Order: %0d -> %0d -> %0d -> %0d", pat_bank[0], pat_bank[1], pat_bank[2], pat_bank[3]);
        $display("  [Input] Tree 0: Bank %0d, Row %2d | Tree 1: Bank %0d, Row %2d", pat_bank[0], pat_row[0], pat_bank[1], pat_row[1]);
        $display("  [Input] Tree 2: Bank %0d, Row %2d | Tree 3: Bank %0d, Row %2d", pat_bank[2], pat_row[2], pat_bank[3], pat_row[3]);
    end

    if (pat_mode == 1'b0) begin
        for (i = 0; i < 4; i = i + 1) begin
            target_addr = {pat_bank[i], pat_row[i], 8'h00};
            if (error_dump_en) $display("  >>> Processing Tree %0d (Root Addr: %h) <<<", i, target_addr);
            
            golden_ans_queue[ans_tail] = calc_tree(target_addr, 0);
            
            if (error_dump_en)
                $display("  >>> Final Result for Tree %0d = %h (%0d) <<<\n", i, golden_ans_queue[ans_tail], golden_ans_queue[ans_tail]);
                
            ans_tail = ans_tail + 1;
        end
    end 
    else begin
        sum = 0;
        sum_sq = 0; N = 0;

        // Phase 1: Accumulate Sum and Sum_Sq
        for (i = 0; i < 4; i = i + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                target_addr = {pat_bank[i], pat_row[i], c[7:0]};
                raw_data = golden_dram[target_addr]; 
                
                // Bit[63] == 0 indicates valid number
                if (raw_data[63] == 1'b0) begin 
                    val_128 = {97'b0, raw_data[62:32]}; // Treated as unsigned 31-bit
                    sum = sum + val_128;
                    sum_sq = sum_sq + (val_128 * val_128);
                    N = N + 1;
                end
            end
        end
        
        // Calculate Scaled Variance: (N * Sum(X^2)) - (Sum(X))^2
        if (N > 0) variance_scaled = (N * sum_sq) - (sum * sum);
        else variance_scaled = 0; 
        
        if (error_dump_en) begin
            $display("  [Phase 1] Scanned 1024 entries. Found %0d valid numbers.", N[31:0]);
            $display("  [Phase 1] Sum = %0d, Sum_Sq = %0d", sum, sum_sq);
            $display("  [Phase 2] Calculated Scaled Variance (N*S_2 - S^2) = %0d", variance_scaled);
            $display("  [Phase 3] Starting Output Filtering (Threshold: (N*X - S)^2 <= Variance)...");
        end

        // Phase 2: Filter Data
        for (i = 0; i < 4; i = i + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                target_addr = {pat_bank[i], pat_row[i], c[7:0]};
                raw_data = golden_dram[target_addr];
                
                // 完美處理 TA 要求的 "EOF 只輸出一次" 規則
                if (i == 3 && c == 255) begin
                    if (error_dump_en) $display("    -> Pushed Last Entry @ %h (Force push for EOF)", target_addr);
                    golden_ans_queue[ans_tail] = raw_data;
                    ans_tail = ans_tail + 1;
                end 
                else if (raw_data[63] == 1'b0 && N > 0) begin
                    val_128 = {97'b0, raw_data[62:32]};
                    diff_128 = $signed(val_128) * $signed(N) - $signed(sum);
                    
                    if ((diff_128 * diff_128) <= variance_scaled) begin
                        if (error_dump_en) $display("    -> Pushed Entry @ %h | Val = %0d, (N*X-S)^2 = %0d", target_addr, val_128[31:0], (diff_128 * diff_128));
                        golden_ans_queue[ans_tail] = raw_data;
                        ans_tail = ans_tail + 1;
                    end
                end
            end
        end
        if (!error_dump_en) $display("  [GAUSS] Total Expected Golden Outputs: %0d", ans_tail);
        else $display("  [GAUSS] Total Expected Outputs: %0d", ans_tail);
    end
end endtask

task wait_and_check_output_task; 
    integer d, delay_cycles;
begin
    current_latency = 0;
    is_waiting_output = 1'b1;
    
    while (ans_head < ans_tail) begin
        @(negedge clk1);
        current_latency = current_latency + 1;
        
        // Timeout Protection 放寬到 90,000 cycles
        if (current_latency > 90000) begin
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] Specifications: The execution latency of each operation is limited to 90,000 cycles.");
            $display("Pattern: %0d | Mode: %s", pat_cnt, pat_mode == 1'b0 ? "CALC" : "GAUSS");
            $display("        (Current Latency: %0d cycles)", current_latency);
            $display("=======================================================\n");
            dump_trace_and_fail;
        end

        if (^out_valid === 1'bx) begin
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] Specifications: The out_valid must be asserted in specified cycles. (Found X state)");
            $display("        (Current Latency: %0d cycles)", current_latency);
            $display("=======================================================\n");
            dump_trace_and_fail;
        end
        else if (out_valid === 1'b1) begin
            
            if (^out_data === 1'bx) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] out_data contains X/Z states while out_valid is high!");
                $display("Got: %h", out_data);
                $display("=======================================================\n");
                dump_trace_and_fail;
            end
            
            // Strict In-Order Checking for both CALC and GAUSS
            if (out_data !== golden_ans_queue[ans_head]) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Specifications: The out_data should be correct and STRICTLY IN-ORDER.");
                $display("Pattern: %0d | Mode: %s | Current Latency: %0d cycles", pat_cnt, pat_mode == 1'b0 ? "CALC" : "GAUSS", current_latency);
                if (pat_mode == 1'b1 && ans_head == ans_tail - 1) begin
                    $display("-> [Warning] This is the Last Position (EOF marker). It must match exactly.");
                end
                $display("Expected Output Index %0d: %h", ans_head, golden_ans_queue[ans_head]);
                $display("Got Data:               %h", out_data);
                $display("=======================================================\n");
                dump_trace_and_fail;
            end
            
            ans_head = ans_head + 1;
        end
    end
    
    // Check out_valid drop
    @(negedge clk1);
    current_latency = current_latency + 1;
    if (out_valid !== 1'b0) begin 
        $display("\n===================== ERROR DUMP ======================");
        $display("[Error] Specifications: out_valid must be pulled down immediately after all data is output.");
        $display("        (Detected extra out_valid high cycles! Your RTL might be outputting MORE data than expected!)");
        $display("Pattern: %0d | Mode: %s | Current Latency: %0d cycles", pat_cnt, pat_mode == 1'b0 ? "CALC" : "GAUSS", current_latency);
        $display("Expected Total Outputs: %0d", ans_tail);
        $display("=======================================================\n");
        dump_trace_and_fail;
    end
    
    total_latency = total_latency + current_latency;
    is_waiting_output = 1'b0;

    // Assure out_valid remains low during inter-pattern delay
    delay_cycles = {$random(seed)} % 3 + 2; // Spec: 2~4 cycles delay
    for (d = 0; d < delay_cycles; d = d + 1) begin
        @(negedge clk1);
        if (out_valid !== 1'b0) begin 
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] Specifications: The out_valid must be asserted in specified cycles.");
            $display("        (out_valid should remain strictly low during idle phase)");
            $display("=======================================================\n");
            FAIL_DOG_task;
        end
    end

end endtask


//================================================================
// Enhanced AXI Protocol Checkers (Unrolled for clk2)
//================================================================
always @(negedge clk2 or negedge rst_n) begin 
    if (!rst_n) begin 
        ar_timeout_cnt_clk2 <= 0;
        r_timeout_cnt_clk2 <= 0; 
        ar_to_r_timeout_cnt_clk2 <= 0; 
        outstanding_cnt_clk2 <= 0; 
        snoop_head_clk2 <= 0; 
        snoop_tail_clk2 <= 0;
        
        past_ar_valid_clk2 <= 0;
        past_ar_addr_clk2  <= 0;
        past_ar_ready_clk2 <= 0;
        past_r_valid_clk2  <= 0;
        past_r_data_clk2   <= 0;
        past_r_ready_clk2  <= 0;
    end else begin 
        if ($time > 100) begin 
            // -----------------------------------------------------------
            // 1. Instant Validity & Overflow Checks
            // -----------------------------------------------------------
            if (^ar_valid_clk2 === 1'bx || ^r_valid_clk2 === 1'bx) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] VALID signals cannot be X or Z. (clk2)"); 
                $display("=======================================================\n");
                FAIL_DOG_task;
            end 
            
            // Rule 4: AR_ADDR should be valid when AR_VALID is high
            if (ar_valid_clk2 === 1'b1 && ^ar_addr_clk2 === 1'bx) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 4: ar_addr_clk2 contains X/Z states when ar_valid is high!"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end
            
            // Rule 8: 僅檢查 R_DATA，移除 R_RESP 檢查以避免 Testbed 懸空造成誤判
            if (r_valid_clk2 === 1'b1 && ^r_data_clk2 === 1'bx) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 8: r_data_clk2 contains X/Z states when r_valid is high!"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end
            
            // Rule 3
            if (ar_valid_clk2 === 1'b1 && snoop_word_addr_clk2 > 16'hFFFF) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 3: AR_ADDR should be within the legal range (0~65535 word limit). (clk2: %h)", ar_addr_clk2); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
            
            // Rule 5
            if (ar_valid_clk2 === 1'b0 && ar_addr_clk2 !== 32'b0) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 5: AR_ADDR should be reset, when AR_VALID is low. (clk2)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
            
            // Rule 9
            if (r_valid_clk2 === 1'b0 && r_data_clk2 !== 64'b0) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 9: R_DATA should be reset when R_VALID is low. (clk2)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 

            // Snoop Queue Overflow Protect (Size = 2048)
            if (outstanding_cnt_clk2 > 2000) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] AXI Snoop Queue Overflow! Outstanding > 2000 in clk2."); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 

            // -----------------------------------------------------------
            // 2. Stability Checks (Requires valid past history)
            // -----------------------------------------------------------
            if (past_ar_valid_clk2 === 1'b1 && past_ar_ready_clk2 !== 1'b1) begin 
                if (ar_valid_clk2 !== 1'b1 || ar_addr_clk2 !== past_ar_addr_clk2) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] Rule 2: AR_VALID and AR_ADDR should remain stable until AR_READY goes high. (clk2)"); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
            end 
            
            if (past_r_valid_clk2 === 1'b1 && past_r_ready_clk2 !== 1'b1) begin 
                // Rule 10: 僅檢查 R_VALID, R_DATA 穩定度
                if (r_valid_clk2 !== 1'b1 || r_data_clk2 !== past_r_data_clk2) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] Rule 10: R_VALID and R_DATA should remain stable until R_READY goes high. (clk2)"); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
            end 
        end 
        
        // -----------------------------------------------------------
        // 3. Snoop Queue and Outstanding Check
        // -----------------------------------------------------------
        if (ar_fire_clk2) begin 
            snoop_addr_queue_clk2[snoop_tail_clk2[10:0]] <= ar_addr_clk2;
            snoop_tail_clk2 <= snoop_tail_clk2 + 1; 
        end 
        
        if (r_fire_clk2) begin 
            if (outstanding_cnt_clk2 > 0 && snoop_head_clk2 < snoop_tail_clk2) begin 
                if (r_data_clk2 !== golden_dram[ snoop_word_addr_clk2 ]) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] AXI SNOOP FAIL: R_DATA mismatch in clk2."); 
                    $display("Requested Addr: %h (Word Index: %h)", snoop_addr_queue_clk2[snoop_head_clk2[10:0]], snoop_word_addr_clk2);
                    $display("Expected Data : %h", golden_dram[ snoop_word_addr_clk2 ]); 
                    $display("Got R_DATA    : %h", r_data_clk2); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
                snoop_head_clk2 <= snoop_head_clk2 + 1;
            end else begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] AXI FAIL: Unexpected R_VALID (Queue Empty or Zero Outstanding) in clk2."); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end 
        
        if (ar_fire_clk2 && !r_fire_clk2) outstanding_cnt_clk2 <= outstanding_cnt_clk2 + 1;
        else if (!ar_fire_clk2 && r_fire_clk2) outstanding_cnt_clk2 <= outstanding_cnt_clk2 - 1;
        
        if (outstanding_cnt_clk2 < 0) begin 
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] AXI FAIL: Unexpected R_VALID (Outstanding < 0) in clk2."); 
            $display("=======================================================\n"); 
            FAIL_DOG_task;
        end 
        
        // -----------------------------------------------------------
        // 4. Timeout Checks
        // -----------------------------------------------------------
        if (outstanding_cnt_clk2 > 0 && r_valid_clk2 === 1'b0) begin 
            ar_to_r_timeout_cnt_clk2 <= ar_to_r_timeout_cnt_clk2 + 1;
            if (ar_to_r_timeout_cnt_clk2 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 6: After read address channel communicate, R_VALID and R_READY should be pulled high in 0~500 cycles. (clk2)"); 
                $display("=======================================================\n");
                FAIL_DOG_task; 
            end 
        end else begin 
            ar_to_r_timeout_cnt_clk2 <= 0;
        end 
        
        if (ar_valid_clk2 === 1'b1 && ar_ready_clk2 !== 1'b1) begin 
            ar_timeout_cnt_clk2 <= ar_timeout_cnt_clk2 + 1;
            if (ar_timeout_cnt_clk2 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 1: After AR_VALID is high, AR_READY should be pulled high in 0~500 cycles. (clk2)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end else ar_timeout_cnt_clk2 <= 0;
        
        if (r_valid_clk2 === 1'b1 && r_ready_clk2 !== 1'b1) begin 
            r_timeout_cnt_clk2 <= r_timeout_cnt_clk2 + 1;
            if (r_timeout_cnt_clk2 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 7: After R_VALID is high, R_READY should be pulled high in 0~500 cycles. (clk2)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end else r_timeout_cnt_clk2 <= 0;
        
        // -----------------------------------------------------------
        // 5. Update Past Status
        // -----------------------------------------------------------
        past_ar_valid_clk2 <= ar_valid_clk2;
        past_ar_addr_clk2  <= ar_addr_clk2; 
        past_ar_ready_clk2 <= ar_ready_clk2;
        past_r_valid_clk2  <= r_valid_clk2; 
        past_r_data_clk2   <= r_data_clk2; 
        past_r_ready_clk2  <= r_ready_clk2;
    end 
end 

//================================================================
// Enhanced AXI Protocol Checkers (Unrolled for clk3)
//================================================================
always @(negedge clk3 or negedge rst_n) begin 
    if (!rst_n) begin 
        ar_timeout_cnt_clk3 <= 0;
        r_timeout_cnt_clk3 <= 0; 
        ar_to_r_timeout_cnt_clk3 <= 0; 
        outstanding_cnt_clk3 <= 0; 
        snoop_head_clk3 <= 0; 
        snoop_tail_clk3 <= 0;
        
        past_ar_valid_clk3 <= 0;
        past_ar_addr_clk3  <= 0;
        past_ar_ready_clk3 <= 0;
        past_r_valid_clk3  <= 0;
        past_r_data_clk3   <= 0;
        past_r_ready_clk3  <= 0;
    end else begin 
        if ($time > 100) begin 
            // -----------------------------------------------------------
            // 1. Instant Validity & Overflow Checks
            // -----------------------------------------------------------
            if (^ar_valid_clk3 === 1'bx || ^r_valid_clk3 === 1'bx) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] VALID signals cannot be X or Z. (clk3)"); 
                $display("=======================================================\n");
                FAIL_DOG_task;
            end 
            
            // Rule 4
            if (ar_valid_clk3 === 1'b1 && ^ar_addr_clk3 === 1'bx) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 4: ar_addr_clk3 contains X/Z states when ar_valid is high!"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end
            
            // Rule 8: 僅檢查 R_DATA，移除 R_RESP 檢查
            if (r_valid_clk3 === 1'b1 && ^r_data_clk3 === 1'bx) begin
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 8: r_data_clk3 contains X/Z states when r_valid is high!"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end
            
            // Rule 3
            if (ar_valid_clk3 === 1'b1 && snoop_word_addr_clk3 > 16'hFFFF) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 3: AR_ADDR should be within the legal range (0~65535 word limit). (clk3: %h)", ar_addr_clk3); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
            
            // Rule 5
            if (ar_valid_clk3 === 1'b0 && ar_addr_clk3 !== 32'b0) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 5: AR_ADDR should be reset, when AR_VALID is low. (clk3)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
            
            // Rule 9
            if (r_valid_clk3 === 1'b0 && r_data_clk3 !== 64'b0) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 9: R_DATA should be reset when R_VALID is low. (clk3)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 

            if (outstanding_cnt_clk3 > 2000) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] AXI Snoop Queue Overflow! Outstanding > 2000 in clk3."); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 

            // -----------------------------------------------------------
            // 2. Stability Checks
            // -----------------------------------------------------------
            if (past_ar_valid_clk3 === 1'b1 && past_ar_ready_clk3 !== 1'b1) begin 
                if (ar_valid_clk3 !== 1'b1 || ar_addr_clk3 !== past_ar_addr_clk3) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] Rule 2: AR_VALID and AR_ADDR should remain stable until AR_READY goes high. (clk3)"); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
            end 
            
            if (past_r_valid_clk3 === 1'b1 && past_r_ready_clk3 !== 1'b1) begin 
                // Rule 10: 僅檢查 R_VALID, R_DATA 穩定度
                if (r_valid_clk3 !== 1'b1 || r_data_clk3 !== past_r_data_clk3) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] Rule 10: R_VALID and R_DATA should remain stable until R_READY goes high. (clk3)"); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
            end 
        end 
        
        // -----------------------------------------------------------
        // 3. Snoop Queue and Outstanding Check
        // -----------------------------------------------------------
        if (ar_fire_clk3) begin 
            snoop_addr_queue_clk3[snoop_tail_clk3[10:0]] <= ar_addr_clk3;
            snoop_tail_clk3 <= snoop_tail_clk3 + 1; 
        end 
        
        if (r_fire_clk3) begin 
            if (outstanding_cnt_clk3 > 0 && snoop_head_clk3 < snoop_tail_clk3) begin 
                if (r_data_clk3 !== golden_dram[ snoop_word_addr_clk3 ]) begin 
                    $display("\n===================== ERROR DUMP ======================");
                    $display("[Error] AXI SNOOP FAIL: R_DATA mismatch in clk3."); 
                    $display("Requested Addr: %h (Word Index: %h)", snoop_addr_queue_clk3[snoop_head_clk3[10:0]], snoop_word_addr_clk3);
                    $display("Expected Data : %h", golden_dram[ snoop_word_addr_clk3 ]); 
                    $display("Got R_DATA    : %h", r_data_clk3); 
                    $display("=======================================================\n"); 
                    FAIL_DOG_task;
                end 
                snoop_head_clk3 <= snoop_head_clk3 + 1;
            end else begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] AXI FAIL: Unexpected R_VALID (Queue Empty or Zero Outstanding) in clk3."); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end 
        
        if (ar_fire_clk3 && !r_fire_clk3) outstanding_cnt_clk3 <= outstanding_cnt_clk3 + 1;
        else if (!ar_fire_clk3 && r_fire_clk3) outstanding_cnt_clk3 <= outstanding_cnt_clk3 - 1;
        
        if (outstanding_cnt_clk3 < 0) begin 
            $display("\n===================== ERROR DUMP ======================");
            $display("[Error] AXI FAIL: Unexpected R_VALID (Outstanding < 0) in clk3."); 
            $display("=======================================================\n"); 
            FAIL_DOG_task;
        end 
        
        // -----------------------------------------------------------
        // 4. Timeout Checks
        // -----------------------------------------------------------
        if (outstanding_cnt_clk3 > 0 && r_valid_clk3 === 1'b0) begin 
            ar_to_r_timeout_cnt_clk3 <= ar_to_r_timeout_cnt_clk3 + 1;
            if (ar_to_r_timeout_cnt_clk3 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 6: After read address channel communicate, R_VALID and R_READY should be pulled high in 0~500 cycles. (clk3)"); 
                $display("=======================================================\n");
                FAIL_DOG_task; 
            end 
        end else begin 
            ar_to_r_timeout_cnt_clk3 <= 0;
        end 
        
        if (ar_valid_clk3 === 1'b1 && ar_ready_clk3 !== 1'b1) begin 
            ar_timeout_cnt_clk3 <= ar_timeout_cnt_clk3 + 1;
            if (ar_timeout_cnt_clk3 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 1: After AR_VALID is high, AR_READY should be pulled high in 0~500 cycles. (clk3)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end else ar_timeout_cnt_clk3 <= 0;
        
        if (r_valid_clk3 === 1'b1 && r_ready_clk3 !== 1'b1) begin 
            r_timeout_cnt_clk3 <= r_timeout_cnt_clk3 + 1;
            if (r_timeout_cnt_clk3 > 500) begin 
                $display("\n===================== ERROR DUMP ======================");
                $display("[Error] Rule 7: After R_VALID is high, R_READY should be pulled high in 0~500 cycles. (clk3)"); 
                $display("=======================================================\n"); 
                FAIL_DOG_task;
            end 
        end else r_timeout_cnt_clk3 <= 0;
        
        // -----------------------------------------------------------
        // 5. Update Past Status
        // -----------------------------------------------------------
        past_ar_valid_clk3 <= ar_valid_clk3;
        past_ar_addr_clk3  <= ar_addr_clk3; 
        past_ar_ready_clk3 <= ar_ready_clk3;
        past_r_valid_clk3  <= r_valid_clk3; 
        past_r_data_clk3   <= r_data_clk3; 
        past_r_ready_clk3  <= r_ready_clk3;
    end 
end 

//================================================================
// Dog Tasks
//================================================================
task dump_trace_and_fail;
begin
    $display("\n%s========================================================%s", `C_RED, `C_RST);
    $display("%s   [!] DATA MISMATCH OR FATAL ERROR DETECTED !          %s", `C_RED, `C_RST);
    $display("%s   REPLAYING CALCULATION TRACE FOR PATTERN %0d...       %s", `C_RED, `C_RST, pat_cnt);
    $display("%s========================================================%s\n", `C_RED, `C_RST);
    error_dump_en = 1;
    calculate_golden_task;
    FAIL_DOG_task;
end endtask

task YOU_PASS_task;
begin
    if (min_latency_calc == 999999) min_latency_calc = 0;
    if (min_latency_gauss == 999999) min_latency_gauss = 0;

    $display("\n%s========================================================%s", `C_GRN, `C_RST);
    $display("%s    ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                        %s", `C_GRN, `C_RST);
    $display("%s   ▄▀            ▀▄      ▄▄                                %s", `C_GRN, `C_RST);
    $display("%s   █  ▀  ▀       ▀▄▄   █  █                                %s", `C_GRN, `C_RST);
    $display("%s   █   ▀▀            ▀▀▀   ▀▄       Congratulations !   %s", `C_GRN, `C_RST);
    $display("%s   █ ▀▄▄▄▄▀                █  ╭ %s", `C_GRN, `C_RST);
    $display("%s   ▀▄                    █  ╭ %s", `C_GRN, `C_RST);
    $display("%s    █   ▄▄   ▄▄▄▄▄    ▄▄   █      You have passed all patterns !  %s", `C_GRN, `C_RST);
    $display("%s    ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                %s", `C_GRN, `C_RST);
    $display("%s========================================================%s", `C_GRN, `C_RST);
    
    // Performance Statistics Report
    $display("%s[Performance Report]%s", `C_YEL, `C_RST);
    $display("%s  [CALC Mode]  Tested: %4d times | Avg: %5d cycles | Min: %5d | Max: %5d %s", 
        `C_CYA, count_calc,  count_calc ? (total_latency_calc / count_calc) : 0, min_latency_calc, max_latency_calc, `C_RST);
    $display("%s  [GAUSS Mode] Tested: %4d times | Avg: %5d cycles | Min: %5d | Max: %5d %s", 
        `C_CYA, count_gauss, count_gauss ? (total_latency_gauss / count_gauss) : 0, min_latency_gauss, max_latency_gauss, `C_RST);
    $display("%s--------------------------------------------------------%s", `C_GRN, `C_RST);
    $display("%s  Total Execution Cycles: %0d %s", `C_WHT, total_latency, `C_RST);
    $display("%s========================================================%s", `C_GRN, `C_RST);

    $display("\n%s[Coverage Information]%s", `C_YEL, `C_RST);
    $display("%s  [Tree Status] Max Prefix Tree Depth Encountered: %0d %s", `C_CYA, global_max_depth, `C_RST);
    if (global_max_depth < 8) begin
        $display("%s  [Warning] The tree depth in your current DRAM_init.dat is less than 8! %s", `C_YEL, `C_RST);
        $display("%s            Consider using a script to generate corner cases with depth=8%s", `C_YEL, `C_RST);
        $display("%s            to ensure your hardware stack won't overflow during the demo. %s", `C_YEL, `C_RST);
    end
    $display("%s========================================================%s\n", `C_GRN, `C_RST);

    $finish;
end endtask

task FAIL_DOG_task;
begin
    $display("\n%s========================================================%s", `C_RED, `C_RST);
    $display("%s    ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                        %s", `C_RED, `C_RST);
    $display("%s   ▄▀            ▀▄      ▄▄                                %s", `C_RED, `C_RST);
    $display("%s   █  x  x       ▀▄▄   █  █                                %s", `C_RED, `C_RST);
    $display("%s   █   ▄▄            ▀▀▀   ▀▄       Simulation Failed !   %s", `C_RED, `C_RST);
    $display("%s   █ ▄▀▀▀▀▄                █  ╭ %s", `C_RED, `C_RST);
    $display("%s   ▀▄                    █  ╭ %s", `C_RED, `C_RST);
    $display("%s    █   ▄▄   ▄▄▄▄▄    ▄▄   █      Go check your waves...          %s", `C_RED, `C_RST);
    $display("%s    ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                %s", `C_RED, `C_RST);
    $display("%s========================================================%s\n", `C_RED, `C_RST);
    $finish;
end endtask

endmodule