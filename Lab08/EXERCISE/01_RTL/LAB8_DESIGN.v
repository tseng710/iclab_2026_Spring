// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on



module LAB8_DESIGN(
    // input signals
    clk,
    rst_n,
	
    in_valid,
	in_data,

	cg_en,
	  
    // output signals
	out_valid,	
	out_data
);

input              clk;
input              rst_n;

input              in_valid;
input       [7:0]  in_data;

input              cg_en;

output reg         out_valid;
output reg  [11:0]  out_data;

//==================================================================
// parameter & integer
//==================================================================

localparam S_IDLE = 2'd0, S_IN   = 2'd1,  S_OUT  = 2'd2;

//==================================================================
// reg & wire
//==================================================================
            
reg [1:0] state;
reg [6:0] in_cnt;
reg [4:0] out_cnt;
reg       task_num;

reg [7:0]  A [0:15];
reg [7:0]  B [0:15];
reg [3:0]  F1[0:15];
reg [3:0]  H1[0:15];
reg [3:0]  F2[0:15];
reg [3:0]  H2[0:15];
reg [11:0] Mid_Reg [0:15];

wire [6:0] t0_p1_idx_full;
wire [3:0] op_idx;

wire       is_T0_P1;
wire       is_T0_P2;
wire       is_T1_P1;
wire       is_T1_P2;

wire       op_active;
wire       use_1;

wire [1:0] r;
wire [1:0] c;

wire       sel_A;
wire       sel_B;

wire [3:0] cur_f0, cur_f1, cur_f2, cur_f3;
wire [3:0] cur_h0, cur_h1, cur_h2, cur_h3;
wire [11:0] cur_m0, cur_m1, cur_m2, cur_m3;
wire [7:0]  cur_aux;

wire [3:0] mac_left_f_0, mac_left_f_1, mac_left_f_2, mac_left_f_3;
wire [3:0] mac_left_h_0, mac_left_h_1, mac_left_h_2, mac_left_h_3;
wire [11:0] mac_right_0, mac_right_1, mac_right_2, mac_right_3;

wire [17:0] mac_f_out;
wire [17:0] mac_h_out;

wire [3:0]  mod15_out;
wire [3:0]  alu_X;
wire [7:0]  alu_Y;
wire [11:0] alu_out;

wire        out_valid_next;
wire [11:0] out_data_next;


//==================================================================
// design
//==================================================================

assign t0_p1_idx_full = in_cnt - 7'd65;

assign is_T0_P1 = (~task_num) & (state == S_IN)  & (in_cnt >= 7'd65) & (in_cnt <= 7'd80);
assign is_T0_P2 = (~task_num) & (state == S_OUT) & (~out_cnt[4]); 
assign is_T1_P1 = (task_num)  & (state == S_OUT) & (~out_cnt[4]);
assign is_T1_P2 = (task_num)  & (state == S_OUT) & (out_cnt[4]);

assign op_active = is_T0_P1 | is_T0_P2 | is_T1_P1 | is_T1_P2;
assign op_idx    = is_T0_P1 ? t0_p1_idx_full[3:0] : out_cnt[3:0];
assign use_1     = is_T0_P1 | is_T1_P2;

assign r = op_idx[3:2];
assign c = op_idx[1:0];

assign cur_f0 = use_1 ? F1[{r, 2'd0}] : F2[{r, 2'd0}];
assign cur_f1 = use_1 ? F1[{r, 2'd1}] : F2[{r, 2'd1}];
assign cur_f2 = use_1 ? F1[{r, 2'd2}] : F2[{r, 2'd2}];
assign cur_f3 = use_1 ? F1[{r, 2'd3}] : F2[{r, 2'd3}];

assign cur_h0 = use_1 ? H1[{r, 2'd0}] : H2[{r, 2'd0}];
assign cur_h1 = use_1 ? H1[{r, 2'd1}] : H2[{r, 2'd1}];
assign cur_h2 = use_1 ? H1[{r, 2'd2}] : H2[{r, 2'd2}];
assign cur_h3 = use_1 ? H1[{r, 2'd3}] : H2[{r, 2'd3}];

assign mac_left_f_0 = op_active ? cur_f0 : 4'd0;
assign mac_left_f_1 = op_active ? cur_f1 : 4'd0;
assign mac_left_f_2 = op_active ? cur_f2 : 4'd0;
assign mac_left_f_3 = op_active ? cur_f3 : 4'd0;

assign mac_left_h_0 = op_active ? cur_h0 : 4'd0;
assign mac_left_h_1 = op_active ? cur_h1 : 4'd0;
assign mac_left_h_2 = op_active ? cur_h2 : 4'd0;
assign mac_left_h_3 = op_active ? cur_h3 : 4'd0;

assign sel_A = is_T0_P1;
assign sel_B = is_T1_P1;

assign cur_m0 = sel_A ? {4'd0, A[{2'd0, c}]} : sel_B ? {4'd0, B[{2'd0, c}]} : Mid_Reg[{2'd0, c}];
assign cur_m1 = sel_A ? {4'd0, A[{2'd1, c}]} : sel_B ? {4'd0, B[{2'd1, c}]} : Mid_Reg[{2'd1, c}];
assign cur_m2 = sel_A ? {4'd0, A[{2'd2, c}]} : sel_B ? {4'd0, B[{2'd2, c}]} : Mid_Reg[{2'd2, c}];
assign cur_m3 = sel_A ? {4'd0, A[{2'd3, c}]} : sel_B ? {4'd0, B[{2'd3, c}]} : Mid_Reg[{2'd3, c}];

assign mac_right_0 = op_active ? cur_m0 : 12'd0;
assign mac_right_1 = op_active ? cur_m1 : 12'd0;
assign mac_right_2 = op_active ? cur_m2 : 12'd0;
assign mac_right_3 = op_active ? cur_m3 : 12'd0;

assign cur_aux = use_1 ? B[op_idx] : A[op_idx];

MAC_4x12 MAC_F (
    .f0(mac_left_f_0), .f1(mac_left_f_1), .f2(mac_left_f_2), .f3(mac_left_f_3),
    .m0(mac_right_0),  .m1(mac_right_1),  .m2(mac_right_2),  .m3(mac_right_3),
    .out(mac_f_out)
);

MAC_4x12 MAC_H (
    .f0(mac_left_h_0), .f1(mac_left_h_1), .f2(mac_left_h_2), .f3(mac_left_h_3),
    .m0(mac_right_0),  .m1(mac_right_1),  .m2(mac_right_2),  .m3(mac_right_3),
    .out(mac_h_out)
);

MOD_15 M15 (.in(mac_f_out), .out(mod15_out));

assign alu_X = op_active ? (mod15_out + 4'd1) : 4'd1;
assign alu_Y = op_active ? mac_h_out[7:0]   : 8'd0;

CORE_ALU ALU_INST (
    .task_num(task_num),
    .en(op_active),
    .X(alu_X),
    .Y(alu_Y),
    .Aux(cur_aux),
    .result(alu_out)
);

assign out_valid_next = (state == S_OUT);
assign out_data_next  = (~out_cnt[4]) ? alu_out :
                        (~task_num) ? Mid_Reg[out_cnt[3:0]] : alu_out;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state     <= S_IDLE;
        in_cnt    <= 7'd0;
        out_cnt   <= 5'd0;
        out_valid <= 1'b0;
        out_data  <= 12'd0;
        task_num  <= 1'b0;
    end 
    else begin
        if (state == S_IDLE) begin
            if (in_valid) begin
                state    <= S_IN;
                in_cnt   <= in_cnt + 7'd1;
                task_num <= in_data[0];
            end
        end 
        else if (state == S_IN) begin
            if (in_valid) begin
                in_cnt <= in_cnt + 7'd1;
                if (in_cnt == 7'd96) begin
                    state   <= S_OUT;
                    out_cnt <= 5'd0;
                end
            end
        end 
        else if (state == S_OUT) begin
            out_cnt <= out_cnt + 5'd1;
            if (out_cnt == 5'd31) begin
                state  <= S_IDLE;
                in_cnt <= 7'd0;
            end
        end
        
        out_valid <= out_valid_next;
        out_data  <= out_valid_next ? out_data_next : 12'd0;
    end
end

genvar idx;
generate
    for (idx = 0; idx < 16; idx = idx + 1) begin : gen_cg
        
        wire sleep_A;
        wire sleep_B;
        wire sleep_F1;
        wire sleep_H1;
        wire sleep_F2;
        wire sleep_H2;
        wire write_mid;
        wire sleep_Mid;
        
        wire clk_A;
        wire clk_B;
        wire clk_F1;
        wire clk_H1;
        wire clk_F2;
        wire clk_H2;
        wire clk_Mid;
        
        assign sleep_A   = cg_en & ~(in_valid & in_cnt == (idx + 1));
        assign sleep_B   = cg_en & ~(in_valid & in_cnt == (idx + 17));
        assign sleep_F1  = cg_en & ~(in_valid & in_cnt == (idx + 33));
        assign sleep_H1  = cg_en & ~(in_valid & in_cnt == (idx + 49));
        assign sleep_F2  = cg_en & ~(in_valid & in_cnt == (idx + 65));
        assign sleep_H2  = cg_en & ~(in_valid & in_cnt == (idx + 81));
        
        assign write_mid = is_T0_P1 | is_T1_P1;
        assign sleep_Mid = cg_en & ~(write_mid & (op_idx == idx[3:0]));
        
        GATED_OR GATED_A  (.CLOCK(clk), .SLEEP_CTRL(sleep_A),  .RST_N(rst_n), .CLOCK_GATED(clk_A));
        GATED_OR GATED_B  (.CLOCK(clk), .SLEEP_CTRL(sleep_B),  .RST_N(rst_n), .CLOCK_GATED(clk_B));
        GATED_OR GATED_F1 (.CLOCK(clk), .SLEEP_CTRL(sleep_F1), .RST_N(rst_n), .CLOCK_GATED(clk_F1));
        GATED_OR GATED_H1 (.CLOCK(clk), .SLEEP_CTRL(sleep_H1), .RST_N(rst_n), .CLOCK_GATED(clk_H1));
        GATED_OR GATED_F2 (.CLOCK(clk), .SLEEP_CTRL(sleep_F2), .RST_N(rst_n), .CLOCK_GATED(clk_F2));
        GATED_OR GATED_H2 (.CLOCK(clk), .SLEEP_CTRL(sleep_H2), .RST_N(rst_n), .CLOCK_GATED(clk_H2));
        GATED_OR GATED_Mid(.CLOCK(clk), .SLEEP_CTRL(sleep_Mid),.RST_N(rst_n), .CLOCK_GATED(clk_Mid));
        
        always @(posedge clk_A or negedge rst_n) begin
            if (!rst_n) A[idx] <= 8'd0; 
            else if (in_valid && in_cnt == (idx + 1)) A[idx] <= in_data;
        end
            
        always @(posedge clk_B or negedge rst_n) begin
            if (!rst_n) B[idx] <= 8'd0; 
            else if (in_valid && in_cnt == (idx + 17)) B[idx] <= in_data;
        end
            
        always @(posedge clk_F1 or negedge rst_n) begin
            if (!rst_n) F1[idx] <= 4'd0; 
            else if (in_valid && in_cnt == (idx + 33)) F1[idx] <= in_data[3:0];
        end
            
        always @(posedge clk_H1 or negedge rst_n) begin
            if (!rst_n) H1[idx] <= 4'd0; 
            else if (in_valid && in_cnt == (idx + 49)) H1[idx] <= in_data[3:0];
        end
            
        always @(posedge clk_F2 or negedge rst_n) begin
            if (!rst_n) F2[idx] <= 4'd0; 
            else if (in_valid && in_cnt == (idx + 65)) F2[idx] <= in_data[3:0];
        end
            
        always @(posedge clk_H2 or negedge rst_n) begin
            if (!rst_n) H2[idx] <= 4'd0; 
            else if (in_valid && in_cnt == (idx + 81)) H2[idx] <= in_data[3:0];
        end

        always @(posedge clk_Mid or negedge rst_n) begin
            if (!rst_n) Mid_Reg[idx] <= 12'd0;
            else if (write_mid && (op_idx == idx[3:0])) Mid_Reg[idx] <= alu_out;
        end
    end
endgenerate

endmodule

module MAC_4x12(
    input  [3:0]  f0, f1, f2, f3,
    input  [11:0] m0, m1, m2, m3,
    output [17:0] out
);
wire [17:0] p0 = f0 * m0;
wire [17:0] p1 = f1 * m1;
wire [17:0] p2 = f2 * m2;
wire [17:0] p3 = f3 * m3;

assign out = p0 + p1 + p2 + p3;
endmodule

module MOD_15(
    input  [17:0] in,
    output [3:0]  out
);

wire [7:0] s1 = in[3:0] + in[7:4] + in[11:8] + in[15:12] + in[17:16];
wire [4:0] s2 = s1[3:0] + s1[7:4];
wire [4:0] s3 = s2[3:0] + s2[4];

assign out = (s3 >= 5'd15) ? (s3 - 5'd15) : s3[3:0];

endmodule

module CORE_ALU(
    input         task_num,
    input         en,
    input  [3:0]  X,
    input  [7:0]  Y,
    input  [7:0]  Aux,
    output [11:0] result
);

wire [3:0]  mult_X = (en && !task_num) ? X : 4'd0;
wire [7:0]  mult_A = (en && !task_num) ? Aux : 8'd0;
wire [11:0] mult_op = mult_X * mult_A;
wire [11:0] task0_res = mult_op ^ {4'd0, Y};

wire [7:0]  xor_op = Aux ^ Y;
wire [7:0]  div_N  = (en && task_num) ? xor_op : 8'd0;
wire [3:0]  div_D  = (en && task_num) ? X : 4'd1; 
wire [7:0]  div_op = div_N / div_D;
wire [11:0] task1_res = {4'd0, div_op};

assign result = task_num ? task1_res : task0_res;
endmodule
