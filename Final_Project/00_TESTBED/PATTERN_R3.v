//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name       : PATTERN.v
//   Module Name     : PATTERN.v
//   Release version : V18.5 (Single-Run Marathon & Seed Injected Edition)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
    `define CYCLE_TIME 6.0 
`elsif GATE
    `define CYCLE_TIME 3.7
`elsif CHIP
    `define CYCLE_TIME 6.0
`elsif POST
    `define CYCLE_TIME 6.0
`endif

`ifdef FUNC
    `define PAT_NUM 40960
    `define MAX_WAIT_READY_CYCLE 2000
`endif
`ifdef PERF
    `define PAT_NUM 10000
    `define MAX_WAIT_READY_CYCLE 100000
`endif

`ifndef SEED_NUMBER
    `define SEED_NUMBER 2321
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

integer latency;
integer TOTAL_STEPS; 

integer seed = `SEED_NUMBER;
integer dump_seed;

reg [15:0] golden_r1 [0:100000][0:7];
reg [15:0] golden_r2 [0:100000][0:7];

reg [15:0] golden_inst1 [0:4095];
reg [15:0] golden_inst2 [0:4095];

reg [7:0] inst_1_dram [0:8191];
reg [7:0] inst_2_dram [0:8191];
reg [7:0] data_dram [0:12287]; 
reg [7:0] initial_dram [0:12287];
reg [7:0] golden_dram [0:12287]; 
reg [7:0] expected_dram [0:12287]; 
reg [7:0] pattern_start_dram [0:12287]; 

reg        c1_store_valid [0:100000]; 
reg [31:0] c1_store_addr  [0:100000]; 
reg [15:0] c1_store_data  [0:100000];

reg        c2_store_valid [0:100000]; 
reg [31:0] c2_store_addr  [0:100000]; 
reg [15:0] c2_store_data  [0:100000];

reg valid_inst1 [0:4095];
reg valid_inst2 [0:4095];

integer pc1;
integer pc2;

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
    if(`MAX_WAIT_READY_CYCLE == 2000)$display("now is at FUNC mode");
    if(`MAX_WAIT_READY_CYCLE == 100000)$display("now is at PERF mode");
    
    if ($value$plusargs("seed=%d", seed)) begin
        $display("\033[0;35m[INFO] External SEED injected: %0d\033[m", seed);
    end else begin
        $display("[INFO] Using default SEED: %0d", seed);
    end
    dump_seed = $urandom(seed);
    $display("[INFO] Running with SEED: %0d", seed);
    $display("[INFO] Target Instruction Steps (PAT_NUM): %0d", `PAT_NUM);
    
    generate_and_simulate_task;
    
    $readmemh("../00_TESTBED/DRAM/inst_1_dram_file.dat", u_DRAM_inst1.DRAM_r); 
    $readmemh("../00_TESTBED/DRAM/inst_2_dram_file.dat", u_DRAM_inst2.DRAM_r);
    $readmemh("../00_TESTBED/DRAM/data_dram_file.dat", u_DRAM_data.DRAM_r);
    
    reset_task;
    wait_and_check_task;

    $display("==================================================");
    $display("\033[0;34mPASS MARATHON RUN,\033[m \033[0;32mExecution Steps: %5d, Latency Cycle: %5d\033[m", TOTAL_STEPS, latency);
    $display("==================================================");
    
    $display("=============================================================");
    $display("  [INFO] Congratulations! Dual-Core CPU Execution PASSED!    ");
    $display("  [INFO] Total Latency Cycles = %0d                        ", latency);
    $display("  [INFO] Your cycle time = %0f                        ", `CYCLE_TIME);
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
    integer valid_rs_count;
    integer min_imm, max_imm, target_imm2, inject_hazard;
    
    // 🌟 SEED 引擎變數
    integer dynamic_pat_num;
    integer sweep_period;
    integer op_profile;
    integer loop_mode; // 🌟 0: 線性掃蕩 (掃蕩 ADDR), 1: 混沌迴圈 (測試 Branch)
    
    // 🌟 基於時間的牽引目標
    integer target_center;
    integer target_min, target_max;
    integer sweep_up;
    
    reg [15:0] inst1_word, inst2_word;
    reg [2:0]  op1, op2, rs1, rt1, rd1, rs2, rt2, rd2, func1, func2, rl1, rl2;
    reg [2:0]  prev_rd1, prev_rt1, prev_rd2, prev_rt2;
    reg [3:0]  valid_rs_list [0:7];
    reg signed [15:0] imm1_ext, imm2_ext; 
    reg signed [15:0] val_rs1, val_rt1, val_rs2, val_rt2;
    reg signed [31:0] mult_res1, mult_res2;
    
    integer expected_addr1;
    integer addr1, addr2, target1, target2, temp_imm1, temp_imm2;
    reg [15:0] temp_data;

    begin
        // =========================================================================
        // 🌟 啟動多重宇宙 (Dynamic SEED Engine)
        // =========================================================================
        dynamic_pat_num = `PAT_NUM; 
        sweep_period    = $urandom_range(800, 3000);
        op_profile      = $urandom_range(0, 3);
        loop_mode       = $urandom_range(0, 1); // 隨機決定要測「掃蕩」還是「迴圈」
        
        $display("\n========================================================");
        $display(" 🌟 ENTERING MULTIVERSE: SEED %0d", `SEED_NUMBER);
        $display("   - Sweep Period  : %0d steps", sweep_period);
        $display("   - Op Profile    : %0d (0:Bal, 1:Mem, 2:ALU, 3:Branch)", op_profile);
        $display("   - Loop Mode     : %0d (0:Linear Sweep, 1:Loop Chaos)", loop_mode);
        $display("========================================================\n");

        for (i = 4096; i < 12288; i = i + 1) begin
            data_dram[i] = 8'd0; golden_dram[i] = 8'd0;
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

        for (i = 0; i < 8192; i = i + 1) begin
            inst_1_dram[i] = 8'd0; inst_2_dram[i] = 8'd0; 
        end
        for (i = 0; i < 4096; i = i + 1) begin
            valid_inst1[i] = 0; valid_inst2[i] = 0;
        end
        for (i = 0; i < 100000; i = i + 1) begin
            c1_store_valid[i] = 0; c2_store_valid[i] = 0;
        end
        
        for (i = 0; i < 8; i = i + 1) begin 
            sim_r1[i] = 0; sim_r2[i] = 0; 
        end
        
        pc1 = 0; pc2 = 0; step = 0; 
        prev_rd1 = 0; prev_rt1 = 0; prev_rd2 = 0; prev_rt2 = 0;
        
        for (i = 4096; i < 12288; i = i + 1) begin
            pattern_start_dram[i] = golden_dram[i];
        end

        fd_trace = $fopen("golden_trace.txt", "w");
        $fdisplay(fd_trace, "==========================================================================");
        $fdisplay(fd_trace, "                        MARATHON TRACE (SEED: %0d)", `SEED_NUMBER);
        $fdisplay(fd_trace, "==========================================================================");

        while (step < dynamic_pat_num && pc1 <= 4095 && pc2 <= 4095) begin
            
            // 🌟 目標中心跟著 step 推進
            target_center = (step % sweep_period) * 4095 / sweep_period;
            if ((step / sweep_period) % 2 == 1) begin
                target_center = 4095 - target_center; 
                sweep_up = 0;
            end else begin
                sweep_up = 1;
            end

            //---------------------------------------------------------------------
            //   JIT Generation for Core 1
            //---------------------------------------------------------------------
            if (!valid_inst1[pc1]) begin
                if (pc1 < 8) begin
                    if (pc1 == 0)      inst1_word = {3'b010, 3'd0, 3'd0, 7'd0}; 
                    else if (pc1 == 1) inst1_word = {3'b010, 3'd0, 3'd1, 7'd10};
                    else if (pc1 == 2) inst1_word = {3'b010, 3'd0, 3'd2, 7'd20};
                    else begin op1 = 3'b100; rs1 = 3'd0; rt1 = pc1[2:0]; imm1_ext = $urandom_range(0, 31); inst1_word = {op1, rs1, rt1, imm1_ext[6:0]}; end
                end else begin
                    // 🌟 戰鬥風格
                    if (op_profile == 1) begin 
                        if ($urandom_range(0, 100) < 55) op1 = $urandom_range(4, 5); else op1 = $urandom_range(0, 3);
                    end else if (op_profile == 2) begin 
                        if ($urandom_range(0, 100) < 65) op1 = $urandom_range(0, 3); else op1 = $urandom_range(4, 5);
                    end else if (op_profile == 3) begin 
                        if ($urandom_range(0, 100) < 30) op1 = $urandom_range(6, 7); else op1 = $urandom_range(0, 5);
                    end else begin
                        op1 = $urandom_range(0, 7);
                    end
                    if (step % 50 <= 15 || step % 50 >= 35) if (op1 == 3'b101) op1 = 3'b100;
                    
                    rs1 = $urandom_range(0, 7); 
                    
                    // 🌟 寬鬆保護：盡量不污染 r0, r1
                    rd1 = $urandom_range(2, 7); 
                    rl1 = $urandom_range(2, 7); 
                    if (op1 == 4) rt1 = $urandom_range(2, 7); 
                    else if (op1 == 5 || op1 == 6) rt1 = $urandom_range(0, 7); 
                    else rt1 = $urandom_range(2, 7);
                    
                    func1 = $urandom_range(0, 7); 

                    if (pc1 == 4095) begin
                        op1 = 3'b111; target1 = 4095; inst1_word = {op1, target1[11:0], 1'b0}; 
                    end 
                    else begin
                        if (op1 == 4 || op1 == 5) begin
                            valid_rs_count = 0;
                            target_min = target_center - 100; if (target_min < 0) target_min = 0;
                            target_max = target_center + 100; if (target_max > 4095) target_max = 4095;

                            for (k = 0; k < 2; k = k + 1) begin // 只用 r0, r1 當指標
                                if (($signed(sim_r1[k]) + 63 >= target_min) && ($signed(sim_r1[k]) - 64 <= target_max)) begin 
                                    valid_rs_list[valid_rs_count] = k; valid_rs_count = valid_rs_count + 1;
                                end
                            end
                            
                            if (valid_rs_count == 0) begin
                                op1 = 3'b010; 
                                rs1 = $urandom_range(0, 1); rt1 = rs1; 
                                if ($signed(sim_r1[rs1]) < target_center) imm1_ext = 63;
                                else imm1_ext = -64;
                                inst1_word = {op1, rs1, rt1, imm1_ext[6:0]};
                            end else begin
                                rs1 = valid_rs_list[$unsigned($urandom) % valid_rs_count];
                                min_imm = target_min - $signed(sim_r1[rs1]); if (min_imm < -64) min_imm = -64;
                                max_imm = target_max - $signed(sim_r1[rs1]); if (max_imm > 63) max_imm = 63;
                                if (max_imm < min_imm) begin min_imm = 0; max_imm = 0; end
                                
                                temp_imm1 = min_imm + ($unsigned($urandom) % (max_imm - min_imm + 1));
                                inst1_word = {op1, rs1, rt1, temp_imm1[6:0]};
                            end
                            
                        end else if (op1 == 6) begin 
                            if ($urandom_range(0, 100) < 30) rt1 = rs1; 
                            
                            // 🌟 雙模式切換！
                            if (loop_mode == 0) begin // 掃蕩模式：只能往前跳
                                imm1_ext = $urandom_range(1, 63); 
                            end else begin // 混沌模式：允許往後跳產生迴圈
                                if ($urandom_range(0, 100) < 70) imm1_ext = $urandom_range(1, 63); 
                                else imm1_ext = -$urandom_range(1, 64);
                            end
                            
                            if (pc1 + 1 + imm1_ext < 0) imm1_ext = -1 - pc1; 
                            if (pc1 + 1 + imm1_ext > 4095) imm1_ext = 4095 - 1 - pc1; 
                            inst1_word = {op1, rs1, rt1, imm1_ext[6:0]};
                            
                        end else if (op1 == 7) begin 
                            // 🌟 雙模式切換！
                            if (loop_mode == 0) begin
                                jump_offset1 = $urandom_range(1, 127);
                            end else begin
                                if ($urandom_range(0, 100) < 70) jump_offset1 = $urandom_range(1, 127);
                                else jump_offset1 = -$urandom_range(1, 128);
                            end
                            
                            target1 = pc1 + jump_offset1;
                            if (target1 < 0) target1 = 0; if (target1 > 4095) target1 = 4095; 
                            inst1_word = {op1, target1[11:0], 1'b0}; 
                            
                        end else if (op1 == 2 || op1 == 3) begin
                            rs1 = $urandom_range(0, 1); 
                            rt1 = rs1; // 100% 累加自己
                            
                            // 🌟 超級防撞牆：如果嚴重偏離 target_center，拉回來
                            if ($signed(sim_r1[rs1]) < target_center - 100) imm1_ext = (op1 == 2) ? 63 : -64;
                            else if ($signed(sim_r1[rs1]) > target_center + 100) imm1_ext = (op1 == 2) ? -64 : 63;
                            else begin
                                if (sweep_up) imm1_ext = (op1 == 2) ? $urandom_range(20, 63) : -$urandom_range(20, 64);
                                else          imm1_ext = (op1 == 2) ? -$urandom_range(20, 64) : $urandom_range(20, 63);
                            end

                            if ($signed(sim_r1[rs1]) > 4000) imm1_ext = -30;
                            if ($signed(sim_r1[rs1]) < 100)  imm1_ext = 30;

                            inst1_word = {op1, rs1, rt1, imm1_ext[6:0]};
                        end else begin
                            if (op1 == 1) inst1_word = {op1, rs1, rt1, rd1, rl1, 1'b0}; else inst1_word = {op1, rs1, rt1, rd1, func1, 1'b0};
                        end
                    end
                end
                inst_1_dram[pc1*2] = inst1_word[7:0]; inst_1_dram[pc1*2+1] = inst1_word[15:8];
                valid_inst1[pc1] = 1;
            end else inst1_word = {inst_1_dram[pc1*2+1], inst_1_dram[pc1*2]}; 

            op1 = inst1_word[15:13]; rs1 = inst1_word[12:10]; rt1 = inst1_word[9:7]; 
            rd1 = inst1_word[6:4]; func1 = inst1_word[3:1]; rl1 = inst1_word[3:1]; 
            imm1_ext = {{9{inst1_word[6]}}, inst1_word[6:0]}; val_rs1 = sim_r1[rs1]; 
            if (op1 == 7) target1 = inst1_word[12:0];

            //---------------------------------------------------------------------
            //   JIT Generation for Core 2
            //---------------------------------------------------------------------
            if (!valid_inst2[pc2]) begin
                if (pc2 < 8) begin
                    if (pc2 == 0)      inst2_word = {3'b010, 3'd0, 3'd0, 7'd0}; 
                    else if (pc2 == 1) inst2_word = {3'b010, 3'd0, 3'd1, 7'd10}; 
                    else if (pc2 == 2) inst2_word = {3'b010, 3'd0, 3'd2, 7'd20}; 
                    else begin op2 = 3'b100; rs2 = 3'd0; rt2 = pc2[2:0]; imm2_ext = $urandom_range(0, 31); inst2_word = {op2, rs2, rt2, imm2_ext[6:0]}; end
                end else begin
                    // 🌟 戰鬥風格
                    if (op_profile == 1) begin 
                        if ($urandom_range(0, 100) < 55) op2 = $urandom_range(4, 5); else op2 = $urandom_range(0, 3);
                    end else if (op_profile == 2) begin 
                        if ($urandom_range(0, 100) < 65) op2 = $urandom_range(0, 3); else op2 = $urandom_range(4, 5);
                    end else if (op_profile == 3) begin 
                        if ($urandom_range(0, 100) < 30) op2 = $urandom_range(6, 7); else op2 = $urandom_range(0, 5);
                    end else begin
                        op2 = $urandom_range(0, 7);
                    end

                    if (op1 == 5 && op2 == 5) op2 = $urandom_range(0, 4); 
                    if (step % 50 <= 15 || step % 50 >= 35) if (op2 == 3'b101) op2 = 3'b100;
                    
                    rs2 = $urandom_range(0, 7); 
                    rd2 = $urandom_range(2, 7); 
                    rl2 = $urandom_range(2, 7); 
                    if (op2 == 4) rt2 = $urandom_range(2, 7);
                    else if (op2 == 5 || op2 == 6) rt2 = $urandom_range(0, 7);
                    else rt2 = $urandom_range(2, 7);
                    
                    func2 = $urandom_range(0, 7); 

                    if (pc2 == 4095) begin
                        op2 = 3'b111; target2 = 4095; inst2_word = {op2, target2[11:0], 1'b0}; 
                    end else begin
                        if (op2 == 4 || op2 == 5) begin
                            valid_rs_count = 0;
                            target_min = target_center - 100; if (target_min < 0) target_min = 0;
                            target_max = target_center + 100; if (target_max > 4095) target_max = 4095;

                            for (k = 0; k < 2; k = k + 1) begin
                                if (($signed(sim_r2[k]) + 63 >= target_min) && ($signed(sim_r2[k]) - 64 <= target_max)) begin
                                    valid_rs_list[valid_rs_count] = k; valid_rs_count = valid_rs_count + 1;
                                end
                            end
                            
                            if (valid_rs_count == 0) begin
                                op2 = 3'b010;
                                rs2 = $urandom_range(0, 1); rt2 = rs2; 
                                if ($signed(sim_r2[rs2]) < target_center) imm2_ext = 63;
                                else imm2_ext = -64;
                                inst2_word = {op2, rs2, rt2, imm2_ext[6:0]};
                            end else begin
                                rs2 = valid_rs_list[$unsigned($urandom) % valid_rs_count];
                                min_imm = target_min - $signed(sim_r2[rs2]); if (min_imm < -64) min_imm = -64;
                                max_imm = target_max - $signed(sim_r2[rs2]); if (max_imm > 63) max_imm = 63;
                                if (max_imm < min_imm) begin min_imm = 0; max_imm = 0; end
                                
                                temp_imm2 = min_imm + ($unsigned($urandom) % (max_imm - min_imm + 1));

                                inject_hazard = $urandom_range(0, 99);
                                if ((op1 == 4 || op1 == 5) && (op2 == 4 || op2 == 5)) begin
                                    if (inject_hazard > 50) begin
                                        for (k = 0; k < 2; k = k + 1) begin
                                            target_imm2 = target_center - $signed(sim_r2[k]);
                                            if (target_imm2 >= -64 && target_imm2 <= 63) begin
                                                rs2 = k; temp_imm2 = target_imm2; 
                                            end
                                        end
                                    end
                                end

                                inst2_word = {op2, rs2, rt2, temp_imm2[6:0]};
                            end
                            
                        end else if (op2 == 6) begin 
                            if ($urandom_range(0, 100) < 30) rt2 = rs2; 
                            
                            // 🌟 雙模式切換！
                            if (loop_mode == 0) begin
                                imm2_ext = $urandom_range(1, 63); 
                            end else begin
                                if ($urandom_range(0, 100) < 70) imm2_ext = $urandom_range(1, 63); 
                                else imm2_ext = -$urandom_range(1, 64);
                            end
                            
                            if (pc2 + 1 + imm2_ext < 0) imm2_ext = -1 - pc2; 
                            if (pc2 + 1 + imm2_ext > 4095) imm2_ext = 4095 - 1 - pc2; 
                            inst2_word = {op2, rs2, rt2, imm2_ext[6:0]};
                            
                        end else if (op2 == 7) begin 
                            // 🌟 雙模式切換！
                            if (loop_mode == 0) begin
                                jump_offset2 = $urandom_range(1, 127);
                            end else begin
                                if ($urandom_range(0, 100) < 70) jump_offset2 = $urandom_range(1, 127);
                                else jump_offset2 = -$urandom_range(1, 128);
                            end
                            
                            target2 = pc2 + jump_offset2; 
                            if (target2 < 0) target2 = 0; if (target2 > 4095) target2 = 4095;
                            inst2_word = {op2, target2[11:0], 1'b0};
                            
                        end else if (op2 == 2 || op2 == 3) begin
                            rs2 = $urandom_range(0, 1);
                            rt2 = rs2; 
                            
                            if ($signed(sim_r2[rs2]) < target_center - 100) imm2_ext = (op2 == 2) ? 63 : -64;
                            else if ($signed(sim_r2[rs2]) > target_center + 100) imm2_ext = (op2 == 2) ? -64 : 63;
                            else begin
                                if (sweep_up) imm2_ext = (op2 == 2) ? $urandom_range(20, 63) : -$urandom_range(20, 64);
                                else          imm2_ext = (op2 == 2) ? -$urandom_range(20, 64) : $urandom_range(20, 63);
                            end

                            if ($signed(sim_r2[rs2]) > 4000) imm2_ext = -30;
                            if ($signed(sim_r2[rs2]) < 100)  imm2_ext = 30;

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
            else begin rs1 = inst1_word[12:10]; rt1 = inst1_word[9:7]; imm1_ext = {{9{inst1_word[6]}}, inst1_word[6:0]}; rd1 = inst1_word[6:4]; func1 = inst1_word[3:1]; rl1 = inst1_word[3:1]; end
            val_rs1 = sim_r1[rs1]; val_rt1 = sim_r1[rt1];
            
            op2 = inst2_word[15:13]; 
            if (op2 == 7) target2 = inst2_word[12:0]; 
            else begin rs2 = inst2_word[12:10]; rt2 = inst2_word[9:7]; imm2_ext = {{9{inst2_word[6]}}, inst2_word[6:0]}; rd2 = inst2_word[6:4]; func2 = inst2_word[3:1]; rl2 = inst2_word[3:1]; end
            val_rs2 = sim_r2[rs2]; val_rt2 = sim_r2[rt2];

            next_pc1 = pc1 + 1; 
            next_pc2 = pc2 + 1;

            if (op1 == 4 || op1 == 5) addr1 = 4096 + ($signed(val_rs1) + imm1_ext) * 2; else addr1 = 0;
            if (op2 == 4 || op2 == 5) addr2 = 4096 + ($signed(val_rs2) + imm2_ext) * 2; else addr2 = 0;

            if (op1 == 5) begin 
                golden_dram[addr1] = sim_r1[rt1][7:0]; 
                golden_dram[addr1+1] = sim_r1[rt1][15:8];
                c1_store_valid[step] = 1'b1; 
                c1_store_addr[step] = addr1; 
                c1_store_data[step] = sim_r1[rt1];
                $display("\033[0;33m[Step = %4d] [Core 1] STORE | ADDR: %4d | DATA: %6d\033[m", step, addr1, $signed(sim_r1[rt1]));
            end
            if (op2 == 5) begin 
                golden_dram[addr2] = sim_r2[rt2][7:0]; 
                golden_dram[addr2+1] = sim_r2[rt2][15:8];
                c2_store_valid[step] = 1'b1; 
                c2_store_addr[step] = addr2; 
                c2_store_data[step] = sim_r2[rt2];
                $display("\033[0;35m[Step = %4d] [Core 2] STORE | ADDR: %4d | DATA: %6d\033[m", step, addr2, $signed(sim_r2[rt2]));
            end

            if (op1 == 4) begin
                sim_r1[rt1] = {golden_dram[addr1+1], golden_dram[addr1]};
                $display("\033[0;36m[Step = %4d] [Core 1] LOAD  | ADDR: %4d | DATA: %6d\033[m", step, addr1, $signed(sim_r1[rt1]));
            end
            if (op2 == 4) begin
                sim_r2[rt2] = {golden_dram[addr2+1], golden_dram[addr2]};
                $display("\033[0;32m[Step = %4d] [Core 2] LOAD  | ADDR: %4d | DATA: %6d\033[m", step, addr2, $signed(sim_r2[rt2]));
            end

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
            
            inst1_word = {inst_1_dram[i*2+1], inst_1_dram[i*2]};
            op1 = inst1_word[15:13]; rs1 = inst1_word[12:10]; rt1 = inst1_word[9:7]; rd1 = inst1_word[6:4];
            func1 = inst1_word[3:1]; rl1 = inst1_word[3:1]; imm1_ext = {{9{inst1_word[6]}}, inst1_word[6:0]}; target1 = inst1_word[12:0];
            
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
            func2 = inst2_word[3:1]; rl2 = inst2_word[3:1]; imm2_ext = {{9{inst2_word[6]}}, inst2_word[6:0]}; target2 = inst2_word[12:0];

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