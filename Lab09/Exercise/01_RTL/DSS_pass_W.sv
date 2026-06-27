//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//      Date        : 2026/5
//      Version     : v10.4 (The Final "Foolproof" Architecture)
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

    // Datapath Registers (No Reset to save Area)
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
    
    // Control Registers (Requires strict Reset)
    logic [2:0]  res_idx;
    logic [3:0]  input_cnt;

    logic [3:0]  inputs_needed;
    
    logic         read_req;
    logic [16:0]  read_addr;
    logic         read_done;
    logic [63:0]  read_data;
    
    logic         write_req;
    logic [16:0]  write_addr;
    logic [63:0]  write_data;
    logic         write_done;

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
                          inf.date_valid |
                          inf.staff_valid | inf.data_no_valid | inf.restock_valid;

    // Control Path: FSM & Counters
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
            
            // [FIX 4]: Early Termination Bypass
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

    // Datapath: Input Capture & Pipeline
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

    // Output Registers (Strictly With Reset)
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

    assign read_req   = (state == S_RD_REQ_0) ||
                        (state == S_RD_REQ_1);
    assign read_addr  = (state == S_RD_REQ_0 || state == S_RD_WAIT_0) ?
                        (17'h10000 + {9'b0, in_data_no} * 16) : (17'h10000 + {9'b0, in_data_no} * 16 + 8);
                        
    assign write_req  = (state == S_WR_REQ_0) || (state == S_WR_REQ_1);
    assign write_addr = (state == S_WR_REQ_0 || state == S_WR_WAIT_0) ?
                        (17'h10000 + {9'b0, in_data_no} * 16) : (17'h10000 + {9'b0, in_data_no} * 16 + 8);
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

    // [FIX 1]: Data Isolation Masking to pass initial PATTERN check
    assign inf.AR_VALID = (r_state == R_ADDR);
    assign inf.AR_ADDR  = (inf.AR_VALID) ? read_addr : 17'd0;
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

    // [FIX 1]: Data Isolation Masking to pass initial PATTERN check
    assign inf.AW_VALID = (w_state == W_REQ && !aw_done);
    assign inf.AW_ADDR  = (inf.AW_VALID) ? write_addr : 17'd0;
    
    assign inf.W_VALID  = (w_state == W_REQ && !w_done_reg);
    assign inf.W_DATA   = (inf.W_VALID) ? write_data : 64'd0;
    
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

    // [FIX 3]: Corrected Memory Mapping according to TA QA
    assign old_f     = d_old[63:52];
    assign old_b     = d_old[51:40];
    assign old_mon   = d_old[39:32];
    assign old_m     = d_old[31:20];
    assign old_s     = d_old[19:8];
    assign old_day   = d_old[7:0];
    
    assign old_fr    = d_old[127:116]; 
    assign old_sales = d_old[115:104];
    assign old_staff = d_old[103:96];
    assign old_bal   = d_old[95:72];  // Balance is 24-bits directly above Level
    assign old_level = d_old[71:64];  // Level is the lowest 8-bits

    logic [6:0] level;
    logic [3:0] lvl_div_10;
    logic [4:0] lvl_factor;
    logic [5:0] lvl_sq_div_200;
    
    assign level          = old_level[6:0];
    assign lvl_div_10     = level / 10; 
    assign lvl_factor     = 5'd10 + lvl_div_10;
    assign lvl_sq_div_200 = (level * level) / 200;

    logic [7:0]  req_f_base, req_b_base, req_m_base, req_s_base, req_fr_base;
    logic [5:0]  p_base_div_10;
    logic [3:0]  scale;
    
    logic [11:0] ms_req_f, ms_req_b, ms_req_m, ms_req_s, ms_req_fr;
    logic        stock_warn;
    
    logic [10:0] price;
    logic [13:0] earn;
    logic [24:0] ms_bal_tmp;
    logic [11:0] ms_sales_tmp;
    logic [11:0] ms_sat_sales;
    logic [7:0]  lvl_threshold;
    logic        lvl_up_flag;

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

    // [FIX 2]: Explicit Padding to prevent implicit truncation
    assign ms_req_f  = {4'b0, req_f_base} * {8'b0, scale};
    assign ms_req_b  = {4'b0, req_b_base} * {8'b0, scale};
    assign ms_req_m  = {4'b0, req_m_base} * {8'b0, scale};
    assign ms_req_s  = {4'b0, req_s_base} * {8'b0, scale};
    assign ms_req_fr = {4'b0, req_fr_base} * {8'b0, scale};

    assign stock_warn = (old_f < ms_req_f) || (old_b < ms_req_b) || 
                        (old_m < ms_req_m) || (old_s < ms_req_s) || (old_fr < ms_req_fr);
                        
    assign price = p_base_div_10 * lvl_factor + lvl_sq_div_200;
    assign earn  = {3'b0, price} * {10'b0, scale};
    assign ms_bal_tmp = old_bal + earn;

    assign ms_sales_tmp = old_sales + {8'b0, scale};
    assign ms_sat_sales = (ms_sales_tmp > 12'd4095) ? 12'd4095 : ms_sales_tmp;

    assign lvl_threshold = (lvl_div_10 == 0) ? 8'd10 : (10 * lvl_div_10);
    assign lvl_up_flag   = (old_level < 8'd100) && (ms_sat_sales >= {4'b0, lvl_threshold});

    logic [5:0]  cost_f, cost_m, cost_s;
    logic [7:0]  cost_b, cost_fr;
    logic [19:0] req_cost_r;
    logic        r_bal_warn;
    
    logic [12:0] t_f, t_b, t_m, t_s, t_fr;
    logic        restock_warn;
    
    logic [11:0] a_f, a_b, a_m, a_s, a_fr;
    logic [19:0] act_cost_r;

    assign cost_f  = (3 * lvl_factor) >> 1;
    assign cost_b  = 6 * lvl_factor;        
    assign cost_m  = (5 * lvl_factor) >> 1;
    assign cost_s  = lvl_factor;            
    assign cost_fr = 8 * lvl_factor;
    
    // [FIX 2]: Explicit Padding
    assign req_cost_r = {9'b0, in_res[0]} * {14'b0, cost_f} +
                        {9'b0, in_res[1]} * {12'b0, cost_b} +
                        {9'b0, in_res[2]} * {14'b0, cost_m} +
                        {9'b0, in_res[3]} * {14'b0, cost_s} +
                        {9'b0, in_res[4]} * {12'b0, cost_fr};
                        
    assign r_bal_warn = (old_bal < req_cost_r);

    assign t_f  = old_f + in_res[0];
    assign t_b  = old_b + in_res[1];
    assign t_m  = old_m + in_res[2];
    assign t_s  = old_s + in_res[3];
    assign t_fr = old_fr + in_res[4];
    
    assign restock_warn = (t_f > 13'd4095) || (t_b > 13'd4095) || (t_m > 13'd4095) || (t_s > 13'd4095) ||
                          (t_fr > 13'd4095);

    assign a_f  = (t_f > 13'd4095) ? (12'd4095 - old_f) : {1'b0, in_res[0]};
    assign a_b  = (t_b > 13'd4095) ? (12'd4095 - old_b) : {1'b0, in_res[1]};
    assign a_m  = (t_m > 13'd4095) ? (12'd4095 - old_m) : {1'b0, in_res[2]};
    assign a_s  = (t_s > 13'd4095) ? (12'd4095 - old_s) : {1'b0, in_res[3]};
    assign a_fr = (t_fr > 13'd4095) ? (12'd4095 - old_fr) : {1'b0, in_res[4]};
    
    // [FIX 2]: Explicit Padding
    assign act_cost_r = {8'b0, a_f} * {14'b0, cost_f} +
                        {8'b0, a_b} * {12'b0, cost_b} +
                        {8'b0, a_m} * {14'b0, cost_m} +
                        {8'b0, a_s} * {14'b0, cost_s} +
                        {8'b0, a_fr} * {12'b0, cost_fr};
    
    logic [13:0] cost_per_staff;
    logic [19:0] req_hire_cost;
    logic        h_bal_warn;
    logic [7:0]  t_staff;
    logic        staff_warn;
    logic [6:0]  a_staff;
    logic [19:0] act_hire_cost;
    
    assign cost_per_staff = 14'd2000 + {7'b0, level} * 14'd100 + {10'b0, lvl_div_10} * 14'd200;
    assign req_hire_cost  = {15'b0, in_hire} * {6'b0, cost_per_staff};
    assign h_bal_warn     = (old_bal < {4'b0, req_hire_cost});

    assign t_staff = old_staff + {3'b0, in_hire};
    assign staff_warn = (t_staff > 8'd100);
    assign a_staff = (t_staff > 8'd100) ? (7'd100 - old_staff[6:0]) : {2'b0, in_hire};
    assign act_hire_cost = {13'b0, a_staff} * {6'b0, cost_per_staff};

    logic [15:0] salary_per_staff;
    logic [23:0] total_salary;
    logic        p_bal_warn;

    assign salary_per_staff = 16'd20000 + {9'b0, level} * 16'd200 + {12'b0, lvl_div_10} * 16'd1000;
    assign total_salary     = {16'b0, old_staff} * {8'b0, salary_per_staff};
    assign p_bal_warn       = (old_bal < total_salary);
    
    logic date_warn;
    assign date_warn = (in_m < old_mon) || ((in_m == old_mon) && (in_d < old_day));

    // [FIX 4]: Early Termination Protocol -> Abort AXI Write if Fatal Warning occurs
    assign early_term = 
        (date_warn && act != Check_Valid_Date) ||
        (!date_warn && act == Make_and_Sell && (old_staff == 0 || stock_warn)) ||
        (!date_warn && act == Restock       && r_bal_warn) ||
        (!date_warn && act == Hire_Staff    && h_bal_warn) ||
        (!date_warn && act == Pay_Day       && old_staff == 0);

    logic [11:0] n_f, n_b, n_m, n_s, n_fr, n_sales;
    logic [7:0]  n_month, n_day, n_staff, n_level;
    logic [23:0] n_bal;
    
    always_comb begin
        n_f = old_f; n_b = old_b; n_m = old_m;
        n_s = old_s; n_fr = old_fr;
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
                            n_bal = (ms_bal_tmp > 25'd16777215) ? 24'd16777215 : ms_bal_tmp[23:0];
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
                            n_bal = old_bal - {4'b0, act_cost_r};
                        end
                    end
                    Hire_Staff: begin
                        if (h_bal_warn)          warn_out = 3'b100;
                        else if (staff_warn)     warn_out = 3'b110;
                        else                     complete_out = 1'b1;
                        
                        if (!h_bal_warn) begin 
                            n_staff = old_staff + {1'b0, a_staff};
                            n_bal   = old_bal - {4'b0, act_hire_cost};
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
                                n_bal = old_bal - total_salary;
                            end
                        end
                    end
                    default: ;
                endcase
            end
        end
    end

    // [FIX 3]: Write back matching the correct QA document order
    assign d_new[63:52]   = n_f;
    assign d_new[51:40]   = n_b;
    assign d_new[39:32]   = n_month;
    assign d_new[31:20]   = n_m;
    assign d_new[19:8]    = n_s;
    assign d_new[7:0]     = n_day;
    assign d_new[127:116] = n_fr;
    assign d_new[115:104] = n_sales;
    assign d_new[103:96]  = n_staff;
    assign d_new[95:72]   = n_bal;    // Balance
    assign d_new[71:64]   = n_level;  // Level

endmodule