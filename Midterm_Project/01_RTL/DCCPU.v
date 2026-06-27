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
//   File Name   : DCCPU.v
//   Module Name : DCCPU.v
//   Release version : V1.0
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module DCCPU(
// Input
    clk,
    rst_n,
// Output
    stall_1,
    stall_2,
//===== AXI-4 Instruction1 DRAM =====
    arid_m_inf_inst_1,
    araddr_m_inf_inst_1,
    arlen_m_inf_inst_1,
    arsize_m_inf_inst_1,
    arburst_m_inf_inst_1,
    arvalid_m_inf_inst_1,
    arready_m_inf_inst_1,

    rid_m_inf_inst_1,
    rdata_m_inf_inst_1,
    rresp_m_inf_inst_1,
    rlast_m_inf_inst_1,
    rvalid_m_inf_inst_1,
    rready_m_inf_inst_1,

    awid_m_inf_inst_1,
    awaddr_m_inf_inst_1,
    awsize_m_inf_inst_1,
    awburst_m_inf_inst_1,
    awlen_m_inf_inst_1,
    awvalid_m_inf_inst_1,
    awready_m_inf_inst_1,
                
    wdata_m_inf_inst_1,
    wlast_m_inf_inst_1,
    wvalid_m_inf_inst_1,
    wready_m_inf_inst_1,

    bid_m_inf_inst_1,
    bresp_m_inf_inst_1,
    bvalid_m_inf_inst_1,
    bready_m_inf_inst_1,
//===== AXI-4 Instruction2 DRAM =====
    arid_m_inf_inst_2,
    araddr_m_inf_inst_2,
    arlen_m_inf_inst_2,
    arsize_m_inf_inst_2,
    arburst_m_inf_inst_2,
    arvalid_m_inf_inst_2,
    arready_m_inf_inst_2,

    rid_m_inf_inst_2,
    rdata_m_inf_inst_2,
    rresp_m_inf_inst_2,
    rlast_m_inf_inst_2,
    rvalid_m_inf_inst_2,
    rready_m_inf_inst_2,

    awid_m_inf_inst_2,
    awaddr_m_inf_inst_2,
    awsize_m_inf_inst_2,
    awburst_m_inf_inst_2,
    awlen_m_inf_inst_2,
    awvalid_m_inf_inst_2,
    awready_m_inf_inst_2,
                
    wdata_m_inf_inst_2,
    wlast_m_inf_inst_2,
    wvalid_m_inf_inst_2,
    wready_m_inf_inst_2,

    bid_m_inf_inst_2,
    bresp_m_inf_inst_2,
    bvalid_m_inf_inst_2,
    bready_m_inf_inst_2,  
//===== AXI-4 Data DRAM =====
    arid_m_inf_data,
    araddr_m_inf_data,
    arlen_m_inf_data,
    arsize_m_inf_data,
    arburst_m_inf_data,
    arvalid_m_inf_data,
    arready_m_inf_data,

    rid_m_inf_data,
    rdata_m_inf_data,
    rresp_m_inf_data,
    rlast_m_inf_data,
    rvalid_m_inf_data,
    rready_m_inf_data,

    awid_m_inf_data,
    awaddr_m_inf_data,
    awsize_m_inf_data,
    awburst_m_inf_data,
    awlen_m_inf_data,
    awvalid_m_inf_data,
    awready_m_inf_data,
                
    wdata_m_inf_data,
    wlast_m_inf_data,
    wvalid_m_inf_data,
    wready_m_inf_data,

    bid_m_inf_data,
    bresp_m_inf_data,
    bvalid_m_inf_data,
    bready_m_inf_data
);
// Input port
input wire clk, rst_n;
// Output port
output reg  stall_1, stall_2;

parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

// AXI Interface wire connecttion for pseudo-DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/

//########################################### Instruction1 DRAM
// axi write addr channel 
// src master
output wire [ID_WIDTH-1:0]   awid_m_inf_inst_1; 
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_1;
output wire [2:0]            awsize_m_inf_inst_1; 
output wire [1:0]            awburst_m_inf_inst_1; 
output wire [BURST_LEN-1:0]  awlen_m_inf_inst_1;
output wire                  awvalid_m_inf_inst_1;
// src slave
input wire                   awready_m_inf_inst_1;
// -------------------------

// axi write data channel 
// src master
output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_1;
output wire                  wlast_m_inf_inst_1;
output wire                  wvalid_m_inf_inst_1;
// src slave
input wire                   wready_m_inf_inst_1;

// axi write resp channel 
// src slave
input wire  [ID_WIDTH-1:0] bid_m_inf_inst_1; 
input wire  [1:0]          bresp_m_inf_inst_1; 
input wire                 bvalid_m_inf_inst_1;
// src master 
output wire                bready_m_inf_inst_1;
// ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_1; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_1;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_1;
output wire [2:0]            arsize_m_inf_inst_1; 
output wire [1:0]            arburst_m_inf_inst_1; 
output wire                  arvalid_m_inf_inst_1;
// src slave
input wire                   arready_m_inf_inst_1;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_inst_1; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_inst_1;
input wire [1:0]            rresp_m_inf_inst_1; 
input wire                  rlast_m_inf_inst_1;
input wire                  rvalid_m_inf_inst_1;
// master
output wire                 rready_m_inf_inst_1;
// -----------------------------

//########################################### Instruction2 DRAM
// axi write addr channel 
// src master
output wire [ID_WIDTH-1:0]   awid_m_inf_inst_2; 
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_2;
output wire [2:0]            awsize_m_inf_inst_2; 
output wire [1:0]            awburst_m_inf_inst_2; 
output wire [BURST_LEN-1:0]  awlen_m_inf_inst_2;
output wire                  awvalid_m_inf_inst_2;
// src slave
input wire                   awready_m_inf_inst_2;
// -------------------------

// axi write data channel 
// src master
output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_2;
output wire                  wlast_m_inf_inst_2;
output wire                  wvalid_m_inf_inst_2;
// src slave
input wire                   wready_m_inf_inst_2;

// axi write resp channel 
// src slave
input wire  [ID_WIDTH-1:0] bid_m_inf_inst_2; 
input wire  [1:0]          bresp_m_inf_inst_2; 
input wire                 bvalid_m_inf_inst_2;
// src master 
output wire                bready_m_inf_inst_2;
// ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_inst_2; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_2;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_2;
output wire [2:0]            arsize_m_inf_inst_2; 
output wire [1:0]            arburst_m_inf_inst_2; 
output wire                  arvalid_m_inf_inst_2;
// src slave
input wire                   arready_m_inf_inst_2;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_inst_2; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_inst_2;
input wire [1:0]            rresp_m_inf_inst_2; 
input wire                  rlast_m_inf_inst_2;
input wire                  rvalid_m_inf_inst_2;
// master
output wire                 rready_m_inf_inst_2;
// -----------------------------

//########################################### Data DRAM 
// axi write addr channel 
// src master
output wire [ID_WIDTH-1:0]   awid_m_inf_data; 
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_data;
output wire [2:0]            awsize_m_inf_data; 
output wire [1:0]            awburst_m_inf_data; 
output wire [BURST_LEN-1:0]  awlen_m_inf_data;
output wire                  awvalid_m_inf_data;
// src slave
input wire                   awready_m_inf_data;
// -------------------------

// axi write data channel 
// src master
output wire [DATA_WIDTH-1:0] wdata_m_inf_data;
output wire                  wlast_m_inf_data;
output wire                  wvalid_m_inf_data;
// src slave
input wire                   wready_m_inf_data;

// axi write resp channel 
// src slave
input wire  [ID_WIDTH-1:0] bid_m_inf_data; 
input wire  [1:0]          bresp_m_inf_data; 
input wire                 bvalid_m_inf_data;
// src master 
output wire                bready_m_inf_data;
// ------------------------

// axi read addr channel 
// src master
output wire [ID_WIDTH-1:0]   arid_m_inf_data; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_data;
output wire [BURST_LEN-1:0]  arlen_m_inf_data;
output wire [2:0]            arsize_m_inf_data; 
output wire [1:0]            arburst_m_inf_data; 
output wire                  arvalid_m_inf_data;
// src slave
input wire                   arready_m_inf_data;
// ------------------------

// axi read data channel 
// slave
input wire [ID_WIDTH-1:0]   rid_m_inf_data; 
input wire [DATA_WIDTH-1:0] rdata_m_inf_data;
input wire [1:0]            rresp_m_inf_data; 
input wire                  rlast_m_inf_data;
input wire                  rvalid_m_inf_data;
// master
output wire                 rready_m_inf_data;
// -----------------------------
//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/
reg [15:0] core_1_r0, core_1_r1, core_1_r2, core_1_r3;
reg [15:0] core_1_r4, core_1_r5, core_1_r6, core_1_r7;
reg [15:0] core_2_r0, core_2_r1, core_2_r2, core_2_r3;
reg [15:0] core_2_r4, core_2_r5, core_2_r6, core_2_r7;
// -----------------------------

//###########################################
//
// Wrtie down your design below
//
//##################################################

parameter IDLE  = 4'd0, F1    = 4'd1, F2    = 4'd2,
             CHK   = 4'd3, IREQ  = 4'd4, IRD   = 4'd5, 
             DEC   = 4'd6, RDREG = 4'd7, EXE   = 4'd8, 
             MUL   = 4'd9, DREQ  = 4'd10, DWT   = 4'd11, WB    = 4'd12; 

wire [ID_WIDTH-1:0] awid_m_inf_inst_1;
wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_1;
wire [2:0] awsize_m_inf_inst_1;
wire [1:0] awburst_m_inf_inst_1;
wire [BURST_LEN-1:0] awlen_m_inf_inst_1;
wire awvalid_m_inf_inst_1;
wire [DATA_WIDTH-1:0] wdata_m_inf_inst_1;
wire wlast_m_inf_inst_1;
wire wvalid_m_inf_inst_1;
wire bready_m_inf_inst_1;
wire [ID_WIDTH-1:0] arid_m_inf_inst_1;
wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_1;
wire [BURST_LEN-1:0] arlen_m_inf_inst_1;
wire [2:0] arsize_m_inf_inst_1;
wire [1:0] arburst_m_inf_inst_1;
wire arvalid_m_inf_inst_1;
wire rready_m_inf_inst_1;

wire [ID_WIDTH-1:0] awid_m_inf_inst_2;
wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_2;
wire [2:0] awsize_m_inf_inst_2;
wire [1:0] awburst_m_inf_inst_2;
wire [BURST_LEN-1:0] awlen_m_inf_inst_2;
wire awvalid_m_inf_inst_2;
wire [DATA_WIDTH-1:0] wdata_m_inf_inst_2;
wire wlast_m_inf_inst_2;
wire wvalid_m_inf_inst_2;
wire bready_m_inf_inst_2;
wire [ID_WIDTH-1:0] arid_m_inf_inst_2;
wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_2;
wire [BURST_LEN-1:0] arlen_m_inf_inst_2;
wire [2:0] arsize_m_inf_inst_2;
wire [1:0] arburst_m_inf_inst_2;
wire arvalid_m_inf_inst_2;
wire rready_m_inf_inst_2;

wire [ID_WIDTH-1:0] awid_m_inf_data;
wire [ADDR_WIDTH-1:0] awaddr_m_inf_data;
wire [2:0] awsize_m_inf_data;
wire [1:0] awburst_m_inf_data;
wire [BURST_LEN-1:0] awlen_m_inf_data;
wire awvalid_m_inf_data;
wire [DATA_WIDTH-1:0] wdata_m_inf_data;
wire wlast_m_inf_data;
wire wvalid_m_inf_data;
wire bready_m_inf_data;
wire [ID_WIDTH-1:0] arid_m_inf_data;
wire [ADDR_WIDTH-1:0] araddr_m_inf_data;
wire [BURST_LEN-1:0] arlen_m_inf_data;
wire [2:0] arsize_m_inf_data;
wire [1:0] arburst_m_inf_data;
wire arvalid_m_inf_data;
wire rready_m_inf_data;


wire [31:0] inst_addr_1;
wire [31:0] inst_addr_2;

reg [3:0] c_st;
reg [3:0] n_st;
reg [15:0] prog_cnt1;
reg [15:0] prog_cnt2;
reg stop1;
reg stop2;
reg is_fst_c;
reg act_c;
reg exe_ph;
reg is_miss;

reg v1_0, v1_1, v1_2, v1_3;
reg [9:0] t1_0, t1_1, t1_2, t1_3;
reg v2_0, v2_1, v2_2, v2_3;
reg [9:0] t2_0, t2_1, t2_2, t2_3;

reg [15:0] ir1;
reg [15:0] ir2;
reg [2:0] b_cnt;
reg [15:0] d_addr;
reg [15:0] d_wdat;
reg [15:0] d_rdat;
reg f_ar;
reg f_aw;
reg f_w;

reg [15:0] pl_rs_v;
reg [15:0] pl_rt_v;
reg [15:0] pl_imm;
reg [15:0] pl_pc;
reg [2:0] pl_op;
reg [2:0] pl_fn;
reg [2:0] pl_rd;
reg [2:0] pl_rt;
reg [2:0] pl_rl;
reg [12:0] pl_j;
reg pl_alu;
reg pl_st;
reg pl_ld;
reg pl_mul;

reg act_c1;
reg act_c2;

wire [15:0] mem_do;
reg [15:0] mem_di;
reg [5:0] mem_a;
reg mem_we;

wire [15:0] run_ir;
wire [15:0] run_pc;
wire [15:0] act_r0, act_r1, act_r2, act_r3, act_r4, act_r5, act_r6, act_r7;
wire [15:0] v_rs_cur;
wire [15:0] v_rt_cur;
wire [2:0] dec_op, dec_rs, dec_rt, dec_rd, dec_fn, dec_rl;
wire [15:0] dec_imm;
wire [12:0] dec_j;
wire dec_is_alu, dec_is_st, dec_is_ld, dec_is_mul;
wire [15:0] alu_out;
wire [15:0] calc_addr;
wire [15:0] branch_tgt;
wire [15:0] nxt_pc;


wire [1:0] idx1;
wire [9:0] ct1;
wire h1_0;
wire h1_1;
wire h1_2;
wire h1_3;
wire h1_act;
wire hit1;
wire [1:0] idx2;
wire [9:0] ct2;
wire h2_0;
wire h2_1;
wire h2_2;
wire h2_3;
wire h2_act;
wire hit2;
wire mul_start;
wire mul_shift;
wire [31:0] mul_res;
wire [4:0] mul_step;
wire c2_wb_en;
wire alu_eq_flag;
wire [15:0] pl_pc_p2;
wire [15:0] wb_hi;
wire [15:0] wb_lo;
wire [2:0]  wb_dest;
wire        do_wb;
wire        c1_wb_en;
wire [31:0] mem_axi_addr;
wire core_halt;

//design 
assign awid_m_inf_inst_1 = 4'd0; 
assign awaddr_m_inf_inst_1 = 32'd0;
assign awsize_m_inf_inst_1 = 3'd0;
assign awburst_m_inf_inst_1 = 2'd0; 
assign awlen_m_inf_inst_1 = 7'd0; 
assign awvalid_m_inf_inst_1 = 1'b0;
assign wdata_m_inf_inst_1 = 16'd0;
assign wlast_m_inf_inst_1 = 1'b0; 
assign wvalid_m_inf_inst_1 = 1'b0; 
assign bready_m_inf_inst_1 = 1'b0;

assign awid_m_inf_inst_2 = 4'd0; 
assign awaddr_m_inf_inst_2 = 32'd0;
assign awsize_m_inf_inst_2 = 3'd0;
assign awburst_m_inf_inst_2 = 2'd0; 
assign awlen_m_inf_inst_2 = 7'd0; 
assign awvalid_m_inf_inst_2 = 1'b0;
assign wdata_m_inf_inst_2 = 16'd0;
assign wlast_m_inf_inst_2 = 1'b0; 
assign wvalid_m_inf_inst_2 = 1'b0; 
assign bready_m_inf_inst_2 = 1'b0;

assign arid_m_inf_inst_1 = 4'd0; 
assign arsize_m_inf_inst_1 = 3'b001;
assign arburst_m_inf_inst_1 = 2'b01;
assign arlen_m_inf_inst_1 = 7'd7; 

assign arid_m_inf_inst_2 = 4'd0; 
assign arsize_m_inf_inst_2 = 3'b001;
assign arburst_m_inf_inst_2 = 2'b01; 
assign arlen_m_inf_inst_2 = 7'd7;

assign awid_m_inf_data = 4'd0;
assign awsize_m_inf_data = 3'b001;
assign awburst_m_inf_data = 2'b01;
assign awlen_m_inf_data = 7'd0;
assign wlast_m_inf_data = 1'b1;
assign arid_m_inf_data = 4'd0; 
assign arsize_m_inf_data = 3'b001;
assign arburst_m_inf_data = 2'b01; 
assign arlen_m_inf_data = 7'd0;


assign idx1 = prog_cnt1[5:4];
assign ct1 = prog_cnt1[15:6];
assign h1_0 = v1_0 && (t1_0 == ct1);
assign h1_1 = v1_1 && (t1_1 == ct1);
assign h1_2 = v1_2 && (t1_2 == ct1);
assign h1_3 = v1_3 && (t1_3 == ct1);
assign h1_act = (idx1 == 2'd0 && h1_0) || (idx1 == 2'd1 && h1_1) ||
                (idx1 == 2'd2 && h1_2) || (idx1 == 2'd3 && h1_3);
assign hit1 = stop1 || h1_act;


assign idx2 = prog_cnt2[5:4];
assign ct2 = prog_cnt2[15:6];
assign h2_0 = v2_0 && (t2_0 == ct2);
assign h2_1 = v2_1 && (t2_1 == ct2);
assign h2_2 = v2_2 && (t2_2 == ct2);
assign h2_3 = v2_3 && (t2_3 == ct2);
assign h2_act = (idx2 == 2'd0 && h2_0) || (idx2 == 2'd1 && h2_1) ||
                (idx2 == 2'd2 && h2_2) || (idx2 == 2'd3 && h2_3);
assign hit2 = stop2 || h2_act;

assign run_ir = (act_c == 1'b0) ? ir1 : ir2;
assign run_pc = (act_c == 1'b0) ? prog_cnt1 : prog_cnt2;

assign act_r0 = (act_c == 1'b0) ? core_1_r0 : core_2_r0;
assign act_r1 = (act_c == 1'b0) ? core_1_r1 : core_2_r1;
assign act_r2 = (act_c == 1'b0) ? core_1_r2 : core_2_r2;
assign act_r3 = (act_c == 1'b0) ? core_1_r3 : core_2_r3;
assign act_r4 = (act_c == 1'b0) ? core_1_r4 : core_2_r4;
assign act_r5 = (act_c == 1'b0) ? core_1_r5 : core_2_r5;
assign act_r6 = (act_c == 1'b0) ? core_1_r6 : core_2_r6;
assign act_r7 = (act_c == 1'b0) ? core_1_r7 : core_2_r7;

assign v_rs_cur = (dec_rs == 3'd0) ? act_r0 : (dec_rs == 3'd1) ? act_r1 : 
                  (dec_rs == 3'd2) ? act_r2 : (dec_rs == 3'd3) ? act_r3 :
                  (dec_rs == 3'd4) ? act_r4 : (dec_rs == 3'd5) ? act_r5 : 
                  (dec_rs == 3'd6) ? act_r6 : act_r7;

assign v_rt_cur = (dec_rt == 3'd0) ? act_r0 : (dec_rt == 3'd1) ? act_r1 : 
                  (dec_rt == 3'd2) ? act_r2 : (dec_rt == 3'd3) ? act_r3 :
                  (dec_rt == 3'd4) ? act_r4 : (dec_rt == 3'd5) ? act_r5 : 
                  (dec_rt == 3'd6) ? act_r6 : act_r7;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) c_st <= IDLE;
    else        c_st <= n_st;
end

always @(*) begin
    n_st = c_st;
    case (c_st)
        IDLE:      n_st = F1;
        F1:        n_st = F2;
        F2:        n_st = CHK;
        CHK: begin
            if (!stop1 && !hit1)      n_st = IREQ;
            else if (!stop2 && !hit2) n_st = IREQ;
            else if (stop1 && stop2)  n_st = CHK;
            else                      n_st = DEC;
        end
        IREQ: begin
            if (!is_miss && (arready_m_inf_inst_1 || f_ar)) n_st = IRD;
            if (is_miss && (arready_m_inf_inst_2 || f_ar)) n_st = IRD;
        end
        IRD: begin
            if (!is_miss && rvalid_m_inf_inst_1 && rlast_m_inf_inst_1 && rready_m_inf_inst_1) n_st = F1;
            if (is_miss && rvalid_m_inf_inst_2 && rlast_m_inf_inst_2 && rready_m_inf_inst_2) n_st = F1;
        end
        DEC:       n_st = RDREG;
        RDREG:     n_st = EXE;    
        EXE: begin
            if (pl_mul)                  n_st = MUL;
            else if (pl_ld || pl_st)     n_st = DREQ;
            else                         n_st = WB;
        end
        MUL: begin
            if (pl_j == 13'd15)          n_st = WB; 
        end
        DREQ: begin
            if (pl_ld && ((arvalid_m_inf_data && arready_m_inf_data) || f_ar)) n_st = DWT;
            if (pl_st && ((awvalid_m_inf_data && awready_m_inf_data) || f_aw) && 
                         ((wvalid_m_inf_data && wready_m_inf_data) || f_w))   n_st = DWT;
        end
        DWT: begin
            if (pl_ld && rvalid_m_inf_data) n_st = WB;
            if (pl_st && bvalid_m_inf_data) n_st = WB;
        end
        WB: begin
            if (!exe_ph)  n_st = RDREG;
            else          n_st = F1;
        end
        default: n_st = IDLE;
    endcase
end

assign core_halt = (nxt_pc >= 16'h2000);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prog_cnt1 <= 16'd0;
        stop1 <= 1'b0;
    end 
    else if (c_st == IDLE) begin  
        prog_cnt1 <= 16'd0;
        stop1 <= 1'b0;
    end 
    else if (c_st == WB && act_c == 1'b0 && !stop1) begin
        prog_cnt1 <= nxt_pc;
        if (core_halt) stop1 <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        prog_cnt2 <= 16'd0;
        stop2 <= 1'b0;
    end 
    else if (c_st == IDLE) begin  
        prog_cnt2 <= 16'd0;
        stop2 <= 1'b0;
    end 
    else if (c_st == WB && act_c == 1'b1 && !stop2) begin
        prog_cnt2 <= nxt_pc;
        if (core_halt) stop2 <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        act_c1 <= 1'b0;
        act_c2 <= 1'b0;
    end 
    else if (c_st == IDLE) begin 
        act_c1 <= 1'b0;
        act_c2 <= 1'b0;
    end 
    else if (c_st == F1) begin 
        act_c1 <= !stop1;
        act_c2 <= !stop2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        stall_1 <= 1'b1;
        stall_2 <= 1'b1;
    end 
    else if (c_st == WB && exe_ph == 1'b1) begin 
        stall_1 <= act_c1 ? 1'b0 : 1'b1;
        stall_2 <= act_c2 ? 1'b0 : 1'b1;
    end 
    else begin
        stall_1 <= 1'b1; 
        stall_2 <= 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        is_fst_c <= 1'b0;
        act_c <= 1'b0;
        exe_ph <= 1'b0; 
        is_miss <= 1'b0;
    end 
    else if (c_st == IDLE) begin 
        is_fst_c <= 1'b0;
        act_c <= 1'b0;
        exe_ph <= 1'b0; 
        is_miss <= 1'b0;
    end 
    else begin
        if (c_st == CHK) begin
            is_miss <= (!stop1 && !hit1) ? 1'b0 : 1'b1;
        end 
        else if (c_st == DEC) begin
            exe_ph <= 1'b0;
            if (!stop1 && !stop2) begin
                if ((ir2[15:13] == 3'b101) && (ir1[15:13] != 3'b101)) begin
                    is_fst_c <= 1'b1;
                    act_c <= 1'b1;
                end 
                else begin
                    is_fst_c <= 1'b0;
                    act_c <= 1'b0;
                end
            end 
            else if (!stop1) begin 
                is_fst_c <= 1'b0;
                act_c <= 1'b0;
            end 
            else begin
                is_fst_c <= 1'b1;
                act_c <= 1'b1;
            end
        end 
        else if (c_st == WB && exe_ph == 1'b0) begin
            exe_ph <= 1'b1;
            act_c <= ~is_fst_c; 
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pl_rs_v <= 16'd0; pl_rt_v <= 16'd0; pl_imm <= 16'd0; pl_pc <= 16'd0;
        pl_op <= 3'd0; pl_fn <= 3'd0; pl_rd <= 3'd0; pl_rt <= 3'd0; pl_rl <= 3'd0;
        pl_alu <= 1'b0; pl_st <= 1'b0; pl_ld <= 1'b0; pl_mul <= 1'b0;
    end 
    else if (c_st == IDLE) begin 
        pl_rs_v <= 16'd0; pl_rt_v <= 16'd0; pl_imm <= 16'd0; pl_pc <= 16'd0;
        pl_op <= 3'd0; pl_fn <= 3'd0; pl_rd <= 3'd0; pl_rt <= 3'd0; pl_rl <= 3'd0;
        pl_alu <= 1'b0; pl_st <= 1'b0; pl_ld <= 1'b0; pl_mul <= 1'b0;
    end 
    else if (c_st == RDREG) begin
        pl_rs_v <= v_rs_cur; pl_rt_v <= v_rt_cur; pl_imm <= dec_imm; pl_pc <= run_pc;
        pl_op <= dec_op; pl_fn <= dec_fn; pl_rd <= dec_rd; pl_rt <= dec_rt; pl_rl <= dec_rl;
        if (act_c == 1'b0 ? stop1 : stop2) begin
            pl_alu <= 1'b0; pl_st <= 1'b0; pl_ld <= 1'b0; pl_mul <= 1'b0;
        end 
        else begin
            pl_alu <= dec_is_alu; pl_st <= dec_is_st; pl_ld <= dec_is_ld; pl_mul <= dec_is_mul;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ir1 <= 16'd0;
        ir2 <= 16'd0; 
        b_cnt <= 3'd0;
    end 
    else if (c_st == IDLE) begin 
        ir1 <= 16'd0;
        ir2 <= 16'd0; 
        b_cnt <= 3'd0;
    end 
    else begin
        if (c_st == F2) ir1 <= mem_do;
        if (c_st == CHK) ir2 <= mem_do;
        if (c_st == IREQ) b_cnt <= 3'd0;
        if (c_st == IRD) begin
            if (!is_miss && rvalid_m_inf_inst_1 && rready_m_inf_inst_1) b_cnt <= b_cnt + 3'd1;
            if (is_miss && rvalid_m_inf_inst_2 && rready_m_inf_inst_2) b_cnt <= b_cnt + 3'd1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        v1_0 <= 1'b0; v1_1 <= 1'b0; v1_2 <= 1'b0; v1_3 <= 1'b0;
        t1_0 <= 10'd0; t1_1 <= 10'd0; t1_2 <= 10'd0; t1_3 <= 10'd0;
    end 
    else if (c_st == IDLE) begin
        v1_0 <= 1'b0; v1_1 <= 1'b0; v1_2 <= 1'b0; v1_3 <= 1'b0;
        t1_0 <= 10'd0; t1_1 <= 10'd0; t1_2 <= 10'd0; t1_3 <= 10'd0;
    end 
    else if (c_st == IRD && !is_miss && rlast_m_inf_inst_1) begin
        if (idx1 == 2'd0) begin v1_0 <= 1'b1; t1_0 <= ct1; end
        if (idx1 == 2'd1) begin v1_1 <= 1'b1; t1_1 <= ct1; end
        if (idx1 == 2'd2) begin v1_2 <= 1'b1; t1_2 <= ct1; end
        if (idx1 == 2'd3) begin v1_3 <= 1'b1; t1_3 <= ct1; end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        v2_0 <= 1'b0; v2_1 <= 1'b0; v2_2 <= 1'b0; v2_3 <= 1'b0;
        t2_0 <= 10'd0; t2_1 <= 10'd0; t2_2 <= 10'd0; t2_3 <= 10'd0;
    end 
    else if (c_st == IDLE) begin
        v2_0 <= 1'b0; v2_1 <= 1'b0; v2_2 <= 1'b0; v2_3 <= 1'b0;
        t2_0 <= 10'd0; t2_1 <= 10'd0; t2_2 <= 10'd0; t2_3 <= 10'd0;
    end 
    else if (c_st == IRD && is_miss && rlast_m_inf_inst_2) begin
        if (idx2 == 2'd0) begin v2_0 <= 1'b1; t2_0 <= ct2; end
        if (idx2 == 2'd1) begin v2_1 <= 1'b1; t2_1 <= ct2; end
        if (idx2 == 2'd2) begin v2_2 <= 1'b1; t2_2 <= ct2; end
        if (idx2 == 2'd3) begin v2_3 <= 1'b1; t2_3 <= ct2; end
    end
end

always @(*) begin
    mem_we = 1'b0;
    mem_di = 16'd0; 
    mem_a = 6'd0;
    if (c_st == F1) mem_a = {1'b0, prog_cnt1[5:1]};
    else if (c_st == F2) mem_a = {1'b1, prog_cnt2[5:1]};
    else if (c_st == IRD) begin
        mem_a = {is_miss, (is_miss == 1'b0 ? prog_cnt1[5:4] : prog_cnt2[5:4]), b_cnt};
        if (!is_miss) begin mem_we = rvalid_m_inf_inst_1; mem_di = rdata_m_inf_inst_1; end 
        else begin mem_we = rvalid_m_inf_inst_2; mem_di = rdata_m_inf_inst_2; end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_addr <= 16'd0;
        d_wdat <= 16'd0; 
        d_rdat <= 16'd0;
    end 
    else if (c_st == IDLE) begin 
        d_addr <= 16'd0;
        d_wdat <= 16'd0; 
        d_rdat <= 16'd0;
    end 
    else begin
        if (c_st == EXE && (pl_ld || pl_st)) begin
            d_addr <= calc_addr;
            d_wdat <= pl_rt_v;
        end
        if (c_st == DWT && pl_ld && rvalid_m_inf_data) begin
            d_rdat <= rdata_m_inf_data;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        f_ar <= 1'b0;
        f_aw <= 1'b0; 
        f_w <= 1'b0;
    end 
    else if (c_st == IDLE) begin 
        f_ar <= 1'b0;
        f_aw <= 1'b0; 
        f_w <= 1'b0;
    end 
    else begin
        if (c_st == IREQ && !is_miss && arready_m_inf_inst_1) f_ar <= 1'b1;
        else if (c_st == IREQ && is_miss && arready_m_inf_inst_2) f_ar <= 1'b1;
        else if (c_st == DREQ && arready_m_inf_data) f_ar <= 1'b1;
        else if (c_st != IREQ && c_st != DREQ) f_ar <= 1'b0;

        if (c_st == DREQ && awready_m_inf_data) f_aw <= 1'b1;
        else if (c_st != DREQ) f_aw <= 1'b0;

        if (c_st == DREQ && wready_m_inf_data) f_w <= 1'b1;
        else if (c_st != DREQ) f_w <= 1'b0;
    end
end

assign inst_addr_1 = {16'd0, prog_cnt1[15:4], 4'd0};
assign inst_addr_2 = {16'd0, prog_cnt2[15:4], 4'd0};

assign araddr_m_inf_inst_1  = inst_addr_1;
assign arvalid_m_inf_inst_1 = (c_st == IREQ && !is_miss && !f_ar);
assign rready_m_inf_inst_1  = (c_st == IRD && !is_miss);

assign araddr_m_inf_inst_2  = inst_addr_2;
assign arvalid_m_inf_inst_2 = (c_st == IREQ && is_miss && !f_ar);
assign rready_m_inf_inst_2  = (c_st == IRD && is_miss);

assign mem_axi_addr = {16'd0, d_addr};

assign awaddr_m_inf_data  = mem_axi_addr;
assign wdata_m_inf_data   = d_wdat;

assign wvalid_m_inf_data  = (c_st == DREQ && pl_st && !f_w);
assign bready_m_inf_data  = (c_st == DWT && pl_st);

assign araddr_m_inf_data  = mem_axi_addr;

assign rready_m_inf_data  = (c_st == DWT && pl_ld);

assign awvalid_m_inf_data = (c_st == DREQ && pl_st && !f_aw && ((act_c == 0 && !stop1) || (act_c == 1 && !stop2)));
assign arvalid_m_inf_data = (c_st == DREQ && pl_ld && !f_ar && ((act_c == 0 && !stop1) || (act_c == 1 && !stop2)));
assign mul_start = (c_st == EXE) && pl_mul;
assign mul_shift = (c_st == MUL);

BOOTH_MULT u_mult (
    .clk(clk),
    .rst_n(rst_n),
    .clr(c_st == IDLE),
    .start(mul_start),
    .shift(mul_shift),
    .rs_v(pl_rs_v),
    .rt_v(pl_rt_v),
    .step_cnt(mul_step),
    .mult_final(mul_res)
);

always @(*) begin
    pl_j = {8'd0, mul_step};
end

assign wb_hi = pl_mul ? mul_res[31:16] : (pl_ld ? d_rdat : alu_out);
assign wb_lo = pl_mul ? mul_res[15:0]  : (pl_ld ? d_rdat : alu_out);
assign wb_dest = (pl_op == 3'b000) ? pl_rd : pl_rt;
assign do_wb = (pl_alu || pl_ld || pl_mul);
assign c1_wb_en = (c_st == WB && act_c == 1'b0 && !stop1 && do_wb);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_1_r0 <= 16'd0; core_1_r1 <= 16'd0; core_1_r2 <= 16'd0; core_1_r3 <= 16'd0;
        core_1_r4 <= 16'd0; core_1_r5 <= 16'd0; core_1_r6 <= 16'd0; core_1_r7 <= 16'd0;
    end 
    else if (c_st == IDLE || (stop1 && stop2)) begin 
        core_1_r0 <= 16'd0; core_1_r1 <= 16'd0; core_1_r2 <= 16'd0; core_1_r3 <= 16'd0;
        core_1_r4 <= 16'd0; core_1_r5 <= 16'd0; core_1_r6 <= 16'd0; core_1_r7 <= 16'd0;
    end 
    else if (c1_wb_en) begin
        if (pl_mul) begin 
            if (pl_rl == 3'd0) core_1_r0 <= wb_lo; else if (pl_rd == 3'd0) core_1_r0 <= wb_hi;
            if (pl_rl == 3'd1) core_1_r1 <= wb_lo; else if (pl_rd == 3'd1) core_1_r1 <= wb_hi;
            if (pl_rl == 3'd2) core_1_r2 <= wb_lo; else if (pl_rd == 3'd2) core_1_r2 <= wb_hi;
            if (pl_rl == 3'd3) core_1_r3 <= wb_lo; else if (pl_rd == 3'd3) core_1_r3 <= wb_hi;
            if (pl_rl == 3'd4) core_1_r4 <= wb_lo; else if (pl_rd == 3'd4) core_1_r4 <= wb_hi;
            if (pl_rl == 3'd5) core_1_r5 <= wb_lo; else if (pl_rd == 3'd5) core_1_r5 <= wb_hi;
            if (pl_rl == 3'd6) core_1_r6 <= wb_lo; else if (pl_rd == 3'd6) core_1_r6 <= wb_hi;
            if (pl_rl == 3'd7) core_1_r7 <= wb_lo; else if (pl_rd == 3'd7) core_1_r7 <= wb_hi;
        end 
        else begin 
            if (wb_dest == 3'd0) core_1_r0 <= wb_lo;
            if (wb_dest == 3'd1) core_1_r1 <= wb_lo;
            if (wb_dest == 3'd2) core_1_r2 <= wb_lo;
            if (wb_dest == 3'd3) core_1_r3 <= wb_lo;
            if (wb_dest == 3'd4) core_1_r4 <= wb_lo;
            if (wb_dest == 3'd5) core_1_r5 <= wb_lo;
            if (wb_dest == 3'd6) core_1_r6 <= wb_lo;
            if (wb_dest == 3'd7) core_1_r7 <= wb_lo;
        end
    end
end


assign c2_wb_en = (c_st == WB && act_c == 1'b1 && !stop2 && do_wb);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_2_r0 <= 16'd0; core_2_r1 <= 16'd0; core_2_r2 <= 16'd0; core_2_r3 <= 16'd0;
        core_2_r4 <= 16'd0; core_2_r5 <= 16'd0; core_2_r6 <= 16'd0; core_2_r7 <= 16'd0;
    end 
    else if (c_st == IDLE || (stop1 && stop2)) begin 
        core_2_r0 <= 16'd0; core_2_r1 <= 16'd0; core_2_r2 <= 16'd0; core_2_r3 <= 16'd0;
        core_2_r4 <= 16'd0; core_2_r5 <= 16'd0; core_2_r6 <= 16'd0; core_2_r7 <= 16'd0;
    end 
    else if (c2_wb_en) begin
        if (pl_mul) begin 
            if (pl_rl == 3'd0) core_2_r0 <= wb_lo; else if (pl_rd == 3'd0) core_2_r0 <= wb_hi;
            if (pl_rl == 3'd1) core_2_r1 <= wb_lo; else if (pl_rd == 3'd1) core_2_r1 <= wb_hi;
            if (pl_rl == 3'd2) core_2_r2 <= wb_lo; else if (pl_rd == 3'd2) core_2_r2 <= wb_hi;
            if (pl_rl == 3'd3) core_2_r3 <= wb_lo; else if (pl_rd == 3'd3) core_2_r3 <= wb_hi;
            if (pl_rl == 3'd4) core_2_r4 <= wb_lo; else if (pl_rd == 3'd4) core_2_r4 <= wb_hi;
            if (pl_rl == 3'd5) core_2_r5 <= wb_lo; else if (pl_rd == 3'd5) core_2_r5 <= wb_hi;
            if (pl_rl == 3'd6) core_2_r6 <= wb_lo; else if (pl_rd == 3'd6) core_2_r6 <= wb_hi;
            if (pl_rl == 3'd7) core_2_r7 <= wb_lo; else if (pl_rd == 3'd7) core_2_r7 <= wb_hi;
        end 
        else begin 
            if (wb_dest == 3'd0) core_2_r0 <= wb_lo;
            if (wb_dest == 3'd1) core_2_r1 <= wb_lo;
            if (wb_dest == 3'd2) core_2_r2 <= wb_lo;
            if (wb_dest == 3'd3) core_2_r3 <= wb_lo;
            if (wb_dest == 3'd4) core_2_r4 <= wb_lo;
            if (wb_dest == 3'd5) core_2_r5 <= wb_lo;
            if (wb_dest == 3'd6) core_2_r6 <= wb_lo;
            if (wb_dest == 3'd7) core_2_r7 <= wb_lo;
        end
    end
end

DEC_CORE u_dec (
    .i_inst(run_ir),
    .o_op(dec_op), .o_rs(dec_rs), .o_rt(dec_rt), .o_rd(dec_rd), .o_fn(dec_fn), .o_rl(dec_rl),
    .o_imm(dec_imm), .o_j(dec_j),
    .f_alu(dec_is_alu), .f_st(dec_is_st), .f_ld(dec_is_ld), .f_mul(dec_is_mul)
);

ALU_CORE u_alu (
    .c_op(pl_op), .c_fn(pl_fn), .c_pc(pl_pc), .v_rs(pl_rs_v), .v_rt(pl_rt_v), .v_imm(pl_imm),
    .res_alu(alu_out), .res_mem_a(calc_addr), .res_branch_pc(branch_tgt), .is_eq(alu_eq_flag)
);


assign pl_pc_p2 = pl_pc + 16'd2;

assign nxt_pc = (pl_op == 3'b111) ? {3'b000, dec_j} : ((pl_op == 3'b110 && alu_eq_flag) ? branch_tgt : pl_pc_p2);

SRAM64X16 u_sram_inst (
    .A0(mem_a[0]), .A1(mem_a[1]), .A2(mem_a[2]), .A3(mem_a[3]), .A4(mem_a[4]), .A5(mem_a[5]), 
    .DO0(mem_do[0]), .DO1(mem_do[1]), .DO2(mem_do[2]), .DO3(mem_do[3]), .DO4(mem_do[4]), .DO5(mem_do[5]), 
    .DO6(mem_do[6]), .DO7(mem_do[7]), .DO8(mem_do[8]), .DO9(mem_do[9]), .DO10(mem_do[10]), .DO11(mem_do[11]), 
    .DO12(mem_do[12]), .DO13(mem_do[13]), .DO14(mem_do[14]), .DO15(mem_do[15]), 
    .DI0(mem_di[0]), .DI1(mem_di[1]), .DI2(mem_di[2]), .DI3(mem_di[3]), .DI4(mem_di[4]), .DI5(mem_di[5]), 
    .DI6(mem_di[6]), .DI7(mem_di[7]), .DI8(mem_di[8]), .DI9(mem_di[9]), .DI10(mem_di[10]), .DI11(mem_di[11]), 
    .DI12(mem_di[12]), .DI13(mem_di[13]), .DI14(mem_di[14]), .DI15(mem_di[15]), 
    .CK(clk), .WEB(~mem_we), .OE(1'b1), .CS(1'b1)
);

endmodule

module BOOTH_MULT (
    clk, rst_n, clr, start, shift, rs_v, rt_v, step_cnt, mult_final
);

input clk;
input rst_n;
input clr;
input start;
input shift;
input [15:0] rs_v;
input [15:0] rt_v;

output [4:0] step_cnt;
output [31:0] mult_final;

wire [4:0] step_cnt;
wire [31:0] mult_final;

reg [32:0] mp;
reg [15:0] mcnd;
reg [4:0] cnt;

wire [16:0] ext_mcnd;
wire [16:0] b_up;
wire [16:0] b_add;
wire [16:0] b_sub;
reg [16:0] n_up;

assign step_cnt = cnt;
assign mult_final = mp[32:1];
assign ext_mcnd = {mcnd[15], mcnd};
assign b_up = {mp[32], mp[32:17]};
assign b_add = b_up + ext_mcnd;
assign b_sub = b_up - ext_mcnd;

always @(*) begin
    case (mp[1:0])
        2'b01: n_up = b_add;
        2'b10: n_up = b_sub;
        default: n_up = b_up;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mp <= 33'd0;
        mcnd <= 16'd0;
        cnt <= 5'd0;
    end 
    else if (clr) begin
        mp <= 33'd0;
        mcnd <= 16'd0;
        cnt <= 5'd0;
    end 
    else if (start) begin
        mp <= {16'd0, rt_v, 1'b0};
        mcnd <= rs_v;
        cnt <= 5'd0;
    end 
    else if (shift) begin
        mp <= {n_up, mp[16:1]};
        cnt <= cnt + 5'd1;
    end
end

endmodule

module DEC_CORE (
    i_inst, o_op, o_rs, o_rt, o_rd, o_fn, o_rl, o_imm, o_j, f_alu, f_st, f_ld, f_mul
);

input [15:0] i_inst;
output [2:0] o_op;
output [2:0] o_rs;
output [2:0] o_rt;
output [2:0] o_rd;
output [2:0] o_fn;
output [2:0] o_rl;
output [15:0] o_imm;
output [12:0] o_j;
output f_alu;
output f_st;
output f_ld;
output f_mul;

wire [2:0] o_op;
wire [2:0] o_rs;
wire [2:0] o_rt;
wire [2:0] o_rd;
wire [2:0] o_fn;
wire [2:0] o_rl;
wire [15:0] o_imm;
wire [12:0] o_j;
wire f_alu;
wire f_st;
wire f_ld;
wire f_mul;

assign o_op = i_inst[15:13];
assign o_rs = i_inst[12:10];
assign o_rt = i_inst[9:7];
assign o_rd = i_inst[6:4];
assign o_fn = i_inst[3:1];
assign o_rl = i_inst[3:1];
assign o_imm = {{9{i_inst[6]}}, i_inst[6:0]};
assign o_j = i_inst[12:0];

assign f_alu = (o_op == 3'b000) || (o_op == 3'b010) || (o_op == 3'b011);
assign f_st = (o_op == 3'b101);
assign f_ld = (o_op == 3'b100);
assign f_mul = (o_op == 3'b001);

endmodule

module ALU_CORE (
    c_op, c_fn, c_pc, v_rs, v_rt, v_imm, res_alu, res_mem_a, res_branch_pc, is_eq
);

input [2:0] c_op;
input [2:0] c_fn;
input [15:0] c_pc;
input [15:0] v_rs;
input [15:0] v_rt;
input [15:0] v_imm;

output [15:0] res_alu;
output [15:0] res_mem_a;
output [15:0] res_branch_pc;
output is_eq;

wire [15:0] res_alu;
wire [15:0] res_mem_a;
wire [15:0] res_branch_pc;
wire is_eq;

wire [15:0] pc_p2 = c_pc + 16'd2;
wire is_imm_t = (c_op == 3'b010) || (c_op == 3'b011) || (c_op == 3'b100) || (c_op == 3'b101);
wire is_sub_t = (c_op == 3'b011) || (c_op == 3'b110) || (c_op == 3'b000 && (c_fn == 3'b001 || c_fn == 3'b111));

wire [15:0] arg_a = (c_op == 3'b110) ? pc_p2 : v_rs;
wire [15:0] arg_b = (c_op == 3'b110) ? {v_imm[14:0], 1'b0} : ((is_imm_t ? v_imm : v_rt) ^ {16{is_sub_t}});
wire arg_cin = (c_op == 3'b110) ? 1'b0 : is_sub_t;

wire [15:0] a_sum = arg_a + arg_b + {15'd0, arg_cin};
wire s_slt = (v_rs[15] != v_rt[15]) ? v_rs[15] : a_sum[15];

reg [15:0] out_buf;

always @(*) begin
    case (c_op)
        3'b000: begin
            case(c_fn)
                3'b000, 3'b001: out_buf = a_sum;
                3'b010:         out_buf = v_rs & v_rt;
                3'b011:         out_buf = v_rs | v_rt;
                3'b100:         out_buf = ~(v_rs & v_rt);
                3'b101:         out_buf = ~(v_rs | v_rt);
                3'b110:         out_buf = v_rs ^ v_rt;
                3'b111:         out_buf = {15'd0, s_slt};
            endcase
        end
        3'b010, 3'b011: out_buf = a_sum;
        default:        out_buf = 16'd0;
    endcase
end

assign is_eq = (v_rs == v_rt);
assign res_alu = out_buf;
assign res_mem_a = 16'h1000 + {a_sum[14:0], 1'b0};
assign res_branch_pc = a_sum;

endmodule