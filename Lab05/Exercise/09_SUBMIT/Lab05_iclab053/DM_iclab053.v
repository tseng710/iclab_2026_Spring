module DM(
    clk,
    rst_n,
    i_valid,
    i_iter,
    i_mode,
    i_data,
    i_weight,
    o_valid,
    o_data
);

input       clk, rst_n, i_valid;
input       [7:0] i_data;
input       [2:0] i_iter;
input       [1:0] i_mode;
input       [3:0] i_weight;
output reg  o_valid;
output reg  [7:0] o_data;

// ------------------------------------------------------------------------------
// 1. Parameters & State Definition
// ------------------------------------------------------------------------------
parameter IDLE       = 4'd0;
parameter LOAD_W     = 4'd1;
parameter LOAD_IMG   = 4'd2;
parameter CONV_DN    = 4'd3;
parameter PROJ_QKV   = 4'd4;
parameter ATTN_CALC  = 4'd5;
parameter FFN_CALC   = 4'd6;  
parameter CONV_UP    = 4'd7;
parameter INTERP_OUT = 4'd8;  
parameter NXT_ITR    = 4'd9; 

reg [3:0] curr_st, next_st;

// ------------------------------------------------------------------------------
// 2. System Control Registers
// ------------------------------------------------------------------------------
reg [2:0]  reg_target_iter;
reg [2:0]  reg_curr_iter;
reg [1:0]  reg_saved_mode;
reg        flag_wt_loaded;

reg [12:0] cnt_load;
reg [1:0]  cnt_img_pack;
reg [8:0]  cnt_pixel;
reg [9:0]  cnt_step;  
reg [10:0] cnt_w;      
reg [4:0]  cnt_w_ch;
reg [4:0]  cnt_w_idx;
reg [3:0]  ptr_w_qkv;

reg        val_dn_d1;
reg        val_dn_d2;
reg        val_up_d1;
reg        val_up_d2;
reg        val_up_d3;
reg [11:0] img_idx_d1;
reg [11:0] img_idx_d2;

integer idx_i, idx_j;

// ------------------------------------------------------------------------------
// 3. Shared Memory & Registers 
// ------------------------------------------------------------------------------
reg  [9:0]   sram_img_A;
reg  [31:0]  sram_img_DI;
wire [31:0]  sram_img_DO;
reg          sram_img_WEB;

reg  [8:0]   sram_fmA_A;
reg  [127:0] sram_fmA_DI;
wire [127:0] sram_fmA_DO;
reg          sram_fmA_WEB;

reg  [8:0]   sram_fmB_A;
reg  [127:0] sram_fmB_DI;
wire [127:0] sram_fmB_DO;
reg          sram_fmB_WEB;

// Unrolled Shared Buffers
reg [127:0]  sh_buf_0;
reg [127:0]  sh_buf_1;
reg [127:0]  sh_buf_2;
reg [127:0]  sh_buf_3;

reg [127:0]  sram_rd_buf_A;
reg [127:0]  sram_rd_buf_B;
reg [127:0]  V_reg_pipeline;

reg [7:0]    fx_reg0;
reg [7:0]    fx_reg1;
reg [7:0]    fx_reg2;
reg [7:0]    fx_reg3;

// Unrolled Accumulator Arrays
reg signed [24:0] sh_acc_0 [0:15];
reg signed [24:0] sh_acc_1 [0:15];
reg signed [24:0] sh_acc_2 [0:15];
reg signed [24:0] sh_acc_3 [0:15];

// ------------------------------------------------------------------------------
// 4. SRAM Instantiations (Expanded Port Mapping)
// ------------------------------------------------------------------------------
SUMA180_1024X32X1BM2 u_img_sram (
    .A0(sram_img_A[0]),   .A1(sram_img_A[1]),   .A2(sram_img_A[2]),   .A3(sram_img_A[3]), 
    .A4(sram_img_A[4]),   .A5(sram_img_A[5]),   .A6(sram_img_A[6]),   .A7(sram_img_A[7]), 
    .A8(sram_img_A[8]),   .A9(sram_img_A[9]),
    .DO0(sram_img_DO[0]), .DO1(sram_img_DO[1]), .DO2(sram_img_DO[2]), .DO3(sram_img_DO[3]), 
    .DO4(sram_img_DO[4]), .DO5(sram_img_DO[5]), .DO6(sram_img_DO[6]), .DO7(sram_img_DO[7]),
    .DO8(sram_img_DO[8]), .DO9(sram_img_DO[9]), .DO10(sram_img_DO[10]),.DO11(sram_img_DO[11]), 
    .DO12(sram_img_DO[12]),.DO13(sram_img_DO[13]),.DO14(sram_img_DO[14]),.DO15(sram_img_DO[15]),
    .DO16(sram_img_DO[16]),.DO17(sram_img_DO[17]),.DO18(sram_img_DO[18]),.DO19(sram_img_DO[19]), 
    .DO20(sram_img_DO[20]),.DO21(sram_img_DO[21]),.DO22(sram_img_DO[22]),.DO23(sram_img_DO[23]),
    .DO24(sram_img_DO[24]),.DO25(sram_img_DO[25]),.DO26(sram_img_DO[26]),.DO27(sram_img_DO[27]), 
    .DO28(sram_img_DO[28]),.DO29(sram_img_DO[29]),.DO30(sram_img_DO[30]),.DO31(sram_img_DO[31]),
    .DI0(sram_img_DI[0]), .DI1(sram_img_DI[1]), .DI2(sram_img_DI[2]), .DI3(sram_img_DI[3]), 
    .DI4(sram_img_DI[4]), .DI5(sram_img_DI[5]), .DI6(sram_img_DI[6]), .DI7(sram_img_DI[7]),
    .DI8(sram_img_DI[8]), .DI9(sram_img_DI[9]), .DI10(sram_img_DI[10]),.DI11(sram_img_DI[11]), 
    .DI12(sram_img_DI[12]),.DI13(sram_img_DI[13]),.DI14(sram_img_DI[14]),.DI15(sram_img_DI[15]),
    .DI16(sram_img_DI[16]),.DI17(sram_img_DI[17]),.DI18(sram_img_DI[18]),.DI19(sram_img_DI[19]), 
    .DI20(sram_img_DI[20]),.DI21(sram_img_DI[21]),.DI22(sram_img_DI[22]),.DI23(sram_img_DI[23]),
    .DI24(sram_img_DI[24]),.DI25(sram_img_DI[25]),.DI26(sram_img_DI[26]),.DI27(sram_img_DI[27]), 
    .DI28(sram_img_DI[28]),.DI29(sram_img_DI[29]),.DI30(sram_img_DI[30]),.DI31(sram_img_DI[31]),
    .WEB(sram_img_WEB), .OE(1'b1), .CS(1'b1), .CK(clk)
);

SRAM_512x128 u_fmA_sram (
    .A0(sram_fmA_A[0]), .A1(sram_fmA_A[1]), .A2(sram_fmA_A[2]), .A3(sram_fmA_A[3]), 
    .A4(sram_fmA_A[4]), .A5(sram_fmA_A[5]), .A6(sram_fmA_A[6]), .A7(sram_fmA_A[7]), .A8(sram_fmA_A[8]),
    .DO0(sram_fmA_DO[0]), .DO1(sram_fmA_DO[1]), .DO2(sram_fmA_DO[2]), .DO3(sram_fmA_DO[3]), 
    .DO4(sram_fmA_DO[4]), .DO5(sram_fmA_DO[5]), .DO6(sram_fmA_DO[6]), .DO7(sram_fmA_DO[7]), 
    .DO8(sram_fmA_DO[8]), .DO9(sram_fmA_DO[9]), .DO10(sram_fmA_DO[10]), .DO11(sram_fmA_DO[11]), 
    .DO12(sram_fmA_DO[12]), .DO13(sram_fmA_DO[13]), .DO14(sram_fmA_DO[14]), .DO15(sram_fmA_DO[15]),
    .DO16(sram_fmA_DO[16]), .DO17(sram_fmA_DO[17]), .DO18(sram_fmA_DO[18]), .DO19(sram_fmA_DO[19]), 
    .DO20(sram_fmA_DO[20]), .DO21(sram_fmA_DO[21]), .DO22(sram_fmA_DO[22]), .DO23(sram_fmA_DO[23]), 
    .DO24(sram_fmA_DO[24]), .DO25(sram_fmA_DO[25]), .DO26(sram_fmA_DO[26]), .DO27(sram_fmA_DO[27]), 
    .DO28(sram_fmA_DO[28]), .DO29(sram_fmA_DO[29]), .DO30(sram_fmA_DO[30]), .DO31(sram_fmA_DO[31]),
    .DO32(sram_fmA_DO[32]), .DO33(sram_fmA_DO[33]), .DO34(sram_fmA_DO[34]), .DO35(sram_fmA_DO[35]), 
    .DO36(sram_fmA_DO[36]), .DO37(sram_fmA_DO[37]), .DO38(sram_fmA_DO[38]), .DO39(sram_fmA_DO[39]), 
    .DO40(sram_fmA_DO[40]), .DO41(sram_fmA_DO[41]), .DO42(sram_fmA_DO[42]), .DO43(sram_fmA_DO[43]), 
    .DO44(sram_fmA_DO[44]), .DO45(sram_fmA_DO[45]), .DO46(sram_fmA_DO[46]), .DO47(sram_fmA_DO[47]),
    .DO48(sram_fmA_DO[48]), .DO49(sram_fmA_DO[49]), .DO50(sram_fmA_DO[50]), .DO51(sram_fmA_DO[51]), 
    .DO52(sram_fmA_DO[52]), .DO53(sram_fmA_DO[53]), .DO54(sram_fmA_DO[54]), .DO55(sram_fmA_DO[55]), 
    .DO56(sram_fmA_DO[56]), .DO57(sram_fmA_DO[57]), .DO58(sram_fmA_DO[58]), .DO59(sram_fmA_DO[59]), 
    .DO60(sram_fmA_DO[60]), .DO61(sram_fmA_DO[61]), .DO62(sram_fmA_DO[62]), .DO63(sram_fmA_DO[63]),
    .DO64(sram_fmA_DO[64]), .DO65(sram_fmA_DO[65]), .DO66(sram_fmA_DO[66]), .DO67(sram_fmA_DO[67]), 
    .DO68(sram_fmA_DO[68]), .DO69(sram_fmA_DO[69]), .DO70(sram_fmA_DO[70]), .DO71(sram_fmA_DO[71]), 
    .DO72(sram_fmA_DO[72]), .DO73(sram_fmA_DO[73]), .DO74(sram_fmA_DO[74]), .DO75(sram_fmA_DO[75]), 
    .DO76(sram_fmA_DO[76]), .DO77(sram_fmA_DO[77]), .DO78(sram_fmA_DO[78]), .DO79(sram_fmA_DO[79]),
    .DO80(sram_fmA_DO[80]), .DO81(sram_fmA_DO[81]), .DO82(sram_fmA_DO[82]), .DO83(sram_fmA_DO[83]), 
    .DO84(sram_fmA_DO[84]), .DO85(sram_fmA_DO[85]), .DO86(sram_fmA_DO[86]), .DO87(sram_fmA_DO[87]), 
    .DO88(sram_fmA_DO[88]), .DO89(sram_fmA_DO[89]), .DO90(sram_fmA_DO[90]), .DO91(sram_fmA_DO[91]), 
    .DO92(sram_fmA_DO[92]), .DO93(sram_fmA_DO[93]), .DO94(sram_fmA_DO[94]), .DO95(sram_fmA_DO[95]),
    .DO96(sram_fmA_DO[96]), .DO97(sram_fmA_DO[97]), .DO98(sram_fmA_DO[98]), .DO99(sram_fmA_DO[99]), 
    .DO100(sram_fmA_DO[100]), .DO101(sram_fmA_DO[101]), .DO102(sram_fmA_DO[102]), .DO103(sram_fmA_DO[103]), 
    .DO104(sram_fmA_DO[104]), .DO105(sram_fmA_DO[105]), .DO106(sram_fmA_DO[106]), .DO107(sram_fmA_DO[107]), 
    .DO108(sram_fmA_DO[108]), .DO109(sram_fmA_DO[109]), .DO110(sram_fmA_DO[110]), .DO111(sram_fmA_DO[111]),
    .DO112(sram_fmA_DO[112]), .DO113(sram_fmA_DO[113]), .DO114(sram_fmA_DO[114]), .DO115(sram_fmA_DO[115]), 
    .DO116(sram_fmA_DO[116]), .DO117(sram_fmA_DO[117]), .DO118(sram_fmA_DO[118]), .DO119(sram_fmA_DO[119]), 
    .DO120(sram_fmA_DO[120]), .DO121(sram_fmA_DO[121]), .DO122(sram_fmA_DO[122]), .DO123(sram_fmA_DO[123]), 
    .DO124(sram_fmA_DO[124]), .DO125(sram_fmA_DO[125]), .DO126(sram_fmA_DO[126]), .DO127(sram_fmA_DO[127]),
    .DI0(sram_fmA_DI[0]), .DI1(sram_fmA_DI[1]), .DI2(sram_fmA_DI[2]), .DI3(sram_fmA_DI[3]), 
    .DI4(sram_fmA_DI[4]), .DI5(sram_fmA_DI[5]), .DI6(sram_fmA_DI[6]), .DI7(sram_fmA_DI[7]), 
    .DI8(sram_fmA_DI[8]), .DI9(sram_fmA_DI[9]), .DI10(sram_fmA_DI[10]), .DI11(sram_fmA_DI[11]), 
    .DI12(sram_fmA_DI[12]), .DI13(sram_fmA_DI[13]), .DI14(sram_fmA_DI[14]), .DI15(sram_fmA_DI[15]),
    .DI16(sram_fmA_DI[16]), .DI17(sram_fmA_DI[17]), .DI18(sram_fmA_DI[18]), .DI19(sram_fmA_DI[19]), 
    .DI20(sram_fmA_DI[20]), .DI21(sram_fmA_DI[21]), .DI22(sram_fmA_DI[22]), .DI23(sram_fmA_DI[23]), 
    .DI24(sram_fmA_DI[24]), .DI25(sram_fmA_DI[25]), .DI26(sram_fmA_DI[26]), .DI27(sram_fmA_DI[27]), 
    .DI28(sram_fmA_DI[28]), .DI29(sram_fmA_DI[29]), .DI30(sram_fmA_DI[30]), .DI31(sram_fmA_DI[31]),
    .DI32(sram_fmA_DI[32]), .DI33(sram_fmA_DI[33]), .DI34(sram_fmA_DI[34]), .DI35(sram_fmA_DI[35]), 
    .DI36(sram_fmA_DI[36]), .DI37(sram_fmA_DI[37]), .DI38(sram_fmA_DI[38]), .DI39(sram_fmA_DI[39]), 
    .DI40(sram_fmA_DI[40]), .DI41(sram_fmA_DI[41]), .DI42(sram_fmA_DI[42]), .DI43(sram_fmA_DI[43]), 
    .DI44(sram_fmA_DI[44]), .DI45(sram_fmA_DI[45]), .DI46(sram_fmA_DI[46]), .DI47(sram_fmA_DI[47]),
    .DI48(sram_fmA_DI[48]), .DI49(sram_fmA_DI[49]), .DI50(sram_fmA_DI[50]), .DI51(sram_fmA_DI[51]), 
    .DI52(sram_fmA_DI[52]), .DI53(sram_fmA_DI[53]), .DI54(sram_fmA_DI[54]), .DI55(sram_fmA_DI[55]), 
    .DI56(sram_fmA_DI[56]), .DI57(sram_fmA_DI[57]), .DI58(sram_fmA_DI[58]), .DI59(sram_fmA_DI[59]), 
    .DI60(sram_fmA_DI[60]), .DI61(sram_fmA_DI[61]), .DI62(sram_fmA_DI[62]), .DI63(sram_fmA_DI[63]),
    .DI64(sram_fmA_DI[64]), .DI65(sram_fmA_DI[65]), .DI66(sram_fmA_DI[66]), .DI67(sram_fmA_DI[67]), 
    .DI68(sram_fmA_DI[68]), .DI69(sram_fmA_DI[69]), .DI70(sram_fmA_DI[70]), .DI71(sram_fmA_DI[71]), 
    .DI72(sram_fmA_DI[72]), .DI73(sram_fmA_DI[73]), .DI74(sram_fmA_DI[74]), .DI75(sram_fmA_DI[75]), 
    .DI76(sram_fmA_DI[76]), .DI77(sram_fmA_DI[77]), .DI78(sram_fmA_DI[78]), .DI79(sram_fmA_DI[79]),
    .DI80(sram_fmA_DI[80]), .DI81(sram_fmA_DI[81]), .DI82(sram_fmA_DI[82]), .DI83(sram_fmA_DI[83]), 
    .DI84(sram_fmA_DI[84]), .DI85(sram_fmA_DI[85]), .DI86(sram_fmA_DI[86]), .DI87(sram_fmA_DI[87]), 
    .DI88(sram_fmA_DI[88]), .DI89(sram_fmA_DI[89]), .DI90(sram_fmA_DI[90]), .DI91(sram_fmA_DI[91]), 
    .DI92(sram_fmA_DI[92]), .DI93(sram_fmA_DI[93]), .DI94(sram_fmA_DI[94]), .DI95(sram_fmA_DI[95]),
    .DI96(sram_fmA_DI[96]), .DI97(sram_fmA_DI[97]), .DI98(sram_fmA_DI[98]), .DI99(sram_fmA_DI[99]), 
    .DI100(sram_fmA_DI[100]), .DI101(sram_fmA_DI[101]), .DI102(sram_fmA_DI[102]), .DI103(sram_fmA_DI[103]), 
    .DI104(sram_fmA_DI[104]), .DI105(sram_fmA_DI[105]), .DI106(sram_fmA_DI[106]), .DI107(sram_fmA_DI[107]), 
    .DI108(sram_fmA_DI[108]), .DI109(sram_fmA_DI[109]), .DI110(sram_fmA_DI[110]), .DI111(sram_fmA_DI[111]),
    .DI112(sram_fmA_DI[112]), .DI113(sram_fmA_DI[113]), .DI114(sram_fmA_DI[114]), .DI115(sram_fmA_DI[115]), 
    .DI116(sram_fmA_DI[116]), .DI117(sram_fmA_DI[117]), .DI118(sram_fmA_DI[118]), .DI119(sram_fmA_DI[119]), 
    .DI120(sram_fmA_DI[120]), .DI121(sram_fmA_DI[121]), .DI122(sram_fmA_DI[122]), .DI123(sram_fmA_DI[123]), 
    .DI124(sram_fmA_DI[124]), .DI125(sram_fmA_DI[125]), .DI126(sram_fmA_DI[126]), .DI127(sram_fmA_DI[127]),
    .WEB(sram_fmA_WEB), .OE(1'b1), .CS(1'b1), .CK(clk)
);

SRAM_512x128 u_fmB_sram (
    .A0(sram_fmB_A[0]), .A1(sram_fmB_A[1]), .A2(sram_fmB_A[2]), .A3(sram_fmB_A[3]), 
    .A4(sram_fmB_A[4]), .A5(sram_fmB_A[5]), .A6(sram_fmB_A[6]), .A7(sram_fmB_A[7]), .A8(sram_fmB_A[8]),
    .DO0(sram_fmB_DO[0]), .DO1(sram_fmB_DO[1]), .DO2(sram_fmB_DO[2]), .DO3(sram_fmB_DO[3]), 
    .DO4(sram_fmB_DO[4]), .DO5(sram_fmB_DO[5]), .DO6(sram_fmB_DO[6]), .DO7(sram_fmB_DO[7]), 
    .DO8(sram_fmB_DO[8]), .DO9(sram_fmB_DO[9]), .DO10(sram_fmB_DO[10]), .DO11(sram_fmB_DO[11]), 
    .DO12(sram_fmB_DO[12]), .DO13(sram_fmB_DO[13]), .DO14(sram_fmB_DO[14]), .DO15(sram_fmB_DO[15]),
    .DO16(sram_fmB_DO[16]), .DO17(sram_fmB_DO[17]), .DO18(sram_fmB_DO[18]), .DO19(sram_fmB_DO[19]), 
    .DO20(sram_fmB_DO[20]), .DO21(sram_fmB_DO[21]), .DO22(sram_fmB_DO[22]), .DO23(sram_fmB_DO[23]), 
    .DO24(sram_fmB_DO[24]), .DO25(sram_fmB_DO[25]), .DO26(sram_fmB_DO[26]), .DO27(sram_fmB_DO[27]), 
    .DO28(sram_fmB_DO[28]), .DO29(sram_fmB_DO[29]), .DO30(sram_fmB_DO[30]), .DO31(sram_fmB_DO[31]),
    .DO32(sram_fmB_DO[32]), .DO33(sram_fmB_DO[33]), .DO34(sram_fmB_DO[34]), .DO35(sram_fmB_DO[35]), 
    .DO36(sram_fmB_DO[36]), .DO37(sram_fmB_DO[37]), .DO38(sram_fmB_DO[38]), .DO39(sram_fmB_DO[39]), 
    .DO40(sram_fmB_DO[40]), .DO41(sram_fmB_DO[41]), .DO42(sram_fmB_DO[42]), .DO43(sram_fmB_DO[43]), 
    .DO44(sram_fmB_DO[44]), .DO45(sram_fmB_DO[45]), .DO46(sram_fmB_DO[46]), .DO47(sram_fmB_DO[47]),
    .DO48(sram_fmB_DO[48]), .DO49(sram_fmB_DO[49]), .DO50(sram_fmB_DO[50]), .DO51(sram_fmB_DO[51]), 
    .DO52(sram_fmB_DO[52]), .DO53(sram_fmB_DO[53]), .DO54(sram_fmB_DO[54]), .DO55(sram_fmB_DO[55]), 
    .DO56(sram_fmB_DO[56]), .DO57(sram_fmB_DO[57]), .DO58(sram_fmB_DO[58]), .DO59(sram_fmB_DO[59]), 
    .DO60(sram_fmB_DO[60]), .DO61(sram_fmB_DO[61]), .DO62(sram_fmB_DO[62]), .DO63(sram_fmB_DO[63]),
    .DO64(sram_fmB_DO[64]), .DO65(sram_fmB_DO[65]), .DO66(sram_fmB_DO[66]), .DO67(sram_fmB_DO[67]), 
    .DO68(sram_fmB_DO[68]), .DO69(sram_fmB_DO[69]), .DO70(sram_fmB_DO[70]), .DO71(sram_fmB_DO[71]), 
    .DO72(sram_fmB_DO[72]), .DO73(sram_fmB_DO[73]), .DO74(sram_fmB_DO[74]), .DO75(sram_fmB_DO[75]), 
    .DO76(sram_fmB_DO[76]), .DO77(sram_fmB_DO[77]), .DO78(sram_fmB_DO[78]), .DO79(sram_fmB_DO[79]),
    .DO80(sram_fmB_DO[80]), .DO81(sram_fmB_DO[81]), .DO82(sram_fmB_DO[82]), .DO83(sram_fmB_DO[83]), 
    .DO84(sram_fmB_DO[84]), .DO85(sram_fmB_DO[85]), .DO86(sram_fmB_DO[86]), .DO87(sram_fmB_DO[87]), 
    .DO88(sram_fmB_DO[88]), .DO89(sram_fmB_DO[89]), .DO90(sram_fmB_DO[90]), .DO91(sram_fmB_DO[91]), 
    .DO92(sram_fmB_DO[92]), .DO93(sram_fmB_DO[93]), .DO94(sram_fmB_DO[94]), .DO95(sram_fmB_DO[95]),
    .DO96(sram_fmB_DO[96]), .DO97(sram_fmB_DO[97]), .DO98(sram_fmB_DO[98]), .DO99(sram_fmB_DO[99]), 
    .DO100(sram_fmB_DO[100]), .DO101(sram_fmB_DO[101]), .DO102(sram_fmB_DO[102]), .DO103(sram_fmB_DO[103]), 
    .DO104(sram_fmB_DO[104]), .DO105(sram_fmB_DO[105]), .DO106(sram_fmB_DO[106]), .DO107(sram_fmB_DO[107]), 
    .DO108(sram_fmB_DO[108]), .DO109(sram_fmB_DO[109]), .DO110(sram_fmB_DO[110]), .DO111(sram_fmB_DO[111]),
    .DO112(sram_fmB_DO[112]), .DO113(sram_fmB_DO[113]), .DO114(sram_fmB_DO[114]), .DO115(sram_fmB_DO[115]), 
    .DO116(sram_fmB_DO[116]), .DO117(sram_fmB_DO[117]), .DO118(sram_fmB_DO[118]), .DO119(sram_fmB_DO[119]), 
    .DO120(sram_fmB_DO[120]), .DO121(sram_fmB_DO[121]), .DO122(sram_fmB_DO[122]), .DO123(sram_fmB_DO[123]), 
    .DO124(sram_fmB_DO[124]), .DO125(sram_fmB_DO[125]), .DO126(sram_fmB_DO[126]), .DO127(sram_fmB_DO[127]),
    .DI0(sram_fmB_DI[0]), .DI1(sram_fmB_DI[1]), .DI2(sram_fmB_DI[2]), .DI3(sram_fmB_DI[3]), 
    .DI4(sram_fmB_DI[4]), .DI5(sram_fmB_DI[5]), .DI6(sram_fmB_DI[6]), .DI7(sram_fmB_DI[7]), 
    .DI8(sram_fmB_DI[8]), .DI9(sram_fmB_DI[9]), .DI10(sram_fmB_DI[10]), .DI11(sram_fmB_DI[11]), 
    .DI12(sram_fmB_DI[12]), .DI13(sram_fmB_DI[13]), .DI14(sram_fmB_DI[14]), .DI15(sram_fmB_DI[15]),
    .DI16(sram_fmB_DI[16]), .DI17(sram_fmB_DI[17]), .DI18(sram_fmB_DI[18]), .DI19(sram_fmB_DI[19]), 
    .DI20(sram_fmB_DI[20]), .DI21(sram_fmB_DI[21]), .DI22(sram_fmB_DI[22]), .DI23(sram_fmB_DI[23]), 
    .DI24(sram_fmB_DI[24]), .DI25(sram_fmB_DI[25]), .DI26(sram_fmB_DI[26]), .DI27(sram_fmB_DI[27]), 
    .DI28(sram_fmB_DI[28]), .DI29(sram_fmB_DI[29]), .DI30(sram_fmB_DI[30]), .DI31(sram_fmB_DI[31]),
    .DI32(sram_fmB_DI[32]), .DI33(sram_fmB_DI[33]), .DI34(sram_fmB_DI[34]), .DI35(sram_fmB_DI[35]), 
    .DI36(sram_fmB_DI[36]), .DI37(sram_fmB_DI[37]), .DI38(sram_fmB_DI[38]), .DI39(sram_fmB_DI[39]), 
    .DI40(sram_fmB_DI[40]), .DI41(sram_fmB_DI[41]), .DI42(sram_fmB_DI[42]), .DI43(sram_fmB_DI[43]), 
    .DI44(sram_fmB_DI[44]), .DI45(sram_fmB_DI[45]), .DI46(sram_fmB_DI[46]), .DI47(sram_fmB_DI[47]),
    .DI48(sram_fmB_DI[48]), .DI49(sram_fmB_DI[49]), .DI50(sram_fmB_DI[50]), .DI51(sram_fmB_DI[51]), 
    .DI52(sram_fmB_DI[52]), .DI53(sram_fmB_DI[53]), .DI54(sram_fmB_DI[54]), .DI55(sram_fmB_DI[55]), 
    .DI56(sram_fmB_DI[56]), .DI57(sram_fmB_DI[57]), .DI58(sram_fmB_DI[58]), .DI59(sram_fmB_DI[59]), 
    .DI60(sram_fmB_DI[60]), .DI61(sram_fmB_DI[61]), .DI62(sram_fmB_DI[62]), .DI63(sram_fmB_DI[63]),
    .DI64(sram_fmB_DI[64]), .DI65(sram_fmB_DI[65]), .DI66(sram_fmB_DI[66]), .DI67(sram_fmB_DI[67]), 
    .DI68(sram_fmB_DI[68]), .DI69(sram_fmB_DI[69]), .DI70(sram_fmB_DI[70]), .DI71(sram_fmB_DI[71]), 
    .DI72(sram_fmB_DI[72]), .DI73(sram_fmB_DI[73]), .DI74(sram_fmB_DI[74]), .DI75(sram_fmB_DI[75]), 
    .DI76(sram_fmB_DI[76]), .DI77(sram_fmB_DI[77]), .DI78(sram_fmB_DI[78]), .DI79(sram_fmB_DI[79]),
    .DI80(sram_fmB_DI[80]), .DI81(sram_fmB_DI[81]), .DI82(sram_fmB_DI[82]), .DI83(sram_fmB_DI[83]), 
    .DI84(sram_fmB_DI[84]), .DI85(sram_fmB_DI[85]), .DI86(sram_fmB_DI[86]), .DI87(sram_fmB_DI[87]), 
    .DI88(sram_fmB_DI[88]), .DI89(sram_fmB_DI[89]), .DI90(sram_fmB_DI[90]), .DI91(sram_fmB_DI[91]), 
    .DI92(sram_fmB_DI[92]), .DI93(sram_fmB_DI[93]), .DI94(sram_fmB_DI[94]), .DI95(sram_fmB_DI[95]),
    .DI96(sram_fmB_DI[96]), .DI97(sram_fmB_DI[97]), .DI98(sram_fmB_DI[98]), .DI99(sram_fmB_DI[99]), 
    .DI100(sram_fmB_DI[100]), .DI101(sram_fmB_DI[101]), .DI102(sram_fmB_DI[102]), .DI103(sram_fmB_DI[103]), 
    .DI104(sram_fmB_DI[104]), .DI105(sram_fmB_DI[105]), .DI106(sram_fmB_DI[106]), .DI107(sram_fmB_DI[107]), 
    .DI108(sram_fmB_DI[108]), .DI109(sram_fmB_DI[109]), .DI110(sram_fmB_DI[110]), .DI111(sram_fmB_DI[111]),
    .DI112(sram_fmB_DI[112]), .DI113(sram_fmB_DI[113]), .DI114(sram_fmB_DI[114]), .DI115(sram_fmB_DI[115]), 
    .DI116(sram_fmB_DI[116]), .DI117(sram_fmB_DI[117]), .DI118(sram_fmB_DI[118]), .DI119(sram_fmB_DI[119]), 
    .DI120(sram_fmB_DI[120]), .DI121(sram_fmB_DI[121]), .DI122(sram_fmB_DI[122]), .DI123(sram_fmB_DI[123]), 
    .DI124(sram_fmB_DI[124]), .DI125(sram_fmB_DI[125]), .DI126(sram_fmB_DI[126]), .DI127(sram_fmB_DI[127]),
    .WEB(sram_fmB_WEB), .OE(1'b1), .CS(1'b1), .CK(clk)
);


reg [3:0] pack_array_wt [0:3];

always @(posedge clk) begin
    if ((curr_st == IDLE || curr_st == LOAD_W) && i_valid) begin
        pack_array_wt[cnt_w_idx[1:0]] <= i_weight;
    end
end


reg flag_is_conv_lyr;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        flag_is_conv_lyr <= 1'b1;
    end 
    else if (curr_st == IDLE) begin
        flag_is_conv_lyr <= 1'b1;
    end 
    else if (curr_st == LOAD_W && i_valid) begin
        if      (cnt_load == 143)  flag_is_conv_lyr <= 1'b0;
        else if (cnt_load == 1167) flag_is_conv_lyr <= 1'b1;
    end
end

wire flag_wr_trigger;
assign flag_wr_trigger = i_valid && ((cnt_w_idx[1:0] == 2'b11) || (flag_is_conv_lyr && cnt_w_idx == 8));


reg [6:0] addr_wt_base;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr_wt_base <= 7'd0;
    end 
    else if (curr_st == IDLE) begin
        addr_wt_base <= 7'd0;
    end 
    else if (curr_st == LOAD_W && i_valid) begin
        if      (cnt_load == 143)  addr_wt_base <= 7'd3;
        else if (cnt_load == 399)  addr_wt_base <= 7'd7;
        else if (cnt_load == 655)  addr_wt_base <= 7'd11;
        else if (cnt_load == 911)  addr_wt_base <= 7'd15;
        else if (cnt_load == 1167) addr_wt_base <= 7'd19;
    end
end

wire [6:0] addr_wt_write;
assign addr_wt_write = addr_wt_base + {5'b0, cnt_w_idx[3:2]};

reg [6:0] addr_wt_read;
reg [1:0] offset_wt_read;
reg [1:0] offset_wt_read_d1;


wire [9:0] step_minus_1;
wire [6:0] step_plus_1;
wire [6:0] step_plus_13;

assign step_minus_1 = cnt_step - 10'd1;
assign step_plus_1  = cnt_step[6:0] + 7'd1;  
assign step_plus_13 = cnt_step[6:0] + 7'd13; 

always @(*) begin
    addr_wt_read   = 7'd0;
    offset_wt_read = 2'd0;
    if (curr_st == CONV_DN) begin
        if (cnt_step >= 1 && cnt_step <= 9) begin
            addr_wt_read   = {5'b0, step_minus_1[3:2]};
            offset_wt_read = step_minus_1[1:0];
        end
    end 
    else if (curr_st == PROJ_QKV) begin
        if (cnt_step >= 2 && cnt_step <= 13) begin
            addr_wt_read = step_plus_1;
        end
    end 
    else if (curr_st == FFN_CALC) begin
        if (cnt_step >= 2 && cnt_step <= 5) begin
            addr_wt_read = step_plus_13;
        end
    end 
    else if (curr_st == CONV_UP) begin
        if (cnt_step >= 1 && cnt_step <= 9) begin
            addr_wt_read   = 7'd19 + {5'b0, step_minus_1[3:2]};
            offset_wt_read = step_minus_1[1:0];
        end
    end
end

always @(posedge clk) begin
    offset_wt_read_d1 <= offset_wt_read;
end

wire [255:0] flat_wt_out_full;
wire [15:0]  safe_bus_wt_we;
wire [15:0]  safe_bus_wt_di;
wire [6:0]   safe_addr_wr;
wire [6:0]   safe_addr_rd;
wire         safe_is_wt_wr;


assign safe_is_wt_wr  = (!rst_n) ? 1'b0 : (curr_st == LOAD_W);
assign safe_bus_wt_we = (!rst_n) ? 16'hFFFF : ((curr_st == LOAD_W && flag_wr_trigger) ? ~(16'h0001 << cnt_w_ch) : 16'hFFFF);
assign safe_addr_wr   = (!rst_n) ? 7'd0 : addr_wt_write;
assign safe_addr_rd   = (!rst_n) ? 7'd0 : addr_wt_read;

assign safe_bus_wt_di = (!rst_n) ? 16'd0 : {
    (cnt_w_idx[1:0] == 2'b11 ? i_weight : pack_array_wt[3]),
    (cnt_w_idx[1:0] == 2'b10 ? i_weight : pack_array_wt[2]),
    (cnt_w_idx[1:0] == 2'b01 ? i_weight : pack_array_wt[1]),
    (cnt_w_idx[1:0] == 2'b00 ? i_weight : pack_array_wt[0])
};

Weight_SRAM_Wrapper u_wt_sram_wrapper (
    .clk            (clk),
    .i_is_write     (safe_is_wt_wr),
    .i_addr_wr      (safe_addr_wr),
    .i_addr_rd      (safe_addr_rd),
    .i_we_bus       (safe_bus_wt_we),
    .i_data_in      (safe_bus_wt_di),
    .o_wt_out_full  (flat_wt_out_full)
);

wire signed [3:0] val_wt_0 [0:15];
wire signed [3:0] val_wt_1 [0:15];
wire signed [3:0] val_wt_2 [0:15];
wire signed [3:0] val_wt_3 [0:15];
wire signed [3:0] cur_wt_v [0:15];

genvar idx_upk;
generate
    for (idx_upk = 0; idx_upk < 16; idx_upk = idx_upk + 1) begin : UNPACK_WT
        assign val_wt_0[idx_upk] = flat_wt_out_full[idx_upk*16      +: 4];
        assign val_wt_1[idx_upk] = flat_wt_out_full[idx_upk*16 + 4  +: 4];
        assign val_wt_2[idx_upk] = flat_wt_out_full[idx_upk*16 + 8  +: 4];
        assign val_wt_3[idx_upk] = flat_wt_out_full[idx_upk*16 + 12 +: 4];

        assign cur_wt_v[idx_upk] = (offset_wt_read_d1 == 2'd0) ? val_wt_0[idx_upk] :
                                   (offset_wt_read_d1 == 2'd1) ? val_wt_1[idx_upk] :
                                   (offset_wt_read_d1 == 2'd2) ? val_wt_2[idx_upk] : 
                                                                 val_wt_3[idx_upk];
    end
endgenerate

//  Main FSM Logic
always @(*) begin
    next_st = curr_st;
    case (curr_st)
        IDLE:       if (i_valid) next_st = (!flag_wt_loaded) ? LOAD_W : LOAD_IMG;
        LOAD_W:     if (cnt_load == 1312) next_st = IDLE;
        LOAD_IMG:   if (cnt_load == 4096) next_st = CONV_DN;
        CONV_DN:    if (cnt_pixel == 255 && cnt_step == 11) next_st = PROJ_QKV;
        PROJ_QKV:   if (cnt_pixel == 255 && cnt_step == 19) next_st = ATTN_CALC;
        ATTN_CALC:  if (cnt_pixel == 63  && cnt_step == 268) next_st = FFN_CALC;
        FFN_CALC:   if (cnt_pixel == 255 && cnt_step == 8)  next_st = CONV_UP;
        CONV_UP:    if (cnt_pixel == 255 && cnt_step == 12) next_st = INTERP_OUT;
        INTERP_OUT: if (cnt_w == 1024 && cnt_step == 3) 
                           next_st = (reg_curr_iter == reg_target_iter) ? IDLE : NXT_ITR;
        NXT_ITR:    next_st = CONV_DN;
        default:       next_st = IDLE;
    endcase
end

wire [3:0] crd_ox;
wire [3:0] crd_oy;
assign crd_ox = cnt_pixel[3:0];
assign crd_oy = cnt_pixel[7:4];

reg [1:0] crd_kx;
reg [1:0] crd_ky;

always @(*) begin
    case (cnt_step)
        10'd0: begin crd_kx = 2'd0; crd_ky = 2'd0; end 
        10'd1: begin crd_kx = 2'd1; crd_ky = 2'd0; end
        10'd2: begin crd_kx = 2'd2; crd_ky = 2'd0; end
        10'd3: begin crd_kx = 2'd0; crd_ky = 2'd1; end
        10'd4: begin crd_kx = 2'd1; crd_ky = 2'd1; end
        10'd5: begin crd_kx = 2'd2; crd_ky = 2'd1; end
        10'd6: begin crd_kx = 2'd0; crd_ky = 2'd2; end
        10'd7: begin crd_kx = 2'd1; crd_ky = 2'd2; end
        10'd8: begin crd_kx = 2'd2; crd_ky = 2'd2; end
        default: begin crd_kx = 2'd0; crd_ky = 2'd0; end
    endcase
end


wire signed [6:0] ox_sh_m1;
wire signed [6:0] oy_sh_m1;
assign ox_sh_m1 = {1'b0, crd_ox, 2'b00} - 7'sd1;
assign oy_sh_m1 = {1'b0, crd_oy, 2'b00} - 7'sd1;

wire signed [6:0] ix_dn;
wire signed [6:0] iy_dn;
assign ix_dn = ox_sh_m1 + $signed({5'b0, crd_kx});
assign iy_dn = oy_sh_m1 + $signed({5'b0, crd_ky});

wire val_dn_comb;
assign val_dn_comb = (ix_dn >= 0 && ix_dn < 64 && iy_dn >= 0 && iy_dn < 64);

wire [11:0] idx_img_px;
assign idx_img_px = {iy_dn[5:0], 6'b000000} + ix_dn;

wire signed [5:0] ox_up_m1;
wire signed [5:0] oy_up_m1;
assign ox_up_m1 = {2'b0, crd_ox} - 6'sd1;
assign oy_up_m1 = {2'b0, crd_oy} - 6'sd1;

wire signed [5:0] ix_up;
wire signed [5:0] iy_up;
assign ix_up = ox_up_m1 + $signed({4'b0, crd_kx});
assign iy_up = oy_up_m1 + $signed({4'b0, crd_ky});

wire val_up_comb;
assign val_up_comb = (ix_up >= 0 && ix_up < 16 && iy_up >= 0 && iy_up < 16);

wire [7:0] addr_up_comb;
assign addr_up_comb = {iy_up[3:0], 4'b0000} + ix_up;

wire [3:0] blk_x;
wire [5:0] blk_y;
wire [1:0] interp_dy;
wire [3:0] blk_y_real;

assign blk_x      = cnt_w[3:0];
assign blk_y      = cnt_w[9:4];
assign interp_dy  = cnt_w[5:4];
assign blk_y_real = cnt_w[9:6];

wire [3:0] read_coord_X_A;
wire [3:0] read_coord_X_B;
wire [3:0] read_coord_Y_A;
wire [3:0] read_coord_Y_B;

assign read_coord_X_A = (reg_saved_mode == 1 && blk_x == 15) ? 4'd14 : blk_x;
assign read_coord_X_B = (reg_saved_mode == 1 && blk_x == 15) ? 4'd15 : ((reg_saved_mode == 1) ? blk_x + 1 : blk_x);
assign read_coord_Y_A = (reg_saved_mode == 2 && blk_y_real == 15) ? 4'd14 : blk_y_real;
assign read_coord_Y_B = (reg_saved_mode == 2 && blk_y_real == 15) ? 4'd15 : ((reg_saved_mode == 2) ? blk_y_real + 1 : blk_y_real);


//6. THE HYBRID DATAPATH
reg [7:0] cur_img_px;

always @(*) begin
    if (val_dn_d2) begin
        case (img_idx_d2[1:0])
            2'b00: cur_img_px = sram_img_DO[7:0];
            2'b01: cur_img_px = sram_img_DO[15:8];
            2'b10: cur_img_px = sram_img_DO[23:16];
            2'b11: cur_img_px = sram_img_DO[31:24];
        endcase
    end else begin
        cur_img_px = 8'd0;
    end
end

reg signed [8:0] op_A [0:3][0:15];
reg signed [8:0] op_B [0:3][0:15];

always @(*) begin
    for (idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            op_A[idx_i][idx_j] = 9'sd0;
            op_B[idx_i][idx_j] = 9'sd0;
        end
    end

    if (curr_st == PROJ_QKV) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            op_A[0][idx_j] = $signed({1'b0, sram_rd_buf_A[idx_j*8 +: 8]}) - 9'sd128;
            op_A[1][idx_j] = op_A[0][idx_j];
            op_A[2][idx_j] = op_A[0][idx_j];
            op_A[3][idx_j] = op_A[0][idx_j];

            op_B[0][idx_j] = val_wt_0[idx_j];
            op_B[1][idx_j] = val_wt_1[idx_j];
            op_B[2][idx_j] = val_wt_2[idx_j];
            op_B[3][idx_j] = val_wt_3[idx_j];
        end
    end
    else if (curr_st == ATTN_CALC) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            op_A[0][idx_j] = $signed(sh_buf_0[idx_j*8 +: 8]); op_B[0][idx_j] = $signed(sram_rd_buf_B[idx_j*8 +: 8]);
            op_A[1][idx_j] = $signed(sh_buf_1[idx_j*8 +: 8]); op_B[1][idx_j] = $signed(sram_rd_buf_B[idx_j*8 +: 8]);
            op_A[2][idx_j] = $signed(sh_buf_2[idx_j*8 +: 8]); op_B[2][idx_j] = $signed(sram_rd_buf_B[idx_j*8 +: 8]);
            op_A[3][idx_j] = $signed(sh_buf_3[idx_j*8 +: 8]); op_B[3][idx_j] = $signed(sram_rd_buf_B[idx_j*8 +: 8]);
        end
    end
    else if (curr_st == FFN_CALC) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            op_A[0][idx_j] = $signed(sram_rd_buf_A[idx_j*8 +: 8]);
            op_A[1][idx_j] = op_A[0][idx_j];
            op_A[2][idx_j] = op_A[0][idx_j];
            op_A[3][idx_j] = op_A[0][idx_j];

            op_B[0][idx_j] = val_wt_0[idx_j];
            op_B[1][idx_j] = val_wt_1[idx_j];
            op_B[2][idx_j] = val_wt_2[idx_j];
            op_B[3][idx_j] = val_wt_3[idx_j];
        end
    end
    else if (curr_st == CONV_UP) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            op_A[0][idx_j] = $signed({1'b0, sram_fmB_DO[idx_j*8 +: 8]});
            op_B[0][idx_j] = cur_wt_v[idx_j];
        end
    end
end

// Explicit Adder Tree
reg signed [17:0] tree_mult [0:3][0:15];
reg signed [18:0] tree_L1   [0:3][0:7];
reg signed [19:0] tree_L2   [0:3][0:3];
reg signed [19:0] pipe_L2   [0:3][0:3];
reg signed [20:0] tree_L3   [0:3][0:1];
reg signed [21:0] tree_out  [0:3];

always @(*) begin
    for(idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        for(idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            tree_mult[idx_i][idx_j] = op_A[idx_i][idx_j] * op_B[idx_i][idx_j];
        end
        // Level 1
        for(idx_j = 0; idx_j < 8; idx_j = idx_j + 1) begin
            tree_L1[idx_i][idx_j] = tree_mult[idx_i][2*idx_j] + tree_mult[idx_i][2*idx_j+1];
        end
        // Level 2
        for(idx_j = 0; idx_j < 4; idx_j = idx_j + 1) begin
            tree_L2[idx_i][idx_j] = tree_L1[idx_i][2*idx_j] + tree_L1[idx_i][2*idx_j+1];
        end
    end
end

always @(*) begin
    for(idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        // Level 3 (from pipelined L2)
        tree_L3[idx_i][0] = pipe_L2[idx_i][0] + pipe_L2[idx_i][1];
        tree_L3[idx_i][1] = pipe_L2[idx_i][2] + pipe_L2[idx_i][3];
        // Final sum
        tree_out[idx_i]   = tree_L3[idx_i][0] + tree_L3[idx_i][1];
    end
end

// Convolution Down / Attention V-mac logic
reg signed [8:0]  mac_scalar [0:3];
reg signed [8:0]  mac_vector [0:3][0:15];
reg signed [17:0] mac_mult   [0:3][0:15];

always @(*) begin
    for (idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        mac_scalar[idx_i] = 9'sd0;
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            mac_vector[idx_i][idx_j] = 9'sd0;
        end
    end

    if (curr_st == ATTN_CALC) begin
        mac_scalar[0] = $signed({1'b0, fx_reg0});
        mac_scalar[1] = $signed({1'b0, fx_reg1});
        mac_scalar[2] = $signed({1'b0, fx_reg2}); 
        mac_scalar[3] = $signed({1'b0, fx_reg3});

        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            mac_vector[0][idx_j] = $signed(V_reg_pipeline[idx_j*8 +: 8]);
            mac_vector[1][idx_j] = $signed(V_reg_pipeline[idx_j*8 +: 8]);
            mac_vector[2][idx_j] = $signed(V_reg_pipeline[idx_j*8 +: 8]);
            mac_vector[3][idx_j] = $signed(V_reg_pipeline[idx_j*8 +: 8]);
        end
    end
    else if (curr_st == CONV_DN) begin
        mac_scalar[0] = $signed({1'b0, cur_img_px});
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            mac_vector[0][idx_j] = $signed(cur_wt_v[idx_j]); 
        end
    end
    
    for (idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        for (idx_j = 0; idx_j < 16; idx_j = idx_j + 1) begin
            mac_mult[idx_i][idx_j] = mac_scalar[idx_i] * mac_vector[idx_i][idx_j];
        end
    end
end

// Datapath Normalization, Shifting & Clipping
reg [7:0] qkv_clip_arr [0:3];
reg [7:0] ffn_clip_arr [0:3];
reg [7:0] fx_calc0, fx_calc1, fx_calc2, fx_calc3;

reg signed [21:0] val_q_div [0:3];
reg signed [21:0] val_ffn_norm [0:3];
reg signed [21:0] div_sc0, div_sc1, div_sc2, div_sc3;

always @(*) begin
    for (idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        val_q_div[idx_i]    = tree_out[idx_i] >>> 4;
        val_ffn_norm[idx_i] = (tree_out[idx_i] >>> 4) + 22'sd128;

        if (val_q_div[idx_i] < -22'sd128)      qkv_clip_arr[idx_i] = 8'd128; // -128 in 2's comp byte
        else if (val_q_div[idx_i] > 22'sd127)  qkv_clip_arr[idx_i] = 8'd127;
        else                                   qkv_clip_arr[idx_i] = val_q_div[idx_i][7:0];

        if (val_ffn_norm[idx_i] < 22'sd0)      ffn_clip_arr[idx_i] = 8'd0;
        else if (val_ffn_norm[idx_i] > 22'sd255) ffn_clip_arr[idx_i] = 8'd255;
        else                                   ffn_clip_arr[idx_i] = val_ffn_norm[idx_i][7:0];
    end

    div_sc0 = tree_out[0] >>> 6;
    div_sc1 = tree_out[1] >>> 6;
    div_sc2 = tree_out[2] >>> 6;
    div_sc3 = tree_out[3] >>> 6;

    if (div_sc0 < -22'sd128)      fx_calc0 = 8'd0;
    else if (div_sc0 > 22'sd127)  fx_calc0 = 8'd255;
    else                          fx_calc0 = div_sc0[7:0] + 8'd128;

    if (div_sc1 < -22'sd128)      fx_calc1 = 8'd0;
    else if (div_sc1 > 22'sd127)  fx_calc1 = 8'd255;
    else                          fx_calc1 = div_sc1[7:0] + 8'd128;

    if (div_sc2 < -22'sd128)      fx_calc2 = 8'd0;
    else if (div_sc2 > 22'sd127)  fx_calc2 = 8'd255;
    else                          fx_calc2 = div_sc2[7:0] + 8'd128;

    if (div_sc3 < -22'sd128)      fx_calc3 = 8'd0;
    else if (div_sc3 > 22'sd127)  fx_calc3 = 8'd255;
    else                          fx_calc3 = div_sc3[7:0] + 8'd128;
end

reg [7:0] out_clip_buffer [0:15];
reg signed [26:0] sh_mac_val [0:15];

always @(*) begin
    for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) begin
        sh_mac_val[idx_i] = (sh_acc_0[idx_i] >>> 6) + 27'sd128;
        if (sh_mac_val[idx_i] < 27'sd0)        out_clip_buffer[idx_i] = 8'd0;
        else if (sh_mac_val[idx_i] > 27'sd255) out_clip_buffer[idx_i] = 8'd255;
        else                                   out_clip_buffer[idx_i] = sh_mac_val[idx_i][7:0];
    end
end

reg signed [25:0] attn_v_shift [0:15];
reg [7:0] attn_clip_buffer [0:15];

always @(*) begin
    for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) begin
        if      (cnt_step == 265) attn_v_shift[idx_i] = sh_acc_0[idx_i] >>> 16;
        else if (cnt_step == 266) attn_v_shift[idx_i] = sh_acc_1[idx_i] >>> 16;
        else if (cnt_step == 267) attn_v_shift[idx_i] = sh_acc_2[idx_i] >>> 16;
        else                      attn_v_shift[idx_i] = sh_acc_3[idx_i] >>> 16;

        if (attn_v_shift[idx_i] > 26'sd127)       attn_clip_buffer[idx_i] = 8'd127;
        else if (attn_v_shift[idx_i] < -26'sd128) attn_clip_buffer[idx_i] = 8'd128; 
        else                                      attn_clip_buffer[idx_i] = attn_v_shift[idx_i][7:0];
    end
end

//  7. PIPELINED INTERPOLATION LOGIC
reg [7:0]  interp_val_A;
wire [7:0] interp_val_B;
assign interp_val_B = sram_fmA_DO[7:0];

reg [31:0] img_orig_word;
reg [7:0]  out_word_calc [0:3];
reg [31:0] out_word_store;

reg signed [12:0] base_val_ext;
reg signed [12:0] A_ext;
reg signed [12:0] B_ext;
reg signed [12:0] diff_signed;
reg signed [12:0] step_signed;
reg signed [12:0] interp_res;
reg [7:0]         interp_clip_res;
reg signed [12:0] orig_pixel_ext;
reg signed [12:0] noise_scale_ext;
reg signed [12:0] denoise_diff;

always @(*) begin
    A_ext = {1'b0, interp_val_A};
    B_ext = {1'b0, interp_val_B};

    if ((reg_saved_mode == 1 && blk_x == 15) || (reg_saved_mode == 2 && blk_y_real == 15))
        base_val_ext = B_ext;
    else 
        base_val_ext = A_ext;

    diff_signed = B_ext - A_ext;
    step_signed = diff_signed >>> 2;

    for (idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        if (reg_saved_mode == 0) begin
            interp_res = base_val_ext;
        end 
        else if (reg_saved_mode == 1) begin
            if      (idx_i == 0) interp_res = base_val_ext;
            else if (idx_i == 1) interp_res = base_val_ext + step_signed;
            else if (idx_i == 2) interp_res = base_val_ext + step_signed * 2;
            else                 interp_res = base_val_ext + step_signed * 3;
        end else begin
            if      (interp_dy == 0) interp_res = base_val_ext;
            else if (interp_dy == 1) interp_res = base_val_ext + step_signed;
            else if (interp_dy == 2) interp_res = base_val_ext + step_signed * 2;
            else                     interp_res = base_val_ext + step_signed * 3;
        end
        
        if (interp_res < 13'sd0)        interp_clip_res = 8'd0;
        else if (interp_res > 13'sd255) interp_clip_res = 8'd255;
        else                            interp_clip_res = interp_res[7:0];
        
        orig_pixel_ext  = {1'b0, img_orig_word[idx_i*8 +: 8]};
        noise_scale_ext = {1'b0, interp_clip_res[7:3]};
        denoise_diff    = orig_pixel_ext - noise_scale_ext;
        
        if (denoise_diff < 13'sd0)        out_word_calc[idx_i] = 8'd0;
        else if (denoise_diff > 13'sd255) out_word_calc[idx_i] = 8'd255;
        else                              out_word_calc[idx_i] = denoise_diff[7:0];
    end
end

wire [31:0] combined_final_word;
assign combined_final_word = {out_word_calc[3], out_word_calc[2], out_word_calc[1], out_word_calc[0]};

//8. SEQUENTIAL CONTROL BLOCKS (With Reset)

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        curr_st         <= IDLE;
        
        cnt_load        <= 13'd0;
        cnt_w_ch        <= 5'd0;
        cnt_w_idx       <= 5'd0;
        cnt_img_pack    <= 2'd0;
        reg_target_iter <= 3'd0;
        reg_curr_iter   <= 3'd0;
        reg_saved_mode  <= 2'd0;
        flag_wt_loaded  <= 1'b0;
        ptr_w_qkv       <= 4'd0;

        val_dn_d1  <= 1'b0; val_dn_d2  <= 1'b0;
        val_up_d1  <= 1'b0; val_up_d2  <= 1'b0; val_up_d3 <= 1'b0;
        img_idx_d1 <= 12'd0;
        img_idx_d2 <= 12'd0;
    end 
    else begin
        curr_st <= next_st;

        val_dn_d1  <= val_dn_comb;
        val_dn_d2  <= val_dn_d1;
        val_up_d1  <= val_up_comb; 
        val_up_d2  <= val_up_d1; 
        val_up_d3  <= val_up_d2;
        img_idx_d1 <= idx_img_px;
        img_idx_d2 <= img_idx_d1;

        if (curr_st == IDLE && i_valid && !flag_wt_loaded) begin
            cnt_w_idx <= 5'd1;
        end 
        else if (curr_st == LOAD_W && i_valid) begin
            if (cnt_load < 144) begin
                if (cnt_w_idx == 8) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
                if (cnt_load == 143) cnt_w_idx <= 5'd0;
            end 
            else if (cnt_load < 400) begin
                if (cnt_w_idx == 15) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
                if (cnt_load == 399) cnt_w_idx <= 5'd0;
            end 
            else if (cnt_load < 656) begin
                if (cnt_w_idx == 15) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
                if (cnt_load == 655) cnt_w_idx <= 5'd0;
            end 
            else if (cnt_load < 912) begin
                if (cnt_w_idx == 15) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
                if (cnt_load == 911) cnt_w_idx <= 5'd0;
            end 
            else if (cnt_load < 1168) begin
                if (cnt_w_idx == 15) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
                if (cnt_load == 1167) cnt_w_idx <= 5'd0;
            end else begin
                if (cnt_w_idx == 8) cnt_w_idx <= 5'd0; else cnt_w_idx <= cnt_w_idx + 1;
            end
        end

        if (curr_st == IDLE && i_valid && !flag_wt_loaded) begin
            cnt_w_ch <= 5'd0;
        end 
        else if (curr_st == LOAD_W && i_valid) begin
            if (cnt_load < 144) begin 
                if (cnt_w_idx == 8) cnt_w_ch <= cnt_w_ch + 1;
                if (cnt_load == 143) cnt_w_ch <= 5'd0; 
            end 
            else if (cnt_load < 400) begin 
                if (cnt_w_idx == 15) cnt_w_ch <= cnt_w_ch + 1;
                if (cnt_load == 399) cnt_w_ch <= 5'd0; 
            end 
            else if (cnt_load < 656) begin 
                if (cnt_w_idx == 15) cnt_w_ch <= cnt_w_ch + 1;
                if (cnt_load == 655) cnt_w_ch <= 5'd0; 
            end 
            else if (cnt_load < 912) begin 
                if (cnt_w_idx == 15) cnt_w_ch <= cnt_w_ch + 1;
                if (cnt_load == 911) cnt_w_ch <= 5'd0; 
            end 
            else if (cnt_load < 1168) begin 
                if (cnt_w_idx == 15) cnt_w_ch <= cnt_w_ch + 1;
                if (cnt_load == 1167) cnt_w_ch <= 5'd0; 
            end else begin 
                if (cnt_w_idx == 8) cnt_w_ch <= cnt_w_ch + 1;
            end
        end

        if (curr_st == IDLE) begin 
            if (i_valid) cnt_load <= 13'd1; else cnt_load <= 13'd0; 
        end 
        else if ((curr_st == LOAD_W || curr_st == LOAD_IMG) && i_valid) begin
            cnt_load <= cnt_load + 1;
        end

        if (curr_st == IDLE && i_valid && flag_wt_loaded) begin
            cnt_img_pack <= 2'd1;
        end 
        else if (curr_st == LOAD_IMG && i_valid) begin
            cnt_img_pack <= (cnt_img_pack == 3) ? 2'd0 : cnt_img_pack + 1;
        end

        if (curr_st == IDLE && i_valid && flag_wt_loaded) begin
            reg_target_iter <= i_iter;
            reg_saved_mode  <= i_mode;
            reg_curr_iter   <= 3'd1;
        end 
        else if (curr_st == NXT_ITR && reg_curr_iter != reg_target_iter) begin
            reg_curr_iter <= reg_curr_iter + 1;
        end

        if (curr_st == LOAD_W && cnt_load == 1311 && i_valid) begin
            flag_wt_loaded <= 1'b1;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_step  <= 10'd0;
        cnt_pixel <= 9'd0;
        cnt_w     <= 11'd0;
    end 
    else begin
           case (curr_st)
            IDLE:       cnt_step <= 10'd0;
            CONV_DN:    cnt_step <= (cnt_step == 11) ? 10'd0 : cnt_step + 1;
            PROJ_QKV:   cnt_step <= (cnt_step == 19) ? 10'd0 : cnt_step + 1;
            ATTN_CALC:  cnt_step <= (cnt_step == 268) ? 10'd0 : cnt_step + 1;
            FFN_CALC:   cnt_step <= (cnt_step == 8)  ? 10'd0 : cnt_step + 1;
            CONV_UP:    cnt_step <= (cnt_step == 12) ? 10'd0 : cnt_step + 1;
            INTERP_OUT: cnt_step <= (cnt_step == 3)  ? 10'd0 : cnt_step + 1;
            NXT_ITR:    cnt_step <= 10'd0;
        endcase

        case (curr_st)
            IDLE:       cnt_pixel <= 9'd0;
            CONV_DN:    if (cnt_step == 11)  cnt_pixel <= (cnt_pixel == 255) ? 9'd0 : cnt_pixel + 1;
            PROJ_QKV:   if (cnt_step == 19)  cnt_pixel <= (cnt_pixel == 255) ? 9'd0 : cnt_pixel + 1;
            ATTN_CALC:  if (cnt_step == 268) cnt_pixel <= (cnt_pixel == 63)  ? 9'd0 : cnt_pixel + 1;
            FFN_CALC:   if (cnt_step == 8)   cnt_pixel <= (cnt_pixel == 255) ? 9'd0 : cnt_pixel + 1;
            CONV_UP:    if (cnt_step == 12)  cnt_pixel <= (cnt_pixel == 255) ? 9'd0 : cnt_pixel + 1;
            NXT_ITR:    cnt_pixel <= 9'd0;
        endcase

        if (curr_st == IDLE || curr_st == NXT_ITR) begin
            cnt_w <= 11'd0;
        end 
        else if (curr_st == INTERP_OUT && cnt_step == 3 && cnt_w != 1024) begin
            cnt_w <= cnt_w + 1;
        end
    end
end

// 9. SRAM Controls 

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sram_img_A   <= 10'd0;
        sram_img_WEB <= 1'b1;
        sram_fmA_A   <= 9'd0; 
        sram_fmA_WEB <= 1'b1;
        sram_fmB_A   <= 9'd0; 
        sram_fmB_WEB <= 1'b1;
    end else begin
        // Image SRAM Address Control
        if (curr_st == IDLE && i_valid && flag_wt_loaded) begin
            sram_img_A <= 10'd0;
        end 
        else if (curr_st == LOAD_IMG && i_valid && cnt_img_pack == 0 && cnt_load > 3) begin
            sram_img_A <= sram_img_A + 1;
        end 
        else if (curr_st == CONV_DN && cnt_step < 9 && val_dn_comb) begin
            sram_img_A <= idx_img_px[11:2];
        end 
        else if (curr_st == INTERP_OUT) begin
            // Isolate SRAM Read and Write explicitly to prevent WEB=0 driving DO into Unknown (X)
            if (cnt_step == 0) sram_img_A <= cnt_w[9:0];
            if (cnt_step == 1) sram_img_A <= cnt_w[9:0];
            if (cnt_step == 2) sram_img_A <= cnt_w[9:0] - 1;
        end

        // Image SRAM WEB Control
        if (curr_st == LOAD_IMG && i_valid && cnt_img_pack == 3) begin
            sram_img_WEB <= 1'b0;
        end 
        else if (curr_st == INTERP_OUT && cnt_step == 2 && cnt_w >= 1 && cnt_w <= 1024) begin
            // Delay WEB=0 until step_cnt=2 so that DO safely storees RAM data
            sram_img_WEB <= 1'b0;
        end else begin
            sram_img_WEB <= 1'b1;
        end

        // fmA SRAM Address Control
        if (curr_st == CONV_DN && cnt_step == 11) begin
            sram_fmA_A <= cnt_pixel[8:0];
        end 
        else if (curr_st == PROJ_QKV) begin
            sram_fmA_A <= (cnt_step == 0) ? cnt_pixel[8:0] : (cnt_step == 19 ? 9'd256 + cnt_pixel[8:0] : sram_fmA_A);
        end 
        else if (curr_st == ATTN_CALC) begin
            if (cnt_step >= 5 && cnt_step <= 260) sram_fmA_A <= 9'd256 + (cnt_step - 5);
            else if (cnt_step == 265)             sram_fmA_A <= {1'b0, cnt_pixel[5:0], 2'b00};
            else if (cnt_step == 266)             sram_fmA_A <= {1'b0, cnt_pixel[5:0], 2'b01};
            else if (cnt_step == 267)             sram_fmA_A <= {1'b0, cnt_pixel[5:0], 2'b10};
            else if (cnt_step == 268)             sram_fmA_A <= {1'b0, cnt_pixel[5:0], 2'b11};
        end 
        else if (curr_st == FFN_CALC && cnt_step == 0) begin
            sram_fmA_A <= cnt_pixel[8:0];
        end 
        else if (curr_st == CONV_UP && cnt_step == 12) begin
            sram_fmA_A <= cnt_pixel[8:0];
        end 
        else if (curr_st == INTERP_OUT) begin
            sram_fmA_A <= (cnt_step == 0) ? ({5'b0, read_coord_Y_A} << 4) + {5'b0, read_coord_X_A} : 
                          (cnt_step == 1) ? ({5'b0, read_coord_Y_B} << 4) + {5'b0, read_coord_X_B} : sram_fmA_A;
        end

        // fmA SRAM WEB Control
        if ((curr_st == CONV_DN   && cnt_step == 11) || 
            (curr_st == PROJ_QKV  && cnt_step == 19) || 
            (curr_st == ATTN_CALC && cnt_step >= 265 && cnt_step <= 268) || 
            (curr_st == CONV_UP   && cnt_step == 12)) begin
            sram_fmA_WEB <= 1'b0;
        end else begin
            sram_fmA_WEB <= 1'b1;
        end

        // fmB SRAM Address Control
        if (curr_st == PROJ_QKV) begin
            sram_fmB_A <= (cnt_step == 17) ? cnt_pixel[8:0] : (cnt_step == 18 ? 9'd256 + cnt_pixel[8:0] : sram_fmB_A);
        end 
        else if (curr_st == ATTN_CALC) begin
            if (cnt_step == 0) sram_fmB_A <= {1'b0, cnt_pixel[5:0], 2'b00};
            else if (cnt_step == 1) sram_fmB_A <= {1'b0, cnt_pixel[5:0], 2'b01};
            else if (cnt_step == 2) sram_fmB_A <= {1'b0, cnt_pixel[5:0], 2'b10};
            else if (cnt_step == 3) sram_fmB_A <= {1'b0, cnt_pixel[5:0], 2'b11};
            else if (cnt_step == 4) sram_fmB_A <= 9'd256;
            else if (cnt_step >= 5 && cnt_step <= 259) sram_fmB_A <= 9'd256 + (cnt_step - 4);
        end 
        else if (curr_st == FFN_CALC && cnt_step == 8) begin
            sram_fmB_A <= cnt_pixel[8:0];
        end 
        else if (curr_st == CONV_UP && cnt_step < 9 && val_up_comb) begin
            sram_fmB_A <= {1'b0, addr_up_comb};
        end

        // fmB SRAM WEB Control
        if ((curr_st == PROJ_QKV && (cnt_step == 17 || cnt_step == 18)) || 
            (curr_st == FFN_CALC && cnt_step == 8)) begin
            sram_fmB_WEB <= 1'b0;
        end else begin
            sram_fmB_WEB <= 1'b1;
        end
    end
end

// 10. DATA REGISTERS 
always @(posedge clk) begin
    // Pipeline registers for L2 Adder Tree
    for(idx_i = 0; idx_i < 4; idx_i = idx_i + 1) begin
        for(idx_j = 0; idx_j < 4; idx_j = idx_j + 1) begin
            pipe_L2[idx_i][idx_j] <= tree_L2[idx_i][idx_j];
        end
    end

    // Image Data Input / Feedback write
    if (curr_st == LOAD_IMG && i_valid) begin
        sram_img_DI <= {i_data, sram_img_DI[31:8]};
    end 
    else if (curr_st == IDLE && i_valid && flag_wt_loaded) begin
        sram_img_DI <= {i_data, 24'd0};
    end 
    else if (curr_st == INTERP_OUT && cnt_step == 2) begin
        sram_img_DI <= out_word_store; // Sync with delayed write
    end

    // Shared Accumulators Write
    if (curr_st == CONV_DN) begin
        if (cnt_step == 0) begin
            for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) sh_acc_0[idx_i] <= 0;
        end 
        else if (cnt_step >= 2 && cnt_step <= 10) begin
            for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) sh_acc_0[idx_i] <= sh_acc_0[idx_i] + mac_mult[0][idx_i];
        end
    end 
    else if (curr_st == CONV_UP) begin
        if (cnt_step == 0) begin
            sh_acc_0[0] <= 0;
        end 
        else if (cnt_step >= 3 && cnt_step <= 11 && val_up_d3) begin
            sh_acc_0[0] <= sh_acc_0[0] + tree_out[0];
        end
    end 
    else if (curr_st == ATTN_CALC) begin
        if (cnt_step == 0) begin
            for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) begin
                sh_acc_0[idx_i] <= 0;
                sh_acc_1[idx_i] <= 0; 
                sh_acc_2[idx_i] <= 0; 
                sh_acc_3[idx_i] <= 0;
            end
        end 
        else if (cnt_step >= 9 && cnt_step <= 264) begin
            for (idx_i = 0; idx_i < 16; idx_i = idx_i + 1) begin
                sh_acc_0[idx_i] <= sh_acc_0[idx_i] + mac_mult[0][idx_i];
                sh_acc_1[idx_i] <= sh_acc_1[idx_i] + mac_mult[1][idx_i];
                sh_acc_2[idx_i] <= sh_acc_2[idx_i] + mac_mult[2][idx_i];
                sh_acc_3[idx_i] <= sh_acc_3[idx_i] + mac_mult[3][idx_i];
            end
        end
    end

    // Memory Data Out -> Next Stage Input
    if (curr_st == CONV_DN && cnt_step == 11) begin
        sram_fmA_DI <= { out_clip_buffer[15], out_clip_buffer[14], out_clip_buffer[13], out_clip_buffer[12], 
                         out_clip_buffer[11], out_clip_buffer[10], out_clip_buffer[9],  out_clip_buffer[8], 
                         out_clip_buffer[7],  out_clip_buffer[6],  out_clip_buffer[5],  out_clip_buffer[4], 
                         out_clip_buffer[3],  out_clip_buffer[2],  out_clip_buffer[1],  out_clip_buffer[0] };
    end 
    else if (curr_st == PROJ_QKV && cnt_step == 19) begin
        sram_fmA_DI <= sh_buf_2;
    end 
    else if (curr_st == ATTN_CALC && cnt_step >= 265 && cnt_step <= 268) begin
        sram_fmA_DI <= { attn_clip_buffer[15], attn_clip_buffer[14], attn_clip_buffer[13], attn_clip_buffer[12], 
                         attn_clip_buffer[11], attn_clip_buffer[10], attn_clip_buffer[9],  attn_clip_buffer[8], 
                         attn_clip_buffer[7],  attn_clip_buffer[6],  attn_clip_buffer[5],  attn_clip_buffer[4], 
                         attn_clip_buffer[3],  attn_clip_buffer[2],  attn_clip_buffer[1],  attn_clip_buffer[0] };
    end 
    else if (curr_st == CONV_UP && cnt_step == 12) begin
        sram_fmA_DI <= {120'd0, out_clip_buffer[0]};
    end

    if (curr_st == PROJ_QKV && cnt_step == 17) begin
        sram_fmB_DI <= sh_buf_0;
    end 
    else if (curr_st == PROJ_QKV && cnt_step == 18) begin
        sram_fmB_DI <= sh_buf_1;
    end 
    else if (curr_st == FFN_CALC && cnt_step == 8) begin
        sram_fmB_DI <= sh_buf_0;
    end

    // Read Buffers
    if (curr_st == PROJ_QKV && cnt_step == 2) begin
        sram_rd_buf_A <= sram_fmA_DO;
    end 
    else if (curr_st == FFN_CALC && cnt_step == 2) begin
        sram_rd_buf_A <= sram_fmA_DO;
    end 
    else if (curr_st == ATTN_CALC) begin
        if (cnt_step >= 7 && cnt_step <= 262) sram_rd_buf_A <= sram_fmA_DO;
        if (cnt_step >= 6 && cnt_step <= 261) sram_rd_buf_B <= sram_fmB_DO;
    end

    // QKV and FFN Shared Shifting Buffers
    if (curr_st == PROJ_QKV) begin
        if (cnt_step >= 4 && cnt_step <= 7) begin
            sh_buf_0 <= {qkv_clip_arr[3], qkv_clip_arr[2], qkv_clip_arr[1], qkv_clip_arr[0], sh_buf_0[127:32]};
        end
        if (cnt_step >= 8 && cnt_step <= 11) begin
            sh_buf_1 <= {qkv_clip_arr[3], qkv_clip_arr[2], qkv_clip_arr[1], qkv_clip_arr[0], sh_buf_1[127:32]};
        end
        if (cnt_step >= 12 && cnt_step <= 15) begin
            sh_buf_2 <= {qkv_clip_arr[3], qkv_clip_arr[2], qkv_clip_arr[1], qkv_clip_arr[0], sh_buf_2[127:32]};
        end
    end 
    else if (curr_st == FFN_CALC) begin
        if (cnt_step >= 4 && cnt_step <= 7) begin
            sh_buf_0 <= {ffn_clip_arr[3], ffn_clip_arr[2], ffn_clip_arr[1], ffn_clip_arr[0], sh_buf_0[127:32]};
        end
    end 
    else if (curr_st == ATTN_CALC) begin
        if (cnt_step == 2) sh_buf_0 <= sram_fmB_DO;
        if (cnt_step == 3) sh_buf_1 <= sram_fmB_DO;
        if (cnt_step == 4) sh_buf_2 <= sram_fmB_DO;
        if (cnt_step == 5) sh_buf_3 <= sram_fmB_DO;
        
        if (cnt_step >= 8 && cnt_step <= 263) begin
            fx_reg0 <= fx_calc0;
            fx_reg1 <= fx_calc1; 
            fx_reg2 <= fx_calc2; 
            fx_reg3 <= fx_calc3;
            V_reg_pipeline <= sram_rd_buf_A;
        end
    end

    // Interpolation store
    if (curr_st == INTERP_OUT) begin
        if (cnt_step == 2) begin 
            interp_val_A  <= sram_fmA_DO[7:0];
            img_orig_word <= sram_img_DO; // Safely storees the valid DO since WEB is 1 during step 1
        end
        if (cnt_step == 3) begin
            out_word_store <= combined_final_word;
        end
    end
end

// OUTPUT LOGIC
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_valid <= 1'b0;
        o_data  <= 8'd0;
    end else begin
        if (curr_st == INTERP_OUT && reg_curr_iter == reg_target_iter) begin
            if (cnt_step == 3 && cnt_w < 1024) begin
                o_valid <= 1'b1;
                o_data  <= out_word_calc[0]; 
            end 
            else if (cnt_w >= 1 && cnt_w <= 1024 && cnt_step < 3) begin
                o_valid <= 1'b1;
                if      (cnt_step == 0) o_data <= out_word_store[15:8];
                else if (cnt_step == 1) o_data <= out_word_store[23:16];
                else if (cnt_step == 2) o_data <= out_word_store[31:24];
            end else begin
                o_valid <= 1'b0;
                o_data  <= 8'd0;
            end
        end else begin
            o_valid <= 1'b0;
            o_data  <= 8'd0;
        end
    end
end

endmodule


module Weight_SRAM_Wrapper (
    input  wire         clk,
    input  wire         i_is_write,
    input  wire [6:0]   i_addr_wr,
    input  wire [6:0]   i_addr_rd,
    input  wire [15:0]  i_we_bus,
    input  wire [15:0]  i_data_in,
    output wire [255:0] o_wt_out_full
);

    wire [6:0]  sram_A  [0:15];
    wire [15:0] sram_DO [0:15];

    genvar g;
    generate
        for (g = 0; g < 16; g = g + 1) begin : W_SRAM_MACRO
            assign sram_A[g] = i_is_write ? i_addr_wr : i_addr_rd;
            
            SRAM_128X16 u_sram (
                .A0(sram_A[g][0]), .A1(sram_A[g][1]), .A2(sram_A[g][2]), 
                .A3(sram_A[g][3]), .A4(sram_A[g][4]), .A5(sram_A[g][5]), 
                .A6(sram_A[g][6]),
                .DO0(sram_DO[g][0]),   .DO1(sram_DO[g][1]),   .DO2(sram_DO[g][2]),   .DO3(sram_DO[g][3]),
                .DO4(sram_DO[g][4]),   .DO5(sram_DO[g][5]),   .DO6(sram_DO[g][6]),   .DO7(sram_DO[g][7]),
                .DO8(sram_DO[g][8]),   .DO9(sram_DO[g][9]),   .DO10(sram_DO[g][10]), .DO11(sram_DO[g][11]),
                .DO12(sram_DO[g][12]), .DO13(sram_DO[g][13]), .DO14(sram_DO[g][14]), .DO15(sram_DO[g][15]),
                .DI0(i_data_in[0]),    .DI1(i_data_in[1]),    .DI2(i_data_in[2]),    .DI3(i_data_in[3]),
                .DI4(i_data_in[4]),    .DI5(i_data_in[5]),    .DI6(i_data_in[6]),    .DI7(i_data_in[7]),
                .DI8(i_data_in[8]),    .DI9(i_data_in[9]),    .DI10(i_data_in[10]),  .DI11(i_data_in[11]),
                .DI12(i_data_in[12]),  .DI13(i_data_in[13]),  .DI14(i_data_in[14]),  .DI15(i_data_in[15]),
                .WEB(i_we_bus[g]), .OE(1'b1), .CS(1'b1), .CK(clk)
            );

            assign o_wt_out_full[g*16 +: 16] = sram_DO[g];
        end
    endgenerate

endmodule