

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
    `define CYCLE_TIME 3.7 
`elsif GATE
    `define CYCLE_TIME 3.7
`elsif CHIP
    `define CYCLE_TIME 20.0
`elsif POST
    `define CYCLE_TIME 20.0
`endif

`ifdef FUNC
    `define TIMEOUT_LIMIT 2000
`endif
`ifdef PERF
    `define TIMEOUT_LIMIT 100000
`endif

`define DUT TESTBED.u_DCCPU

module PATTERN(
    output reg clk, output reg rst_n, input wire stall_1, input wire stall_2,

    // [AXI-4] Instruction 1
    input wire [3:0] awid_s_inf_inst_1, input wire [31:0] awaddr_s_inf_inst_1, input wire [2:0] awsize_s_inf_inst_1, input wire [1:0] awburst_s_inf_inst_1, input wire [6:0] awlen_s_inf_inst_1, input wire awvalid_s_inf_inst_1, output wire awready_s_inf_inst_1, input wire [15:0] wdata_s_inf_inst_1, input wire wlast_s_inf_inst_1, input wire wvalid_s_inf_inst_1, output wire wready_s_inf_inst_1, output wire [3:0] bid_s_inf_inst_1, output wire [1:0] bresp_s_inf_inst_1, output wire bvalid_s_inf_inst_1, input wire bready_s_inf_inst_1, input wire [3:0] arid_s_inf_inst_1, input wire [31:0] araddr_s_inf_inst_1, input wire [6:0] arlen_s_inf_inst_1, input wire [2:0] arsize_s_inf_inst_1, input wire [1:0] arburst_s_inf_inst_1, input wire arvalid_s_inf_inst_1, output wire arready_s_inf_inst_1, output wire [3:0] rid_s_inf_inst_1, output wire [15:0] rdata_s_inf_inst_1, output wire [1:0] rresp_s_inf_inst_1, output wire rlast_s_inf_inst_1, output wire rvalid_s_inf_inst_1, input wire rready_s_inf_inst_1,

    // [AXI-4] Instruction 2
    input wire [3:0] awid_s_inf_inst_2, input wire [31:0] awaddr_s_inf_inst_2, input wire [2:0] awsize_s_inf_inst_2, input wire [1:0] awburst_s_inf_inst_2, input wire [6:0] awlen_s_inf_inst_2, input wire awvalid_s_inf_inst_2, output wire awready_s_inf_inst_2, input wire [15:0] wdata_s_inf_inst_2, input wire wlast_s_inf_inst_2, input wire wvalid_s_inf_inst_2, output wire wready_s_inf_inst_2, output wire [3:0] bid_s_inf_inst_2, output wire [1:0] bresp_s_inf_inst_2, output wire bvalid_s_inf_inst_2, input wire bready_s_inf_inst_2, input wire [3:0] arid_s_inf_inst_2, input wire [31:0] araddr_s_inf_inst_2, input wire [6:0] arlen_s_inf_inst_2, input wire [2:0] arsize_s_inf_inst_2, input wire [1:0] arburst_s_inf_inst_2, input wire arvalid_s_inf_inst_2, output wire arready_s_inf_inst_2, output wire [3:0] rid_s_inf_inst_2, output wire [15:0] rdata_s_inf_inst_2, output wire [1:0] rresp_s_inf_inst_2, output wire rlast_s_inf_inst_2, output wire rvalid_s_inf_inst_2, input wire rready_s_inf_inst_2,

    // [AXI-4] Data Memory
    input wire [3:0] awid_s_inf_data, input wire [31:0] awaddr_s_inf_data, input wire [2:0] awsize_s_inf_data, input wire [1:0] awburst_s_inf_data, input wire [6:0] awlen_s_inf_data, input wire awvalid_s_inf_data, output wire awready_s_inf_data, input wire [15:0] wdata_s_inf_data, input wire wlast_s_inf_data, input wire wvalid_s_inf_data, output wire wready_s_inf_data, output wire [3:0] bid_s_inf_data, output wire [1:0] bresp_s_inf_data, output wire bvalid_s_inf_data, input wire bready_s_inf_data, input wire [3:0] arid_s_inf_data, input wire [31:0] araddr_s_inf_data, input wire [6:0] arlen_s_inf_data, input wire [2:0] arsize_s_inf_data, input wire [1:0] arburst_s_inf_data, input wire arvalid_s_inf_data, output wire arready_s_inf_data, output wire [3:0] rid_s_inf_data, output wire [15:0] rdata_s_inf_data, output wire [1:0] rresp_s_inf_data, output wire rlast_s_inf_data, output wire rvalid_s_inf_data, input wire rready_s_inf_data
);

parameter NUM_ROUNDS = 10; 
integer round_idx;
integer global_total_cycles, global_total_inst;

integer iter;
integer rand_gen_seed; 
integer dynamic_total_ic; 

reg signed [15:0] expected_reg_c1 [0:4095][0:7];
reg signed [15:0] expected_reg_c2 [0:4095][0:7];

reg [15:0] history_instr_c1 [0:4095];
reg [15:0] history_instr_c2 [0:4095];
reg [15:0] history_pc_1 [0:4095];
reg [15:0] history_pc_2 [0:4095];

reg [15:0] sim_mem_i1 [0:4095];
reg [15:0] sim_mem_i2 [0:4095];
reg [15:0] sim_mem_dat [0:4095];
reg [15:0] final_dram_chk [0:4095];

reg [0:0] mem_written_1 [0:4095];
reg [0:0] mem_written_2 [0:4095];

reg signed [15:0] g_r1 [0:7];
reg signed [15:0] g_r2 [0:7];
reg [15:0] p1, p2, n_p1, n_p2;

integer inst_cnt_1, inst_cnt_2;
integer timeout_cnt_1, timeout_cnt_2;
integer total_sys_latency, mem_check_target;
integer pending_axi_writes, stall_flush_cnt;

integer lat_c1_ar, lat_c2_ar, lat_dat_ar, lat_dat_aw;
integer c1_axi_busy_cnt, c2_axi_busy_cnt, dat_axi_busy_cnt;
integer stall_1_cnt, stall_2_cnt;
reg c1_axi_is_busy, c2_axi_is_busy, dat_axi_ar_busy, dat_axi_aw_busy;

// DRAM Modules
pseudo_DRAM_inst1 #(4, 32, 16, 7) mem_block_i1 (.clk(clk), .rst_n(rst_n), .awid_s_inf(awid_s_inf_inst_1), .awaddr_s_inf(awaddr_s_inf_inst_1), .awsize_s_inf(awsize_s_inf_inst_1), .awburst_s_inf(awburst_s_inf_inst_1), .awlen_s_inf(awlen_s_inf_inst_1), .awvalid_s_inf(awvalid_s_inf_inst_1), .awready_s_inf(awready_s_inf_inst_1), .wdata_s_inf(wdata_s_inf_inst_1), .wlast_s_inf(wlast_s_inf_inst_1), .wvalid_s_inf(wvalid_s_inf_inst_1), .wready_s_inf(wready_s_inf_inst_1), .bid_s_inf(bid_s_inf_inst_1), .bresp_s_inf(bresp_s_inf_inst_1), .bvalid_s_inf(bvalid_s_inf_inst_1), .bready_s_inf(bready_s_inf_inst_1), .arid_s_inf(arid_s_inf_inst_1), .araddr_s_inf(araddr_s_inf_inst_1), .arlen_s_inf(arlen_s_inf_inst_1), .arsize_s_inf(arsize_s_inf_inst_1), .arburst_s_inf(arburst_s_inf_inst_1), .arvalid_s_inf(arvalid_s_inf_inst_1), .arready_s_inf(arready_s_inf_inst_1), .rid_s_inf(rid_s_inf_inst_1), .rdata_s_inf(rdata_s_inf_inst_1), .rresp_s_inf(rresp_s_inf_inst_1), .rlast_s_inf(rlast_s_inf_inst_1), .rvalid_s_inf(rvalid_s_inf_inst_1), .rready_s_inf(rready_s_inf_inst_1));
pseudo_DRAM_inst2 #(4, 32, 16, 7) mem_block_i2 (.clk(clk), .rst_n(rst_n), .awid_s_inf(awid_s_inf_inst_2), .awaddr_s_inf(awaddr_s_inf_inst_2), .awsize_s_inf(awsize_s_inf_inst_2), .awburst_s_inf(awburst_s_inf_inst_2), .awlen_s_inf(awlen_s_inf_inst_2), .awvalid_s_inf(awvalid_s_inf_inst_2), .awready_s_inf(awready_s_inf_inst_2), .wdata_s_inf(wdata_s_inf_inst_2), .wlast_s_inf(wlast_s_inf_inst_2), .wvalid_s_inf(wvalid_s_inf_inst_2), .wready_s_inf(wready_s_inf_inst_2), .bid_s_inf(bid_s_inf_inst_2), .bresp_s_inf(bresp_s_inf_inst_2), .bvalid_s_inf(bvalid_s_inf_inst_2), .bready_s_inf(bready_s_inf_inst_2), .arid_s_inf(arid_s_inf_inst_2), .araddr_s_inf(araddr_s_inf_inst_2), .arlen_s_inf(arlen_s_inf_inst_2), .arsize_s_inf(arsize_s_inf_inst_2), .arburst_s_inf(arburst_s_inf_inst_2), .arvalid_s_inf(arvalid_s_inf_inst_2), .arready_s_inf(arready_s_inf_inst_2), .rid_s_inf(rid_s_inf_inst_2), .rdata_s_inf(rdata_s_inf_inst_2), .rresp_s_inf(rresp_s_inf_inst_2), .rlast_s_inf(rlast_s_inf_inst_2), .rvalid_s_inf(rvalid_s_inf_inst_2), .rready_s_inf(rready_s_inf_inst_2));
pseudo_DRAM_data #(4, 32, 16, 7) mem_block_dat (.clk(clk), .rst_n(rst_n), .awid_s_inf(awid_s_inf_data), .awaddr_s_inf(awaddr_s_inf_data), .awsize_s_inf(awsize_s_inf_data), .awburst_s_inf(awburst_s_inf_data), .awlen_s_inf(awlen_s_inf_data), .awvalid_s_inf(awvalid_s_inf_data), .awready_s_inf(awready_s_inf_data), .wdata_s_inf(wdata_s_inf_data), .wlast_s_inf(wlast_s_inf_data), .wvalid_s_inf(wvalid_s_inf_data), .wready_s_inf(wready_s_inf_data), .bid_s_inf(bid_s_inf_data), .bresp_s_inf(bresp_s_inf_data), .bvalid_s_inf(bvalid_s_inf_data), .bready_s_inf(bready_s_inf_data), .arid_s_inf(arid_s_inf_data), .araddr_s_inf(araddr_s_inf_data), .arlen_s_inf(arlen_s_inf_data), .arsize_s_inf(arsize_s_inf_data), .arburst_s_inf(arburst_s_inf_data), .arvalid_s_inf(arvalid_s_inf_data), .arready_s_inf(arready_s_inf_data), .rid_s_inf(rid_s_inf_data), .rdata_s_inf(rdata_s_inf_data), .rresp_s_inf(rresp_s_inf_data), .rlast_s_inf(rlast_s_inf_data), .rvalid_s_inf(rvalid_s_inf_data), .rready_s_inf(rready_s_inf_data));

initial clk = 0;
always #(`CYCLE_TIME/2.0) clk = ~clk;

// AXI Timeout Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        lat_c1_ar <= 0; lat_c2_ar <= 0; lat_dat_ar <= 0; lat_dat_aw <= 0; pending_axi_writes <= 0; 
        c1_axi_busy_cnt <= 0; c2_axi_busy_cnt <= 0; dat_axi_busy_cnt <= 0;
        stall_1_cnt <= 0; stall_2_cnt <= 0;
        c1_axi_is_busy <= 0; c2_axi_is_busy <= 0; dat_axi_ar_busy <= 0; dat_axi_aw_busy <= 0;
    end else begin
        lat_c1_ar  <= (rvalid_s_inf_inst_1 && !rready_s_inf_inst_1) ? lat_c1_ar + 1 : 0;
        lat_c2_ar  <= (rvalid_s_inf_inst_2 && !rready_s_inf_inst_2) ? lat_c2_ar + 1 : 0;
        lat_dat_ar <= (rvalid_s_inf_data && !rready_s_inf_data) ? lat_dat_ar + 1 : 0;
        lat_dat_aw <= (bvalid_s_inf_data && !bready_s_inf_data) ? lat_dat_aw + 1 : 0;
        if (awvalid_s_inf_data && awready_s_inf_data) pending_axi_writes <= pending_axi_writes + 1;
        if (bvalid_s_inf_data && bready_s_inf_data)   pending_axi_writes <= pending_axi_writes - 1;
        if (lat_c1_ar > 300 || lat_c2_ar > 300 || lat_dat_ar > 300 || lat_dat_aw > 300) begin
            $display("\n[FAIL] SPEC 20 VIOLATION: AXI LATENCY > 300"); $finish;
        end

        if (stall_1) stall_1_cnt <= stall_1_cnt + 1;
        if (stall_2) stall_2_cnt <= stall_2_cnt + 1;

        if (arvalid_s_inf_inst_1 && !arready_s_inf_inst_1) c1_axi_is_busy <= 1;
        else if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1 && !rlast_s_inf_inst_1) c1_axi_is_busy <= 1;
        else if (rlast_s_inf_inst_1 && rready_s_inf_inst_1) c1_axi_is_busy <= 0;
        if (c1_axi_is_busy || arvalid_s_inf_inst_1 || rvalid_s_inf_inst_1) c1_axi_busy_cnt <= c1_axi_busy_cnt + 1;

        if (arvalid_s_inf_inst_2 && !arready_s_inf_inst_2) c2_axi_is_busy <= 1;
        else if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2 && !rlast_s_inf_inst_2) c2_axi_is_busy <= 1;
        else if (rlast_s_inf_inst_2 && rready_s_inf_inst_2) c2_axi_is_busy <= 0;
        if (c2_axi_is_busy || arvalid_s_inf_inst_2 || rvalid_s_inf_inst_2) c2_axi_busy_cnt <= c2_axi_busy_cnt + 1;

        if (arvalid_s_inf_data && !arready_s_inf_data) dat_axi_ar_busy <= 1;
        else if (arvalid_s_inf_data && arready_s_inf_data && !rlast_s_inf_data) dat_axi_ar_busy <= 1;
        else if (rlast_s_inf_data && rready_s_inf_data) dat_axi_ar_busy <= 0;

        if (awvalid_s_inf_data && !awready_s_inf_data) dat_axi_aw_busy <= 1;
        else if (awvalid_s_inf_data && awready_s_inf_data && !bvalid_s_inf_data) dat_axi_aw_busy <= 1;
        else if (bvalid_s_inf_data && bready_s_inf_data) dat_axi_aw_busy <= 0;

        if (dat_axi_ar_busy || arvalid_s_inf_data || rvalid_s_inf_data ||
            dat_axi_aw_busy || awvalid_s_inf_data || wvalid_s_inf_data || bvalid_s_inf_data) 
            dat_axi_busy_cnt <= dat_axi_busy_cnt + 1;
    end
end

initial begin
    global_total_cycles = 0; global_total_inst = 0;

    $display("\n========================================================");
    $display("   [PATTERN ENGINE] V17.0 Cool-Down Edition");
    $display("   [PATTERN ENGINE] Total Rounds to execute: %0d", NUM_ROUNDS);
    $display("========================================================\n");

    for (round_idx = 0; round_idx < NUM_ROUNDS; round_idx = round_idx + 1) begin
        rand_gen_seed = 888 + (round_idx * 1337); 
        init_and_reset_dut();
        
        $display(">>>>> [ROUND %0d / %0d] Building Dynamic JIT Path (Seed: %0d)...", round_idx + 1, NUM_ROUNDS, rand_gen_seed);
        build_jit_custom_path();
        if (round_idx == 0) export_dram_files(); 
        
        inst_cnt_1 = 0; inst_cnt_2 = 0; total_sys_latency = 0; mem_check_target = 49;
        exec_and_verify_engine(round_idx + 1);
        
        global_total_cycles = global_total_cycles + total_sys_latency;
        global_total_inst   = global_total_inst + dynamic_total_ic;
        $display(">>>>> [ROUND %0d / %0d] PASSED! (Target IC: %0d | Cycles: %0d | CPI: %.3f)", 
            round_idx + 1, NUM_ROUNDS, dynamic_total_ic, total_sys_latency, $itor(total_sys_latency)/$itor(dynamic_total_ic));
            
        $display(">>>>> [ROUND %0d / %0d] Initiating AXI Cool-down sequence...\n", round_idx + 1, NUM_ROUNDS);
        wait_axi_idle_and_cooldown();
    end
    
    $display("\n========================================================");
    $display("             🎊 ALL %0d ROUNDS PASSED SUCCESSFULLY! 🎊         ", NUM_ROUNDS);
    $display("--------------------------------------------------------");
    $display("   GLOBAL Performance Profiler:");
    $display("   * Total Cycles Executed : %0d cycles", global_total_cycles);
    $display("   * Total Instructions    : %0d insts", global_total_inst);
    $display("   * GLOBAL Average CPI    : %.3f", $itor(global_total_cycles) / $itor(global_total_inst));
    $display("========================================================\n");
    $finish;
end

task init_and_reset_dut; begin
    rst_n = 1'b1; 
    @(negedge clk); 
    #(0.1 * `CYCLE_TIME) rst_n = 1'b0; 
    #(2.2 * `CYCLE_TIME) rst_n = 1'b1;
    @(negedge clk);
    if (stall_1 !== 1'b1 || stall_2 !== 1'b1) begin
        $display("[FAIL] SPEC 4 VIOLATION: STALL SHOULD BE HIGH AFTER RESET"); $finish;
    end
end endtask

task wait_axi_idle_and_cooldown; 
    integer silence_cnt;
begin
    silence_cnt = 0;
    while (silence_cnt < 50) begin
        @(negedge clk);
        if (arvalid_s_inf_inst_1 || awvalid_s_inf_inst_1 || wvalid_s_inf_inst_1 || rvalid_s_inf_inst_1 || bvalid_s_inf_inst_1 ||
            arvalid_s_inf_inst_2 || awvalid_s_inf_inst_2 || wvalid_s_inf_inst_2 || rvalid_s_inf_inst_2 || bvalid_s_inf_inst_2 ||
            arvalid_s_inf_data || awvalid_s_inf_data || wvalid_s_inf_data || rvalid_s_inf_data || bvalid_s_inf_data ||
            pending_axi_writes > 0) begin
            silence_cnt = 0; 
        end else begin
            silence_cnt = silence_cnt + 1;
        end
    end
    repeat(100) @(negedge clk);
end endtask

// =========================================================================
//  核心：即時動態鋪路器 (JIT Compiler / Dynamic Emulator)
// =========================================================================
task build_jit_custom_path; 
    reg [2:0] op1, fn1, s1, t1, d1, l1; reg [2:0] op2, fn2, s2, t2, d2, l2;
    reg signed [6:0] imm1, imm2; reg [12:0] jaddr1, jaddr2;
    reg signed [31:0] addr1, addr2, mul1, mul2;
    reg [15:0] inst1, inst2; integer op_rand, k, q;
begin
    for (iter = 0; iter < 4096; iter = iter + 1) begin
        sim_mem_i1[iter] = 16'h0000; sim_mem_i2[iter] = 16'h0000;
        mem_written_1[iter] = 0; mem_written_2[iter] = 0;
        sim_mem_dat[iter] = $unsigned($random(rand_gen_seed)) % 65536; final_dram_chk[iter] = sim_mem_dat[iter];
    end
    for (q = 0; q < 8; q = q + 1) begin g_r1[q] = 0; g_r2[q] = 0; end
    p1 = 0; p2 = 0;

    for (k = 0; k < 2600; k = k + 1) begin
        if (p1 == 8190 && p2 == 8190) begin
            inst1 = 16'h0490; inst2 = 16'h0920; 
            sim_mem_i1[4095] = inst1; sim_mem_i2[4095] = inst2; 
            history_instr_c1[k] = inst1; history_instr_c2[k] = inst2;
            history_pc_1[k] = p1; history_pc_2[k] = p2;
            g_r1[1] = g_r1[1] + g_r1[1]; g_r2[2] = g_r2[2] + g_r2[2];
            for (q=0; q<8; q=q+1) begin expected_reg_c1[k][q] = g_r1[q]; expected_reg_c2[k][q] = g_r2[q]; end
            dynamic_total_ic = k + 1;
            break; 
        end
        else if (p1 >= 8180 || p2 >= 8180 || k == 2498) begin
            inst1 = 16'hFFFE; inst2 = 16'hFFFE; 
            sim_mem_i1[p1>>1] = inst1; mem_written_1[p1>>1] = 1;
            sim_mem_i2[p2>>1] = inst2; mem_written_2[p2>>1] = 1;
        end
        else begin
            if (mem_written_1[p1>>1] == 0) begin
                if      (p1 == 0)  inst1 = {3'b000, 3'd1, 3'd1, 3'd1, 3'd6, 1'b0}; 
                else if (p1 == 2)  inst1 = {3'b000, 3'd2, 3'd2, 3'd2, 3'd6, 1'b0}; 
                else if (p1 == 4)  inst1 = {3'b010, 3'd2, 3'd2, 7'd3};             
                else if (p1 == 6)  inst1 = {3'b010, 3'd1, 3'd1, 7'd1};             
                else if (p1 == 8)  inst1 = {3'b110, 3'd1, 3'd2, 7'd1};             
                else if (p1 == 10) inst1 = {3'b111, 13'd6};                        
                else if (p1 == 12) inst1 = {3'b000, 3'd1, 3'd2, 3'd3, 3'd0, 1'b0}; 
                else if (p1 == 14) inst1 = {3'b111, 13'd18};                       
                else if (p1 == 16) inst1 = {3'b101, 3'd1, 3'd1, 7'd0};             
                else if (p1 == 18) inst1 = {3'b000, 3'd1, 3'd1, 3'd1, 3'd0, 1'b0}; 
                else begin
                    op_rand = $unsigned($random(rand_gen_seed)) % 100;
                    if      (op_rand < 15) op1 = 0; else if (op_rand < 30) op1 = 1; else if (op_rand < 45) op1 = 2;
                    else if (op_rand < 60) op1 = 3; else if (op_rand < 75) op1 = 4; else if (op_rand < 90) op1 = 5;
                    else if (op_rand < 95) op1 = 6; else op1 = 7;
                    s1 = $unsigned($random(rand_gen_seed)) % 8; t1 = $unsigned($random(rand_gen_seed)) % 8;
                    d1 = 1 + ($unsigned($random(rand_gen_seed)) % 7); l1 = 1 + ($unsigned($random(rand_gen_seed)) % 7);
                    fn1 = $unsigned($random(rand_gen_seed)) % 8; imm1 = -64 + ($unsigned($random(rand_gen_seed)) % 128);

                    if (t1 == 0 && (op1 == 2 || op1 == 3 || op1 == 4)) t1 = 1;
                    if (op1 == 4 || op1 == 5) begin addr1 = g_r1[s1] + imm1; if (addr1 < 0 || addr1 > 4095) op1 = 0; end 
                    else if (op1 == 6) begin imm1 = 1 + ($unsigned($random(rand_gen_seed)) % 5); if (p1 + 2 + imm1*2 > 8180) op1 = 0; end 
                    else if (op1 == 7) begin jaddr1 = p1 + 2 + ($unsigned($random(rand_gen_seed)) % 5)*2; if (jaddr1 > 8180) op1 = 0; end
                    case(op1)
                        0: inst1 = {3'b000, s1, t1, d1, fn1, 1'b0}; 1: inst1 = {3'b001, s1, t1, d1, l1, 1'b0};
                        2,3,4,5: inst1 = {op1, s1, t1, imm1[6:0]}; 6: inst1 = {3'b110, s1, t1, imm1[6:0]}; 7: inst1 = {3'b111, jaddr1[12:0]};
                    endcase
                end
                sim_mem_i1[p1>>1] = inst1; mem_written_1[p1>>1] = 1;
            end else inst1 = sim_mem_i1[p1>>1];

            if (mem_written_2[p2>>1] == 0) begin
                if      (p2 == 0)  inst2 = {3'b000, 3'd4, 3'd4, 3'd4, 3'd6, 1'b0}; 
                else if (p2 == 2)  inst2 = {3'b000, 3'd5, 3'd5, 3'd5, 3'd6, 1'b0}; 
                else if (p2 == 4)  inst2 = {3'b010, 3'd5, 3'd5, 7'd4};             
                else if (p2 == 6)  inst2 = {3'b010, 3'd4, 3'd4, 7'd1};             
                else if (p2 == 8)  inst2 = {3'b110, 3'd4, 3'd5, 7'd1};             
                else if (p2 == 10) inst2 = {3'b111, 13'd6};                        
                else if (p2 == 12) inst2 = {3'b000, 3'd4, 3'd5, 3'd6, 3'd0, 1'b0}; 
                else if (p2 == 14) inst2 = {3'b111, 13'd18};                       
                else if (p2 == 16) inst2 = {3'b101, 3'd4, 3'd4, 7'd0};             
                else if (p2 == 18) inst2 = {3'b000, 3'd4, 3'd4, 3'd4, 3'd0, 1'b0}; 
                else begin
                    op_rand = $unsigned($random(rand_gen_seed)) % 100;
                    if      (op_rand < 15) op2 = 0; else if (op_rand < 30) op2 = 1; else if (op_rand < 45) op2 = 2;
                    else if (op_rand < 60) op2 = 3; else if (op_rand < 75) op2 = 4; else if (op_rand < 90) op2 = 5;
                    else if (op_rand < 95) op2 = 6; else op2 = 7;
                    s2 = $unsigned($random(rand_gen_seed)) % 8; t2 = $unsigned($random(rand_gen_seed)) % 8;
                    d2 = 1 + ($unsigned($random(rand_gen_seed)) % 7); l2 = 1 + ($unsigned($random(rand_gen_seed)) % 7);
                    fn2 = $unsigned($random(rand_gen_seed)) % 8; imm2 = -64 + ($unsigned($random(rand_gen_seed)) % 128);

                    if (t2 == 0 && (op2 == 2 || op2 == 3 || op2 == 4)) t2 = 1;
                    if (op2 == 4 || op2 == 5) begin addr2 = g_r2[s2] + imm2; if (addr2 < 0 || addr2 > 4095) op2 = 0; end 
                    else if (op2 == 6) begin imm2 = 1 + ($unsigned($random(rand_gen_seed)) % 5); if (p2 + 2 + imm2*2 > 8180) op2 = 0; end 
                    else if (op2 == 7) begin jaddr2 = p2 + 2 + ($unsigned($random(rand_gen_seed)) % 5)*2; if (jaddr2 > 8180) op2 = 0; end
                    case(op2)
                        0: inst2 = {3'b000, s2, t2, d2, fn2, 1'b0}; 1: inst2 = {3'b001, s2, t2, d2, l2, 1'b0};
                        2,3,4,5: inst2 = {op2, s2, t2, imm2[6:0]}; 6: inst2 = {3'b110, s2, t2, imm2[6:0]}; 7: inst2 = {3'b111, jaddr2[12:0]};
                    endcase
                end
                if (inst1[15:13] == 5 && inst2[15:13] == 5) inst2[15:13] = 4;
                sim_mem_i2[p2>>1] = inst2; mem_written_2[p2>>1] = 1;
            end else inst2 = sim_mem_i2[p2>>1];
        end

        history_instr_c1[k] = inst1; history_instr_c2[k] = inst2;
        history_pc_1[k] = p1; history_pc_2[k] = p2;

        op1 = inst1[15:13]; s1 = inst1[12:10]; t1 = inst1[9:7]; d1 = inst1[6:4]; l1 = inst1[3:1]; fn1 = inst1[3:1]; imm1 = $signed({{9{inst1[6]}}, inst1[6:0]});
        op2 = inst2[15:13]; s2 = inst2[12:10]; t2 = inst2[9:7]; d2 = inst2[6:4]; l2 = inst2[3:1]; fn2 = inst2[3:1]; imm2 = $signed({{9{inst2[6]}}, inst2[6:0]}); 

        if (op1 == 5) final_dram_chk[g_r1[s1] + imm1] = g_r1[t1];
        if (op2 == 5) final_dram_chk[g_r2[s2] + imm2] = g_r2[t2];

        if (op1 != 5 && op1 != 6 && op1 != 7) begin
            if (op1 == 0) begin
                if (fn1 == 0) g_r1[d1] = g_r1[s1] + g_r1[t1]; else if (fn1 == 1) g_r1[d1] = g_r1[s1] - g_r1[t1];
                else if (fn1 == 2) g_r1[d1] = g_r1[s1] & g_r1[t1]; else if (fn1 == 3) g_r1[d1] = g_r1[s1] | g_r1[t1];
                else if (fn1 == 4) g_r1[d1] = ~(g_r1[s1] & g_r1[t1]); else if (fn1 == 5) g_r1[d1] = ~(g_r1[s1] | g_r1[t1]);
                else if (fn1 == 6) g_r1[d1] = g_r1[s1] ^ g_r1[t1]; else if (fn1 == 7) g_r1[d1] = ($signed(g_r1[s1]) < $signed(g_r1[t1])) ? 1 : 0;
            end
            else if (op1 == 1) begin mul1 = $signed(g_r1[s1]) * $signed(g_r1[t1]); g_r1[d1] = mul1[31:16]; g_r1[l1] = mul1[15:0]; end
            else if (op1 == 2) g_r1[t1] = g_r1[s1] + imm1; else if (op1 == 3) g_r1[t1] = g_r1[s1] - imm1;
            else if (op1 == 4) g_r1[t1] = final_dram_chk[g_r1[s1] + imm1];
        end
        n_p1 = (op1 == 6) ? ((g_r1[s1] == g_r1[t1]) ? (p1 + 2 + (imm1 * 2)) : (p1 + 2)) : ((op1 == 7) ? inst1[12:0] : (p1 + 2));

        if (op2 != 5 && op2 != 6 && op2 != 7) begin
            if (op2 == 0) begin
                if (fn2 == 0) g_r2[d2] = g_r2[s2] + g_r2[t2]; else if (fn2 == 1) g_r2[d2] = g_r2[s2] - g_r2[t2];
                else if (fn2 == 2) g_r2[d2] = g_r2[s2] & g_r2[t2]; else if (fn2 == 3) g_r2[d2] = g_r2[s2] | g_r2[t2];
                else if (fn2 == 4) g_r2[d2] = ~(g_r2[s2] & g_r2[t2]); else if (fn2 == 5) g_r2[d2] = ~(g_r2[s2] | g_r2[t2]);
                else if (fn2 == 6) g_r2[d2] = g_r2[s2] ^ g_r2[t2]; else if (fn2 == 7) g_r2[d2] = ($signed(g_r2[s2]) < $signed(g_r2[t2])) ? 1 : 0;
            end
            else if (op2 == 1) begin mul2 = $signed(g_r2[s2]) * $signed(g_r2[t2]); g_r2[d2] = mul2[31:16]; g_r2[l2] = mul2[15:0]; end
            else if (op2 == 2) g_r2[t2] = g_r2[s2] + imm2; else if (op2 == 3) g_r2[t2] = g_r2[s2] - imm2;
            else if (op2 == 4) g_r2[t2] = final_dram_chk[g_r2[s2] + imm2];
        end
        n_p2 = (op2 == 6) ? ((g_r2[s2] == g_r2[t2]) ? (p2 + 2 + (imm2 * 2)) : (p2 + 2)) : ((op2 == 7) ? inst2[12:0] : (p2 + 2));

        for (q=0; q<8; q=q+1) begin expected_reg_c1[k][q] = g_r1[q]; expected_reg_c2[k][q] = g_r2[q]; end
        p1 = n_p1; p2 = n_p2;
    end

    for (iter=0; iter<4096; iter=iter+1) begin
        mem_block_i1.DRAM_r[iter*2]   = sim_mem_i1[iter][7:0]; mem_block_i1.DRAM_r[iter*2+1] = sim_mem_i1[iter][15:8];
        mem_block_i2.DRAM_r[iter*2]   = sim_mem_i2[iter][7:0]; mem_block_i2.DRAM_r[iter*2+1] = sim_mem_i2[iter][15:8];
        mem_block_dat.DRAM_r[4096 + iter*2]   = sim_mem_dat[iter][7:0]; mem_block_dat.DRAM_r[4096 + iter*2+1] = sim_mem_dat[iter][15:8];
    end
end endtask

task export_dram_files; begin
    integer f1, f2, fd;
    f1 = $fopen("../00_TESTBED/DRAM/inst_1_dram_file.dat", "w"); $fdisplay(f1, "@0000");
    f2 = $fopen("../00_TESTBED/DRAM/inst_2_dram_file.dat", "w"); $fdisplay(f2, "@0000");
    fd = $fopen("../00_TESTBED/DRAM/data_dram_file.dat", "w"); $fdisplay(fd, "@1000");
    for (iter = 0; iter < 4096; iter = iter + 1) begin
        $fdisplay(f1, "%02X %02X", sim_mem_i1[iter][7:0], sim_mem_i1[iter][15:8]);
        $fdisplay(f2, "%02X %02X", sim_mem_i2[iter][7:0], sim_mem_i2[iter][15:8]);
        $fdisplay(fd, "%02X %02X", sim_mem_dat[iter][7:0], sim_mem_dat[iter][15:8]);
    end
    $fclose(f1); $fclose(f2); $fclose(fd);
end endtask

task exec_and_verify_engine; 
    input integer curr_round;
begin
    timeout_cnt_1 = 0; timeout_cnt_2 = 0;
    
    while ((inst_cnt_1 != dynamic_total_ic) || (inst_cnt_2 != dynamic_total_ic)) begin
        @(negedge clk);
        
        if (inst_cnt_1 != dynamic_total_ic) begin
            if (~stall_1) begin 
                eval_c1_regs(curr_round); 
                if (history_instr_c1[inst_cnt_1][15:13] == 3'b110) begin
                    if (history_pc_1[inst_cnt_1 + 1] != history_pc_1[inst_cnt_1] + 2)
                        $display("  [C1 R%0d] BEQ  at PC: 0x%04x (IC: %0d) -> TAKEN     (Jump to: 0x%04x)", curr_round, history_pc_1[inst_cnt_1], inst_cnt_1, history_pc_1[inst_cnt_1+1]);
                    else
                        $display("  [C1 R%0d] BEQ  at PC: 0x%04x (IC: %0d) -> NOT TAKEN (Next: 0x%04x)", curr_round, history_pc_1[inst_cnt_1], inst_cnt_1, history_pc_1[inst_cnt_1+1]);
                end else if (history_instr_c1[inst_cnt_1][15:13] == 3'b111) begin
                    $display("  [C1 R%0d] JUMP at PC: 0x%04x (IC: %0d) -> JUMPED    (Jump to: 0x%04x)", curr_round, history_pc_1[inst_cnt_1], inst_cnt_1, history_pc_1[inst_cnt_1+1]);
                end
                timeout_cnt_1 = 0; inst_cnt_1 = inst_cnt_1 + 1; 
            end else timeout_cnt_1 = timeout_cnt_1 + 1;
        end
        
        if (inst_cnt_2 != dynamic_total_ic) begin
            if (~stall_2) begin 
                eval_c2_regs(curr_round); 
                if (history_instr_c2[inst_cnt_2][15:13] == 3'b110) begin
                    if (history_pc_2[inst_cnt_2 + 1] != history_pc_2[inst_cnt_2] + 2)
                        $display("  [C2 R%0d] BEQ  at PC: 0x%04x (IC: %0d) -> TAKEN     (Jump to: 0x%04x)", curr_round, history_pc_2[inst_cnt_2], inst_cnt_2, history_pc_2[inst_cnt_2+1]);
                    else
                        $display("  [C2 R%0d] BEQ  at PC: 0x%04x (IC: %0d) -> NOT TAKEN (Next: 0x%04x)", curr_round, history_pc_2[inst_cnt_2], inst_cnt_2, history_pc_2[inst_cnt_2+1]);
                end else if (history_instr_c2[inst_cnt_2][15:13] == 3'b111) begin
                    $display("  [C2 R%0d] JUMP at PC: 0x%04x (IC: %0d) -> JUMPED    (Jump to: 0x%04x)", curr_round, history_pc_2[inst_cnt_2], inst_cnt_2, history_pc_2[inst_cnt_2+1]);
                end
                timeout_cnt_2 = 0; inst_cnt_2 = inst_cnt_2 + 1; 
                if ((inst_cnt_2 - inst_cnt_1) > 1) begin
                    $display("\n************************************************************");
                    $display("* [FATAL R%0d] SYNCHRONIZATION FAULT: C2 advanced beyond C1 limit", curr_round);
                    $display("************************************************************\n");
                    $display(">>> CORE 1 Trace:"); dump_inst_trace(1, inst_cnt_1);
                    $display("\n>>> CORE 2 Trace:"); dump_inst_trace(2, inst_cnt_2);
                    $finish;
                end
            end else timeout_cnt_2 = timeout_cnt_2 + 1;
        end

        if ((inst_cnt_1 >= mem_check_target) && (inst_cnt_2 >= mem_check_target)) mem_check_target = mem_check_target + 50;

        if (timeout_cnt_1 > `TIMEOUT_LIMIT || timeout_cnt_2 > `TIMEOUT_LIMIT) begin
            $display("\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("! [TIMEOUT R%0d] Execution halted: Stall signal locked high !", curr_round);
            $display("! Progress  : Core1 = %0d/%0d, Core2 = %0d/%0d", inst_cnt_1, dynamic_total_ic, inst_cnt_2, dynamic_total_ic);
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
            $display(">>> CORE 1 Trace:"); dump_inst_trace(1, inst_cnt_1);
            $display("\n>>> CORE 2 Trace:"); dump_inst_trace(2, inst_cnt_2);
            $finish;
        end
        total_sys_latency = total_sys_latency + 1;
    end
    
    @(negedge clk);
    if (stall_1 !== 1'b1 || stall_2 !== 1'b1) begin
        $display("\n========================================================");
        $display("   [FAIL R%0d] STALL SIGNAL NOT ASSERTED AFTER COMPLETION!", curr_round);
        $display("   CPU must pull stall_1 and stall_2 HIGH immediately");
        $display("   after finishing the final instruction at 0x1FFE.");
        $display("========================================================\n");
        $display(">>> CORE 1 Trace:"); dump_inst_trace(1, inst_cnt_1);
        $display("\n>>> CORE 2 Trace:"); dump_inst_trace(2, inst_cnt_2);
        $finish;
    end
end endtask

task eval_c1_regs; 
    input integer curr_round;
begin
    if (`DUT.core_1_r0 !== expected_reg_c1[inst_cnt_1][0] || `DUT.core_1_r1 !== expected_reg_c1[inst_cnt_1][1] ||
        `DUT.core_1_r2 !== expected_reg_c1[inst_cnt_1][2] || `DUT.core_1_r3 !== expected_reg_c1[inst_cnt_1][3] ||
        `DUT.core_1_r4 !== expected_reg_c1[inst_cnt_1][4] || `DUT.core_1_r5 !== expected_reg_c1[inst_cnt_1][5] ||
        `DUT.core_1_r6 !== expected_reg_c1[inst_cnt_1][6] || `DUT.core_1_r7 !== expected_reg_c1[inst_cnt_1][7]) begin
        $display("\n========================================================");
        $display("               [FAIL R%0d] CORE 1 REGISTER MISMATCH!            ", curr_round);
        $display("========================================================");
        $display(" PATTERN IDX : %0d", inst_cnt_1);
        $display(" --------------------------------------------------------");
        $display(" Reg |   Expected (Golden)   |       Actual (DUT)    | Status ");
        $display(" --------------------------------------------------------");
        $display("  r0 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][0], expected_reg_c1[inst_cnt_1][0][15:0], $signed(`DUT.core_1_r0), `DUT.core_1_r0, (expected_reg_c1[inst_cnt_1][0] !== `DUT.core_1_r0) ? "<-- ERROR" : "  OK");
        $display("  r1 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][1], expected_reg_c1[inst_cnt_1][1][15:0], $signed(`DUT.core_1_r1), `DUT.core_1_r1, (expected_reg_c1[inst_cnt_1][1] !== `DUT.core_1_r1) ? "<-- ERROR" : "  OK");
        $display("  r2 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][2], expected_reg_c1[inst_cnt_1][2][15:0], $signed(`DUT.core_1_r2), `DUT.core_1_r2, (expected_reg_c1[inst_cnt_1][2] !== `DUT.core_1_r2) ? "<-- ERROR" : "  OK");
        $display("  r3 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][3], expected_reg_c1[inst_cnt_1][3][15:0], $signed(`DUT.core_1_r3), `DUT.core_1_r3, (expected_reg_c1[inst_cnt_1][3] !== `DUT.core_1_r3) ? "<-- ERROR" : "  OK");
        $display("  r4 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][4], expected_reg_c1[inst_cnt_1][4][15:0], $signed(`DUT.core_1_r4), `DUT.core_1_r4, (expected_reg_c1[inst_cnt_1][4] !== `DUT.core_1_r4) ? "<-- ERROR" : "  OK");
        $display("  r5 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][5], expected_reg_c1[inst_cnt_1][5][15:0], $signed(`DUT.core_1_r5), `DUT.core_1_r5, (expected_reg_c1[inst_cnt_1][5] !== `DUT.core_1_r5) ? "<-- ERROR" : "  OK");
        $display("  r6 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][6], expected_reg_c1[inst_cnt_1][6][15:0], $signed(`DUT.core_1_r6), `DUT.core_1_r6, (expected_reg_c1[inst_cnt_1][6] !== `DUT.core_1_r6) ? "<-- ERROR" : "  OK");
        $display("  r7 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c1[inst_cnt_1][7], expected_reg_c1[inst_cnt_1][7][15:0], $signed(`DUT.core_1_r7), `DUT.core_1_r7, (expected_reg_c1[inst_cnt_1][7] !== `DUT.core_1_r7) ? "<-- ERROR" : "  OK");
        $display("========================================================\n");
        dump_inst_trace(1, inst_cnt_1); $finish;
    end
end endtask

task eval_c2_regs; 
    input integer curr_round;
begin
    if (`DUT.core_2_r0 !== expected_reg_c2[inst_cnt_2][0] || `DUT.core_2_r1 !== expected_reg_c2[inst_cnt_2][1] ||
        `DUT.core_2_r2 !== expected_reg_c2[inst_cnt_2][2] || `DUT.core_2_r3 !== expected_reg_c2[inst_cnt_2][3] ||
        `DUT.core_2_r4 !== expected_reg_c2[inst_cnt_2][4] || `DUT.core_2_r5 !== expected_reg_c2[inst_cnt_2][5] ||
        `DUT.core_2_r6 !== expected_reg_c2[inst_cnt_2][6] || `DUT.core_2_r7 !== expected_reg_c2[inst_cnt_2][7]) begin
        $display("\n========================================================");
        $display("               [FAIL R%0d] CORE 2 REGISTER MISMATCH!            ", curr_round);
        $display("========================================================");
        $display(" PATTERN IDX : %0d", inst_cnt_2);
        $display(" --------------------------------------------------------");
        $display(" Reg |   Expected (Golden)   |       Actual (DUT)    | Status ");
        $display(" --------------------------------------------------------");
        $display("  r0 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][0], expected_reg_c2[inst_cnt_2][0][15:0], $signed(`DUT.core_2_r0), `DUT.core_2_r0, (expected_reg_c2[inst_cnt_2][0] !== `DUT.core_2_r0) ? "<-- ERROR" : "  OK");
        $display("  r1 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][1], expected_reg_c2[inst_cnt_2][1][15:0], $signed(`DUT.core_2_r1), `DUT.core_2_r1, (expected_reg_c2[inst_cnt_2][1] !== `DUT.core_2_r1) ? "<-- ERROR" : "  OK");
        $display("  r2 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][2], expected_reg_c2[inst_cnt_2][2][15:0], $signed(`DUT.core_2_r2), `DUT.core_2_r2, (expected_reg_c2[inst_cnt_2][2] !== `DUT.core_2_r2) ? "<-- ERROR" : "  OK");
        $display("  r3 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][3], expected_reg_c2[inst_cnt_2][3][15:0], $signed(`DUT.core_2_r3), `DUT.core_2_r3, (expected_reg_c2[inst_cnt_2][3] !== `DUT.core_2_r3) ? "<-- ERROR" : "  OK");
        $display("  r4 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][4], expected_reg_c2[inst_cnt_2][4][15:0], $signed(`DUT.core_2_r4), `DUT.core_2_r4, (expected_reg_c2[inst_cnt_2][4] !== `DUT.core_2_r4) ? "<-- ERROR" : "  OK");
        $display("  r5 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][5], expected_reg_c2[inst_cnt_2][5][15:0], $signed(`DUT.core_2_r5), `DUT.core_2_r5, (expected_reg_c2[inst_cnt_2][5] !== `DUT.core_2_r5) ? "<-- ERROR" : "  OK");
        $display("  r6 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][6], expected_reg_c2[inst_cnt_2][6][15:0], $signed(`DUT.core_2_r6), `DUT.core_2_r6, (expected_reg_c2[inst_cnt_2][6] !== `DUT.core_2_r6) ? "<-- ERROR" : "  OK");
        $display("  r7 | %8d (0x%04X) | %8d (0x%04X) | %s", expected_reg_c2[inst_cnt_2][7], expected_reg_c2[inst_cnt_2][7][15:0], $signed(`DUT.core_2_r7), `DUT.core_2_r7, (expected_reg_c2[inst_cnt_2][7] !== `DUT.core_2_r7) ? "<-- ERROR" : "  OK");
        $display("========================================================\n");
        dump_inst_trace(2, inst_cnt_2); $finish;
    end
end endtask

task verify_final_mem_state; 
    input integer curr_round;
    reg [15:0] hw_dat; integer b_addr;
begin
    for (iter = 0; iter < 4096; iter = iter + 1) begin
        b_addr = 4096 + iter*2; 
        hw_dat = {mem_block_dat.DRAM_r[b_addr + 1], mem_block_dat.DRAM_r[b_addr]};
        if (hw_dat !== final_dram_chk[iter]) begin
             $display("\n========================================================");
             $display("                 [FAIL R%0d] DRAM DATA MISMATCH!                       ", curr_round);
             $display("========================================================");
             $display(" Error at Byte Address: 0x%04X", b_addr);
             $display(" Expected: 0x%04X (from Golden Model)", final_dram_chk[iter]);
             $display(" Got     : 0x%04X (from pseudo_DRAM)", hw_dat);
             $display("========================================================\n");
             $display(">>> CORE 1 Final Trace:"); dump_inst_trace(1, dynamic_total_ic - 1);
             $display("\n>>> CORE 2 Final Trace:"); dump_inst_trace(2, dynamic_total_ic - 1);
             $finish;
        end
    end
end endtask

task dump_inst_trace;
    input [3:0] c_idx; input integer ref_ic;
    integer start_pt, ptr; reg [15:0] mach_code, m_pc; reg [2:0] mop, mrs, mrt, mrd, mrl, mfn; reg signed [15:0] mimm; reg [12:0] maddr; reg signed [15:0] rs_val; reg [15:0] d_addr, axi_addr, exp_data; 
    begin
        if (ref_ic >= dynamic_total_ic && dynamic_total_ic > 0) ref_ic = dynamic_total_ic - 1;
        $display("   [Instruction History Trace - Last 5 Cycles]");
        start_pt = (ref_ic < 4) ? 0 : ref_ic - 4;
        for (ptr = start_pt; ptr <= ref_ic; ptr = ptr + 1) begin
            mach_code = (c_idx == 1) ? history_instr_c1[ptr] : history_instr_c2[ptr];
            m_pc      = (c_idx == 1) ? history_pc_1[ptr] : history_pc_2[ptr];
            mop = mach_code[15:13]; mrs = mach_code[12:10]; mrt = mach_code[9:7]; mrd = mach_code[6:4]; mrl = mach_code[3:1]; mfn = mach_code[3:1];
            mimm = $signed({{9{mach_code[6]}}, mach_code[6:0]}); maddr = mach_code[12:0];

            if (ptr == ref_ic) $write("->    "); else $write("      ");
            $write("[IC: %4d] PC: %04x | Instr: %04x | ", ptr, m_pc, mach_code);

            case (mop)
                0: begin
                    if (mfn == 0) $display("ADD    r%0d = r%0d + r%0d", mrd, mrs, mrt); else if (mfn == 1) $display("SUB    r%0d = r%0d - r%0d", mrd, mrs, mrt);
                    else if (mfn == 2) $display("AND    r%0d = r%0d & r%0d", mrd, mrs, mrt); else if (mfn == 3) $display("OR     r%0d = r%0d | r%0d", mrd, mrs, mrt);
                    else if (mfn == 4) $display("NAND   r%0d = ~(r%0d & r%0d)", mrd, mrs, mrt); else if (mfn == 5) $display("NOR    r%0d = ~(r%0d | r%0d)", mrd, mrs, mrt);
                    else if (mfn == 6) $display("XOR    r%0d = r%0d ^ r%0d", mrd, mrs, mrt); else if (mfn == 7) $display("SLT    r%0d = (r%0d < r%0d)", mrd, mrs, mrt);
                end
                1: $display("MULT   {r%0d, r%0d} = r%0d * r%0d", mrd, mrl, mrs, mrt); 2: $display("ADDI   r%0d = r%0d + (%0d)", mrt, mrs, mimm); 3: $display("SUBI   r%0d = r%0d - (%0d)", mrt, mrs, mimm);
                4: begin 
                    if (ptr == ref_ic) begin
                        rs_val = (c_idx == 1) ? ((ptr == 0) ? 0 : expected_reg_c1[ptr - 1][mrs]) : ((ptr == 0) ? 0 : expected_reg_c2[ptr - 1][mrs]);
                        exp_data = (c_idx == 1) ? expected_reg_c1[ptr][mrt] : expected_reg_c2[ptr][mrt];
                        d_addr = rs_val + mimm; axi_addr = 16'h1000 + (d_addr * 2);
                        $display("LOAD   r%0d = MEM[r%0d + (%0d)]  => [Target AXI: %04x | Expected Read: %04x]", mrt, mrs, mimm, axi_addr, exp_data);
                    end else $display("LOAD   r%0d = MEM[r%0d + (%0d)]", mrt, mrs, mimm);
                end
                5: begin 
                    if (ptr == ref_ic) begin
                        rs_val = (c_idx == 1) ? ((ptr == 0) ? 0 : expected_reg_c1[ptr - 1][mrs]) : ((ptr == 0) ? 0 : expected_reg_c2[ptr - 1][mrs]);
                        exp_data = (c_idx == 1) ? ((ptr == 0) ? 0 : expected_reg_c1[ptr - 1][mrt]) : ((ptr == 0) ? 0 : expected_reg_c2[ptr - 1][mrt]);
                        d_addr = rs_val + mimm; axi_addr = 16'h1000 + (d_addr * 2);
                        $display("STORE  MEM[r%0d + (%0d)] = r%0d  => [Target AXI: %04x | Write Data: %04x]", mrs, mimm, mrt, axi_addr, exp_data);
                    end else $display("STORE  MEM[r%0d + (%0d)] = r%0d", mrs, mimm, mrt);
                end
                6: $display("BEQ    IF(r%0d == r%0d) PC = PC + 2 + (%0d)", mrs, mrt, mimm * 2); 7: $display("JUMP   PC = %04x", maddr);
            endcase
        end
    end
endtask

endmodule