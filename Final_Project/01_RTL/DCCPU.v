module DCCPU(
    clk,
    rst_n,
    stall_1,
    stall_2,
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
    // awid_m_inf_inst_1,
    // awaddr_m_inf_inst_1,
    // awsize_m_inf_inst_1,
    // awburst_m_inf_inst_1,
    // awlen_m_inf_inst_1,
    // awvalid_m_inf_inst_1,
    // awready_m_inf_inst_1,
    // wdata_m_inf_inst_1,
    // wlast_m_inf_inst_1,
    // wvalid_m_inf_inst_1,
    // wready_m_inf_inst_1,
    // bid_m_inf_inst_1,
    // bresp_m_inf_inst_1,
    // bvalid_m_inf_inst_1,
    // bready_m_inf_inst_1,
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
    // awid_m_inf_inst_2,
    // awaddr_m_inf_inst_2,
    // awsize_m_inf_inst_2,
    // awburst_m_inf_inst_2,
    // awlen_m_inf_inst_2,
    // awvalid_m_inf_inst_2,
    // awready_m_inf_inst_2,
    // wdata_m_inf_inst_2,
    // wlast_m_inf_inst_2,
    // wvalid_m_inf_inst_2,
    // wready_m_inf_inst_2,
    // bid_m_inf_inst_2,
    // bresp_m_inf_inst_2,
    // bvalid_m_inf_inst_2,
    // bready_m_inf_inst_2,  
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

input wire clk, rst_n;
output reg stall_1, stall_2;

parameter ID_WIDTH=4, ADDR_WIDTH=32, DATA_WIDTH=16, BURST_LEN=7;

// output wire [ID_WIDTH-1:0]   awid_m_inf_inst_1;
// output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_1;
// output wire [2:0]            awsize_m_inf_inst_1;
// output wire [1:0]            awburst_m_inf_inst_1; 
// output wire [BURST_LEN-1:0]  awlen_m_inf_inst_1;
// output wire                  awvalid_m_inf_inst_1;
// input wire                   awready_m_inf_inst_1;
// output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_1;
// output wire                  wlast_m_inf_inst_1;
// output wire                  wvalid_m_inf_inst_1;
// input wire                   wready_m_inf_inst_1;
// input wire  [ID_WIDTH-1:0]   bid_m_inf_inst_1;
// input wire  [1:0]            bresp_m_inf_inst_1;
// input wire                   bvalid_m_inf_inst_1;
// output wire                  bready_m_inf_inst_1;

output wire [ID_WIDTH-1:0]   arid_m_inf_inst_1; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_1;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_1;
output wire [2:0]            arsize_m_inf_inst_1;
output wire [1:0]            arburst_m_inf_inst_1;
output wire                  arvalid_m_inf_inst_1;
input wire                   arready_m_inf_inst_1;
input wire [ID_WIDTH-1:0]    rid_m_inf_inst_1; 
input wire [DATA_WIDTH-1:0]  rdata_m_inf_inst_1;
input wire [1:0]             rresp_m_inf_inst_1;
input wire                   rlast_m_inf_inst_1;
input wire                   rvalid_m_inf_inst_1;
output wire                  rready_m_inf_inst_1;

// output wire [ID_WIDTH-1:0]   awid_m_inf_inst_2; 
// output wire [ADDR_WIDTH-1:0] awaddr_m_inf_inst_2;
// output wire [2:0]            awsize_m_inf_inst_2;
// output wire [1:0]            awburst_m_inf_inst_2; 
// output wire [BURST_LEN-1:0]  awlen_m_inf_inst_2;
// output wire                  awvalid_m_inf_inst_2;
// input wire                   awready_m_inf_inst_2;
// output wire [DATA_WIDTH-1:0] wdata_m_inf_inst_2;
// output wire                  wlast_m_inf_inst_2;
// output wire                  wvalid_m_inf_inst_2;
// input wire                   wready_m_inf_inst_2;
// input wire  [ID_WIDTH-1:0]   bid_m_inf_inst_2;
// input wire  [1:0]            bresp_m_inf_inst_2;
// input wire                   bvalid_m_inf_inst_2;
// output wire                  bready_m_inf_inst_2;

output wire [ID_WIDTH-1:0]   arid_m_inf_inst_2; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_inst_2;
output wire [BURST_LEN-1:0]  arlen_m_inf_inst_2;
output wire [2:0]            arsize_m_inf_inst_2;
output wire [1:0]            arburst_m_inf_inst_2;
output wire                  arvalid_m_inf_inst_2;
input wire                   arready_m_inf_inst_2;
input wire [ID_WIDTH-1:0]    rid_m_inf_inst_2; 
input wire [DATA_WIDTH-1:0]  rdata_m_inf_inst_2;
input wire [1:0]             rresp_m_inf_inst_2;
input wire                   rlast_m_inf_inst_2;
input wire                   rvalid_m_inf_inst_2;
output wire                  rready_m_inf_inst_2;

output wire [ID_WIDTH-1:0]   awid_m_inf_data;
output wire [ADDR_WIDTH-1:0] awaddr_m_inf_data;
output wire [2:0]            awsize_m_inf_data;
output wire [1:0]            awburst_m_inf_data; 
output wire [BURST_LEN-1:0]  awlen_m_inf_data;
output wire                  awvalid_m_inf_data;
input wire                   awready_m_inf_data;
output wire [DATA_WIDTH-1:0] wdata_m_inf_data;
output wire                  wlast_m_inf_data;
output wire                  wvalid_m_inf_data;
input wire                   wready_m_inf_data;
input wire  [ID_WIDTH-1:0]   bid_m_inf_data;
input wire  [1:0]            bresp_m_inf_data;
input wire                   bvalid_m_inf_data;
output wire                  bready_m_inf_data;
output wire [ID_WIDTH-1:0]   arid_m_inf_data; 
output wire [ADDR_WIDTH-1:0] araddr_m_inf_data;
output wire [BURST_LEN-1:0]  arlen_m_inf_data;
output wire [2:0]            arsize_m_inf_data;
output wire [1:0]            arburst_m_inf_data;
output wire                  arvalid_m_inf_data;
input wire                   arready_m_inf_data;
input wire [ID_WIDTH-1:0]    rid_m_inf_data; 
input wire [DATA_WIDTH-1:0]  rdata_m_inf_data;
input wire [1:0]             rresp_m_inf_data;
input wire                   rlast_m_inf_data;
input wire                   rvalid_m_inf_data;
output wire                  rready_m_inf_data;

wire [15:0] nxt_pc;
wire [15:0] alu_out;
wire alu_eq_flag;

reg [15:0] core_1_r0, core_1_r1, core_1_r2, core_1_r3;
reg [15:0] core_1_r4, core_1_r5, core_1_r6, core_1_r7;
reg [15:0] core_2_r0, core_2_r1, core_2_r2, core_2_r3;
reg [15:0] core_2_r4, core_2_r5, core_2_r6, core_2_r7;

parameter IDLE  = 4'd0, F1    = 4'd1, F2    = 4'd2,
          CHK   = 4'd3, IREQ  = 4'd4, IRD   = 4'd5, 
          DEC   = 4'd6, EXE   = 4'd8, MUL   = 4'd9,
          DREQ  = 4'd10, DWT  = 4'd11, WB   = 4'd12;

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
reg pl_is_imm;
reg pl_is_sub;

reg [15:0] pl_pc_p2;
reg [15:0] pl_br_tgt;
reg [15:0] pl_jmp_tgt;
reg [15:0] pl_d_addr;

reg act_c1;
reg act_c2;
wire [15:0] mem_do;
reg [15:0] mem_di;
reg [5:0] mem_a;
reg mem_we;
reg mem_cs;

wire [15:0] run_ir;
wire [15:0] run_pc;
wire [15:0] v_rs_cur;
wire [15:0] v_rt_cur;

wire [2:0] dec_op, dec_rs, dec_rt, dec_rd, dec_fn, dec_rl;
wire [15:0] dec_imm;
wire [12:0] dec_j;
wire dec_is_alu, dec_is_st, dec_is_ld, dec_is_mul, dec_is_imm, dec_is_sub;

wire [1:0] idx1;
wire [9:0] ct1;
wire h1_0, h1_1, h1_2, h1_3, h1_act, hit1;

wire [1:0] idx2;
wire [9:0] ct2;
wire h2_0, h2_1, h2_2, h2_3, h2_act, hit2;

wire  mul_start;
wire  mul_shift;
wire [31:0] mul_res;
wire [4:0] mul_step;

wire c2_wb_en;
wire [15:0] wb_hi;
wire [15:0] wb_lo;
wire [2:0]  wb_dest;
wire        do_wb;
wire        c1_wb_en;
wire [31:0] mem_axi_addr;
wire core_halt;

reg        d_cache_valid;
reg [11:0] d_cache_tag;
reg [15:0] d_cache_data [0:7];
reg [2:0]  db_cnt;

wire [15:0] peek_ir2 = (c_st == CHK) ? mem_do : ir2;
wire pre_nxt_act_c = (!stop1 && !stop2) ? ((peek_ir2[15:13] == 3'b101 && ir1[15:13] != 3'b101) ? 1'b1 : 1'b0) : (stop1 ? 1'b1 : 1'b0);

wire [11:0] comb_target_tag = pl_d_addr[15:4];
wire comb_d_cache_hit = d_cache_valid && (d_cache_tag == comb_target_tag);

wire [11:0] reg_target_tag = d_addr[15:4];
wire [2:0]  reg_target_idx = d_addr[3:1];
wire reg_d_cache_hit = d_cache_valid && (d_cache_tag == reg_target_tag);

// assign awid_m_inf_inst_1 = 4'd0;
// assign awaddr_m_inf_inst_1 = 32'd0;
// assign awsize_m_inf_inst_1 = 3'd0;
// assign awburst_m_inf_inst_1 = 2'd0; 
// assign awlen_m_inf_inst_1 = 7'd0; 
// assign awvalid_m_inf_inst_1 = 1'b0;
// assign wdata_m_inf_inst_1 = 16'd0;
// assign wlast_m_inf_inst_1 = 1'b0;
// assign wvalid_m_inf_inst_1 = 1'b0; 
// assign bready_m_inf_inst_1 = 1'b0;

// assign awid_m_inf_inst_2 = 4'd0;
// assign awaddr_m_inf_inst_2 = 32'd0;
// assign awsize_m_inf_inst_2 = 3'd0;
// assign awburst_m_inf_inst_2 = 2'd0; 
// assign awlen_m_inf_inst_2 = 7'd0; 
// assign awvalid_m_inf_inst_2 = 1'b0;
// assign wdata_m_inf_inst_2 = 16'd0;
// assign wlast_m_inf_inst_2 = 1'b0;
// assign wvalid_m_inf_inst_2 = 1'b0; 
// assign bready_m_inf_inst_2 = 1'b0;

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
assign arlen_m_inf_data = 7'd7;

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
assign h2_act = (idx2 == 2'd0 && h2_0) ||
                (idx2 == 2'd1 && h2_1) || (idx2 == 2'd2 && h2_2) || (idx2 == 2'd3 && h2_3);
assign hit2 = stop2 || h2_act;

wire only_one_core_runs = (stop1 || stop2);

wire eval_act_c = (c_st == WB && !exe_ph && !only_one_core_runs) ? ~is_fst_c : act_c;

assign run_ir = (eval_act_c == 1'b0) ? ir1 : ir2;
assign run_pc = (eval_act_c == 1'b0) ? prog_cnt1 : prog_cnt2;

wire [2:0] ir1_rs = ir1[12:10];
wire [2:0] ir1_rt = ir1[9:7];
wire [2:0] ir2_rs = ir2[12:10];
wire [2:0] ir2_rt = ir2[9:7];

wire [15:0] c1_rs_mux = (ir1_rs == 3'd0) ? core_1_r0 :
                        (ir1_rs == 3'd1) ? core_1_r1 :
                        (ir1_rs == 3'd2) ? core_1_r2 :
                        (ir1_rs == 3'd3) ? core_1_r3 :
                        (ir1_rs == 3'd4) ? core_1_r4 :
                        (ir1_rs == 3'd5) ? core_1_r5 :
                        (ir1_rs == 3'd6) ? core_1_r6 : core_1_r7;

wire [15:0] c2_rs_mux = (ir2_rs == 3'd0) ? core_2_r0 :
                        (ir2_rs == 3'd1) ? core_2_r1 :
                        (ir2_rs == 3'd2) ? core_2_r2 :
                        (ir2_rs == 3'd3) ? core_2_r3 :
                        (ir2_rs == 3'd4) ? core_2_r4 :
                        (ir2_rs == 3'd5) ? core_2_r5 :
                        (ir2_rs == 3'd6) ? core_2_r6 : core_2_r7;

assign v_rs_cur = (eval_act_c == 1'b0) ? c1_rs_mux : c2_rs_mux;

wire [15:0] c1_rt_mux = (ir1_rt == 3'd0) ? core_1_r0 :
                        (ir1_rt == 3'd1) ? core_1_r1 :
                        (ir1_rt == 3'd2) ? core_1_r2 :
                        (ir1_rt == 3'd3) ? core_1_r3 :
                        (ir1_rt == 3'd4) ? core_1_r4 :
                        (ir1_rt == 3'd5) ? core_1_r5 :
                        (ir1_rt == 3'd6) ? core_1_r6 : core_1_r7;

wire [15:0] c2_rt_mux = (ir2_rt == 3'd0) ? core_2_r0 :
                        (ir2_rt == 3'd1) ? core_2_r1 :
                        (ir2_rt == 3'd2) ? core_2_r2 :
                        (ir2_rt == 3'd3) ? core_2_r3 :
                        (ir2_rt == 3'd4) ? core_2_r4 :
                        (ir2_rt == 3'd5) ? core_2_r5 :
                        (ir2_rt == 3'd6) ? core_2_r6 : core_2_r7;

assign v_rt_cur = (eval_act_c == 1'b0) ? c1_rt_mux : c2_rt_mux;

wire en_pipeline = (c_st == DEC || (c_st == WB && !exe_ph && !only_one_core_runs) || c_st == IDLE);
wire gclk_pipeline = clk & en_pipeline;

wire en_ir1 = (c_st == IDLE) || (c_st == F2);
wire gclk_ir1 = clk & en_ir1;

wire en_ir2 = (c_st == IDLE) || (c_st == CHK);
wire gclk_ir2 = clk & en_ir2;

wire en_b_cnt = (c_st == IDLE) || (c_st == IREQ) || (c_st == IRD);
wire gclk_b_cnt = clk & en_b_cnt;

wire en_tags = (c_st == IDLE) || (c_st == IRD);
wire gclk_tags = clk & en_tags;

wire en_dmem_reg = (c_st == IDLE) || (c_st == EXE && (pl_ld || pl_st));
wire gclk_dmem_reg = clk & en_dmem_reg;

wire en_axi_flags = (c_st == IDLE) || (c_st == IREQ) || (c_st == DREQ) || (c_st == IRD) || (c_st == DWT);
wire gclk_axi_flags = clk & en_axi_flags;

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
        DEC:       n_st = EXE;
        EXE: begin
            if (pl_mul)               n_st = MUL;
            else if (pl_ld) begin
                if (comb_d_cache_hit) n_st = WB;
                else                  n_st = DREQ;
            end
            else if (pl_st)           n_st = DREQ;
            else                      n_st = WB;
        end
        MUL: begin
            if (mul_step == 5'd15)    n_st = WB;
        end
        DREQ: begin
            if (pl_ld && ((arvalid_m_inf_data && arready_m_inf_data) || f_ar)) n_st = DWT;
            if (pl_st && ((awvalid_m_inf_data && awready_m_inf_data) || f_aw) && ((wvalid_m_inf_data && wready_m_inf_data) || f_w)) n_st = DWT;
        end
        DWT: begin
            if (pl_ld && rvalid_m_inf_data && rlast_m_inf_data) n_st = WB;
            if (pl_st && bvalid_m_inf_data) n_st = WB;
        end
        WB: begin
            if (!exe_ph && !only_one_core_runs) n_st = EXE;
            else n_st = F1;
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
    else if (c_st == WB && (exe_ph == 1'b1 || only_one_core_runs)) begin 
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
            if (n_st == DEC) begin
                is_fst_c <= pre_nxt_act_c;
                act_c    <= pre_nxt_act_c;
            end
        end 
        else if (c_st == DEC) begin
            exe_ph <= 1'b0;
        end 
        else if (c_st == WB && exe_ph == 1'b0 && !only_one_core_runs) begin
            exe_ph <= 1'b1;
            act_c <= ~is_fst_c; 
        end
    end
end

wire is_idle = (c_st == IDLE);
wire block_act = (eval_act_c == 1'b0 ? stop1 : stop2);

wire [15:0] dec_pc_p2   = run_pc + 16'd2;
wire [15:0] dec_br_tgt  = dec_pc_p2 + {dec_imm[14:0], 1'b0};
wire [15:0] dec_jmp_tgt = {dec_pc_p2[15:13], dec_j};
wire [15:0] dec_mem_off = {dec_imm[14:0], 1'b0} + 16'h1000;
wire [15:0] dec_d_addr  = {v_rs_cur[14:0], 1'b0} + dec_mem_off;

wire [15:0] nxt_pl_rs_v = is_idle ? 16'd0 : v_rs_cur;
wire [15:0] nxt_pl_rt_v = is_idle ? 16'd0 : v_rt_cur;
wire [15:0] nxt_pl_imm  = is_idle ? 16'd0 : dec_imm;
wire [15:0] nxt_pl_pc   = is_idle ? 16'd0 : run_pc;
wire [2:0]  nxt_pl_op   = is_idle ? 3'd0  : dec_op;
wire [2:0]  nxt_pl_fn   = is_idle ? 3'd0  : dec_fn;
wire [2:0]  nxt_pl_rd   = is_idle ? 3'd0  : dec_rd;
wire [2:0]  nxt_pl_rt   = is_idle ? 3'd0  : dec_rt;
wire [2:0]  nxt_pl_rl   = is_idle ? 3'd0  : dec_rl;
wire [12:0] nxt_pl_j    = is_idle ? 13'd0 : dec_j;

wire nxt_pl_alu = is_idle ? 1'b0 : (block_act ? 1'b0 : dec_is_alu);
wire nxt_pl_st  = is_idle ? 1'b0 : (block_act ? 1'b0 : dec_is_st);
wire nxt_pl_ld  = is_idle ? 1'b0 : (block_act ? 1'b0 : dec_is_ld);
wire nxt_pl_mul = is_idle ? 1'b0 : (block_act ? 1'b0 : dec_is_mul);
wire nxt_pl_is_imm = is_idle ? 1'b0 : dec_is_imm;
wire nxt_pl_is_sub = is_idle ? 1'b0 : dec_is_sub;

wire [15:0] nxt_pl_pc_p2   = is_idle ? 16'd0 : dec_pc_p2;
wire [15:0] nxt_pl_br_tgt  = is_idle ? 16'd0 : dec_br_tgt;
wire [15:0] nxt_pl_jmp_tgt = is_idle ? 16'd0 : dec_jmp_tgt;
wire [15:0] nxt_pl_d_addr  = is_idle ? 16'd0 : dec_d_addr;

always @(posedge gclk_pipeline or negedge rst_n) begin
    if (!rst_n) begin
        pl_rs_v <= 16'd0;
        pl_rt_v <= 16'd0; pl_imm <= 16'd0; pl_pc <= 16'd0;
        pl_op <= 3'd0; pl_fn <= 3'd0; pl_rd <= 3'd0;
        pl_rt <= 3'd0; pl_rl <= 3'd0;
        pl_alu <= 1'b0; pl_st <= 1'b0; pl_ld <= 1'b0; pl_mul <= 1'b0;
        pl_j <= 13'd0;
        pl_is_imm <= 1'b0; pl_is_sub <= 1'b0;
        
        pl_pc_p2   <= 16'd0;
        pl_br_tgt  <= 16'd0;
        pl_jmp_tgt <= 16'd0;
        pl_d_addr  <= 16'd0;
    end else begin
        pl_rs_v <= nxt_pl_rs_v;
        pl_rt_v <= nxt_pl_rt_v;
        pl_imm  <= nxt_pl_imm;
        pl_pc   <= nxt_pl_pc;
        pl_op   <= nxt_pl_op;
        pl_fn   <= nxt_pl_fn;
        pl_rd   <= nxt_pl_rd;
        pl_rt   <= nxt_pl_rt;
        pl_rl   <= nxt_pl_rl;
        pl_j    <= nxt_pl_j;
        pl_alu  <= nxt_pl_alu;
        pl_st   <= nxt_pl_st;
        pl_ld   <= nxt_pl_ld;
        pl_mul  <= nxt_pl_mul;
        pl_is_imm <= nxt_pl_is_imm;
        pl_is_sub <= nxt_pl_is_sub;

        pl_pc_p2   <= nxt_pl_pc_p2;
        pl_br_tgt  <= nxt_pl_br_tgt;
        pl_jmp_tgt <= nxt_pl_jmp_tgt;
        pl_d_addr  <= nxt_pl_d_addr;
    end
end

always @(posedge gclk_ir1 or negedge rst_n) begin
    if (!rst_n) ir1 <= 16'd0;
    else if (c_st == IDLE) ir1 <= 16'd0;
    else ir1 <= mem_do;
end

always @(posedge gclk_ir2 or negedge rst_n) begin
    if (!rst_n) ir2 <= 16'd0;
    else if (c_st == IDLE) ir2 <= 16'd0;
    else ir2 <= mem_do;
end

always @(posedge gclk_b_cnt or negedge rst_n) begin
    if (!rst_n) b_cnt <= 3'd0;
    else if (c_st == IDLE || c_st == IREQ) b_cnt <= 3'd0;
    else if (c_st == IRD) begin
        if (!is_miss && rvalid_m_inf_inst_1) b_cnt <= b_cnt + 3'd1;
        else if (is_miss && rvalid_m_inf_inst_2) b_cnt <= b_cnt + 3'd1;
    end
end

always @(posedge gclk_tags or negedge rst_n) begin
    if (!rst_n) begin
        v1_0 <= 1'b0;
        v1_1 <= 1'b0; v1_2 <= 1'b0; v1_3 <= 1'b0;
        t1_0 <= 10'd0; t1_1 <= 10'd0; t1_2 <= 10'd0;
        t1_3 <= 10'd0;
        v2_0 <= 1'b0; v2_1 <= 1'b0; v2_2 <= 1'b0; v2_3 <= 1'b0;
        t2_0 <= 10'd0;
        t2_1 <= 10'd0; t2_2 <= 10'd0; t2_3 <= 10'd0;
    end 
    else if (c_st == IDLE) begin
        v1_0 <= 1'b0;
        v1_1 <= 1'b0; v1_2 <= 1'b0; v1_3 <= 1'b0;
        t1_0 <= 10'd0; t1_1 <= 10'd0; t1_2 <= 10'd0;
        t1_3 <= 10'd0;
        v2_0 <= 1'b0; v2_1 <= 1'b0; v2_2 <= 1'b0; v2_3 <= 1'b0;
        t2_0 <= 10'd0;
        t2_1 <= 10'd0; t2_2 <= 10'd0; t2_3 <= 10'd0;
    end 
    else if (c_st == IRD) begin
        if (!is_miss && rlast_m_inf_inst_1) begin
            if (idx1 == 2'd0) begin v1_0 <= 1'b1; t1_0 <= ct1; end
            if (idx1 == 2'd1) begin v1_1 <= 1'b1; t1_1 <= ct1; end
            if (idx1 == 2'd2) begin v1_2 <= 1'b1; t1_2 <= ct1; end
            if (idx1 == 2'd3) begin v1_3 <= 1'b1; t1_3 <= ct1; end
        end
        if (is_miss && rlast_m_inf_inst_2) begin
            if (idx2 == 2'd0) begin v2_0 <= 1'b1; t2_0 <= ct2; end
            if (idx2 == 2'd1) begin v2_1 <= 1'b1; t2_1 <= ct2; end
            if (idx2 == 2'd2) begin v2_2 <= 1'b1; t2_2 <= ct2; end
            if (idx2 == 2'd3) begin v2_3 <= 1'b1; t2_3 <= ct2; end
        end
    end
end

always @(*) begin
    mem_we = 1'b0;
    mem_di = 16'd0;
    mem_a = 6'd0;
    mem_cs = 1'b0;

    if (c_st == F1) begin
        mem_a = {1'b0, prog_cnt1[5:1]};
        mem_cs = 1'b1;
    end
    else if (c_st == F2) begin
        mem_a = {1'b1, prog_cnt2[5:1]};
        mem_cs = 1'b1;
    end
    else if (c_st == IRD) begin
        mem_a = {is_miss, (is_miss == 1'b0 ? prog_cnt1[5:4] : prog_cnt2[5:4]), b_cnt};
        if (!is_miss) begin 
            mem_we = rvalid_m_inf_inst_1;
            mem_di = rdata_m_inf_inst_1; 
            mem_cs = rvalid_m_inf_inst_1;
        end 
        else begin 
            mem_we = rvalid_m_inf_inst_2;
            mem_di = rdata_m_inf_inst_2; 
            mem_cs = rvalid_m_inf_inst_2;
        end
    end
end

always @(posedge gclk_dmem_reg or negedge rst_n) begin
    if (!rst_n) begin
        d_addr <= 16'd0;
        d_wdat <= 16'd0; 
    end 
    else if (c_st == IDLE) begin 
        d_addr <= 16'd0;
        d_wdat <= 16'd0; 
    end 
    else begin
        d_addr <= pl_d_addr;
        d_wdat <= pl_rt_v;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_cache_valid <= 1'b0;
        d_cache_tag <= 12'd0;
    end
    else if (c_st == IDLE) begin
        d_cache_valid <= 1'b0;
        d_cache_tag <= 12'd0;
    end
    else if (c_st == DWT && pl_ld && rvalid_m_inf_data && rlast_m_inf_data) begin
        d_cache_valid <= 1'b1;
        d_cache_tag <= reg_target_tag;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) db_cnt <= 3'd0;
    else if (c_st == IDLE) db_cnt <= 3'd0;
    else if (c_st == DREQ) db_cnt <= 3'd0;
    else if (c_st == DWT && pl_ld && rvalid_m_inf_data && rready_m_inf_data) db_cnt <= db_cnt + 3'd1;
end

wire [7:0] cache_word_en;
genvar i_gen;
generate
    for(i_gen=0; i_gen<8; i_gen=i_gen+1) begin : cache_gen
        assign cache_word_en[i_gen] = (c_st == IDLE) ||
                                      (c_st == DWT && pl_ld && db_cnt == i_gen) ||
                                      (c_st == DREQ && pl_st && reg_d_cache_hit && !f_w && reg_target_idx == i_gen);
        wire gclk_cache_word = clk & cache_word_en[i_gen];
        always @(posedge gclk_cache_word or negedge rst_n) begin
            if (!rst_n) d_cache_data[i_gen] <= 16'd0;
            else if (c_st == IDLE) d_cache_data[i_gen] <= 16'd0;
            else if (c_st == DWT) begin
                if (rvalid_m_inf_data) d_cache_data[i_gen] <= rdata_m_inf_data;
            end
            else if (c_st == DREQ) begin
                if (reg_d_cache_hit) d_cache_data[i_gen] <= d_wdat;
            end
        end
    end
endgenerate

always @(posedge gclk_axi_flags or negedge rst_n) begin
    if (!rst_n) begin
        f_ar <= 1'b0;
        f_aw <= 1'b0; f_w <= 1'b0;
    end 
    else if (c_st == IDLE) begin 
        f_ar <= 1'b0;
        f_aw <= 1'b0; f_w <= 1'b0;
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

assign nxt_pc = (pl_op == 3'b111) ? pl_jmp_tgt : ((pl_op == 3'b110 && alu_eq_flag) ? pl_br_tgt : pl_pc_p2);
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

assign araddr_m_inf_data  = {16'd0, d_addr[15:4], 4'd0};
assign rready_m_inf_data  = (c_st == DWT && pl_ld);

assign awvalid_m_inf_data = (c_st == DREQ && pl_st && !f_aw && ((act_c == 0 && !stop1) || (act_c == 1 && !stop2)));
assign arvalid_m_inf_data = (c_st == DREQ && pl_ld && !reg_d_cache_hit && !f_ar && ((act_c == 0 && !stop1) || (act_c == 1 && !stop2)));

assign mul_start = (c_st == EXE) && pl_mul;
assign mul_shift = (c_st == MUL);

wire en_mul = (c_st == IDLE) || (c_st == EXE && pl_mul) || (c_st == MUL);
wire gclk_mul = clk & en_mul;

BOOTH_MULT u_mult (
    .clk(gclk_mul), 
    .rst_n(rst_n),
    .clr(c_st == IDLE),
    .start(mul_start),
    .shift(mul_shift),
    .rs_v(pl_rs_v),
    .rt_v(pl_rt_v),
    .step_cnt(mul_step),
    .mult_final(mul_res)
);

wire [15:0] loaded_data = d_cache_data[d_addr[3:1]];
assign wb_hi = pl_mul ? mul_res[31:16] : (pl_ld ? loaded_data : alu_out);
assign wb_lo = pl_mul ? mul_res[15:0]  : (pl_ld ? loaded_data : alu_out);
assign wb_dest = (pl_op == 3'b000) ? pl_rd : pl_rt;

assign do_wb = (pl_alu || pl_ld || pl_mul);

assign c1_wb_en = (c_st == WB && act_c == 1'b0 && !stop1 && do_wb);

wire match_c1_r0 = (pl_mul && (pl_rl == 3'd0 || pl_rd == 3'd0)) || (!pl_mul && (wb_dest == 3'd0));
wire match_c1_r1 = (pl_mul && (pl_rl == 3'd1 || pl_rd == 3'd1)) || (!pl_mul && (wb_dest == 3'd1));
wire match_c1_r2 = (pl_mul && (pl_rl == 3'd2 || pl_rd == 3'd2)) || (!pl_mul && (wb_dest == 3'd2));
wire match_c1_r3 = (pl_mul && (pl_rl == 3'd3 || pl_rd == 3'd3)) || (!pl_mul && (wb_dest == 3'd3));
wire match_c1_r4 = (pl_mul && (pl_rl == 3'd4 || pl_rd == 3'd4)) || (!pl_mul && (wb_dest == 3'd4));
wire match_c1_r5 = (pl_mul && (pl_rl == 3'd5 || pl_rd == 3'd5)) || (!pl_mul && (wb_dest == 3'd5));
wire match_c1_r6 = (pl_mul && (pl_rl == 3'd6 || pl_rd == 3'd6)) || (!pl_mul && (wb_dest == 3'd6));
wire match_c1_r7 = (pl_mul && (pl_rl == 3'd7 || pl_rd == 3'd7)) || (!pl_mul && (wb_dest == 3'd7));

wire en_c1_r0 = c1_wb_en && match_c1_r0;
wire en_c1_r1 = c1_wb_en && match_c1_r1;
wire en_c1_r2 = c1_wb_en && match_c1_r2;
wire en_c1_r3 = c1_wb_en && match_c1_r3;
wire en_c1_r4 = c1_wb_en && match_c1_r4;
wire en_c1_r5 = c1_wb_en && match_c1_r5;
wire en_c1_r6 = c1_wb_en && match_c1_r6;
wire en_c1_r7 = c1_wb_en && match_c1_r7;

wire gclk_c1_r0 = clk & en_c1_r0;
wire gclk_c1_r1 = clk & en_c1_r1;
wire gclk_c1_r2 = clk & en_c1_r2;
wire gclk_c1_r3 = clk & en_c1_r3;
wire gclk_c1_r4 = clk & en_c1_r4;
wire gclk_c1_r5 = clk & en_c1_r5;
wire gclk_c1_r6 = clk & en_c1_r6;
wire gclk_c1_r7 = clk & en_c1_r7;

wire [15:0] nxt_c1_r0 = pl_mul ? ((pl_rl == 3'd0) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r1 = pl_mul ? ((pl_rl == 3'd1) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r2 = pl_mul ? ((pl_rl == 3'd2) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r3 = pl_mul ? ((pl_rl == 3'd3) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r4 = pl_mul ? ((pl_rl == 3'd4) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r5 = pl_mul ? ((pl_rl == 3'd5) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r6 = pl_mul ? ((pl_rl == 3'd6) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c1_r7 = pl_mul ? ((pl_rl == 3'd7) ? wb_lo : wb_hi) : wb_lo;

always @(posedge gclk_c1_r0 or negedge rst_n) begin if (!rst_n) begin core_1_r0 <= 16'd0; end else begin core_1_r0 <= nxt_c1_r0; end end
always @(posedge gclk_c1_r1 or negedge rst_n) begin if (!rst_n) begin core_1_r1 <= 16'd0; end else begin core_1_r1 <= nxt_c1_r1; end end
always @(posedge gclk_c1_r2 or negedge rst_n) begin if (!rst_n) begin core_1_r2 <= 16'd0; end else begin core_1_r2 <= nxt_c1_r2; end end
always @(posedge gclk_c1_r3 or negedge rst_n) begin if (!rst_n) begin core_1_r3 <= 16'd0; end else begin core_1_r3 <= nxt_c1_r3; end end
always @(posedge gclk_c1_r4 or negedge rst_n) begin if (!rst_n) begin core_1_r4 <= 16'd0; end else begin core_1_r4 <= nxt_c1_r4; end end
always @(posedge gclk_c1_r5 or negedge rst_n) begin if (!rst_n) begin core_1_r5 <= 16'd0; end else begin core_1_r5 <= nxt_c1_r5; end end
always @(posedge gclk_c1_r6 or negedge rst_n) begin if (!rst_n) begin core_1_r6 <= 16'd0; end else begin core_1_r6 <= nxt_c1_r6; end end
always @(posedge gclk_c1_r7 or negedge rst_n) begin if (!rst_n) begin core_1_r7 <= 16'd0; end else begin core_1_r7 <= nxt_c1_r7; end end

assign c2_wb_en = (c_st == WB && act_c == 1'b1 && !stop2 && do_wb);

wire match_c2_r0 = (pl_mul && (pl_rl == 3'd0 || pl_rd == 3'd0)) || (!pl_mul && (wb_dest == 3'd0));
wire match_c2_r1 = (pl_mul && (pl_rl == 3'd1 || pl_rd == 3'd1)) || (!pl_mul && (wb_dest == 3'd1));
wire match_c2_r2 = (pl_mul && (pl_rl == 3'd2 || pl_rd == 3'd2)) || (!pl_mul && (wb_dest == 3'd2));
wire match_c2_r3 = (pl_mul && (pl_rl == 3'd3 || pl_rd == 3'd3)) || (!pl_mul && (wb_dest == 3'd3));
wire match_c2_r4 = (pl_mul && (pl_rl == 3'd4 || pl_rd == 3'd4)) || (!pl_mul && (wb_dest == 3'd4));
wire match_c2_r5 = (pl_mul && (pl_rl == 3'd5 || pl_rd == 3'd5)) || (!pl_mul && (wb_dest == 3'd5));
wire match_c2_r6 = (pl_mul && (pl_rl == 3'd6 || pl_rd == 3'd6)) || (!pl_mul && (wb_dest == 3'd6));
wire match_c2_r7 = (pl_mul && (pl_rl == 3'd7 || pl_rd == 3'd7)) || (!pl_mul && (wb_dest == 3'd7));

wire en_c2_r0 = c2_wb_en && match_c2_r0;
wire en_c2_r1 = c2_wb_en && match_c2_r1;
wire en_c2_r2 = c2_wb_en && match_c2_r2;
wire en_c2_r3 = c2_wb_en && match_c2_r3;
wire en_c2_r4 = c2_wb_en && match_c2_r4;
wire en_c2_r5 = c2_wb_en && match_c2_r5;
wire en_c2_r6 = c2_wb_en && match_c2_r6;
wire en_c2_r7 = c2_wb_en && match_c2_r7;

wire gclk_c2_r0 = clk & en_c2_r0;
wire gclk_c2_r1 = clk & en_c2_r1;
wire gclk_c2_r2 = clk & en_c2_r2;
wire gclk_c2_r3 = clk & en_c2_r3;
wire gclk_c2_r4 = clk & en_c2_r4;
wire gclk_c2_r5 = clk & en_c2_r5;
wire gclk_c2_r6 = clk & en_c2_r6;
wire gclk_c2_r7 = clk & en_c2_r7;

wire [15:0] nxt_c2_r0 = pl_mul ? ((pl_rl == 3'd0) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r1 = pl_mul ? ((pl_rl == 3'd1) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r2 = pl_mul ? ((pl_rl == 3'd2) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r3 = pl_mul ? ((pl_rl == 3'd3) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r4 = pl_mul ? ((pl_rl == 3'd4) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r5 = pl_mul ? ((pl_rl == 3'd5) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r6 = pl_mul ? ((pl_rl == 3'd6) ? wb_lo : wb_hi) : wb_lo;
wire [15:0] nxt_c2_r7 = pl_mul ? ((pl_rl == 3'd7) ? wb_lo : wb_hi) : wb_lo;

always @(posedge gclk_c2_r0 or negedge rst_n) begin if (!rst_n) begin core_2_r0 <= 16'd0; end else begin core_2_r0 <= nxt_c2_r0; end end
always @(posedge gclk_c2_r1 or negedge rst_n) begin if (!rst_n) begin core_2_r1 <= 16'd0; end else begin core_2_r1 <= nxt_c2_r1; end end
always @(posedge gclk_c2_r2 or negedge rst_n) begin if (!rst_n) begin core_2_r2 <= 16'd0; end else begin core_2_r2 <= nxt_c2_r2; end end
always @(posedge gclk_c2_r3 or negedge rst_n) begin if (!rst_n) begin core_2_r3 <= 16'd0; end else begin core_2_r3 <= nxt_c2_r3; end end
always @(posedge gclk_c2_r4 or negedge rst_n) begin if (!rst_n) begin core_2_r4 <= 16'd0; end else begin core_2_r4 <= nxt_c2_r4; end end
always @(posedge gclk_c2_r5 or negedge rst_n) begin if (!rst_n) begin core_2_r5 <= 16'd0; end else begin core_2_r5 <= nxt_c2_r5; end end
always @(posedge gclk_c2_r6 or negedge rst_n) begin if (!rst_n) begin core_2_r6 <= 16'd0; end else begin core_2_r6 <= nxt_c2_r6; end end
always @(posedge gclk_c2_r7 or negedge rst_n) begin if (!rst_n) begin core_2_r7 <= 16'd0; end else begin core_2_r7 <= nxt_c2_r7; end end

DEC_CORE u_dec (
    .i_inst(run_ir),
    .o_op(dec_op), .o_rs(dec_rs), .o_rt(dec_rt), .o_rd(dec_rd), .o_fn(dec_fn), .o_rl(dec_rl),
    .o_imm(dec_imm), .o_j(dec_j),
    .f_alu(dec_is_alu), .f_st(dec_is_st), .f_ld(dec_is_ld), .f_mul(dec_is_mul),
    .f_imm_op(dec_is_imm), .f_sub_op(dec_is_sub)
);

ALU_CORE u_alu (
    .c_op(pl_op), 
    .c_fn(pl_fn), 
    .c_is_imm(pl_is_imm), 
    .c_is_sub(pl_is_sub),
    .v_rs(pl_rs_v), 
    .v_rt(pl_rt_v), 
    .v_imm(pl_imm),
    .pl_alu(pl_alu),
    .res_alu(alu_out), 
    .is_eq(alu_eq_flag)
);

SRAM64X16 u_sram_inst (
    .A0(mem_a[0]), .A1(mem_a[1]), .A2(mem_a[2]), .A3(mem_a[3]), .A4(mem_a[4]), .A5(mem_a[5]), 
    .DO0(mem_do[0]), .DO1(mem_do[1]), .DO2(mem_do[2]), .DO3(mem_do[3]), .DO4(mem_do[4]), .DO5(mem_do[5]), 
    .DO6(mem_do[6]), .DO7(mem_do[7]), .DO8(mem_do[8]), .DO9(mem_do[9]), .DO10(mem_do[10]), .DO11(mem_do[11]), 
    .DO12(mem_do[12]), .DO13(mem_do[13]), .DO14(mem_do[14]), .DO15(mem_do[15]), 
    .DI0(mem_di[0]), .DI1(mem_di[1]), .DI2(mem_di[2]), .DI3(mem_di[3]), .DI4(mem_di[4]), .DI5(mem_di[5]), 
    .DI6(mem_di[6]), .DI7(mem_di[7]), .DI8(mem_di[8]), .DI9(mem_di[9]), .DI10(mem_di[10]), .DI11(mem_di[11]), 
    .DI12(mem_di[12]), .DI13(mem_di[13]), .DI14(mem_di[14]), .DI15(mem_di[15]), 
    .CK(clk), .WEB(~mem_we), .OE(1'b1), .CS(mem_cs) 
);

endmodule


module BOOTH_MULT (
    input clk,
    input rst_n,
    input clr,
    input start,
    input shift,
    input [15:0] rs_v,
    input [15:0] rt_v,
    output [4:0] step_cnt,
    output [31:0] mult_final
);

reg [4:0] cnt;
reg [31:0] p_reg;
reg p_last;
reg [15:0] mcand;

assign step_cnt = cnt;
assign mult_final = p_reg;

wire [15:0] p_high = p_reg[31:16];
wire [15:0] p_low  = p_reg[15:0];

wire [1:0] action = {p_low[0], p_last};

wire [15:0] add_val = (action == 2'b01) ? mcand : (action == 2'b10) ? ~mcand : 16'd0;
wire        add_cin = (action == 2'b10);

wire [15:0] new_high = p_high + add_val + {15'd0, add_cin};
wire [32:0] shift_in = {new_high[15], new_high, p_low};

wire [4:0]  nxt_cnt    = clr ? 5'd0 : (start ? 5'd0 : (shift ? cnt + 5'd1 : cnt));
wire [31:0] nxt_p_reg  = clr ? 32'd0 : (start ? {16'd0, rt_v} : (shift ? shift_in[32:1] : p_reg));
wire        nxt_p_last = clr ? 1'b0 : (start ? 1'b0 : (shift ? shift_in[0] : p_last));
wire [15:0] nxt_mcand  = clr ? 16'd0 : (start ? rs_v : mcand);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 5'd0;
        p_reg <= 32'd0;
        p_last <= 1'b0;
        mcand <= 16'd0;
    end else begin
        cnt <= nxt_cnt;
        p_reg <= nxt_p_reg;
        p_last <= nxt_p_last;
        mcand <= nxt_mcand;
    end
end
endmodule


module DEC_CORE (
    i_inst, o_op, o_rs, o_rt, o_rd, o_fn, o_rl, o_imm, o_j, f_alu, f_st, f_ld, f_mul, f_imm_op, f_sub_op
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
output f_imm_op;
output f_sub_op;

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
wire f_imm_op;
wire f_sub_op;

assign o_op  = i_inst[15:13];
assign o_rs  = i_inst[12:10];
assign o_rt  = i_inst[9:7];
assign o_rd  = i_inst[6:4];
assign o_fn  = i_inst[3:1];
assign o_rl  = i_inst[3:1];
assign o_imm = {{9{i_inst[6]}}, i_inst[6:0]};
assign o_j   = i_inst[12:0];

assign f_alu = (o_op == 3'b000) || (o_op == 3'b010) || (o_op == 3'b011);
assign f_st  = (o_op == 3'b101);
assign f_ld  = (o_op == 3'b100);
assign f_mul = (o_op == 3'b001);
assign f_imm_op = (o_op == 3'b010) || (o_op == 3'b011) || (o_op == 3'b100) || (o_op == 3'b101);
assign f_sub_op = (o_op == 3'b011) || (o_op == 3'b110) ||
                  (o_op == 3'b000 && (o_fn == 3'b001 || o_fn == 3'b111));

endmodule


module ALU_CORE (
    c_op, c_fn, c_is_imm, c_is_sub, v_rs, v_rt, v_imm, pl_alu, res_alu, is_eq
);

input [2:0] c_op;
input [2:0] c_fn;
input c_is_imm;
input c_is_sub;
input [15:0] v_rs;
input [15:0] v_rt;
input [15:0] v_imm;
input pl_alu;
output [15:0] res_alu;
output is_eq;

wire [15:0] res_alu;
wire is_eq;

wire [15:0] iso_rs  = pl_alu ? v_rs : 16'd0;
wire [15:0] iso_rt  = pl_alu ? v_rt : 16'd0;
wire [15:0] iso_imm = pl_alu ? v_imm : 16'd0;

wire [15:0] arg_a = iso_rs;
wire [15:0] arg_b = (c_is_imm ? iso_imm : iso_rt) ^ {16{c_is_sub & pl_alu}};
wire arg_cin = c_is_sub & pl_alu;
wire [15:0] a_sum = arg_a + arg_b + {15'd0, arg_cin};
wire s_slt = (iso_rs[15] != iso_rt[15]) ? iso_rs[15] : a_sum[15];

reg [15:0] out_buf;

always @(*) begin
    if (!pl_alu) begin
        out_buf = 16'd0;
    end else begin
        case (c_op)
            3'b000: begin
                case(c_fn)
                    3'b000, 3'b001: out_buf = a_sum;
                    3'b010:         out_buf = iso_rs & iso_rt;
                    3'b011:         out_buf = iso_rs | iso_rt;
                    3'b100:         out_buf = ~(iso_rs & iso_rt);
                    3'b101:         out_buf = ~(iso_rs | iso_rt);
                    3'b110:         out_buf = iso_rs ^ iso_rt;
                    3'b111:         out_buf = {15'd0, s_slt};
                endcase
            end
            3'b010, 3'b011: out_buf = a_sum;
            default:        out_buf = 16'd0;
        endcase
    end
end

assign is_eq = (v_rs == v_rt);
assign res_alu = out_buf;

endmodule