//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//      Date        : 2026/5
//      Version     : v10.9 (Golden Release: Requested vs Actual Warning Fix)
//      File Name   : DSS.sv
//      Module Name : DSS
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "Usertype.sv"

// ============================================================================
// Module: DSS (Top Module & FSM Controller)
// ============================================================================
module DSS(input clk, INF.DSS_inf inf);
    import usertype::*;

    typedef enum logic [3:0] {
        S_IDLE, 
        S_RD_REQ_0, S_RD_WAIT_0, 
        S_RD_REQ_1, S_RD_WAIT_1,
        S_WAIT_IN,  S_CALC,
        S_WR_REQ_0, S_WR_WAIT_0,
        S_WR_REQ_1, S_WR_WAIT_1,
        S_OUT
    } state_t;
    
    state_t state, n_state;

    // Datapath Registers
    Action       act_reg;
    Dessert_Type type_reg;
    Order_Mode   mode_reg;
    logic [3:0]  in_m;
    logic [4:0]  in_d;
    logic [7:0]  in_data_no;
    logic [4:0]  in_hire;
    logic [10:0] in_res [0:4];
    
    logic [127:0] d_old;
    logic [127:0] d_new_reg;
    Warn_Msg      warn_reg;
    logic         comp_reg;

    // Control Registers
    logic [2:0]  res_idx;
    logic [3:0]  input_cnt;

    logic [3:0]  inputs_needed;
    logic        read_req;
    logic [16:0] read_addr;
    logic        read_done;
    logic [63:0] read_data;

    logic        write_req;
    logic [16:0] write_addr;
    logic [63:0] write_data;
    logic        write_done;

    logic [127:0] alu_d_new;
    logic [2:0]   alu_warn;
    logic         alu_comp;
    logic         alu_early_term;
    logic         any_valid_in;

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

    assign any_valid_in = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                          inf.date_valid | inf.staff_valid | inf.data_no_valid | inf.restock_valid;

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            state     <= S_IDLE;
            res_idx   <= 0;
            input_cnt <= 0;
        end else begin
            state <= n_state;
            if (state == S_OUT) begin
                res_idx   <= 0;
                input_cnt <= 0;
            end else begin
                if (inf.restock_valid) res_idx <= res_idx + 1;
                if (any_valid_in)      input_cnt <= input_cnt + 1;
            end
        end
    end

    always_comb begin
        n_state = state;
        case (state)
            S_IDLE:      if (inf.data_no_valid)   n_state = S_RD_REQ_0;
            S_RD_REQ_0:                           n_state = S_RD_WAIT_0;
            S_RD_WAIT_0: if (read_done)           n_state = S_RD_REQ_1;
            S_RD_REQ_1:                           n_state = S_RD_WAIT_1;
            S_RD_WAIT_1: if (read_done)           n_state = S_WAIT_IN;
            S_WAIT_IN:   if (input_cnt == inputs_needed) n_state = S_CALC;
            S_CALC:      if (alu_early_term)      n_state = S_OUT;
                         else                     n_state = S_WR_REQ_0;
            S_WR_REQ_0:                           n_state = S_WR_WAIT_0;
            S_WR_WAIT_0: if (write_done)          n_state = S_WR_REQ_1;
            S_WR_REQ_1:                           n_state = S_WR_WAIT_1;
            S_WR_WAIT_1: if (write_done)          n_state = S_OUT;
            S_OUT:                                n_state = S_IDLE;
            default:                              n_state = S_IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (inf.sel_action_valid) act_reg    <= Action'(inf.D[2:0]);
        if (inf.type_valid)       type_reg   <= Dessert_Type'(inf.D[2:0]);
        if (inf.mode_valid)       mode_reg   <= Order_Mode'(inf.D[1:0]);
        if (inf.data_no_valid)    in_data_no <= inf.D[7:0];
        if (inf.staff_valid)      in_hire    <= inf.D[4:0];
        
        if (inf.date_valid) begin
            in_m <= inf.D[8:5];
            in_d <= inf.D[4:0];
        end
        
        if (inf.restock_valid) begin
            in_res[res_idx] <= inf.D[10:0];
        end

        if (state == S_RD_WAIT_0 && read_done) d_old[63:0]   <= read_data;
        if (state == S_RD_WAIT_1 && read_done) d_old[127:64] <= read_data;
        
        if (state == S_CALC) begin
            d_new_reg <= alu_d_new;
            warn_reg  <= Warn_Msg'(alu_warn);
            comp_reg  <= alu_comp;
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.out_valid <= 1'b0;
            inf.complete  <= 1'b0;
            inf.warn_msg  <= No_Warn;
        end else if (state == S_OUT) begin
            inf.out_valid <= 1'b1;
            inf.complete  <= comp_reg;
            inf.warn_msg  <= warn_reg;
        end else begin
            inf.out_valid <= 1'b0;
            inf.complete  <= 1'b0;
            inf.warn_msg  <= No_Warn;
        end
    end

    assign read_req   = (state == S_RD_REQ_0) || (state == S_RD_REQ_1);
    assign read_addr  = (state == S_RD_REQ_0 || state == S_RD_WAIT_0) ? (17'h10000 + {9'b0, in_data_no} * 16) : (17'h10000 + {9'b0, in_data_no} * 16 + 8);
    
    assign write_req  = (state == S_WR_REQ_0) || (state == S_WR_REQ_1);
    assign write_addr = (state == S_WR_REQ_0 || state == S_WR_WAIT_0) ? (17'h10000 + {9'b0, in_data_no} * 16) : (17'h10000 + {9'b0, in_data_no} * 16 + 8);
    assign write_data = (state == S_WR_REQ_0 || state == S_WR_WAIT_0) ? d_new_reg[63:0] : d_new_reg[127:64];

    DSS_AXI_CTRL u_axi_ctrl (
        .clk(clk), .rst_n(inf.rst_n),
        .read_req(read_req), .read_addr(read_addr), .read_done(read_done), .read_data(read_data),
        .write_req(write_req), .write_addr(write_addr), .write_data(write_data), .write_done(write_done),
        .inf(inf)
    );

    DSS_ALU u_alu (
        .act(act_reg), .dtype(type_reg), .mode(mode_reg),
        .in_m(in_m), .in_d(in_d), .in_hire(in_hire),
        .in_res(in_res), .d_old(d_old),
        .d_new(alu_d_new), .warn_out(alu_warn), .complete_out(alu_comp), .early_term(alu_early_term)
    );

endmodule

// ============================================================================
// Module: DSS_AXI_CTRL
// ============================================================================
module DSS_AXI_CTRL (
    input  logic        clk,
    input  logic        rst_n,
    
    input  logic        read_req,
    input  logic [16:0] read_addr,
    output logic        read_done,
    output logic [63:0] read_data,

    input  logic        write_req,
    input  logic [16:0] write_addr,
    input  logic [63:0] write_data,
    output logic        write_done,

    INF.DSS_inf         inf
);
    typedef enum logic [1:0] {R_IDLE, R_ADDR, R_DATA} axi_r_state_t;
    typedef enum logic [1:0] {W_IDLE, W_REQ, W_RESP}  axi_w_state_t;
    
    axi_r_state_t r_state, r_next;
    axi_w_state_t w_state, w_next;

    logic aw_done;
    logic w_done_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_state <= R_IDLE;
        else        r_state <= r_next;
    end

    always_comb begin
        r_next = r_state;
        case(r_state)
            R_IDLE: if (read_req)     r_next = R_ADDR;
            R_ADDR: if (inf.AR_READY) r_next = R_DATA;
            R_DATA: if (inf.R_VALID)  r_next = R_IDLE;
            default:                  r_next = R_IDLE;
        endcase
    end

    assign inf.AR_VALID = (r_state == R_ADDR);
    assign inf.AR_ADDR  = (r_state == R_IDLE) ? 17'b0 : read_addr;
    assign inf.R_READY  = (r_state == R_DATA);
    
    assign read_done    = (r_state == R_DATA && inf.R_VALID);
    assign read_data    = inf.R_DATA; 

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state    <= W_IDLE;
            aw_done    <= 1'b0;
            w_done_reg <= 1'b0;
        end else begin
            w_state <= w_next;
            if (w_state == W_REQ) begin
                if (inf.AW_VALID && inf.AW_READY) aw_done    <= 1'b1;
                if (inf.W_VALID  && inf.W_READY)  w_done_reg <= 1'b1;
            end else if (w_state == W_IDLE) begin
                aw_done    <= 1'b0;
                w_done_reg <= 1'b0;
            end
        end
    end

    always_comb begin
        w_next = w_state;
        case(w_state)
            W_IDLE: if (write_req) w_next = W_REQ;
            W_REQ:  if ((inf.AW_READY || aw_done) && (inf.W_READY || w_done_reg)) w_next = W_RESP;
            W_RESP: if (inf.B_VALID) w_next = W_IDLE;
            default: w_next = W_IDLE;
        endcase
    end

    assign inf.AW_VALID = (w_state == W_REQ && !aw_done);
    assign inf.AW_ADDR  = (w_state == W_IDLE) ? 17'b0 : write_addr;
    assign inf.W_VALID  = (w_state == W_REQ && !w_done_reg);
    assign inf.W_DATA   = (w_state == W_IDLE) ? 64'b0 : write_data;
    assign inf.B_READY  = (w_state == W_RESP);
    assign write_done   = (w_state == W_RESP && inf.B_VALID);

endmodule

// ============================================================================
// Module: DSS_ALU
// ============================================================================
module DSS_ALU (
    input  usertype::Action       act,
    input  usertype::Dessert_Type dtype,
    input  usertype::Order_Mode   mode,
    input  logic [3:0]            in_m,
    input  logic [4:0]            in_d,
    input  logic [4:0]            in_hire,
    input  logic [10:0]           in_res [0:4],
    input  logic [127:0]          d_old,
    output logic [127:0]          d_new,
    output logic [2:0]            warn_out,
    output logic                  complete_out,
    output logic                  early_term
);
    import usertype::*;

    logic [11:0] old_f, old_b, old_m, old_s, old_fr, old_sales;
    logic [7:0]  old_mon, old_day, old_staff, old_level;
    logic [23:0] old_bal;

    assign old_f     = d_old[63:52];
    assign old_b     = d_old[51:40];
    assign old_mon   = d_old[39:32];
    assign old_m     = d_old[31:20];
    assign old_s     = d_old[19:8];
    assign old_day   = d_old[7:0];
    assign old_fr    = d_old[127:116]; 
    assign old_sales = d_old[115:104];
    assign old_staff = d_old[103:96];
    
    // Bit Slicing Fixes included
    assign old_bal   = d_old[95:72];  
    assign old_level = d_old[71:64];  

    logic date_warn;
    assign date_warn  = (in_m < old_mon) || ((in_m == old_mon) && (in_d < old_day));

    logic [6:0] level;
    logic [3:0] lvl_div_10;
    logic [4:0] lvl_factor;

    assign level          = old_level[6:0];
    assign lvl_div_10     = level / 10; 
    assign lvl_factor     = 5'd10 + lvl_div_10;
    
    // 32-bit Safe Balance Check for Pay Day
    logic [31:0] calc_bal;
    assign calc_bal = {8'b0, old_bal};
    
    logic [31:0] p_salary_per_staff;
    logic [31:0] p_total_salary;
    logic        p_bal_warn;
    
    assign p_salary_per_staff = 32'd20000 + {25'b0, level} * 32'd200 + {28'b0, lvl_div_10} * 32'd1000;
    assign p_total_salary     = {24'b0, old_staff} * p_salary_per_staff;
    assign p_bal_warn         = (calc_bal < p_total_salary);

    // ✨✨ FIX: Hire Staff (Requested vs Actual) ✨✨
    logic [6:0]  a_staff;
    logic [7:0]  t_staff;
    logic        staff_warn;
    assign t_staff = old_staff + {3'b0, in_hire};
    assign staff_warn = (t_staff > 8'd100);
    assign a_staff = (t_staff > 8'd100) ? (7'd100 - old_staff[6:0]) : {2'b0, in_hire};

    logic [31:0] h_cost_per_staff;
    logic [31:0] h_total_cost;
    logic [31:0] h_req_cost; // 要求雇用成本
    logic        h_bal_warn;
    
    assign h_cost_per_staff = 32'd2000 + {25'b0, level} * 32'd100 + {28'b0, lvl_div_10} * 32'd200;
    assign h_req_cost       = {27'b0, in_hire} * h_cost_per_staff;   // Warning 用 Requested
    assign h_total_cost     = {25'b0, a_staff} * h_cost_per_staff;   // 扣款用 Actual
    assign h_bal_warn       = (calc_bal < h_req_cost);

    // ✨✨ FIX: Restock (Requested vs Actual) ✨✨
    logic [12:0] t_f, t_b, t_m, t_s, t_fr;
    logic [11:0] a_f, a_b, a_m, a_s, a_fr;
    logic        restock_warn;
    
    assign t_f  = {1'b0, old_f} + {2'b0, in_res[0]};
    assign t_b  = {1'b0, old_b} + {2'b0, in_res[1]};
    assign t_m  = {1'b0, old_m} + {2'b0, in_res[2]};
    assign t_s  = {1'b0, old_s} + {2'b0, in_res[3]};
    assign t_fr = {1'b0, old_fr} + {2'b0, in_res[4]};

    assign restock_warn = (t_f > 13'd4095) || (t_b > 13'd4095) || (t_m > 13'd4095) || (t_s > 13'd4095) || (t_fr > 13'd4095);

    assign a_f  = (t_f > 13'd4095) ? (12'd4095 - old_f) : {1'b0, in_res[0]};
    assign a_b  = (t_b > 13'd4095) ? (12'd4095 - old_b) : {1'b0, in_res[1]};
    assign a_m  = (t_m > 13'd4095) ? (12'd4095 - old_m) : {1'b0, in_res[2]};
    assign a_s  = (t_s > 13'd4095) ? (12'd4095 - old_s) : {1'b0, in_res[3]};
    assign a_fr = (t_fr > 13'd4095) ? (12'd4095 - old_fr) : {1'b0, in_res[4]};

    logic [31:0] r_cost_f, r_cost_m, r_cost_s, r_cost_b, r_cost_fr;
    logic [31:0] r_total_cost;
    logic [31:0] r_req_cost; // 要求補貨成本
    logic        r_bal_warn;
    
    assign r_cost_f  = (32'd3 * {27'b0, lvl_factor}) >> 1;
    assign r_cost_b  = 32'd6 * {27'b0, lvl_factor};
    assign r_cost_m  = (32'd5 * {27'b0, lvl_factor}) >> 1;
    assign r_cost_s  = {27'b0, lvl_factor};
    assign r_cost_fr = 32'd8 * {27'b0, lvl_factor};
    
    // Warning 用 Requested Amount 算成本
    assign r_req_cost = {21'b0, in_res[0]} * r_cost_f +
                        {21'b0, in_res[1]} * r_cost_b +
                        {21'b0, in_res[2]} * r_cost_m +
                        {21'b0, in_res[3]} * r_cost_s +
                        {21'b0, in_res[4]} * r_cost_fr;

    // 扣款用 Actual (Clamped) Amount 算成本
    assign r_total_cost = {20'b0, a_f} * r_cost_f +
                          {20'b0, a_b} * r_cost_b +
                          {20'b0, a_m} * r_cost_m +
                          {20'b0, a_s} * r_cost_s +
                          {20'b0, a_fr} * r_cost_fr;

    assign r_bal_warn = (calc_bal < r_req_cost);

    // 32-bit Safe Math for Make & Sell
    logic [7:0]  req_f_base, req_b_base, req_m_base, req_s_base, req_fr_base;
    logic [5:0]  p_base_div_10;
    logic [3:0]  scale;
    logic [11:0] ms_req_f, ms_req_b, ms_req_m, ms_req_s, ms_req_fr;
    logic        stock_warn;
    
    always_comb begin
        case(dtype)
            Cookie:     begin req_f_base=100; req_b_base=50;  req_m_base=0;   req_s_base=30;  req_fr_base=0;   p_base_div_10=12; end
            Bread:      begin req_f_base=200; req_b_base=20;  req_m_base=50;  req_s_base=10;  req_fr_base=0;   p_base_div_10=10; end
            Fruit_Cake: begin req_f_base=150; req_b_base=80;  req_m_base=40;  req_s_base=60;  req_fr_base=100; p_base_div_10=40; end
            Pudding:    begin req_f_base=0;   req_b_base=0;   req_m_base=150; req_s_base=50;  req_fr_base=20;  p_base_div_10=18; end
            Macaron:    begin req_f_base=40;  req_b_base=30;  req_m_base=0;   req_s_base=120; req_fr_base=0;   p_base_div_10=25; end
            Pancake:    begin req_f_base=120; req_b_base=30;  req_m_base=80;  req_s_base=20;  req_fr_base=40;  p_base_div_10=20; end
            Brownie:    begin req_f_base=80;  req_b_base=100; req_m_base=0;   req_s_base=100; req_fr_base=0;   p_base_div_10=28; end
            Scone:      begin req_f_base=150; req_b_base=60;  req_m_base=30;  req_s_base=20;  req_fr_base=10;  p_base_div_10=16; end
            default:    begin req_f_base=0;   req_b_base=0;   req_m_base=0;   req_s_base=0;   req_fr_base=0;   p_base_div_10=0;  end
        endcase
        case(mode)
            Single:     scale = 1;
            Family_Set: scale = 4;
            Party_Pack: scale = 8;
            default:    scale = 0;
        endcase
    end

    assign ms_req_f  = {4'b0, req_f_base} * {8'b0, scale};
    assign ms_req_b  = {4'b0, req_b_base} * {8'b0, scale};
    assign ms_req_m  = {4'b0, req_m_base} * {8'b0, scale};
    assign ms_req_s  = {4'b0, req_s_base} * {8'b0, scale};
    assign ms_req_fr = {4'b0, req_fr_base} * {8'b0, scale};

    assign stock_warn = (old_f < ms_req_f) || (old_b < ms_req_b) || (old_m < ms_req_m) || (old_s < ms_req_s) || (old_fr < ms_req_fr);

    // 完全對齊 Golden Pattern 的 Abort 邏輯
    assign early_term = (date_warn && (act != Check_Valid_Date)) ||
                        (act == Make_and_Sell && (old_staff == 0 || stock_warn)) ||
                        (act == Restock       && r_bal_warn) ||
                        (act == Hire_Staff    && h_bal_warn) ||
                        (act == Pay_Day       && old_staff == 0);

    logic [31:0] ms_lvl_sq_div_200;
    logic [31:0] ms_price;
    logic [31:0] ms_earn;
    logic [31:0] ms_bal_tmp;
    
    assign ms_lvl_sq_div_200 = ({25'b0, level} * {25'b0, level}) / 32'd200;
    assign ms_price   = {26'b0, p_base_div_10} * {27'b0, lvl_factor} + ms_lvl_sq_div_200;
    assign ms_earn    = ms_price * {28'b0, scale};
    assign ms_bal_tmp = calc_bal + ms_earn;

    logic [12:0] ms_sales_tmp;
    logic [12:0] ms_sat_sales;
    logic [7:0]  lvl_threshold;
    logic        lvl_up_flag;
    
    assign ms_sales_tmp = {1'b0, old_sales} + {9'b0, scale};
    assign ms_sat_sales = (ms_sales_tmp > 13'd4095) ? 12'd4095 : ms_sales_tmp[11:0];
    assign lvl_threshold = (lvl_div_10 == 0) ? 8'd10 : (10 * lvl_div_10);
    assign lvl_up_flag   = (old_level < 8'd100) && (ms_sat_sales >= {4'b0, lvl_threshold});

    // ----------------------------------------------------
    //  Output / Update Logic
    // ----------------------------------------------------
    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;

    always_comb begin
        n_f = old_f; n_b = old_b; n_m = old_m; n_s = old_s; n_fr = old_fr;
        n_sales = old_sales; n_staff = old_staff; n_level = old_level; n_bal = old_bal;
        n_month = old_mon; n_day = old_day;

        warn_out = 3'b000;
        complete_out = 1'b0;

        if (act == Check_Valid_Date) begin
            n_month = {4'b0, in_m};
            n_day   = {3'b0, in_d};
            if (date_warn) warn_out = 3'b001;
            else           complete_out = 1'b1;
        end else begin
            if (!date_warn) begin
                n_month = {4'b0, in_m};
                n_day   = {3'b0, in_d};
            end

            if (date_warn) begin
                warn_out = 3'b001;
            end else begin
                case(act)
                    Make_and_Sell: begin
                        if (old_staff == 0)      warn_out = 3'b010;
                        else if (stock_warn)     warn_out = 3'b011;
                        else begin
                            complete_out = 1'b1;
                            n_f  = old_f - ms_req_f;
                            n_b  = old_b - ms_req_b;
                            n_m  = old_m - ms_req_m;
                            n_s  = old_s - ms_req_s;
                            n_fr = old_fr - ms_req_fr;
                            n_bal = (ms_bal_tmp > 32'd16777215) ? 24'd16777215 : ms_bal_tmp[23:0];
                            n_sales = lvl_up_flag ? (ms_sat_sales - {4'b0, lvl_threshold}) : ms_sat_sales;
                            n_level = lvl_up_flag ? (old_level + 8'd1) : old_level;
                        end
                    end
                    Restock: begin
                        if (r_bal_warn)          warn_out = 3'b100;
                        else if (restock_warn)   warn_out = 3'b101;
                        else                     complete_out = 1'b1;

                        if (!r_bal_warn) begin 
                            n_f  = old_f + a_f;
                            n_b  = old_b + a_b;
                            n_m  = old_m + a_m;
                            n_s  = old_s + a_s;
                            n_fr = old_fr + a_fr;
                            n_bal = calc_bal - r_total_cost;
                        end
                    end
                    Hire_Staff: begin
                        if (h_bal_warn)          warn_out = 3'b100;
                        else if (staff_warn)     warn_out = 3'b110;
                        else                     complete_out = 1'b1;

                        if (!h_bal_warn) begin 
                            n_staff = old_staff + {1'b0, a_staff};
                            n_bal   = calc_bal - h_total_cost;
                        end
                    end
                    Pay_Day: begin
                        if (old_staff == 0)      warn_out = 3'b010;
                        else if (p_bal_warn)     warn_out = 3'b100;
                        else                     complete_out = 1'b1;

                        if (old_staff != 0) begin
                            if (p_bal_warn) begin
                                n_level = (old_level < 8'd10) ? 8'd0 : (old_level - 8'd10);
                                n_staff = (old_staff >> 1 == 0) ? 8'd1 : (old_staff >> 1);
                                n_sales = 12'd0;
                            end else begin
                                n_bal = calc_bal - p_total_salary;
                            end
                        end
                    end
                    default: ;
                endcase
            end
        end
    end

    assign d_new[63:52]   = n_f;
    assign d_new[51:40]   = n_b;
    assign d_new[39:32]   = n_month;
    assign d_new[31:20]   = n_m;
    assign d_new[19:8]    = n_s;
    assign d_new[7:0]     = n_day;
    assign d_new[127:116] = n_fr;
    assign d_new[115:104] = n_sales;
    assign d_new[103:96]  = n_staff;
    
    assign d_new[95:72]   = n_bal;
    assign d_new[71:64]   = n_level;

endmodule