`include "Usertype.sv"

// ============================================================================
// Module 1: DSS (Top Module)
// Description: Manages AXI4-Lite FSM and Pipeline routing.
// ============================================================================
module DSS (
    input clk, 
    INF.DSS_inf inf
);
    import usertype::*;

    typedef enum logic [3:0] {
        S_IDLE     = 4'd0,
        S_AR_0     = 4'd1,
        S_R_0      = 4'd2,
        S_AR_1     = 4'd3,
        S_R_1      = 4'd4,
        S_WAIT_IN  = 4'd5,
        S_CALC_1   = 4'd6, 
        S_CALC_2   = 4'd7, 
        S_CALC_3   = 4'd8, 
        S_AW_W_0   = 4'd9,
        S_B_0      = 4'd10,
        S_AW_W_1   = 4'd11,
        S_B_1      = 4'd12
    } state_t;

    state_t state;
    state_t n_state;

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

    assign is_out_cycle = (state == S_CALC_3 && early_term) ||
                          (state == S_B_0    && inf.B_VALID && !req_w1) ||
                          (state == S_B_1    && inf.B_VALID);

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

    DSS_MATH_PIPELINE u_pipeline (
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
            S_IDLE:    if (inf.data_no_valid) n_state = S_AR_0;
            S_AR_0:    if (inf.AR_READY)      n_state = S_R_0;
            S_R_0:     if (inf.R_VALID)       n_state = S_AR_1;
            S_AR_1:    if (inf.AR_READY)      n_state = S_R_1;
            S_R_1:     if (inf.R_VALID)       n_state = inputs_ready ? S_CALC_1 : S_WAIT_IN;
            S_WAIT_IN: if (inputs_ready)      n_state = S_CALC_1;
            
            S_CALC_1:  n_state = S_CALC_2; 
            S_CALC_2:  n_state = S_CALC_3; 
            S_CALC_3: begin
                if (early_term)      n_state = S_IDLE;
                else if (req_w0)     n_state = S_AW_W_0; 
                else if (req_w1)     n_state = S_AW_W_1;
                else                 n_state = S_IDLE;
            end
            
            S_AW_W_0:  if (aw_fire && w_fire) n_state = S_B_0;
            S_B_0: begin
                if (inf.B_VALID) begin
                    if (req_w1)      n_state = S_AW_W_1;
                    else             n_state = S_IDLE;
                end
            end
            S_AW_W_1:  if (aw_fire && w_fire) n_state = S_B_1;
            S_B_1:     if (inf.B_VALID)       n_state = S_IDLE;
            default:                          n_state = S_IDLE;
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
            aw_done <= 1'b0;
            w_done  <= 1'b0;
        end else begin
            if (state == S_AW_W_0 || state == S_AW_W_1) begin
                if (inf.AW_VALID && inf.AW_READY) aw_done <= 1'b1;
                if (inf.W_VALID  && inf.W_READY)  w_done  <= 1'b1;
            end else begin
                aw_done <= 1'b0;
                w_done  <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AR_VALID <= 1'b0;
            inf.AR_ADDR  <= 17'd0;
        end else begin
            if ((state == S_IDLE && n_state == S_AR_0) || (state == S_R_0 && n_state == S_AR_1)) begin
                inf.AR_VALID <= 1'b1;
                inf.AR_ADDR  <= (n_state == S_AR_0) ? base_addr : base_addr_offset;
            end else if (inf.AR_VALID && inf.AR_READY) begin
                inf.AR_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.R_READY <= 1'b0;
        end else begin
            if ((state == S_AR_0 && n_state == S_R_0) || (state == S_AR_1 && n_state == S_R_1)) begin
                inf.R_READY <= 1'b1;
            end else if (inf.R_VALID && inf.R_READY) begin
                inf.R_READY <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
        end else begin
            if ((state == S_CALC_3 && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= (n_state == S_AW_W_0) ? base_addr : base_addr_offset;
            end else if (inf.AW_VALID && inf.AW_READY) begin
                inf.AW_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.W_VALID <= 1'b0;
            inf.W_DATA  <= 64'd0;
        end else begin
            if ((state == S_CALC_3 && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.W_VALID <= 1'b1;
                inf.W_DATA  <= (n_state == S_AW_W_0) ? d_new[63:0] : d_new[127:64];
            end else if (inf.W_VALID && inf.W_READY) begin
                inf.W_VALID <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.B_READY <= 1'b0;
        end else begin
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
    input  logic                  clk,
    input  logic                  rst_n,
    INF.DSS_inf                   inf,
    input  logic                  is_out_cycle,
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
// Module 3: DSS_MATH_PIPELINE (3-Stage Data Path)
// ============================================================================
module DSS_MATH_PIPELINE (
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

    logic [4:0]  rc_f;
    logic [7:0]  rc_b; 
    logic [5:0]  rc_m; 
    logic [4:0]  rc_s; 
    logic [7:0]  rc_fr;
    logic [13:0] h_unit_cost;
    logic [15:0] p_unit_cost;
    logic [11:0] req_f, req_b, req_m, req_s, req_fr;
    logic [3:0]  scale_val;
    logic [13:0] ms_earn;
    logic [7:0]  lvl_threshold;

    DSS_LUT_CONFIG u_lut (
        .level      (old_level),
        .type_reg   (type_reg),
        .mode_reg   (mode_reg),
        .threshold  (lvl_threshold),
        .rc_f       (rc_f), .rc_b (rc_b), .rc_m (rc_m), .rc_s (rc_s), .rc_fr (rc_fr),
        .h_cost     (h_unit_cost), .p_cost (p_unit_cost),
        .req_f      (req_f), .req_b (req_b), .req_m (req_m), .req_s (req_s), .req_fr (req_fr),
        .scale      (scale_val), .ms_earn(ms_earn)
    );

    logic [11:0] in_f, in_b, in_res_m, in_s, in_fr;
    assign {in_f, in_b, in_res_m, in_s, in_fr} = in_res_buf;

    logic        date_warn;
    assign date_warn = {in_m, in_d} < {old_mon[3:0], old_day[4:0]};

    // Shared ALU for Add/Sub (Massive Area Saving)
    logic [12:0] res_f, res_b, res_m, res_s, res_fr;
    logic [11:0] op_f, op_b, op_m, op_s, op_fr;

    assign op_f  = (act == Make_and_Sell) ? req_f  : in_f;
    assign op_b  = (act == Make_and_Sell) ? req_b  : in_b;
    assign op_m  = (act == Make_and_Sell) ? req_m  : in_res_m;
    assign op_s  = (act == Make_and_Sell) ? req_s  : in_s;
    assign op_fr = (act == Make_and_Sell) ? req_fr : in_fr;

    assign res_f  = (act == Make_and_Sell) ? ({1'b0, old_f}  - {1'b0, op_f})  : ({1'b0, old_f}  + {1'b0, op_f});
    assign res_b  = (act == Make_and_Sell) ? ({1'b0, old_b}  - {1'b0, op_b})  : ({1'b0, old_b}  + {1'b0, op_b});
    assign res_m  = (act == Make_and_Sell) ? ({1'b0, old_m}  - {1'b0, op_m})  : ({1'b0, old_m}  + {1'b0, op_m});
    assign res_s  = (act == Make_and_Sell) ? ({1'b0, old_s}  - {1'b0, op_s})  : ({1'b0, old_s}  + {1'b0, op_s});
    assign res_fr = (act == Make_and_Sell) ? ({1'b0, old_fr} - {1'b0, op_fr}) : ({1'b0, old_fr} + {1'b0, op_fr});

    logic [11:0] a_f, a_b, a_m, a_s, a_fr;
    assign a_f  = (res_f[12]  && act != Make_and_Sell) ? ~old_f  : in_f;
    assign a_b  = (res_b[12]  && act != Make_and_Sell) ? ~old_b  : in_b;
    assign a_m  = (res_m[12]  && act != Make_and_Sell) ? ~old_m  : in_res_m;
    assign a_s  = (res_s[12]  && act != Make_and_Sell) ? ~old_s  : in_s;
    assign a_fr = (res_fr[12] && act != Make_and_Sell) ? ~old_fr : in_fr;

    logic [8:0]  res_staff;
    logic [6:0]  a_staff;
    assign res_staff = {1'b0, old_staff} + {2'd0, in_hire};
    assign a_staff   = (res_staff > 9'd100) ? (7'd100 - old_staff[6:0]) : in_hire;

    logic [12:0] sales_add, sales_rem;
    assign sales_add = {1'b0, old_sales} + {9'd0, scale_val};
    assign sales_rem = sales_add - {5'd0, lvl_threshold};

    // ========================================================================
    // Pipeline Stage 1 Registers (ALU & LUT Capture)
    // ========================================================================
    logic [11:0] p1_a_f, p1_a_b, p1_a_m, p1_a_s, p1_a_fr;
    logic [4:0]  p1_rc_f; logic [7:0] p1_rc_b; logic [5:0] p1_rc_m; logic [4:0] p1_rc_s; logic [7:0] p1_rc_fr;
    logic [12:0] p1_res_f, p1_res_b, p1_res_m, p1_res_s, p1_res_fr;
    logic [13:0] p1_ms_earn;
    logic [7:0]  p1_staff_op1;
    logic [15:0] p1_staff_op2;
    logic [8:0]  p1_res_staff;
    logic [12:0] p1_sales_add, p1_sales_rem;
    logic        p1_date_warn;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p1_a_f <= 12'd0; p1_a_b <= 12'd0; p1_a_m <= 12'd0; p1_a_s <= 12'd0; p1_a_fr <= 12'd0;
            p1_rc_f <= 5'd0; p1_rc_b <= 8'd0; p1_rc_m <= 6'd0; p1_rc_s <= 5'd0; p1_rc_fr <= 8'd0;
            p1_res_f <= 13'd0; p1_res_b <= 13'd0; p1_res_m <= 13'd0; p1_res_s <= 13'd0; p1_res_fr <= 13'd0;
            p1_ms_earn <= 14'd0;
            p1_staff_op1 <= 8'd0; p1_staff_op2 <= 16'd0; p1_res_staff <= 9'd0;
            p1_sales_add <= 13'd0; p1_sales_rem <= 13'd0;
            p1_date_warn <= 1'b0;
        end else if (state == 4'd6) begin 
            p1_a_f <= a_f; p1_a_b <= a_b; p1_a_m <= a_m; p1_a_s <= a_s; p1_a_fr <= a_fr;
            p1_rc_f <= rc_f; p1_rc_b <= rc_b; p1_rc_m <= rc_m; p1_rc_s <= rc_s; p1_rc_fr <= rc_fr;
            p1_res_f <= res_f; p1_res_b <= res_b; p1_res_m <= res_m; p1_res_s <= res_s; p1_res_fr <= res_fr;
            p1_ms_earn <= ms_earn;
            p1_staff_op1 <= (act == Hire_Staff) ? {1'b0, a_staff} : old_staff;
            p1_staff_op2 <= (act == Hire_Staff) ? {2'd0, h_unit_cost} : p_unit_cost;
            p1_res_staff <= res_staff;
            p1_sales_add <= sales_add;
            p1_sales_rem <= sales_rem;
            p1_date_warn <= date_warn;
        end
    end

    // ========================================================================
    // Pipeline Stage 2 Registers (Multiplier Engine)
    // ========================================================================
    logic [20:0] p2_cost_fb;
    logic [18:0] p2_cost_ms;
    logic [19:0] p2_cost_fr;
    logic [23:0] p2_cost_staff;
    
    logic [12:0] p2_res_f, p2_res_b, p2_res_m, p2_res_s, p2_res_fr;
    logic [13:0] p2_ms_earn;
    logic [8:0]  p2_res_staff;
    logic [12:0] p2_sales_add, p2_sales_rem;
    logic        p2_date_warn;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p2_cost_fb <= 21'd0; p2_cost_ms <= 19'd0; p2_cost_fr <= 20'd0;
            p2_cost_staff <= 23'd0;
            p2_res_f <= 13'd0; p2_res_b <= 13'd0; p2_res_m <= 13'd0; p2_res_s <= 13'd0; p2_res_fr <= 13'd0;
            p2_ms_earn <= 14'd0; p2_res_staff <= 9'd0;
            p2_sales_add <= 13'd0; p2_sales_rem <= 13'd0;
            p2_date_warn <= 1'b0;
        end else if (state == 4'd7) begin
            p2_cost_fb <= ({5'd0, p1_a_f} * p1_rc_f) + ({1'd0, p1_a_b} * p1_rc_b);
            p2_cost_ms <= ({1'd0, p1_a_m} * p1_rc_m) + ({2'd0, p1_a_s} * p1_rc_s);
            p2_cost_fr <= (p1_a_fr * p1_rc_fr);
            p2_cost_staff <= p1_staff_op1 * p1_staff_op2;
            
            p2_res_f <= p1_res_f; p2_res_b <= p1_res_b; p2_res_m <= p1_res_m; p2_res_s <= p1_res_s; p2_res_fr <= p1_res_fr;
            p2_ms_earn <= p1_ms_earn; p2_res_staff <= p1_res_staff;
            p2_sales_add <= p1_sales_add; p2_sales_rem <= p1_sales_rem;
            p2_date_warn <= p1_date_warn;
        end
    end

    // ========================================================================
    // Combinational Stage 3 (Adder Tree, Balance, Warning Flags)
    // ========================================================================
    logic [21:0] total_cost;
    logic [23:0] unified_cost;
    logic [23:0] bal_alu_op2;
    logic [24:0] bal_alu_res;
    logic        bal_underflow, bal_overflow;
    logic        stock_err, staff_err;

    assign total_cost   = {1'b0, p2_cost_fb} + {3'd0, p2_cost_ms} + {2'd0, p2_cost_fr};
    assign unified_cost = (act == Restock) ? {2'd0, total_cost} : p2_cost_staff;
    assign bal_alu_op2  = (act == Make_and_Sell) ? {10'd0, p2_ms_earn} : unified_cost;
    assign bal_alu_res  = (act == Make_and_Sell) ? ({1'b0, old_bal} + {1'b0, bal_alu_op2}) : ({1'b0, old_bal} - {1'b0, bal_alu_op2});
    
    assign bal_underflow = (act != Make_and_Sell) && bal_alu_res[24];
    assign bal_overflow  = (act == Make_and_Sell) && bal_alu_res[24];

    assign stock_err = p2_res_f[12] | p2_res_b[12] | p2_res_m[12] | p2_res_s[12] | p2_res_fr[12];
    assign staff_err = (p2_res_staff > 9'd100);

    assign req_w0 = 1'b1;
    assign req_w1 = (act != Check_Valid_Date);
    assign early_term = p2_date_warn && (act != Check_Valid_Date);

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;

    always_comb begin
        n_f = old_f; n_b = old_b; n_m = old_m; n_s = old_s; n_fr = old_fr;
        n_sales = old_sales; n_staff = old_staff; n_level = old_level; n_bal = old_bal;
        n_month = {4'd0, in_m}; n_day = {3'd0, in_d}; 
        warn_out = 3'b000;
        comp_out = 1'b0;

        if (p2_date_warn && act == Check_Valid_Date) begin
            warn_out = 3'b001;
        end else if (p2_date_warn) begin
            warn_out = 3'b001;
            n_month  = old_mon; 
            n_day    = old_day;
        end else begin
            case(act)
                Make_and_Sell: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (stock_err) begin
                        warn_out = 3'b011;
                    end else begin
                        comp_out = 1'b1;
                        n_f = p2_res_f[11:0]; n_b = p2_res_b[11:0]; n_m = p2_res_m[11:0];
                        n_s = p2_res_s[11:0]; n_fr = p2_res_fr[11:0];
                        n_bal = bal_overflow ? 24'hFFFFFF : bal_alu_res[23:0];
                        
                        if (old_level < 8'd100 && !p2_sales_rem[12]) begin
                            n_level = old_level + 8'd1;
                            n_sales = p2_sales_rem[11:0];
                        end else begin
                            n_sales = p2_sales_add[12] ? 12'hFFF : p2_sales_add[11:0];
                        end
                    end
                end
                Restock: begin
                    if (bal_underflow) begin
                        warn_out = 3'b100;
                    end else if (stock_err) begin
                        warn_out = 3'b101;
                        n_f = p2_res_f[12] ? 12'hFFF : p2_res_f[11:0]; 
                        n_b = p2_res_b[12] ? 12'hFFF : p2_res_b[11:0]; 
                        n_m = p2_res_m[12] ? 12'hFFF : p2_res_m[11:0]; 
                        n_s = p2_res_s[12] ? 12'hFFF : p2_res_s[11:0]; 
                        n_fr = p2_res_fr[12] ? 12'hFFF : p2_res_fr[11:0];
                        n_bal = bal_alu_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_f = p2_res_f[11:0]; n_b = p2_res_b[11:0]; n_m = p2_res_m[11:0]; 
                        n_s = p2_res_s[11:0]; n_fr = p2_res_fr[11:0];
                        n_bal = bal_alu_res[23:0];
                    end
                end
                Hire_Staff: begin
                    if (bal_underflow) begin
                        warn_out = 3'b100;
                    end else if (staff_err) begin
                        warn_out = 3'b110;
                        n_staff = 8'd100;
                        n_bal   = bal_alu_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_staff = p2_res_staff[7:0];
                        n_bal   = bal_alu_res[23:0];
                    end
                end
                Pay_Day: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (bal_underflow) begin
                        warn_out = 3'b100;
                        n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                        n_staff = (old_staff == 8'd1) ? 8'd1 : {1'b0, old_staff[7:1]};
                        n_sales = 12'd0; 
                    end else begin
                        comp_out = 1'b1;
                        n_bal = bal_alu_res[23:0];
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
    input  logic [7:0]            level,
    input  usertype::Dessert_Type type_reg,
    input  usertype::Order_Mode   mode_reg,

    output logic [7:0]            threshold,
    output logic [4:0]            rc_f,
    output logic [7:0]            rc_b,
    output logic [5:0]            rc_m,
    output logic [4:0]            rc_s,
    output logic [7:0]            rc_fr,
    output logic [13:0]           h_cost,
    output logic [15:0]           p_cost,
    output logic [11:0]           req_f,
    output logic [11:0]           req_b,
    output logic [11:0]           req_m,
    output logic [11:0]           req_s,
    output logic [11:0]           req_fr,
    output logic [3:0]            scale,
    output logic [13:0]           ms_earn
);
    import usertype::*;

    logic [3:0] k;
    logic [4:0] lvl_factor;
    logic [5:0] sq_div_200;

    const logic [5:0] SQ_LUT [0:100] = '{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 
        8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 
        18, 18, 19, 19, 20, 21, 21, 22, 23, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30, 31, 
        32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50
    };

    always_comb begin
        if      (level >= 100) k = 10;
        else if (level >= 90)  k = 9;
        else if (level >= 80)  k = 8;
        else if (level >= 70)  k = 7;
        else if (level >= 60)  k = 6;
        else if (level >= 50)  k = 5;
        else if (level >= 40)  k = 4;
        else if (level >= 30)  k = 3;
        else if (level >= 20)  k = 2;
        else if (level >= 10)  k = 1;
        else                   k = 0;
    end

    assign lvl_factor = 5'd10 + {1'b0, k};
    assign sq_div_200 = SQ_LUT[(level > 100) ? 100 : level];
    assign threshold  = (k == 0) ? 8'd10 : ({4'd0, k} * 8'd10);
    
    assign rc_f  = 5'd15 + {1'b0, k} + {2'b0, k[3:1]};
    assign rc_b  = ({3'd0, lvl_factor} << 2) + ({3'd0, lvl_factor} << 1);
    assign rc_m  = 6'd25 + {1'b0, k, 1'b0} + {3'b0, k[3:1]};
    assign rc_s  = {3'd0, lvl_factor};
    assign rc_fr = {3'd0, lvl_factor} << 3; 

    logic [14:0] lvl_x_100;
    logic [11:0] k_x_200;
    assign lvl_x_100 = (level << 6) + (level << 5) + (level << 2); 
    assign k_x_200   = (k << 7) + (k << 6) + (k << 3);             

    assign h_cost = 14'd2000 + lvl_x_100 + {3'd0, k_x_200};
    assign p_cost = 16'd20000 + ({1'b0, lvl_x_100} << 1) + ({4'd0, k_x_200} << 2) + {4'd0, k_x_200};

    logic [7:0] r_f, r_b, r_m, r_s, r_fr;
    logic [5:0] pb_div10;
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

    logic [10:0] ms_price; 
    assign ms_price = (pb_div10 * lvl_factor) + sq_div_200;
    
    always_comb begin
        if (mode_reg == Party_Pack)      ms_earn = {ms_price[10:0], 3'd0};
        else if (mode_reg == Family_Set) ms_earn = {1'b0, ms_price[10:0], 2'd0};
        else                             ms_earn = {3'd0, ms_price[10:0]};
    end

    always_comb begin
        if (mode_reg == Party_Pack) begin
            req_f = {1'b0, r_f, 3'd0}; req_b = {1'b0, r_b, 3'd0}; req_m = {1'b0, r_m, 3'd0}; req_s = {1'b0, r_s, 3'd0}; req_fr = {1'b0, r_fr, 3'd0};
        end else if (mode_reg == Family_Set) begin
            req_f = {2'b0, r_f, 2'd0}; req_b = {2'b0, r_b, 2'd0}; req_m = {2'b0, r_m, 2'd0}; req_s = {2'b0, r_s, 2'd0}; req_fr = {2'b0, r_fr, 2'd0};
        end else begin
            req_f = {4'b0, r_f}; req_b = {4'b0, r_b}; req_m = {4'b0, r_m}; req_s = {4'b0, r_s}; req_fr = {4'b0, r_fr};
        end
    end
endmodule