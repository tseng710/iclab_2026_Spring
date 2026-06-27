module ISP(
    //Input Port
    clk,
    rst_n,

    in_valid,
    in,
    param_valid,
    param_gain,

    //Output Port
    out_valid,
    r_out,
    g_out,
    b_out
    );

//==============================
//   INPUT/OUTPUT DECLARATION
//==============================
input clk;
input rst_n;
input in_valid;
input [11:0] in;
input param_valid;
input [11:0] param_gain;

output reg out_valid;
output reg [11:0] r_out;
output reg [11:0] g_out;
output reg [11:0] b_out;

//==============================
//   Design
//==============================

//Area : 634,564 / CT: 4.5

integer i;
// gain store
reg [7:0] gain_cnt;
reg [11:0] gain_R  [0:35];
reg [11:0] gain_Gr [0:35];
reg [11:0] gain_Gb [0:35];
reg [11:0] gain_B  [0:35];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        gain_cnt <= 0;
    else if (param_valid) 
        gain_cnt <= gain_cnt + 1;
    else 
        gain_cnt <= gain_cnt;
end


// wire [5:0]gain_idx;
// assign gain_idx = (gain_cnt < 36) ? gain_cnt: (gain_cnt < 72) ? gain_cnt - 8'd36 : (gain_cnt < 108) ? gain_cnt - 8'd72 : gain_cnt - 8'd108;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        for(i=0;i<36;i=i+1)begin
            gain_R[i] <= 0;
            gain_Gr[i] <= 0;
            gain_Gb[i] <= 0;
            gain_B[i] <= 0;
        end
    end
    else if (param_valid) begin
        if (gain_cnt < 36) 
            gain_R[gain_cnt] <= param_gain;
        else if (gain_cnt < 72) 
            gain_Gr[gain_cnt - 36] <= param_gain;
        else if (gain_cnt < 108) 
            gain_Gb[gain_cnt - 72] <= param_gain;
        else 
            gain_B[gain_cnt - 108] <= param_gain;
    end
end

// Global Time Counter
reg [9:0] global_cnt;
reg       frame_active;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        global_cnt   <= 0;
        frame_active <= 0;
    end
    else if (frame_active) begin
        if (global_cnt == 511) begin
            frame_active <= in_valid;
            global_cnt   <= in_valid ? 1 : 0;
        end
        else begin
            global_cnt <= global_cnt + 1;
        end
    end
    else if (in_valid) begin
        frame_active <= 1;
        global_cnt   <= 1;
    end
end

//
wire dpc_center_valid;

assign dpc_center_valid  = (global_cnt > 229 && global_cnt < 486);

// In and BLC
reg [7:0] in_cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        in_cnt <= 0;
    else if (in_valid) 
        in_cnt <= in_cnt + 1;
    else 
        in_cnt <= 0;
end

wire [3:0] in_x;                 wire [3:0] in_y;
assign in_x = in_cnt[3:0];       assign in_y = in_cnt[7:4];
wire [6:0] blc_offset;
wire [1:0] color_now;
assign color_now  = {in_y[0], in_x[0]};

assign blc_offset = (color_now == 0) ? 64 : 
                    (color_now == 1) ? 48 : 
                    (color_now == 2) ? 52 : 72;

wire signed [12:0] blc_sub;
wire [11:0] blc_out;

assign blc_sub = {1'b0, in} - {6'b0, blc_offset};
assign blc_out = (blc_sub < 0) ? 0 : blc_sub[11:0];




// LSC 
reg [2:0] x_0, y_0;
reg [1:0] r_x, r_y;
always @(*) begin
    case(in_x)
        4'd0, 4'd1, 4'd2:    begin x_0 = 3'd0;         r_x = in_x[1:0];        end
        4'd3, 4'd4, 4'd5:    begin x_0 = 3'd1;         r_x = in_x[1:0] - 2'd3; end
        4'd6, 4'd7, 4'd8:    begin x_0 = 3'd2;         r_x = in_x[1:0] - 2'd2; end
        4'd9, 4'd10, 4'd11:  begin x_0 = 3'd3;         r_x = in_x[1:0] - 2'd1; end
        4'd12, 4'd13, 4'd14: begin x_0 = 3'd4;         r_x = in_x[1:0];        end
        4'd15:               begin x_0 = 3'd4;         r_x = 2'd2;             end
        default:             begin x_0 = 3'd0;         r_x = 2'd0;             end
    endcase
    case(in_y)
        4'd0, 4'd1, 4'd2:    begin y_0 = 3'd0;        r_y = in_y[1:0];        end
        4'd3, 4'd4, 4'd5:    begin y_0 = 3'd1;        r_y = in_y[1:0] - 2'd3; end
        4'd6, 4'd7, 4'd8:    begin y_0 = 3'd2;        r_y = in_y[1:0] - 2'd2; end
        4'd9, 4'd10, 4'd11:  begin y_0 = 3'd3;        r_y = in_y[1:0] - 2'd1; end
        4'd12, 4'd13, 4'd14: begin y_0 = 3'd4;        r_y = in_y[1:0];        end
        4'd15:               begin y_0 = 3'd4;        r_y = 2'd2;             end
        default:             begin y_0 = 3'd0;        r_y = 2'd0;             end
    endcase
end

wire [5:0] idx00; 
assign idx00 = (y_0 << 2) + (y_0 << 1) + x_0;// y_0 * 6
reg [11:0] g00, g01, g10, g11; 

always @(*) begin
    case (color_now)
        2'b00: begin g00 = gain_R[idx00];  g01 = gain_R[idx00+1];  g10 = gain_R[idx00+6];  g11 = gain_R[idx00+7];  end
        2'b01: begin g00 = gain_Gr[idx00]; g01 = gain_Gr[idx00+1]; g10 = gain_Gr[idx00+6]; g11 = gain_Gr[idx00+7]; end
        2'b10: begin g00 = gain_Gb[idx00]; g01 = gain_Gb[idx00+1]; g10 = gain_Gb[idx00+6]; g11 = gain_Gb[idx00+7]; end
        2'b11: begin g00 = gain_B[idx00];  g01 = gain_B[idx00+1];  g10 = gain_B[idx00+6];  g11 = gain_B[idx00+7];  end
    endcase
end

// LSC Stage 1
reg [11:0] blc_stage1, g00_stage1, g01_stage1, g10_stage1, g11_stage1;
reg [1:0]  r_x_stage1, r_y_stage1;

always @(posedge clk) begin
    blc_stage1 <= blc_out;
    g00_stage1 <= g00; g01_stage1 <= g01; g10_stage1 <= g10; g11_stage1 <= g11;
    r_x_stage1 <= r_x; r_y_stage1 <= r_y;
end



// LSC Stage 2
wire signed [12:0] diff_x0;
wire signed [21:0] diff_x0_ext;
assign diff_x0 = $signed({1'b0, g01_stage1}) - $signed({1'b0, g00_stage1});
assign diff_x0_ext = diff_x0;

wire signed [21:0] dx0_5 ; // x * 5
wire signed [21:0] dx0_85;             // x * 85
wire signed [21:0] dx0_171 ;      // x * 171

assign dx0_5   = (diff_x0_ext <<< 2) + diff_x0_ext; // x * 5
assign dx0_85  = (dx0_5 <<< 4) + dx0_5;             // x * 85
assign dx0_171 = (dx0_85 <<< 1) + diff_x0_ext; 

wire signed [21:0] term_x0;


wire [21:0] Y0_comb;

assign Y0_comb = $unsigned($signed({1'b0, g00_stage1, 8'b0}) + term_x0);
assign term_x0 = (r_x_stage1 == 2'd0) ? 22'sd0 :
                             (r_x_stage1 == 2'd1) ? dx0_85 : dx0_171;

wire signed [12:0] diff_x1;
wire signed [21:0] diff_x1_ext;

assign diff_x1 = $signed({1'b0, g11_stage1}) - $signed({1'b0, g10_stage1});
assign diff_x1_ext = diff_x1;

wire signed [21:0] dx1_5; 
wire signed [21:0] dx1_85;             
wire signed [21:0] dx1_171;  

assign dx1_5   = (diff_x1_ext <<< 2) + diff_x1_ext; 
assign dx1_85  = (dx1_5 <<< 4) + dx1_5;             
assign dx1_171 = (dx1_85 <<< 1) + diff_x1_ext;    

wire signed [21:0] term_x1;
wire [21:0] Y1_comb;

assign term_x1 = (r_x_stage1 == 2'd0) ? 22'sd0 :
                 (r_x_stage1 == 2'd1) ? dx1_85 : dx1_171;
assign Y1_comb = $unsigned($signed({1'b0, g10_stage1, 8'b0}) + term_x1);



reg [21:0] Y0_stage2, Y1_stage2;
reg [1:0]  r_y_stage2;
reg [11:0] blc_stage2;

always @(posedge clk) begin
    Y0_stage2 <= Y0_comb; Y1_stage2 <= Y1_comb;
    r_y_stage2 <= r_y_stage1; blc_stage2 <= blc_stage1;
end



// LSC Stage 3
wire signed [22:0] diff_y;
wire signed [31:0] diff_y_ext;

assign diff_y = $signed({1'b0, Y1_stage2}) - $signed({1'b0, Y0_stage2});
assign diff_y_ext = diff_y;

wire signed [31:0] dy_5;       // y * 5
wire signed [31:0] dy_85;      // y * 85
wire signed [31:0] dy_171;     // y * 171

assign dy_5   = (diff_y_ext <<< 2) + diff_y_ext; 
assign dy_85  = (dy_5 <<< 4) + dy_5;             
assign dy_171 = (dy_85 <<< 1) + diff_y_ext;      

wire signed [31:0] term_y;
wire [30:0] G_val_comb;

assign term_y = (r_y_stage2 == 2'd0) ? 32'sd0 :
                (r_y_stage2 == 2'd1) ? dy_85 : dy_171;

assign G_val_comb = $unsigned($signed({1'b0, Y0_stage2, 8'b0}) + term_y + 33'sd32768);

reg [30:0] G_val_stage3;
reg [11:0] blc_stage3;

always @(posedge clk) begin
    G_val_stage3 <= G_val_comb; 
    blc_stage3 <= blc_stage2;
end



//Stage 4
wire [23:0] Pixel_full;
wire [13:0] Pixel_trunc;
wire [11:0] Pixel_prime_comb;

assign Pixel_full = blc_stage3 * G_val_stage3[27:16] + 512;
assign Pixel_trunc = Pixel_full[23:10];
assign Pixel_prime_comb = (Pixel_trunc > 12'hfff) ? 12'hfff : Pixel_trunc[11:0];

reg [11:0] Pixel_prime_stage;
always @(posedge clk) begin
    
end

//Shift 
reg [11:0] delay_sr [0:190]; 
reg [11:0] dpc_sr   [0:68];
reg [11:0] dem_sr   [0:34];

always @(posedge clk) begin
    Pixel_prime_stage <= Pixel_prime_comb;
    delay_sr[0] <= Pixel_prime_stage;
    for (i = 1; i < 191; i = i + 1) begin
        delay_sr[i] <= delay_sr[i-1];
    end

    dpc_sr[0] <= delay_sr[190]; 
    for (i = 1; i < 69; i = i + 1) begin
         dpc_sr[i] <= dpc_sr[i-1];
    end
end



//DPC prestage
reg  [7:0] dpc_cnt;
wire [3:0] dpc_x;
wire [3:0] dpc_y;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        dpc_cnt <= 0;
    else 
        dpc_cnt <= dpc_center_valid ? dpc_cnt + 1 : 0;
end

//DPC stage1
assign dpc_x = dpc_cnt[3:0];
assign dpc_y = dpc_cnt[7:4];

reg [11:0] r0_c0, r0_c2, r0_c4;
reg [11:0] r1_c1, r1_c2, r1_c3;
reg [11:0] r2_c0, r2_c1, r2_c2, r2_c3, r2_c4;
reg [11:0] r3_c1, r3_c2, r3_c3;
reg [11:0] r4_c0, r4_c2, r4_c4;

reg [11:0] py0_c0, py0_c2, py0_c4;
reg [11:0] py1_c1, py1_c2, py1_c3;
reg [11:0] py3_c1, py3_c2, py3_c3;
reg [11:0] py4_c0, py4_c2, py4_c4;

reg [11:0] w00, w02, w04;
reg [11:0] w11, w12, w13;
reg [11:0] w20, w21, w23, w24;
reg [11:0] w31, w32, w33;
reg [11:0] w40, w42, w44;

always @(*) begin

    r0_c0 = dpc_sr[68]; r0_c2 = dpc_sr[66]; r0_c4 = dpc_sr[64];
    r1_c1 = dpc_sr[51]; r1_c2 = dpc_sr[50]; r1_c3 = dpc_sr[49];
    r2_c0 = dpc_sr[36]; r2_c1 = dpc_sr[35]; r2_c2 = dpc_sr[34]; r2_c3 = dpc_sr[33]; r2_c4 = dpc_sr[32];
    r3_c1 = dpc_sr[19]; r3_c2 = dpc_sr[18]; r3_c3 = dpc_sr[17];
    r4_c0 = dpc_sr[4];  r4_c2 = dpc_sr[2];  r4_c4 = dpc_sr[0];

    py0_c0 = (dpc_y == 0)  ? r4_c0 : ((dpc_y == 1)  ? r2_c0 : r0_c0);
    py0_c2 = (dpc_y == 0)  ? r4_c2 : ((dpc_y == 1)  ? r2_c2 : r0_c2);
    py0_c4 = (dpc_y == 0)  ? r4_c4 : ((dpc_y == 1)  ? r2_c4 : r0_c4);

    py1_c1 = (dpc_y == 0)  ? r3_c1 : r1_c1;
    py1_c2 = (dpc_y == 0)  ? r3_c2 : r1_c2;
    py1_c3 = (dpc_y == 0)  ? r3_c3 : r1_c3;

    py3_c1 = (dpc_y == 15) ? r1_c1 : r3_c1;
    py3_c2 = (dpc_y == 15) ? r1_c2 : r3_c2;
    py3_c3 = (dpc_y == 15) ? r1_c3 : r3_c3;

    py4_c0 = (dpc_y == 15) ? r0_c0 : ((dpc_y == 14) ? r2_c0 : r4_c0);
    py4_c2 = (dpc_y == 15) ? r0_c2 : ((dpc_y == 14) ? r2_c2 : r4_c2);
    py4_c4 = (dpc_y == 15) ? r0_c4 : ((dpc_y == 14) ? r2_c4 : r4_c4);

    
    w00 = (dpc_x == 0)  ? py0_c4 : ((dpc_x == 1)  ? py0_c2 : py0_c0);
    w02 = py0_c2;
    w04 = (dpc_x == 15) ? py0_c0 : ((dpc_x == 14) ? py0_c2 : py0_c4);

    w11 = (dpc_x == 0)  ? py1_c3 : py1_c1; 
    w12 = py1_c2;
    w13 = (dpc_x == 15) ? py1_c1 : py1_c3;

    w20 = (dpc_x == 0)  ? r2_c4  : ((dpc_x == 1)  ? r2_c2  : r2_c0);
    w21 = (dpc_x == 0)  ? r2_c3  : r2_c1;
    w23 = (dpc_x == 15) ? r2_c1  : r2_c3;
    w24 = (dpc_x == 15) ? r2_c0  : ((dpc_x == 14) ? r2_c2  : r2_c4);

    w31 = (dpc_x == 0)  ? py3_c3 : py3_c1;
    w32 = py3_c2;
    w33 = (dpc_x == 15) ? py3_c1 : py3_c3;

    w40 = (dpc_x == 0)  ? py4_c4 : ((dpc_x == 1)  ? py4_c2 : py4_c0);
    w42 = py4_c2;
    w44 = (dpc_x == 15) ? py4_c0 : ((dpc_x == 14) ? py4_c2 : py4_c4);
end

reg [11:0] pw20_stage1, pw21_stage1, pw23_stage1, pw24_stage1;
reg [11:0] pw02_stage1, pw12_stage1, pw32_stage1, pw42_stage1;
reg [11:0] pw44_stage1, pw33_stage1, pw11_stage1, pw00_stage1;
reg [11:0] pw40_stage1, pw31_stage1, pw13_stage1, pw04_stage1;
reg [11:0] pc_stage1;

always @(posedge clk) begin
    pw20_stage1 <= w20; pw21_stage1 <= w21; pw23_stage1 <= w23; pw24_stage1 <= w24;
    pw02_stage1 <= w02; pw12_stage1 <= w12; pw32_stage1 <= w32; pw42_stage1 <= w42;
    pw44_stage1 <= w44; pw33_stage1 <= w33; pw11_stage1 <= w11; pw00_stage1 <= w00;
    pw40_stage1 <= w40; pw31_stage1 <= w31; pw13_stage1 <= w13; pw04_stage1 <= w04;
    pc_stage1   <= r2_c2;
end



// Stage 2 (Median
wire [11:0] mH_c2;  MEDIAN4 mH_inst  (.a(pw20_stage1), .b(pw21_stage1), .c(pw23_stage1), .d(pw24_stage1), .out(mH_c2));
wire [11:0] mV_c2;  MEDIAN4 mV_inst  (.a(pw02_stage1), .b(pw12_stage1), .c(pw32_stage1), .d(pw42_stage1), .out(mV_c2));
wire [11:0] mD1_c2; MEDIAN4 mD1_inst (.a(pw44_stage1), .b(pw33_stage1), .c(pw11_stage1), .d(pw00_stage1), .out(mD1_c2));
wire [11:0] mD2_c2; MEDIAN4 mD2_inst (.a(pw40_stage1), .b(pw31_stage1), .c(pw13_stage1), .d(pw04_stage1), .out(mD2_c2));

reg [11:0] median_stage2 [0:3]; 
reg [11:0] pixels_stage2 [0:15];  
reg [11:0] pc_stage2;

always @(posedge clk) begin
    median_stage2[0] <= mH_c2;
    median_stage2[1] <= mV_c2;
    median_stage2[2] <= mD1_c2;
    median_stage2[3] <= mD2_c2;
    pc_stage2   <= pc_stage1;

    // H
    pixels_stage2[ 0] <= pw20_stage1;
    pixels_stage2[ 1] <= pw21_stage1;
    pixels_stage2[ 2] <= pw23_stage1;
    pixels_stage2[ 3] <= pw24_stage1;
    // V
    pixels_stage2[ 4] <= pw02_stage1;
    pixels_stage2[ 5] <= pw12_stage1;
    pixels_stage2[ 6] <= pw32_stage1;
    pixels_stage2[ 7] <= pw42_stage1;

    pixels_stage2[ 8] <= pw44_stage1;
    pixels_stage2[ 9] <= pw33_stage1;
    pixels_stage2[10] <= pw11_stage1;
    pixels_stage2[11] <= pw00_stage1;
    
    pixels_stage2[12] <= pw40_stage1;
    pixels_stage2[13] <= pw31_stage1;
    pixels_stage2[14] <= pw13_stage1;
    pixels_stage2[15] <= pw04_stage1;
end

// DPC Stage 3
wire [11:0] d_stage3 [0:15];
ABS_DIFFERENCE ad_0 (.a(pixels_stage2[0]), .b(median_stage2[0]), .out(d_stage3[0]));
ABS_DIFFERENCE ad_1 (.a(pixels_stage2[1]), .b(median_stage2[0]), .out(d_stage3[1]));
ABS_DIFFERENCE ad_2 (.a(pixels_stage2[2]), .b(median_stage2[0]), .out(d_stage3[2]));
ABS_DIFFERENCE ad_3 (.a(pixels_stage2[3]), .b(median_stage2[0]), .out(d_stage3[3]));

ABS_DIFFERENCE ad_4 (.a(pixels_stage2[4]), .b(median_stage2[1]), .out(d_stage3[4]));
ABS_DIFFERENCE ad_5 (.a(pixels_stage2[5]), .b(median_stage2[1]), .out(d_stage3[5]));
ABS_DIFFERENCE ad_6 (.a(pixels_stage2[6]), .b(median_stage2[1]), .out(d_stage3[6]));
ABS_DIFFERENCE ad_7 (.a(pixels_stage2[7]), .b(median_stage2[1]), .out(d_stage3[7]));

ABS_DIFFERENCE ad_8  (.a(pixels_stage2[8]),  .b(median_stage2[2]),  .out(d_stage3[8]));
ABS_DIFFERENCE ad_9  (.a(pixels_stage2[9]),  .b(median_stage2[2]),  .out(d_stage3[9]));
ABS_DIFFERENCE ad_10 (.a(pixels_stage2[10]), .b(median_stage2[2]),  .out(d_stage3[10]));
ABS_DIFFERENCE ad_11 (.a(pixels_stage2[11]), .b(median_stage2[2]),  .out(d_stage3[11]));

ABS_DIFFERENCE ad_12 (.a(pixels_stage2[12]), .b(median_stage2[3]), .out(d_stage3[12]));
ABS_DIFFERENCE ad_13 (.a(pixels_stage2[13]), .b(median_stage2[3]), .out(d_stage3[13]));
ABS_DIFFERENCE ad_14 (.a(pixels_stage2[14]), .b(median_stage2[3]), .out(d_stage3[14]));
ABS_DIFFERENCE ad_15 (.a(pixels_stage2[15]), .b(median_stage2[3]), .out(d_stage3[15]));


wire [13:0] s_c3 [0:3];
assign s_c3[0] = ({2'b0, d_stage3[0]}  + {2'b0, d_stage3[1]})   + ({2'b0, d_stage3[2]}  + {2'b0, d_stage3[3]});
assign s_c3[1] = ({2'b0, d_stage3[4]}  + {2'b0, d_stage3[5]})   + ({2'b0, d_stage3[6]}  + {2'b0, d_stage3[7]});
assign s_c3[2] = ({2'b0, d_stage3[8]}  + {2'b0, d_stage3[9]})   + ({2'b0, d_stage3[10]} + {2'b0, d_stage3[11]});
assign s_c3[3] = ({2'b0, d_stage3[12]} + {2'b0, d_stage3[13]})  + ({2'b0, d_stage3[14]} + {2'b0, d_stage3[15]});

// Stage 3
reg [13:0] s_stage3 [0:3];
reg [11:0] m_stage3 [0:3];
reg [11:0] pc_stage3;

always @(posedge clk) begin
    s_stage3[0] <= s_c3[0];  s_stage3[1] <= s_c3[1];
    s_stage3[2] <= s_c3[2];  s_stage3[3] <= s_c3[3];
    m_stage3[0] <= median_stage2[0];  m_stage3[1] <= median_stage2[1];
    m_stage3[2] <= median_stage2[2];  m_stage3[3] <= median_stage2[3];
    pc_stage3   <= pc_stage2;
end

// Stage 4
wire [11:0] diff_c [0:3];

ABS_DIFFERENCE ad_16(pc_stage3, m_stage3[0], diff_c[0]); 
ABS_DIFFERENCE ad_17(pc_stage3, m_stage3[1], diff_c[1]);
ABS_DIFFERENCE ad_18(pc_stage3, m_stage3[2], diff_c[2]); 
ABS_DIFFERENCE ad_19(pc_stage3, m_stage3[3], diff_c[3]);

wire [1:0] dir_sel_c4;

assign dir_sel_c4 = (s_stage3[0] <= s_stage3[1] && s_stage3[0] <= s_stage3[2] && s_stage3[0] <= s_stage3[3]) ? 0 :
                    (s_stage3[1] <= s_stage3[2] && s_stage3[1] <= s_stage3[3])                               ? 1 :
                    (s_stage3[2] <= s_stage3[3])                                                             ? 2 : 3;


wire [11:0] dpc_out_c4;
assign dpc_out_c4 = (diff_c[dir_sel_c4] > 320) ? m_stage3[dir_sel_c4] : pc_stage3;

reg [11:0] dpc_out_stage;


always @(posedge clk) begin
    dpc_out_stage <= dpc_out_c4;
    dem_sr[0] <= dpc_out_stage;
    for (i=1; i<35; i=i+1) 
        dem_sr[i] <= dem_sr[i-1];
end


wire dem_center_valid;
assign dem_center_valid  = (global_cnt > 251 && global_cnt < 508);

// Demosaic 
reg [7:0] dem_cnt;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        dem_cnt <= 0;
    else 
        dem_cnt <= (dem_center_valid)? dem_cnt + 1 : 0;
end

//stage 1
wire [3:0] dem_x;      wire [3:0] dem_y;

assign dem_x = dem_cnt[3:0];
assign dem_y = dem_cnt[7:4];


wire x0, x15, y0, y15;

assign x0  = ~|dem_x; // dem_x == (4'b0000)
assign x15 = &dem_x;  // dem_x == (4'b1111)
assign y0  = ~|dem_y;   
assign y15 = &dem_y;  

wire [11:0] d_stage0_c0, d_stage0_c1, d_stage0_c2;
wire [11:0] d_stage1_c0, d_stage1_c1, d_stage1_c2;
wire [11:0] d_stage2_c0, d_stage2_c1, d_stage2_c2;

assign d_stage0_c0 = dem_sr[34]; assign d_stage0_c1 = dem_sr[33]; assign d_stage0_c2 = dem_sr[32];
assign d_stage1_c0 = dem_sr[18]; assign d_stage1_c1 = dem_sr[17]; assign d_stage1_c2 = dem_sr[16];
assign d_stage2_c0 = dem_sr[2];  assign d_stage2_c1 = dem_sr[1];  assign d_stage2_c2 = dem_sr[0];



wire [11:0] topixel_c0,topixel_c1,topixel_c2;//y

wire [11:0] bot_c0, bot_c1, bot_c2;

assign topixel_c0 = y0  ? d_stage2_c0 : d_stage0_c0;
assign topixel_c1 = y0  ? d_stage2_c1 : d_stage0_c1;
assign topixel_c2 = y0  ? d_stage2_c2 : d_stage0_c2;
assign bot_c0 = y15 ? d_stage0_c0 : d_stage2_c0;
assign bot_c1 = y15 ? d_stage0_c1 : d_stage2_c1;
assign bot_c2 = y15 ? d_stage0_c2 : d_stage2_c2;

// 3x3
wire [11:0] d_NW, d_N, d_NE, d_W, d_C, d_E ,d_SW ,d_S,d_SE;

assign d_NW = x0  ? topixel_c2 : topixel_c0;
assign d_N  = topixel_c1;
assign d_NE = x15 ? topixel_c0 : topixel_c2;
assign d_W  = x0  ? d_stage1_c2 : d_stage1_c0;
assign d_C  = d_stage1_c1;
assign d_E  = x15 ? d_stage1_c0 : d_stage1_c2;
assign d_SW = x0  ? bot_c2 : bot_c0;
assign d_S  = bot_c1;
assign d_SE = x15 ? bot_c0 : bot_c2;

wire [12:0] sum_H, sum_V;
wire [13:0] sum_ortho, sum_diag;

assign sum_H    = {1'b0, d_W} + {1'b0, d_E};
assign sum_V    = {1'b0, d_N} + {1'b0, d_S};
assign sum_ortho = {1'b0, sum_H} + {1'b0, sum_V};
assign sum_diag  = ({2'b0, d_NW} + {2'b0, d_NE}) + ({2'b0, d_SW} + {2'b0, d_SE});


reg [11:0] aO_stage1, aD_stage1, aH_stage1, aV_stage1, dC_stage1;
reg [1:0]  col_dem_stage1;
always @(posedge clk) begin
    aO_stage1 <= sum_ortho[13:2];   // >> 2
    aD_stage1 <= sum_diag[13:2];    // >> 2
    aH_stage1 <= sum_H[12:1];       // >> 1
    aV_stage1 <= sum_V[12:1];       // >> 1
    dC_stage1 <= d_C;
    col_dem_stage1 <= {dem_y[0], dem_x[0]};
end

// Stage 2
wire [1:0] sel;
wire same_parity;

wire [11:0] r_y0 ; 
wire [11:0] r_y1; 
wire [11:0] dR_c2;

wire [11:0] b_y0;
wire [11:0] b_y1;
wire [11:0] dB_c2;

wire [11:0] dG_c2;


assign sel = col_dem_stage1;
assign same_parity = ~(sel[1] ^ sel[0]);

assign r_y0 = sel[0] ? aH_stage1 : dC_stage1; 
assign r_y1 = sel[0] ? aD_stage1 : aV_stage1; 
assign dR_c2 = sel[1] ? r_y1 : r_y0;

assign b_y0 = sel[0] ? aV_stage1 : aD_stage1;
assign b_y1 = sel[0] ? dC_stage1 : aH_stage1;
assign dB_c2 = sel[1] ? b_y1 : b_y0;

assign dG_c2 = same_parity ? aO_stage1 : dC_stage1;

reg [11:0] dR_stage2, dG_stage2, dB_stage2;
always @(posedge clk) begin
    dR_stage2 <= dR_c2;
    dG_stage2 <= dG_c2;
    dB_stage2 <= dB_c2;
end



//  CCM 
// Stage 1

wire signed [14:0] s_Sum_c;
wire signed [21:0] common_to_sub_comb; 

wire signed [14:0] s_dR;
wire signed [14:0] s_dG;
wire signed [14:0] s_dB;

wire signed [24:0] r_1150_comb;
wire signed [24:0] g_1150_comb;
wire signed [24:0] b_1150_comb;

assign s_Sum_c = $signed({1'b0, dR_stage2}) + $signed({1'b0, dG_stage2}) + $signed({1'b0, dB_stage2});
assign common_to_sub_comb = (s_Sum_c <<< 5) + (s_Sum_c <<< 4) + (s_Sum_c <<< 1); ///32 + 16 + 2

assign s_dR = {3'b0, dR_stage2};
assign s_dG = {3'b0, dG_stage2};
assign s_dB = {3'b0, dB_stage2};

assign r_1150_comb = (s_dR <<< 10) + (s_dR <<< 7) - (s_dR <<< 1); //1024+128-2
assign g_1150_comb = (s_dG <<< 10) + (s_dG <<< 7) - (s_dG <<< 1);
assign b_1150_comb = (s_dB <<< 10) + (s_dB <<< 7) - (s_dB <<< 1);

reg signed [21:0] common_to_sub;//50 to share hardware
reg signed [24:0] r_1150, g_1150, b_1150;

always @(posedge clk) begin
    common_to_sub <= common_to_sub_comb;
    r_1150 <= r_1150_comb; 
    g_1150 <= g_1150_comb; 
    b_1150 <= b_1150_comb;
end

// Stage 2
wire signed [24:0] cR_full;
wire signed [24:0] cG_full;
wire signed [24:0] cB_full;

wire signed [14:0] r_shift;
wire signed [14:0] g_shift;
wire signed [14:0] b_shift;

wire [11:0] r_out_comb;
wire [11:0] g_out_comb;
wire [11:0] b_out_comb;

assign cR_full = (r_1150 + 512) - common_to_sub;
assign cG_full = (g_1150 + 512) - common_to_sub;
assign cB_full = (b_1150 + 512) - common_to_sub;

assign r_shift = cR_full >>> 10;
assign g_shift = cG_full >>> 10;
assign b_shift = cB_full >>> 10;

assign r_out_comb = (r_shift[14]) ? 0 : (r_shift[13:12] != 2'b00) ? 12'hfff : r_shift[11:0];
assign g_out_comb = (g_shift[14]) ? 0 : (g_shift[13:12] != 2'b00) ? 12'hfff : g_shift[11:0];
assign b_out_comb = (b_shift[14]) ? 0 : (b_shift[13:12] != 2'b00) ? 12'hfff : b_shift[11:0];

//Output
wire out_valid_comb;
assign out_valid_comb  = (global_cnt > 254 && global_cnt < 511);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        r_out <= 0; 
        g_out <= 0; 
        b_out <= 0;
    end 
    else begin
        out_valid <= out_valid_comb;
        if (out_valid_comb) begin
            r_out <= r_out_comb;
            g_out <= g_out_comb;
            b_out <= b_out_comb;
        end 
        else begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
        end
    end
end
endmodule

module MEDIAN4(
    input  [11:0] a, b, c, d,
    output [11:0] out
);
    wire [11:0] min1;
    wire [11:0] max1;
    wire [11:0] min2;
    wire [11:0] max2;
    wire [11:0] mid1;
    wire [11:0] mid2;
    wire [12:0] sum;

    assign min1 = (a < b) ? a : b;
    assign max1 = (a > b) ? a : b;
    assign min2 = (c < d) ? c : d;
    assign max2 = (c > d) ? c : d;
    assign mid1 = (min1 > min2) ? min1 : min2;
    assign mid2 = (max1 < max2) ? max1 : max2;
    assign sum  = {1'b0, mid1} + {1'b0, mid2};
    assign out = sum[12:1];
endmodule

module ABS_DIFFERENCE(
    input  [11:0] a, b,
    output [11:0] out
);
    wire [12:0] sub;
    wire sign;

    assign sub = {1'b0, a} - {1'b0, b};
    assign sign = sub[12];
    assign out = (sub[11:0] ^ {12{sign}}) + sign;
endmodule 