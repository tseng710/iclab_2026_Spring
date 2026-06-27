module CDNA(
    // Input Port
    clk,
    rst_n,
    instruction_in_valid,
    image_in_valid,
    weight_in_valid,
    in_data,
    
    // Output Port
    out_valid,
    out_data
);

input         clk;
input         rst_n;
input         instruction_in_valid;
input         image_in_valid;
input         weight_in_valid;
input  [31:0] in_data;

output reg        out_valid;
output reg [31:0] out_data;

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;

//Example DW code
//DW_fp_add #(inst_sig_width, inst_exp_width ,inst_ieee_compliance, inst_arch_type, inst_arch, inst_faithful_round) u_add(.a(add_in_a), .b(add_in_b), .z(add_out), .status(add_status), .rnd(rnd));
//Example DW code

// FSM states
parameter IDLE    = 3'd0;
parameter LOAD_W  = 3'd1;
parameter LOAD_I  = 3'd2;
parameter PROCESS = 3'd3;
parameter OUTPUT  = 3'd4;

reg [2:0]  state_curr, state_next;
reg [9:0]  sys_cnt; 

reg        mode;
reg [1:0]  act_sel;                
reg [7:0]  input_counter;                   
reg [7:0]  output_counter;          

reg [31:0] weight_memory [0:143];
reg [31:0] feature_map_A [0:127];   
reg [31:0] feature_map_B [0:127];   
reg [1:0]  switch_pool_layer0 [0:31]; 
reg [1:0]  switch_pool_layer1 [0:7];

reg [31:0] maxval_ch0, minval_ch0;
reg [31:0] maxval_ch1, minval_ch1;
reg [31:0] scale_diff_ch0, scale_diff_ch1;
reg [31:0] inv_scale_ch0,  inv_scale_ch1;

// Pipeline control
reg        pipeline_ctrl[0:15];
reg [2:0]  pipeline_layer[0:15];
reg [3:0]  pipeline_y[0:15];
reg [3:0]  pipeline_x[0:15];
reg [1:0]  pipeline_sub_position[0:15];

integer i;
integer t_i;

// FSM
wire is_layer_gen_done;
wire is_layer_drain_done;

always @(*) begin
    state_next = state_curr;
    case (state_curr)
        IDLE: begin
            if (instruction_in_valid) state_next = LOAD_W;
        end
        LOAD_W: begin
            if (weight_in_valid && input_counter == 143) state_next = LOAD_I;
        end
        LOAD_I: begin
            if (image_in_valid  && input_counter == 127) state_next = PROCESS;
        end
        PROCESS: begin
            // Output limit is checked at the new end-stage 15
            if (is_layer_drain_done && pipeline_layer[15] == 3) state_next = OUTPUT;
        end
        OUTPUT: begin
            if (output_counter == 127) state_next = IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_curr <= IDLE;
    end else begin       
        state_curr <= state_next;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sys_cnt <= 0;
    end else if (state_curr == PROCESS) begin
        sys_cnt <= sys_cnt + 1;
    end else begin
        sys_cnt <= 0;
    end
end

// Decoding ,Loading
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        mode    <= 1'b0; 
        act_sel <= 2'b00; 
    end else if (instruction_in_valid) begin 
        mode    <= in_data[2]; 
        act_sel <= in_data[1:0]; 
    end
end

// Input Counters
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_counter <= 8'd0;
    end else if (weight_in_valid || image_in_valid) begin
        input_counter <= input_counter + 8'd1;
    end else begin
        input_counter <= 8'd0;
    end
end

integer i_weight;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i_weight = 0; i_weight < 144; i_weight = i_weight + 1) begin
            weight_memory[i_weight] <= 32'd0;
        end
    end else if (weight_in_valid) begin
        weight_memory[input_counter] <= in_data;
    end
end

// Pre-processing
wire [31:0] cmp1_b = (input_counter < 8'd64 ? (input_counter == 8'd0 ? in_data : maxval_ch0) : (input_counter == 8'd64 ? in_data : maxval_ch1));
wire [31:0] cmp2_b = (input_counter < 8'd64 ? (input_counter == 8'd0 ? in_data : minval_ch0) : (input_counter == 8'd64 ? in_data : minval_ch1));
wire [31:0] img_max, img_min;

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_cmp1 (
    .a(in_data), .b(cmp1_b), .zctr(1'b0), .z1(img_max), .z0(), .status0(), .status1(), .aeqb(), .agtb(), .altb(), .unordered()
);
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_cmp2 (
    .a(in_data), .b(cmp2_b), .zctr(1'b0), .z1(), .z0(img_min), .status0(), .status1(), .aeqb(), .agtb(), .altb(), .unordered()
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        maxval_ch0 <= 0; 
        minval_ch0 <= 0; 
        maxval_ch1 <= 0; 
        minval_ch1 <= 0; 
    end 
    else if (state_curr == LOAD_I && image_in_valid) begin
        if (input_counter < 8'd64) begin 
            maxval_ch0 <= img_max; 
            minval_ch0 <= img_min; 
        end 
        else begin 
            maxval_ch1 <= img_max; 
            minval_ch1 <= img_min; 
        end
    end
end

// Pre-Diff & Reciprocal
reg [31:0] pre_diff_a_reg, pre_diff_b_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pre_diff_a_reg <= 0;
        pre_diff_b_reg <= 0;
    end 
    else if (state_curr == PROCESS) begin
        if (sys_cnt == 0) begin 
            pre_diff_a_reg <= maxval_ch0; 
            pre_diff_b_reg <= minval_ch0; 
        end
        if (sys_cnt == 1) begin 
            pre_diff_a_reg <= maxval_ch1; 
            pre_diff_b_reg <= minval_ch1; 
        end
    end
end

wire [31:0] pre_sub_z;
wire [31:0] inv_scale_w0, inv_scale_w1;

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_pre_sub (
    .a(pre_diff_a_reg), .b(pre_diff_b_reg), .rnd(3'b0), .z(pre_sub_z), .status()
);

// Replaced DW_fp_div with DW_fp_recip for calculating 1 / (Max - Min)
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) u_pre_recip0 (
    .a(scale_diff_ch0), .rnd(3'b0), .z(inv_scale_w0), .status()
);
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) u_pre_recip1 (
    .a(scale_diff_ch1), .rnd(3'b0), .z(inv_scale_w1), .status()
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        scale_diff_ch0 <= 0; 
        scale_diff_ch1 <= 0; 
        inv_scale_ch0  <= 0; 
        inv_scale_ch1  <= 0;
    end 
    else if (state_curr == PROCESS) begin
        if (sys_cnt == 1) scale_diff_ch0 <= pre_sub_z;
        if (sys_cnt == 2) scale_diff_ch1 <= pre_sub_z;
        if (sys_cnt == 2) inv_scale_ch0  <= inv_scale_w0;
        if (sys_cnt == 3) inv_scale_ch1  <= inv_scale_w1;
    end
end

// FAST PRE_SCALE

wire [6:0] ps_rd_base = (sys_cnt >= 4 && sys_cnt <= 35) ? (sys_cnt - 4) * 2 : 0;

wire [6:0] ps_wr_base = (sys_cnt >= 7 && sys_cnt <= 38) ? (sys_cnt - 7) * 2 : 0;

// Stage 1
reg [31:0] ps_r0_reg, ps_r1_reg, ps_r2_reg, ps_r3_reg;
always @(posedge clk) begin
    if (state_curr == PROCESS && sys_cnt >= 4 && sys_cnt <= 35) begin
        ps_r0_reg <= feature_map_A[ps_rd_base];
        ps_r1_reg <= feature_map_A[ps_rd_base + 1];
        ps_r2_reg <= feature_map_A[ps_rd_base + 64];
        ps_r3_reg <= feature_map_A[ps_rd_base + 65];
    end
end

// Stage 2
wire [31:0] ps_s0, ps_s1, ps_s2, ps_s3;
reg  [31:0] ps_s0_reg, ps_s1_reg, ps_s2_reg, ps_s3_reg;

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_sub0 (.a(ps_r0_reg), .b(minval_ch0), .rnd(3'b0), .z(ps_s0), .status());
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_sub1 (.a(ps_r1_reg), .b(minval_ch0), .rnd(3'b0), .z(ps_s1), .status());
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_sub2 (.a(ps_r2_reg), .b(minval_ch1), .rnd(3'b0), .z(ps_s2), .status());
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_sub3 (.a(ps_r3_reg), .b(minval_ch1), .rnd(3'b0), .z(ps_s3), .status());

always @(posedge clk) begin
    if (state_curr == PROCESS && sys_cnt >= 5 && sys_cnt <= 36) begin
        ps_s0_reg <= ps_s0;
        ps_s1_reg <= ps_s1;
        ps_s2_reg <= ps_s2;
        ps_s3_reg <= ps_s3;
    end
end

// Stage 3
wire [31:0] ps_m0, ps_m1, ps_m2, ps_m3;
reg  [31:0] ps_m0_reg, ps_m1_reg, ps_m2_reg, ps_m3_reg;

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_mul0 (.a(ps_s0_reg), .b(inv_scale_ch0), .rnd(3'b0), .z(ps_m0), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_mul1 (.a(ps_s1_reg), .b(inv_scale_ch0), .rnd(3'b0), .z(ps_m1), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_mul2 (.a(ps_s2_reg), .b(inv_scale_ch1), .rnd(3'b0), .z(ps_m2), .status());
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) ps_mul3 (.a(ps_s3_reg), .b(inv_scale_ch1), .rnd(3'b0), .z(ps_m3), .status());

always @(posedge clk) begin
    if (state_curr == PROCESS && sys_cnt >= 6 && sys_cnt <= 37) begin
        ps_m0_reg <= ps_m0;
        ps_m1_reg <= ps_m1;
        ps_m2_reg <= ps_m2;
        ps_m3_reg <= ps_m3;
    end
end

// Coordinate
wire [3:0] coord_limit_xy  = (pipeline_layer[0] == 3'd0 || pipeline_layer[0] == 3'd2) ? 4'd3 : (pipeline_layer[0] == 3'd1) ? 4'd1 : 4'd7;
wire [1:0] coord_limit_sub = (pipeline_layer[0] < 3'd2) ? 2'd3 : 2'd0;
wire [3:0] output_limit_xy = (pipeline_layer[15] == 3'd0 || pipeline_layer[15] == 3'd2) ? 4'd3 : (pipeline_layer[15] == 3'd1) ? 4'd1 : 4'd7;

assign is_layer_gen_done   = (pipeline_y[0] == coord_limit_xy) && (pipeline_x[0] == coord_limit_xy) && (pipeline_sub_position[0] == coord_limit_sub);
assign is_layer_drain_done = pipeline_ctrl[15] && (pipeline_layer[15] == pipeline_layer[0]) && (pipeline_y[15] == output_limit_xy) && (pipeline_x[15] == output_limit_xy);

wire roll_sub = (pipeline_sub_position[0] == coord_limit_sub);
wire roll_x   = roll_sub && (pipeline_x[0] == coord_limit_xy);
wire roll_y   = roll_x   && (pipeline_y[0] == coord_limit_xy);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pipeline_ctrl[0]         <= 0; 
        pipeline_layer[0]        <= 0; 
        pipeline_y[0]            <= 0; 
        pipeline_x[0]            <= 0; 
        pipeline_sub_position[0] <= 0;
    end 
    else begin
        if (state_curr == PROCESS) begin
            if (sys_cnt == 39) begin 
                pipeline_ctrl[0] <= 1; 
            end 
            else if (pipeline_ctrl[0] || sys_cnt > 39) begin
                if ((pipeline_layer[0] == 3) && is_layer_gen_done) begin 
                    pipeline_ctrl[0] <= 0;
                end 
                else if (is_layer_gen_done && is_layer_drain_done) begin
                    pipeline_ctrl[0]         <= 1; 
                    pipeline_layer[0]        <= pipeline_layer[0] + 1; 
                    pipeline_y[0]            <= 0; 
                    pipeline_x[0]            <= 0; 
                    pipeline_sub_position[0] <= 0;
                end 
                else if (is_layer_gen_done) begin
                    pipeline_ctrl[0] <= 0;
                end 
                else begin
                    pipeline_ctrl[0] <= 1;
                    pipeline_sub_position[0] <= roll_sub ? 0 : (pipeline_sub_position[0] + 1);
                    if (roll_sub) begin
                        pipeline_x[0] <= roll_x ? 0 : (pipeline_x[0] + 1);
                    end
                    if (roll_x) begin
                        pipeline_y[0] <= roll_y ? 0 : (pipeline_y[0] + 1);
                    end
                end
            end
        end 
        else begin
            pipeline_ctrl[0]         <= 0; 
            pipeline_layer[0]        <= 0; 
            pipeline_y[0]            <= 0; 
            pipeline_x[0]            <= 0; 
            pipeline_sub_position[0] <= 0;
        end
    end
end

// Pipeline propagation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 1; i <= 15; i = i + 1) begin
            pipeline_ctrl[i]         <= 1'b0; 
            pipeline_layer[i]        <= 0; 
            pipeline_y[i]            <= 0; 
            pipeline_x[i]            <= 0; 
            pipeline_sub_position[i] <= 0;
        end
    end 
    else begin
        for (i = 1; i <= 15; i = i + 1) begin
            if (i == 9) begin
                pipeline_ctrl[9] <= pipeline_ctrl[8] && ((pipeline_layer[8] < 3'd2) ? (pipeline_sub_position[8] == 2'd3) : 1'b1);
            end 
            else begin
                pipeline_ctrl[i] <= pipeline_ctrl[i - 1];
            end
            
            pipeline_layer[i]        <= pipeline_layer[i - 1]; 
            pipeline_y[i]            <= pipeline_y[i - 1]; 
            pipeline_x[i]            <= pipeline_x[i - 1]; 
            pipeline_sub_position[i] <= pipeline_sub_position[i - 1];
        end
    end
end

// COMPUTE 
wire       is_conv = (pipeline_layer[0] < 2);
wire [3:0] base_x  = is_conv ? {pipeline_x[0][2:0], pipeline_sub_position[0][0]} : pipeline_x[0];
wire [3:0] base_y  = is_conv ? {pipeline_y[0][2:0], pipeline_sub_position[0][1]} : pipeline_y[0];
wire [3:0] b_max   = (pipeline_layer[0] == 0 || pipeline_layer[0] == 3) ? 7 : 3;

reg [31:0] stg1_fm_vals_ch0 [0:8];   
reg [31:0] stg1_fm_vals_ch1 [0:8];
reg [31:0] stg1_wght_out0_in0 [0:8]; 
reg [31:0] stg1_wght_out0_in1 [0:8];
reg [31:0] stg1_wght_out1_in0 [0:8]; 
reg [31:0] stg1_wght_out1_in1 [0:8];

genvar k;
generate
    for (k = 0; k < 9; k = k + 1) begin : PE_PIPELINE
        wire       c_pad_flag; 
        wire [3:0] c_px, c_py;
        wire [6:0] c_addr_A0, c_addr_A1, c_addr_B0, c_addr_B1;
        wire [7:0] c_w_out0_in0, c_w_out0_in1, c_w_out1_in0, c_w_out1_in1;

        PE_ADDR_GEN #(.KERNEL_INDEX(k)) u_addr_gen (
            .coord_x(base_x), .coord_y(base_y), .coord_boundary(b_max), .layer_id_0(pipeline_layer[0]),
            .padding_out(c_pad_flag), .padded_x(c_px), .padded_y(c_py),
            .fm_a_addr_l0(c_addr_A0), .fm_a_addr_l1(c_addr_A1), .fm_b_addr_l0(c_addr_B0), .fm_b_addr_l1(c_addr_B1),
            .w_idx_out0_in0(c_w_out0_in0), .w_idx_out0_in1(c_w_out0_in1), .w_idx_out1_in0(c_w_out1_in0), .w_idx_out1_in1(c_w_out1_in1)
        );
        
        reg r_pad_flag; 
        reg [3:0] r_py, r_px;
        reg [6:0] r_addr_A0, r_addr_A1, r_addr_B0, r_addr_B1;
        reg [7:0] r_w_out0_in0, r_w_out0_in1, r_w_out1_in0, r_w_out1_in1;

        always @(posedge clk) begin
            if (pipeline_ctrl[0]) begin
                r_pad_flag   <= c_pad_flag; 
                r_py         <= c_py; 
                r_px         <= c_px;
                r_addr_A0    <= c_addr_A0; 
                r_addr_A1    <= c_addr_A1; 
                r_addr_B0    <= c_addr_B0; 
                r_addr_B1    <= c_addr_B1;
                r_w_out0_in0 <= c_w_out0_in0; 
                r_w_out0_in1 <= c_w_out0_in1; 
                r_w_out1_in0 <= c_w_out1_in0; 
                r_w_out1_in1 <= c_w_out1_in1;
            end
        end

        wire [6:0] addr_L0_ch1 = r_addr_A0 + 64; 
        wire [6:0] addr_L1_ch1 = r_addr_A1 + 16;
        wire [6:0] addr_L2_ch1 = r_addr_B0 + 4;  
        wire [6:0] addr_L3_ch1 = r_addr_B1 + 16;
        
        wire is_unpool_hit_L2_ch0 = (switch_pool_layer1[r_addr_B0]   == {r_py[0], r_px[0]});
        wire is_unpool_hit_L3_ch0 = (switch_pool_layer0[r_addr_B1]   == {r_py[0], r_px[0]});
        wire is_unpool_hit_L2_ch1 = (switch_pool_layer1[addr_L2_ch1] == {r_py[0], r_px[0]});
        wire is_unpool_hit_L3_ch1 = (switch_pool_layer0[addr_L3_ch1] == {r_py[0], r_px[0]});

        reg [31:0] fetch_ch0, fetch_ch1;
        always @(*) begin
            fetch_ch0 = 0; 
            fetch_ch1 = 0;
            case(pipeline_layer[1])
                0: begin 
                    fetch_ch0 = feature_map_A[r_addr_A0]; 
                    fetch_ch1 = feature_map_A[addr_L0_ch1]; 
                end
                1: begin 
                    fetch_ch0 = feature_map_B[r_addr_A1]; 
                    fetch_ch1 = feature_map_B[addr_L1_ch1]; 
                end
                2: begin 
                    if (is_unpool_hit_L2_ch0) fetch_ch0 = feature_map_A[r_addr_B0]; 
                    if (is_unpool_hit_L2_ch1) fetch_ch1 = feature_map_A[addr_L2_ch1]; 
                end
                3: begin 
                    if (is_unpool_hit_L3_ch0) fetch_ch0 = feature_map_B[r_addr_B1]; 
                    if (is_unpool_hit_L3_ch1) fetch_ch1 = feature_map_B[addr_L3_ch1]; 
                end
            endcase
        end

        always @(posedge clk) begin
            stg1_fm_vals_ch0[k]   <= (r_pad_flag && !mode) ? 0 : fetch_ch0;
            stg1_fm_vals_ch1[k]   <= (r_pad_flag && !mode) ? 0 : fetch_ch1;
            
            stg1_wght_out0_in0[k] <= weight_memory[r_w_out0_in0]; 
            stg1_wght_out0_in1[k] <= weight_memory[r_w_out0_in1];
            stg1_wght_out1_in0[k] <= weight_memory[r_w_out1_in0]; 
            stg1_wght_out1_in1[k] <= weight_memory[r_w_out1_in1];
        end
    end
endgenerate

// STAGE 2
wire [31:0] c_mult_out0_ch0 [0:8]; 
wire [31:0] c_mult_out0_ch1 [0:8];
wire [31:0] c_mult_out1_ch0 [0:8]; 
wire [31:0] c_mult_out1_ch1 [0:8];
reg  [31:0] stg2_mul_out0 [0:17];  
reg  [31:0] stg2_mul_out1 [0:17];

genvar k_mult;
generate
    for (k_mult = 0; k_mult < 9; k_mult = k_mult + 1) begin : MULT_ARRAY
        DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_m0_0 (.a(stg1_fm_vals_ch0[k_mult]), .b(stg1_wght_out0_in0[k_mult]), .rnd(3'b0), .z(c_mult_out0_ch0[k_mult]), .status());
        DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_m1_0 (.a(stg1_fm_vals_ch1[k_mult]), .b(stg1_wght_out0_in1[k_mult]), .rnd(3'b0), .z(c_mult_out0_ch1[k_mult]), .status());
        DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_m0_1 (.a(stg1_fm_vals_ch0[k_mult]), .b(stg1_wght_out1_in0[k_mult]), .rnd(3'b0), .z(c_mult_out1_ch0[k_mult]), .status());
        DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_m1_1 (.a(stg1_fm_vals_ch1[k_mult]), .b(stg1_wght_out1_in1[k_mult]), .rnd(3'b0), .z(c_mult_out1_ch1[k_mult]), .status());

        always @(posedge clk) begin
            if (pipeline_ctrl[2]) begin
                stg2_mul_out0[k_mult*2]   <= c_mult_out0_ch0[k_mult]; 
                stg2_mul_out0[k_mult*2+1] <= c_mult_out0_ch1[k_mult];
                
                stg2_mul_out1[k_mult*2]   <= c_mult_out1_ch0[k_mult]; 
                stg2_mul_out1[k_mult*2+1] <= c_mult_out1_ch1[k_mult];
            end
        end
    end
endgenerate

//STAGE 3
wire [31:0] c_add_l1_0 [0:8]; 
wire [31:0] c_add_l1_1 [0:8]; 
reg  [31:0] stg3_sum_0 [0:8]; 
reg  [31:0] stg3_sum_1 [0:8];

wire [31:0] c_add_l2_0 [0:3]; 
wire [31:0] c_add_l2_1 [0:3]; 
reg  [31:0] stg4_sum_0 [0:4]; 
reg  [31:0] stg4_sum_1 [0:4];

wire [31:0] c_add_l3_0 [0:1]; 
wire [31:0] c_add_l3_1 [0:1]; 
reg  [31:0] stg5_sum_0 [0:2]; 
reg  [31:0] stg5_sum_1 [0:2];

wire [31:0] c_add_l4_0, c_add_l4_1;                         
reg  [31:0] stg6_sum_0 [0:1]; 
reg  [31:0] stg6_sum_1 [0:1];

wire [31:0] c_add_l5_0, c_add_l5_1;                         
reg  [31:0] stg7_conv_0, stg7_conv_1;

genvar k_add1, k_add2;
generate
    for (k_add1 = 0; k_add1 < 9; k_add1 = k_add1 + 1) begin : TREE_L1
        DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L1_0 (.a(stg2_mul_out0[k_add1*2]), .b(stg2_mul_out0[k_add1*2+1]), .rnd(3'b0), .z(c_add_l1_0[k_add1]), .status());
        DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L1_1 (.a(stg2_mul_out1[k_add1*2]), .b(stg2_mul_out1[k_add1*2+1]), .rnd(3'b0), .z(c_add_l1_1[k_add1]), .status());
    end
    for (k_add2 = 0; k_add2 < 4; k_add2 = k_add2 + 1) begin : TREE_L2
        DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L2_0 (.a(stg3_sum_0[k_add2*2]), .b(stg3_sum_0[k_add2*2+1]), .rnd(3'b0), .z(c_add_l2_0[k_add2]), .status());
        DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L2_1 (.a(stg3_sum_1[k_add2*2]), .b(stg3_sum_1[k_add2*2+1]), .rnd(3'b0), .z(c_add_l2_1[k_add2]), .status());
    end
endgenerate

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L3_0_0 (.a(stg4_sum_0[0]), .b(stg4_sum_0[1]), .rnd(3'b0), .z(c_add_l3_0[0]), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L3_1_0 (.a(stg4_sum_0[2]), .b(stg4_sum_0[3]), .rnd(3'b0), .z(c_add_l3_0[1]), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L3_0_1 (.a(stg4_sum_1[0]), .b(stg4_sum_1[1]), .rnd(3'b0), .z(c_add_l3_1[0]), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L3_1_1 (.a(stg4_sum_1[2]), .b(stg4_sum_1[3]), .rnd(3'b0), .z(c_add_l3_1[1]), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L4_0 (.a(stg5_sum_0[0]), .b(stg5_sum_0[1]), .rnd(3'b0), .z(c_add_l4_0), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L4_1 (.a(stg5_sum_1[0]), .b(stg5_sum_1[1]), .rnd(3'b0), .z(c_add_l4_1), .status());

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L5_0 (.a(stg6_sum_0[0]), .b(stg6_sum_0[1]), .rnd(3'b0), .z(c_add_l5_0), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_L5_1 (.a(stg6_sum_1[0]), .b(stg6_sum_1[1]), .rnd(3'b0), .z(c_add_l5_1), .status());

always @(posedge clk) begin
    if (pipeline_ctrl[3]) begin
        for (t_i=0; t_i<9; t_i=t_i+1) begin 
            stg3_sum_0[t_i] <= c_add_l1_0[t_i]; 
            stg3_sum_1[t_i] <= c_add_l1_1[t_i]; 
        end
    end
    
    if (pipeline_ctrl[4]) begin 
        for (t_i=0; t_i<4; t_i=t_i+1) begin 
            stg4_sum_0[t_i] <= c_add_l2_0[t_i]; 
            stg4_sum_1[t_i] <= c_add_l2_1[t_i]; 
        end 
        stg4_sum_0[4] <= stg3_sum_0[8]; 
        stg4_sum_1[4] <= stg3_sum_1[8]; 
    end
    
    if (pipeline_ctrl[5]) begin 
        stg5_sum_0[0] <= c_add_l3_0[0]; 
        stg5_sum_0[1] <= c_add_l3_0[1]; 
        stg5_sum_0[2] <= stg4_sum_0[4]; 
        
        stg5_sum_1[0] <= c_add_l3_1[0]; 
        stg5_sum_1[1] <= c_add_l3_1[1]; 
        stg5_sum_1[2] <= stg4_sum_1[4]; 
    end
    
    if (pipeline_ctrl[6]) begin 
        stg6_sum_0[0] <= c_add_l4_0; 
        stg6_sum_0[1] <= stg5_sum_0[2]; 
        
        stg6_sum_1[0] <= c_add_l4_1; 
        stg6_sum_1[1] <= stg5_sum_1[2]; 
    end
    
    if (pipeline_ctrl[7]) begin 
        stg7_conv_0 <= c_add_l5_0; 
        stg7_conv_1 <= c_add_l5_1; 
    end
end

// STAGE 8
reg  [31:0] pool_max_val_0, pool_max_val_1; 
reg  [1:0]  pool_max_idx_0, pool_max_idx_1;
wire [31:0] c_pool_res_0, c_pool_res_1; 
wire        c_pool_gt_0, c_pool_gt_1;

wire [31:0] next_pool_m0 = (pipeline_sub_position[8] == 0) ? stg7_conv_0 : c_pool_res_0;
wire [1:0]  next_pool_i0 = (pipeline_sub_position[8] == 0) ? 0 : (c_pool_gt_0 ? pipeline_sub_position[8] : pool_max_idx_0);
wire [31:0] next_pool_m1 = (pipeline_sub_position[8] == 0) ? stg7_conv_1 : c_pool_res_1;
wire [1:0]  next_pool_i1 = (pipeline_sub_position[8] == 0) ? 0 : (c_pool_gt_1 ? pipeline_sub_position[8] : pool_max_idx_1);

wire [4:0]  pool0_addr_0 = {1'b0, pipeline_y[8][1:0], pipeline_x[8][1:0]}; 
wire [4:0]  pool0_addr_1 = {1'b1, pipeline_y[8][1:0], pipeline_x[8][1:0]};
wire [3:0]  pool1_addr_0 = {1'b0, pipeline_y[8][0],   pipeline_x[8][0]};   
wire [3:0]  pool1_addr_1 = {1'b1, pipeline_y[8][0],   pipeline_x[8][0]};

reg  [31:0] stg9_pool_0, stg9_pool_1;
integer i_pool;

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_pool_cmp_0 (.a(stg7_conv_0), .b(pool_max_val_0), .zctr(1'b0), .z1(c_pool_res_0), .agtb(c_pool_gt_0), .z0(), .aeqb(), .altb(), .unordered(), .status0(), .status1());
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_pool_cmp_1 (.a(stg7_conv_1), .b(pool_max_val_1), .zctr(1'b0), .z1(c_pool_res_1), .agtb(c_pool_gt_1), .z0(), .aeqb(), .altb(), .unordered(), .status0(), .status1());

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pool_max_val_0 <= 0; pool_max_idx_0 <= 0; stg9_pool_0 <= 0; 
        pool_max_val_1 <= 0; pool_max_idx_1 <= 0; stg9_pool_1 <= 0;
        
        for(i_pool=0; i_pool<32; i_pool=i_pool+1) switch_pool_layer0[i_pool] <= 0;
        for(i_pool=0; i_pool<8;  i_pool=i_pool+1) switch_pool_layer1[i_pool] <= 0;
    end 
    else if (pipeline_ctrl[8]) begin
        pool_max_val_0 <= next_pool_m0; 
        pool_max_idx_0 <= next_pool_i0; 
        pool_max_val_1 <= next_pool_m1; 
        pool_max_idx_1 <= next_pool_i1;
        
        stg9_pool_0 <= (pipeline_layer[8] < 2) ? next_pool_m0 : stg7_conv_0;
        stg9_pool_1 <= (pipeline_layer[8] < 2) ? next_pool_m1 : stg7_conv_1;
        
        if (pipeline_layer[8] < 2 && pipeline_sub_position[8] == 3) begin
            if (pipeline_layer[8] == 0) begin 
                switch_pool_layer0[pool0_addr_0] <= next_pool_i0; 
                switch_pool_layer0[pool0_addr_1] <= next_pool_i1; 
            end else begin 
                switch_pool_layer1[pool1_addr_0] <= next_pool_i0; 
                switch_pool_layer1[pool1_addr_1] <= next_pool_i1; 
            end
        end
    end
end

//STAGE 9
wire is_tanh_func = (act_sel == 1);
wire [31:0] abs_in_0 = {1'b0, stg9_pool_0[30:0]}; 
wire [31:0] abs_in_1 = {1'b0, stg9_pool_1[30:0]};

wire [7:0]  exp_bias_0 = (abs_in_0[30:23] == 255) ? 255 : abs_in_0[30:23] + 1;
wire [7:0]  exp_bias_1 = (abs_in_1[30:23] == 255) ? 255 : abs_in_1[30:23] + 1;

wire [31:0] abs_in_x2_0 = (abs_in_0 == 0) ? 0 : {1'b0, exp_bias_0, abs_in_0[22:0]};
wire [31:0] abs_in_x2_1 = (abs_in_1 == 0) ? 0 : {1'b0, exp_bias_1, abs_in_1[22:0]};

wire [31:0] exp_op_0 = {1'b1, (is_tanh_func ? abs_in_x2_0[30:0] : abs_in_0[30:0])};
wire [31:0] exp_op_1 = {1'b1, (is_tanh_func ? abs_in_x2_1[30:0] : abs_in_1[30:0])};

reg  [31:0] stg10_exp_in_0, stg10_orig_0;
reg  [31:0] stg10_exp_in_1, stg10_orig_1;

always @(posedge clk) begin 
    if(pipeline_ctrl[9]) begin 
        stg10_exp_in_0 <= exp_op_0; 
        stg10_orig_0   <= stg9_pool_0; 
        
        stg10_exp_in_1 <= exp_op_1; 
        stg10_orig_1   <= stg9_pool_1; 
    end 
end

//Stage 10
wire [31:0] c_exp_0, c_exp_1; 
reg  [31:0] stg11_exp_0, stg11_orig_0;
reg  [31:0] stg11_exp_1, stg11_orig_1;

//DW_fp_exp
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) u_exp_0 (.a(stg10_exp_in_0), .z(c_exp_0), .status());
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, 0) u_exp_1 (.a(stg10_exp_in_1), .z(c_exp_1), .status());

always @(posedge clk) begin
    if (pipeline_ctrl[10]) begin
        stg11_exp_0  <= c_exp_0; 
        stg11_orig_0 <= stg10_orig_0;
        
        stg11_exp_1  <= c_exp_1; 
        stg11_orig_1 <= stg10_orig_1;
    end
end

// Stage 11
wire [31:0] c_denom_0, c_num_0, c_denom_1, c_num_1;

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_denom_add_0 (.a(stg11_exp_0), .b(32'h3F800000), .rnd(3'b0), .z(c_denom_0), .status());
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_denom_add_1 (.a(stg11_exp_1), .b(32'h3F800000), .rnd(3'b0), .z(c_denom_1), .status());

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_tanh_sub_0  (.a(32'h3F800000), .b(stg11_exp_0), .rnd(3'b0), .z(c_num_0),   .status());
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_tanh_sub_1  (.a(32'h3F800000), .b(stg11_exp_1), .rnd(3'b0), .z(c_num_1),   .status());

reg  [31:0] stg12_den_0, stg12_num_0_raw, stg12_orig_0, stg12_exp_0;
reg  [31:0] stg12_den_1, stg12_num_1_raw, stg12_orig_1, stg12_exp_1;

always @(posedge clk) begin
    if(pipeline_ctrl[11]) begin 
        stg12_den_0     <= c_denom_0; 
        stg12_num_0_raw <= c_num_0; 
        stg12_orig_0    <= stg11_orig_0;
        stg12_exp_0     <= stg11_exp_0;

        stg12_den_1     <= c_denom_1; 
        stg12_num_1_raw <= c_num_1; 
        stg12_orig_1    <= stg11_orig_1;
        stg12_exp_1     <= stg11_exp_1;
    end
end

// Stage 12
wire [31:0] pre_div_num_0 = is_tanh_func ? stg12_num_0_raw : (stg12_orig_0[31] ? stg12_exp_0 : 32'h3F800000);
wire [31:0] pre_div_num_1 = is_tanh_func ? stg12_num_1_raw : (stg12_orig_1[31] ? stg12_exp_1 : 32'h3F800000);

reg  [31:0] stg13_den_0, stg13_num_0, stg13_orig_0;
reg  [31:0] stg13_den_1, stg13_num_1, stg13_orig_1;

always @(posedge clk) begin
    if(pipeline_ctrl[12]) begin
        stg13_den_0  <= stg12_den_0;
        stg13_num_0  <= pre_div_num_0;
        stg13_orig_0 <= stg12_orig_0;

        stg13_den_1  <= stg12_den_1;
        stg13_num_1  <= pre_div_num_1;
        stg13_orig_1 <= stg12_orig_1;
    end
end

//Stage 13
wire [31:0] c_recip_0, c_recip_1;
reg  [31:0] stg14_recip_0, stg14_num_0, stg14_orig_0;
reg  [31:0] stg14_recip_1, stg14_num_1, stg14_orig_1;

DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) u_act_recip_0 (
    .a(stg13_den_0), .rnd(3'b0), .z(c_recip_0), .status()
);
DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) u_act_recip_1 (
    .a(stg13_den_1), .rnd(3'b0), .z(c_recip_1), .status()
);

always @(posedge clk) begin
    if (pipeline_ctrl[13]) begin
        stg14_recip_0 <= c_recip_0;
        stg14_num_0   <= stg13_num_0; 
        stg14_orig_0  <= stg13_orig_0;
        
        stg14_recip_1 <= c_recip_1;
        stg14_num_1   <= stg13_num_1; 
        stg14_orig_1  <= stg13_orig_1;
    end
end

//Stage 14
wire [31:0] c_act_mul_0, c_act_mul_1;
reg  [31:0] stg15_mul_0, stg15_orig_0;
reg  [31:0] stg15_mul_1, stg15_orig_1;

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_act_mul_0 (
    .a(stg14_num_0), .b(stg14_recip_0), .rnd(3'b0), .z(c_act_mul_0), .status()
);
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) u_act_mul_1 (
    .a(stg14_num_1), .b(stg14_recip_1), .rnd(3'b0), .z(c_act_mul_1), .status()
);

always @(posedge clk) begin
    if (pipeline_ctrl[14]) begin
        stg15_mul_0  <= c_act_mul_0;
        stg15_orig_0 <= stg14_orig_0;
        
        stg15_mul_1  <= c_act_mul_1;
        stg15_orig_1 <= stg14_orig_1;
    end
end


//Stage 15
wire [31:0] act_sig_0 = stg15_mul_0; 
wire [31:0] act_sig_1 = stg15_mul_1;

wire [7:0]  o_exp_0 = stg15_orig_0[30:23]; 
wire [7:0]  o_exp_1 = stg15_orig_1[30:23];

wire [31:0] act_tan_0  = (o_exp_0 >= 131) ? {stg15_orig_0[31], 8'd127, 23'd0} : {stg15_orig_0[31], stg15_mul_0[30:0]};
wire [31:0] act_tan_1  = (o_exp_1 >= 131) ? {stg15_orig_1[31], 8'd127, 23'd0} : {stg15_orig_1[31], stg15_mul_1[30:0]};

wire [31:0] act_relu_0 = stg15_orig_0[31] ? 0 : stg15_orig_0;
wire [31:0] act_relu_1 = stg15_orig_1[31] ? 0 : stg15_orig_1;

wire [31:0] act_lky_0  = (stg15_orig_0[31] && o_exp_0 < 3) ? 0 : (stg15_orig_0[31] ? {1'b1, o_exp_0 - 8'd3, stg15_orig_0[22:0]} : stg15_orig_0);
wire [31:0] act_lky_1  = (stg15_orig_1[31] && o_exp_1 < 3) ? 0 : (stg15_orig_1[31] ? {1'b1, o_exp_1 - 8'd3, stg15_orig_1[22:0]} : stg15_orig_1);

wire [31:0] final_act_0 = (act_sel == 0) ? act_sig_0 : (act_sel == 1) ? act_tan_0 : (act_sel == 2) ? act_relu_0 : act_lky_0;
wire [31:0] final_act_1 = (act_sel == 0) ? act_sig_1 : (act_sel == 1) ? act_tan_1 : (act_sel == 2) ? act_relu_1 : act_lky_1;

wire [6:0] wb_addr_L0_0 = {1'b0, pipeline_y[15][2:0], pipeline_x[15][2:0]}; 
wire [6:0] wb_addr_L0_1 = {1'b1, pipeline_y[15][2:0], pipeline_x[15][2:0]};

wire [4:0] wb_addr_L1_0 = {1'b0, pipeline_y[15][1:0], pipeline_x[15][1:0]}; 
wire [4:0] wb_addr_L1_1 = {1'b1, pipeline_y[15][1:0], pipeline_x[15][1:0]};

wire [3:0] wb_addr_L2_0 = {1'b0, pipeline_y[15][0],   pipeline_x[15][0]};   
wire [3:0] wb_addr_L2_1 = {1'b1, pipeline_y[15][0],   pipeline_x[15][0]};

wire [4:0] wb_addr_L3_0 = {1'b0, pipeline_y[15][1:0], pipeline_x[15][1:0]}; 
wire [4:0] wb_addr_L3_1 = {1'b1, pipeline_y[15][1:0], pipeline_x[15][1:0]};

always @(posedge clk) begin
    if (image_in_valid) begin
        feature_map_A[input_counter] <= in_data;
    end else if (state_curr == PROCESS && sys_cnt >= 7 && sys_cnt <= 38) begin
        feature_map_A[ps_wr_base]      <= ps_m0_reg;
        feature_map_A[ps_wr_base + 1]  <= ps_m1_reg;
        feature_map_A[ps_wr_base + 64] <= ps_m2_reg;
        feature_map_A[ps_wr_base + 65] <= ps_m3_reg;
    end else if (pipeline_ctrl[15]) begin
        case(pipeline_layer[15])
            0: begin 
                feature_map_B[wb_addr_L1_0] <= final_act_0; 
                feature_map_B[wb_addr_L1_1] <= final_act_1; 
            end
            1: begin 
                feature_map_A[wb_addr_L2_0] <= final_act_0; 
                feature_map_A[wb_addr_L2_1] <= final_act_1; 
            end
            2: begin 
                feature_map_B[wb_addr_L3_0] <= final_act_0; 
                feature_map_B[wb_addr_L3_1] <= final_act_1; 
            end
            3: begin 
                feature_map_A[wb_addr_L0_0] <= final_act_0; 
                feature_map_A[wb_addr_L0_1] <= final_act_1; 
            end
        endcase
    end
end

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        out_valid      <= 0; 
        out_data       <= 0; 
        output_counter <= 0; 
    end 
    else if (state_curr == OUTPUT) begin 
        out_valid      <= 1; 
        out_data       <= feature_map_A[output_counter]; 
        output_counter <= output_counter + 1; 
    end 
    else begin 
        out_valid      <= 0; 
        out_data       <= 0; 
        output_counter <= 0; 
    end
end

endmodule 


module PE_ADDR_GEN #(parameter KERNEL_INDEX = 0) (
    input  wire [3:0] coord_x, 
    input  wire [3:0] coord_y, 
    input  wire [3:0] coord_boundary,
    input  wire [2:0] layer_id_0,
    
    output wire       padding_out,
    output wire [3:0] padded_x, 
    output wire [3:0] padded_y,
    output wire [6:0] fm_a_addr_l0, 
    output wire [6:0] fm_a_addr_l1, 
    output wire [6:0] fm_b_addr_l0, 
    output wire [6:0] fm_b_addr_l1,
    output wire [7:0] w_idx_out0_in0, 
    output wire [7:0] w_idx_out0_in1,
    output wire [7:0] w_idx_out1_in0, 
    output wire [7:0] w_idx_out1_in1
);

wire signed [4:0] kernel_dx;
wire signed [4:0] kernel_dy;
wire signed [4:0] computed_x;
wire signed [4:0] computed_y;
wire signed [4:0] bound;

assign kernel_dx = (KERNEL_INDEX == 0 || KERNEL_INDEX == 3 || KERNEL_INDEX == 6) ? -5'sd1 :
                   (KERNEL_INDEX == 1 || KERNEL_INDEX == 4 || KERNEL_INDEX == 7) ?  5'sd0 : 5'sd1;

assign kernel_dy = (KERNEL_INDEX < 3) ? -5'sd1 : 
                   (KERNEL_INDEX < 6) ?  5'sd0 : 5'sd1;

assign computed_x = $signed({1'b0, coord_x}) + kernel_dx;
assign computed_y = $signed({1'b0, coord_y}) + kernel_dy;
assign bound      = $signed({1'b0, coord_boundary});

assign padding_out = (computed_x < 0) || (computed_x > bound) || (computed_y < 0) || (computed_y > bound);
                        
assign padded_x = padding_out ? ((computed_x < 0) ? 0 : ((computed_x > bound) ? coord_boundary : computed_x[3:0])) : computed_x[3:0];
assign padded_y = padding_out ? ((computed_y < 0) ? 0 : ((computed_y > bound) ? coord_boundary : computed_y[3:0])) : computed_y[3:0];

assign fm_a_addr_l0 = {1'b0, padded_y[2:0], padded_x[2:0]};
assign fm_a_addr_l1 = {3'b0, padded_y[1:0], padded_x[1:0]};

assign fm_b_addr_l0 = {5'b0, padded_y[1],   padded_x[1]};
assign fm_b_addr_l1 = {3'b0, padded_y[2:1], padded_x[2:1]};

assign w_idx_out0_in0 = layer_id_0 * 36 +  0 + KERNEL_INDEX[3:0];
assign w_idx_out0_in1 = layer_id_0 * 36 +  9 + KERNEL_INDEX[3:0];
assign w_idx_out1_in0 = layer_id_0 * 36 + 18 + KERNEL_INDEX[3:0];
assign w_idx_out1_in1 = layer_id_0 * 36 + 27 + KERNEL_INDEX[3:0];

endmodule
