//############################################################################
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//      File Name   : DSS.sv
//      Module Name : DSS
//############################################################################

`include "Usertype.sv"

module DSS(input clk, INF.DSS_inf inf);
    import usertype::*;

    // ============================================================================
    // FSM State Encoding
    // ============================================================================
    typedef enum logic [3:0] {
        S_IDLE    = 4'd0,
        S_AR_0    = 4'd1,
        S_R_0     = 4'd2,
        S_AR_1    = 4'd3,
        S_R_1     = 4'd4,
        S_WAIT_IN = 4'd5,
        S_CALC    = 4'd6,
        S_AW_W_0  = 4'd7,
        S_B_0     = 4'd8,
        S_AW_W_1  = 4'd9,
        S_B_1     = 4'd10,
        S_OUT     = 4'd11
    } state_t;

    state_t state, n_state;

    // ============================================================================
    // Datapath & Control Registers
    // ============================================================================
    Action       act_reg;
    Dessert_Type type_reg;
    Order_Mode   mode_reg;
    
    logic [7:0]  in_data_no;
    logic [4:0]  in_hire;
    logic [3:0]  in_m;
    logic [4:0]  in_d;
    logic [54:0] in_res_buf;

    logic [3:0]  input_cnt;
    logic [3:0]  inputs_needed;
    logic        any_valid_in;
    logic        inputs_ready;

    logic [127:0] d_old;
    logic [127:0] datapath_d_new;
    logic [2:0]   datapath_warn;
    logic         datapath_comp;
    logic         early_term;

    logic [2:0]   warn_reg;
    logic         comp_reg;

    logic aw_done;
    logic w_done;
    logic aw_fire;
    logic w_fire;

    // ============================================================================
    // Combinational Assignments for Control
    // ============================================================================
    assign any_valid_in = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                          inf.staff_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid;

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

    assign inputs_ready = (input_cnt == inputs_needed) || ((input_cnt == inputs_needed - 4'd1) && any_valid_in);

    // ============================================================================
    // Input Registers 
    // ============================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            act_reg    <= Make_and_Sell; 
            type_reg   <= Cookie;
            mode_reg   <= Single;
            in_data_no <= 8'd0;
            in_hire    <= 5'd0;
            in_m       <= 4'd0;
            in_d       <= 5'd0;
        end else begin
            if (inf.sel_action_valid) act_reg    <= Action'(inf.D[2:0]);
            if (inf.type_valid)       type_reg   <= Dessert_Type'(inf.D[2:0]);
            if (inf.mode_valid)       mode_reg   <= Order_Mode'(inf.D[1:0]);
            if (inf.data_no_valid)    in_data_no <= inf.D[7:0];
            if (inf.staff_valid)      in_hire    <= inf.D[4:0];
            if (inf.date_valid) begin
                in_m <= inf.D[8:5];
                in_d <= inf.D[4:0];
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            in_res_buf <= 55'd0;
        end else if (inf.restock_valid) begin
            in_res_buf <= {in_res_buf[43:0], inf.D[10:0]};
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            input_cnt <= 4'd0;
        end else begin
            if (state == S_OUT) begin
                input_cnt <= 4'd0;
            end else if (any_valid_in) begin
                input_cnt <= input_cnt + 4'd1;
            end
        end
    end

    // ============================================================================
    // AXI Data Reception
    // ============================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            d_old <= 128'd0;
        end else begin
            if (state == S_R_0 && inf.R_VALID) d_old[63:0]   <= inf.R_DATA;
            if (state == S_R_1 && inf.R_VALID) d_old[127:64] <= inf.R_DATA;
        end
    end

    // ============================================================================
    // FSM Control
    // ============================================================================
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) state <= S_IDLE;
        else            state <= n_state;
    end

    assign aw_fire = (inf.AW_VALID && inf.AW_READY) || aw_done;
    assign w_fire  = (inf.W_VALID && inf.W_READY) || w_done;

    always_comb begin
        n_state = state;
        case (state)
            S_IDLE:    if (inf.data_no_valid) n_state = S_AR_0;
            S_AR_0:    if (inf.AR_READY)      n_state = S_R_0;
            S_R_0:     if (inf.R_VALID)       n_state = S_AR_1;
            S_AR_1:    if (inf.AR_READY)      n_state = S_R_1;
            S_R_1:     if (inf.R_VALID)       n_state = inputs_ready ? S_CALC : S_WAIT_IN;
            S_WAIT_IN: if (inputs_ready)      n_state = S_CALC;
            S_CALC:    if (early_term)        n_state = S_OUT;
                       else                   n_state = S_AW_W_0;
            S_AW_W_0:  if (aw_fire && w_fire) n_state = S_B_0;
            S_B_0:     if (inf.B_VALID)       n_state = S_AW_W_1;
            S_AW_W_1:  if (aw_fire && w_fire) n_state = S_B_1;
            S_B_1:     if (inf.B_VALID)       n_state = S_OUT;
            S_OUT:                            n_state = S_IDLE;
            default:                          n_state = S_IDLE;
        endcase
    end

    // ============================================================================
    // AXI-4 Lite Control Signals
    // ============================================================================
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
            inf.R_READY  <= 1'b0;
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
            inf.W_VALID  <= 1'b0;
            inf.W_DATA   <= 64'd0;
            inf.B_READY  <= 1'b0;
        end else begin
            if ((state == S_IDLE && n_state == S_AR_0) || (state == S_R_0 && n_state == S_AR_1)) begin
                inf.AR_VALID <= 1'b1;
                inf.AR_ADDR  <= (n_state == S_AR_0) ? (17'h10000 + {9'd0, inf.D[7:0]} * 17'd16) :
                                                      (17'h10000 + {9'd0, in_data_no} * 17'd16 + 17'd8);
            end else if (inf.AR_VALID && inf.AR_READY) begin
                inf.AR_VALID <= 1'b0;
            end

            if ((state == S_AR_0 && n_state == S_R_0) || (state == S_AR_1 && n_state == S_R_1)) begin
                inf.R_READY <= 1'b1;
            end else if (inf.R_VALID && inf.R_READY) begin
                inf.R_READY <= 1'b0;
            end

            if ((state == S_CALC && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= (n_state == S_AW_W_0) ? (17'h10000 + {9'd0, in_data_no} * 17'd16) :
                                                        (17'h10000 + {9'd0, in_data_no} * 17'd16 + 17'd8);
            end else if (inf.AW_VALID && inf.AW_READY) begin
                inf.AW_VALID <= 1'b0;
            end

            if ((state == S_CALC && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.W_VALID <= 1'b1;
                inf.W_DATA  <= (n_state == S_AW_W_0) ? datapath_d_new[63:0] : datapath_d_new[127:64];
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

    DSS_DATAPATH u_datapath (
        .act(act_reg),
        .type_reg(type_reg),
        .mode_reg(mode_reg),
        .in_m(in_m),
        .in_d(in_d),
        .in_hire(in_hire),
        .in_res_buf(in_res_buf),
        .d_old(d_old),
        .d_new(datapath_d_new),
        .warn_out(datapath_warn),
        .comp_out(datapath_comp),
        .early_term(early_term)
    );

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            warn_reg <= 3'b000;
            comp_reg <= 1'b0;
        end else if (state == S_CALC) begin
            warn_reg <= datapath_warn;
            comp_reg <= datapath_comp;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end else if (n_state == S_OUT) begin
            inf.out_valid <= 1'b1;
            inf.warn_msg  <= Warn_Msg'((state == S_CALC) ? datapath_warn : warn_reg);
            inf.complete  <= (state == S_CALC) ? datapath_comp : comp_reg;
        end else begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end
    end

endmodule

// ============================================================================
// Module: DSS_DATAPATH (Golden-Matched + Ultra PPA logic)
// ============================================================================
module DSS_DATAPATH (
    input  usertype::Action       act,
    input  usertype::Dessert_Type type_reg,
    input  usertype::Order_Mode   mode_reg,
    input  logic [3:0]            in_m,
    input  logic [4:0]            in_d,
    input  logic [4:0]            in_hire,
    input  logic [54:0]           in_res_buf,
    input  logic [127:0]          d_old,
    
    output logic [127:0]          d_new,
    output logic [2:0]            warn_out,
    output logic                  comp_out,
    output logic                  early_term
);
    import usertype::*;

    logic [11:0] old_f, old_b, old_m, old_s, old_fr, old_sales;
    logic [7:0]  old_mon, old_day, old_staff, old_level;
    logic [23:0] old_bal;

    logic        date_warn;
    logic [3:0]  k; 
    logic [4:0]  lvl_factor;
    logic [13:0] lvl_sq;
    logic [6:0]  lvl_sq_div_200;

    logic [3:0]  scale_val;
    logic [7:0]  req_f_b, req_b_b, req_m_b, req_s_b, req_fr_b;
    logic [5:0]  p_b_div10;

    logic [11:0] ms_req_f, ms_req_b, ms_req_m, ms_req_s, ms_req_fr;
    logic [10:0] ms_price; 
    logic [13:0] ms_earn;
    logic [24:0] ms_bal_tmp;
    logic [12:0] ms_sales_tmp;
    logic [12:0] rem_sales;

    logic [10:0] in_f, in_b, in_res_m, in_s, in_fr;

    logic [12:0] sum_f, sum_b, sum_m, sum_s, sum_fr;
    logic [11:0] a_f, a_b, a_m, a_s, a_fr;

    logic [4:0]  rc_f;
    logic [6:0]  rc_b;
    logic [5:0]  rc_m;
    logic [4:0]  rc_s;
    logic [7:0]  rc_fr;
    logic [21:0] act_r_total_cost;

    logic [8:0]  sum_staff;
    logic [6:0]  a_staff;
    
    logic [13:0] h_unit_cost;
    logic [20:0] act_h_total_cost;

    logic [15:0] p_unit_cost;
    logic [23:0] p_total_cost;

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;

    logic [7:0]  lvl_threshold;

    // ----------------------------------------------------
    // Extraction
    // ----------------------------------------------------
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

    assign date_warn  = ({4'd0, in_m} < old_mon) || (({4'd0, in_m} == old_mon) && ({3'd0, in_d} < old_day));
    assign early_term = date_warn && (act != Check_Valid_Date);

    // Div 10 Mux to perfectly replicate the division bounds without synthesis cost
    always_comb begin
        if (old_level >= 100) k = 10;
        else if (old_level >= 90) k = 9;
        else if (old_level >= 80) k = 8;
        else if (old_level >= 70) k = 7;
        else if (old_level >= 60) k = 6;
        else if (old_level >= 50) k = 5;
        else if (old_level >= 40) k = 4;
        else if (old_level >= 30) k = 3;
        else if (old_level >= 20) k = 2;
        else if (old_level >= 10) k = 1;
        else k = 0;
    end
    
    assign lvl_factor = 5'd10 + {1'b0, k};
    
    // Explicit 14-bit square division avoids Level=86 bug
    assign lvl_sq         = {7'd0, old_level[6:0]} * {7'd0, old_level[6:0]};
    assign lvl_sq_div_200 = lvl_sq / 8'd200;

    assign scale_val = (mode_reg == Party_Pack) ? 4'd8 : (mode_reg == Family_Set) ? 4'd4 : 4'd1;

    always_comb begin
        req_f_b = 8'd0; req_b_b = 8'd0; req_m_b = 8'd0; req_s_b = 8'd0; req_fr_b = 8'd0; p_b_div10 = 6'd0;
        case(type_reg)
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

    assign ms_req_f  = (mode_reg == Party_Pack) ? {1'b0, req_f_b,  3'd0} : (mode_reg == Family_Set) ? {2'b0, req_f_b,  2'd0} : {4'b0, req_f_b};
    assign ms_req_b  = (mode_reg == Party_Pack) ? {1'b0, req_b_b,  3'd0} : (mode_reg == Family_Set) ? {2'b0, req_b_b,  2'd0} : {4'b0, req_b_b};
    assign ms_req_m  = (mode_reg == Party_Pack) ? {1'b0, req_m_b,  3'd0} : (mode_reg == Family_Set) ? {2'b0, req_m_b,  2'd0} : {4'b0, req_m_b};
    assign ms_req_s  = (mode_reg == Party_Pack) ? {1'b0, req_s_b,  3'd0} : (mode_reg == Family_Set) ? {2'b0, req_s_b,  2'd0} : {4'b0, req_s_b};
    assign ms_req_fr = (mode_reg == Party_Pack) ? {1'b0, req_fr_b, 3'd0} : (mode_reg == Family_Set) ? {2'b0, req_fr_b, 2'd0} : {4'b0, req_fr_b};

    // Safe 11-bit addition sizes
    assign ms_price = {5'd0, p_b_div10} * {6'd0, lvl_factor} + {4'd0, lvl_sq_div_200};
    assign ms_earn = (mode_reg == Party_Pack) ? {ms_price[10:0], 3'd0} : (mode_reg == Family_Set) ? {1'b0, ms_price[10:0], 2'd0} : {3'b0, ms_price[10:0]};
    assign ms_bal_tmp = {1'b0, old_bal} + {11'd0, ms_earn};
    assign ms_sales_tmp = {1'b0, old_sales} + {9'd0, scale_val};

    assign in_f  = in_res_buf[54:44];
    assign in_b  = in_res_buf[43:33];
    assign in_res_m = in_res_buf[32:22];
    assign in_s  = in_res_buf[21:11];
    assign in_fr = in_res_buf[10:0];

    // PPA area savings: Directly compute the Actual Restock Amounts (a_f, etc.)
    assign sum_f = {1'b0, old_f} + {2'd0, in_f};
    assign sum_b = {1'b0, old_b} + {2'd0, in_b};
    assign sum_m = {1'b0, old_m} + {2'd0, in_res_m};
    assign sum_s = {1'b0, old_s} + {2'd0, in_s};
    assign sum_fr= {1'b0, old_fr}+ {2'd0, in_fr};

    assign a_f  = (sum_f > 13'd4095)  ? (12'd4095 - old_f) : {1'b0, in_f};
    assign a_b  = (sum_b > 13'd4095)  ? (12'd4095 - old_b) : {1'b0, in_b};
    assign a_m  = (sum_m > 13'd4095)  ? (12'd4095 - old_m) : {1'b0, in_res_m};
    assign a_s  = (sum_s > 13'd4095)  ? (12'd4095 - old_s) : {1'b0, in_s};
    assign a_fr = (sum_fr > 13'd4095) ? (12'd4095 - old_fr): {1'b0, in_fr};

    // Math substitution for the constant formulas (Saves 5 Large Multipliers/Dividers)
    // Carefully bit-padded to completely avoid out-of-bounds mapping errors!
    assign rc_f  = 5'd15 + {1'b0, k} + {2'b00, k[3:1]};
    assign rc_b  = 7'd60 + {1'b0, k, 2'b00} + {2'b00, k, 1'b0};
    assign rc_m  = 6'd25 + {1'b0, k, 1'b0} + {3'b000, k[3:1]};
    assign rc_s  = 5'd10 + {1'b0, k};
    assign rc_fr = 8'd80 + {1'b0, k, 3'b000};

    // Using ACTUAL COST logic ONLY, saving massive Area overhead!
    // Size bounded safely to 22-bits.
    assign act_r_total_cost = {10'd0, a_f} * {17'd0, rc_f} + 
                              {10'd0, a_b} * {15'd0, rc_b} + 
                              {10'd0, a_m} * {16'd0, rc_m} + 
                              {10'd0, a_s} * {17'd0, rc_s} + 
                              {10'd0, a_fr} * {14'd0, rc_fr};

    assign sum_staff = {1'b0, old_staff} + {4'd0, in_hire};
    assign a_staff   = (sum_staff > 9'd100) ? (7'd100 - old_staff[6:0]) : {2'd0, in_hire};

    // Using ACTUAL COST logic ONLY for Hire Staff
    assign h_unit_cost = 14'd2000 + ({7'd0, old_level[6:0]} * 14'd100) + ({10'd0, k} * 14'd200);
    assign act_h_total_cost = {14'd0, a_staff} * {7'd0, h_unit_cost};

    assign p_unit_cost = 16'd20000 + ({9'd0, old_level[6:0]} * 16'd200) + ({12'd0, k} * 16'd1000);
    assign p_total_cost = {16'd0, old_staff} * {8'd0, p_unit_cost}; 

    assign lvl_threshold = (k == 0) ? 8'd10 : ({4'd0, k} * 8'd10);

    // ----------------------------------------------------
    // Output Evaluation Logic 
    // ----------------------------------------------------
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
        n_month   = {4'd0, in_m};
        n_day     = {3'd0, in_d};
        rem_sales = 13'd0;

        warn_out = 3'b000;
        comp_out = 1'b0;

        if (date_warn && act == Check_Valid_Date) begin
            warn_out = 3'b001; 
        end else if (date_warn) begin
            warn_out = 3'b001;
            n_month = old_mon;
            n_day   = old_day;
        end else begin
            case(act)
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
                    // 完美的 Golden 邏輯匹配: 只檢查實際會花費的成本 (act_r_total_cost)
                    if (old_bal < {2'd0, act_r_total_cost}) begin
                        warn_out = 3'b100;
                    end else if (sum_f > 13'd4095 || sum_b > 13'd4095 || sum_m > 13'd4095 || sum_s > 13'd4095 || sum_fr > 13'd4095) begin
                        warn_out = 3'b101; 
                        n_f  = old_f + a_f;
                        n_b  = old_b + a_b;
                        n_m  = old_m + a_m;
                        n_s  = old_s + a_s;
                        n_fr = old_fr + a_fr;
                        n_bal = old_bal - {2'd0, act_r_total_cost};
                    end else begin
                        comp_out = 1'b1;
                        n_f  = old_f + {1'b0, in_f};
                        n_b  = old_b + {1'b0, in_b};
                        n_m  = old_m + {1'b0, in_res_m};
                        n_s  = old_s + {1'b0, in_s};
                        n_fr = old_fr + {1'b0, in_fr};
                        n_bal = old_bal - {2'd0, act_r_total_cost};
                    end
                end
                Hire_Staff: begin
                    if (old_bal < {3'd0, act_h_total_cost}) begin
                        warn_out = 3'b100; 
                    end else if (sum_staff > 9'd100) begin
                        warn_out = 3'b110; 
                        n_staff = old_staff + {1'b0, a_staff};
                        n_bal = old_bal - {3'd0, act_h_total_cost};
                    end else begin
                        comp_out = 1'b1;
                        n_staff = old_staff + {3'd0, in_hire};
                        n_bal = old_bal - {3'd0, act_h_total_cost};
                    end
                end
                Pay_Day: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010; 
                    end else if (old_bal < p_total_cost) begin
                        warn_out = 3'b100; 
                        n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                        n_staff = (old_staff == 8'd1) ? 8'd1 : {1'b0, old_staff[7:1]};
                        n_sales = 12'd0;
                    end else begin
                        comp_out = 1'b1;
                        n_bal = old_bal - p_total_cost;
                    end
                end
                Check_Valid_Date: begin
                    comp_out = 1'b1;
                end
                default: ;
            endcase
        end
    end

    // ----------------------------------------------------
    // Output Combiner
    // ----------------------------------------------------
    assign d_new = {n_fr, n_sales, n_staff, n_bal, n_level, n_f, n_b, n_month, n_m, n_s, n_day};

endmodule