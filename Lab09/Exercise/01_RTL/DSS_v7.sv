`include "Usertype.sv"

// ============================================================================
// Module 1: DSS (Top Module)
// Description: Manages AXI4-Lite FSM and submodules. (Perfect Pipeline Balance)
// ============================================================================
module DSS(input clk, INF.DSS_inf inf);
    import usertype::*;

    typedef enum logic [3:0] {
        S_IDLE     = 4'd0,
        S_AR_0     = 4'd1,
        S_R_0      = 4'd2,
        S_AR_1     = 4'd3,
        S_R_1      = 4'd4,
        S_WAIT_IN  = 4'd5,
        S_CALC_LUT = 4'd6,
        S_CALC_ALU = 4'd7,
        S_CALC_WB  = 4'd8,
        S_AW_W_0   = 4'd9,
        S_B_0      = 4'd10,
        S_AW_W_1   = 4'd11,
        S_B_1      = 4'd12
    } state_t;

    state_t state, n_state;

    Action       in_act;
    Dessert_Type in_type;
    Order_Mode   in_mode;
    logic [7:0]  in_data_no;
    logic [6:0]  in_hire;     
    logic [3:0]  in_m;
    logic [4:0]  in_d;
    logic [59:0] in_res_buf;  
    logic        inputs_ready;

    logic [127:0] d_old;
    logic [127:0] d_new;
    logic [2:0]   dp_warn;
    logic         dp_comp;
    logic         req_w0;
    logic         req_w1;
    logic         early_term;
    logic         is_out_cycle;

    logic         aw_done;
    logic         w_done;
    logic         aw_fire;
    logic         w_fire;
    logic [7:0]   current_data_no;
    logic [16:0]  base_addr;
    logic [16:0]  base_addr_offset;

    assign current_data_no  = inf.data_no_valid ? inf.D[7:0] : in_data_no;
    assign base_addr        = {1'b1, 4'b0000, current_data_no, 4'b0000};
    assign base_addr_offset = {1'b1, 4'b0000, current_data_no, 4'b1000};

    assign aw_fire = (inf.AW_VALID && inf.AW_READY) || aw_done;
    assign w_fire  = (inf.W_VALID  && inf.W_READY)  || w_done;

    assign is_out_cycle = (state == S_CALC_LUT && early_term) ||
                          (state == S_B_0  && inf.B_VALID && !req_w1) ||
                          (state == S_B_1  && inf.B_VALID);

    DSS_INPUT_RECEIVER u_input_recv (
        .clk          (clk),
        .rst_n        (inf.rst_n),
        .inf          (inf),
        .is_out_cycle (is_out_cycle),
        .act_reg      (in_act),
        .type_reg     (in_type),
        .mode_reg     (in_mode),
        .in_data_no   (in_data_no),
        .in_hire      (in_hire),
        .in_m         (in_m),
        .in_d         (in_d),
        .in_res_buf   (in_res_buf),
        .inputs_ready (inputs_ready)
    );

    DSS_MATH_CORE u_math_core (
        .clk        (clk),
        .rst_n      (inf.rst_n),
        .state      (state),
        .act        (in_act),
        .type_reg   (in_type),
        .mode_reg   (in_mode),
        .in_m       (in_m),
        .in_d       (in_d),
        .in_hire    (in_hire),
        .in_res_buf (in_res_buf),
        .d_old      (d_old),
        .d_new      (d_new),
        .warn_out   (dp_warn),
        .comp_out   (dp_comp),
        .req_w0     (req_w0),
        .req_w1     (req_w1),
        .early_term (early_term)
    );

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) state <= S_IDLE;
        else            state <= n_state;
    end

    always_comb begin
        n_state = state;
        case (state)
            S_IDLE:     if (inf.data_no_valid) n_state = S_AR_0;
            S_AR_0:     if (inf.AR_READY)      n_state = S_R_0;
            S_R_0:      if (inf.R_VALID)       n_state = S_AR_1;
            S_AR_1:     if (inf.AR_READY)      n_state = S_R_1;
            S_R_1:      if (inf.R_VALID)       n_state = inputs_ready ? S_CALC_LUT : S_WAIT_IN;
            S_WAIT_IN:  if (inputs_ready)      n_state = S_CALC_LUT;
            S_CALC_LUT: n_state = early_term ? S_IDLE : S_CALC_ALU; 
            S_CALC_ALU: n_state = S_CALC_WB;
            S_CALC_WB: begin
                if (req_w0)      n_state = S_AW_W_0; 
                else if (req_w1) n_state = S_AW_W_1; 
                else             n_state = S_IDLE; 
            end
            S_AW_W_0:   if (aw_fire && w_fire) n_state = S_B_0;
            S_B_0: begin
                if (inf.B_VALID) begin
                    if (req_w1)  n_state = S_AW_W_1;
                    else         n_state = S_IDLE; 
                end
            end
            S_AW_W_1:   if (aw_fire && w_fire) n_state = S_B_1;
            S_B_1:      if (inf.B_VALID)       n_state = S_IDLE; 
            default:                           n_state = S_IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            d_old <= 128'd0;
        end else begin
            if (state == S_R_0 && inf.R_VALID) d_old[63:0]   <= inf.R_DATA;
            if (state == S_R_1 && inf.R_VALID) d_old[127:64] <= inf.R_DATA;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AR_VALID <= 1'b0;
            inf.AR_ADDR  <= 17'd0;
            inf.R_READY  <= 1'b0;
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
            inf.W_VALID  <= 1'b0;
            inf.W_DATA   <= 64'd0;
            inf.B_READY  <= 1'b0;
            aw_done      <= 1'b0;
            w_done       <= 1'b0;
        end else begin
            if ((state == S_IDLE && n_state == S_AR_0) || (state == S_R_0 && n_state == S_AR_1)) begin
                inf.AR_VALID <= 1'b1;
                inf.AR_ADDR  <= (n_state == S_AR_0) ? base_addr : base_addr_offset;
            end else if (inf.AR_VALID && inf.AR_READY) begin
                inf.AR_VALID <= 1'b0;
            end

            if ((state == S_AR_0 && n_state == S_R_0) || (state == S_AR_1 && n_state == S_R_1)) begin
                inf.R_READY <= 1'b1;
            end else if (inf.R_VALID && inf.R_READY) begin
                inf.R_READY <= 1'b0;
            end

            if (state == S_AW_W_0 || state == S_AW_W_1) begin
                if (inf.AW_VALID && inf.AW_READY) aw_done <= 1'b1;
                if (inf.W_VALID  && inf.W_READY)  w_done  <= 1'b1;
            end else begin
                aw_done <= 1'b0;
                w_done  <= 1'b0;
            end

            if ((state == S_CALC_WB && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= (n_state == S_AW_W_0) ? base_addr : base_addr_offset;
            end else if (inf.AW_VALID && inf.AW_READY) begin
                inf.AW_VALID <= 1'b0;
            end

            if ((state == S_CALC_WB && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.W_VALID <= 1'b1;
                inf.W_DATA  <= (n_state == S_AW_W_0) ? d_new[63:0] : d_new[127:64];
            end else if (inf.W_VALID && inf.W_READY) begin
                inf.W_VALID <= 1'b0;
            end

            if ((state == S_AW_W_0 && n_state == S_B_0) || (state == S_AW_W_1 && n_state == S_B_1)) begin
                inf.B_READY <= 1'b1;
            end else if (inf.B_VALID && inf.B_READY) begin
                inf.B_READY <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end else if (is_out_cycle) begin
            inf.out_valid <= 1'b1;
            inf.warn_msg  <= Warn_Msg'(dp_warn);
            inf.complete  <= dp_comp;
        end else begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end
    end
endmodule

// ============================================================================
// Module 2: DSS_INPUT_RECEIVER
// ============================================================================
module DSS_INPUT_RECEIVER (
    input  logic        clk,
    input  logic        rst_n,
    INF.DSS_inf         inf,
    input  logic        is_out_cycle,
    output usertype::Action       act_reg,
    output usertype::Dessert_Type type_reg,
    output usertype::Order_Mode   mode_reg,
    output logic [7:0]            in_data_no,
    output logic [6:0]            in_hire,
    output logic [3:0]            in_m,
    output logic [4:0]            in_d,
    output logic [59:0]           in_res_buf,
    output logic                  inputs_ready
);
    import usertype::*;

    logic [3:0] input_cnt;
    logic [3:0] inputs_needed;
    logic       any_valid_in;

    assign any_valid_in = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                          inf.staff_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid;

    assign inputs_ready = (input_cnt == inputs_needed) || 
                          ((input_cnt == inputs_needed - 4'd1) && any_valid_in);

    always_comb begin
        case(act_reg)
            Make_and_Sell:    inputs_needed = 4'd5;
            Restock:          inputs_needed = 4'd8;
            Hire_Staff:       inputs_needed = 4'd4;
            Pay_Day:          inputs_needed = 4'd3;
            Check_Valid_Date: inputs_needed = 4'd3;
            default:          inputs_needed = 4'd15;
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_reg    <= Make_and_Sell;
            type_reg   <= Cookie;
            mode_reg   <= Single;
            in_data_no <= 8'd0;
            in_hire    <= 7'd0;
            in_m       <= 4'd0;
            in_d       <= 5'd0;
        end else begin
            if (inf.sel_action_valid) act_reg    <= Action'(inf.D[2:0]);
            if (inf.type_valid)       type_reg   <= Dessert_Type'(inf.D[2:0]);
            if (inf.mode_valid)       mode_reg   <= Order_Mode'(inf.D[1:0]);
            if (inf.data_no_valid)    in_data_no <= inf.D[7:0];
            if (inf.staff_valid)      in_hire    <= inf.D[6:0];
            if (inf.date_valid) begin
                in_m <= inf.D[8:5];
                in_d <= inf.D[4:0];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in_res_buf <= 60'd0;
        end else if (inf.restock_valid && act_reg == Restock) begin 
            in_res_buf <= {in_res_buf[47:0], inf.D[11:0]};
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_cnt <= 4'd0;
        end else begin
            if (is_out_cycle) begin
                input_cnt <= 4'd0;
            end else if (any_valid_in) begin
                input_cnt <= input_cnt + 4'd1;
            end
        end
    end
endmodule

// ============================================================================
// Module 3: DSS_MATH_CORE (Perfect Rebalanced Pipeline)
// ============================================================================
module DSS_MATH_CORE (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [3:0]            state,
    input  usertype::Action       act,
    input  usertype::Dessert_Type type_reg,
    input  usertype::Order_Mode   mode_reg,
    input  logic [3:0]            in_m,
    input  logic [4:0]            in_d,
    input  logic [6:0]            in_hire,
    input  logic [59:0]           in_res_buf,
    input  logic [127:0]          d_old,
    
    output logic [127:0]          d_new,
    output logic [2:0]            warn_out,
    output logic                  comp_out,
    output logic                  req_w0,
    output logic                  req_w1,
    output logic                  early_term
);
    import usertype::*;

    logic [11:0] old_f, old_b, old_m, old_s, old_fr, old_sales;
    logic [7:0]  old_mon, old_day, old_staff, old_level;
    logic [23:0] old_bal;

    assign {old_fr, old_sales, old_staff, old_bal, old_level} = d_old[127:64];
    assign {old_f, old_b, old_mon, old_m, old_s, old_day}     = d_old[63:0];

    // LUT Wires
    logic [7:0]  lut_threshold;
    logic [4:0]  lut_rc_f; logic [7:0] lut_rc_b; logic [5:0] lut_rc_m; logic [4:0] lut_rc_s; logic [7:0] lut_rc_fr;
    logic [11:0] lut_req_f, lut_req_b, lut_req_m, lut_req_s, lut_req_fr;
    logic [3:0]  lut_scale_val;
    logic [5:0]  lut_pb_div10;
    logic [4:0]  lut_lvl_factor;
    logic [5:0]  lut_sq_div_200;
    logic [14:0] lut_lvl_x100;
    logic [11:0] lut_k_x200;
    logic [13:0] lut_k_x1000;

    DSS_LUT_CONFIG u_lut (
        .level      (old_level),
        .type_reg   (type_reg),
        .mode_reg   (mode_reg),
        .threshold  (lut_threshold),
        .rc_f       (lut_rc_f), .rc_b (lut_rc_b), .rc_m (lut_rc_m), .rc_s (lut_rc_s), .rc_fr (lut_rc_fr),
        .req_f      (lut_req_f), .req_b (lut_req_b), .req_m (lut_req_m), .req_s (lut_req_s), .req_fr (lut_req_fr),
        .scale      (lut_scale_val), 
        .pb_div10   (lut_pb_div10),
        .lvl_factor (lut_lvl_factor),
        .sq_div_200 (lut_sq_div_200),
        .lvl_x100   (lut_lvl_x100),
        .k_x200     (lut_k_x200),
        .k_x1000    (lut_k_x1000)
    );

    logic date_warn;
    assign date_warn  = {in_m, in_d} < {old_mon[3:0], old_day[4:0]};
    assign early_term = date_warn && (act != Check_Valid_Date);
    assign req_w0     = 1'b1; 
    assign req_w1     = (act != Check_Valid_Date);

    // ------------------------------------------------------------------------
    // STAGE 1: Extract Base Values & Calculate Immediate Saturation
    // ------------------------------------------------------------------------
    logic [11:0] in_f, in_b, in_res_m, in_s, in_fr;
    assign {in_f, in_b, in_res_m, in_s, in_fr} = in_res_buf;

    logic [11:0] p1_a_f, p1_a_b, p1_a_m, p1_a_s, p1_a_fr;
    logic p1_of_f, p1_of_b, p1_of_m, p1_of_s, p1_of_fr;
    logic [6:0] p1_a_staff;
    logic p1_of_staff;

    logic [12:0] sum_f_c, sum_b_c, sum_m_c, sum_s_c, sum_fr_c;
    logic [8:0] sum_staff_c;

    assign sum_f_c  = {1'b0, old_f} + {1'b0, in_f};
    assign sum_b_c  = {1'b0, old_b} + {1'b0, in_b};
    assign sum_m_c  = {1'b0, old_m} + {1'b0, in_res_m};
    assign sum_s_c  = {1'b0, old_s} + {1'b0, in_s};
    assign sum_fr_c = {1'b0, old_fr}+ {1'b0, in_fr};
    assign sum_staff_c = {1'b0, old_staff} + {2'd0, in_hire};

    logic [11:0] p1_req_f, p1_req_b, p1_req_m, p1_req_s, p1_req_fr;
    logic [4:0]  p1_rc_f; logic [7:0] p1_rc_b; logic [5:0] p1_rc_m; logic [4:0] p1_rc_s; logic [7:0] p1_rc_fr;
    logic [14:0] p1_lvl_x100; logic [11:0] p1_k_x200; logic [13:0] p1_k_x1000;
    logic [7:0]  p1_lvl_threshold; logic [3:0] p1_scale_val;
    logic [5:0]  p1_pb_div10; logic [4:0] p1_lvl_factor; logic [5:0] p1_sq_div_200;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p1_a_f <= 12'd0; p1_a_b <= 12'd0; p1_a_m <= 12'd0; p1_a_s <= 12'd0; p1_a_fr <= 12'd0;
            p1_of_f <= 1'b0; p1_of_b <= 1'b0; p1_of_m <= 1'b0; p1_of_s <= 1'b0; p1_of_fr <= 1'b0;
            p1_a_staff <= 7'd0; p1_of_staff <= 1'b0;
            p1_req_f <= 12'd0; p1_req_b <= 12'd0; p1_req_m <= 12'd0; p1_req_s <= 12'd0; p1_req_fr <= 12'd0;
            p1_rc_f <= 5'd0; p1_rc_b <= 8'd0; p1_rc_m <= 6'd0; p1_rc_s <= 5'd0; p1_rc_fr <= 8'd0;
            p1_lvl_x100 <= 15'd0; p1_k_x200 <= 12'd0; p1_k_x1000 <= 14'd0;
            p1_lvl_threshold <= 8'd0; p1_scale_val <= 4'd0;
            p1_pb_div10 <= 6'd0; p1_lvl_factor <= 5'd0; p1_sq_div_200 <= 6'd0;
        end else if (state == 4'd6) begin
            p1_a_f <= sum_f_c[12] ? ~old_f : in_f;
            p1_a_b <= sum_b_c[12] ? ~old_b : in_b;
            p1_a_m <= sum_m_c[12] ? ~old_m : in_res_m;
            p1_a_s <= sum_s_c[12] ? ~old_s : in_s;
            p1_a_fr<= sum_fr_c[12]? ~old_fr: in_fr;
            p1_of_f <= sum_f_c[12]; p1_of_b <= sum_b_c[12]; p1_of_m <= sum_m_c[12]; p1_of_s <= sum_s_c[12]; p1_of_fr <= sum_fr_c[12];
            
            p1_a_staff <= (sum_staff_c > 9'd100) ? (7'd100 - old_staff[6:0]) : in_hire;
            p1_of_staff <= (sum_staff_c > 9'd100);

            p1_req_f <= lut_req_f; p1_req_b <= lut_req_b; p1_req_m <= lut_req_m; p1_req_s <= lut_req_s; p1_req_fr <= lut_req_fr;
            p1_rc_f <= lut_rc_f; p1_rc_b <= lut_rc_b; p1_rc_m <= lut_rc_m; p1_rc_s <= lut_rc_s; p1_rc_fr <= lut_rc_fr;
            
            p1_lvl_x100 <= lut_lvl_x100; p1_k_x200 <= lut_k_x200; p1_k_x1000 <= lut_k_x1000;
            p1_lvl_threshold <= lut_threshold; p1_scale_val <= lut_scale_val;
            p1_pb_div10 <= lut_pb_div10; p1_lvl_factor <= lut_lvl_factor; p1_sq_div_200 <= lut_sq_div_200;
        end
    end

    // ------------------------------------------------------------------------
    // STAGE 2: Core Arithmetic Logic Unit (Adders & Multipliers)
    // ------------------------------------------------------------------------
    logic [16:0] cost_f_c; logic [19:0] cost_b_c; logic [17:0] cost_m_c; logic [16:0] cost_s_c; logic [19:0] cost_fr_c;
    logic [13:0] h_cost_c; logic [15:0] p_cost_c;
    logic [7:0] staff_op1_c; logic [15:0] staff_op2_c;
    logic [10:0] ms_price_c; logic [13:0] ms_earn_c;
    logic [12:0] sub_f_c, sub_b_c, sub_m_c, sub_s_c, sub_fr_c;
    logic [12:0] sales_add_c, sales_rem_c;

    assign cost_f_c  = p1_a_f * p1_rc_f;
    assign cost_b_c  = p1_a_b * p1_rc_b;
    assign cost_m_c  = p1_a_m * p1_rc_m;
    assign cost_s_c  = p1_a_s * p1_rc_s;
    assign cost_fr_c = p1_a_fr * p1_rc_fr;

    assign h_cost_c = 14'd2000 + p1_lvl_x100 + {2'd0, p1_k_x200};
    assign p_cost_c = 16'd20000 + ({1'b0, p1_lvl_x100} << 1) + {2'd0, p1_k_x1000};
    
    assign staff_op1_c = (act == Hire_Staff) ? {1'b0, p1_a_staff} : old_staff;
    assign staff_op2_c = (act == Hire_Staff) ? {2'd0, h_cost_c} : p_cost_c;

    assign ms_price_c = ({5'd0, p1_pb_div10} * {6'd0, p1_lvl_factor}) + {5'd0, p1_sq_div_200};
    always_comb begin
        if (mode_reg == Party_Pack)      ms_earn_c = {ms_price_c[10:0], 3'd0};
        else if (mode_reg == Family_Set) ms_earn_c = {1'b0, ms_price_c[10:0], 2'd0};
        else                             ms_earn_c = {3'd0, ms_price_c[10:0]};
    end

    assign sub_f_c  = {1'b0, old_f} - {1'b0, p1_req_f};
    assign sub_b_c  = {1'b0, old_b} - {1'b0, p1_req_b};
    assign sub_m_c  = {1'b0, old_m} - {1'b0, p1_req_m};
    assign sub_s_c  = {1'b0, old_s} - {1'b0, p1_req_s};
    assign sub_fr_c = {1'b0, old_fr}- {1'b0, p1_req_fr};

    assign sales_add_c = {1'b0, old_sales} + {9'd0, p1_scale_val};
    assign sales_rem_c = sales_add_c - {5'd0, p1_lvl_threshold};

    logic [16:0] p2_cost_f, p2_cost_s; logic [19:0] p2_cost_b, p2_cost_fr; logic [17:0] p2_cost_m;
    logic [23:0] p2_staff_cost; logic [13:0] p2_ms_earn;
    logic [12:0] p2_sub_f, p2_sub_b, p2_sub_m, p2_sub_s, p2_sub_fr;
    logic [12:0] p2_sales_add, p2_sales_rem;
    
    // Piped from Stage 1
    logic [11:0] p2_a_f, p2_a_b, p2_a_m, p2_a_s, p2_a_fr;
    logic p2_of_f, p2_of_b, p2_of_m, p2_of_s, p2_of_fr;
    logic [6:0] p2_a_staff; logic p2_of_staff;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p2_cost_f <= 17'd0; p2_cost_b <= 20'd0; p2_cost_m <= 18'd0; p2_cost_s <= 17'd0; p2_cost_fr <= 20'd0;
            p2_staff_cost <= 24'd0; p2_ms_earn <= 14'd0;
            p2_sub_f <= 13'd0; p2_sub_b <= 13'd0; p2_sub_m <= 13'd0; p2_sub_s <= 13'd0; p2_sub_fr <= 13'd0;
            p2_sales_add <= 13'd0; p2_sales_rem <= 13'd0;
            p2_a_f <= 12'd0; p2_a_b <= 12'd0; p2_a_m <= 12'd0; p2_a_s <= 12'd0; p2_a_fr <= 12'd0;
            p2_of_f <= 1'b0; p2_of_b <= 1'b0; p2_of_m <= 1'b0; p2_of_s <= 1'b0; p2_of_fr <= 1'b0;
            p2_a_staff <= 7'd0; p2_of_staff <= 1'b0;
        end else if (state == 4'd7) begin
            p2_cost_f <= cost_f_c; p2_cost_b <= cost_b_c; p2_cost_m <= cost_m_c; p2_cost_s <= cost_s_c; p2_cost_fr <= cost_fr_c;
            p2_staff_cost <= staff_op1_c * staff_op2_c;
            p2_ms_earn <= ms_earn_c;
            p2_sub_f <= sub_f_c; p2_sub_b <= sub_b_c; p2_sub_m <= sub_m_c; p2_sub_s <= sub_s_c; p2_sub_fr <= sub_fr_c;
            p2_sales_add <= sales_add_c; p2_sales_rem <= sales_rem_c;
            
            p2_a_f <= p1_a_f; p2_a_b <= p1_a_b; p2_a_m <= p1_a_m; p2_a_s <= p1_a_s; p2_a_fr <= p1_a_fr;
            p2_of_f <= p1_of_f; p2_of_b <= p1_of_b; p2_of_m <= p1_of_m; p2_of_s <= p1_of_s; p2_of_fr <= p1_of_fr;
            p2_a_staff <= p1_a_staff; p2_of_staff <= p1_of_staff;
        end
    end

    // ------------------------------------------------------------------------
    // STAGE 3: Final Write Back and Warning Checks
    // ------------------------------------------------------------------------
    logic [21:0] r_total_cost;
    logic [23:0] unified_cost;
    logic [24:0] bal_sub_res, bal_ms_res;
    
    assign r_total_cost = {5'd0, p2_cost_f} + {2'd0, p2_cost_b} + {4'd0, p2_cost_m} + {5'd0, p2_cost_s} + {2'd0, p2_cost_fr};
    
    always_comb begin
        if (act == Restock) unified_cost = {2'd0, r_total_cost};
        else                unified_cost = p2_staff_cost;
    end
    
    assign bal_sub_res = {1'b0, old_bal} - {1'b0, unified_cost};
    assign bal_ms_res  = {1'b0, old_bal} + {11'd0, p2_ms_earn};

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;

    always_comb begin
        n_f = old_f; n_b = old_b; n_m = old_m; n_s = old_s; n_fr = old_fr;
        n_sales = old_sales; n_staff = old_staff; n_level = old_level; n_bal = old_bal;
        n_month = {4'd0, in_m}; n_day = {3'd0, in_d}; 
        warn_out = 3'b000;
        comp_out = 1'b0;

        if (date_warn && act == Check_Valid_Date) begin
            warn_out = 3'b001;
        end else if (date_warn) begin
            warn_out = 3'b001;
            n_month  = old_mon; 
            n_day    = old_day;
        end else begin
            case(act)
                Make_and_Sell: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (p2_sub_f[12] | p2_sub_b[12] | p2_sub_m[12] | p2_sub_s[12] | p2_sub_fr[12]) begin
                        warn_out = 3'b011;
                    end else begin
                        comp_out = 1'b1;
                        n_f = p2_sub_f[11:0]; n_b = p2_sub_b[11:0]; n_m = p2_sub_m[11:0];
                        n_s = p2_sub_s[11:0]; n_fr = p2_sub_fr[11:0];
                        n_bal = bal_ms_res[24] ? 24'hFFFFFF : bal_ms_res[23:0];
                        
                        if (old_level < 8'd100 && !p2_sales_rem[12]) begin
                            n_level = old_level + 8'd1;
                            n_sales = p2_sales_rem[11:0];
                        end else begin
                            n_sales = p2_sales_add[12] ? 12'hFFF : p2_sales_add[11:0];
                        end
                    end
                end
                Restock: begin
                    if (bal_sub_res[24]) begin 
                        warn_out = 3'b100;
                    end else if (p2_of_f | p2_of_b | p2_of_m | p2_of_s | p2_of_fr) begin
                        warn_out = 3'b101;
                        n_f = p2_of_f ? 12'hFFF : (old_f + p2_a_f);
                        n_b = p2_of_b ? 12'hFFF : (old_b + p2_a_b);
                        n_m = p2_of_m ? 12'hFFF : (old_m + p2_a_m);
                        n_s = p2_of_s ? 12'hFFF : (old_s + p2_a_s);
                        n_fr = p2_of_fr? 12'hFFF : (old_fr + p2_a_fr);
                        n_bal = bal_sub_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_f = old_f + p2_a_f; n_b = old_b + p2_a_b; n_m = old_m + p2_a_m; 
                        n_s = old_s + p2_a_s; n_fr = old_fr + p2_a_fr;
                        n_bal = bal_sub_res[23:0];
                    end
                end
                Hire_Staff: begin
                    if (bal_sub_res[24]) begin
                        warn_out = 3'b100;
                    end else if (p2_of_staff) begin
                        warn_out = 3'b110;
                        n_staff = 8'd100;
                        n_bal   = bal_sub_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_staff = old_staff + p2_a_staff;
                        n_bal   = bal_sub_res[23:0];
                    end
                end
                Pay_Day: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (bal_sub_res[24]) begin
                        warn_out = 3'b100;
                        n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                        n_staff = (old_staff == 8'd1) ? 8'd1 : {1'b0, old_staff[7:1]};
                        n_sales = 12'd0; 
                    end else begin
                        comp_out = 1'b1;
                        n_bal = bal_sub_res[23:0];
                    end
                end
                Check_Valid_Date: begin
                    comp_out = 1'b1;
                end
                default: ;
            endcase
        end
    end

    assign d_new = {n_fr, n_sales, n_staff, n_bal, n_level, n_f, n_b, n_month, n_m, n_s, n_day};
endmodule

// ============================================================================
// Module 4: DSS_LUT_CONFIG
// ============================================================================
module DSS_LUT_CONFIG (
    input  logic [7:0]  level,
    input  usertype::Dessert_Type type_reg,
    input  usertype::Order_Mode   mode_reg,

    output logic [7:0]  threshold,
    output logic [4:0]  rc_f, logic [7:0]  rc_b, logic [5:0]  rc_m, logic [4:0]  rc_s, logic [7:0]  rc_fr,
    output logic [11:0] req_f, logic [11:0] req_b, logic [11:0] req_m, logic [11:0] req_s, logic [11:0] req_fr,
    output logic [3:0]  scale,
    output logic [5:0]  pb_div10,
    output logic [4:0]  lvl_factor,
    output logic [5:0]  sq_div_200,
    output logic [14:0] lvl_x100,
    output logic [11:0] k_x200,
    output logic [13:0] k_x1000
);
    import usertype::*;

    const logic [5:0] SQ_LUT [0:100] = '{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 
        8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 
        18, 18, 19, 19, 20, 21, 21, 22, 23, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30, 31, 
        32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50
    };

    const logic [3:0] K_LUT [0:100] = '{
        0,0,0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1,1,1, 2,2,2,2,2,2,2,2,2,2,
        3,3,3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4,4,4, 5,5,5,5,5,5,5,5,5,5,
        6,6,6,6,6,6,6,6,6,6, 7,7,7,7,7,7,7,7,7,7, 8,8,8,8,8,8,8,8,8,8,
        9,9,9,9,9,9,9,9,9,9, 10
    };

    logic [3:0] k;
    assign k = K_LUT[(level > 100) ? 100 : level];
    assign lvl_factor = 5'd10 + {1'b0, k};
    assign sq_div_200 = SQ_LUT[(level > 100) ? 100 : level];
    assign threshold  = (k == 0) ? 8'd10 : ({4'd0, k} * 8'd10);

    assign rc_f  = 5'd15 + {1'b0, k} + {2'b0, k[3:1]};
    assign rc_b  = ({3'd0, lvl_factor} << 2) + ({3'd0, lvl_factor} << 1);
    assign rc_m  = 6'd25 + {1'b0, k, 1'b0} + {3'b0, k[3:1]};
    assign rc_s  = {3'd0, lvl_factor};
    assign rc_fr = {3'd0, lvl_factor} << 3; 

    assign lvl_x100 = level * 7'd100; 
    assign k_x200   = k * 8'd200;     
    assign k_x1000  = k * 10'd1000;

    logic [7:0] r_f, r_b, r_m, r_s, r_fr;
    assign scale = (mode_reg == Party_Pack) ? 4'd8 : (mode_reg == Family_Set) ? 4'd4 : 4'd1;

    always_comb begin
        r_f = 8'd0; r_b = 8'd0; r_m = 8'd0; r_s = 8'd0; r_fr = 8'd0; pb_div10 = 6'd0;
        case(type_reg)
            Cookie:     begin r_f=8'd100; r_b=8'd50;  r_s=8'd30;  pb_div10=6'd12; end
            Bread:      begin r_f=8'd200; r_b=8'd20;  r_m=8'd50;  r_s=8'd10;  pb_div10=6'd10; end
            Fruit_Cake: begin r_f=8'd150; r_b=8'd80;  r_m=8'd40;  r_s=8'd60;  r_fr=8'd100; pb_div10=6'd40; end
            Pudding:    begin r_m=8'd150; r_s=8'd50;  r_fr=8'd20; pb_div10=6'd18; end
            Macaron:    begin r_f=8'd40;  r_b=8'd30;  r_s=8'd120; pb_div10=6'd25; end
            Pancake:    begin r_f=8'd120; r_b=8'd30;  r_m=8'd80;  r_s=8'd20;  r_fr=8'd40; pb_div10=6'd20; end
            Brownie:    begin r_f=8'd80;  r_b=8'd100; r_s=8'd100; pb_div10=6'd28; end
            Scone:      begin r_f=8'd150; r_b=8'd60;  r_m=8'd30;  r_s=8'd20;  r_fr=8'd10; pb_div10=6'd16; end
        endcase
    end

    always_comb begin
        if (mode_reg == Party_Pack) begin
            req_f  = {1'b0, r_f,  3'd0}; req_b  = {1'b0, r_b,  3'd0};
            req_m  = {1'b0, r_m,  3'd0}; req_s  = {1'b0, r_s,  3'd0};
            req_fr = {1'b0, r_fr, 3'd0};
        end else if (mode_reg == Family_Set) begin
            req_f  = {2'b0, r_f,  2'd0}; req_b  = {2'b0, r_b,  2'd0};
            req_m  = {2'b0, r_m,  2'd0}; req_s  = {2'b0, r_s,  2'd0};
            req_fr = {2'b0, r_fr, 2'd0};
        end else begin
            req_f  = {4'b0, r_f}; req_b  = {4'b0, r_b};
            req_m  = {4'b0, r_m}; req_s  = {4'b0, r_s};
            req_fr = {4'b0, r_fr};
        end
    end
endmodule