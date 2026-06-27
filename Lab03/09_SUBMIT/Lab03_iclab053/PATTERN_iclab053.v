`ifdef RTL
    `define CYCLE_TIME 8.0
`endif
`ifdef GATE
    `define CYCLE_TIME 8.0
`endif

module PATTERN(
    output reg      clk,
    output reg      rst_n,
    // AXI4-Lite Master
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

    output reg       in_mode_valid,
    output reg [1:0] in_mode,
    output reg       in_valid,
    output reg [1:0] in_bank,
    output reg [5:0] in_src_row,
    output reg [5:0] in_dst_row,
    output reg [63:0]in_data,
    
    input            out_valid,
    input [63:0]     out_data
);

// Golden Memory for Verification
reg [63:0] golden_DRAM [0:65535];
parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";
initial $readmemh(DRAM_p_r, golden_DRAM);
//you can access psuedo_DRAM memory by u_DRAM.DRAM

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
integer total_latency;
real CYCLE = `CYCLE_TIME;

integer current_latency;
integer pat_idx;
integer i, b, c;

reg [63:0] golden_data;
reg [63:0] write_data_buf [0:255];

localparam PATNUM = 100;
reg     reset_whether; 
            
//---------------------------------------------------------------------
//   REG & WIRE DECLARATION
//---------------------------------------------------------------------
reg is_waiting;

reg spec_main1, spec_main2, spec_main3, spec_main4, spec_main5;
reg spec_axi1, spec_axi2, spec_axi3, spec_axi4, spec_axi5, spec_axi6;

reg [1:0] sim_mode;
reg [1:0] sim_bank;
reg [5:0] sim_src_row;
reg [5:0] sim_dst_row;

//---------------------------------------------------------------------
//  CLOCK
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//  SIMULATION
//---------------------------------------------------------------------

// =======================================
// helper
// =======================================
task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask
task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

// SPEC MAIN-1
task spec_main1_check;
    begin
        if (out_valid !== 0 || out_data  !== 0 ||
            aw_addr  !== 0 || aw_valid  !== 0 || aw_ready !== 0 ||
            w_data   !== 0 || w_valid   !== 0 || w_ready  !== 0 ||
            b_resp   !== 0 || b_valid   !== 0 || b_ready  !== 0 ||
            ar_addr  !== 0 || ar_valid  !== 0 || ar_ready !== 0 ||
            r_data   !== 0 || r_resp    !== 0 || r_valid  !== 0 || r_ready !== 0) begin
            spec_main1 = 1;
        end
    end
endtask

// SPEC AXI-1 
task spec_axi1_check;
    begin
        if (!aw_valid && aw_addr !== 0) spec_axi1 = 1;
        if (!w_valid  && w_data  !== 0) spec_axi1 = 1;
        if (!ar_valid && ar_addr !== 0) spec_axi1 = 1;
        if (!b_valid  && b_resp  !== 0) spec_axi1 = 1;
        if (!r_valid  && (r_data !== 0 || r_resp !== 0)) spec_axi1 = 1;
    end
endtask

// SPEC AXI-3
reg [7:0] unmatched_aw;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        unmatched_aw <= 0;
    else if (reset_whether) begin
        if (aw_valid && aw_ready && !(w_valid && w_ready))
            unmatched_aw <= unmatched_aw + 1;
        else if (!(aw_valid && aw_ready) && (w_valid && w_ready))
            unmatched_aw <= unmatched_aw - 1;
    end
end

task spec_axi3_check;
    begin
        if (w_valid && !aw_valid && unmatched_aw == 0) 
        spec_axi3 = 1;
    end
endtask

// SPEC AXI-4
task spec_axi4_check;
    begin
        if (aw_valid && aw_addr > 32'hFFFF) 
            spec_axi4 = 1;
        if (ar_valid && ar_addr > 32'hFFFF) 
            spec_axi4 = 1;
    end
endtask

// SPEC AXI-2
reg        check_aw, check_w, check_ar, check_b, check_r;
reg [31:0] locked_aw_addr, locked_ar_addr;
reg [63:0] locked_w_data,  locked_r_data;
reg [1:0]  locked_b_resp,  locked_r_resp;

task spec_axi2_check;
    begin
        if (check_aw && (!aw_valid || aw_addr !== locked_aw_addr)) spec_axi2 = 1;
        if (check_w  && (!w_valid  || w_data  !== locked_w_data)) spec_axi2 = 1;
        if (check_ar && (!ar_valid || ar_addr !== locked_ar_addr)) spec_axi2 = 1;
        if (check_b  && (!b_valid  || b_resp  !== locked_b_resp)) spec_axi2 = 1;
        if (check_r  && (!r_valid  || r_data  !== locked_r_data || r_resp !== locked_r_resp)) spec_axi2 = 1;
    end
endtask

//(AXI-1, 2, 3, 4, MAIN-2)
always @(negedge clk) begin
    if (!rst_n) begin
        check_aw <= 0; check_w <= 0; check_ar <= 0;
        check_b  <= 0; check_r  <= 0;
    end
    else if (reset_whether) begin
        spec_axi1_check;
        spec_axi2_check;
        spec_axi3_check;
        spec_axi4_check;

        if (is_waiting && current_latency > 10000) 
            spec_main2 = 1;
        if (aw_valid && !aw_ready) begin 
            check_aw <= 1; 
            locked_aw_addr <= aw_addr; 
        end
        else 
            check_aw <= 0;
        
        if (w_valid  && !w_ready) begin 
            check_w  <= 1; 
            locked_w_data  <= w_data;  
        end
        else 
            check_w  <= 0;
        
        if (ar_valid && !ar_ready) begin 
            check_ar <= 1; 
            locked_ar_addr <= ar_addr; 
        end
        else 
            check_ar <= 0;
        
        if (b_valid  && !b_ready) begin 
            check_b  <= 1; 
            locked_b_resp  <= b_resp;  
        end
        else 
            check_b  <= 0;
        
        if (r_valid  && !r_ready) begin 
            check_r  <= 1; 
            locked_r_data  <= r_data;
            locked_r_resp <= r_resp; 
        end
        else 
            check_r  <= 0;
    end
end

// SPEC AXI-5
integer aw_rdy_cnt, w_rdy_cnt, ar_rdy_cnt, b_rdy_cnt, r_rdy_cnt;

reg [2:0] cnnt;

task spec_axi5_check;
    begin
        if (aw_rdy_cnt > 50) begin
            spec_axi5 = 1;
            cnnt = 0;
        end
        else if (ar_rdy_cnt > 50) begin
            spec_axi5 = 1;
            cnnt = 1;
        end
        else if ( w_rdy_cnt  > 100) begin
            spec_axi5 = 1;
            cnnt = 2;
        end
        else if ( b_rdy_cnt  > 100) begin
            spec_axi5 = 1;
            cnnt = 3;
        end
        if (r_rdy_cnt > 100) begin
            spec_axi5 = 1;
            cnnt = 4;
        end
        
    end
endtask

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        aw_rdy_cnt <= 0; w_rdy_cnt <= 0; ar_rdy_cnt <= 0;
        b_rdy_cnt  <= 0; r_rdy_cnt <= 0;
    end 
    else if (reset_whether) begin
        aw_rdy_cnt <= (aw_valid && !aw_ready) ? aw_rdy_cnt + 1 : 0;
        w_rdy_cnt  <= (w_valid  && !w_ready)  ? w_rdy_cnt  + 1 : 0;
        ar_rdy_cnt <= (ar_valid && !ar_ready) ? ar_rdy_cnt + 1 : 0;
        b_rdy_cnt  <= (b_valid  && !b_ready)  ? b_rdy_cnt  + 1 : 0;
        r_rdy_cnt  <= (r_valid  && !r_ready)  ? r_rdy_cnt  + 1 : 0;
        spec_axi5_check;
    end
end

// SPEC AXI-6
integer out_aw, out_w, out_ar;
integer aw_to_w_cnt, w_to_b_cnt, ar_to_r_cnt;

task spec_axi6_check;
    begin
        if (aw_to_w_cnt >= 150 || w_to_b_cnt >= 150 || ar_to_r_cnt >= 150) 
            spec_axi6 = 1;
    end
endtask

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_aw <= 0; out_w <= 0; out_ar <= 0;
        aw_to_w_cnt <= 0; w_to_b_cnt <= 0; ar_to_r_cnt <= 0;
    end 
    else if (reset_whether) begin
        if (aw_valid && aw_ready && !(w_valid && w_ready)) 
            out_aw <= out_aw + 1;
        else if (!(aw_valid && aw_ready) && (w_valid && w_ready)) 
            out_aw <= out_aw - 1;

        if (w_valid && w_ready && !(b_valid && b_ready)) 
            out_w <= out_w + 1;
        else if (!(w_valid && w_ready) && (b_valid && b_ready)) 
            out_w <= out_w - 1;

        if (ar_valid && ar_ready && !(r_valid && r_ready)) 
            out_ar <= out_ar + 1;
        else if (!(ar_valid && ar_ready) && (r_valid && r_ready)) 
            out_ar <= out_ar - 1;

        if ((out_aw + (aw_valid&&aw_ready) - (w_valid&&w_ready)) > 0 && !w_valid)
            aw_to_w_cnt <= aw_to_w_cnt + 1;
        else 
            aw_to_w_cnt <= 0;

        if ((out_w  + (w_valid&&w_ready)  - (b_valid&&b_ready))  > 0 && !b_valid)
            w_to_b_cnt  <= w_to_b_cnt  + 1;
        else 
            w_to_b_cnt  <= 0;

        if ((out_ar + (ar_valid&&ar_ready) - (r_valid&&r_ready)) > 0 && !r_valid)
            ar_to_r_cnt <= ar_to_r_cnt + 1;
        else 
            ar_to_r_cnt <= 0;
            
        spec_axi6_check;
    end
end

// MAIN-3
task spec_main3_check_high;
    begin
        if (out_valid !== 1) spec_main3 = 1;
    end
endtask
task spec_main3_check_low;
    begin
        if (out_valid === 1) spec_main3 = 1;
    end
endtask

// MAIN-4
task spec_main4_check;
    input [63:0] expected;
    input        is_signed;
    begin
        if (!is_signed) begin
            if (out_data !== expected) spec_main4 = 1;
        end 
        else begin
            if ($signed(out_data) !== $signed(expected)) spec_main4 = 1;
        end
    end
endtask

// SPEC MAIN-5 
task spec_main5_check_write;
    begin
        for (c = 0; c < 256; c = c + 1) begin
            golden_DRAM[{sim_bank, sim_dst_row, c[7:0]}] = write_data_buf[c];
            if (u_DRAM.DRAM[{sim_bank, sim_dst_row, c[7:0]}] !== write_data_buf[c]) 
                spec_main5 = 1;
        end
    end
endtask

task spec_main5_check_sort;
    begin
        for (b = 0; b < 4; b = b + 1)
            for (c = 0; c < 256; c = c + 1)
                if (u_DRAM.DRAM[{b[1:0], sim_dst_row, c[7:0]}] !== golden_DRAM[{b[1:0], sim_dst_row, c[7:0]}]) 
                    spec_main5 = 1;
    end
endtask
// $display("*************************************************************************");
// $display("*                           SPEC MAIN-1 FAIL                            *");
// $display("*                           SPEC MAIN-2 FAIL                            *");
// $display("*                           SPEC MAIN-3 FAIL                            *");
// $display("*                           SPEC MAIN-4 FAIL                            *");
// $display("*                           SPEC MAIN-5 FAIL                            *");
// $display("*************************************************************************");

// $display("*************************************************************************");
// $display("*                          SPEC AXI-1 FAIL                              *");
// $display("*                          SPEC AXI-2 FAIL                              *");
// $display("*                          SPEC AXI-3 FAIL                              *");
// $display("*                          SPEC AXI-4 FAIL                              *");
// $display("*                          SPEC AXI-5 FAIL                              *");
// $display("*                          SPEC AXI-6 FAIL                              *");
// $display("*************************************************************************");
//  spec for all
always @(negedge clk) begin
    if (spec_main1) begin
        YOU_FAIL_task; $display("*                           SPEC MAIN-1 FAIL                            *"); $finish;
    end
    else if (spec_axi1) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-1 FAIL                              *"); $finish;
    end
    else if (spec_axi2) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-2 FAIL                              *"); $finish;
    end

    else if (spec_axi4) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-4 FAIL                              *"); $finish;
    end
    
    else if (spec_axi3) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-3 FAIL                              *"); $finish;
    end
    else if (spec_axi5) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-5 FAIL                              *"); 
                    //$display("*                         %3d                              *",cnnt);
        $finish;
    end
    else if (spec_axi6) begin
        YOU_FAIL_task; $display("*                          SPEC AXI-6 FAIL                              *"); $finish;
    end
    else if (spec_main2) begin
        YOU_FAIL_task; $display("*                           SPEC MAIN-2 FAIL                            *"); $finish;
    end
    else if (spec_main3) begin
        YOU_FAIL_task; $display("*                           SPEC MAIN-3 FAIL                            *"); $finish;
    end
    else if (spec_main4) begin
        YOU_FAIL_task; $display("*                           SPEC MAIN-4 FAIL                            *"); $finish;
    end
    else if (spec_main5) begin
        YOU_FAIL_task; $display("*                           SPEC MAIN-5 FAIL                            *"); $finish;
    end
end

// 
function automatic signed [63:0] eval_tree;
    input [15:0] node_addr;
    reg [63:0]        node_data;
    reg [1:0]         opcode;
    reg signed [63:0] left_val, right_val;
    begin
        node_data = golden_DRAM[node_addr];
        if (node_data[63] == 1'b0) begin
            eval_tree = $signed(node_data[62:32]);
        end 
        else begin
            opcode    = node_data[33:32];
            left_val  = eval_tree(node_data[31:16]);
            right_val = eval_tree(node_data[15:0]);
            case (opcode)
                2'b00: eval_tree = left_val + right_val;
                2'b01: eval_tree = left_val - right_val;
                2'b10: eval_tree = left_val * right_val;
                2'b11: eval_tree = left_val >>> right_val[5:0];
            endcase
        end
    end
endfunction

reg [63:0] sort_buffer [0:1023];
reg [15:0] sort_addr   [0:1023];

task golden_sort_task;
    input [5:0] src_row;
    input [5:0] dst_row;
    integer si, sj, sb, sc, idx;
    reg [63:0] tmp_data;
    reg [15:0] tmp_addr;
    begin
        idx = 0;
        for (sb = 0; sb < 4; sb = sb + 1)
            for (sc = 0; sc < 256; sc = sc + 1) begin
                sort_addr[idx]   = {sb[1:0], src_row, sc[7:0]};
                sort_buffer[idx] = golden_DRAM[sort_addr[idx]];
                idx = idx + 1;
            end
        for (si = 0; si < 1024; si = si + 1)
            for (sj = 0; sj < 1023 - si; sj = sj + 1)
                if ((sort_buffer[sj][62:32] > sort_buffer[sj+1][62:32]) ||
                    (sort_buffer[sj][62:32] == sort_buffer[sj+1][62:32] && sort_addr[sj] > sort_addr[sj+1])) begin
                    tmp_data           = sort_buffer[sj];
                    sort_buffer[sj]    = sort_buffer[sj+1];
                    sort_buffer[sj+1]  = tmp_data;
                    tmp_addr           = sort_addr[sj];
                    sort_addr[sj]      = sort_addr[sj+1];
                    sort_addr[sj+1]    = tmp_addr;
                end
        idx = 0;
        for (sb = 0; sb < 4; sb = sb + 1)
            for (sc = 0; sc < 256; sc = sc + 1) begin
                golden_DRAM[{sb[1:0], dst_row, sc[7:0]}] = sort_buffer[idx];
                idx = idx + 1;
            end
    end
endtask

integer rand_op;
task send_input;
    integer k;
    begin
        rand_op = $urandom_range(0, 79);
        if      (rand_op < 10) sim_mode = 2'd0;
        else if (rand_op < 20) sim_mode = 2'd1;
        //else sim_mode = 2'd2;
        else if (rand_op < 50) sim_mode = 2'd2;
        else                   sim_mode = 2'd3;
        //sim_mode = 2'd3;
        
        if (sim_mode == 2'd0) begin // READ
            sim_bank = $urandom_range(0, 3);
            sim_src_row = $urandom_range(0, 62);
        end else if (sim_mode == 2'd1) begin // WRITE
            sim_bank = $urandom_range(0, 3);
            sim_dst_row = $urandom_range(32, 62);
        end else if (sim_mode == 2'd2) begin // CALC
            sim_src_row = $urandom_range(0, 31);
        end else if (sim_mode == 2'd3) begin // SORT
            sim_src_row = $urandom_range(0, 62);
            sim_dst_row = $urandom_range(32, 62);
        end

        
        @(negedge clk);
        in_mode_valid = 1;
        in_mode = sim_mode;

        @(negedge clk);
        in_mode_valid = 0;
        in_mode = 2'bx;  

        
        if (sim_mode == 2'd1) begin          // WRITE
            in_valid = 1;
            in_bank = sim_bank;
            in_dst_row = sim_dst_row;
            in_src_row = 6'bx;
            
            for (k = 0; k < 256; k = k + 1) begin
                in_data  = {$urandom(), $urandom()};
                write_data_buf[k] = in_data;
                @(negedge clk);
            end
            
            in_valid = 0;
            in_bank = 2'bx;
            in_dst_row = 6'bx;
            in_data = 64'bx;
        end 
        else begin                   // READ / CALC / SORT
            in_valid = 1;
            if (sim_mode == 2'd0) begin
                in_bank = sim_bank;
                in_src_row = sim_src_row;
            end else if (sim_mode == 2'd2) begin
                in_src_row = sim_src_row;
            end else if (sim_mode == 2'd3) begin
                in_src_row = sim_src_row;
                in_dst_row = sim_dst_row;
            end
            
            @(negedge clk);
            in_valid = 0;
            in_bank = 2'bx;
            in_src_row = 6'bx;
            in_dst_row = 6'bx;
        end
    end
endtask

task wait_for_out_valid;
    begin
        current_latency = 0;
        is_waiting = 1;
        while (!out_valid) begin
            @(negedge clk);
            current_latency = current_latency + 1;
        end
        is_waiting = 0;
        total_latency = total_latency + current_latency;
    end
endtask

task golden_answer_cal;
    integer idx, limit;
    begin
        case (sim_mode)
            2'd0: limit = 256; // READ
            2'd1: limit = 1;   // WRITE
            2'd2: limit = 4;   // CALC
            2'd3: limit = 1;   // SORT
        endcase

        for (idx = 0; idx < limit; idx = idx + 1) begin
            spec_main3_check_high;

            case (sim_mode)
                2'd0: begin // READ
                    golden_data = golden_DRAM[{sim_bank, sim_src_row, idx[7:0]}];
                    spec_main4_check(golden_data, 0);
                end
                2'd1: begin // WRITE
                    spec_main5_check_write;
                end
                2'd2: begin // CALC
                    golden_data = eval_tree({idx[1:0], sim_src_row, 8'd0});
                    spec_main4_check(golden_data, 1); // signed comparison
                end
                2'd3: begin // SORT
                    golden_sort_task(sim_src_row, sim_dst_row);
                    spec_main5_check_sort;
                end
            endcase

            @(negedge clk);
        end
        
        spec_main3_check_low;
    end
endtask

// ============================================================
//   MAIN FLOW
// ============================================================
initial begin
    spec_main1 = 0; spec_main2 = 0; spec_main3 = 0; spec_main4 = 0; spec_main5 = 0;
    spec_axi1  = 0; spec_axi2  = 0; spec_axi3  = 0; spec_axi4  = 0; spec_axi5  = 0; spec_axi6  = 0;

    reset_whether = 0;
    is_waiting = 0;
    
    rst_n = 1;
    in_mode_valid = 0; 
    in_mode = 2'bx; 
    in_valid = 0;
    in_bank = 2'bx; 
    in_src_row = 6'bx; 
    in_dst_row = 6'bx; 
    in_data = 64'bx;
    total_latency = 0;

    #(CYCLE) rst_n = 0;
    #(CYCLE * 3);
    spec_main1_check;

    @(negedge clk); 
    rst_n = 1;
    
    #(CYCLE * 3);
    reset_whether = 1; 

    for (pat_idx = 0; pat_idx < PATNUM; pat_idx = pat_idx + 1) begin
        send_input;
        wait_for_out_valid; 

        golden_answer_cal;

        repeat($urandom_range(2, 4)) @(negedge clk);
    end

    YOU_PASS_task;
end

endmodule