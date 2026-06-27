//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring Midterm Project: Dual-Core CPU 
//   Author                           : Ying-Yu Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.v
//   Module Name : PATTERN.v
//   Release version : V3.0 (Ultimate Auto-Generation Golden Edition)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

`ifdef RTL
	`define CYCLE_TIME 4.4 
`elsif GATE
	`define CYCLE_TIME 3.7
`elsif CHIP
    `define CYCLE_TIME 20.0
`elsif POST
    `define CYCLE_TIME 20.0
`endif

`ifdef FUNC
`define MAX_WAIT_READY_CYCLE 2000
`endif
`ifdef PERF
`define MAX_WAIT_READY_CYCLE 100000
`endif

`ifdef GEN
localparam FLAG_GEN = 1'b1;
`else
localparam FLAG_GEN = 1'b0;
`endif

module PATTERN(
    output reg clk,
    output reg rst_n,
    input wire stall_1,
    input wire stall_2,

    //===== AXI-4 Instruction1 DRAM =====
    input wire [3:0]   arid_s_inf_inst_1,
    input wire [31:0]  araddr_s_inf_inst_1,
    input wire [6:0]   arlen_s_inf_inst_1,
    input wire [2:0]   arsize_s_inf_inst_1,
    input wire [1:0]   arburst_s_inf_inst_1,
    input wire         arvalid_s_inf_inst_1,
    output wire        arready_s_inf_inst_1,
    output wire [3:0]  rid_s_inf_inst_1,
    output wire [15:0] rdata_s_inf_inst_1,
    output wire [1:0]  rresp_s_inf_inst_1,
    output wire        rlast_s_inf_inst_1,
    output wire        rvalid_s_inf_inst_1,
    input wire         rready_s_inf_inst_1,
    input wire [3:0]   awid_s_inf_inst_1,
    input wire [31:0]  awaddr_s_inf_inst_1,
    input wire [2:0]   awsize_s_inf_inst_1,
    input wire [1:0]   awburst_s_inf_inst_1,
    input wire [6:0]   awlen_s_inf_inst_1,
    input wire         awvalid_s_inf_inst_1,
    output wire        awready_s_inf_inst_1,
    input wire [15:0]  wdata_s_inf_inst_1,
    input wire         wlast_s_inf_inst_1,
    input wire         wvalid_s_inf_inst_1,
    output wire        wready_s_inf_inst_1,
    output wire [3:0]  bid_s_inf_inst_1,
    output wire [1:0]  bresp_s_inf_inst_1,
    output wire        bvalid_s_inf_inst_1,
    input wire         bready_s_inf_inst_1,

    //===== AXI-4 Instruction2 DRAM =====
    input wire [3:0]   arid_s_inf_inst_2,
    input wire [31:0]  araddr_s_inf_inst_2,
    input wire [6:0]   arlen_s_inf_inst_2,
    input wire [2:0]   arsize_s_inf_inst_2,
    input wire [1:0]   arburst_s_inf_inst_2,
    input wire         arvalid_s_inf_inst_2,
    output wire        arready_s_inf_inst_2,
    output wire [3:0]  rid_s_inf_inst_2,
    output wire [15:0] rdata_s_inf_inst_2,
    output wire [1:0]  rresp_s_inf_inst_2,
    output wire        rlast_s_inf_inst_2,
    output wire        rvalid_s_inf_inst_2,
    input wire         rready_s_inf_inst_2,
    input wire [3:0]   awid_s_inf_inst_2,
    input wire [31:0]  awaddr_s_inf_inst_2,
    input wire [2:0]   awsize_s_inf_inst_2,
    input wire [1:0]   awburst_s_inf_inst_2,
    input wire [6:0]   awlen_s_inf_inst_2,
    input wire         awvalid_s_inf_inst_2,
    output wire        awready_s_inf_inst_2,
    input wire [15:0]  wdata_s_inf_inst_2,
    input wire         wlast_s_inf_inst_2,
    input wire         wvalid_s_inf_inst_2,
    output wire        wready_s_inf_inst_2,
    output wire [3:0]  bid_s_inf_inst_2,
    output wire [1:0]  bresp_s_inf_inst_2,
    output wire        bvalid_s_inf_inst_2,
    input wire         bready_s_inf_inst_2,

    //===== AXI-4 Data DRAM =====
    input wire [3:0]   arid_s_inf_data,
    input wire [31:0]  araddr_s_inf_data,
    input wire [6:0]   arlen_s_inf_data,
    input wire [2:0]   arsize_s_inf_data,
    input wire [1:0]   arburst_s_inf_data,
    input wire         arvalid_s_inf_data,
    output wire        arready_s_inf_data,
    output wire [3:0]  rid_s_inf_data,
    output wire [15:0] rdata_s_inf_data,
    output wire [1:0]  rresp_s_inf_data,
    output wire        rlast_s_inf_data,
    output wire        rvalid_s_inf_data,
    input wire         rready_s_inf_data,
    input wire [3:0]   awid_s_inf_data,
    input wire [31:0]  awaddr_s_inf_data,
    input wire [2:0]   awsize_s_inf_data,
    input wire [1:0]   awburst_s_inf_data,
    input wire [6:0]   awlen_s_inf_data,
    input wire         awvalid_s_inf_data,
    output wire        awready_s_inf_data,
    input wire [15:0]  wdata_s_inf_data,
    input wire         wlast_s_inf_data,
    input wire         wvalid_s_inf_data,
    output wire        wready_s_inf_data,
    output wire [3:0]  bid_s_inf_data,
    output wire [1:0]  bresp_s_inf_data,
    output wire        bvalid_s_inf_data,
    input wire         bready_s_inf_data
);

//---------------------------------------------------------------------
//   PARAMETER & VARIABLES
//---------------------------------------------------------------------
parameter TOTAL_TEST_IC = 2000; 
parameter MAX_ERROR_PRINTS = 20;
parameter D_BURST_SIZE = 4;
localparam D_BLOCK_BIT = $clog2(D_BURST_SIZE);
parameter D_SRAM_DEPTH = 64; 
localparam D_INDEX_BIT = $clog2(D_SRAM_DEPTH);

integer ic_count = 0;
integer i;

// perf counter
integer total_cycles = 0;
integer c1_mem_access = 0, c1_mem_miss = 0;
integer c2_mem_access = 0, c2_mem_miss = 0;
integer c1_inst_miss = 0, c2_inst_miss = 0;
integer c1_load_cnt = 0, c1_store_cnt = 0;
integer c2_load_cnt = 0, c2_store_cnt = 0;

// PATTERN (Golden Model)
reg signed [15:0] gold_r1 [0:7];
reg signed [15:0] gold_r2 [0:7];
reg        [15:0] gold_pc1;
reg        [15:0] gold_pc2;
reg        [7:0]  gold_DRAM [0:65535];

// PATTERN (Golden Cache)
reg        gold_sram_valid [0:D_SRAM_DEPTH-1];
reg [15-D_INDEX_BIT-1:0] gold_sram_tag [0:D_SRAM_DEPTH-1];
reg [15:0] gold_sram_data  [0:D_SRAM_DEPTH-1];
// PATTERN 
reg [7:0] gold_inst1_DRAM [0:65535];
reg [7:0] gold_inst2_DRAM [0:65535];

// same addr Load/Store
reg [15:0] global_addr1;
reg [15:0] global_addr2;
reg global_is_ls1;
reg global_is_ls2;
integer same_addr_hazard_cnt = 0;

// Cache Miss AXI Snooping cnt
integer c1_i_miss = 0;
integer c2_i_miss = 0;
integer total_d_miss = 0;
integer c1_d_miss_approx = 0;
integer c2_d_miss_approx = 0;

//---------------------------------------------------------------------
//   CLOCK & RESET & DRAM INITIALIZATION
//---------------------------------------------------------------------
initial clk = 0;
always #(`CYCLE_TIME/2.0) clk = ~clk;

initial begin
    rst_n = 1;
    force clk = 0;


    for (i = 0; i < 65536; i = i + 1) gold_DRAM[i] = 8'd0;
    for (i = 0; i < 8; i = i + 1) begin
        gold_r1[i] = 16'd0;
        gold_r2[i] = 16'd0;
    end
    gold_pc1 = 16'd0;
    gold_pc2 = 16'd0;
    
    // D_SRAM_DEPTH
    for (i = 0; i < D_SRAM_DEPTH; i = i + 1) begin
        gold_sram_valid[i] = 1'b0;
        gold_sram_tag[i]   = 0;
        gold_sram_data[i]  = 16'd0; 
    end

    // Verilog interior gen
    generate_and_output_dram_task();
    

    if (FLAG_GEN) begin
        // FAQ Q22 gen pass: three .dat files are on disk, exit at sim time 0.
        $display("GEN DONE: three .dat files written to ../00_TESTBED/DRAM/");
        $finish;
    end else begin
        $readmemh("../00_TESTBED/DRAM/inst_1_dram_file.dat", u_pseudo_DRAM_inst1.DRAM_r, 16'h0000);
        $readmemh("../00_TESTBED/DRAM/inst_2_dram_file.dat", u_pseudo_DRAM_inst2.DRAM_r, 16'h0000);
        $readmemh("../00_TESTBED/DRAM/data_dram_file.dat",   u_pseudo_DRAM_data.DRAM_r,  16'h1000);
        // ====================================================================
        // Reset check
        // ====================================================================
        #(`CYCLE_TIME); 
        rst_n = 0; // Reset
        
        // 3 Cycle
        #(`CYCLE_TIME*3);
        //$display(`CYCLE_TIME);
        //#(6); 

        // All stall signals should be one
        if (stall_1 !== 1'b1 || stall_2 !== 1'b1) begin
            $display("==================================================");
            $display(" [SPEC FAIL] stall signals must be 1 after reset asserts!");
            $display("   stall_1 = %b, stall_2 = %b", stall_1, stall_2);
            $display("==================================================");
            $finish;
        end

        // All registers of two cores should be zero
        if (TESTBED.u_DCCPU.core_1_r0 !== 16'd0 || TESTBED.u_DCCPU.core_1_r1 !== 16'd0 ||
            TESTBED.u_DCCPU.core_1_r2 !== 16'd0 || TESTBED.u_DCCPU.core_1_r3 !== 16'd0 ||
            TESTBED.u_DCCPU.core_1_r4 !== 16'd0 || TESTBED.u_DCCPU.core_1_r5 !== 16'd0 ||
            TESTBED.u_DCCPU.core_1_r6 !== 16'd0 || TESTBED.u_DCCPU.core_1_r7 !== 16'd0) begin
            $display("==================================================");
            $display("[SPEC FAIL] Core 1 registers are NOT zero after reset!");
            $display("==================================================");
            $finish;
        end

        if (TESTBED.u_DCCPU.core_2_r0 !== 16'd0 || TESTBED.u_DCCPU.core_2_r1 !== 16'd0 ||
            TESTBED.u_DCCPU.core_2_r2 !== 16'd0 || TESTBED.u_DCCPU.core_2_r3 !== 16'd0 ||
            TESTBED.u_DCCPU.core_2_r4 !== 16'd0 || TESTBED.u_DCCPU.core_2_r5 !== 16'd0 ||
            TESTBED.u_DCCPU.core_2_r6 !== 16'd0 || TESTBED.u_DCCPU.core_2_r7 !== 16'd0) begin
            $display("==================================================");
            $display("[SPEC FAIL] Core 2 registers are NOT zero after reset!");
            $display("==================================================");
            $finish;
        end

        // All D-flip-flop must be reset
        if (arvalid_s_inf_inst_1 !== 1'b0 || arvalid_s_inf_inst_1 !== 1'b0 || wvalid_s_inf_inst_1 !== 1'b0 ||
            arvalid_s_inf_inst_2 !== 1'b0 || awvalid_s_inf_inst_2 !== 1'b0 || wvalid_s_inf_inst_2 !== 1'b0 ||
            arvalid_s_inf_data !== 1'b0   || awvalid_s_inf_data !== 1'b0   || wvalid_s_inf_data !== 1'b0) begin
            $display("==================================================");
            $display("[SPEC FAIL] AXI output signals (DFFs) are NOT zero after reset!");
            $display("arvalid_s_inf_inst_1 = %b, awvalid_s_inf_inst_1 = %b, wvalid_s_inf_inst_1 = %b", arvalid_s_inf_inst_1,arvalid_s_inf_inst_1,wvalid_s_inf_inst_1);
            $display("arvalid_s_inf_inst_2 = %b, awvalid_s_inf_inst_2 = %b, wvalid_s_inf_inst_2 = %b", arvalid_s_inf_inst_2,arvalid_s_inf_inst_2,wvalid_s_inf_inst_2);
            $display("arvalid_s_inf_data = %b, awvalid_s_inf_data = %b, wvalid_s_inf_data = %b", arvalid_s_inf_data,arvalid_s_inf_data,wvalid_s_inf_data);
            $display("==================================================");
            $finish;
        end

        // ====================================================================
        // direct write again (protect IO race)
        // ====================================================================
        // 1. Instruction DRAM (0x0000 ~ 0x1FFF)
        /*for (i = 16'h0000; i < 16'h2000; i = i + 1) begin
            u_pseudo_DRAM_inst1.DRAM_r[i] = gold_inst1_DRAM[i];
            u_pseudo_DRAM_inst2.DRAM_r[i] = gold_inst2_DRAM[i];
        end
        
        // 2. Data DRAM (0x1000 ~ 0x2FFF)
        for (i = 16'h1000; i < 16'h3000; i = i + 1) begin
            u_pseudo_DRAM_data.DRAM_r[i]  = gold_DRAM[i];
        end*/
        
        // ====================================================================
        // ====================================================================

        #(`CYCLE_TIME);
        rst_n = 1; // release Reset
        
        #(`CYCLE_TIME*3); 
        release clk; // Clock
    end
end

//---------------------------------------------------------------------
//   INSTANTIATE TA'S PSEUDO DRAMs
//---------------------------------------------------------------------
pseudo_DRAM_inst1 u_pseudo_DRAM_inst1(
    .clk(clk), .rst_n(rst_n),
    .arid_s_inf(arid_s_inf_inst_1), .araddr_s_inf(araddr_s_inf_inst_1), .arlen_s_inf(arlen_s_inf_inst_1), .arsize_s_inf(arsize_s_inf_inst_1), .arburst_s_inf(arburst_s_inf_inst_1), .arvalid_s_inf(arvalid_s_inf_inst_1), .arready_s_inf(arready_s_inf_inst_1),
    .rid_s_inf(rid_s_inf_inst_1), .rdata_s_inf(rdata_s_inf_inst_1), .rresp_s_inf(rresp_s_inf_inst_1), .rlast_s_inf(rlast_s_inf_inst_1), .rvalid_s_inf(rvalid_s_inf_inst_1), .rready_s_inf(rready_s_inf_inst_1),
    .awid_s_inf(awid_s_inf_inst_1), .awaddr_s_inf(awaddr_s_inf_inst_1), .awsize_s_inf(awsize_s_inf_inst_1), .awburst_s_inf(awburst_s_inf_inst_1), .awlen_s_inf(awlen_s_inf_inst_1), .awvalid_s_inf(awvalid_s_inf_inst_1), .awready_s_inf(awready_s_inf_inst_1),
    .wdata_s_inf(wdata_s_inf_inst_1), .wlast_s_inf(wlast_s_inf_inst_1), .wvalid_s_inf(wvalid_s_inf_inst_1), .wready_s_inf(wready_s_inf_inst_1),
    .bid_s_inf(bid_s_inf_inst_1), .bresp_s_inf(bresp_s_inf_inst_1), .bvalid_s_inf(bvalid_s_inf_inst_1), .bready_s_inf(bready_s_inf_inst_1)
);
pseudo_DRAM_inst2 u_pseudo_DRAM_inst2(
    .clk(clk), .rst_n(rst_n),
    .arid_s_inf(arid_s_inf_inst_2), .araddr_s_inf(araddr_s_inf_inst_2), .arlen_s_inf(arlen_s_inf_inst_2), .arsize_s_inf(arsize_s_inf_inst_2), .arburst_s_inf(arburst_s_inf_inst_2), .arvalid_s_inf(arvalid_s_inf_inst_2), .arready_s_inf(arready_s_inf_inst_2),
    .rid_s_inf(rid_s_inf_inst_2), .rdata_s_inf(rdata_s_inf_inst_2), .rresp_s_inf(rresp_s_inf_inst_2), .rlast_s_inf(rlast_s_inf_inst_2), .rvalid_s_inf(rvalid_s_inf_inst_2), .rready_s_inf(rready_s_inf_inst_2),
    .awid_s_inf(awid_s_inf_inst_2), .awaddr_s_inf(awaddr_s_inf_inst_2), .awsize_s_inf(awsize_s_inf_inst_2), .awburst_s_inf(awburst_s_inf_inst_2), .awlen_s_inf(awlen_s_inf_inst_2), .awvalid_s_inf(awvalid_s_inf_inst_2), .awready_s_inf(awready_s_inf_inst_2),
    .wdata_s_inf(wdata_s_inf_inst_2), .wlast_s_inf(wlast_s_inf_inst_2), .wvalid_s_inf(wvalid_s_inf_inst_2), .wready_s_inf(wready_s_inf_inst_2),
    .bid_s_inf(bid_s_inf_inst_2), .bresp_s_inf(bresp_s_inf_inst_2), .bvalid_s_inf(bvalid_s_inf_inst_2), .bready_s_inf(bready_s_inf_inst_2)
);
pseudo_DRAM_data u_pseudo_DRAM_data(
    .clk(clk), .rst_n(rst_n),
    .arid_s_inf(arid_s_inf_data), .araddr_s_inf(araddr_s_inf_data), .arlen_s_inf(arlen_s_inf_data), .arsize_s_inf(arsize_s_inf_data), .arburst_s_inf(arburst_s_inf_data), .arvalid_s_inf(arvalid_s_inf_data), .arready_s_inf(arready_s_inf_data),
    .rid_s_inf(rid_s_inf_data), .rdata_s_inf(rdata_s_inf_data), .rresp_s_inf(rresp_s_inf_data), .rlast_s_inf(rlast_s_inf_data), .rvalid_s_inf(rvalid_s_inf_data), .rready_s_inf(rready_s_inf_data),
    .awid_s_inf(awid_s_inf_data), .awaddr_s_inf(awaddr_s_inf_data), .awsize_s_inf(awsize_s_inf_data), .awburst_s_inf(awburst_s_inf_data), .awlen_s_inf(awlen_s_inf_data), .awvalid_s_inf(awvalid_s_inf_data), .awready_s_inf(awready_s_inf_data),
    .wdata_s_inf(wdata_s_inf_data), .wlast_s_inf(wlast_s_inf_data), .wvalid_s_inf(wvalid_s_inf_data), .wready_s_inf(wready_s_inf_data),
    .bid_s_inf(bid_s_inf_data), .bresp_s_inf(bresp_s_inf_data), .bvalid_s_inf(bvalid_s_inf_data), .bready_s_inf(bready_s_inf_data)
);


//---------------------------------------------------------------------
//   2 core Golden ALU 
//---------------------------------------------------------------------
task emulate_core1;
    reg [15:0] inst1;
    reg [2:0] op1, rs1, rt1, rd1, func1, rl1;
    reg signed [15:0] ext_imm1, rs_val1, rt_val1, alu1, mult_rl1;
    reg [15:0] next_pc1, addr1, base_addr1;
    reg wr_reg1, is_mult1, is_load1, is_store1;
begin
    inst1 = {u_pseudo_DRAM_inst1.DRAM_r[gold_pc1+1], u_pseudo_DRAM_inst1.DRAM_r[gold_pc1]};
    op1 = inst1[15:13]; rs1 = inst1[12:10]; rt1 = inst1[9:7]; 
    rd1 = inst1[6:4]; func1 = inst1[3:1]; rl1 = inst1[3:1];
    ext_imm1 = {{9{inst1[6]}}, inst1[6:0]};
    rs_val1 = gold_r1[rs1]; rt_val1 = gold_r1[rt1];
    
    wr_reg1 = 0; is_mult1 = 0; is_load1 = 0; is_store1 = 0;
    next_pc1 = gold_pc1 + 2; addr1 = 0; alu1 = 0; mult_rl1 = 0;

    //$display(" ");
    case(op1)
        3'b000: begin wr_reg1 = 1;
            case(func1)
                3'b000: alu1 = rs_val1 + rt_val1;
                3'b001: alu1 = rs_val1 - rt_val1;
                3'b010: alu1 = rs_val1 & rt_val1;
                3'b011: alu1 = rs_val1 | rt_val1;
                3'b100: alu1 = ~(rs_val1 & rt_val1);
                3'b101: alu1 = ~(rs_val1 | rt_val1);
                3'b110: alu1 = rs_val1 ^ rt_val1;
                3'b111: alu1 = (rs_val1 < rt_val1) ? 16'd1 : 16'd0;
            endcase
            //$display("op1 = R_type");
        end
        3'b001: begin 
            wr_reg1 = 1; is_mult1 = 1; {alu1, mult_rl1} = rs_val1 * rt_val1; 
            //$display("op1 = mul"); 
        end
        3'b010: begin 
            wr_reg1 = 1; rd1 = rt1; alu1 = rs_val1 + ext_imm1; 
            //$display("op1 = addi"); 
        end
        3'b011: begin 
            wr_reg1 = 1; rd1 = rt1; alu1 = rs_val1 - ext_imm1; 
            //$display("op1 = subi"); 
        end
        3'b100: begin 
            wr_reg1 = 1; rd1 = rt1; is_load1 = 1; c1_load_cnt = c1_load_cnt + 1; addr1 = (rs_val1 + ext_imm1) * 2 + 16'h1000; 
            //$display("op1 = load"); 
        end
        3'b101: begin 
            is_store1 = 1; c1_store_cnt = c1_store_cnt + 1; addr1 = (rs_val1 + ext_imm1) * 2 + 16'h1000; 
            //$display("op1 = store"); 
        end
        3'b110: begin 
            if (rs_val1 == rt_val1) next_pc1 = gold_pc1 + 2 + ext_imm1 * 2; 
            //$display("op1 = beq"); 
        end
        3'b111: begin 
            //next_pc1 = {3'b000, inst1[12:0]} * 2; 
            next_pc1 = {3'b000, inst1[12:0]}; 
            //$display("op1 = jump");
        end
    endcase
    
    if (is_store1) begin
        //$display("store addr1 = %h", addr1);
        //$display("tag = %h", addr1[15:D_INDEX_BIT+1]);
        c1_mem_access = c1_mem_access + 1;
        gold_DRAM[addr1] = rt_val1[7:0]; gold_DRAM[addr1+1] = rt_val1[15:8];
        gold_sram_valid[addr1[D_INDEX_BIT:1]] = 1'b1;
        gold_sram_tag[addr1[D_INDEX_BIT:1]]   = addr1[15:D_INDEX_BIT+1];
        gold_sram_data[addr1[D_INDEX_BIT:1]]  = rt_val1;
    end
    if (is_load1) begin
        //$display("load addr1 = %h", addr1);
        c1_mem_access = c1_mem_access + 1;
        alu1 = {gold_DRAM[addr1+1], gold_DRAM[addr1]};
        if (!(gold_sram_valid[addr1[D_INDEX_BIT:1]] && gold_sram_tag[addr1[D_INDEX_BIT:1]] == addr1[15:D_INDEX_BIT+1])) begin
            c1_mem_miss = c1_mem_miss + 1;
            base_addr1 = {addr1[15:(D_BLOCK_BIT+1)], {(D_BLOCK_BIT+1){1'b0}}};
            for (i = 0; i < D_BURST_SIZE; i = i + 1) begin
                gold_sram_valid[{addr1[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}] = 1'b1;
                gold_sram_tag[{addr1[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}]   = addr1[15:D_INDEX_BIT+1];
                gold_sram_data[{addr1[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}]  = {gold_DRAM[base_addr1 + i*2 + 1], gold_DRAM[base_addr1 + i*2]};
            end
        end
    end

    //$display("opcode=%d",op2);
    /*$display("core1 rs=%d", rs1);
    $display("core1 rt=%d", rt1);
    $display("rs_val1 = %d", $signed(rs_val1));
    $display("rt_val1 = %d", $signed(rt_val1));
    $display("next pc1=%h", next_pc1);*/

    if (wr_reg1) gold_r1[rd1] = alu1;
    if (is_mult1) gold_r1[rl1] = mult_rl1;
    gold_pc1 = next_pc1;

    //  L/S addr give to main loop
    global_addr1 = addr1;
    global_is_ls1 = (is_load1 | is_store1);
end endtask

task emulate_core2;
    reg [15:0] inst2;
    reg [2:0] op2, rs2, rt2, rd2, func2, rl2;
    reg signed [15:0] ext_imm2, rs_val2, rt_val2, alu2, mult_rl2;
    reg [15:0] next_pc2, addr2, base_addr2;
    reg wr_reg2, is_mult2, is_load2, is_store2;
begin
    inst2 = {u_pseudo_DRAM_inst2.DRAM_r[gold_pc2+1], u_pseudo_DRAM_inst2.DRAM_r[gold_pc2]};
    op2 = inst2[15:13]; rs2 = inst2[12:10]; rt2 = inst2[9:7]; 
    rd2 = inst2[6:4]; func2 = inst2[3:1]; rl2 = inst2[3:1];
    ext_imm2 = {{9{inst2[6]}}, inst2[6:0]};
    rs_val2 = gold_r2[rs2]; rt_val2 = gold_r2[rt2];
    
    wr_reg2 = 0; is_mult2 = 0; is_load2 = 0; is_store2 = 0;
    next_pc2 = gold_pc2 + 2; addr2 = 0; alu2 = 0; mult_rl2 = 0;

    //$display("");
    case(op2)
        3'b000: begin wr_reg2 = 1;
            case(func2)
                3'b000: alu2 = rs_val2 + rt_val2;
                3'b001: alu2 = rs_val2 - rt_val2;
                3'b010: alu2 = rs_val2 & rt_val2;
                3'b011: alu2 = rs_val2 | rt_val2;
                3'b100: alu2 = ~(rs_val2 & rt_val2);
                3'b101: alu2 = ~(rs_val2 | rt_val2);
                3'b110: alu2 = rs_val2 ^ rt_val2;
                3'b111: alu2 = (rs_val2 < rt_val2) ? 16'd1 : 16'd0;
            endcase
            //$display("op2 = R_type");
        end
        3'b001: begin 
            wr_reg2 = 1; is_mult2 = 1; {alu2, mult_rl2} = rs_val2 * rt_val2; //$display("op2 = mul"); 
        end
        3'b010: begin 
            wr_reg2 = 1; rd2 = rt2; alu2 = rs_val2 + ext_imm2;  //$display("op2 = addi");
        end
        3'b011: begin 
            wr_reg2 = 1; rd2 = rt2; alu2 = rs_val2 - ext_imm2; //$display("op2 = subi");
        end
        3'b100: begin 
            wr_reg2 = 1; rd2 = rt2; is_load2 = 1; c2_load_cnt = c2_load_cnt + 1; addr2 = (rs_val2 + ext_imm2) * 2 + 16'h1000;  //$display("op2 = load");
        end
        3'b101: begin 
            is_store2 = 1; c2_store_cnt = c2_store_cnt + 1; addr2 = (rs_val2 + ext_imm2) * 2 + 16'h1000; //$display("op2 = store"); 
        end
        3'b110: begin 
            if (rs_val2 == rt_val2) next_pc2 = gold_pc2 + 2 + ext_imm2 * 2; //$display("op2 = beq"); 
        end
        3'b111: begin 
            //next_pc2 = {3'b000, inst2[12:0]} * 2; 
            next_pc2 = {3'b000, inst2[12:0]};
            //$display("op2 = jump");
        end
    endcase
    
    if (is_store2) begin
        c2_mem_access = c2_mem_access + 1;
        gold_DRAM[addr2] = rt_val2[7:0]; gold_DRAM[addr2+1] = rt_val2[15:8];
        gold_sram_valid[addr2[D_INDEX_BIT:1]] = 1'b1;
        gold_sram_tag[addr2[D_INDEX_BIT:1]]   = addr2[15:D_INDEX_BIT+1];
        gold_sram_data[addr2[D_INDEX_BIT:1]]  = rt_val2;
    end
    if (is_load2) begin
        c2_mem_access = c2_mem_access + 1;
        alu2 = {gold_DRAM[addr2+1], gold_DRAM[addr2]};
        if (!(gold_sram_valid[addr2[D_INDEX_BIT:1]] && gold_sram_tag[addr2[D_INDEX_BIT:1]] == addr2[15:D_INDEX_BIT+1])) begin
            c2_mem_miss = c2_mem_miss + 1;
            base_addr2 = {addr2[15:(D_BLOCK_BIT+1)], {(D_BLOCK_BIT+1){1'b0}}};
            for (i = 0; i < D_BURST_SIZE; i = i + 1) begin
                gold_sram_valid[{addr2[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}] = 1'b1;
                gold_sram_tag[{addr2[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}]   = addr2[15:D_INDEX_BIT+1];
                gold_sram_data[{addr2[D_INDEX_BIT:(D_BLOCK_BIT+1)], i[D_BLOCK_BIT-1:0]}]  = {gold_DRAM[base_addr2 + i*2 + 1], gold_DRAM[base_addr2 + i*2]};
            end
        end
    end

    //$display("opcode=%d",op2);
    /*$display("core2 rs=%d", rs2);
    $display("core2 rt=%d", rt2);
    $display("rs_val2 = %d", $signed(rs_val2));
    $display("rt_val2 = %d", $signed(rt_val2));
    $display("next pc2=%h", next_pc2);*/

    if (wr_reg2) gold_r2[rd2] = alu2;
    if (is_mult2) gold_r2[rl2] = mult_rl2;
    gold_pc2 = next_pc2;

    // Core 2  L/S addr give to main loop
    global_addr2 = addr2;
    global_is_ls2 = (is_load2 | is_store2);
end endtask



//---------------------------------------------------------------------
//   MAIN TEST LOGIC & INDEPENDENT STALL MONITOR
//---------------------------------------------------------------------
integer ic_count_1 = 0;
integer ic_count_2 = 0;
integer latency_cnt_1 = 0;
integer latency_cnt_2 = 0;

reg [15:0] current_pc1;
reg [15:0] current_pc2;


integer random_max_ic;

initial begin
    // 500 ~ 2500: (Forced Halt)
    // 2500 ~ 4500: (Natural Halt)
    random_max_ic = 5000; 
    //$urandom_range(3000, 4500); 
end

// --- current step reg answer ---
integer emulated_ic = 0;
reg [15:0] c1_core_reg [0:7];
reg [15:0] c2_core_reg [0:7];
reg [15:0] core_pc1;
reg [15:0] core_pc2;
// 
reg c1_done;
reg c2_done;


always @(negedge clk) begin
    if (rst_n) begin
        // --- AXI Bus Snooping:  Cache Miss  ---
        if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1) c1_i_miss = c1_i_miss + 1;
        if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2) c2_i_miss = c2_i_miss + 1;
        // ar (ask data from dram) real Cache Miss
        if (arvalid_s_inf_data && arready_s_inf_data) total_d_miss = total_d_miss + 1;
        

        // Who done in this Cycle
        c1_done = (stall_1 === 1'b0 && gold_pc1 < 16'h2000);
        c2_done = (stall_2 === 1'b0 && gold_pc2 < 16'h2000);

        if (c1_done || c2_done) begin
            
            // =========================================================
            // (Anti-Cheat)
            // Core 1(N) has to execute before Core 2(N+1) ->
            // =========================================================
            if (c1_done && ic_count_1 > ic_count_2) begin
                $display("\n==================================================");
                $display(" [FAIL] Core 1 early run (Execution Order Violation)!");
                $display("   Core 1 about finish IC=%0d, but Core 2 stuck at IC=%0d", ic_count_1, ic_count_2);
                $display("==================================================");
                $finish;
            end
            if (c2_done && ic_count_2 > ic_count_1) begin
                $display("\n==================================================");
                $display(" [FAIL] Core 2 early run (Execution Order Violation)!");
                $display("   Core 2 about finish IC=%0d, but Core 1 stuck at IC=%0d", ic_count_2, ic_count_1);
                $display("==================================================");
                $finish;
            end

            // =========================================================
            // Phase 1:  emulate_IC (any one Core enter new IC trigger)
            // =========================================================
            if (ic_count_1 == emulated_ic || ic_count_2 == emulated_ic) begin
                
                core_pc1 = gold_pc1;
                core_pc2 = gold_pc2;

                // consider Dependency (Store-before-Load priority)  golden_reg
                if (u_pseudo_DRAM_inst1.DRAM_r[gold_pc1+1][7:5] == 3'b100 && 
                    u_pseudo_DRAM_inst2.DRAM_r[gold_pc2+1][7:5] == 3'b101) begin
                    emulate_core2(); emulate_core1();
                end else if (u_pseudo_DRAM_inst1.DRAM_r[gold_pc1+1][7:5] == 3'b101 && 
                             u_pseudo_DRAM_inst2.DRAM_r[gold_pc2+1][7:5] == 3'b100) begin
                    emulate_core1(); emulate_core2();
                end else begin
                    emulate_core1(); emulate_core2();
                end

                if (global_is_ls1 && global_is_ls2 && (global_addr1 == global_addr2)) begin
                    same_addr_hazard_cnt = same_addr_hazard_cnt + 1;
                end

                // golden_reg store to 1 core_reg
                c1_core_reg[0] = gold_r1[0]; c1_core_reg[1] = gold_r1[1]; c1_core_reg[2] = gold_r1[2]; c1_core_reg[3] = gold_r1[3];
                c1_core_reg[4] = gold_r1[4]; c1_core_reg[5] = gold_r1[5]; c1_core_reg[6] = gold_r1[6]; c1_core_reg[7] = gold_r1[7];
                
                c2_core_reg[0] = gold_r2[0]; c2_core_reg[1] = gold_r2[1]; c2_core_reg[2] = gold_r2[2]; c2_core_reg[3] = gold_r2[3];
                c2_core_reg[4] = gold_r2[4]; c2_core_reg[5] = gold_r2[5]; c2_core_reg[6] = gold_r2[6]; c2_core_reg[7] = gold_r2[7];

                emulated_ic = emulated_ic + 1;
            end

            // =========================================================
            // Phase 2: check ans (check see golden_reg)
            // =========================================================
            if (c1_done) begin
                // core_reg dump to golden_reg, check_task dont need to change
                gold_r1[0] = c1_core_reg[0]; gold_r1[1] = c1_core_reg[1]; gold_r1[2] = c1_core_reg[2]; gold_r1[3] = c1_core_reg[3];
                gold_r1[4] = c1_core_reg[4]; gold_r1[5] = c1_core_reg[5]; gold_r1[6] = c1_core_reg[6]; gold_r1[7] = c1_core_reg[7];
                /*$display("IC=%d",emulated_ic);
                for (integer m = 0 ; m < 8 ; m = m + 1 ) begin
                    $display("c1_core_reg[%d] = %d", m,$signed(c1_core_reg[m]));
                end*/
                check_core1_regs_task(core_pc1, ic_count_1);
                ic_count_1 = ic_count_1 + 1;
                latency_cnt_1 = 0;
            end
            
            if (c2_done) begin
                /*$display("IC=%d",emulated_ic);
                for (integer m = 0 ; m < 8 ; m = m + 1 ) begin
                    $display("c2_core_reg[%d] = %d", m,$signed(c2_core_reg[m]));
                end*/
                gold_r2[0] = c2_core_reg[0]; gold_r2[1] = c2_core_reg[1]; gold_r2[2] = c2_core_reg[2]; gold_r2[3] = c2_core_reg[3];
                gold_r2[4] = c2_core_reg[4]; gold_r2[5] = c2_core_reg[5]; gold_r2[6] = c2_core_reg[6]; gold_r2[7] = c2_core_reg[7];

                check_core2_regs_task(core_pc2, ic_count_2);
                ic_count_2 = ic_count_2 + 1;
                latency_cnt_2 = 0;
            end

            // =========================================================
            // Phase 3: same IC check DRAM (slower one stall=0)
            // =========================================================
            // when ic_count_1 == ic_count_2, means the later one has just finished
            if (ic_count_1 > 0 && ic_count_1 == ic_count_2) begin
                check_sram_and_dram_task(1, core_pc1, ic_count_1-1);
            end
        end

        // --- Timeout  (early finished Core not counted) ---
        if (gold_pc1 < 16'h2000 && stall_1 !== 1'b0) latency_cnt_1 = latency_cnt_1 + 1;
        if (gold_pc2 < 16'h2000 && stall_2 !== 1'b0) latency_cnt_2 = latency_cnt_2 + 1;

        if (latency_cnt_1 >= `MAX_WAIT_READY_CYCLE || latency_cnt_2 >= `MAX_WAIT_READY_CYCLE) begin
            $display("\n=========================================================");
            $display("LATENCY TIMEOUT");
            $finish;
        end

        // =====================================================================
        // natural reache end (>= 0x2000) or force halt (>= random_max_ic)
        // =====================================================================
        if ((gold_pc1 >= 16'h2000 && gold_pc2 >= 16'h2000) || 
            (ic_count_1 >= random_max_ic || ic_count_2 >= random_max_ic)) begin
            
            $display("\n========================================");
            if (gold_pc1 >= 16'h2000 && gold_pc2 >= 16'h2000) begin
                $display(" [EXIT REASON] Natural Halt");
                $display("    Both cores successfully reached the end of instructions.");
            end else begin
                $display(" [EXIT REASON] Forced Halt (Killed by TA's rules)");
                $display("    Simulation terminated because random_max_ic limit was reached.");
                if (ic_count_1 >= random_max_ic) $display("    -> Core 1 hit Limit (%0d)", ic_count_1);
                if (ic_count_2 >= random_max_ic) $display("    -> Core 2 hit Limit (%0d)", ic_count_2);
            end
            $display("========================================");

            $display("[PASS] Every single instruction matched perfectly!");
            
            begin : PRINT_PERF_METRICS
                real avg_cycle;
                avg_cycle = total_cycles / ((ic_count_1 + ic_count_2) / 2.0); 
                
                // L/S percentage, estimate Core 1 Core 2 respective Data Miss
                c1_d_miss_approx = total_d_miss * (c1_load_cnt + c1_store_cnt) / (c1_load_cnt + c1_store_cnt + c2_load_cnt + c2_store_cnt + 1);
                c2_d_miss_approx = total_d_miss - c1_d_miss_approx;

                $display("\n========================================================");
                $display("                     ALL PASSED!                        ");
                $display("       Asymmetric Execution Successfully Verified!      ");
                $display("--------------------------------------------------------");
                $display("   [Overall]");
                $display("   IC1: %0d, IC2: %0d",ic_count_1,ic_count_2);
                $display("   Total Execution Cycles : %0d", total_cycles);
                $display("   Average Cycles per IC  : %.2f\n", avg_cycle);
                
                $display("   [Instruction Mix (Load/Store Ratio)]");
                $display("   Core 1 L/S Count       : %4d (Load: %4d, Store: %4d, Ratio: %5.2f%%)", (c1_load_cnt + c1_store_cnt), c1_load_cnt, c1_store_cnt, ((c1_load_cnt + c1_store_cnt)*100.0)/ic_count_1);
                $display("   Core 2 L/S Count       : %4d (Load: %4d, Store: %4d, Ratio: %5.2f%%)\n", (c2_load_cnt + c2_store_cnt), c2_load_cnt, c2_store_cnt, ((c2_load_cnt + c2_store_cnt)*100.0)/ic_count_2);

                $display("   [Instruction Cache (I-Cache)]");
                $display("   Core 1 Inst Access     : %4d (Miss: %4d, Rate: %5.2f%%)", ic_count_1, c1_i_miss, (c1_i_miss * 100.0) / ic_count_1);
                $display("   Core 2 Inst Access     : %4d (Miss: %4d, Rate: %5.2f%%)\n", ic_count_2, c2_i_miss, (c2_i_miss * 100.0) / ic_count_2);

                $display("   [Data Cache (D-Cache)]");
                $display("   Core 1 Data Access     : %4d (Miss: %4d, Rate: %5.2f%%)", (c1_load_cnt + c1_store_cnt), c1_d_miss_approx, (c1_d_miss_approx * 100.0) / (c1_load_cnt + c1_store_cnt + 1));
                $display("   Core 2 Data Access     : %4d (Miss: %4d, Rate: %5.2f%%)", (c2_load_cnt + c2_store_cnt), c2_d_miss_approx, (c2_d_miss_approx * 100.0) / (c2_load_cnt + c2_store_cnt + 1));
                $display("========================================================");
            end
            $finish;
        end
    end
end


//---------------------------------------------------------------------
//   AXI PROTOCOL LATENCY MONITOR & CYCLE COUNTER
//---------------------------------------------------------------------
integer wait_b_inst1, wait_r_inst1;
integer wait_b_inst2, wait_r_inst2;
integer wait_b_data,  wait_r_data;

always @(negedge clk) begin
    if (~rst_n) begin
        total_cycles = 0;
        wait_b_inst1 = 0; wait_r_inst1 = 0;
        wait_b_inst2 = 0; wait_r_inst2 = 0;
        wait_b_data  = 0; wait_r_data  = 0;
    end else begin
        total_cycles = total_cycles + 1;
        if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1) c1_inst_miss = c1_inst_miss + 1;
        if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2) c2_inst_miss = c2_inst_miss + 1;

        if (bvalid_s_inf_inst_1 && ~bready_s_inf_inst_1) wait_b_inst1 = wait_b_inst1 + 1; else wait_b_inst1 = 0;
        if (rvalid_s_inf_inst_1 && ~rready_s_inf_inst_1) wait_r_inst1 = wait_r_inst1 + 1; else wait_r_inst1 = 0;
        if (bvalid_s_inf_inst_2 && ~bready_s_inf_inst_2) wait_b_inst2 = wait_b_inst2 + 1; else wait_b_inst2 = 0;
        if (rvalid_s_inf_inst_2 && ~rready_s_inf_inst_2) wait_r_inst2 = wait_r_inst2 + 1; else wait_r_inst2 = 0;
        if (bvalid_s_inf_data && ~bready_s_inf_data) wait_b_data = wait_b_data + 1; else wait_b_data = 0;
        if (rvalid_s_inf_data && ~rready_s_inf_data) wait_r_data = wait_r_data + 1; else wait_r_data = 0;
        
        if (wait_b_inst1 > 300 || wait_r_inst1 > 300 ||
            wait_b_inst2 > 300 || wait_r_inst2 > 300 ||
            wait_b_data  > 300 || wait_r_data  > 300) begin
            $display("\n=========================================================");
            $display("[FAIL] AXI PROTOCOL TIMEOUT");
            $display("BVALID/BREADY or RVALID/RREADY latency exceeded 300 cycles!");
            $display("=========================================================\n");
            $finish;
        end
    end
end

//---------------------------------------------------------------------
//   TASKS  (Step-by-Step Checking)
//---------------------------------------------------------------------

task check_core1_regs_task;
    input [15:0] pc_val;
    input integer ic_val;
begin
    integer reg_err; reg_err = 0;
    if (TESTBED.u_DCCPU.core_1_r0 !== gold_r1[0]) begin $display(" [C1 REG ERROR] R0: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[0], TESTBED.u_DCCPU.core_1_r0, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r1 !== gold_r1[1]) begin $display(" [C1 REG ERROR] R1: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[1], TESTBED.u_DCCPU.core_1_r1, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r2 !== gold_r1[2]) begin $display(" [C1 REG ERROR] R2: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[2], TESTBED.u_DCCPU.core_1_r2, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r3 !== gold_r1[3]) begin $display(" [C1 REG ERROR] R3: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[3], TESTBED.u_DCCPU.core_1_r3, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r4 !== gold_r1[4]) begin $display(" [C1 REG ERROR] R4: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[4], TESTBED.u_DCCPU.core_1_r4, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r5 !== gold_r1[5]) begin $display(" [C1 REG ERROR] R5: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[5], TESTBED.u_DCCPU.core_1_r5, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r6 !== gold_r1[6]) begin $display(" [C1 REG ERROR] R6: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[6], TESTBED.u_DCCPU.core_1_r6, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_1_r7 !== gold_r1[7]) begin $display(" [C1 REG ERROR] R7: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r1[7], TESTBED.u_DCCPU.core_1_r7, pc_val, ic_val); reg_err=1; end
    if (reg_err) begin 
        $display("Error"); 
        $finish; 
    end;
end endtask

task check_core2_regs_task;
    input [15:0] pc_val;
    input integer ic_val;
begin
    integer reg_err; reg_err = 0;
    if (TESTBED.u_DCCPU.core_2_r0 !== gold_r2[0]) begin $display(" [C2 REG ERROR] R0: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[0], TESTBED.u_DCCPU.core_2_r0, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r1 !== gold_r2[1]) begin $display(" [C2 REG ERROR] R1: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[1], TESTBED.u_DCCPU.core_2_r1, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r2 !== gold_r2[2]) begin $display(" [C2 REG ERROR] R2: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[2], TESTBED.u_DCCPU.core_2_r2, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r3 !== gold_r2[3]) begin $display(" [C2 REG ERROR] R3: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[3], TESTBED.u_DCCPU.core_2_r3, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r4 !== gold_r2[4]) begin $display(" [C2 REG ERROR] R4: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[4], TESTBED.u_DCCPU.core_2_r4, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r5 !== gold_r2[5]) begin $display(" [C2 REG ERROR] R5: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[5], TESTBED.u_DCCPU.core_2_r5, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r6 !== gold_r2[6]) begin $display(" [C2 REG ERROR] R6: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[6], TESTBED.u_DCCPU.core_2_r6, pc_val, ic_val); reg_err=1; end
    if (TESTBED.u_DCCPU.core_2_r7 !== gold_r2[7]) begin $display(" [C2 REG ERROR] R7: Exp %04x, Got %04x (PC=%04x, IC=%0d)", gold_r2[7], TESTBED.u_DCCPU.core_2_r7, pc_val, ic_val); reg_err=1; end
    if (reg_err) begin 
        $display("Error"); 
        $finish; 
    end;
end endtask

task check_sram_and_dram_task;
    input integer core_id;
    input [15:0] pc_val;
    input integer ic_val;
begin
    integer idx;
    
`ifdef RTL    
    // 1. check SRAM
    for (idx = 0; idx < D_SRAM_DEPTH; idx = idx + 1) begin
        if (TESTBED.u_DCCPU.data_valid[idx] !== gold_sram_valid[idx]) begin
            $display("[SRAM ERROR] Core %0d at PC=%04x (IC=%0d)", core_id, pc_val, ic_val);
            $display("   SRAM Index %0d (0x%0x): Valid wrong. Exp=%b, Got=%b", idx, idx, gold_sram_valid[idx], TESTBED.u_DCCPU.data_valid[idx]);
            $finish;
        end
        if (gold_sram_valid[idx]) begin
            if (TESTBED.u_DCCPU.data_tag[idx] !== gold_sram_tag[idx]) begin
                $display(" [SRAM ERROR] Core %0d at PC=%04x (IC=%0d)", core_id, pc_val, ic_val);
                $display("   SRAM Index %0d (0x%0x): Tag wrong. Exp=%x, Got=%x", idx, idx, gold_sram_tag[idx], TESTBED.u_DCCPU.data_tag[idx]);
                $finish;
            end
            if (TESTBED.u_DCCPU.u_data.Memory[idx] !== gold_sram_data[idx]) begin
                $display("[SRAM ERROR] Core %0d at PC=%04x (IC=%0d)", core_id, pc_val, ic_val);
                $display("   SRAM Index %0d (0x%0x): interior data wrong. Exp=%04x, Got=%04x", idx, idx, gold_sram_data[idx], TESTBED.u_DCCPU.u_data.Memory[idx]);
                $finish;
            end
        end
    end
`endif

    // 2. check AXI data DRAM
    for (idx = 16'h1000; idx < 16'h3000; idx = idx + 1) begin
        if (u_pseudo_DRAM_data.DRAM_r[idx] !== gold_DRAM[idx]) begin
            $display("[DRAM ERROR] Core %0d at PC=%04x (IC=%0d)", core_id, pc_val, ic_val);
            $display("   DRAM Addr 0x%x: Expected %x, Got %x", idx, gold_DRAM[idx], u_pseudo_DRAM_data.DRAM_r[idx]);
            $display("Error");
            $finish;
        end
    end
end endtask


//---------------------------------------------------------------------
//   linked generater ( Golden Model Synced)
//         Data ±200 Bytes, Jump ±256 Bytes
//         (no same Store, MULT rd != rl)
//---------------------------------------------------------------------
task generate_and_output_dram_task; 
    integer idx, op_prob;
    integer gen_ic; 
    
    // =========================================================
    // sim state
    // =========================================================
    reg signed [15:0] sim_reg1 [0:7]; //
    integer pc1, next_pc1;
    reg visited1 [0:4095]; 
    
    reg signed [15:0] sim_reg2 [0:7];
    integer pc2, next_pc2;
    reg visited2 [0:4095];

    reg [7:0] sim_DRAM [0:65535];

    // =========================================================
    // instruction and reg
    // =========================================================
    reg [15:0] rand_inst1, rand_inst2;
    reg [2:0]  opcode1, opcode2;
    reg [2:0]  rs1, rt1, rd1, rl1, func1;
    reg [2:0]  rs2, rt2, rd2, rl2, func2;
    reg signed [6:0] imm1, imm2;
    reg [12:0] target1, target2;
    
    reg signed [15:0] ext_imm1, ext_imm2;
    reg signed [15:0] alu1, mult_rl1;
    reg signed [15:0] alu2, mult_rl2;
    reg [15:0] addr1, addr2;

    reg violation1, violation2;
    reg signed [15:0] rs_val1, rt_val1, rs_val2, rt_val2;

    // TA Locality Constraints
    integer last_data_addr1, last_data_addr2;
    integer t_min1, t_max1, i_min1, i_max1, tr_rs1, s_val1;
    integer t_min2, t_max2, i_min2, i_max2, tr_rs2, s_val2;
    reg ls_ok1, ls_ok2;
    integer j_min1, j_max1, offset1, found1;
    integer j_min2, j_max2, offset2, found2;

    integer c1_neg_cnt, c2_neg_cnt;
    integer MAX_IC = 1500;
begin
    $display("========================================");
    $display("   Generating LOCALITY-CONSTRAINED Trace... ");
    $display("   (Data: ±200 Bytes, Jump: ±256 Bytes)     ");
    $display("========================================");

    // initial
    /*for (idx = 0; idx < 65536; idx = idx + 2) begin
        gold_inst1_DRAM[idx]   = 8'h00; gold_inst1_DRAM[idx+1] = 8'hF0; 
        gold_inst2_DRAM[idx]   = 8'h00; gold_inst2_DRAM[idx+1] = 8'hF0;
        gold_DRAM[idx]         = 8'd0;  gold_DRAM[idx+1]       = 8'd0;
        sim_DRAM[idx]          = 8'd0;  sim_DRAM[idx+1]        = 8'd0;
    end*/
    // initial
    for (idx = 0; idx < 65536; idx = idx + 2) begin
        //8'h00
        gold_inst1_DRAM[idx]   = 8'h00; gold_inst1_DRAM[idx+1] = 8'h00; 
        gold_inst2_DRAM[idx]   = 8'h00; gold_inst2_DRAM[idx+1] = 8'h00;
        gold_DRAM[idx]         = 8'd0;  gold_DRAM[idx+1]       = 8'd0;
        sim_DRAM[idx]          = 8'd0;  sim_DRAM[idx+1]        = 8'd0;

        // clean pseudo_DRAM
        //u_pseudo_DRAM_inst1.DRAM_r[idx] = 8'h00; u_pseudo_DRAM_inst1.DRAM_r[idx+1] = 8'h00;
        //u_pseudo_DRAM_inst2.DRAM_r[idx] = 8'h00; u_pseudo_DRAM_inst2.DRAM_r[idx+1] = 8'h00;
    end
    // Data DRAM initial  0x1000 ~ 0x2FFF
    for (idx = 16'h1000; idx < 16'h3000; idx = idx + 1) begin
        gold_DRAM[idx] = $urandom_range(0, 255);
        // gen only positive
        //gold_DRAM[idx] = $urandom_range(0, 127);
        sim_DRAM[idx]  = gold_DRAM[idx]; 
        //u_pseudo_DRAM_data.DRAM_r[idx] = gold_DRAM[idx]; 
    end
    for (idx = 0; idx < 4096; idx = idx + 1) begin
        visited1[idx] = 0; visited2[idx] = 0;
    end
    // =========================================================
    // last address (1FFE / 2 = 4095) mark as visited
    // JUMP will not contaminated it, still keep ADD r0 r0 r0
    // =========================================================
    visited1[4095] = 1; 
    visited2[4095] = 1;
    for (idx = 0; idx < 8; idx = idx + 1) begin
        sim_reg1[idx] = 0; sim_reg2[idx] = 0;
    end

    last_data_addr1 = 16'h1000; last_data_addr2 = 16'h1000;

    // =========================================================
    // 2 core sync
    // =========================================================
    pc1 = 0; pc2 = 0;
    gen_ic = 0;
    c1_neg_cnt = 0; c2_neg_cnt = 0;
    
    while (gen_ic < MAX_IC) begin
        // 2 core both finished
        if (pc1 >= 16'h2000 && pc2 >= 16'h2000) begin
            gen_ic = MAX_IC; 
        end 
        else begin
            violation1 = 0; violation2 = 0;
            if (pc1 < 16'h2000) visited1[pc1/2] = 1;
            if (pc2 < 16'h2000) visited2[pc2/2] = 1;
            
            // ---------------------------------------------------------
            // random get instruction
            // ---------------------------------------------------------
            op_prob = $urandom_range(0, 99);
            if      (op_prob < 30) opcode1 = $urandom_range(0, 3); // 30% : ALU
            else if (op_prob < 75) opcode1 = $urandom_range(4, 5); // 45% : LOAD/STORE
            else if (op_prob < 90) opcode1 = 3'b110;               // 15% : BEQ
            else                   opcode1 = 3'b111;               // 10% : JUMP

            op_prob = $urandom_range(0, 99);
            if      (op_prob < 30) opcode2 = $urandom_range(0, 3); // 30% : ALU
            else if (op_prob < 75) opcode2 = $urandom_range(4, 5); // 45% : LOAD/STORE
            else if (op_prob < 90) opcode2 = 3'b110;               // 15% : BEQ
            else                   opcode2 = 3'b111;               // 10% : JUMP
            // AXI congest
            // ALU 5%, L/S 85%, BEQ 5%, JUMP 5%
            /*op_prob = $urandom_range(0, 99);
            if      (op_prob < 5)  opcode1 = $urandom_range(0, 3); // 5% : ALU
            else if (op_prob < 90) opcode1 = $urandom_range(4, 5); // 85% : LOAD/STORE
            else if (op_prob < 95) opcode1 = 3'b110;               // 5% : BEQ
            else                   opcode1 = 3'b111;               // 5% : JUMP
            
            op_prob = $urandom_range(0, 99);
            if      (op_prob < 5)  opcode2 = $urandom_range(0, 3);
            else if (op_prob < 90) opcode2 = $urandom_range(4, 5); // 85% : LOAD/STORE
            else if (op_prob < 95) opcode2 = 3'b110;
            else                   opcode2 = 3'b111;*/

            // jump
            // ALU 20%, L/S 20%, BEQ 30%, JUMP 30%
            /*op_prob = $urandom_range(0, 99);
            if      (op_prob < 20) opcode1 = $urandom_range(0, 3); // 20% : ALU
            else if (op_prob < 40) opcode1 = $urandom_range(4, 5); // 20% : LOAD/STORE
            else if (op_prob < 70) opcode1 = 3'b110;               // 30% : BEQ
            else                   opcode1 = 3'b111;               // 30% : JUMP
            
            op_prob = $urandom_range(0, 99);
            if      (op_prob < 20) opcode2 = $urandom_range(0, 3); 
            else if (op_prob < 40) opcode2 = $urandom_range(4, 5); 
            else if (op_prob < 70) opcode2 = 3'b110;               
            else                   opcode2 = 3'b111;*/

            // diff core
            // Core 1: jump (ALU 10%, L/S 0%, BEQ 45%, JUMP 45%)
            /*op_prob = $urandom_range(0, 99);
            if      (op_prob < 10) opcode1 = $urandom_range(0, 3); 
            else if (op_prob < 55) opcode1 = 3'b110;               
            else                   opcode1 = 3'b111;               
            // (Core 1 no L/S)

            // Core 2: load/s a lot (ALU 10%, L/S 90%, BEQ 0%, JUMP 0%)
            op_prob = $urandom_range(0, 99);
            if      (op_prob < 10)  opcode2 = $urandom_range(0, 3); 
            else                    opcode2 = $urandom_range(4, 5);*/


            // ALU 60%, L/S 25%, BEQ 10%, JUMP 5%
            /*op_prob = $urandom_range(0, 99);
            if      (op_prob < 50) opcode1 = $urandom_range(0, 3); // 60% : opcode 0~3 (R-Type, MULT, ADDI, SUBI)
            else if (op_prob < 75) opcode1 = $urandom_range(4, 5); // 25% : opcode 4~5 (LOAD, STORE)
            else if (op_prob < 88) opcode1 = 3'b110;               // 10% : opcode 6 (BEQ)
            else                   opcode1 = 3'b111;               //  5% : opcode 7 (JUMP)

            op_prob = $urandom_range(0, 99);
            if      (op_prob < 50) opcode2 = $urandom_range(0, 3); 
            else if (op_prob < 75) opcode2 = $urandom_range(4, 5); 
            else if (op_prob < 88) opcode2 = 3'b110;               
            else                   opcode2 = 3'b111;*/

            // spec 1: no both Store
            if (opcode1 == 3'b101 && opcode2 == 3'b101) opcode2 = 3'b100; 

            
            // 80%: in some reg (Data Hazard)
            // 20%: random
            if ($urandom_range(0, 99) < 80) begin
                // r0~r3
                rs1 = $urandom_range(0, 3); 
                rt1 = $urandom_range(0, 3); 
                rd1 = $urandom_range(0, 3);
            end else begin
                // r0~r7
                rs1 = $urandom_range(0, 7); 
                rt1 = $urandom_range(0, 7); 
                rd1 = $urandom_range(0, 7);
            end
            // random get R0~R7
            //rs1 = $urandom_range(0, 7); rt1 = $urandom_range(0, 7); rd1 = $urandom_range(0, 7); 
            rl1 = $urandom_range(0, 7); func1 = $urandom_range(0, 7);
            // spec 2: MULT  rd cant equal rl
            if (opcode1 == 3'b001) begin
                while (rd1 == rl1) rl1 = $urandom_range(0, 7); //
            end
            imm1 = $urandom_range(0, 127) - 64; 

            
            // Core 2 r4~r7
            if ($urandom_range(0, 99) < 80) begin
                // Core 2 r4~r7
                rs2 = $urandom_range(4, 7); 
                rt2 = $urandom_range(4, 7); 
                rd2 = $urandom_range(4, 7);
            end else begin
                rs2 = $urandom_range(0, 7); 
                rt2 = $urandom_range(0, 7); 
                rd2 = $urandom_range(0, 7);
            end
            //rs2 = $urandom_range(0, 7); rt2 = $urandom_range(0, 7); rd2 = $urandom_range(0, 7); 
            rl2 = $urandom_range(0, 7); func2 = $urandom_range(0, 7);
            // spec 2: MULT  rd cant equal rl
            if (opcode2 == 3'b001) begin
                while (rd2 == rl2) rl2 = $urandom_range(0, 7); //
            end
            imm2 = $urandom_range(0, 127) - 64; 


            // =========================================================
            // ★★★ [定向測資注入點 (Directed Tests)] ★★★
            // =========================================================

            // 💀 測資 1：終極連鎖相依 (Chain of RAW Hazards)
            if (gen_ic == 20) begin
                opcode1 = 3'b100; rt1 = 1; // Inst 1: LOAD 寫入 r1 (位址交給下方的 TA 邏輯自動保護)
            end else if (gen_ic == 21) begin
                opcode1 = 3'b000; func1 = 3'b000; rs1 = 1; rt1 = 1; rd1 = 2; // Inst 2: ADD r2, r1, r1 (需等 Inst 1)
            end else if (gen_ic == 22) begin
                opcode1 = 3'b011; rs1 = 2; rt1 = 2; imm1 = 5; // Inst 3: SUBI r2, 5 (需等 Inst 2)
            end else if (gen_ic == 23) begin
                opcode1 = 3'b110; rs1 = 2; rt1 = 3; imm1 = 2; // Inst 4: BEQ r2, r3 (需等 Inst 3)
            end

            // 🏎️🐢 測資 2：龜兔賽跑 (Asymmetric Execution) - 測試 S_WAIT_SYNC 屏障
            if (gen_ic >= 30 && gen_ic <= 34) begin
                opcode1 = 3'b000; func1 = 3'b000; // Core 1 瘋狂 1 拍 ADD
                opcode2 = 3'b101;                 // Core 2 瘋狂 300 拍 STORE
            end

            // 🌪️ 測資 3：管線塞車極限 (AXI Congestion)
            if (gen_ic == 50) begin
                opcode1 = 3'b100; opcode2 = 3'b000; // C1: LOAD,  C2: ADD
            end else if (gen_ic == 51) begin
                opcode1 = 3'b101; opcode2 = 3'b000; // C1: STORE, C2: ADD (緊接 LOAD 後的 AXI 競爭)
            end else if (gen_ic == 52) begin
                opcode1 = 3'b100; opcode2 = 3'b000; // C1: LOAD,  C2: ADD
            end

            // ⚔️ 測資 4：雙核記憶體黃金交叉 (Bypass 壓力測試)
            // 【終極修正版：不依賴 r0=0，動態計算保證相同位址】
            if (gen_ic == 60) begin
                opcode1 = 3'b101; rs1 = 0; rt1 = 1; // Core 1: STORE r1, offset1(r0)
                opcode2 = 3'b100; rs2 = 0; rt2 = 2; // Core 2: LOAD  r2, offset2(r0)
                
                // 為了確保寫入與讀取同一個位址，我們要讓 (sim_reg1[rs1] + imm1) == (sim_reg2[rs2] + imm2)
                // 我們隨便挑一個合法的 offset 目標 (例如 50)
                // 數學推導：目標值 = sim_reg1[0] + imm1 = 50  =>  imm1 = 50 - sim_reg1[0]
                imm1 = 50 - sim_reg1[0]; 
                imm2 = 50 - sim_reg2[0]; 
                
                // 防呆機制：確保算出來的 imm 沒有爆掉 (超過 7-bit signed: -64 ~ 63)
                // 如果爆了，我們就乾脆讓 imm1 = 0, imm2 = sim_reg1[0] - sim_reg2[0] (前提是差距不大)
                if (imm1 > 63 || imm1 < -64 || imm2 > 63 || imm2 < -64) begin
                     imm1 = 0;
                     imm2 = sim_reg1[0] - sim_reg2[0];
                end
            end

            // ---------------------------------------------------------
            // B: Core 1 locality protect (if not finished)
            // ---------------------------------------------------------
            if (pc1 < 16'h2000) begin
                rs_val1 = sim_reg1[rs1]; rt_val1 = sim_reg1[rt1];
                if (opcode1 == 3'b100 || opcode1 == 3'b101) begin
                    //t_min1 = last_data_addr1 - 200; if (t_min1 < 16'h1000) t_min1 = 16'h1000;
                    //t_max1 = last_data_addr1 + 200; if (t_max1 > 16'h2FFE) t_max1 = 16'h2FFE;
                    if ($urandom_range(0, 99) < 20) begin 
                        // 10% : global (D-Cache Miss)
                        t_min1 = 16'h1000;
                        t_max1 = 16'h2FFE;
                    end else begin
                        // 90% : ±200 local
                        t_min1 = last_data_addr1 - 200; if (t_min1 < 16'h1000) t_min1 = 16'h1000;
                        t_max1 = last_data_addr1 + 200; if (t_max1 > 16'h2FFE) t_max1 = 16'h2FFE;
                    end
                    ls_ok1 = 0;
                    
                    for (tr_rs1 = 0; tr_rs1 < 8; tr_rs1 = tr_rs1 + 1) begin
                        if (!ls_ok1) begin
                            s_val1 = {{16{sim_reg1[tr_rs1][15]}}, sim_reg1[tr_rs1]}; 
                            i_min1 = (t_min1 - 16'h1000)/2 - s_val1;
                            i_max1 = (t_max1 - 16'h1000)/2 - s_val1;
                            if (i_min1 < -64) i_min1 = -64;
                            if (i_max1 > 63)  i_max1 = 63;
                            
                            if (i_min1 <= i_max1) begin
                                rs1 = tr_rs1;
                                imm1 = i_min1 + $urandom_range(0, i_max1 - i_min1);
                                ext_imm1 = {{9{imm1[6]}}, imm1[6:0]}; 
                                addr1 = (sim_reg1[rs1] + ext_imm1) * 2 + 16'h1000;
                                if (addr1 >= 16'h1000 && addr1 <= 16'h2FFE) ls_ok1 = 1;
                            end
                        end
                    end
                    if (ls_ok1) last_data_addr1 = addr1; else violation1 = 1;
                end
                
                if (violation1) begin opcode1 = 3'b000; func1 = 3'b010; end
                
                // last IC, force to JUMP
                if (gen_ic >= MAX_IC - 1) opcode1 = 3'b111;

                rand_inst1 = (opcode1 == 3'b111) ? {3'b111, 13'd0} : {opcode1, rs1, rt1, imm1[6:0]}; 
                if (opcode1 == 3'b000) rand_inst1 = {3'b000, rs1, rt1, rd1, func1, 1'b0};
                if (opcode1 == 3'b001) rand_inst1 = {3'b001, rs1, rt1, rd1, rl1, 1'b0};

                ext_imm1 = {{9{imm1[6]}}, imm1[6:0]};
                if (opcode1 == 3'b110 && sim_reg1[rs1] == sim_reg1[rt1]) next_pc1 = pc1 + 2 + ext_imm1 * 2; else next_pc1 = pc1 + 2;
                
                if (opcode1 == 3'b111 || next_pc1 < 0 || next_pc1 >= 16'h2000 || visited1[next_pc1/2]) begin
                    
                    // last IC, JUMP force to jump to 0x2000
                    if (gen_ic >= MAX_IC - 1) begin
                        //opcode1 = 3'b111; rand_inst1 = {3'b111, 13'h1000}; next_pc1 = 16'h2000;
                        opcode1 = 3'b111; 
                        rand_inst1 = {3'b111, 13'h1FFE}; 
                        next_pc1 = 16'h2000;             // stop generate inst (avoid overwrite 1FFE)
                    end else begin
                        // find jump point
                        //j_min1 = (pc1 >= 256) ? (pc1 - 256)/2 : 0;
                        //j_max1 = (pc1 + 256 <= 8190) ? (pc1 + 256)/2 : 4095;
                        // global jump (0 ~ 4095)
                        j_min1 = 0;
                        j_max1 = 4095;
                        target1 = j_min1 + $urandom_range(0, j_max1 - j_min1);
                        found1 = 0;
                        for (offset1 = 0; offset1 <= 128; offset1 = offset1 + 1) begin
                            if (!found1 && target1 + offset1 <= j_max1 && !visited1[target1 + offset1]) begin target1 = target1 + offset1; found1 = 1; end
                            if (!found1 && target1 - offset1 >= j_min1 && !visited1[target1 - offset1]) begin target1 = target1 - offset1; found1 = 1; end
                        end
                        
                        // global search
                        if (!found1) begin
                            for (offset1 = 0; offset1 < 4096; offset1 = offset1 + 1) begin
                                if (!found1 && !visited1[offset1]) begin target1 = offset1; found1 = 1; end
                            end
                        end
                        
                        if (found1) begin
                            //opcode1 = 3'b111; rand_inst1 = {3'b111, target1[12:0]}; next_pc1 = target1 * 2;
                            opcode1 = 3'b111; 
                            next_pc1 = target1 * 2; 
                            rand_inst1 = {3'b111, next_pc1[12:0]}; // put * 2 after Byte Address
                        end else begin
                            // memory all full
                            opcode1 = 3'b111; 
                            rand_inst1 = {3'b111, 13'h1FFE}; 
                            next_pc1 = 16'h2000;             // stop generate inst (avoid overwrite 1FFE)
                        end
                    end
                end
            end else begin
                opcode1 = 3'b111; next_pc1 = 16'h2000; 
            end

            // ---------------------------------------------------------
            // C: Core 2 locality protect (if not finished)
            // ---------------------------------------------------------
            if (pc2 < 16'h2000) begin
                rs_val2 = sim_reg2[rs2]; rt_val2 = sim_reg2[rt2];
                if (opcode2 == 3'b100 || opcode2 == 3'b101) begin
                    //t_min2 = last_data_addr2 - 200; if (t_min2 < 16'h1000) t_min2 = 16'h1000;
                    //t_max2 = last_data_addr2 + 200; if (t_max2 > 16'h2FFE) t_max2 = 16'h2FFE;
                    if ($urandom_range(0, 99) < 20) begin 
                        // 10% : global D-Cache Miss)
                        t_min2 = 16'h1000;
                        t_max2 = 16'h2FFE;
                    end else begin
                        // 90% : ±200 local
                        t_min2 = last_data_addr2 - 200; if (t_min2 < 16'h1000) t_min2 = 16'h1000;
                        t_max2 = last_data_addr2 + 200; if (t_max2 > 16'h2FFE) t_max2 = 16'h2FFE;
                    end
                    ls_ok2 = 0;
                    
                    for (tr_rs2 = 0; tr_rs2 < 8; tr_rs2 = tr_rs2 + 1) begin
                        if (!ls_ok2) begin
                            s_val2 = {{16{sim_reg2[tr_rs2][15]}}, sim_reg2[tr_rs2]}; 
                            i_min2 = (t_min2 - 16'h1000)/2 - s_val2;
                            i_max2 = (t_max2 - 16'h1000)/2 - s_val2;
                            if (i_min2 < -64) i_min2 = -64;
                            if (i_max2 > 63)  i_max2 = 63;
                            
                            if (i_min2 <= i_max2) begin
                                rs2 = tr_rs2;
                                imm2 = i_min2 + $urandom_range(0, i_max2 - i_min2);
                                ext_imm2 = {{9{imm2[6]}}, imm2[6:0]};
                                addr2 = (sim_reg2[rs2] + ext_imm2) * 2 + 16'h1000;
                                if (addr2 >= 16'h1000 && addr2 <= 16'h2FFE) ls_ok2 = 1;
                            end
                        end
                    end
                    if (ls_ok2) last_data_addr2 = addr2; else violation2 = 1;
                end
                
                if (violation2) begin opcode2 = 3'b000; func2 = 3'b010; end
                
                // last IC, JUMP force to jump to 0x2000
                if (gen_ic >= MAX_IC - 1) opcode2 = 3'b111;

                rand_inst2 = (opcode2 == 3'b111) ? {3'b111, 13'd0} : {opcode2, rs2, rt2, imm2[6:0]}; 
                if (opcode2 == 3'b000) rand_inst2 = {3'b000, rs2, rt2, rd2, func2, 1'b0};
                if (opcode2 == 3'b001) rand_inst2 = {3'b001, rs2, rt2, rd2, rl2, 1'b0};

                ext_imm2 = {{9{imm2[6]}}, imm2[6:0]};
                if (opcode2 == 3'b110 && sim_reg2[rs2] == sim_reg2[rt2]) next_pc2 = pc2 + 2 + ext_imm2 * 2; else next_pc2 = pc2 + 2;
                
                if (opcode2 == 3'b111 || next_pc2 < 0 || next_pc2 >= 16'h2000 || visited2[next_pc2/2]) begin
                    
                    if (gen_ic >= MAX_IC - 1) begin
                        //opcode2 = 3'b111; rand_inst2 = {3'b111, 13'h1000}; next_pc2 = 16'h2000;
                        opcode2 = 3'b111; 
                        rand_inst2 = {3'b111, 13'h1FFE};
                        next_pc2 = 16'h2000;
                    end else begin
                        //j_min2 = (pc2 >= 256) ? (pc2 - 256)/2 : 0;
                        //j_max2 = (pc2 + 256 <= 8190) ? (pc2 + 256)/2 : 4095;
                        // global jump (0 ~ 4095)
                        j_min2 = 0;
                        j_max2 = 4095;
                        target2 = j_min2 + $urandom_range(0, j_max2 - j_min2);
                        found2 = 0;
                        for (offset2 = 0; offset2 <= 128; offset2 = offset2 + 1) begin
                            if (!found2 && target2 + offset2 <= j_max2 && !visited2[target2 + offset2]) begin target2 = target2 + offset2; found2 = 1; end
                            if (!found2 && target2 - offset2 >= j_min2 && !visited2[target2 - offset2]) begin target2 = target2 - offset2; found2 = 1; end
                        end
                        
                        if (!found2) begin
                            for (offset2 = 0; offset2 < 4096; offset2 = offset2 + 1) begin
                                if (!found2 && !visited2[offset2]) begin target2 = offset2; found2 = 1; end
                            end
                        end
                        
                        if (found2) begin
                            //opcode2 = 3'b111; rand_inst2 = {3'b111, target2[12:0]}; next_pc2 = target2 * 2;
                            opcode2 = 3'b111; 
                            next_pc2 = target2 * 2; 
                            rand_inst2 = {3'b111, next_pc2[12:0]}; //  Byte Address
                        end else begin
                            //opcode2 = 3'b111; rand_inst2 = {3'b111, 13'h1000}; next_pc2 = 16'h2000;
                            opcode2 = 3'b111; 
                            rand_inst2 = {3'b111, 13'h1FFE}; 
                            next_pc2 = 16'h2000;
                        end
                    end
                end
            end else begin
                opcode2 = 3'b111; next_pc2 = 16'h2000;
            end

            // =========================================================
            // D: write instruction and update sim dram  (non finished Core)
            // =========================================================
            rs_val1 = sim_reg1[rs1]; rt_val1 = sim_reg1[rt1];
            ext_imm1 = {{9{imm1[6]}}, imm1[6:0]};
            rs_val2 = sim_reg2[rs2]; rt_val2 = sim_reg2[rt2];
            ext_imm2 = {{9{imm2[6]}}, imm2[6:0]};

            if (pc1 < 16'h2000) begin
                gold_inst1_DRAM[pc1] = rand_inst1[7:0]; gold_inst1_DRAM[pc1+1] = rand_inst1[15:8];
                // feed to Core 1  pseudo_DRAM
                //u_pseudo_DRAM_inst1.DRAM_r[pc1] = rand_inst1[7:0]; 
                //u_pseudo_DRAM_inst1.DRAM_r[pc1+1] = rand_inst1[15:8];
                if (opcode1 == 3'b101) begin addr1 = (rs_val1 + ext_imm1) * 2 + 16'h1000; sim_DRAM[addr1] = sim_reg1[rt1][7:0]; sim_DRAM[addr1+1] = sim_reg1[rt1][15:8]; end
            end
            if (pc2 < 16'h2000) begin
                gold_inst2_DRAM[pc2] = rand_inst2[7:0]; gold_inst2_DRAM[pc2+1] = rand_inst2[15:8];
                // feed to Core 2  pseudo_DRAM
                //u_pseudo_DRAM_inst2.DRAM_r[pc2] = rand_inst2[7:0]; 
                //u_pseudo_DRAM_inst2.DRAM_r[pc2+1] = rand_inst2[15:8];
                if (opcode2 == 3'b101) begin addr2 = (rs_val2 + ext_imm2) * 2 + 16'h1000; sim_DRAM[addr2] = sim_reg2[rt2][7:0]; sim_DRAM[addr2+1] = sim_reg2[rt2][15:8]; end
            end

            if (pc1 < 16'h2000) begin
                if (opcode1 == 3'b000) begin
                    if (func1 == 3'b000) alu1 = rs_val1 + rt_val1; else if (func1 == 3'b001) alu1 = rs_val1 - rt_val1;
                    else if (func1 == 3'b010) alu1 = rs_val1 & rt_val1; else if (func1 == 3'b011) alu1 = rs_val1 | rt_val1;
                    else if (func1 == 3'b100) alu1 = ~(rs_val1 & rt_val1); else if (func1 == 3'b101) alu1 = ~(rs_val1 | rt_val1);
                    else if (func1 == 3'b110) alu1 = rs_val1 ^ rt_val1; else if (func1 == 3'b111) alu1 = (rs_val1 < rt_val1) ? 16'd1 : 16'd0;
                    sim_reg1[rd1] = alu1;
                end else if (opcode1 == 3'b001) begin {alu1, mult_rl1} = rs_val1 * rt_val1; sim_reg1[rd1] = alu1; sim_reg1[rl1] = mult_rl1;
                end else if (opcode1 == 3'b010) begin alu1 = rs_val1 + ext_imm1; sim_reg1[rt1] = alu1;
                end else if (opcode1 == 3'b011) begin alu1 = rs_val1 - ext_imm1; sim_reg1[rt1] = alu1;
                end else if (opcode1 == 3'b100) begin addr1 = (rs_val1 + ext_imm1) * 2 + 16'h1000; sim_reg1[rt1] = {sim_DRAM[addr1+1], sim_DRAM[addr1]}; end 
            end

            if (pc2 < 16'h2000) begin
                if (opcode2 == 3'b000) begin
                    if (func2 == 3'b000) alu2 = rs_val2 + rt_val2; else if (func2 == 3'b001) alu2 = rs_val2 - rt_val2;
                    else if (func2 == 3'b010) alu2 = rs_val2 & rt_val2; else if (func2 == 3'b011) alu2 = rs_val2 | rt_val2;
                    else if (func2 == 3'b100) alu2 = ~(rs_val2 & rt_val2); else if (func2 == 3'b101) alu2 = ~(rs_val2 | rt_val2);
                    else if (func2 == 3'b110) alu2 = rs_val2 ^ rt_val2; else if (func2 == 3'b111) alu2 = (rs_val2 < rt_val2) ? 16'd1 : 16'd0;
                    sim_reg2[rd2] = alu2;
                end else if (opcode2 == 3'b001) begin {alu2, mult_rl2} = rs_val2 * rt_val2; sim_reg2[rd2] = alu2; sim_reg2[rl2] = mult_rl2;
                end else if (opcode2 == 3'b010) begin alu2 = rs_val2 + ext_imm2; sim_reg2[rt2] = alu2;
                end else if (opcode2 == 3'b011) begin alu2 = rs_val2 - ext_imm2; sim_reg2[rt2] = alu2;
                end else if (opcode2 == 3'b100) begin addr2 = (rs_val2 + ext_imm2) * 2 + 16'h1000; sim_reg2[rt2] = {sim_DRAM[addr2+1], sim_DRAM[addr2]}; end 
            end
            
            /*if (gen_ic < 1500) begin
                if (opcode1 == 3'b000 && func1 == 3'b000 && alu1[15] == 1'b1) begin
                    $display("[IC=%3d] ADD neg computation: %6d = %6d + %6d  | Hex: %4h = %4h + %4h", 
                            gen_ic, 
                            $signed(alu1), $signed(rs_val1), $signed(rt_val1),
                            alu1, rs_val1, rt_val1);                           
                end
            end
            if (gen_ic < 100) begin
                if (opcode1 == 3'b001) begin
                    $display("[IC=%3d] MULT computation: %11d = %6d * %6d  | Hex: %8h = %4h * %4h", 
                            gen_ic, 
                            $signed({alu1, mult_rl1}), $signed(rs_val1), $signed(rt_val1), 
                            {alu1, mult_rl1}, rs_val1, rt_val1);                           
                end
            end*/

            // =========================================================
            // check Load/Store spacial locality
            // =========================================================
            /*if (1) begin // 50 IC gen_ic < 1000
                if (pc1 < 16'h2000 && (opcode1 == 3'b100 || opcode1 == 3'b101) && addr1 > 16'h2000) begin
                    $display("[IC=%3d] Core 1 %s | Hex: %4h | dec: %5d", 
                             gen_ic, (opcode1 == 3'b100) ? "LOAD " : "STORE", addr1, addr1);
                end
                
                if (pc2 < 16'h2000 && (opcode2 == 3'b100 || opcode2 == 3'b101) && addr2 > 16'h2000) begin
                    $display("[IC=%3d] Core 2 %s | Hex: %4h | dec: %5d", 
                             gen_ic, (opcode2 == 3'b100) ? "LOAD " : "STORE", addr2, addr2);
                end
            end*/
            if (1) begin 
                // Core 1 check
                if (pc1 < 16'h2000 && (opcode1 == 3'b100 || opcode1 == 3'b101)) begin
                    if (addr1 == 16'h2ffe) begin
                        $display("[BOUNDARY_HIT_2FFE] Core 1 %s | IC: %3d", (opcode1 == 3'b100) ? "LOAD " : "STORE", gen_ic);
                    end
                    // lower bound 1000
                    if (addr1 == 16'h1000) begin
                        $display("[BOUNDARY_HIT_1000] Core 1 %s | IC: %3d", (opcode1 == 3'b100) ? "LOAD " : "STORE", gen_ic);
                    end
                end
                
                // Core 2 check
                if (pc2 < 16'h2000 && (opcode2 == 3'b100 || opcode2 == 3'b101)) begin
                    if (addr2 == 16'h2ffe) begin
                        $display("[BOUNDARY_HIT_2FFE] Core 2 %s | IC: %3d", (opcode2 == 3'b100) ? "LOAD " : "STORE", gen_ic);
                    end
                    // lower bound 1000
                    if (addr2 == 16'h1000) begin
                        $display("[BOUNDARY_HIT_1000] Core 2 %s | IC: %3d", (opcode2 == 3'b100) ? "LOAD " : "STORE", gen_ic);
                    end
                end
            end
            
            if (opcode1 == 3'b000 || opcode1 == 3'b010 || opcode1 == 3'b011) begin
                if (alu1[15] == 1'b1) c1_neg_cnt = c1_neg_cnt + 1;
            end
            if (opcode2 == 3'b000 || opcode2 == 3'b010 || opcode2 == 3'b011) begin
                if (alu2[15] == 1'b1) c2_neg_cnt = c2_neg_cnt + 1;
            end

            pc1 = next_pc1; pc2 = next_pc2; gen_ic = gen_ic + 1;
        end
    end

    
    // write to dat
    /*$writememh("../00_TESTBED/DRAM/inst_1_dram_file.dat", gold_inst1_DRAM);
    $writememh("../00_TESTBED/DRAM/inst_2_dram_file.dat", gold_inst2_DRAM);
    $writememh("../00_TESTBED/DRAM/data_dram_file.dat",  gold_DRAM);*/
    $writememh("../00_TESTBED/DRAM/inst_1_dram_file.dat", gold_inst1_DRAM, 16'h0000, 16'h1FFF);
    $writememh("../00_TESTBED/DRAM/inst_2_dram_file.dat", gold_inst2_DRAM, 16'h0000, 16'h1FFF);
    
    // Data DRAM : 1000 to 2FFF
    $writememh("../00_TESTBED/DRAM/data_dram_file.dat",   gold_DRAM,       16'h1000, 16'h2FFF);
    
    $display("   Locality-Constrained Trace Generation Completed!  ");
    $display("========================================");
    $display("   [Signed Arithmetic Coverage]");
    $display("   Core 1 Negative ALU Results : %4d times", c1_neg_cnt);
    $display("   Core 2 Negative ALU Results : %4d times", c2_neg_cnt);
    $display("========================================");
end endtask


endmodule