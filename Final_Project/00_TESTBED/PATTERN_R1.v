//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name       : PATTERN.v
//   Module Name     : PATTERN.v
//   Release version : V17.0 (Ultimate Sync & Flawless Memory Bound Edition)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
    `define CYCLE_TIME 3.7
`elsif GATE
    `define CYCLE_TIME 3.7
`elsif CHIP
    `define CYCLE_TIME 6.0
`elsif POST
    `define CYCLE_TIME 6.0
`endif

`ifdef FUNC
    `define PAT_NUM 10
    `define MAX_WAIT_READY_CYCLE 2000
`endif
`ifdef PERF
    `define PAT_NUM 10
    `define MAX_WAIT_READY_CYCLE 100000
`endif

module PATTERN(
    output reg clk, 
    output reg rst_n,
    
    // AXI Inst 1
    input  wire                  awready_s_inf_inst_1, 
    input  wire                  wready_s_inf_inst_1, 
    output wire [3:0]            bid_s_inf_inst_1, 
    output wire [1:0]            bresp_s_inf_inst_1, 
    output wire                  bvalid_s_inf_inst_1,
    input  wire                  arready_s_inf_inst_1, 
    output wire [3:0]            rid_s_inf_inst_1, 
    output wire [15:0]           rdata_s_inf_inst_1, 
    output wire [1:0]            rresp_s_inf_inst_1, 
    output wire                  rlast_s_inf_inst_1, 
    output wire                  rvalid_s_inf_inst_1,
    
    // AXI Inst 2
    input  wire                  awready_s_inf_inst_2, 
    input  wire                  wready_s_inf_inst_2, 
    output wire [3:0]            bid_s_inf_inst_2, 
    output wire [1:0]            bresp_s_inf_inst_2, 
    output wire                  bvalid_s_inf_inst_2,
    input  wire                  arready_s_inf_inst_2, 
    output wire [3:0]            rid_s_inf_inst_2, 
    output wire [15:0]           rdata_s_inf_inst_2, 
    output wire [1:0]            rresp_s_inf_inst_2, 
    output wire                  rlast_s_inf_inst_2, 
    output wire                  rvalid_s_inf_inst_2,
    
    // AXI Data
    input  wire                  awready_s_inf_data, 
    input  wire                  wready_s_inf_data, 
    output wire [3:0]            bid_s_inf_data, 
    output wire [1:0]            bresp_s_inf_data, 
    output wire                  bvalid_s_inf_data,
    input  wire                  arready_s_inf_data, 
    output wire [3:0]            rid_s_inf_data, 
    output wire [15:0]           rdata_s_inf_data, 
    output wire [1:0]            rresp_s_inf_data, 
    output wire                  rlast_s_inf_data, 
    output wire                  rvalid_s_inf_data,
    
    // Stall Signals
    input  wire                  stall_1, 
    input  wire                  stall_2,
    
    // AXI Inst 1 (Master outputs)
    input  wire [3:0]            awid_s_inf_inst_1, 
    input  wire [31:0]           awaddr_s_inf_inst_1, 
    input  wire [2:0]            awsize_s_inf_inst_1, 
    input  wire [1:0]            awburst_s_inf_inst_1, 
    input  wire [6:0]            awlen_s_inf_inst_1, 
    input  wire                  awvalid_s_inf_inst_1,
    input  wire [15:0]           wdata_s_inf_inst_1, 
    input  wire                  wlast_s_inf_inst_1, 
    input  wire                  wvalid_s_inf_inst_1, 
    input  wire                  bready_s_inf_inst_1,
    input  wire [3:0]            arid_s_inf_inst_1, 
    input  wire [31:0]           araddr_s_inf_inst_1, 
    input  wire [6:0]            arlen_s_inf_inst_1, 
    input  wire [2:0]            arsize_s_inf_inst_1, 
    input  wire [1:0]            arburst_s_inf_inst_1, 
    input  wire                  arvalid_s_inf_inst_1, 
    input  wire                  rready_s_inf_inst_1,
    
    // AXI Inst 2 (Master outputs)
    input  wire [3:0]            awid_s_inf_inst_2, 
    input  wire [31:0]           awaddr_s_inf_inst_2, 
    input  wire [2:0]            awsize_s_inf_inst_2, 
    input  wire [1:0]            awburst_s_inf_inst_2, 
    input  wire [6:0]            awlen_s_inf_inst_2, 
    input  wire                  awvalid_s_inf_inst_2,
    input  wire [15:0]           wdata_s_inf_inst_2, 
    input  wire                  wlast_s_inf_inst_2, 
    input  wire                  wvalid_s_inf_inst_2, 
    input  wire                  bready_s_inf_inst_2,
    input  wire [3:0]            arid_s_inf_inst_2, 
    input  wire [31:0]           araddr_s_inf_inst_2, 
    input  wire [6:0]            arlen_s_inf_inst_2, 
    input  wire [2:0]            arsize_s_inf_inst_2, 
    input  wire [1:0]            arburst_s_inf_inst_2, 
    input  wire                  arvalid_s_inf_inst_2, 
    input  wire                  rready_s_inf_inst_2,
    
    // AXI Data (Master outputs)
    input  wire [3:0]            awid_s_inf_data, 
    input  wire [31:0]           awaddr_s_inf_data, 
    input  wire [2:0]            awsize_s_inf_data, 
    input  wire [1:0]            awburst_s_inf_data, 
    input  wire [6:0]            awlen_s_inf_data, 
    input  wire                  awvalid_s_inf_data,
    input  wire [15:0]           wdata_s_inf_data, 
    input  wire                  wlast_s_inf_data, 
    input  wire                  wvalid_s_inf_data, 
    input  wire                  bready_s_inf_data,
    input  wire [3:0]            arid_s_inf_data, 
    input  wire [31:0]           araddr_s_inf_data, 
    input  wire [6:0]            arlen_s_inf_data, 
    input  wire [2:0]            arsize_s_inf_data, 
    input  wire [1:0]            arburst_s_inf_data, 
    input  wire                  arvalid_s_inf_data, 
    input  wire                  rready_s_inf_data
);

parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

integer total_latency;
integer latency;
integer i_pat;
integer TOTAL_STEPS; 

reg [15:0] golden_r1 [0:8191][0:7];
reg [15:0] golden_r2 [0:8191][0:7];

reg [15:0] golden_inst1 [0:8191];
reg [15:0] golden_inst2 [0:8191];

reg [7:0] inst_1_dram [0:8191];
reg [7:0] inst_2_dram [0:8191];
reg [7:0] data_dram [0:12287]; 
reg [7:0] initial_dram [0:12287];
reg [7:0] golden_dram [0:12287]; 
reg [7:0] expected_dram [0:12287]; 
reg [7:0] pattern_start_dram [0:12287]; 

reg        c1_store_valid [0:8191]; 
reg [31:0] c1_store_addr  [0:8191]; 
reg [15:0] c1_store_data  [0:8191];

reg        c2_store_valid [0:8191]; 
reg [31:0] c2_store_addr  [0:8191]; 
reg [15:0] c2_store_data  [0:8191];

reg valid_inst1 [0:8191];
reg valid_inst2 [0:8191];

integer pc1;
integer pc2;

// 🌟 真因修正 1：必須宣告為 signed，否則邊界檢查算數會全部變大正數越界！
reg signed [15:0] sim_r1 [0:7];
reg signed [15:0] sim_r2 [0:7];

//========================================================================
// DRAM Instantiations
//========================================================================
pseudo_DRAM_inst1 u_DRAM_inst1 (
    .clk            (clk),                  .rst_n          (rst_n),
    .awid_s_inf     (awid_s_inf_inst_1),    .awaddr_s_inf   (awaddr_s_inf_inst_1),  .awsize_s_inf   (awsize_s_inf_inst_1), 
    .awburst_s_inf  (awburst_s_inf_inst_1), .awlen_s_inf    (awlen_s_inf_inst_1),   .awvalid_s_inf  (awvalid_s_inf_inst_1), .awready_s_inf  (awready_s_inf_inst_1),
    .wdata_s_inf    (wdata_s_inf_inst_1),   .wlast_s_inf    (wlast_s_inf_inst_1),   .wvalid_s_inf   (wvalid_s_inf_inst_1),  .wready_s_inf   (wready_s_inf_inst_1),
    .bid_s_inf      (bid_s_inf_inst_1),     .bresp_s_inf    (bresp_s_inf_inst_1),   .bvalid_s_inf   (bvalid_s_inf_inst_1),  .bready_s_inf   (bready_s_inf_inst_1),
    .arid_s_inf     (arid_s_inf_inst_1),    .araddr_s_inf   (araddr_s_inf_inst_1),  .arlen_s_inf    (arlen_s_inf_inst_1),   .arsize_s_inf   (arsize_s_inf_inst_1), 
    .arburst_s_inf  (arburst_s_inf_inst_1), .arvalid_s_inf  (arvalid_s_inf_inst_1), .arready_s_inf  (arready_s_inf_inst_1),
    .rid_s_inf      (rid_s_inf_inst_1),     .rdata_s_inf    (rdata_s_inf_inst_1),   .rresp_s_inf    (rresp_s_inf_inst_1),   .rlast_s_inf    (rlast_s_inf_inst_1), 
    .rvalid_s_inf   (rvalid_s_inf_inst_1),  .rready_s_inf   (rready_s_inf_inst_1)
);

pseudo_DRAM_inst2 u_DRAM_inst2 (
    .clk            (clk),                  .rst_n          (rst_n),
    .awid_s_inf     (awid_s_inf_inst_2),    .awaddr_s_inf   (awaddr_s_inf_inst_2),  .awsize_s_inf   (awsize_s_inf_inst_2), 
    .awburst_s_inf  (awburst_s_inf_inst_2), .awlen_s_inf    (awlen_s_inf_inst_2),   .awvalid_s_inf  (awvalid_s_inf_inst_2), .awready_s_inf  (awready_s_inf_inst_2),
    .wdata_s_inf    (wdata_s_inf_inst_2),   .wlast_s_inf    (wlast_s_inf_inst_2),   .wvalid_s_inf   (wvalid_s_inf_inst_2),  .wready_s_inf   (wready_s_inf_inst_2),
    .bid_s_inf      (bid_s_inf_inst_2),     .bresp_s_inf    (bresp_s_inf_inst_2),   .bvalid_s_inf   (bvalid_s_inf_inst_2),  .bready_s_inf   (bready_s_inf_inst_2),
    .arid_s_inf     (arid_s_inf_inst_2),    .araddr_s_inf   (araddr_s_inf_inst_2),  .arlen_s_inf    (arlen_s_inf_inst_2),   .arsize_s_inf   (arsize_s_inf_inst_2), 
    .arburst_s_inf  (arburst_s_inf_inst_2), .arvalid_s_inf  (arvalid_s_inf_inst_2), .arready_s_inf  (arready_s_inf_inst_2),
    .rid_s_inf      (rid_s_inf_inst_2),     .rdata_s_inf    (rdata_s_inf_inst_2),   .rresp_s_inf    (rresp_s_inf_inst_2),   .rlast_s_inf    (rlast_s_inf_inst_2), 
    .rvalid_s_inf   (rvalid_s_inf_inst_2),  .rready_s_inf   (rready_s_inf_inst_2)
);

pseudo_DRAM_data u_DRAM_data (
    .clk            (clk),                  .rst_n          (rst_n),
    .awid_s_inf     (awid_s_inf_data),      .awaddr_s_inf   (awaddr_s_inf_data),    .awsize_s_inf   (awsize_s_inf_data), 
    .awburst_s_inf  (awburst_s_inf_data),   .awlen_s_inf    (awlen_s_inf_data),     .awvalid_s_inf  (awvalid_s_inf_data),   .awready_s_inf  (awready_s_inf_data),
    .wdata_s_inf    (wdata_s_inf_data),     .wlast_s_inf    (wlast_s_inf_data),     .wvalid_s_inf   (wvalid_s_inf_data),    .wready_s_inf   (wready_s_inf_data),
    .bid_s_inf      (bid_s_inf_data),       .bresp_s_inf    (bresp_s_inf_data),     .bvalid_s_inf   (bvalid_s_inf_data),    .bready_s_inf   (bready_s_inf_data),
    .arid_s_inf     (arid_s_inf_data),      .araddr_s_inf   (araddr_s_inf_data),    .arlen_s_inf    (arlen_s_inf_data),     .arsize_s_inf   (arsize_s_inf_data), 
    .arburst_s_inf  (arburst_s_inf_data),   .arvalid_s_inf  (arvalid_s_inf_data),   .arready_s_inf  (arready_s_inf_data),
    .rid_s_inf      (rid_s_inf_data),       .rdata_s_inf    (rdata_s_inf_data),     .rresp_s_inf    (rresp_s_inf_data),     .rlast_s_inf    (rlast_s_inf_data), 
    .rvalid_s_inf   (rvalid_s_inf_data),    .rready_s_inf   (rready_s_inf_data)
);

//========================================================================
// Main Testbench Flow
//========================================================================
initial begin clk = 0; end
always #(`CYCLE_TIME/2.0) clk = ~clk;

initial begin
    total_latency = 0;
    if(`MAX_WAIT_READY_CYCLE == 2000)$display("now is at FUNC mode");
    if(`MAX_WAIT_READY_CYCLE == 100000)$display("now is at PERF mode");
    
    for (i_pat = 0; i_pat < `PAT_NUM; i_pat = i_pat + 1) begin
        generate_and_simulate_task;
        
        $readmemh("../00_TESTBED/DRAM/inst_1_dram_file.dat", u_DRAM_inst1.DRAM_r); 
        $readmemh("../00_TESTBED/DRAM/inst_2_dram_file.dat", u_DRAM_inst2.DRAM_r);

        if (i_pat == 0) begin
            $readmemh("../00_TESTBED/DRAM/data_dram_file.dat", u_DRAM_data.DRAM_r);
            
        end
        reset_task;
        wait_and_check_task;

        $display("==================================================");
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mExecution Steps: %5d, Latency Cycle: %5d\033[m", i_pat, TOTAL_STEPS, latency);
        $display("==================================================");
        
        total_latency = total_latency + latency;

        while (stall_1 === 1'b0 || stall_2 === 1'b0) begin
            @(negedge clk);
        end
    end

    $display("=============================================================");
    $display("  [INFO] Congratulations! All %0d Patterns PASSED!           ", `PAT_NUM);
    $display("  [INFO] Total Execution Cycles = %0d                        ", total_latency);
    $display("  [INFO] AVR. Execution Cycles = %0d                        ", total_latency/`PAT_NUM);
    $display("  [INFO] Your cycle time = %0d                        ", `CYCLE_TIME);
    $display("=============================================================");
    $finish;
end

//---------------------------------------------------------------------
//   TASK: GENERATE AND SIMULATE (True Dual-Core ISS)
//---------------------------------------------------------------------
task generate_and_simulate_task;
    integer fd_inst1, fd_inst2, fd_data, fd_trace;
    integer i, k;
    integer next_pc1, next_pc2, step;
    integer rand_val1, rand_val2; 
    integer jump_offset1, jump_offset2;
    integer last_word_offset1, last_word_offset2;
    integer addr1_index, addr2_index;
    integer steps_left, max_next_pc;
    integer distance1, distance2;
    integer temp_min, temp_max; 
    integer safe_min, safe_max, current_r1, current_r2;
    integer valid_rs_count;
    integer min_imm, max_imm, target_imm2, inject_hazard;
    integer early_exit_flag;
    integer scenario_mode; // 🌟 新增：0=狀況一(跑滿), 1=狀況二(自然提早結束), 2=狀況三(提早到但死迴圈)
    
    reg [15:0] inst1_word, inst2_word;
    reg [2:0]  op1, op2, rs1, rt1, rd1, rs2, rt2, rd2, func1, func2, rl1, rl2;
    reg [2:0]  prev_rd1, prev_rt1, prev_rd2, prev_rt2;
    reg [3:0]  valid_rs_list [0:7];
    reg [6:0]  imm1, imm2;
    reg signed [15:0] imm1_ext, imm2_ext; 
    reg signed [15:0] val_rs1, val_rt1, val_rs2, val_rt2;
    reg signed [31:0] mult_res1, mult_res2;
    
    integer expected_addr1;
    integer addr1, addr2, target1, target2, temp_imm1, temp_imm2;
    reg [15:0] temp_data;

    begin
        if (i_pat == 0) begin
            for (i = 4096; i < 12288; i = i + 1) begin
                data_dram[i] = 8'd0; 
                golden_dram[i] = 8'd0;
            end
            
            fd_data = $fopen("../00_TESTBED/DRAM/data_dram_file.dat", "w"); 
            for (i = 0; i < 4096; i = i + 1) begin
                temp_data = $urandom_range(0, 4095);
                data_dram[4096 + i*2]     = temp_data[7:0]; 
                data_dram[4096 + i*2 + 1] = temp_data[15:8];  
                golden_dram[4096+i*2]   = data_dram[4096+i*2]; 
                golden_dram[4096+i*2+1] = data_dram[4096+i*2+1];
                
                $fdisplay(fd_data, "@%04x \n %02x %02x // %d", (i*2 + 32'h1000), data_dram[4096+i*2], data_dram[4096+i*2+1], $signed({data_dram[4096+i*2+1],data_dram[4096+i*2]}));
            end
            $fclose(fd_data);
        end

        for (i = 0; i < 8192; i = i + 1) begin
            inst_1_dram[i] = 8'd0; inst_2_dram[i] = 8'd0; 
            valid_inst1[i] = 0; valid_inst2[i] = 0;
            c1_store_valid[i] = 0; c2_store_valid[i] = 0;
        end
        
        for (i = 0; i < 8; i = i + 1) begin 
            sim_r1[i] = 0; sim_r2[i] = 0; 
        end
        
        pc1 = 0; pc2 = 0; step = 0; 
        last_word_offset1 = 0; last_word_offset2 = 1000;
        prev_rd1 = 0; prev_rt1 = 0; prev_rd2 = 0; prev_rt2 = 0;
        
        for (i = 4096; i < 12288; i = i + 1) begin
            pattern_start_dram[i] = golden_dram[i];
        end

        fd_trace = $fopen("golden_trace.txt", "w");
        $fdisplay(fd_trace, "==========================================================================");
        $fdisplay(fd_trace, "                        PATTERN NO.%4d", i_pat);
        $fdisplay(fd_trace, "==========================================================================");

        // 🌟 分配三種狀況：0=跑滿, 1=提早結束, 2=提早到終點但死迴圈
        scenario_mode = i_pat % 3;

        while (step < 4096 && pc1 <= 4095 && pc2 <= 4095) begin
            
            steps_left = 4095 - step;
            
            // 🌟 狀況一(0)需限速拖時間，狀況二(1)和三(2)解除限速
            if (scenario_mode == 0) max_next_pc = 4095 - steps_left;
            else max_next_pc = 4095; 

            //---------------------------------------------------------------------
            //   JIT Generation for Core 1
            //---------------------------------------------------------------------
            if (!valid_inst1[pc1]) begin
                if (pc1 < 8) begin
                    if (pc1 == 0)      inst1_word = {3'b010, 3'd0, 3'd0, 7'd0}; 
                    else if (pc1 == 1) inst1_word = {3'b010, 3'd0, 3'd1, 7'd10};
                    else if (pc1 == 2) inst1_word = {3'b010, 3'd0, 3'd2, 7'd20};
                    else begin op1 = 3'b100; rs1 = 3'd0; rt1 = pc1[2:0]; imm1 = $urandom_range(0, 31); inst1_word = {op1, rs1, rt1, imm1}; temp_imm1 = imm1; end
                end else begin
                    rand_val1 = $urandom_range(0, 99);
                    if (i_pat == 4) begin
                        if (rand_val1 < 40) op1 = 3'b101; else if (rand_val1 < 80) op1 = 3'b100; else op1 = $urandom_range(0, 3);
                    end else op1 = $urandom_range(0, 7);
                    
                    if (step % 50 <= 15 || step % 50 >= 35) if (op1 == 3'b101) op1 = 3'b100;
                    if (step < 50) begin
                        if (step % 5 == 0) begin op1 = 3'b000; rs1 = prev_rt1; rt1 = prev_rd1; end 
                        else if (step % 5 == 1) op1 = 3'b001; 
                        else if (step % 5 == 2) op1 = 3'b111; 
                        else if (step % 5 == 3) op1 = 3'b100; 
                        else if (step % 5 == 4) op1 = 3'b101; 
                    end
                    
                    rs1 = $urandom_range(0, 7); 
                    rt1 = (op1 == 5 || op1 == 6) ? $urandom_range(0, 7) : $urandom_range(3, 7); 
                    rd1 = $urandom_range(3, 7); rl1 = $urandom_range(3, 7); func1 = $urandom_range(0, 7); 

                    // 🌟 狀況控制中心：處理到達 4095 的行為
                    if (pc1 == 4095) begin
                        if (scenario_mode == 1) begin
                            // 🚀 狀況二：給它臨門一腳！生成普通 ALU，next_pc 變 4096，提早結束！
                            op1 = 3'b000; rs1 = 0; rt1 = 0; rd1 = 0; func1 = 0; 
                            inst1_word = {op1, rs1, rt1, rd1, func1, 1'b0};
                        end else begin
                            // 🛑 狀況一與三：強迫停車，死迴圈消耗步數
                            op1 = 3'b111; target1 = 4095; inst1_word = {op1, target1[11:0], 1'b0}; 
                        end
                    end else if (scenario_mode == 0 && steps_left <= 40) begin
                        // 🛬 只有狀況一需要強迫降落拖時間
                        distance1 = 4095 - pc1;
                        if (distance1 == steps_left) begin op1 = 3'b000; rs1 = 0; rt1 = 0; rd1 = 0; func1 = 0; inst1_word = {op1, rs1, rt1, rd1, func1, 1'b0}; end 
                        else if (distance1 > steps_left) begin
                            op1 = 3'b111; jump_offset1 = distance1 - steps_left + 1;
                            if (jump_offset1 > 120) jump_offset1 = 120;
                            target1 = pc1 + jump_offset1; inst1_word = {op1, target1[11:0], 1'b0}; 
                        end else begin
                            op1 = 3'b111; target1 = pc1; inst1_word = {op1, target1[11:0], 1'b0}; 
                        end
                    end else begin
                        if (op1 == 4 || op1 == 5) begin
                            valid_rs_count = 0;
                            for (k = 0; k < 3; k = k + 1) begin
                                if (($signed(sim_r1[k]) + 63 >= 0) && ($signed(sim_r1[k]) - 64 <= 4095)) begin 
                                    if (($signed(sim_r1[k]) + 63 >= last_word_offset1 - 100) && ($signed(sim_r1[k]) - 64 <= last_word_offset1 + 100)) begin
                                        valid_rs_list[valid_rs_count] = k; valid_rs_count = valid_rs_count + 1;
                                    end
                                end
                            end
                            if (valid_rs_count == 0) begin valid_rs_list[0] = 0; valid_rs_count = 1; end 
                            
                            rs1 = valid_rs_list[$unsigned($random) % valid_rs_count];
                            current_r1 = $signed(sim_r1[rs1]);
                            
                            safe_min = -64;
                            if ((0 - current_r1) > safe_min) safe_min = (0 - current_r1);
                            
                            safe_max = 63;
                            if ((4095 - current_r1) < safe_max) safe_max = (4095 - current_r1);
                            
                            temp_min = last_word_offset1 - 100 - current_r1;
                            temp_max = last_word_offset1 + 100 - current_r1;
                            
                            if (temp_min > safe_min) safe_min = temp_min;
                            if (temp_max < safe_max) safe_max = temp_max;
                            
                            if (safe_min > safe_max) begin
                                safe_min = -64;
                                if ((0 - current_r1) > safe_min) safe_min = (0 - current_r1);
                                safe_max = 63;
                                if ((4095 - current_r1) < safe_max) safe_max = (4095 - current_r1);
                            end
                            
                            temp_imm1 = safe_min + $signed($urandom_range(0, safe_max - safe_min));
                            last_word_offset1 = current_r1 + temp_imm1;
                            inst1_word = {op1, rs1, rt1, temp_imm1[6:0]};
                            
                        end else if (op1 == 6) begin 
                            if ($urandom_range(0, 100) < 30) rt1 = rs1; 
                            if ($urandom_range(0, 99) < 85) imm1_ext = $urandom_range(1, 63); else imm1_ext = -($signed($urandom_range(1, 63)));
                            if (pc1 + 1 + imm1_ext < 0) imm1_ext = -1 - pc1; 
                            // 🌟 解除 4090 結界！
                            if (pc1 + 1 + imm1_ext > max_next_pc) imm1_ext = max_next_pc - 1 - pc1;
                            inst1_word = {op1, rs1, rt1, imm1_ext[6:0]};
                        end else if (op1 == 7) begin 
                            target1 = pc1 + (($urandom_range(0, 99) < 85) ? $urandom_range(1, 127) : -($signed($urandom_range(1, 127))));
                            if (target1 < 0) target1 = 0; 
                            // 🌟 解除 4090 結界！
                            if (target1 > max_next_pc) target1 = max_next_pc;
                            inst1_word = {op1, target1[11:0], 1'b0}; 
                        end else if (op1 == 2 || op1 == 3) begin
                            imm1_ext = $urandom_range(0, 127) - 64; 
                            inst1_word = {op1, rs1, rt1, imm1_ext[6:0]};
                        end else begin
                            if (op1 == 1) inst1_word = {op1, rs1, rt1, rd1, rl1, 1'b0}; else inst1_word = {op1, rs1, rt1, rd1, func1, 1'b0};
                        end
                    end
                end
                inst_1_dram[pc1*2] = inst1_word[7:0]; inst_1_dram[pc1*2+1] = inst1_word[15:8];
                valid_inst1[pc1] = 1;
            end else inst1_word = {inst_1_dram[pc1*2+1], inst_1_dram[pc1*2]}; 

            //---------------------------------------------------------------------
            //   JIT Generation for Core 2
            //---------------------------------------------------------------------
            if (!valid_inst2[pc2]) begin
                if (pc2 < 8) begin
                    if (pc2 == 0)      inst2_word = {3'b010, 3'd0, 3'd0, 7'd0}; 
                    else if (pc2 == 1) inst2_word = {3'b010, 3'd0, 3'd1, 7'd10}; 
                    else if (pc2 == 2) inst2_word = {3'b010, 3'd0, 3'd2, 7'd20}; 
                    else begin op2 = 3'b100; rs2 = 3'd0; rt2 = pc2[2:0]; imm2 = $urandom_range(0, 31); inst2_word = {op2, rs2, rt2, imm2}; temp_imm2 = imm2; end
                end else begin
                    rand_val2 = $urandom_range(0, 99);
                    if (i_pat == 4) begin
                        if (rand_val2 < 40) op2 = 3'b101; else if (rand_val2 < 80) op2 = 3'b100; else op2 = $urandom_range(0, 3);
                    end else op2 = $urandom_range(0, 7);
                    
                    if (inst1_word[15:13] == 5 && op2 == 5) op2 = $urandom_range(0, 4); 
                    if (step % 50 <= 15 || step % 50 >= 35) if (op2 == 3'b101) op2 = 3'b100;
                    if (step < 50) begin
                        if (step % 5 == 0) begin op2 = 3'b000; rs2 = prev_rt2; rt2 = prev_rd2; end 
                        else if (step % 5 == 1) op2 = 3'b001; 
                        else if (step % 5 == 2) op2 = 3'b111; 
                        else if (step % 5 == 3) op2 = 3'b101; 
                        else if (step % 5 == 4) op2 = 3'b100; 
                    end
                    
                    rs2 = $urandom_range(0, 7); 
                    rt2 = (op2 == 5 || op2 == 6) ? $urandom_range(0, 7) : $urandom_range(3, 7); 
                    rd2 = $urandom_range(3, 7); rl2 = $urandom_range(3, 7); func2 = $urandom_range(0, 7); 

                    // 🌟 狀況控制中心：處理到達 4095 的行為
                    if (pc2 == 4095) begin
                        if (scenario_mode == 1) begin
                            // 🚀 狀況二：給它臨門一腳！生成普通 ALU，next_pc 變 4096，提早結束！
                            op2 = 3'b000; rs2 = 0; rt2 = 0; rd2 = 0; func2 = 0; 
                            inst2_word = {op2, rs2, rt2, rd2, func2, 1'b0};
                        end else begin
                            // 🛑 狀況一與三：強迫停車，死迴圈消耗步數
                            op2 = 3'b111; target2 = 4095; inst2_word = {op2, target2[11:0], 1'b0}; 
                        end
                    end else if (scenario_mode == 0 && steps_left <= 40) begin
                        distance2 = 4095 - pc2;
                        if (distance2 == steps_left) begin op2 = 3'b000; rs2 = 0; rt2 = 0; rd2 = 0; func2 = 0; inst2_word = {op2, rs2, rt2, rd2, func2, 1'b0}; end 
                        else if (distance2 > steps_left) begin
                            op2 = 3'b111; jump_offset2 = distance2 - steps_left + 1;
                            if (jump_offset2 > 120) jump_offset2 = 120;
                            target2 = pc2 + jump_offset2; inst2_word = {op2, target2[11:0], 1'b0};
                        end else begin
                            op2 = 3'b111; target2 = pc2; inst2_word = {op2, target2[11:0], 1'b0};
                        end
                    end else begin
                        if (op2 == 4 || op2 == 5) begin
                            valid_rs_count = 0;
                            for (k = 0; k < 3; k = k + 1) begin
                                if (($signed(sim_r2[k]) + 63 >= 0) && ($signed(sim_r2[k]) - 64 <= 4095)) begin
                                    if (($signed(sim_r2[k]) + 63 >= last_word_offset2 - 100) && ($signed(sim_r2[k]) - 64 <= last_word_offset2 + 100)) begin
                                        valid_rs_list[valid_rs_count] = k; valid_rs_count = valid_rs_count + 1;
                                    end
                                end
                            end
                            if (valid_rs_count == 0) begin valid_rs_list[0] = 0; valid_rs_count = 1; end 
                            
                            rs2 = valid_rs_list[$unsigned($random) % valid_rs_count];
                            current_r2 = $signed(sim_r2[rs2]);
                            
                            safe_min = -64;
                            if ((0 - current_r2) > safe_min) safe_min = (0 - current_r2);
                            safe_max = 63;
                            if ((4095 - current_r2) < safe_max) safe_max = (4095 - current_r2);
                            
                            temp_min = last_word_offset2 - 100 - current_r2;
                            temp_max = last_word_offset2 + 100 - current_r2;
                            
                            if (temp_min > safe_min) safe_min = temp_min;
                            if (temp_max < safe_max) safe_max = temp_max;
                            
                            if (safe_min > safe_max) begin
                                safe_min = -64;
                                if ((0 - current_r2) > safe_min) safe_min = (0 - current_r2);
                                safe_max = 63;
                                if ((4095 - current_r2) < safe_max) safe_max = (4095 - current_r2);
                            end

                            temp_imm2 = safe_min + $signed($urandom_range(0, safe_max - safe_min));
                            
                            inject_hazard = (step < 50) ? 100 : ($urandom_range(0, 99));
                            if ((inst1_word[15:13] == 4 || inst1_word[15:13] == 5) && (op2 == 4 || op2 == 5)) begin
                                if (inject_hazard > 20) begin
                                    expected_addr1 = 4096 + ($signed(sim_r1[inst1_word[12:10]]) + $signed({{9{inst1_word[6]}}, inst1_word[6:0]})) * 2;
                                    for (k = 0; k < 3; k = k + 1) begin
                                        target_imm2 = (expected_addr1 - 4096) / 2 - $signed(sim_r2[k]);
                                        if (target_imm2 >= -64 && target_imm2 <= 63) begin
                                            rs2 = k; temp_imm2 = target_imm2; 
                                        end
                                    end
                                end
                            end

                            last_word_offset2 = $signed(sim_r2[rs2]) + temp_imm2;
                            inst2_word = {op2, rs2, rt2, temp_imm2[6:0]};
                            
                        end else if (op2 == 6) begin 
                            if ($urandom_range(0, 100) < 30) rt2 = rs2; 
                            if ($urandom_range(0, 99) < 85) imm2_ext = $urandom_range(1, 63); else imm2_ext = -($signed($urandom_range(1, 63)));
                            if (pc2 + 1 + imm2_ext < 0) imm2_ext = -1 - pc2; 
                            // 🌟 解除 4090 結界！
                            if (pc2 + 1 + imm2_ext > max_next_pc) imm2_ext = max_next_pc - 1 - pc2;
                            inst2_word = {op2, rs2, rt2, imm2_ext[6:0]};
                        end else if (op2 == 7) begin 
                            target2 = pc2 + (($urandom_range(0, 99) < 85) ? $urandom_range(1, 127) : -($signed($urandom_range(1, 127))));
                            if (target2 < 0) target2 = 0; 
                            // 🌟 解除 4090 結界！
                            if (target2 > max_next_pc) target2 = max_next_pc;
                            inst2_word = {op2, target2[11:0], 1'b0};
                        end else if (op2 == 2 || op2 == 3) begin
                            imm2_ext = $urandom_range(0, 127) - 64; 
                            inst2_word = {op2, rs2, rt2, imm2_ext[6:0]};
                        end else begin
                            if (op2 == 1) inst2_word = {op2, rs2, rt2, rd2, rl2, 1'b0}; else inst2_word = {op2, rs2, rt2, rd2, func2, 1'b0};
                        end
                    end
                end
                inst_2_dram[pc2*2] = inst2_word[7:0]; inst_2_dram[pc2*2+1] = inst2_word[15:8];
                valid_inst2[pc2] = 1;
            end else inst2_word = {inst_2_dram[pc2*2+1], inst_2_dram[pc2*2]}; 

            // --- JIT END --- 

            op1 = inst1_word[15:13]; 
            if (op1 == 7) target1 = inst1_word[12:0]; 
            else begin rs1 = inst1_word[12:10]; rt1 = inst1_word[9:7]; imm1 = inst1_word[6:0]; rd1 = inst1_word[6:4]; func1 = inst1_word[3:1]; rl1 = inst1_word[3:1]; end
            imm1_ext = {{9{imm1[6]}}, imm1[6:0]}; 
            val_rs1 = sim_r1[rs1]; val_rt1 = sim_r1[rt1];
            
            op2 = inst2_word[15:13]; 
            if (op2 == 7) target2 = inst2_word[12:0]; 
            else begin rs2 = inst2_word[12:10]; rt2 = inst2_word[9:7]; imm2 = inst2_word[6:0]; rd2 = inst2_word[6:4]; func2 = inst2_word[3:1]; rl2 = inst2_word[3:1]; end
            imm2_ext = {{9{imm2[6]}}, imm2[6:0]}; 
            val_rs2 = sim_r2[rs2]; val_rt2 = sim_r2[rt2];

            next_pc1 = pc1 + 1; 
            next_pc2 = pc2 + 1;

            if (op1 == 4 || op1 == 5) addr1 = 4096 + ($signed(val_rs1) + imm1_ext) * 2; else addr1 = 0;
            if (op2 == 4 || op2 == 5) addr2 = 4096 + ($signed(val_rs2) + imm2_ext) * 2; else addr2 = 0;

            if (op1 == 5) begin 
                golden_dram[addr1] = sim_r1[rt1][7:0]; 
                golden_dram[addr1+1] = sim_r1[rt1][15:8];
                c1_store_valid[step] = 1'b1; c1_store_addr[step] = addr1; c1_store_data[step] = sim_r1[rt1];
            end
            if (op2 == 5) begin 
                golden_dram[addr2] = sim_r2[rt2][7:0]; 
                golden_dram[addr2+1] = sim_r2[rt2][15:8];
                c2_store_valid[step] = 1'b1; c2_store_addr[step] = addr2; c2_store_data[step] = sim_r2[rt2];
            end

            if (op1 == 4) sim_r1[rt1] = {golden_dram[addr1+1], golden_dram[addr1]};
            if (op2 == 4) sim_r2[rt2] = {golden_dram[addr2+1], golden_dram[addr2]};

            if (op1 == 6) begin if (val_rs1 == val_rt1) next_pc1 = pc1 + imm1_ext + 1; end 
            else if (op1 == 7) next_pc1 = target1 >> 1;
            else if (op1 != 4 && op1 != 5) begin
                case (op1)
                    3'b000: case (func1)
                                3'b000: sim_r1[rd1] = val_rs1 + val_rt1; 
                                3'b001: sim_r1[rd1] = val_rs1 - val_rt1;
                                3'b010: sim_r1[rd1] = val_rs1 & val_rt1; 
                                3'b011: sim_r1[rd1] = val_rs1 | val_rt1;
                                3'b100: sim_r1[rd1] = ~(val_rs1 & val_rt1); 
                                3'b101: sim_r1[rd1] = ~(val_rs1 | val_rt1);
                                3'b110: sim_r1[rd1] = val_rs1 ^ val_rt1; 
                                3'b111: sim_r1[rd1] = (val_rs1 < val_rt1) ? 1 : 0; 
                            endcase
                    3'b001: begin mult_res1 = val_rs1 * val_rt1; sim_r1[rd1] = mult_res1[31:16]; sim_r1[rl1] = mult_res1[15:0]; end
                    3'b010: sim_r1[rt1] = val_rs1 + imm1_ext; 
                    3'b011: sim_r1[rt1] = val_rs1 - imm1_ext; 
                endcase
            end

            if (op2 == 6) begin if (val_rs2 == val_rt2) next_pc2 = pc2 + imm2_ext + 1; end 
            else if (op2 == 7) next_pc2 = target2 >> 1;
            else if (op2 != 4 && op2 != 5) begin
                case (op2)
                    3'b000: case (func2)
                                3'b000: sim_r2[rd2] = val_rs2 + val_rt2; 
                                3'b001: sim_r2[rd2] = val_rs2 - val_rt2;
                                3'b010: sim_r2[rd2] = val_rs2 & val_rt2; 
                                3'b011: sim_r2[rd2] = val_rs2 | val_rt2;
                                3'b100: sim_r2[rd2] = ~(val_rs2 & val_rt2); 
                                3'b101: sim_r2[rd2] = ~(val_rs2 | val_rt2);
                                3'b110: sim_r2[rd2] = val_rs2 ^ val_rt2; 
                                3'b111: sim_r2[rd2] = (val_rs2 < val_rt2) ? 1 : 0;
                            endcase
                    3'b001: begin mult_res2 = val_rs2 * val_rt2; sim_r2[rd2] = mult_res2[31:16]; sim_r2[rl2] = mult_res2[15:0]; end
                    3'b010: sim_r2[rt2] = val_rs2 + imm2_ext;
                    3'b011: sim_r2[rt2] = val_rs2 - imm2_ext;
                endcase
            end

            for (i = 0; i < 8; i = i + 1) begin
                golden_r1[step][i] = sim_r1[i]; 
                golden_r2[step][i] = sim_r2[i];
            end
            
            if (op1 == 0 || op1 == 1) prev_rd1 = rd1; else prev_rd1 = rt1;
            if (op2 == 0 || op2 == 1) prev_rd2 = rd2; else prev_rd2 = rt2;
            prev_rt1 = rt1; prev_rt2 = rt2;
            
            $fdisplay(fd_trace, "[Step = %4d | PC1 = %4d | PC2 = %4d]", step, pc1, pc2);
            case (op1)
                3'b000: $fdisplay(fd_trace, "  [Core 1] ALU  (op:%3b, rs:r%0d, rt:r%0d, rd:r%0d, func:%3b) | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op1, rs1, rt1, rd1, func1, sim_r1[0], sim_r1[1], sim_r1[2], sim_r1[3], sim_r1[4], sim_r1[5], sim_r1[6], sim_r1[7]);
                3'b001: $fdisplay(fd_trace, "  [Core 1] MULT (op:%3b, rs:r%0d, rt:r%0d, rd:r%0d, rl:r%0d)   | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op1, rs1, rt1, rd1, rl1, sim_r1[0], sim_r1[1], sim_r1[2], sim_r1[3], sim_r1[4], sim_r1[5], sim_r1[6], sim_r1[7]);
                3'b010, 3'b011: $fdisplay(fd_trace, "  [Core 1] ALUI (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op1, rs1, rt1, imm1_ext, sim_r1[0], sim_r1[1], sim_r1[2], sim_r1[3], sim_r1[4], sim_r1[5], sim_r1[6], sim_r1[7]);
                3'b100: $fdisplay(fd_trace, "  [Core 1] LOAD (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op1, rs1, rt1, imm1_ext, sim_r1[0], sim_r1[1], sim_r1[2], sim_r1[3], sim_r1[4], sim_r1[5], sim_r1[6], sim_r1[7]);
                3'b101: $fdisplay(fd_trace, "  [Core 1] STOR (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op1, rs1, rt1, imm1_ext, sim_r1[0], sim_r1[1], sim_r1[2], sim_r1[3], sim_r1[4], sim_r1[5], sim_r1[6], sim_r1[7]);
                3'b110: $fdisplay(fd_trace, "  [Core 1] BEQ  (op:%3b, rs:r%0d=%0d, rt:r%0d=%0d, imm:%5d) Target: %4d -> Next PC1: %4d", op1, rs1, val_rs1, rt1, val_rt1, imm1_ext, pc1+1+imm1_ext, next_pc1);
                3'b111: $fdisplay(fd_trace, "  [Core 1] JUMP (op:%3b, target: %4d) -> Next PC1: %4d", op1, target1, next_pc1);
            endcase
            case (op2)
                3'b000: $fdisplay(fd_trace, "  [Core 2] ALU  (op:%3b, rs:r%0d, rt:r%0d, rd:r%0d, func:%3b) | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op2, rs2, rt2, rd2, func2, sim_r2[0], sim_r2[1], sim_r2[2], sim_r2[3], sim_r2[4], sim_r2[5], sim_r2[6], sim_r2[7]);
                3'b001: $fdisplay(fd_trace, "  [Core 2] MULT (op:%3b, rs:r%0d, rt:r%0d, rd:r%0d, rl:r%0d)   | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op2, rs2, rt2, rd2, rl2, sim_r2[0], sim_r2[1], sim_r2[2], sim_r2[3], sim_r2[4], sim_r2[5], sim_r2[6], sim_r2[7]);
                3'b010, 3'b011: $fdisplay(fd_trace, "  [Core 2] ALUI (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op2, rs2, rt2, imm2_ext, sim_r2[0], sim_r2[1], sim_r2[2], sim_r2[3], sim_r2[4], sim_r2[5], sim_r2[6], sim_r2[7]);
                3'b100: $fdisplay(fd_trace, "  [Core 2] LOAD (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op2, rs2, rt2, imm2_ext, sim_r2[0], sim_r2[1], sim_r2[2], sim_r2[3], sim_r2[4], sim_r2[5], sim_r2[6], sim_r2[7]);
                3'b101: $fdisplay(fd_trace, "  [Core 2] STOR (op:%3b, rs:r%0d, rt:r%0d, imm:%6d)       | R0~R7: %6d %6d %6d %6d %6d %6d %6d %6d", op2, rs2, rt2, imm2_ext, sim_r2[0], sim_r2[1], sim_r2[2], sim_r2[3], sim_r2[4], sim_r2[5], sim_r2[6], sim_r2[7]);
                3'b110: $fdisplay(fd_trace, "  [Core 2] BEQ  (op:%3b, rs:r%0d=%0d, rt:r%0d=%0d, imm:%5d) Target: %4d -> Next PC2: %4d", op2, rs2, val_rs2, rt2, val_rt2, imm2_ext, pc2+1+imm2_ext, next_pc2);
                3'b111: $fdisplay(fd_trace, "  [Core 2] JUMP (op:%3b, target: %4d) -> Next PC2: %4d", op2, target2, next_pc2);
            endcase
            $fdisplay(fd_trace, "--------------------------------------------------------------------------");

            pc1 = next_pc1;
            pc2 = next_pc2;
            step = step + 1;
        end

        TOTAL_STEPS = step;

        fd_inst1 = $fopen("../00_TESTBED/DRAM/inst_1_dram_file.dat", "w");
        fd_inst2 = $fopen("../00_TESTBED/DRAM/inst_2_dram_file.dat", "w");

        for (i = 0; i < 4096; i = i + 1) begin
            if(i == 0) begin $fdisplay(fd_inst1, "//PATTERN NO. %0d", i_pat); $fdisplay(fd_inst2, "//PATTERN NO. %0d", i_pat); end
            
            inst1_word = {inst_1_dram[i*2+1], inst_1_dram[i*2]};
            op1 = inst1_word[15:13]; rs1 = inst1_word[12:10]; rt1 = inst1_word[9:7]; rd1 = inst1_word[6:4];
            func1 = inst1_word[3:1]; rl1 = inst1_word[3:1]; imm1 = inst1_word[6:0]; target1 = inst1_word[12:0];
            imm1_ext = {{9{imm1[6]}}, imm1[6:0]}; 

            case(op1)
                3'b000: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: ALU  %b rs = %0d, rt = %0d, rd = %0d, func = %0b", i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, rd1, func1);
                3'b001: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: MULT %b rs = %0d, rt = %0d, rd = %0d, rl = %0d",   i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, rd1, rl1);
                3'b010: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: ADDI %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, $signed(imm1_ext));
                3'b011: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: SUBI %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, $signed(imm1_ext));
                3'b100: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: LOAD %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, $signed(imm1_ext));
                3'b101: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: STOR %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, $signed(imm1_ext));
                3'b110: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: BEQ  %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, rs1, rt1, $signed(imm1_ext));
                3'b111: $fdisplay(fd_inst1, "@%05x\n%02x %02x // I_inst: JUMP %b target = %0d",                           i*2, inst_1_dram[i*2], inst_1_dram[i*2+1], inst1_word, target1);
            endcase

            inst2_word = {inst_2_dram[i*2+1], inst_2_dram[i*2]};
            op2 = inst2_word[15:13]; rs2 = inst2_word[12:10]; rt2 = inst2_word[9:7]; rd2 = inst2_word[6:4];
            func2 = inst2_word[3:1]; rl2 = inst2_word[3:1]; imm2 = inst2_word[6:0]; target2 = inst2_word[12:0];
            imm2_ext = {{9{imm2[6]}}, imm2[6:0]}; 

            case(op2)
                3'b000: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: ALU  %b rs = %0d, rt = %0d, rd = %0d, func = %0b", i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, rd2, func2);
                3'b001: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: MULT %b rs = %0d, rt = %0d, rd = %0d, rl = %0d",   i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, rd2, rl2);
                3'b010: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: ADDI %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, $signed(imm2_ext));
                3'b011: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: SUBI %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, $signed(imm2_ext));
                3'b100: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: LOAD %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, $signed(imm2_ext));
                3'b101: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: STOR %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, $signed(imm2_ext));
                3'b110: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: BEQ  %b rs = %0d, rt = %0d, imm = %0d",          i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, rs2, rt2, $signed(imm2_ext));
                3'b111: $fdisplay(fd_inst2, "@%05x\n%02x %02x // I_inst: JUMP %b target = %0d",                           i*2, inst_2_dram[i*2], inst_2_dram[i*2+1], inst2_word, target2);
            endcase
        end
        $fclose(fd_inst1); $fclose(fd_inst2); $fclose(fd_trace);


        $display("[INFO] Data Generation Completed. Total Steps: %0d", TOTAL_STEPS);
    end
endtask

task reset_task;
    begin
        rst_n = 1'b1; 
        force clk = 0; 
        #(`CYCLE_TIME / 2.0); 
        rst_n = 1'b0; 
        #(100.0);
        if (stall_1 !== 1'b1 || stall_2 !== 1'b1) begin 
            $display("  [ERROR] stall_1 and stall_2 must be High (1) during Reset! "); 
            $finish; 
        end
        if (awvalid_s_inf_inst_1 !== 1'b0 || wvalid_s_inf_inst_1 !== 1'b0 || arvalid_s_inf_inst_1 !== 1'b0 ||
            awvalid_s_inf_inst_2 !== 1'b0 || wvalid_s_inf_inst_2 !== 1'b0 || arvalid_s_inf_inst_2 !== 1'b0 ||
            awvalid_s_inf_data   !== 1'b0 || wvalid_s_inf_data   !== 1'b0 || arvalid_s_inf_data   !== 1'b0) begin
            $display("  [ERROR] AXI4 Master valid signals must be Low (0) during Reset! "); 
            $finish;
        end
        #(10.0); 
        rst_n = 1'b1; 
        release clk;
    end
endtask

task wait_and_check_task;
    integer step_1;
    integer step_2;
    integer lat_cnt;
    integer next_check_step; 
    
    begin
        step_1 = 0; step_2 = 0; lat_cnt = 0; latency = 0; next_check_step = 50; 

        while (step_1 < TOTAL_STEPS || step_2 < TOTAL_STEPS) begin
            
            if (lat_cnt > `MAX_WAIT_READY_CYCLE) begin
                $display("=============================================================");
                $display("  [ERROR] Timeout! CPU execution taking too long : %0d.            ", lat_cnt);
                $display("=============================================================");
                $finish;
            end

            if (stall_1 === 1'b0 && step_1 < TOTAL_STEPS) begin
                if (u_DCCPU.core_1_r0 !== golden_r1[step_1][0] || u_DCCPU.core_1_r1 !== golden_r1[step_1][1] ||
                    u_DCCPU.core_1_r2 !== golden_r1[step_1][2] || u_DCCPU.core_1_r3 !== golden_r1[step_1][3] ||
                    u_DCCPU.core_1_r4 !== golden_r1[step_1][4] || u_DCCPU.core_1_r5 !== golden_r1[step_1][5] ||
                    u_DCCPU.core_1_r6 !== golden_r1[step_1][6] || u_DCCPU.core_1_r7 !== golden_r1[step_1][7]) begin
                    $display("==================================================================================================");
                    $display("  [ERROR] Core 1 Register mismatch at Execution Step = %0d", step_1);
                    $display("  [EXPECT] r0 = %0d , r1 = %0d , r2 = %0d , r3 = %0d , r4 = %0d , r5 = %0d , r6 = %0d , r7 = %0d", 
                             golden_r1[step_1][0], golden_r1[step_1][1], golden_r1[step_1][2], golden_r1[step_1][3], 
                             golden_r1[step_1][4], golden_r1[step_1][5], golden_r1[step_1][6], golden_r1[step_1][7]);
                    $display("  [YOURS]  r0 = %0d , r1 = %0d , r2 = %0d , r3 = %0d , r4 = %0d , r5 = %0d , r6 = %0d , r7 = %0d", 
                             u_DCCPU.core_1_r0, u_DCCPU.core_1_r1, u_DCCPU.core_1_r2, u_DCCPU.core_1_r3, 
                             u_DCCPU.core_1_r4, u_DCCPU.core_1_r5, u_DCCPU.core_1_r6, u_DCCPU.core_1_r7);
                    $display("==================================================================================================");
                    $finish;
                end
                step_1 = step_1 + 1; 
                lat_cnt = 0; 
            end

            if (stall_2 === 1'b0 && step_2 < TOTAL_STEPS) begin
                if (u_DCCPU.core_2_r0 !== golden_r2[step_2][0] || u_DCCPU.core_2_r1 !== golden_r2[step_2][1] ||
                    u_DCCPU.core_2_r2 !== golden_r2[step_2][2] || u_DCCPU.core_2_r3 !== golden_r2[step_2][3] ||
                    u_DCCPU.core_2_r4 !== golden_r2[step_2][4] || u_DCCPU.core_2_r5 !== golden_r2[step_2][5] ||
                    u_DCCPU.core_2_r6 !== golden_r2[step_2][6] || u_DCCPU.core_2_r7 !== golden_r2[step_2][7]) begin
                    $display("==================================================================================================");
                    $display("  [ERROR] Core 2 Register mismatch at Execution Step = %0d", step_2);
                    $display("  [EXPECT] r0 = %0d , r1 = %0d , r2 = %0d , r3 = %0d , r4 = %0d , r5 = %0d , r6 = %0d , r7 = %0d", 
                             golden_r2[step_2][0], golden_r2[step_2][1], golden_r2[step_2][2], golden_r2[step_2][3], 
                             golden_r2[step_2][4], golden_r2[step_2][5], golden_r2[step_2][6], golden_r2[step_2][7]);
                    $display("  [YOURS]  r0 = %0d , r1 = %0d , r2 = %0d , r3 = %0d , r4 = %0d , r5 = %0d , r6 = %0d , r7 = %0d", 
                             u_DCCPU.core_2_r0, u_DCCPU.core_2_r1, u_DCCPU.core_2_r2, u_DCCPU.core_2_r3, 
                             u_DCCPU.core_2_r4, u_DCCPU.core_2_r5, u_DCCPU.core_2_r6, u_DCCPU.core_2_r7);
                    $display("==================================================================================================");
                    $finish;
                end
                step_2 = step_2 + 1; 
                lat_cnt = 0; 
            end

            if (step_1 == next_check_step && step_2 == next_check_step) begin
                check_data_dram_task(step_1, step_2, "Synchronized DRAM Check");
                next_check_step = next_check_step + 50;
            end

            @(negedge clk);
            lat_cnt = lat_cnt + 1; 
            latency = latency + 1; 
        end
    end
endtask

task check_data_dram_task(input integer current_step_1, input integer current_step_2, input [50*8:1] trigger_name);
    integer idx;
    integer max_step;
    begin
        // 🛡️ Data DRAM 檢查 4096 words = 8192 bytes (0x1000 ~ 0x2FFF = 4096 ~ 12287)
        for (idx = 4096; idx < 12288; idx = idx + 1) begin
            expected_dram[idx] = pattern_start_dram[idx];
        end
        
        max_step = (current_step_1 > current_step_2) ? current_step_1 : current_step_2;

        for (idx = 0; idx < max_step; idx = idx + 1) begin
            if (idx < current_step_1 && c1_store_valid[idx]) begin
                expected_dram[c1_store_addr[idx]]   = c1_store_data[idx][7:0];
                expected_dram[c1_store_addr[idx]+1] = c1_store_data[idx][15:8];
            end
            if (idx < current_step_2 && c2_store_valid[idx]) begin
                expected_dram[c2_store_addr[idx]]   = c2_store_data[idx][7:0];
                expected_dram[c2_store_addr[idx]+1] = c2_store_data[idx][15:8];
            end
        end

        for (idx = 4096; idx < 12288; idx = idx + 1) begin
            if (u_DRAM_data.DRAM_r[idx] !== expected_dram[idx]) begin
                $display("=======================================================================================================");
                $display("                                             [ERROR]");
                $display("           %s ", trigger_name);
                $display("                           Data DRAM mismatch at Step = %0d, Addr = %0d", current_step_1, idx);
                $display(" ----------------------------------------------------------------------------------------------------- ");
                $display("                                  [EXPECT] DRAM data = %0d", {expected_dram[idx+1], expected_dram[idx]});
                $display("                                  [YOURS]  DRAM data = %0d", {u_DRAM_data.DRAM_r[idx+1], u_DRAM_data.DRAM_r[idx]});
                $display("=======================================================================================================");
                $finish;
            end
        end
    end
endtask

// =========================================================================
//           AXI Protocol
// =========================================================================
reg [31:0] last_awaddr_data; reg [31:0] last_araddr_data; reg [15:0] last_wdata_data;
reg last_awvalid_data; reg last_wvalid_data; reg last_arvalid_data; 
reg last_awready_data; reg last_wready_data; reg last_arready_data;
reg [31:0] last_araddr_inst_1; reg [31:0] last_araddr_inst_2; 
reg last_arvalid_inst_1; reg last_arvalid_inst_2; 
reg last_arready_inst_1; reg last_arready_inst_2;

// =========================================================================
//           AXI Latency Counters (300 cycles limit)
// =========================================================================
integer b_wait_data_cnt; integer r_wait_data_cnt; integer r_wait_inst1_cnt; integer r_wait_inst2_cnt;

always @(posedge clk) begin
    if (!rst_n) begin
        last_awvalid_data <= 0; last_awready_data <= 0; last_wvalid_data <= 0; last_wready_data <= 0; last_arvalid_data <= 0; last_arready_data <= 0;
        last_arvalid_inst_1 <= 0; last_arready_inst_1 <= 0; last_arvalid_inst_2 <= 0; last_arready_inst_2 <= 0;
        b_wait_data_cnt <= 0; r_wait_data_cnt <= 0; r_wait_inst1_cnt <= 0; r_wait_inst2_cnt <= 0;
    end else begin
        last_awvalid_data <= awvalid_s_inf_data; last_awready_data <= awready_s_inf_data; last_awaddr_data <= awaddr_s_inf_data;
        last_wvalid_data <= wvalid_s_inf_data; last_wready_data <= wready_s_inf_data; last_wdata_data <= wdata_s_inf_data;
        last_arvalid_data <= arvalid_s_inf_data; last_arready_data <= arready_s_inf_data; last_araddr_data <= araddr_s_inf_data;
        last_arvalid_inst_1 <= arvalid_s_inf_inst_1; last_arready_inst_1 <= arready_s_inf_inst_1; last_araddr_inst_1 <= araddr_s_inf_inst_1;
        last_arvalid_inst_2 <= arvalid_s_inf_inst_2; last_arready_inst_2 <= arready_s_inf_inst_2; last_araddr_inst_2 <= araddr_s_inf_inst_2;

        if (bvalid_s_inf_data && !bready_s_inf_data) b_wait_data_cnt <= b_wait_data_cnt + 1; else b_wait_data_cnt <= 0;
        if (rvalid_s_inf_data && !rready_s_inf_data) r_wait_data_cnt <= r_wait_data_cnt + 1; else r_wait_data_cnt <= 0;
        if (rvalid_s_inf_inst_1 && !rready_s_inf_inst_1) r_wait_inst1_cnt <= r_wait_inst1_cnt + 1; else r_wait_inst1_cnt <= 0;
        if (rvalid_s_inf_inst_2 && !rready_s_inf_inst_2) r_wait_inst2_cnt <= r_wait_inst2_cnt + 1; else r_wait_inst2_cnt <= 0;
    end
end

always @(negedge clk) begin
    if (rst_n) begin
        if (last_awvalid_data && !last_awready_data && awaddr_s_inf_data !== last_awaddr_data) begin 
            $display("==================================================================================================");
            $display("  [ERROR] AXI Protocol Violation (AXI-2 FAIL)");
            $display("  [Channel]  Data DRAM - Write Address (AW)");
            $display("  [Reason]   'awaddr' changed before handshake (awready=1) occurred.");
            $display("==================================================================================================");
            $finish; 
        end
        if (last_wvalid_data && !last_wready_data && wdata_s_inf_data !== last_wdata_data) begin 
            $display("==================================================================================================");
            $display("  [ERROR] AXI Protocol Violation (AXI-2 FAIL)");
            $display("  [Channel]  Data DRAM - Write Data (W)");
            $display("  [Reason]   'wdata' changed before handshake (wready=1) occurred.");
            $display("==================================================================================================");
            $finish; 
        end
        if (last_arvalid_data && !last_arready_data && araddr_s_inf_data !== last_araddr_data) begin 
            $display("==================================================================================================");
            $display("  [ERROR] AXI Protocol Violation (AXI-2 FAIL)");
            $display("  [Channel]  Data DRAM - Read Address (AR)");
            $display("  [Reason]   'araddr' changed before handshake (arready=1) occurred.");
            $display("==================================================================================================");
            $finish; 
        end
        if (last_arvalid_inst_1 && !last_arready_inst_1 && araddr_s_inf_inst_1 !== last_araddr_inst_1) begin 
            $display("==================================================================================================");
            $display("  [ERROR] AXI Protocol Violation (AXI-2 FAIL)");
            $display("  [Channel]  Instruction 1 DRAM - Read Address (AR)");
            $display("  [Reason]   'araddr' changed before handshake (arready=1) occurred.");
            $display("==================================================================================================");
            $finish;
        end
        if (last_arvalid_inst_2 && !last_arready_inst_2 && araddr_s_inf_inst_2 !== last_araddr_inst_2) begin 
            $display("==================================================================================================");
            $display("  [ERROR] AXI Protocol Violation (AXI-2 FAIL)");
            $display("  [Channel]  Instruction 2 DRAM - Read Address (AR)");
            $display("  [Reason]   'araddr' changed before handshake (arready=1) occurred.");
            $display("==================================================================================================");
            $finish; 
        end

        if (b_wait_data_cnt > 300) begin
            $display("==================================================================================================");
            $display("  [ERROR] AXI Handshake Timeout Violation");
            $display("  [Channel]  Data DRAM - Write Response (B)");
            $display("  [Reason]   CPU did not assert 'bready' within 300 cycles after 'bvalid' was high.");
            $display("==================================================================================================");
            $finish;
        end
        if (r_wait_data_cnt > 300) begin
            $display("==================================================================================================");
            $display("  [ERROR] AXI Handshake Timeout Violation");
            $display("  [Channel]  Data DRAM - Read Data (R)");
            $display("  [Reason]   CPU did not assert 'rready' within 300 cycles after 'rvalid' was high.");
            $display("==================================================================================================");
            $finish;
        end
        if (r_wait_inst1_cnt > 300) begin
            $display("==================================================================================================");
            $display("  [ERROR] AXI Handshake Timeout Violation");
            $display("  [Channel]  Instruction 1 DRAM - Read Data (R)");
            $display("  [Reason]   CPU did not assert 'rready' within 300 cycles after 'rvalid' was high.");
            $display("==================================================================================================");
            $finish;
        end
        if (r_wait_inst2_cnt > 300) begin
            $display("==================================================================================================");
            $display("  [ERROR] AXI Handshake Timeout Violation");
            $display("  [Channel]  Instruction 2 DRAM - Read Data (R)");
            $display("  [Reason]   CPU did not assert 'rready' within 300 cycles after 'rvalid' was high.");
            $display("==================================================================================================");
            $finish;
        end
    end
end
endmodule