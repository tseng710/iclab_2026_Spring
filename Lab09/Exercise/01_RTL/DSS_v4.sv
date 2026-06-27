//############################################################################
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//      File Name   : DSS.sv
//      Module Name : DSS
//############################################################################

`include "Usertype.sv"
import usertype::*;

// ============================================================================
// Top Module: DSS
// ============================================================================
module DSS(
    input logic clk, 
    INF.DSS_inf inf
);

    // ------------------------------------------------------------------------
    // Parameter & Enum Declarations
    // ------------------------------------------------------------------------
    typedef enum logic [3:0] {
        S_IDLE      = 4'd0,
        S_AR_0      = 4'd1,
        S_R_0       = 4'd2,
        S_AR_1      = 4'd3,
        S_R_1       = 4'd4,
        S_WAIT_IN   = 4'd5,
        S_CALC      = 4'd6,
        S_AW_W_0    = 4'd7,
        S_B_0       = 4'd8,
        S_AW_W_1    = 4'd9,
        S_B_1       = 4'd10,
        S_OUT       = 4'd11
    } state_t;

    // ------------------------------------------------------------------------
    // Variable Declarations
    // ------------------------------------------------------------------------
    state_t state, n_state;

    logic         in_ready;
    Action        req_act;
    Dessert_Type  req_type;
    Order_Mode    req_mode;
    logic [7:0]   req_data_no;
    logic [6:0]   req_hire;
    logic [3:0]   req_m;
    logic [4:0]   req_d;
    logic [59:0]  req_res_buf;

    logic [127:0] d_old;
    logic [127:0] d_new;
    logic [2:0]   warn_out;
    logic         comp_out;
    logic         skip_write;

    logic         aw_done;
    logic         w_done;
    logic         aw_fire;
    logic         w_fire;
    logic [16:0]  target_addr_0;
    logic [16:0]  target_addr_1;

    logic [2:0]   out_warn_reg;
    logic         out_comp_reg;

    // ------------------------------------------------------------------------
    // Submodule Instantiations
    // ------------------------------------------------------------------------
    DSS_INPUT_BUFFER u_in_buf (
        .clk(clk),
        .rst_n(inf.rst_n),
        .clr_buf(state == S_OUT),
        .inf(inf),
        .in_ready(in_ready),
        .req_act(req_act),
        .req_type(req_type),
        .req_mode(req_mode),
        .req_data_no(req_data_no),
        .req_hire(req_hire),
        .req_m(req_m),
        .req_d(req_d),
        .req_res_buf(req_res_buf)
    );

    DSS_ALU u_alu (
        .req_act(req_act),
        .req_type(req_type),
        .req_mode(req_mode),
        .req_m(req_m),
        .req_d(req_d),
        .req_hire(req_hire),
        .req_res_buf(req_res_buf),
        .d_old(d_old),
        .d_new(d_new),
        .warn_out(warn_out),
        .comp_out(comp_out),
        .skip_write(skip_write)
    );

    // ------------------------------------------------------------------------
    // Assignments & Combinational Logic
    // ------------------------------------------------------------------------
    assign target_addr_0 = 17'h10000 + ({9'd0, req_data_no} << 4);
    assign target_addr_1 = target_addr_0 + 17'd8;

    assign aw_fire = (inf.AW_VALID && inf.AW_READY) || aw_done;
    assign w_fire  = (inf.W_VALID && inf.W_READY)   || w_done;

    always_comb begin
        n_state = state;
        case (state)
            S_IDLE:    if (inf.data_no_valid) n_state = S_AR_0;
            S_AR_0:    if (inf.AR_READY)      n_state = S_R_0;
            S_R_0:     if (inf.R_VALID)       n_state = S_AR_1;
            S_AR_1:    if (inf.AR_READY)      n_state = S_R_1;
            S_R_1:     if (inf.R_VALID)       n_state = in_ready ? S_CALC : S_WAIT_IN;
            S_WAIT_IN: if (in_ready)          n_state = S_CALC;
            S_CALC:    if (skip_write)        n_state = S_OUT;
                       else                   n_state = S_AW_W_0;
            S_AW_W_0:  if (aw_fire && w_fire) n_state = S_B_0;
            S_B_0:     if (inf.B_VALID)       n_state = S_AW_W_1;
            S_AW_W_1:  if (aw_fire && w_fire) n_state = S_B_1;
            S_B_1:     if (inf.B_VALID)       n_state = S_OUT;
            S_OUT:                            n_state = S_IDLE;
            default:                          n_state = S_IDLE;
        endcase
    end

    // ------------------------------------------------------------------------
    // Sequential Logic: FSM & Data Buffers
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) state <= S_IDLE;
        else            state <= n_state;
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
            out_warn_reg <= 3'b000;
            out_comp_reg <= 1'b0;
        end else if (state == S_CALC) begin
            out_warn_reg <= warn_out;
            out_comp_reg <= comp_out;
        end
    end

    // ------------------------------------------------------------------------
    // Sequential Logic: AXI Read Channels
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AR_VALID <= 1'b0;
            inf.AR_ADDR  <= 17'd0;
        end else begin
            if ((state == S_IDLE && n_state == S_AR_0) || (state == S_R_0 && n_state == S_AR_1)) begin
                inf.AR_VALID <= 1'b1;
                // Bypass req_data_no for the very first cycle to prevent 1-cycle delay mismatch
                inf.AR_ADDR  <= (n_state == S_AR_0) ? (17'h10000 + ({9'd0, inf.D[7:0]} << 4)) : target_addr_1;
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

    // ------------------------------------------------------------------------
    // Sequential Logic: AXI Write Channels
    // ------------------------------------------------------------------------
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
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
        end else begin
            if ((state == S_CALC && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= (n_state == S_AW_W_0) ? target_addr_0 : target_addr_1;
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
            if ((state == S_CALC && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
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

    // ------------------------------------------------------------------------
    // Sequential Logic: Outputs
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end else if (n_state == S_OUT) begin
            inf.out_valid <= 1'b1;
            inf.warn_msg  <= Warn_Msg'((state == S_CALC) ? warn_out : out_warn_reg);
            inf.complete  <= (state == S_CALC) ? comp_out : out_comp_reg;
        end else begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end
    end

endmodule

// ============================================================================
// Submodule: DSS_INPUT_BUFFER
// ============================================================================
module DSS_INPUT_BUFFER (
    input  logic clk,
    input  logic rst_n,
    input  logic clr_buf,
    INF.DSS_inf  inf,
    output logic in_ready,
    output Action req_act,
    output Dessert_Type req_type,
    output Order_Mode req_mode,
    output logic [7:0] req_data_no,
    output logic [6:0] req_hire,
    output logic [3:0] req_m,
    output logic [4:0] req_d,
    output logic [59:0] req_res_buf
);

    logic [3:0] input_cnt;
    logic [3:0] inputs_needed;
    logic       any_valid_in;

    assign any_valid_in = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                          inf.staff_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid;

    always_comb begin
        case(req_act)
            Make_and_Sell:    inputs_needed = 4'd5;
            Restock:          inputs_needed = 4'd8;
            Hire_Staff:       inputs_needed = 4'd4;
            Pay_Day:          inputs_needed = 4'd3;
            Check_Valid_Date: inputs_needed = 4'd3;
            default:          inputs_needed = 4'd15;
        endcase
    end

    assign in_ready = (input_cnt == inputs_needed) || 
                      ((input_cnt == inputs_needed - 4'd1) && any_valid_in);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_act     <= Make_and_Sell;
            req_type    <= Cookie;
            req_mode    <= Single;
            req_data_no <= 8'd0;
            req_hire    <= 7'd0;
            req_m       <= 4'd0;
            req_d       <= 5'd0;
        end else begin
            if (inf.sel_action_valid) req_act     <= Action'(inf.D[2:0]);
            if (inf.type_valid)       req_type    <= Dessert_Type'(inf.D[2:0]);
            if (inf.mode_valid)       req_mode    <= Order_Mode'(inf.D[1:0]);
            if (inf.data_no_valid)    req_data_no <= inf.D[7:0];
            if (inf.staff_valid)      req_hire    <= inf.D[6:0];
            if (inf.date_valid) begin
                req_m <= inf.D[8:5];
                req_d <= inf.D[4:0];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_res_buf <= 60'd0;
        end else if (inf.restock_valid) begin
            req_res_buf <= {req_res_buf[47:0], inf.D[11:0]};
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            input_cnt <= 4'd0;
        end else begin
            if (clr_buf) begin
                input_cnt <= 4'd0;
            end else if (any_valid_in) begin
                input_cnt <= input_cnt + 4'd1;
            end
        end
    end

endmodule

// ============================================================================
// Submodule: DSS_ALU
// ============================================================================
module DSS_ALU (
    input  Action req_act,
    input  Dessert_Type req_type,
    input  Order_Mode req_mode,
    input  logic [3:0]  req_m,
    input  logic [4:0]  req_d,
    input  logic [6:0]  req_hire,
    input  logic [59:0] req_res_buf,
    input  logic [127:0] d_old,
    
    output logic [127:0] d_new,
    output logic [2:0]   warn_out,
    output logic         comp_out,
    output logic         skip_write
);

    const logic [5:0] SQ_LUT [0:100] = '{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 
        8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 
        18, 18, 19, 19, 20, 21, 21, 22, 23, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30, 31, 
        32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50
    };

    logic [11:0] old_f, old_b, old_m, old_s, old_fr, old_sales;
    logic [7:0]  old_mon, old_day, old_staff, old_level;
    logic [23:0] old_bal;
    logic [11:0] in_f, in_b, in_m_res, in_s, in_fr;
    logic        date_warn;

    logic [3:0]  k; 
    logic [4:0]  lvl_factor;
    logic [5:0]  lvl_sq_div_200;
    logic [7:0]  lvl_threshold;
    logic [3:0]  scale_val;

    logic [7:0]  req_f_b, req_b_b, req_m_b, req_s_b, req_fr_b;
    logic [5:0]  p_b_div10;
    logic [11:0] ms_req_f, ms_req_b, ms_req_m, ms_req_s, ms_req_fr;
    logic [10:0] ms_price; 
    logic [13:0] ms_earn;
    logic [24:0] ms_bal_tmp;
    logic [12:0] ms_sales_tmp;
    logic [12:0] rem_sales;

    logic [12:0] sum_f, sum_b, sum_m, sum_s, sum_fr;
    logic [11:0] a_f, a_b, a_m_act, a_s, a_fr;

    logic [4:0]  rc_f;
    logic [7:0]  rc_b;
    logic [5:0]  rc_m;
    logic [4:0]  rc_s;
    logic [7:0]  rc_fr;

    logic [8:0]  sum_staff;
    logic [6:0]  a_staff;
    logic [13:0] h_unit_cost;
    logic [15:0] p_unit_cost;

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;
    logic [23:0] shared_total_cost;

    assign old_f     = d_old[63:52];
    assign old_b     = d_old[51:40];
    assign old_mon   = d_old[39:32];
    assign old_m     = d_old[31:20];
    assign old_s     = d_old[19:8];
    assign old_day   = d_old[7:0];

    assign old_fr    = d_old[127:116]; 
    assign old_sales = d_old[115:104];
    assign old_staff = d_old[103:96];
    assign old_bal   = d_old[95:72];  
    assign old_level = d_old[71:64];

    assign in_f     = req_res_buf[59:48];
    assign in_b     = req_res_buf[47:36];
    assign in_m_res = req_res_buf[35:24];
    assign in_s     = req_res_buf[23:12];
    assign in_fr    = req_res_buf[11:0];

    assign date_warn  = ({4'd0, req_m} < old_mon) || (({4'd0, req_m} == old_mon) && ({3'd0, req_d} < old_day));
    assign skip_write = date_warn && (req_act != Check_Valid_Date);

    always_comb begin
        if      (old_level >= 100) k = 10;
        else if (old_level >= 90)  k = 9;
        else if (old_level >= 80)  k = 8;
        else if (old_level >= 70)  k = 7;
        else if (old_level >= 60)  k = 6;
        else if (old_level >= 50)  k = 5;
        else if (old_level >= 40)  k = 4;
        else if (old_level >= 30)  k = 3;
        else if (old_level >= 20)  k = 2;
        else if (old_level >= 10)  k = 1;
        else                       k = 0;
    end
    
    assign lvl_factor     = 5'd10 + {1'b0, k};
    assign lvl_sq_div_200 = SQ_LUT[(old_level > 100) ? 100 : old_level];
    assign lvl_threshold  = (k == 0) ? 8'd10 : ({4'd0, k} * 8'd10);
    assign scale_val      = (req_mode == Party_Pack) ? 4'd8 : (req_mode == Family_Set) ? 4'd4 : 4'd1;

    always_comb begin
        req_f_b = 8'd0; req_b_b = 8'd0; req_m_b = 8'd0;
        req_s_b = 8'd0; req_fr_b = 8'd0; p_b_div10 = 6'd0;
        case(req_type)
            Cookie:     begin req_f_b=8'd100; req_b_b=8'd50;  req_s_b=8'd30;  p_b_div10=6'd12; end
            Bread:      begin req_f_b=8'd200; req_b_b=8'd20;  req_m_b=8'd50;  req_s_b=8'd10;  p_b_div10=6'd10; end
            Fruit_Cake: begin req_f_b=8'd150; req_b_b=8'd80;  req_m_b=8'd40;  req_s_b=8'd60;  req_fr_b=8'd100; p_b_div10=6'd40; end
            Pudding:    begin req_m_b=8'd150; req_s_b=8'd50;  req_fr_b=8'd20; p_b_div10=6'd18; end
            Macaron:    begin req_f_b=8'd40;  req_b_b=8'd30;  req_s_b=8'd120; p_b_div10=6'd25; end
            Pancake:    begin req_f_b=8'd120; req_b_b=8'd30;  req_m_b=8'd80;  req_s_b=8'd20;  req_fr_b=8'd40; p_b_div10=6'd20; end
            Brownie:    begin req_f_b=8'd80;  req_b_b=8'd100; req_s_b=8'd100; p_b_div10=6'd28; end
            Scone:      begin req_f_b=8'd150; req_b_b=8'd60;  req_m_b=8'd30;  req_s_b=8'd20;  req_fr_b=8'd10; p_b_div10=6'd16; end
        endcase
    end

    assign ms_req_f  = (req_mode == Party_Pack) ? {1'b0, req_f_b, 3'd0}  : (req_mode == Family_Set) ? {2'b0, req_f_b, 2'd0}  : {4'b0, req_f_b};
    assign ms_req_b  = (req_mode == Party_Pack) ? {1'b0, req_b_b, 3'd0}  : (req_mode == Family_Set) ? {2'b0, req_b_b, 2'd0}  : {4'b0, req_b_b};
    assign ms_req_m  = (req_mode == Party_Pack) ? {1'b0, req_m_b, 3'd0}  : (req_mode == Family_Set) ? {2'b0, req_m_b, 2'd0}  : {4'b0, req_m_b};
    assign ms_req_s  = (req_mode == Party_Pack) ? {1'b0, req_s_b, 3'd0}  : (req_mode == Family_Set) ? {2'b0, req_s_b, 2'd0}  : {4'b0, req_s_b};
    assign ms_req_fr = (req_mode == Party_Pack) ? {1'b0, req_fr_b, 3'd0} : (req_mode == Family_Set) ? {2'b0, req_fr_b, 2'd0} : {4'b0, req_fr_b};

    assign ms_price     = ({6'd0, p_b_div10} * {6'd0, lvl_factor}) + {5'd0, lvl_sq_div_200};
    assign ms_earn      = (req_mode == Party_Pack) ? {ms_price[10:0], 3'd0} : (req_mode == Family_Set) ? {1'b0, ms_price[10:0], 2'd0} : {3'b0, ms_price[10:0]};
    assign ms_bal_tmp   = {1'b0, old_bal} + {11'd0, ms_earn};
    assign ms_sales_tmp = {1'b0, old_sales} + {9'd0, scale_val};

    assign sum_f  = {1'b0, old_f} + {1'b0, in_f};
    assign sum_b  = {1'b0, old_b} + {1'b0, in_b};
    assign sum_m  = {1'b0, old_m} + {1'b0, in_m_res};
    assign sum_s  = {1'b0, old_s} + {1'b0, in_s};
    assign sum_fr = {1'b0, old_fr}+ {1'b0, in_fr};

    assign a_f     = sum_f[12]  ? ~old_f  : in_f;
    assign a_b     = sum_b[12]  ? ~old_b  : in_b;
    assign a_m_act = sum_m[12]  ? ~old_m  : in_m_res;
    assign a_s     = sum_s[12]  ? ~old_s  : in_s;
    assign a_fr    = sum_fr[12] ? ~old_fr : in_fr;

    assign rc_f  = 5'd15 + {1'b0, k} + {2'b0, k[3:1]};
    assign rc_b  = ({3'd0, lvl_factor} << 2) + ({3'd0, lvl_factor} << 1); 
    assign rc_m  = 6'd25 + {1'b0, k, 1'b0} + {3'b0, k[3:1]};
    assign rc_s  = {3'd0, lvl_factor};
    assign rc_fr = ({3'd0, lvl_factor} << 3);

    assign sum_staff   = {1'b0, old_staff} + {2'd0, req_hire};
    assign a_staff     = (sum_staff > 9'd100) ? (7'd100 - old_staff[6:0]) : req_hire;
    assign h_unit_cost = 14'd2000 + ({8'd0, old_level} * 14'd100) + ({10'd0, k} * 14'd200);
    assign p_unit_cost = 16'd20000 + ({8'd0, old_level} * 16'd200) + ({12'd0, k} * 16'd1000);

    always_comb begin
        n_f       = old_f;
        n_b       = old_b; 
        n_m       = old_m;
        n_s       = old_s; 
        n_fr      = old_fr;
        n_sales   = old_sales; 
        n_staff   = old_staff; 
        n_level   = old_level;
        n_bal     = old_bal;
        n_month   = {4'd0, req_m};
        n_day     = {3'd0, req_d};
        rem_sales = 13'd0;
        warn_out  = 3'b000;
        comp_out  = 1'b0;
        shared_total_cost = 24'd0;

        if (date_warn) begin
            warn_out = 3'b001;
            if (req_act != Check_Valid_Date) begin
                n_month = old_mon;
                n_day   = old_day;
            end else begin
                // complete must be 0 for warning
            end
        end 
        else begin
            case(req_act)
                Make_and_Sell: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (old_f < ms_req_f || old_b < ms_req_b || old_m < ms_req_m || old_s < ms_req_s || old_fr < ms_req_fr) begin
                        warn_out = 3'b011;
                    end else begin
                        comp_out = 1'b1;
                        n_f  = old_f - ms_req_f;
                        n_b  = old_b - ms_req_b;
                        n_m  = old_m - ms_req_m;
                        n_s  = old_s - ms_req_s;
                        n_fr = old_fr - ms_req_fr;
                        
                        n_bal = (ms_bal_tmp > 25'd16777215) ? 24'd16777215 : ms_bal_tmp[23:0];

                        if (old_level < 8'd100 && ms_sales_tmp >= {5'd0, lvl_threshold}) begin
                            n_level = old_level + 8'd1;
                            rem_sales = ms_sales_tmp - {5'd0, lvl_threshold};
                            n_sales = (rem_sales > 13'd4095) ? 12'd4095 : rem_sales[11:0];
                        end else begin
                            n_sales = (ms_sales_tmp > 13'd4095) ? 12'd4095 : ms_sales_tmp[11:0];
                        end
                    end
                end

                Restock: begin
                    shared_total_cost = {14'd0, a_f} * {19'd0, rc_f} + 
                                        {14'd0, a_b} * {16'd0, rc_b} + 
                                        {14'd0, a_m_act} * {18'd0, rc_m} + 
                                        {14'd0, a_s} * {19'd0, rc_s} + 
                                        {14'd0, a_fr} * {16'd0, rc_fr};

                    if (old_bal < shared_total_cost) begin
                        warn_out = 3'b100;
                    end else if (sum_f[12] || sum_b[12] || sum_m[12] || sum_s[12] || sum_fr[12]) begin
                        warn_out = 3'b101;
                        n_f  = old_f + a_f;
                        n_b  = old_b + a_b;
                        n_m  = old_m + a_m_act;
                        n_s  = old_s + a_s;
                        n_fr = old_fr + a_fr;
                        n_bal = old_bal - shared_total_cost;
                    end else begin
                        comp_out = 1'b1;
                        n_f  = old_f + in_f;
                        n_b  = old_b + in_b;
                        n_m  = old_m + in_m_res;
                        n_s  = old_s + in_s;
                        n_fr = old_fr + in_fr;
                        n_bal = old_bal - shared_total_cost;
                    end
                end

                Hire_Staff: begin
                    shared_total_cost = {10'd0, a_staff} * {10'd0, h_unit_cost};

                    if (old_bal < shared_total_cost) begin
                        warn_out = 3'b100;
                    end else if (sum_staff > 9'd100) begin
                        warn_out = 3'b110;
                        n_staff = old_staff + {1'b0, a_staff};
                        n_bal = old_bal - shared_total_cost;
                    end else begin
                        comp_out = 1'b1;
                        n_staff = old_staff + {1'b0, req_hire};
                        n_bal = old_bal - shared_total_cost;
                    end
                end

                Pay_Day: begin
                    shared_total_cost = {16'd0, old_staff} * {8'd0, p_unit_cost}; 

                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (old_bal < shared_total_cost) begin
                        warn_out = 3'b100;
                        n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                        n_staff = (old_staff <= 8'd1) ? 8'd1 : {1'b0, old_staff[7:1]};
                        n_sales = 12'd0;
                    end else begin
                        comp_out = 1'b1;
                        n_bal = old_bal - shared_total_cost;
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