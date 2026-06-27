//############################################################################
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//      File Name   : DSS.sv
//      Module Name : DSS
//      Description : Dessert Shop Simulator (Pipelined PPA Optimized)
//############################################################################

`include "Usertype.sv"

// ============================================================================
// Module: DSS (Top Module)
// Description: Manages AXI4-Lite interfaces, FSM, and Input Gathering
// ============================================================================
module DSS(input clk, INF.DSS_inf inf);
    import usertype::*;

    // ------------------------------------------------------------------------
    // FSM State Encoding
    // ------------------------------------------------------------------------
    typedef enum logic [3:0] {
        S_IDLE    = 4'd0,
        S_AR_0    = 4'd1,
        S_R_0     = 4'd2,
        S_AR_1    = 4'd3,
        S_R_1     = 4'd4,
        S_WAIT_IN = 4'd5,
        S_CALC_1  = 4'd6,
        S_CALC_2  = 4'd7,
        S_AW_W_0  = 4'd8,
        S_B_0     = 4'd9,
        S_AW_W_1  = 4'd10,
        S_B_1     = 4'd11,
        S_OUT     = 4'd12
    } state_t;

    state_t state;
    state_t n_state;

    // ------------------------------------------------------------------------
    // Registers & Wires Declaration
    // ------------------------------------------------------------------------
    Action       act_reg;
    Dessert_Type type_reg;
    Order_Mode   mode_reg;
    
    logic [7:0]  in_data_no;
    logic [6:0]  in_hire;     
    logic [3:0]  in_m;
    logic [4:0]  in_d;
    logic [59:0] in_res_buf;  

    logic [3:0]  input_cnt;
    logic [3:0]  inputs_needed;
    logic        any_valid_in;
    logic        inputs_ready;

    logic [127:0] d_old;
    logic [127:0] datapath_d_new;
    logic [2:0]   datapath_warn;
    logic         datapath_comp;
    logic         early_term;
    logic         en_stage1;

    logic         aw_done;
    logic         w_done;
    logic         aw_fire;
    logic         w_fire;
    logic [7:0]   current_data_no;
    logic [16:0]  base_addr;
    logic [16:0]  base_addr_offset;

    // ------------------------------------------------------------------------
    // Continuous Assignments 
    // ------------------------------------------------------------------------
    assign any_valid_in = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                          inf.staff_valid | inf.date_valid | inf.data_no_valid | inf.restock_valid;

    assign current_data_no  = inf.data_no_valid ? inf.D[7:0] : in_data_no;
    assign base_addr        = 17'h10000 + {5'd0, current_data_no, 4'd0};
    assign base_addr_offset = base_addr + 17'd8;

    assign inputs_ready = (input_cnt == inputs_needed) || 
                          ((input_cnt == inputs_needed - 4'd1) && any_valid_in);

    assign aw_fire = (inf.AW_VALID && inf.AW_READY) || aw_done;
    assign w_fire  = (inf.W_VALID && inf.W_READY) || w_done;
    
    assign en_stage1 = (state == S_CALC_1);

    always_comb begin
        inputs_needed = 4'd15;
        case(act_reg)
            Make_and_Sell:    inputs_needed = 4'd5;
            Restock:          inputs_needed = 4'd8;
            Hire_Staff:       inputs_needed = 4'd4;
            Pay_Day:          inputs_needed = 4'd3;
            Check_Valid_Date: inputs_needed = 4'd3;
            default:          inputs_needed = 4'd15;
        endcase
    end

    // ------------------------------------------------------------------------
    // FSM Control
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= n_state;
        end
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
            S_CALC_1:                         n_state = S_CALC_2;
            S_CALC_2:  if (early_term)        n_state = S_OUT;
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
    // Input Gathering 
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
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

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            in_res_buf <= 60'd0;
        end else if (inf.restock_valid && act_reg == Restock) begin 
            in_res_buf <= {in_res_buf[47:0], inf.D[11:0]};
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

    // ------------------------------------------------------------------------
    // Read Data Latch 
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            d_old <= 128'd0;
        end else begin
            if (state == S_R_0 && inf.R_VALID) d_old[63:0]   <= inf.R_DATA;
            if (state == S_R_1 && inf.R_VALID) d_old[127:64] <= inf.R_DATA;
        end
    end

    // ------------------------------------------------------------------------
    // AXI Control: AR Channel
    // ------------------------------------------------------------------------
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

    // ------------------------------------------------------------------------
    // AXI Control: R Channel
    // ------------------------------------------------------------------------
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
    // AXI Control: AW Channel & Handshake
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AW_VALID <= 1'b0;
            inf.AW_ADDR  <= 17'd0;
            aw_done      <= 1'b0;
        end else begin
            if (state == S_AW_W_0 || state == S_AW_W_1) begin
                if (inf.AW_VALID && inf.AW_READY) aw_done <= 1'b1;
            end else begin
                aw_done <= 1'b0;
            end

            if ((state == S_CALC_2 && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.AW_VALID <= 1'b1;
                inf.AW_ADDR  <= (n_state == S_AW_W_0) ? base_addr : base_addr_offset;
            end else if (inf.AW_VALID && inf.AW_READY) begin
                inf.AW_VALID <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // AXI Control: W Channel & Handshake
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.W_VALID <= 1'b0;
            inf.W_DATA  <= 64'd0;
            w_done      <= 1'b0;
        end else begin
            if (state == S_AW_W_0 || state == S_AW_W_1) begin
                if (inf.W_VALID && inf.W_READY) w_done <= 1'b1;
            end else begin
                w_done <= 1'b0;
            end

            if ((state == S_CALC_2 && n_state == S_AW_W_0) || (state == S_B_0 && n_state == S_AW_W_1)) begin
                inf.W_VALID <= 1'b1;
                inf.W_DATA  <= (n_state == S_AW_W_0) ? datapath_d_new[63:0] : datapath_d_new[127:64];
            end else if (inf.W_VALID && inf.W_READY) begin
                inf.W_VALID <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // AXI Control: B Channel
    // ------------------------------------------------------------------------
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
    // Datapath Instantiation (Pipelined)
    // ------------------------------------------------------------------------
    DSS_DATAPATH u_datapath (
        .clk        (clk),
        .rst_n      (inf.rst_n),
        .en_stage1  (en_stage1),
        .act        (act_reg),
        .type_reg   (type_reg),
        .mode_reg   (mode_reg),
        .in_m       (in_m),
        .in_d       (in_d),
        .in_hire    (in_hire),
        .in_res_buf (in_res_buf),
        .d_old      (d_old),
        .d_new      (datapath_d_new),
        .warn_out   (datapath_warn),
        .comp_out   (datapath_comp),
        .early_term (early_term)
    );

    // ------------------------------------------------------------------------
    // Final Output DFFs
    // ------------------------------------------------------------------------
    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end else if (n_state == S_OUT) begin
            inf.out_valid <= 1'b1;
            inf.warn_msg  <= Warn_Msg'(datapath_warn);
            inf.complete  <= datapath_comp;
        end else begin
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end
    end

endmodule

// ============================================================================
// Module: DSS_DATAPATH
// Description: Core Engine with 2-Stage Pipeline (Multiplier -> Saturation)
// ============================================================================
module DSS_DATAPATH (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  en_stage1,
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
    output logic                  early_term
);
    import usertype::*;

    logic [11:0] old_f, old_b, old_m, old_s, old_fr, old_sales;
    logic [7:0]  old_mon, old_day, old_staff, old_level;
    logic [23:0] old_bal;

    logic        date_warn;

    logic [3:0]  k; 
    logic [4:0]  lvl_factor;
    logic [5:0]  lvl_sq_div_200;
    logic [7:0]  lvl_threshold;

    logic [4:0]  rc_f;
    logic [7:0]  rc_b;
    logic [5:0]  rc_m;
    logic [4:0]  rc_s;
    logic [7:0]  rc_fr;
    logic [13:0] h_unit_cost;
    logic [15:0] p_unit_cost;

    logic [5:0]  p_b_div10;
    logic [11:0] ms_req_f, ms_req_b, ms_req_m, ms_req_s, ms_req_fr;
    logic [10:0] ms_price; 
    logic [13:0] ms_earn;
    logic [3:0]  scale_val;

    logic [24:0] ms_bal_tmp;
    logic [12:0] ms_sales_tmp;
    logic [12:0] rem_sales;

    logic [11:0] in_f, in_b, in_res_m, in_s, in_fr;
    logic [12:0] sum_f, sum_b, sum_m, sum_s, sum_fr;
    logic [11:0] a_f, a_b, a_m, a_s, a_fr;

    logic [21:0] act_r_total_cost;
    logic [8:0]  sum_staff;
    logic [6:0]  a_staff;
    logic [20:0] act_h_total_cost;
    logic [23:0] p_total_cost;

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;

    // --- PIPELINE REGISTERS (Stage 1 to Stage 2) ---
    logic        s1_date_warn;
    logic [24:0] s1_ms_bal_tmp;
    logic [12:0] s1_ms_sales_tmp;
    logic [21:0] s1_act_r_total_cost;
    logic [20:0] s1_act_h_total_cost;
    logic [23:0] s1_p_total_cost;
    logic        s1_of_f, s1_of_b, s1_of_m, s1_of_s, s1_of_fr;
    logic [11:0] s1_a_f, s1_a_b, s1_a_m, s1_a_s, s1_a_fr;
    logic        s1_of_staff;
    logic [6:0]  s1_a_staff;

    // ----------------------------------------------------
    // Extraction & Instantiations
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

    DSS_LEVEL_ALU u_level_alu(
        .level      (old_level),
        .k          (k),
        .lvl_factor (lvl_factor),
        .sq_div_200 (lvl_sq_div_200),
        .threshold  (lvl_threshold),
        .rc_f       (rc_f),
        .rc_b       (rc_b),
        .rc_m       (rc_m),
        .rc_s       (rc_s),
        .rc_fr      (rc_fr),
        .h_cost     (h_unit_cost),
        .p_cost     (p_unit_cost)
    );

    DSS_RECIPE_DECODER u_recipe(
        .type_reg (type_reg),
        .mode_reg (mode_reg),
        .req_f    (ms_req_f),
        .req_b    (ms_req_b),
        .req_m    (ms_req_m),
        .req_s    (ms_req_s),
        .req_fr   (ms_req_fr),
        .pb_div10 (p_b_div10),
        .scale    (scale_val)
    );

    // ----------------------------------------------------
    // STAGE 1: Pure Combinational Logic (Arithmetic)
    // ----------------------------------------------------
    assign date_warn  = ({4'd0, in_m} < old_mon) || (({4'd0, in_m} == old_mon) && ({3'd0, in_d} < old_day));

    assign ms_price = ({6'd0, p_b_div10} * {6'd0, lvl_factor}) + {5'd0, lvl_sq_div_200};

    always_comb begin
        ms_earn = {3'b0, ms_price[10:0]};
        if (mode_reg == Party_Pack)      ms_earn = {ms_price[10:0], 3'd0};
        else if (mode_reg == Family_Set) ms_earn = {1'b0, ms_price[10:0], 2'd0};
    end

    assign ms_bal_tmp   = {1'b0, old_bal} + {11'd0, ms_earn};
    assign ms_sales_tmp = {1'b0, old_sales} + {9'd0, scale_val};

    assign in_f     = in_res_buf[59:48];
    assign in_b     = in_res_buf[47:36];
    assign in_res_m = in_res_buf[35:24];
    assign in_s     = in_res_buf[23:12];
    assign in_fr    = in_res_buf[11:0];

    assign sum_f  = {1'b0, old_f} + {1'b0, in_f};
    assign sum_b  = {1'b0, old_b} + {1'b0, in_b};
    assign sum_m  = {1'b0, old_m} + {1'b0, in_res_m};
    assign sum_s  = {1'b0, old_s} + {1'b0, in_s};
    assign sum_fr = {1'b0, old_fr}+ {1'b0, in_fr};

    assign a_f  = sum_f[12]  ? ~old_f  : in_f;
    assign a_b  = sum_b[12]  ? ~old_b  : in_b;
    assign a_m  = sum_m[12]  ? ~old_m  : in_res_m;
    assign a_s  = sum_s[12]  ? ~old_s  : in_s;
    assign a_fr = sum_fr[12] ? ~old_fr : in_fr;

    assign act_r_total_cost = {10'd0, a_f} * {17'd0, rc_f} + 
                              {10'd0, a_b} * {14'd0, rc_b} + 
                              {10'd0, a_m} * {16'd0, rc_m} + 
                              {10'd0, a_s} * {17'd0, rc_s} + 
                              {10'd0, a_fr} * {14'd0, rc_fr};

    assign sum_staff = {1'b0, old_staff} + {2'd0, in_hire};
    assign a_staff   = (sum_staff > 9'd100) ? (7'd100 - old_staff[6:0]) : in_hire;

    assign act_h_total_cost = {14'd0, a_staff} * {7'd0, h_unit_cost};
    assign p_total_cost     = {16'd0, old_staff} * {8'd0, p_unit_cost}; 

    // ----------------------------------------------------
    // PIPELINE REGISTER BLOCK (Clocked)
    // ----------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s1_date_warn        <= 1'b0;
            s1_ms_bal_tmp       <= 25'd0;
            s1_ms_sales_tmp     <= 13'd0;
            s1_act_r_total_cost <= 22'd0;
            s1_act_h_total_cost <= 21'd0;
            s1_p_total_cost     <= 24'd0;
            s1_of_f             <= 1'b0;
            s1_of_b             <= 1'b0;
            s1_of_m             <= 1'b0;
            s1_of_s             <= 1'b0;
            s1_of_fr            <= 1'b0;
            s1_a_f              <= 12'd0;
            s1_a_b              <= 12'd0;
            s1_a_m              <= 12'd0;
            s1_a_s              <= 12'd0;
            s1_a_fr             <= 12'd0;
            s1_of_staff         <= 1'b0;
            s1_a_staff          <= 7'd0;
        end else if (en_stage1) begin
            s1_date_warn        <= date_warn;
            s1_ms_bal_tmp       <= ms_bal_tmp;
            s1_ms_sales_tmp     <= ms_sales_tmp;
            s1_act_r_total_cost <= act_r_total_cost;
            s1_act_h_total_cost <= act_h_total_cost;
            s1_p_total_cost     <= p_total_cost;
            s1_of_f             <= sum_f[12];
            s1_of_b             <= sum_b[12];
            s1_of_m             <= sum_m[12];
            s1_of_s             <= sum_s[12];
            s1_of_fr            <= sum_fr[12];
            s1_a_f              <= a_f;
            s1_a_b              <= a_b;
            s1_a_m              <= a_m;
            s1_a_s              <= a_s;
            s1_a_fr             <= a_fr;
            s1_of_staff         <= (sum_staff > 9'd100);
            s1_a_staff          <= a_staff;
        end
    end

    // ----------------------------------------------------
    // STAGE 2: Logical Decision & Saturation
    // ----------------------------------------------------
    assign early_term = s1_date_warn && (act != Check_Valid_Date);

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

        if (s1_date_warn && act == Check_Valid_Date) begin
            warn_out = 3'b001;
        end else if (s1_date_warn) begin
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
                        
                        n_bal = (s1_ms_bal_tmp > 25'd16777215) ? 24'd16777215 : s1_ms_bal_tmp[23:0];
                        
                        if (old_level < 8'd100 && s1_ms_sales_tmp >= {5'd0, lvl_threshold}) begin
                            n_level   = old_level + 8'd1;
                            rem_sales = s1_ms_sales_tmp - {5'd0, lvl_threshold};
                            n_sales   = (rem_sales > 13'd4095) ? 12'd4095 : rem_sales[11:0];
                        end else begin
                            n_sales   = (s1_ms_sales_tmp > 13'd4095) ? 12'd4095 : s1_ms_sales_tmp[11:0];
                        end
                    end
                end
                Restock: begin
                    if (old_bal < {2'd0, s1_act_r_total_cost}) begin
                        warn_out = 3'b100;
                    end else if (s1_of_f || s1_of_b || s1_of_m || s1_of_s || s1_of_fr) begin
                        warn_out = 3'b101;
                        n_f  = old_f + s1_a_f;
                        n_b  = old_b + s1_a_b;
                        n_m  = old_m + s1_a_m;
                        n_s  = old_s + s1_a_s;
                        n_fr = old_fr + s1_a_fr;
                        n_bal = old_bal - {2'd0, s1_act_r_total_cost};
                    end else begin
                        comp_out = 1'b1;
                        n_f  = old_f + s1_a_f;
                        n_b  = old_b + s1_a_b;
                        n_m  = old_m + s1_a_m;
                        n_s  = old_s + s1_a_s;
                        n_fr = old_fr + s1_a_fr;
                        n_bal = old_bal - {2'd0, s1_act_r_total_cost};
                    end
                end
                Hire_Staff: begin
                    if (old_bal < {3'd0, s1_act_h_total_cost}) begin
                        warn_out = 3'b100;
                    end else if (s1_of_staff) begin
                        warn_out = 3'b110;
                        n_staff = old_staff + {1'b0, s1_a_staff};
                        n_bal = old_bal - {3'd0, s1_act_h_total_cost};
                    end else begin
                        comp_out = 1'b1;
                        n_staff = old_staff + {1'b0, s1_a_staff};
                        n_bal = old_bal - {3'd0, s1_act_h_total_cost};
                    end
                end
                Pay_Day: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (old_bal < s1_p_total_cost) begin
                        warn_out = 3'b100;
                        n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                        n_staff = (old_staff == 8'd1) ? 8'd1 : {1'b0, old_staff[7:1]};
                        n_sales = 12'd0;
                    end else begin
                        comp_out = 1'b1;
                        n_bal = old_bal - s1_p_total_cost;
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
// Module: DSS_LEVEL_ALU
// Description: Multiplier-free derivation of costs using shifts
// ============================================================================
module DSS_LEVEL_ALU (
    input  logic [7:0]  level,
    output logic [3:0]  k,
    output logic [4:0]  lvl_factor,
    output logic [5:0]  sq_div_200,
    output logic [7:0]  threshold,
    output logic [4:0]  rc_f,
    output logic [7:0]  rc_b,
    output logic [5:0]  rc_m,
    output logic [4:0]  rc_s,
    output logic [7:0]  rc_fr,
    output logic [13:0] h_cost,
    output logic [15:0] p_cost
);

    const logic [5:0] SQ_LUT [0:100] = '{
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 
        2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 
        4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 
        8, 8, 8, 9, 9, 10, 10, 11, 11, 12, 
        12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 
        18, 18, 19, 19, 20, 21, 21, 22, 23, 23, 
        24, 25, 25, 26, 27, 28, 28, 29, 30, 31, 
        32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 
        50
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

    // Relied on synthesis tool to optimize constant multiplications via shift-add tree 
    // to keep readability while avoiding standard large multiplier synthesis.
    assign h_cost = 14'd2000 + ({7'd0, level[6:0]} * 14'd100) + ({10'd0, k} * 14'd200);
    assign p_cost = 16'd20000 + ({9'd0, level[6:0]} * 16'd200) + ({12'd0, k} * 16'd1000);

endmodule

// ============================================================================
// Module: DSS_RECIPE_DECODER
// Description: Decodes dessert types and order mode scalings Early pre-decode
// ============================================================================
module DSS_RECIPE_DECODER (
    input  usertype::Dessert_Type type_reg,
    input  usertype::Order_Mode   mode_reg,
    output logic [11:0]           req_f,
    output logic [11:0]           req_b,
    output logic [11:0]           req_m,
    output logic [11:0]           req_s,
    output logic [11:0]           req_fr,
    output logic [5:0]            pb_div10,
    output logic [3:0]            scale
);
    import usertype::*;

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
            req_f  = {1'b0, r_f, 3'd0};
            req_b  = {1'b0, r_b, 3'd0};
            req_m  = {1'b0, r_m, 3'd0};
            req_s  = {1'b0, r_s, 3'd0};
            req_fr = {1'b0, r_fr, 3'd0};
        end else if (mode_reg == Family_Set) begin
            req_f  = {2'b0, r_f, 2'd0};
            req_b  = {2'b0, r_b, 2'd0};
            req_m  = {2'b0, r_m, 2'd0};
            req_s  = {2'b0, r_s, 2'd0};
            req_fr = {2'b0, r_fr, 2'd0};
        end else begin
            req_f  = {4'b0, r_f};
            req_b  = {4'b0, r_b};
            req_m  = {4'b0, r_m};
            req_s  = {4'b0, r_s};
            req_fr = {4'b0, r_fr};
        end
    end

endmodule