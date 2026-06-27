/**************************************************************************/
// MODULE: PATTERN
// FILE NAME: PATTERN.v
// DESCRIPTION: LAB03 Tree Harvester / AXI4-Lite / DRAM Control
/**************************************************************************/

`define PAT_NUM 500
`ifdef RTL
    `define CYCLE_TIME 8.0
`endif
`ifdef GATE
    `define CYCLE_TIME 8.0
`endif

module PATTERN(
    output reg      clk,
    output reg      rst_n,
    // AXI4-Lite Master (Inputs from Harvester)
    input [31:0]    aw_addr,
    input           aw_valid,
    input           aw_ready,
    input [63:0]    w_data,
    input           w_valid,
    input           w_ready,
    input [1:0]     b_resp,
    input           b_valid,
    input           b_ready,
    input [31:0]    ar_addr,
    input           ar_valid,
    input           ar_ready,
    input [63:0]    r_data,
    input [1:0]     r_resp,
    input           r_valid,
    input           r_ready,
    // System Inputs (Driven by Pattern)
    output reg       in_mode_valid,
    output reg [1:0] in_mode,
    output reg       in_valid,
    output reg [1:0] in_bank,
    output reg [5:0] in_src_row,
    output reg [5:0] in_dst_row,
    output reg [63:0]in_data,
    // System Outputs (Monitored by Pattern)
    input             out_valid,
    input [63:0]      out_data
);

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer total_latency, latency;
integer i_pat, i, out_cnt;
real CYCLE = `CYCLE_TIME;

// Golden Data
reg [63:0] golden_DRAM [0:65535];
reg signed [63:0] calc_ans [0:3];
reg [63:0] sort_buffer [0:1023];

// Saved Input Values
reg [1:0] save_mode, save_bank;
reg [5:0] save_src_row, save_dst_row;
reg [63:0] save_write_buffer [0:255];

// AXI Monitoring Registers (Stability Check)
reg aw_hs_done;
reg [31:0] last_aw_addr, last_ar_addr;
reg [63:0] last_w_data;
reg        last_aw_valid, last_ar_valid, last_w_valid;
reg        last_aw_ready, last_ar_ready, last_w_ready;
reg        last_b_valid;
reg        last_b_ready;
reg [1:0]  last_b_resp;
reg [63:0] last_r_data;
reg [1:0]  last_r_resp;
reg        last_r_valid;
reg        last_r_ready;
reg        is_reset_done; 

//---------------------------------------------------------------------
//   CLOCK GENERATION
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//   MAIN SIMULATION
//---------------------------------------------------------------------
initial begin
    is_reset_done = 0;
    $readmemh("../00_TESTBED/DRAM_init.dat", golden_DRAM);
    reset_task; 

    for (i_pat = 0; i_pat < `PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        main_wait_and_check_task; 
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Cycle: %5d\033[m", i_pat, latency);
    end
    YOU_PASS_task;
end

//---------------------------------------------------------------------
//   SPEC AXI MONITOR (Priority: AXI 1-4)
//---------------------------------------------------------------------

// SPEC AXI-1: Signal reset check (negedge)
// SPEC AXI-1: Data, address and response should be reset when valid is low.
always @(negedge clk) begin
    if (is_reset_done && rst_n) begin
        // --- 1. Write Address Channel (AW) ---
        if (!aw_valid && aw_addr !== 32'd0) begin 
            $display("SPEC AXI-1 FAIL-1"); 
            $finish; 
        end
        
        // --- 2. Write Data Channel (W) ---
        if (!w_valid && w_data !== 64'd0) begin 
            $display("SPEC AXI-1 FAIL-2"); 
            $finish; 
        end
        
        // --- 3. Write Response Channel (B) ---
        if (!b_valid && b_resp !== 2'd0) begin 
            $display("SPEC AXI-1 FAIL-3"); 
            $finish; 
        end
        
        // --- 4. Read Address Channel (AR) ---
        if (!ar_valid && ar_addr !== 32'd0) begin 
            $display("SPEC AXI-1 FAIL-4"); 
            $finish; 
        end
        
        // --- 5. Read Data Channel (R) ---
        if (!r_valid && (r_data !== 64'd0 || r_resp !== 2'd0)) begin 
            $display("SPEC AXI-1 FAIL-5"); 
            $finish; 
        end
    end
end

// SPEC AXI-2: Stability Check 
always @(posedge clk) begin
    if (!rst_n) begin
        last_aw_valid <= 1'b0;  
        last_aw_ready <= 1'b0;  

        last_ar_valid <= 1'b0;
        last_ar_ready <= 1'b0;

        last_w_valid <= 1'b0;
        last_w_ready <= 1'b0;

        last_b_valid <= 1'b0;
        last_b_ready <= 1'b0;

        last_r_valid <= 1'b0;
        last_r_ready <= 1'b0;

    end 
    else begin
        last_aw_addr  <= aw_addr;
        last_ar_addr  <= ar_addr;
        last_w_data   <= w_data;
        last_aw_valid <= aw_valid;
        last_ar_valid <= ar_valid;
        last_w_valid  <= w_valid;
        last_aw_ready <= aw_ready;
        last_ar_ready <= ar_ready;
        last_w_ready  <= w_ready;

        last_b_valid <= b_valid;
        last_b_ready <= b_ready;
        last_b_resp  <= b_resp;

        last_r_valid <= r_valid;
        last_r_ready <= r_ready;
        last_r_data  <= r_data;
        last_r_resp  <= r_resp;
    end
end

always @(negedge clk) begin
    if (last_aw_valid && !last_aw_ready) begin
        if (aw_addr !== last_aw_addr) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
    end

    if (last_w_valid && !last_w_ready) begin
        if (w_data !== last_w_data) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
    end

    if (last_b_valid && !last_b_ready) begin
        if (b_resp !== last_b_resp) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
    end

    if (last_ar_valid && !last_ar_ready) begin
        if (ar_addr !== last_ar_addr) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
    end

    if (last_r_valid && !last_r_ready) begin
        if (r_data !== last_r_data) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
        if (r_resp !== last_r_resp) begin 
            $display("SPEC AXI-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end
    end
end

// SPEC AXI-3: Dependency
integer aw_pending_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        aw_pending_cnt <= 0;
    end else begin
        case ({ (aw_valid && aw_ready), (w_valid && w_ready) })
            2'b10: aw_pending_cnt <= aw_pending_cnt + 1; 
            2'b01: aw_pending_cnt <= aw_pending_cnt - 1; 
        endcase
    end
end

always @(negedge clk) begin
    if (rst_n) begin
        if (w_valid && (aw_pending_cnt == 0) && !aw_valid) begin 
            $display("SPEC AXI-3 FAIL"); 
            $finish; 
        end
    end
end

// SPEC AXI-4: Address Range
always @(negedge clk) begin
    if (aw_valid && aw_addr > 32'd65535) begin 
        $display("SPEC AXI-4 FAIL"); 
        $finish; 
    end
    if (ar_valid && ar_addr > 32'd65535) begin 
        $display("SPEC AXI-4 FAIL"); 
        $finish; 
    end
end

// SPEC AXI-5 專用計數器
integer aw_timeout_cnt, ar_timeout_cnt;
integer w_timeout_cnt, r_timeout_cnt, b_timeout_cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        aw_timeout_cnt <= 0; 
        ar_timeout_cnt <= 0;
        w_timeout_cnt  <= 0; 
        r_timeout_cnt  <= 0;
        b_timeout_cnt  <= 0;
    end 
end
always @(negedge clk) begin
    // 1. AW Channel (50 cycles) 
    if (aw_valid && !aw_ready) begin
        aw_timeout_cnt <= aw_timeout_cnt + 1;
        if (aw_timeout_cnt > 50) begin 
            $display("SPEC AXI-5 FAIL"); 
            $finish; 
        end
    end 
    else begin
        aw_timeout_cnt <= 0;
    end

    // 2. AR Channel (50 cycles)
    if (ar_valid && !ar_ready) begin
        ar_timeout_cnt <= ar_timeout_cnt + 1;
        if (ar_timeout_cnt > 50) begin 
            $display("SPEC AXI-5 FAIL"); 
            $finish; 
        end
    end 
    else begin
        ar_timeout_cnt <= 0;
    end

    // 3. W Channel (100 cycles)
    if (w_valid && !w_ready) begin
        w_timeout_cnt <= w_timeout_cnt + 1;
        if (w_timeout_cnt > 100) begin 
            $display("SPEC AXI-5 FAIL"); 
            $finish; 
        end
    end 
    else begin
        w_timeout_cnt <= 0;
    end

    // 4. R Channel (100 cycles)
    if (r_valid && !r_ready) begin
        r_timeout_cnt <= r_timeout_cnt + 1;
        if (r_timeout_cnt > 100) begin 
            $display("SPEC AXI-5 FAIL"); 
            $finish; 
        end
    end 
    else begin
        r_timeout_cnt <= 0;
    end

    // 5. B Channel (100 cycles)
    if (b_valid && !b_ready) begin
        b_timeout_cnt <= b_timeout_cnt + 1;
        if (b_timeout_cnt > 100) begin 
            $display("SPEC AXI-5 FAIL"); 
            $finish; 
        end
    end 
    else begin
        b_timeout_cnt <= 0;
    end
end

// SPEC AXI-6 
integer w_wait_cnt, b_wait_cnt, r_wait_cnt;
reg wait_w_flag, wait_b_flag, wait_r_flag;
// SPEC AXI-6: W/B/R response timeout (150 cycles)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        w_wait_cnt <= 0; 
        b_wait_cnt <= 0; 
        r_wait_cnt <= 0;
        wait_w_flag <= 1'b0; 
        wait_b_flag <= 1'b0; 
        wait_r_flag <= 1'b0;
    end 
    else begin
        // --- 1. AW to W Handshake Check ---
        if (aw_valid && aw_ready && !(w_valid && w_ready)) 
            wait_w_flag <= 1'b1;
        else if (w_valid && w_ready) 
            wait_w_flag <= 1'b0;

        if (wait_w_flag) begin
            if (w_valid && w_ready) begin
                w_wait_cnt <= 0;
            end 
            else begin
                w_wait_cnt <= w_wait_cnt + 1;
                if (w_wait_cnt > 150) begin 
                    $display("SPEC AXI-6 FAIL"); 
                    $finish; 
                end
            end
        end 
        else w_wait_cnt <= 0;

        // --- 2. W to B Response Check ---
        if (w_valid && w_ready && !b_valid)
            wait_b_flag <= 1'b1;
        else if (b_valid) 
            wait_b_flag <= 1'b0;

        if (wait_b_flag) begin
            if (b_valid) begin
                b_wait_cnt <= 0;
            end else begin
                b_wait_cnt <= b_wait_cnt + 1;
                if (b_wait_cnt > 150) begin 
                    $display("SPEC AXI-6 FAIL"); 
                    $finish; 
                end
            end
        end 
        else b_wait_cnt <= 0;

        // --- 3. AR to R Handshake Check ---
        if (ar_valid && ar_ready && !(r_valid && r_ready))
            wait_r_flag <= 1'b1;
        else if (r_valid && r_ready) 
            wait_r_flag <= 1'b0;

        if (wait_r_flag) begin
            if (r_valid && r_ready) begin
                r_wait_cnt <= 0;
            end 
            else begin
                r_wait_cnt <= r_wait_cnt + 1;
                if (r_wait_cnt > 150) begin 
                    $display("SPEC AXI-6 FAIL-3"); 
                    $finish; 
                end
            end
        end 
        else r_wait_cnt <= 0;
    end
end

//---------------------------------------------------------------------
//   TASKS
//---------------------------------------------------------------------

task reset_task; begin
    rst_n = 1'b1;
    in_mode_valid = 1'b0; 
    in_valid = 1'b0; 
    in_mode = 2'bx;
    in_bank = 2'bx; 
    in_src_row = 6'bx; 
    in_dst_row = 6'bx; 
    in_data = 64'dx;

    total_latency = 0; 
    aw_hs_done = 1'b0;
    save_mode = 2'b11;
    
    force clk = 0;
    #CYCLE; 
    rst_n = 1'b0;
    //#(CYCLE * 2.0); 
    //rst_n = 1'b1;
    #(200.0);
    
    // SPEC MAIN-1
    if (out_valid !== 1'b0 || out_data !== 64'd0 || 
        aw_addr !== 32'd0 || aw_valid !== 1'b0 || aw_ready !== 1'b0 || 
        w_data !== 64'd0 || w_valid !== 1'b0 || w_ready !== 1'b0 || 
        b_resp !== 2'd0 || b_valid !== 1'b0 || b_ready !== 1'b0 ||
        ar_addr !== 32'd0 || ar_valid !== 1'b0 || ar_ready !== 1'b0 || 
        r_data !== 64'd0 || r_resp !== 2'd0 || r_valid !== 1'b0 || r_ready !== 1'b0) begin
            $display("SPEC MAIN-1 FAIL"); 
            $finish;
        end
    rst_n = 1'b1;

    release clk;
    repeat(5) @(negedge clk);
    is_reset_done = 1'b1; 
end 
endtask

task input_task; begin
    @(negedge clk);
    save_mode = $urandom_range(0, 3);
    save_bank = (save_mode == 2) ? 0 : $urandom_range(0, 3);
    save_src_row = (save_mode == 2) ? $urandom_range(0, 31) : $urandom_range(0, 62);
    save_dst_row = $urandom_range(32, 62);

    if (save_mode == 2) calc_golden_task;
    if (save_mode == 3) sort_golden_task;

    in_mode = save_mode;
    in_mode_valid = 1'b1;
    @(negedge clk);
    in_mode_valid = 1'b0;
    in_mode = 2'bx;

    if (save_mode == 0) begin
        in_valid = 1'b1;
        in_bank = save_bank; 
        in_src_row = save_src_row; 
        in_dst_row = 6'bx;
        in_data = 64'dx;
        @(negedge clk);
    end
    else if (save_mode == 1) begin // WRITE: 256 cycles input
        for (i = 0; i < 256; i = i + 1) begin
            in_valid = 1'b1;
            save_write_buffer[i] = {$urandom, $urandom};
            in_data = save_write_buffer[i];
            if (i == 0) begin
                in_bank = save_bank; 
                in_src_row = 6'bx; 
                in_dst_row = save_dst_row;
            end else begin
                in_bank = 2'bx; 
                in_src_row = 6'bx; 
                in_dst_row = 6'bx;
            end
            @(negedge clk);
        end
    end 
    else if (save_mode == 2) begin
        in_valid = 1'b1;
        in_bank = 2'bx; 
        in_src_row = save_src_row; 
        in_dst_row = 6'bx;
        in_data = 64'dx;
        @(negedge clk);
    end
    else if (save_mode == 3) begin
        in_valid = 1'b1;
        in_bank = 2'bx; 
        in_src_row = save_src_row; 
        in_dst_row = save_dst_row;
        in_data = 64'dx;
        @(negedge clk);
    end

    in_valid = 1'b0;
    in_bank = 2'bx; 
    in_src_row = 6'bx; 
    in_dst_row = 6'bx; 
    in_data = 64'dx;
end 
endtask

task automatic evaluate_node;
    input  [15:0]  addr;       // 16-bit word address {Bank, Row, Col}
    output signed [63:0] val;  // 64-bit signed result
    
    reg [63:0] current_node;
    reg [63:0] left_raw, right_raw;
    reg signed [63:0] l_final_num; 
    reg signed [63:0] r_final_num; 
    
    begin
        current_node = golden_DRAM[addr];

        if (current_node[63] == 1'b0) begin
            // --- Type 0: Leaf Node  ---
            val = $signed(current_node[62:32]);
        end 
        else begin
            // --- Type 1: Operator Node ---
            case(current_node[33:32])
                2'b11: begin
                    evaluate_node(current_node[31:16], l_final_num);
                    evaluate_node(current_node[15:0], r_final_num);
                    val = l_final_num >>> r_final_num[5:0];
                end
                
                default: begin
                    evaluate_node(current_node[31:16], l_final_num);
                    evaluate_node(current_node[15:0], r_final_num);
                    
                    case(current_node[33:32])
                        2'b00: val = l_final_num + r_final_num;
                        2'b01: val = l_final_num - r_final_num;
                        2'b10: val = l_final_num * r_final_num;
                    endcase
                end
            endcase
        end
    end
endtask

task calc_golden_task; begin
    // Bank 0
    evaluate_node({2'b00, save_src_row, 8'd0}, calc_ans[0]);
    // Bank 1
    evaluate_node({2'b01, save_src_row, 8'd0}, calc_ans[1]);
    // Bank 2
    evaluate_node({2'b10, save_src_row, 8'd0}, calc_ans[2]);
    // Bank 3
    evaluate_node({2'b11, save_src_row, 8'd0}, calc_ans[3]);
end 
endtask

task sort_golden_task;
    integer b, c, m, n;
    reg [63:0] tmp;
    begin
        for (b = 0; b < 4; b = b + 1) begin
            for (c = 0; c < 256; c = c + 1) begin
                sort_buffer[b * 256 + c] = golden_DRAM[{b[1:0], save_src_row, c[7:0]}];
            end
        end

        //Stable Bubble Sort
        for (m = 0; m < 1024 - 1; m = m + 1) begin
            for (n = 0; n < 1024 - 1 - m; n = n + 1) begin
                if (sort_buffer[n][62:32] > sort_buffer[n+1][62:32]) begin
                    tmp = sort_buffer[n];
                    sort_buffer[n] = sort_buffer[n+1];
                    sort_buffer[n+1] = tmp;
                end
            end
        end
    end
endtask

task main_wait_and_check_task; begin
    latency = 0;
    out_cnt = 0;

    while (out_valid !== 1'b1) begin
        if (out_data !== 64'd0) begin 
            $display("SPEC MAIN-3 FAIL"); 
            $finish; 
        end

        latency = latency + 1;
        if (latency > 10000) begin 
            $display("SPEC MAIN-2 FAIL"); 
            repeat(5) @(negedge clk);
            $finish; 
        end 
        @(negedge clk);
    end

    while (out_valid) begin
        if (save_mode == 0 && out_cnt >= 256) begin 
            $display("SPEC MAIN-3 FAIL"); 
            $finish; 
        end
        if (save_mode == 1 && out_cnt >= 1) begin 
            $display("SPEC MAIN-3 FAIL"); 
            $finish; 
        end
        if (save_mode == 2 && out_cnt >= 4) begin 
            $display("SPEC MAIN-3 FAIL"); 
            $finish; 
        end
        if (save_mode == 3 && out_cnt >= 1) begin 
            $display("SPEC MAIN-3 FAIL"); 
            $finish; 
        end
        //(check MAIN-4)
        check_ans_in_mode02;
    end

    if (save_mode == 0 && out_cnt != 256) begin 
        $display("SPEC MAIN-3 FAIL"); 
        $finish; 
    end
    if (save_mode == 2 && out_cnt != 4) begin 
        $display("SPEC MAIN-3 FAIL"); 
        $finish; 
    end
    //(check MAIN-5)
    check_ans_in_mode13;

    total_latency = total_latency + latency;
end endtask

task check_ans_in_mode02; begin
    if (save_mode == 0) begin 
            if (out_data !== golden_DRAM[{save_bank, save_src_row, out_cnt[7:0]}]) begin
                $display("SPEC MAIN-4 FAIL"); 
                $finish;
            end
        end
    if (save_mode == 2) begin 
        if (out_data !== calc_ans[out_cnt]) begin
            $display("SPEC MAIN-4 FAIL"); 
            $finish;
        end
    end
    out_cnt = out_cnt + 1;
    @(negedge clk);
end
endtask

task check_ans_in_mode13; begin
    if (save_mode == 1) begin
        for (i = 0; i < 256; i = i + 1) begin
            if (u_DRAM.DRAM[{save_bank, save_dst_row, i[7:0]}] !== save_write_buffer[i]) begin
                $display("SPEC MAIN-5 FAIL"); 
                $finish;
            end
            golden_DRAM[{save_bank, save_dst_row, i[7:0]}] = save_write_buffer[i];
        end
    end
    if (save_mode == 3) begin
        for (i = 0; i < 1024; i = i + 1) begin
            if (u_DRAM.DRAM[{i[9:8], save_dst_row, i[7:0]}] !== sort_buffer[i]) begin
                $display("SPEC MAIN-5 FAIL"); 
                $finish;
            end
            golden_DRAM[{i[9:8], save_dst_row, i[7:0]}] = sort_buffer[i];
        end
    end
end
endtask

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("* Congratulations!                              *");
    $display("* Your execution cycles = %7d cycles            *", total_latency);
    $display("*************************************************************************");
    $finish;
end endtask

endmodule