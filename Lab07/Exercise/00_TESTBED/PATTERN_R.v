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

`define PAT_NUM 1200

module PATTERN(
    output reg      clk1,
    output reg      clk2,
    output reg      clk3,

    output reg      rst_n,
    // AXI4-Lite Master (clk2)
    input      [31:0]  ar_addr_clk2, 
    input              ar_valid_clk2, 
    input              ar_ready_clk2,
    input      [63:0]  r_data_clk2,  
    input              r_valid_clk2, 
    input              r_ready_clk2,

    // AXI4-Lite Slave (clk3)
    input      [31:0]  ar_addr_clk3, 
    input              ar_valid_clk3, 
    input              ar_ready_clk3,
    input      [63:0]  r_data_clk3,  
    input              r_valid_clk3, 
    input              r_ready_clk3,

    output reg         in_mode_valid,
    output reg         in_mode,
    output reg         in_valid,
    output reg [1:0]   in_bank,
    output reg [5:0]   in_src_row,
    
    input              out_valid,
    input      [63:0]  out_data
);

real    CYCLE_clk1 = `CYCLE_TIME_clk1;
real    CYCLE_clk2 = `CYCLE_TIME_clk2;
real    CYCLE_clk3 = `CYCLE_TIME_clk3;

//================================================================
// parameters & integer
//================================================================
integer total_latency, latency;
integer i_pat, i, b, c;
integer out_cnt;

// ===== Debug 檔案指標 =====
integer debug_file;

reg [63:0] golden_DRAM [0:65535];
reg signed [63:0] calc_ans [0:3];
reg [63:0] guass_ans [0:1023];
integer guass_ans_cnt;

reg save_mode;
reg [1:0] save_bank [0:3];
reg [5:0] save_src_row [0:3];

//================================================================
// clock
//================================================================
initial begin
    clk1 = 0;
    clk2 = 0;
    clk3 = 0;
end

always #(CYCLE_clk1/2.0) clk1 = ~clk1;
always #(CYCLE_clk2/2.0) clk2 = ~clk2;
always #(CYCLE_clk3/2.0) clk3 = ~clk3;

//================================================================
// initial
//================================================================
initial begin
    debug_file = $fopen("debug.txt", "w");
    if (debug_file == 0) begin
        $display("Failed to open debug.txt!");
        $finish;
    end
    $fdisplay(debug_file, "===============================================");
    $fdisplay(debug_file, "           HARVESTER DEBUG LOG FILE            ");
    $fdisplay(debug_file, "===============================================\n");

    $readmemh("../00_TESTBED/DRAM_init.dat", golden_DRAM);
    reset_task;
    for (i_pat = 0; i_pat < `PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_and_check_task;
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Cycle: %5d\033[m", i_pat, latency);
    end
    YOU_PASS_task;
end 

//================================================================
// Tasks
//================================================================
task reset_task; begin
    rst_n = 1'b1;
    in_mode_valid = 1'b0;
    in_mode = 1'bx;
    in_valid = 1'b0;
    in_bank = 2'bx;
    in_src_row = 6'bx;
    total_latency = 0;

    force clk1 = 0;
    force clk2 = 0;
    force clk3 = 0;
    
    #(CYCLE_clk1 * 2);
    rst_n = 1'b0;
    #(CYCLE_clk1 * 3);
    rst_n = 1'b1;

    if (out_valid !== 1'b0 || out_data !== 64'd0 || 
        ar_valid_clk2 !== 1'b0 || r_ready_clk2 !== 1'b0) begin
        $display("\033[1;31m [ SPEC MAIN-1 FAIL ] Signals are not reset properly at initial state! \033[m");
        $fclose(debug_file);
        $finish;
    end

    #(CYCLE_clk1 * 2);
    release clk1;
    release clk2;
    release clk3;
end endtask

task input_task; begin
    repeat($urandom_range(2, 4)) @(negedge clk1);

    if(i_pat % 2 == 0) begin
        save_mode = 0;
    end
    else begin
        save_mode = 1;
    end
    
    for (i = 0; i < 4; i = i + 1) begin
        save_bank[i] = $urandom_range(0, 3);
        save_src_row[i] = $urandom_range(0, 63);
    end

    if (save_mode == 0) begin
        $fdisplay(debug_file, "\n[START PATTERN %4d] Mode: CALC", i_pat);
        golden_calc_task;
    end
    else begin
        golden_gauss_task;
        $fdisplay(debug_file, "\n[START PATTERN %4d] Mode: GUASS (Target Outputs: %0d)", i_pat, guass_ans_cnt);
    end

    in_mode_valid = 1'b1;
    in_mode = save_mode;
    @(negedge clk1);
    in_mode_valid = 1'b0;
    in_mode = 1'bx;

    in_valid = 1'b1;
    for (i = 0; i < 4; i = i + 1) begin
        in_bank = save_bank[i];
        in_src_row = save_src_row[i];
        @(negedge clk1);
    end

    in_valid = 1'b0;
    in_bank = 2'bx;
    in_src_row = 6'bx;
end endtask

task wait_and_check_task; begin
    latency = 0;
    out_cnt = 0;
    
    // SPEC: "The latency is from the falling edge of in_valid to the falling edge of out_valid for the last output"
    // At this point, we are exactly at the negedge clk1 where in_valid went low.

    if (save_mode == 0) begin
        // CALC MODE: Wait for 4 discontinuous valid outputs
        while (out_cnt < 4) begin
            latency = latency + 1;
            
            // SPEC: "The execution latency of each operation is limited in 20,000 cycles (clk1)."
            if (latency > 40000) begin 
                $display("\033[1;31m [ SPEC MAIN-2 FAIL ] Execution Latency exceeds 40000 cycles! \033[m");
                $fdisplay(debug_file, "ERROR: Latency exceeds 40000 cycles!");
                $fclose(debug_file);
                $finish; 
            end 

            if (out_valid === 1'b1) begin
                $fdisplay(debug_file, "  -> Out[%0d] | Golden: %16h (%20d) | Yours: %16h (%20d)", 
                          out_cnt, calc_ans[out_cnt], $signed(calc_ans[out_cnt]), out_data, $signed(out_data));

                if (out_data !== calc_ans[out_cnt]) begin
                    $display("\033[1;31m====================================================================\033[m");
                    $display("\033[1;31m [ CALC MODE FAIL ] Mismatch at Pattern %0d, Output %0d! \033[m", i_pat, out_cnt);
                    $display("\033[1;33m [Expected Answer] \033[m Hex: %16h  |  Dec: %20d", calc_ans[out_cnt], $signed(calc_ans[out_cnt]));
                    $display("\033[1;35m [Your Answer    ] \033[m Hex: %16h  |  Dec: %20d", out_data, $signed(out_data));
                    $display("\033[1;31m====================================================================\033[m");
                    $fdisplay(debug_file, ">>> FAIL: Mismatch detected here!");
                    $fclose(debug_file);
                    $finish;
                end
                out_cnt = out_cnt + 1;
            end
            @(negedge clk1);
        end
    end
    else begin
        // GUASS MODE: Wait for guass_ans_cnt valid outputs
        while (out_cnt < guass_ans_cnt) begin
            latency = latency + 1;
            
            if (latency > 20000) begin
                $display("\033[1;31m [ SPEC MAIN-2 FAIL ] Execution Latency exceeds 20000 cycles! \033[m");
                $fdisplay(debug_file, "ERROR: Latency exceeds 20000 cycles!");
                $fclose(debug_file);
                $finish;
            end

            if (out_valid === 1'b1) begin
                $fdisplay(debug_file, "  -> Out[%0d] | Golden: %16h | Yours: %16h", 
                          out_cnt, guass_ans[out_cnt], out_data);

                if (out_data !== guass_ans[out_cnt]) begin
                    $display("\033[1;31m====================================================================\033[m");
                    $display("\033[1;31m [ GUASS MODE FAIL ] Mismatch at Pattern %0d, Output %0d! \033[m", i_pat, out_cnt);
                    $display("\033[1;33m [Expected Answer] \033[m Hex: %16h  |  Dec (Bits[62:32]): %d", guass_ans[out_cnt], guass_ans[out_cnt][62:32]);
                    $display("\033[1;35m [Your Answer    ] \033[m Hex: %16h  |  Dec (Bits[62:32]): %d", out_data, out_data[62:32]);
                    $display("\033[1;31m====================================================================\033[m");
                    $fdisplay(debug_file, ">>> FAIL: Mismatch detected here!");
                    $fclose(debug_file);
                    $finish;
                end
                out_cnt = out_cnt + 1;
            end
            @(negedge clk1);
        end
    end

    // SPEC: "...to the falling edge of out_valid for the last output, including the output cycles!!!!!!"
    // This loop ensures we keep counting latency until out_valid officially drops to 0
    while (out_valid === 1'b1) begin
        latency = latency + 1;
        if (latency > 20000) begin
            $display("\033[1;31m [ SPEC MAIN-2 FAIL ] Execution Latency exceeds 20000 cycles! \033[m");
            $fdisplay(debug_file, "ERROR: Latency exceeds 20000 cycles!");
            $fclose(debug_file);
            $finish;
        end
        @(negedge clk1);
    end

    total_latency = total_latency + latency;
end endtask

//================================================================
// Golden Algorithms (CALC Recursive Traversal)
//================================================================

// 1. Silent Evaluator (用來先算出 Golden Answer 寫在標題)
task automatic evaluate_node_silent;
    input  [15:0]  addr;
    output signed [63:0] val;
    reg [63:0] current_node;
    reg signed [63:0] l_val, r_val; 
    begin
        current_node = golden_DRAM[addr];
        if (current_node[63] == 1'b0) begin
            val = $signed(current_node[62:32]);
        end 
        else begin
            if (current_node[33:32] == 2'b11) begin
                evaluate_node_silent(current_node[31:16], l_val);
                evaluate_node_silent(current_node[15:0], r_val);
                val = l_val >>> r_val[5:0];
            end
            else begin
                evaluate_node_silent(current_node[31:16], l_val);
                evaluate_node_silent(current_node[15:0], r_val);
                case(current_node[33:32])
                    2'b00: val = l_val + r_val;
                    2'b01: val = l_val - r_val;
                    2'b10: val = l_val * r_val;
                endcase
            end
        end
    end
endtask

// 縮排輔助 Task
task automatic print_indent;
    input integer d;
    integer j;
    begin
        for (j = 0; j < d; j = j + 1) begin
            $fwrite(debug_file, "    ");
        end
    end
endtask

// 2. Verbose Evaluator (用來印出詳細的樹狀足跡)
task automatic evaluate_node_trace;
    input  [15:0]  addr;
    input  integer depth;
    input  integer tree_idx;
    output signed [63:0] val;
    
    reg [63:0] current_node;
    reg signed [63:0] l_val, r_val;
    reg [15:0] left_addr, right_addr;
    reg [1:0] op;
    begin
        current_node = golden_DRAM[addr];

        if (current_node[63] == 1'b0) begin
            val = $signed(current_node[62:32]);
            if (depth == 0) begin
                $fdisplay(debug_file, "ROOT %0d [NUM] Val: %0d (Raw: %016x)", 
                          tree_idx, val, current_node);
            end else begin
                print_indent(depth);
                $fdisplay(debug_file, " ->  %04x [NUM] Val: %0d (Raw: %016x)", 
                          addr, val, current_node);
            end
        end
        else begin
            op = current_node[33:32];
            left_addr = current_node[31:16];
            right_addr = current_node[15:0];

            if (depth == 0) begin
                if (op == 2'b00) begin
                    $fdisplay(debug_file, "ROOT %0d [ADD (+)] Left:%04x Right:%04x (Raw: %016x)", 
                              tree_idx, left_addr, right_addr, current_node);
                end else if (op == 2'b01) begin
                    $fdisplay(debug_file, "ROOT %0d [SUB (-)] Left:%04x Right:%04x (Raw: %016x)", 
                              tree_idx, left_addr, right_addr, current_node);
                end else if (op == 2'b10) begin
                    $fdisplay(debug_file, "ROOT %0d [MULT (*)] Left:%04x Right:%04x (Raw: %016x)", 
                              tree_idx, left_addr, right_addr, current_node);
                end else if (op == 2'b11) begin
                    $fdisplay(debug_file, "ROOT %0d [SHIFT (>>>)] Left:%04x Right:%04x (Raw: %016x)", 
                              tree_idx, left_addr, right_addr, current_node);
                end
            end else begin
                print_indent(depth);
                if (op == 2'b00) begin
                    $fdisplay(debug_file, " ->  %04x [ADD (+)] Left:%04x Right:%04x (Raw: %016x)", 
                              addr, left_addr, right_addr, current_node);
                end else if (op == 2'b01) begin
                    $fdisplay(debug_file, " ->  %04x [SUB (-)] Left:%04x Right:%04x (Raw: %016x)", 
                              addr, left_addr, right_addr, current_node);
                end else if (op == 2'b10) begin
                    $fdisplay(debug_file, " ->  %04x [MULT (*)] Left:%04x Right:%04x (Raw: %016x)", 
                              addr, left_addr, right_addr, current_node);
                end else if (op == 2'b11) begin
                    $fdisplay(debug_file, " ->  %04x [SHIFT (>>>)] Left:%04x Right:%04x (Raw: %016x)", 
                              addr, left_addr, right_addr, current_node);
                end
            end

            evaluate_node_trace(left_addr, depth + 1, tree_idx, l_val);
            evaluate_node_trace(right_addr, depth + 1, tree_idx, r_val);

            print_indent(depth);
            if (op == 2'b11) begin
                val = l_val >>> r_val[5:0];
                $fdisplay(debug_file, " ==> Calc: %0d >> %0d = %0d", l_val, r_val[5:0], val);
            end else begin
                case(op)
                    2'b00: begin 
                        val = l_val + r_val; 
                        $fdisplay(debug_file, " ==> Calc: %0d + %0d = %0d", l_val, r_val, val); 
                    end
                    2'b01: begin 
                        val = l_val - r_val; 
                        $fdisplay(debug_file, " ==> Calc: %0d - %0d = %0d", l_val, r_val, val); 
                    end
                    2'b10: begin 
                        val = l_val * r_val; 
                        $fdisplay(debug_file, " ==> Calc: %0d * %0d = %0d", l_val, r_val, val); 
                    end
                endcase
            end
        end
    end
endtask

// 3. Main CALC Task 控制器
task golden_calc_task; 
    reg signed [63:0] temp_val;
begin
    for (b = 0; b < 4; b = b + 1) begin
        // Step 1: 預先算出答案
        evaluate_node_silent({save_bank[b], save_src_row[b], 8'd0}, calc_ans[b]);
        
        // Step 2: 印出美觀的 Header (包含剛算出的答案)
        $fdisplay(debug_file, "--- Pattern %0d: Bank %0d, Src_Row %0d (Golden: %0d) ---", 
                  i_pat, save_bank[b], save_src_row[b], calc_ans[b]);
                  
        // Step 3: 印出詳細的節點走訪紀錄
        evaluate_node_trace({save_bank[b], save_src_row[b], 8'd0}, 0, b, temp_val);
        $fdisplay(debug_file, " "); // 樹與樹之間留空行
    end
end endtask

//================================================================
// Golden Algorithms (GUASS)
//================================================================
function integer get_sqrt;
    input [127:0] val;
    reg [63:0] l, r, m;
    reg [127:0] m_sq;
    begin
        l = 0;
        r = 64'hFFFFFFFF;
        get_sqrt = 0;
        while (l <= r) begin
            m = (l + r) >> 1;
            m_sq = m * m;
            if (m_sq <= val) begin
                get_sqrt = m;
                l = m + 1;
            end else begin
                r = m - 1;
            end
        end
    end
endfunction

task golden_gauss_task;
    reg [63:0] word;
    reg [30:0] val;
    reg [63:0] sum;
    integer valid_count;
    reg [63:0] mu;
    reg [127:0] var_sum;
    reg [127:0] variance;
    reg [63:0] sigma, lower_bound, upper_bound;
    reg is_last;
begin
    sum = 0;
    valid_count = 0;
    
    for (b = 0; b < 4; b = b + 1) begin
        for (c = 0; c < 256; c = c + 1) begin
            word = golden_DRAM[{save_bank[b], save_src_row[b], c[7:0]}];
            if (word[63] == 1'b0) begin
                val = word[62:32];
                sum = sum + val;
                valid_count = valid_count + 1;
            end
        end
    end
    
    mu = (valid_count > 0) ? (sum / valid_count) : 0;
    var_sum = 0;

    for (b = 0; b < 4; b = b + 1) begin
        for (c = 0; c < 256; c = c + 1) begin
            word = golden_DRAM[{save_bank[b], save_src_row[b], c[7:0]}];
            if (word[63] == 1'b0) begin
                val = word[62:32];
                if (val >= mu) begin
                    var_sum = var_sum + ((val - mu) * (val - mu));
                end
                else begin
                    var_sum = var_sum + ((mu - val) * (mu - val));
                end
            end
        end
    end

    variance = (valid_count > 0) ? (var_sum / valid_count) : 0;
    sigma = get_sqrt(variance);
    lower_bound = (mu > sigma) ? (mu - sigma) : 0;
    upper_bound = mu + sigma;

    $fdisplay(debug_file, "  -> [GUASS Info] Mu = %d, Sigma = %d", mu, sigma);
    $fdisplay(debug_file, "  -> [GUASS Info] Lower Bound = %d, Upper Bound = %d", lower_bound, upper_bound);

    guass_ans_cnt = 0;
    for (b = 0; b < 4; b = b + 1) begin
        for (c = 0; c < 256; c = c + 1) begin
            word = golden_DRAM[{save_bank[b], save_src_row[b], c[7:0]}];
            is_last = (b == 3 && c == 255);
            
            if (word[63] == 1'b0) begin
                val = word[62:32];
                if ((val >= lower_bound && val <= upper_bound) || is_last) begin
                    guass_ans[guass_ans_cnt] = word;
                    guass_ans_cnt = guass_ans_cnt + 1;
                end
            end
            else if (is_last) begin
                guass_ans[guass_ans_cnt] = word;
                guass_ans_cnt = guass_ans_cnt + 1;
            end
        end
    end
end endtask

//================================================================
// Background AXI Monitors
//================================================================
integer ar_timeout_clk2;
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        ar_timeout_clk2 <= 0;
    end 
    else begin
        if (ar_valid_clk2 && !ar_ready_clk2) begin
            ar_timeout_clk2 <= ar_timeout_clk2 + 1;
            if (ar_timeout_clk2 > 500) begin
                $display("\033[1;31m [ AXI TIMEOUT FAIL - CLK2 ] ar_ready_clk2 no response!\033[m");
                $fclose(debug_file);
                $finish;
            end
        end 
        else begin
            ar_timeout_clk2 <= 0;
        end
    end
end

integer ar_timeout_clk3;
always @(posedge clk3 or negedge rst_n) begin
    if (!rst_n) begin
        ar_timeout_clk3 <= 0;
    end 
    else begin
        if (ar_valid_clk3 && !ar_ready_clk3) begin
            ar_timeout_clk3 <= ar_timeout_clk3 + 1;
            if (ar_timeout_clk3 > 500) begin
                $display("\033[1;31m [ AXI TIMEOUT FAIL - CLK3 ] ar_ready_clk3 no response!\033[m");
                $fclose(debug_file);
                $finish;
            end
        end 
        else begin
            ar_timeout_clk3 <= 0;
        end
    end
end

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("* Congratulations!                                                      *");
    $display("* Your execution cycles = %7d cycles                                  *", total_latency);
    $display("* Your clock period = %.1f ns                                         *", CYCLE_clk1);
    $display("* Total Latency = %.1f ns                                             *", total_latency*CYCLE_clk1);
    $display("*************************************************************************");
    $fclose(debug_file);
    $finish;
end endtask

endmodule