//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring Midterm Project: Dual-Core CPU
//   Description : Generator + Pre-simulated Golden + Async Register/DRAM check
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
    `define CYCLE_TIME 20.0
`elsif GATE
`define CYCLE_TIME 3.7
       `elsif CHIP
`define CYCLE_TIME 20.0
       `elsif POST
`define CYCLE_TIME 20.0
`endif

       `ifndef CYCLE_TIME
`define CYCLE_TIME 20.0
`endif

`ifdef FUNC
    `define PAT_NUM 4096
    `define MAX_STALL_CYCLE 2000
`endif
`ifdef PERF
    `define PAT_NUM 1024
    `define MAX_STALL_CYCLE 100000
`endif
       `ifndef PAT_NUM
`define PAT_NUM 4096
`endif
       `ifndef MAX_STALL_CYCLE
`define MAX_STALL_CYCLE 2000
`endif

`define DATA_EFF_MAX 16'sh07FF
`define IMM_MIN  -16'sd64
`define IMM_MAX   16'sd63

       module PATTERN(
           output reg clk,
           output reg rst_n,

           input stall_1,
           input stall_2,

           //===== AXI-4 Instruction1 DRAM =====
           input  wire [3:0]   arid_s_inf_inst_1, input  wire [31:0]  araddr_s_inf_inst_1, input  wire [6:0]   arlen_s_inf_inst_1,
           input  wire [2:0]   arsize_s_inf_inst_1, input  wire [1:0]   arburst_s_inf_inst_1, input  wire         arvalid_s_inf_inst_1,
           output wire         arready_s_inf_inst_1, output wire [3:0]   rid_s_inf_inst_1, output wire [15:0]  rdata_s_inf_inst_1,
           output wire [1:0]   rresp_s_inf_inst_1, output wire         rlast_s_inf_inst_1, output wire         rvalid_s_inf_inst_1,
           input  wire         rready_s_inf_inst_1, input  wire [3:0]   awid_s_inf_inst_1, input  wire [31:0]  awaddr_s_inf_inst_1,
           input  wire [2:0]   awsize_s_inf_inst_1, input  wire [1:0]   awburst_s_inf_inst_1, input  wire [6:0]   awlen_s_inf_inst_1,
           input  wire         awvalid_s_inf_inst_1, output wire         awready_s_inf_inst_1, input  wire [15:0]  wdata_s_inf_inst_1,
           input  wire         wlast_s_inf_inst_1, input  wire         wvalid_s_inf_inst_1, output wire         wready_s_inf_inst_1,
           output wire [3:0]   bid_s_inf_inst_1, output wire [1:0]   bresp_s_inf_inst_1, output wire         bvalid_s_inf_inst_1,
           input  wire         bready_s_inf_inst_1,

           //===== AXI-4 Instruction2 DRAM =====
           input  wire [3:0]   arid_s_inf_inst_2, input  wire [31:0]  araddr_s_inf_inst_2, input  wire [6:0]   arlen_s_inf_inst_2,
           input  wire [2:0]   arsize_s_inf_inst_2, input  wire [1:0]   arburst_s_inf_inst_2, input  wire         arvalid_s_inf_inst_2,
           output wire         arready_s_inf_inst_2, output wire [3:0]   rid_s_inf_inst_2, output wire [15:0]  rdata_s_inf_inst_2,
           output wire [1:0]   rresp_s_inf_inst_2, output wire         rlast_s_inf_inst_2, output wire         rvalid_s_inf_inst_2,
           input  wire         rready_s_inf_inst_2, input  wire [3:0]   awid_s_inf_inst_2, input  wire [31:0]  awaddr_s_inf_inst_2,
           input  wire [2:0]   awsize_s_inf_inst_2, input  wire [1:0]   awburst_s_inf_inst_2, input  wire [6:0]   awlen_s_inf_inst_2,
           input  wire         awvalid_s_inf_inst_2, output wire         awready_s_inf_inst_2, input  wire [15:0]  wdata_s_inf_inst_2,
           input  wire         wlast_s_inf_inst_2, input  wire         wvalid_s_inf_inst_2, output wire         wready_s_inf_inst_2,
           output wire [3:0]   bid_s_inf_inst_2, output wire [1:0]   bresp_s_inf_inst_2, output wire         bvalid_s_inf_inst_2,
           input  wire         bready_s_inf_inst_2,

           //===== AXI-4 Data DRAM =====
           input  wire [3:0]   arid_s_inf_data, input  wire [31:0]  araddr_s_inf_data, input  wire [6:0]   arlen_s_inf_data,
           input  wire [2:0]   arsize_s_inf_data, input  wire [1:0]   arburst_s_inf_data, input  wire         arvalid_s_inf_data,
           output wire         arready_s_inf_data, output wire [3:0]   rid_s_inf_data, output wire [15:0]  rdata_s_inf_data,
           output wire [1:0]   rresp_s_inf_data, output wire         rlast_s_inf_data, output wire         rvalid_s_inf_data,
           input  wire         rready_s_inf_data, input  wire [3:0]   awid_s_inf_data, input  wire [31:0]  awaddr_s_inf_data,
           input  wire [2:0]   awsize_s_inf_data, input  wire [1:0]   awburst_s_inf_data, input  wire [6:0]   awlen_s_inf_data,
           input  wire         awvalid_s_inf_data, output wire         awready_s_inf_data, input  wire [15:0]  wdata_s_inf_data,
           input  wire         wlast_s_inf_data, input  wire         wvalid_s_inf_data, output wire         wready_s_inf_data,
           output wire [3:0]   bid_s_inf_data, output wire [1:0]   bresp_s_inf_data, output wire         bvalid_s_inf_data,
           input  wire         bready_s_inf_data
       );

//---------------------------------------------------------------------
//   CONFIG
//---------------------------------------------------------------------
parameter SHOW_DEBUG = 0; // 0: disable debug trace, 1: enable trace

//---------------------------------------------------------------------
//   STORAGE & COUNTERS
//---------------------------------------------------------------------
integer i, k;
integer f_inst1, f_inst2, f_data;
integer total_cycles;

reg [15:0] inst1_mem [0:4095];
reg [15:0] inst2_mem [0:4095];
reg inst_filled_1 [0:4095];
reg inst_filled_2 [0:4095];

reg signed [15:0] exp_c1_regs [0:`PAT_NUM-1][0:7];
reg signed [15:0] exp_c2_regs [0:`PAT_NUM-1][0:7];
reg [7:0] exp_data_mem      [16'h1000:16'h1FFF];
reg [7:0] exp_data_mem_init [16'h1000:16'h1FFF];
reg [7:0] exp_data_mem_snap [0:(`PAT_NUM/50)][16'h1000:16'h1FFF];

integer inst_cnt_1 = 0;
integer inst_cnt_2 = 0;
integer next_chk_idx = 49;

integer deadlock_cnt_1 = 0;
integer deadlock_cnt_2 = 0;

//---------------------------------------------------------------------
//   DRAM INSTANTIATIONS
//---------------------------------------------------------------------
pseudo_DRAM_inst1 inst1_dram (.clk(clk), .rst_n(rst_n), .arid_s_inf(arid_s_inf_inst_1), .araddr_s_inf(araddr_s_inf_inst_1), .arlen_s_inf(arlen_s_inf_inst_1), .arsize_s_inf(arsize_s_inf_inst_1), .arburst_s_inf(arburst_s_inf_inst_1), .arvalid_s_inf(arvalid_s_inf_inst_1), .arready_s_inf(arready_s_inf_inst_1), .rid_s_inf(rid_s_inf_inst_1), .rdata_s_inf(rdata_s_inf_inst_1), .rresp_s_inf(rresp_s_inf_inst_1), .rlast_s_inf(rlast_s_inf_inst_1), .rvalid_s_inf(rvalid_s_inf_inst_1), .rready_s_inf(rready_s_inf_inst_1), .awid_s_inf(awid_s_inf_inst_1), .awaddr_s_inf(awaddr_s_inf_inst_1), .awsize_s_inf(awsize_s_inf_inst_1), .awburst_s_inf(awburst_s_inf_inst_1), .awlen_s_inf(awlen_s_inf_inst_1), .awvalid_s_inf(awvalid_s_inf_inst_1), .awready_s_inf(awready_s_inf_inst_1), .wdata_s_inf(wdata_s_inf_inst_1), .wlast_s_inf(wlast_s_inf_inst_1), .wvalid_s_inf(wvalid_s_inf_inst_1), .wready_s_inf(wready_s_inf_inst_1), .bid_s_inf(bid_s_inf_inst_1), .bresp_s_inf(bresp_s_inf_inst_1), .bvalid_s_inf(bvalid_s_inf_inst_1), .bready_s_inf(bready_s_inf_inst_1));
pseudo_DRAM_inst2 inst2_dram (.clk(clk), .rst_n(rst_n), .arid_s_inf(arid_s_inf_inst_2), .araddr_s_inf(araddr_s_inf_inst_2), .arlen_s_inf(arlen_s_inf_inst_2), .arsize_s_inf(arsize_s_inf_inst_2), .arburst_s_inf(arburst_s_inf_inst_2), .arvalid_s_inf(arvalid_s_inf_inst_2), .arready_s_inf(arready_s_inf_inst_2), .rid_s_inf(rid_s_inf_inst_2), .rdata_s_inf(rdata_s_inf_inst_2), .rresp_s_inf(rresp_s_inf_inst_2), .rlast_s_inf(rlast_s_inf_inst_2), .rvalid_s_inf(rvalid_s_inf_inst_2), .rready_s_inf(rready_s_inf_inst_2), .awid_s_inf(awid_s_inf_inst_2), .awaddr_s_inf(awaddr_s_inf_inst_2), .awsize_s_inf(awsize_s_inf_inst_2), .awburst_s_inf(awburst_s_inf_inst_2), .awlen_s_inf(awlen_s_inf_inst_2), .awvalid_s_inf(awvalid_s_inf_inst_2), .awready_s_inf(awready_s_inf_inst_2), .wdata_s_inf(wdata_s_inf_inst_2), .wlast_s_inf(wlast_s_inf_inst_2), .wvalid_s_inf(wvalid_s_inf_inst_2), .wready_s_inf(wready_s_inf_inst_2), .bid_s_inf(bid_s_inf_inst_2), .bresp_s_inf(bresp_s_inf_inst_2), .bvalid_s_inf(bvalid_s_inf_inst_2), .bready_s_inf(bready_s_inf_inst_2));
pseudo_DRAM_data  data_dram  (.clk(clk), .rst_n(rst_n), .arid_s_inf(arid_s_inf_data),  .araddr_s_inf(araddr_s_inf_data),  .arlen_s_inf(arlen_s_inf_data),  .arsize_s_inf(arsize_s_inf_data),  .arburst_s_inf(arburst_s_inf_data),  .arvalid_s_inf(arvalid_s_inf_data),  .arready_s_inf(arready_s_inf_data),  .rid_s_inf(rid_s_inf_data),  .rdata_s_inf(rdata_s_inf_data),  .rresp_s_inf(rresp_s_inf_data),  .rlast_s_inf(rlast_s_inf_data),  .rvalid_s_inf(rvalid_s_inf_data),  .rready_s_inf(rready_s_inf_data),  .awid_s_inf(awid_s_inf_data),  .awaddr_s_inf(awaddr_s_inf_data),  .awsize_s_inf(awsize_s_inf_data),  .awburst_s_inf(awburst_s_inf_data),  .awlen_s_inf(awlen_s_inf_data),  .awvalid_s_inf(awvalid_s_inf_data),  .awready_s_inf(awready_s_inf_data),  .wdata_s_inf(wdata_s_inf_data),  .wlast_s_inf(wlast_s_inf_data),  .wvalid_s_inf(wvalid_s_inf_data),  .wready_s_inf(wready_s_inf_data),  .bid_s_inf(bid_s_inf_data),  .bresp_s_inf(bresp_s_inf_data),  .bvalid_s_inf(bvalid_s_inf_data),  .bready_s_inf(bready_s_inf_data));

//---------------------------------------------------------------------
//   CLOCK & CYCLE COUNTER
//---------------------------------------------------------------------
initial begin
    clk = 0;
    total_cycles = 0;
    forever
        #(`CYCLE_TIME/2.0) clk = ~clk;
end
always @(posedge clk) if (rst_n)
        total_cycles = total_cycles + 1;

//=====================================================================
//   AXI LATENCY CHECKER
//=====================================================================
integer r_lat_i1, b_lat_i1;
integer r_lat_i2, b_lat_i2;
integer r_lat_d,  b_lat_d;

always @(posedge clk) begin
    if (!rst_n) begin
        r_lat_i1 = 0;
        b_lat_i1 = 0;
        r_lat_i2 = 0;
        b_lat_i2 = 0;
        r_lat_d  = 0;
        b_lat_d  = 0;
    end
    else begin
        r_lat_i1 = (rvalid_s_inf_inst_1 && !rready_s_inf_inst_1) ? r_lat_i1 + 1 : 0;
        b_lat_i1 = (bvalid_s_inf_inst_1 && !bready_s_inf_inst_1) ? b_lat_i1 + 1 : 0;
        r_lat_i2 = (rvalid_s_inf_inst_2 && !rready_s_inf_inst_2) ? r_lat_i2 + 1 : 0;
        b_lat_i2 = (bvalid_s_inf_inst_2 && !bready_s_inf_inst_2) ? b_lat_i2 + 1 : 0;
        r_lat_d  = (rvalid_s_inf_data && !rready_s_inf_data) ? r_lat_d + 1 : 0;
        b_lat_d  = (bvalid_s_inf_data && !bready_s_inf_data) ? b_lat_d + 1 : 0;

        if (r_lat_i1 > 300 || r_lat_i2 > 300 || r_lat_d > 300) begin
            $display("\n [SPEC ERROR] AXI RREADY not asserted within 300 cycles.");
            $finish;
        end
        if (b_lat_i1 > 300 || b_lat_i2 > 300 || b_lat_d > 300) begin
            $display("\n [SPEC ERROR] AXI BREADY not asserted within 300 cycles.");
            $finish;
        end
    end
end

//---------------------------------------------------------------------
//   MAIN FLOW
//---------------------------------------------------------------------
initial begin
    integer seed = 66; // random seed
    $srandom(seed);
    rst_n = 1'b1;
    generate_and_presimulate();

    $readmemh("../00_TESTBED/DRAM/inst_1_dram_file.dat", inst1_dram.DRAM_r);
    $readmemh("../00_TESTBED/DRAM/inst_2_dram_file.dat", inst2_dram.DRAM_r);
    $readmemh("../00_TESTBED/DRAM/data_dram_file.dat",   data_dram.DRAM_r);

    reset_task();
    while (inst_cnt_1 < `PAT_NUM || inst_cnt_2 < `PAT_NUM) begin
        if (inst_cnt_1 > next_chk_idx && inst_cnt_2 > next_chk_idx) begin
            check_data_dram(next_chk_idx);
            next_chk_idx = next_chk_idx + 50;
        end

        deadlock_cnt_1 = (stall_1 === 1'b1) ? deadlock_cnt_1 + 1 : 0;
        deadlock_cnt_2 = (stall_2 === 1'b1) ? deadlock_cnt_2 + 1 : 0;

        if (deadlock_cnt_1 > `MAX_STALL_CYCLE || deadlock_cnt_2 > `MAX_STALL_CYCLE) begin
            $display("\n===============================================================================");
            $display(" [FATAL ERROR] PIPELINE DEADLOCK DETECTED! (> %0d cycles)", `MAX_STALL_CYCLE);
            $display("===============================================================================");
            $display("   Core 1 Executed IC=%0d", inst_cnt_1);
            $display("   Core 2 Executed IC=%0d", inst_cnt_2);
            $display("===============================================================================\n");
            $finish;
        end
        @(negedge clk);
    end

    check_data_dram(`PAT_NUM - 1);
    success_task();
end

//---------------------------------------------------------------------
//   REGISTER CHECKERS & PROGRESS
//---------------------------------------------------------------------
always @(negedge clk) begin
    if (rst_n && stall_1 === 1'b0 && inst_cnt_1 < `PAT_NUM) begin
        check_core_1_registers(inst_cnt_1);
        if ((inst_cnt_1 + 1) % 100 == 0) begin // print frequency
            $display("\033[1;32m  [PASS] Core 1 Instruction %4d / %4d PASS \033[0m", inst_cnt_1 + 1, `PAT_NUM);
        end
        inst_cnt_1 = inst_cnt_1 + 1;
    end
end

always @(negedge clk) begin
    if (rst_n && stall_2 === 1'b0 && inst_cnt_2 < `PAT_NUM) begin
        check_core_2_registers(inst_cnt_2);
        if ((inst_cnt_2 + 1) % 100 == 0) begin // print frequency
            $display("\033[1;32m  [PASS] Core 2 Instruction %4d / %4d PASS \033[0m", inst_cnt_2 + 1, `PAT_NUM);
        end
        inst_cnt_2 = inst_cnt_2 + 1;
    end
end

//=====================================================================
//   GENERATOR + PRE-SIMULATOR
//=====================================================================
reg signed [15:0] gen_c1_regs [0:7];
reg signed [15:0] gen_c2_regs [0:7];

task generate_and_presimulate;
    integer ic;
    reg [15:0] pc_1, pc_2;
    reg [15:0] i1, i2;
    reg        c2_is_store;
    reg        dummy_flag;
    begin
        for (i = 0; i < 8; i = i + 1) begin
            gen_c1_regs[i] = 0;
            gen_c2_regs[i] = 0;
        end
        pc_1 = 0;
        pc_2 = 0;

        f_inst1 = $fopen("../00_TESTBED/DRAM/inst_1_dram_file.dat", "w");
        f_inst2 = $fopen("../00_TESTBED/DRAM/inst_2_dram_file.dat", "w");
        f_data  = $fopen("../00_TESTBED/DRAM/data_dram_file.dat",  "w");

        if (f_inst1 == 0 || f_inst2 == 0 || f_data == 0) begin
            $display("[SYSTEM ERROR] Cannot open .dat files.");
            $finish;
        end

        for (i = 0; i < 4096; i = i + 1) begin
            inst1_mem[i] = 16'h0000;
            inst2_mem[i] = 16'h0000;
            inst_filled_1[i] = 1'b0;
            inst_filled_2[i] = 1'b0;
        end

        begin : init_data_dram
            reg [7:0] rlo, rhi;
            for (k = 16'h1000; k < 16'h1FFF; k = k + 2) begin
                rlo = $urandom_range(0, 255);
                rhi = $urandom_range(0, 255);
                exp_data_mem[k]        = rlo;
                exp_data_mem[k+1]      = rhi;
                exp_data_mem_init[k]   = rlo;
                exp_data_mem_init[k+1] = rhi;
                $fwrite(f_data, "@%08X\n", k);
                $fwrite(f_data, "%02X %02X\n", rlo, rhi);
            end
        end

        begin : phase1_generate
            reg [15:0] ppc;
            for (i = 0; i < 8; i = i + 1) begin
                gen_c1_regs[i] = 0;
                gen_c2_regs[i] = 0;
            end

            for (ppc = 16'h0000; ppc < (`PAT_NUM * 2); ppc = ppc + 16'd2) begin
                if (ppc == (`PAT_NUM * 2 - 16'd2)) begin
                    i1 = {3'b111, 13'd0};
                    c2_is_store = 1'b0;
                end
                else begin
                    gen_one_instruction_bj(0, 1'b0, ppc, i1, c2_is_store);
                end
                inst1_mem[ppc >> 1] = i1;
                inst_filled_1[ppc >> 1] = 1'b1;

                if (ppc == (`PAT_NUM * 2 - 16'd2)) begin
                    i2 = {3'b111, 13'd0};
                end
                else begin
                    gen_one_instruction_bj(1, c2_is_store, ppc, i2, dummy_flag);
                end
                inst2_mem[ppc >> 1] = i2;
                inst_filled_2[ppc >> 1] = 1'b1;

                if (i2[15:13] == 3'b101) begin
                    execute_instruction(1, i2);
                    execute_instruction(0, i1);
                end
                else begin
                    execute_instruction(0, i1);
                    execute_instruction(1, i2);
                end
            end
        end

        phase2_resimulate;

        for (k = 16'h1000; k <= 16'h1FFF; k = k + 1)
            exp_data_mem_snap[`PAT_NUM/50][k] = exp_data_mem[k];

        for (ic = 0; ic < 4096; ic = ic + 1) begin
            $fwrite(f_inst1, "@%04X\n", ic*2);
            $fwrite(f_inst1, "%02X %02X\n", inst1_mem[ic][7:0], inst1_mem[ic][15:8]);
            $fwrite(f_inst2, "@%04X\n", ic*2);
            $fwrite(f_inst2, "%02X %02X\n", inst2_mem[ic][7:0], inst2_mem[ic][15:8]);
        end

        $fclose(f_inst1);
        $fclose(f_inst2);
        $fclose(f_data);
    end
endtask

//=====================================================================
//  PHASE 2 RE-SIMULATION
//=====================================================================
task phase2_resimulate;
    integer ic, n;
    reg [15:0] pc_1, pc_2;
    reg [15:0] i1, i2;
    reg signed [15:0] rs_v, rt_v;
    reg signed [15:0] imm_s1, imm_s2;
    reg signed [31:0] addr_c1, addr_c2;
    reg        illegal_c1, illegal_c2;
    reg        retry_sim;
    begin
        retry_sim = 1'b1;
        while (retry_sim) begin
            retry_sim = 1'b0;
            for (n = 0; n < 8; n = n + 1) begin
                gen_c1_regs[n] = 16'sd0;
                gen_c2_regs[n] = 16'sd0;
            end
            for (k = 16'h1000; k <= 16'h1FFF; k = k + 1)
                exp_data_mem[k] = exp_data_mem_init[k];
            pc_1 = 16'h0000;
            pc_2 = 16'h0000;

            begin : ic_loop
                for (ic = 0; ic < `PAT_NUM; ic = ic + 1) begin
                    i1 = inst1_mem[pc_1 >> 1];
                    i2 = inst2_mem[pc_2 >> 1];
                    illegal_c1 = 1'b0;
                    illegal_c2 = 1'b0;

                    if (i1[15:13] == 3'b100 || i1[15:13] == 3'b101) begin
                        rs_v   = gen_c1_regs[i1[12:10]];
                        imm_s1 = {{9{i1[6]}}, i1[6:0]};
                        addr_c1 = ({{16{rs_v[15]}}, rs_v} + {{16{imm_s1[15]}}, imm_s1}) * 2 + 32'h0000_1000;
                        if (addr_c1 < 32'h0000_1000 || addr_c1 > 32'h0000_1FFE)
                            illegal_c1 = 1'b1;
                    end
                    if (i2[15:13] == 3'b100 || i2[15:13] == 3'b101) begin
                        rs_v   = gen_c2_regs[i2[12:10]];
                        imm_s2 = {{9{i2[6]}}, i2[6:0]};
                        addr_c2 = ({{16{rs_v[15]}}, rs_v} + {{16{imm_s2[15]}}, imm_s2}) * 2 + 32'h0000_1000;
                        if (addr_c2 < 32'h0000_1000 || addr_c2 > 32'h0000_1FFE)
                            illegal_c2 = 1'b1;
                    end

                    // exclusive store check
                    if (i1[15:13] == 3'b101 && i2[15:13] == 3'b101) begin
                        inst2_mem[pc_2 >> 1] = 16'h0000;
                        retry_sim = 1'b1;
                    end

                    if (illegal_c1) begin
                        inst1_mem[pc_1 >> 1] = 16'h0000;
                        retry_sim = 1'b1;
                    end
                    if (illegal_c2) begin
                        inst2_mem[pc_2 >> 1] = 16'h0000;
                        retry_sim = 1'b1;
                    end

                    if (retry_sim)
                        disable ic_loop;

                    // execute
                    if (i2[15:13] == 3'b101) begin
                        execute_instruction(1, i2);
                        execute_instruction(0, i1);
                    end
                    else begin
                        execute_instruction(0, i1);
                        execute_instruction(1, i2);
                    end

                    // PC update
                    case (i1[15:13])
                        3'b110:
                            pc_1 = (gen_c1_regs[i1[12:10]] == gen_c1_regs[i1[9:7]]) ? (pc_1 + 16'd2 + ({{9{i1[6]}}, i1[6:0], 1'b0})) : (pc_1 + 16'd2);
                        3'b111:
                            pc_1 = {3'b000, i1[12:0]};
                        default:
                            pc_1 = pc_1 + 16'd2;
                    endcase
                    case (i2[15:13])
                        3'b110:
                            pc_2 = (gen_c2_regs[i2[12:10]] == gen_c2_regs[i2[9:7]]) ? (pc_2 + 16'd2 + ({{9{i2[6]}}, i2[6:0], 1'b0})) : (pc_2 + 16'd2);
                        3'b111:
                            pc_2 = {3'b000, i2[12:0]};
                        default:
                            pc_2 = pc_2 + 16'd2;
                    endcase

                    if (pc_1 >= (`PAT_NUM * 2))
                        pc_1 = 16'h0000;
                    if (pc_2 >= (`PAT_NUM * 2))
                        pc_2 = 16'h0000;

                    for (n = 0; n < 8; n = n + 1) begin
                        exp_c1_regs[ic][n] = gen_c1_regs[n];
                        exp_c2_regs[ic][n] = gen_c2_regs[n];
                    end

                    // snapshot dram state
                    if (((ic + 1) % 50) == 0) begin
                        for (k = 16'h1000; k <= 16'h1FFF; k = k + 1)
                            exp_data_mem_snap[(ic+1)/50 - 1][k] = exp_data_mem[k];
                    end
                end
            end
        end
    end
endtask

//---------------------------------------------------------------------
// Generate ONE instruction
//---------------------------------------------------------------------
task gen_one_instruction;
    input  integer core_sel;
    input         forbid_store;
    output reg [15:0] inst_out;
    output reg        is_store_out;

    reg [2:0] op_sel, op, rs, rt, rd, func;
    reg signed [6:0] imm7;
    reg signed [15:0] imm_s;
    reg signed [15:0] rs_val, rt_val;
    reg        ok;
    integer    retry;
    begin
        retry = 0;
        is_store_out = 0;
        ok = 0;
        while (!ok) begin
            op_sel = $urandom_range(0, 5);
            if (forbid_store && op_sel == 5)
                op_sel = 4;

            rs = $urandom_range(0, 7);
            rt = $urandom_range(0, 7);
            rd = $urandom_range(0, 7);

            case (op_sel)
                3'd0: begin // ALU
                    func = $urandom_range(0, 7);
                    rs_val = (core_sel == 0) ? gen_c1_regs[rs] : gen_c2_regs[rs];
                    rt_val = (core_sel == 0) ? gen_c1_regs[rt] : gen_c2_regs[rt];
                    if (func == 3'b000 && add_overflows(rs_val, rt_val)) begin
                        retry = retry + 1;
                        if (retry > 32) begin
                            func = 3'b001;
                            rt = rs; // fallback
                            inst_out = {3'b000, rs, rt, rd, func, 1'b0};
                            ok = 1;
                        end
                    end
                    else if (func == 3'b001 && sub_overflows(rs_val, rt_val)) begin
                        retry = retry + 1;
                        if (retry > 32) begin
                            func = 3'b001;
                            rt = rs; // fallback
                            inst_out = {3'b000, rs, rt, rd, func, 1'b0};
                            ok = 1;
                        end
                    end
                    else begin
                        inst_out = {3'b000, rs, rt, rd, func, 1'b0};
                        ok = 1;
                    end
                end

                3'd1: begin // Mult
                    func = $urandom_range(0, 7);
                    while (func == rd)
                        func = $urandom_range(0, 7);
                    inst_out = {3'b001, rs, rt, rd, func, 1'b0};
                    ok = 1;
                end

                3'd2: begin // ADDI
                    imm7 = $urandom_range(0, 127);
                    imm_s = {{9{imm7[6]}}, imm7};
                    rs_val = (core_sel == 0) ? gen_c1_regs[rs] : gen_c2_regs[rs];
                    if (add_overflows(rs_val, imm_s)) begin
                        retry = retry + 1;
                        if (retry > 32) begin
                            imm7 = 7'd0; // fallback
                            inst_out = {3'b010, rs, rt, imm7};
                            ok = 1;
                        end
                    end
                    else begin
                        inst_out = {3'b010, rs, rt, imm7};
                        ok = 1;
                    end
                end

                3'd3: begin // SUBI
                    imm7 = $urandom_range(0, 127);
                    imm_s = {{9{imm7[6]}}, imm7};
                    rs_val = (core_sel == 0) ? gen_c1_regs[rs] : gen_c2_regs[rs];
                    if (sub_overflows(rs_val, imm_s)) begin
                        retry = retry + 1;
                        if (retry > 32) begin
                            imm7 = 7'd0; // fallback
                            inst_out = {3'b011, rs, rt, imm7};
                            ok = 1;
                        end
                    end
                    else begin
                        inst_out = {3'b011, rs, rt, imm7};
                        ok = 1;
                    end
                end

                3'd4: begin // Load
                    if (pick_base(core_sel, rs, imm7)) begin
                        inst_out = {3'b100, rs, rt, imm7};
                        ok = 1;
                    end
                    else begin
                        inst_out = {3'b000, rs, rt, rd, 3'b010, 1'b0};
                        ok = 1;
                    end
                end

                3'd5: begin // Store
                    if (pick_base(core_sel, rs, imm7)) begin
                        inst_out = {3'b101, rs, rt, imm7};
                        is_store_out = 1;
                        ok = 1;
                    end
                    else begin
                        inst_out = {3'b000, rs, rt, rd, 3'b010, 1'b0};
                        ok = 1;
                    end
                end
                default: begin
                    inst_out = {3'b000, rs, rt, rd, 3'b010, 1'b0};
                    ok = 1;
                end
            endcase
        end
    end
endtask

//---------------------------------------------------------------------
// gen_one_instruction_bj
//---------------------------------------------------------------------
task gen_one_instruction_bj;
    input  integer core_sel;
    input          forbid_store;
    input  [15:0]  curr_pc;
    output reg [15:0] inst_out;
    output reg        is_store_out;

    reg [2:0] pick, rs, rt;
    reg signed [6:0]  imm7;
    reg signed [15:0] sx;
    reg [15:0]        tgt_not_taken;
    reg signed [17:0] tgt_taken;
    reg [15:0]        jump_lo, jump_hi, jump_tgt;
    integer    tries;
    begin
        is_store_out = 1'b0;
        pick = $urandom_range(0, 7);
        if (pick == 0) begin : try_branch
            tries = 0;
            while (tries < 16) begin
                imm7 = $urandom_range(0, 127);
                sx   = {{9{imm7[6]}}, imm7};
                tgt_not_taken = curr_pc + 16'd2;
                tgt_taken = $signed({2'b00, curr_pc}) + 18'sd2 + $signed({{2{sx[15]}}, sx, 1'b0});
                if (tgt_not_taken < (`PAT_NUM * 2 - 2) && tgt_taken >= 18'sd0 && tgt_taken < $signed(`PAT_NUM * 2 - 2)) begin
                    if ($urandom_range(0, 99) < 50) begin
                        rs = $urandom_range(0, 7);
                        rt = rs;
                    end
                    else begin
                        rs = $urandom_range(0, 7);
                        rt = $urandom_range(0, 7);
                    end
                    inst_out = {3'b110, rs, rt, imm7};
                    disable try_branch;
                end
                tries = tries + 1;
            end
            gen_one_instruction(core_sel, forbid_store, inst_out, is_store_out);
        end
        else if (pick == 1) begin : try_jump
            jump_lo = (curr_pc >= 16'd256) ? curr_pc - 16'd256 : 16'h0000;
            jump_hi = (curr_pc + 16'd256 < (`PAT_NUM * 2 - 2)) ? curr_pc + 16'd256 : `PAT_NUM * 2 - 4;

            if (jump_hi < jump_lo)
                gen_one_instruction(core_sel, forbid_store, inst_out, is_store_out);
            else begin
                jump_tgt = jump_lo + ($urandom_range(0, (jump_hi - jump_lo) >> 1) <<< 1);
                inst_out = {3'b111, jump_tgt[12:0]};
            end
        end
        else begin
            gen_one_instruction(core_sel, forbid_store, inst_out, is_store_out);
        end
    end
endtask

//---------------------------------------------------------------------
function pick_base;
    input integer core_sel;
    output reg [2:0] rs_out;
    output reg signed [6:0] imm_out;
    integer n, cand_n, choice, imm_range;
    reg [2:0] cand [0:7];
    reg signed [15:0] v, lo, hi, imm_s;
    begin
        cand_n = 0;
        for (n = 0; n < 8; n = n + 1) begin
            v = (core_sel == 0) ? gen_c1_regs[n] : gen_c2_regs[n];
            if (v >= -16'sd63 && v <= (`DATA_EFF_MAX + 16'sd64)) begin
                cand[cand_n] = n[2:0];
                cand_n = cand_n + 1;
            end
        end

        if (cand_n == 0) begin
            pick_base = 1'b0;
            rs_out = 3'd0;
            imm_out = 7'd0;
        end
        else begin
            choice = $urandom_range(0, cand_n - 1);
            rs_out = cand[choice];
            v = (core_sel == 0) ? gen_c1_regs[rs_out] : gen_c2_regs[rs_out];
            lo = (`IMM_MIN > (-v)) ? `IMM_MIN : (-v);
            hi = (`IMM_MAX < (`DATA_EFF_MAX - v)) ? `IMM_MAX : (`DATA_EFF_MAX - v);
            imm_range = hi - lo;
            imm_s = lo + $urandom_range(0, imm_range);
            imm_out = imm_s[6:0];
            pick_base = 1'b1;
        end
    end
endfunction

//---------------------------------------------------------------------
// execute_instruction
//---------------------------------------------------------------------
task execute_instruction;
    input integer core_sel;
    input [15:0]  inst;
    reg [2:0] op, rs, rt, rd, func, rl;
    reg signed [6:0]  imm7;
    reg signed [15:0] imm_s, rs_v, rt_v, new_val_rd, new_val_rt, new_val_rl;
    reg signed [31:0] mult_res, addr;
    begin
        op = inst[15:13];
        rs = inst[12:10];
        rt = inst[9:7];
        rd = inst[6:4];
        func = inst[3:1];
        rl = inst[3:1];
        imm7 = inst[6:0];
        imm_s = {{9{imm7[6]}}, imm7};
        rs_v = (core_sel == 0) ? gen_c1_regs[rs] : gen_c2_regs[rs];
        rt_v = (core_sel == 0) ? gen_c1_regs[rt] : gen_c2_regs[rt];
        case (op)
            3'b000: begin
                case (func)
                    3'b000:
                        new_val_rd = rs_v + rt_v;
                    3'b001:
                        new_val_rd = rs_v - rt_v;
                    3'b010:
                        new_val_rd = rs_v & rt_v;
                    3'b011:
                        new_val_rd = rs_v | rt_v;
                    3'b100:
                        new_val_rd = ~(rs_v & rt_v);
                    3'b101:
                        new_val_rd = ~(rs_v | rt_v);
                    3'b110:
                        new_val_rd = rs_v ^ rt_v;
                    3'b111:
                        new_val_rd = (rs_v < rt_v) ? 16'sd1 : 16'sd0;
                endcase
                if (core_sel == 0)
                    gen_c1_regs[rd] = new_val_rd;
                else
                    gen_c2_regs[rd] = new_val_rd;
            end
            3'b001: begin
                mult_res = rs_v * rt_v;
                new_val_rd = mult_res[31:16];
                new_val_rl = mult_res[15:0];
                if (core_sel == 0) begin
                    gen_c1_regs[rd] = new_val_rd;
                    gen_c1_regs[rl] = new_val_rl;
                end
                else begin
                    gen_c2_regs[rd] = new_val_rd;
                    gen_c2_regs[rl] = new_val_rl;
                end
            end
            3'b010: begin
                new_val_rt = rs_v + imm_s;
                if (core_sel == 0)
                    gen_c1_regs[rt] = new_val_rt;
                else
                    gen_c2_regs[rt] = new_val_rt;
            end
            3'b011: begin
                new_val_rt = rs_v - imm_s;
                if (core_sel == 0)
                    gen_c1_regs[rt] = new_val_rt;
                else
                    gen_c2_regs[rt] = new_val_rt;
            end
            3'b100: begin
                addr = ({{16{rs_v[15]}}, rs_v} + {{16{imm_s[15]}}, imm_s}) * 2 + 32'h1000;
                new_val_rt = {exp_data_mem[addr+1], exp_data_mem[addr]};
                if (core_sel == 0)
                    gen_c1_regs[rt] = new_val_rt;
                else
                    gen_c2_regs[rt] = new_val_rt;
            end
            3'b101: begin
                addr = ({{16{rs_v[15]}}, rs_v} + {{16{imm_s[15]}}, imm_s}) * 2 + 32'h1000;
                exp_data_mem[addr]   = rt_v[7:0];
                exp_data_mem[addr+1] = rt_v[15:8];
            end
            default:
                ;
        endcase
    end
endtask

//---------------------------------------------------------------------
function add_overflows;
    input signed [15:0] a;
    input signed [15:0] b;
    reg signed [16:0] s;
    begin
        s = {a[15], a} + {b[15], b};
        add_overflows = (s > 16'sh7FFF) || (s < -16'sh8000);
    end
endfunction

function sub_overflows;
    input signed [15:0] a;
    input signed [15:0] b;
    reg signed [16:0] s;
    begin
        s = {a[15], a} - {b[15], b};
        sub_overflows = (s > 16'sh7FFF) || (s < -16'sh8000);
    end
endfunction

//=====================================================================
//   SUPPORTING TASKS
//=====================================================================
task reset_task;
    begin
        force clk = 1'b0;
        // Active-low reset initialization
        rst_n = 1'b1;
        #(0.5 * `CYCLE_TIME);

        // Assert reset (pull low)
        rst_n = 1'b0;
        #(2.0 * `CYCLE_TIME);
        // Release reset (pull high)
        rst_n = 1'b1;
        // Wait at least 3 clock cycles
        #(4.0 * `CYCLE_TIME);
        release clk;


    end
endtask

task check_core_1_registers;
    input integer c_ic;
    reg mismatch;
    begin
        mismatch = 0;
        if (TESTBED.u_DCCPU.core_1_r0 !== exp_c1_regs[c_ic][0])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r1 !== exp_c1_regs[c_ic][1])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r2 !== exp_c1_regs[c_ic][2])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r3 !== exp_c1_regs[c_ic][3])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r4 !== exp_c1_regs[c_ic][4])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r5 !== exp_c1_regs[c_ic][5])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r6 !== exp_c1_regs[c_ic][6])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_1_r7 !== exp_c1_regs[c_ic][7])
            mismatch = 1;

        if (mismatch || (SHOW_DEBUG && c_ic <= 20)) begin
            $display("\n===============================================================================");
            $display(" [TRACE] Core 1 Execution Trace at IC=%0d", c_ic);
            $display("-------------------------------------------------------------------------------");
            $display("  [GOLDEN] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h", exp_c1_regs[c_ic][0], exp_c1_regs[c_ic][1], exp_c1_regs[c_ic][2], exp_c1_regs[c_ic][3], exp_c1_regs[c_ic][4], exp_c1_regs[c_ic][5], exp_c1_regs[c_ic][6], exp_c1_regs[c_ic][7]);
            if (mismatch) begin
                $display("  [ DUT  ] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h   <-- [ERROR MISMATCH]", TESTBED.u_DCCPU.core_1_r0, TESTBED.u_DCCPU.core_1_r1, TESTBED.u_DCCPU.core_1_r2, TESTBED.u_DCCPU.core_1_r3, TESTBED.u_DCCPU.core_1_r4, TESTBED.u_DCCPU.core_1_r5, TESTBED.u_DCCPU.core_1_r6, TESTBED.u_DCCPU.core_1_r7);
                $display("===============================================================================\n");
                $finish;
            end
            else begin
                $display("  [ DUT  ] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h", TESTBED.u_DCCPU.core_1_r0, TESTBED.u_DCCPU.core_1_r1, TESTBED.u_DCCPU.core_1_r2, TESTBED.u_DCCPU.core_1_r3, TESTBED.u_DCCPU.core_1_r4, TESTBED.u_DCCPU.core_1_r5, TESTBED.u_DCCPU.core_1_r6, TESTBED.u_DCCPU.core_1_r7);
                $display("===============================================================================\n");
            end
        end
    end
endtask

task check_core_2_registers;
    input integer c_ic;
    reg mismatch;
    begin
        mismatch = 0;
        if (TESTBED.u_DCCPU.core_2_r0 !== exp_c2_regs[c_ic][0])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r1 !== exp_c2_regs[c_ic][1])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r2 !== exp_c2_regs[c_ic][2])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r3 !== exp_c2_regs[c_ic][3])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r4 !== exp_c2_regs[c_ic][4])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r5 !== exp_c2_regs[c_ic][5])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r6 !== exp_c2_regs[c_ic][6])
            mismatch = 1;
        if (TESTBED.u_DCCPU.core_2_r7 !== exp_c2_regs[c_ic][7])
            mismatch = 1;

        if (mismatch || (SHOW_DEBUG && c_ic <= 20)) begin
            $display("\n===============================================================================");
            $display(" [TRACE] Core 2 Execution Trace at IC=%0d", c_ic);
            $display("-------------------------------------------------------------------------------");
            $display("  [GOLDEN] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h", exp_c2_regs[c_ic][0], exp_c2_regs[c_ic][1], exp_c2_regs[c_ic][2], exp_c2_regs[c_ic][3], exp_c2_regs[c_ic][4], exp_c2_regs[c_ic][5], exp_c2_regs[c_ic][6], exp_c2_regs[c_ic][7]);
            if (mismatch) begin
                $display("  [ DUT  ] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h   <-- [ERROR MISMATCH]", TESTBED.u_DCCPU.core_2_r0, TESTBED.u_DCCPU.core_2_r1, TESTBED.u_DCCPU.core_2_r2, TESTBED.u_DCCPU.core_2_r3, TESTBED.u_DCCPU.core_2_r4, TESTBED.u_DCCPU.core_2_r5, TESTBED.u_DCCPU.core_2_r6, TESTBED.u_DCCPU.core_2_r7);
                $display("===============================================================================\n");
                $finish;
            end
            else begin
                $display("  [ DUT  ] r0:%4h r1:%4h r2:%4h r3:%4h r4:%4h r5:%4h r6:%4h r7:%4h", TESTBED.u_DCCPU.core_2_r0, TESTBED.u_DCCPU.core_2_r1, TESTBED.u_DCCPU.core_2_r2, TESTBED.u_DCCPU.core_2_r3, TESTBED.u_DCCPU.core_2_r4, TESTBED.u_DCCPU.core_2_r5, TESTBED.u_DCCPU.core_2_r6, TESTBED.u_DCCPU.core_2_r7);
                $display("===============================================================================\n");
            end
        end
    end
endtask

task check_data_dram;
    input integer target_ic;
    integer snap_idx;
    reg mismatch;
    begin
        snap_idx = (target_ic == `PAT_NUM - 1) ? (`PAT_NUM / 50) : ((target_ic + 1) / 50 - 1);
        if (snap_idx < 0)
            snap_idx = 0;
        mismatch = 0;
        for (k = 16'h1000; k < 16'h1FFF; k = k + 2) begin
            if (data_dram.DRAM_r[k] !== exp_data_mem_snap[snap_idx][k] || data_dram.DRAM_r[k+1] !== exp_data_mem_snap[snap_idx][k+1]) begin
                $display("\n [WRONG] Data DRAM mismatch at addr %04X", k);
                mismatch = 1;
            end
        end
        if (mismatch)
            $finish;
    end
endtask

task success_task;
    begin
        $display("================================================================");
        $display("  Simulation Finished Successfully!                             ");
        $display("----------------------------------------------------------------");
        $display("  Total Executed Inst. : %0d (Core1: %0d, Core2: %0d)", `PAT_NUM * 2, `PAT_NUM, `PAT_NUM);
        $display("  Total Clock Cycles   : %0d", total_cycles);
        $display("================================================================");
        $finish;
    end
endtask

endmodule
