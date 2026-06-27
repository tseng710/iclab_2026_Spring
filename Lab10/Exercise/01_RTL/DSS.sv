//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module DSS (
    input  logic       clk, 
    INF.DSS_inf        inf
);
    import usertype::*;

    typedef enum logic [3:0] {
        S_IDLE        = 4'd0,
        S_READ_AR0    = 4'd1,
        S_READ_R0     = 4'd2,
        S_READ_AR1    = 4'd3,
        S_READ_R1     = 4'd4,
        S_WAIT_INPUTS = 4'd5,
        S_PROCESS0    = 4'd6,
        S_PROCESS1    = 4'd7,
        S_PROCESS2    = 4'd8,
        S_PROCESS3    = 4'd9,
        S_WRITE_AWW0  = 4'd10,
        S_WRITE_B0    = 4'd11,
        S_WRITE_AWW1  = 4'd12,
        S_WRITE_B1    = 4'd13
    } state_t;

    state_t state;
    state_t n_state;

    Action               in_act;
    Dessert_Type         in_type;
    Order_Mode           in_mode;
    logic [7:0]          in_data_no;
    logic [6:0]          in_hire;     
    logic [3:0]          in_m;
    logic [4:0]          in_d;
    logic [59:0]         in_res_buf;
    logic                inputs_ready;

    logic [127:0]        d_old;
    logic [127:0]        d_new;
    logic [2:0]          dp_warn;
    logic                dp_comp;
    
    logic                req_w0;
    logic                req_w1;
    logic                early_term;
    logic                is_out_cycle;

    logic                aw_done;
    logic                w_done;
    logic                aw_fire;
    logic                w_fire;
    
    logic [7:0]          current_data_no;
    logic [16:0]         base_addr;
    logic [16:0]         base_addr_offset;
    
    logic [3:0]          dram_mon;
    logic [4:0]          dram_day;
    logic                early_date_warn;

    assign current_data_no  = (inf.data_no_valid) ? inf.D[7:0] : in_data_no;
    assign base_addr        = {1'b1, 4'b0000, current_data_no, 4'b0000};
    assign base_addr_offset = {1'b1, 4'b0000, current_data_no, 4'b1000};

    assign aw_fire          = (inf.AW_VALID && inf.AW_READY) || aw_done;
    assign w_fire           = (inf.W_VALID  && inf.W_READY)  || w_done;

    assign dram_mon         = inf.R_DATA[35:32];
    assign dram_day         = inf.R_DATA[4:0];
    assign early_date_warn  = ({in_m, in_d} < {dram_mon, dram_day});

    assign is_out_cycle     = (state == S_PROCESS3 && early_term) ||
                              (state == S_WRITE_B0 && inf.B_VALID && !req_w1) ||
                              (state == S_WRITE_B1 && inf.B_VALID);

    DSS_INPUT_BUFFER u_input_buffer (
        .clk              (clk),
        .rst_n            (inf.rst_n),
        .inf              (inf),
        .is_out_cycle     (is_out_cycle),
        .out_act          (in_act),
        .out_type         (in_type),
        .out_mode         (in_mode),
        .out_data_no      (in_data_no),
        .out_hire         (in_hire),
        .out_m            (in_m),
        .out_d            (in_d),
        .out_res_buf      (in_res_buf),
        .inputs_ready     (inputs_ready)
    );

    DSS_EXECUTION_UNIT u_execution_unit (
        .clk              (clk),
        .rst_n            (inf.rst_n),
        .state            (state),
        .act              (in_act),
        .type_reg         (in_type),
        .mode_reg         (in_mode),
        .in_m             (in_m),
        .in_d             (in_d),
        .in_hire          (in_hire),
        .in_res_buf       (in_res_buf),
        .d_old            (d_old),
        .d_new            (d_new),
        .warn_out         (dp_warn),
        .comp_out         (dp_comp),
        .req_w0           (req_w0),
        .req_w1           (req_w1),
        .early_term       (early_term)
    );

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
            S_IDLE: begin
                if (inf.data_no_valid) begin
                    n_state = S_READ_AR0;
                end
            end
            
            S_READ_AR0: begin
                if (inf.AR_READY) begin
                    n_state = S_READ_R0;
                end
            end
            
            S_READ_R0: begin
                if (inf.R_VALID) begin
                    if (in_act == Check_Valid_Date || early_date_warn) begin
                        if (inputs_ready) begin
                            n_state = S_PROCESS0;
                        end else begin
                            n_state = S_WAIT_INPUTS;
                        end
                    end else begin
                        n_state = S_READ_AR1;
                    end
                end
            end
            
            S_READ_AR1: begin
                if (inf.AR_READY) begin
                    n_state = S_READ_R1;
                end
            end
            
            S_READ_R1: begin
                if (inf.R_VALID) begin
                    if (inputs_ready) begin
                        n_state = S_PROCESS0;
                    end else begin
                        n_state = S_WAIT_INPUTS;
                    end
                end
            end
            
            S_WAIT_INPUTS: begin
                if (inputs_ready) begin
                    n_state = S_PROCESS0;
                end
            end
            
            S_PROCESS0: begin
                n_state = S_PROCESS1;
            end
            
            S_PROCESS1: begin
                n_state = S_PROCESS2; 
            end
            
            S_PROCESS2: begin
                n_state = S_PROCESS3; 
            end
            
            S_PROCESS3: begin
                if (early_term) begin
                    n_state = S_IDLE;
                end else if (req_w0) begin
                    n_state = S_WRITE_AWW0; 
                end else if (req_w1) begin
                    n_state = S_WRITE_AWW1;
                end else begin
                    n_state = S_IDLE;
                end
            end
            
            S_WRITE_AWW0: begin
                if (aw_fire && w_fire) begin
                    n_state = S_WRITE_B0;
                end
            end
            
            S_WRITE_B0: begin
                if (inf.B_VALID) begin
                    if (req_w1) begin
                        n_state = S_WRITE_AWW1;
                    end else begin
                        n_state = S_IDLE;
                    end
                end
            end
            
            S_WRITE_AWW1: begin
                if (aw_fire && w_fire) begin
                    n_state = S_WRITE_B1;
                end
            end
            
            S_WRITE_B1: begin
                if (inf.B_VALID) begin
                    n_state = S_IDLE;
                end
            end
            
            default: begin
                n_state = S_IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            d_old <= 128'd0;
        end else begin
            if (state == S_READ_R0 && inf.R_VALID) begin
                d_old[63:0] <= inf.R_DATA;
            end
            if (state == S_READ_R1 && inf.R_VALID) begin
                d_old[127:64] <= inf.R_DATA;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            aw_done <= 1'b0;
            w_done  <= 1'b0;
        end else begin
            if (state == S_WRITE_AWW0 || state == S_WRITE_AWW1) begin
                if (inf.AW_VALID && inf.AW_READY) begin
                    aw_done <= 1'b1;
                end
                if (inf.W_VALID  && inf.W_READY) begin
                    w_done  <= 1'b1;
                end
            end else begin
                aw_done <= 1'b0;
                w_done  <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge inf.rst_n) begin
        if (!inf.rst_n) begin
            inf.AR_VALID  <= 1'b0;
            inf.AR_ADDR   <= 17'd0;
            inf.R_READY   <= 1'b0;
            inf.AW_VALID  <= 1'b0;
            inf.AW_ADDR   <= 17'd0;
            inf.W_VALID   <= 1'b0;
            inf.W_DATA    <= 64'd0;
            inf.B_READY   <= 1'b0;
            inf.out_valid <= 1'b0;
            inf.warn_msg  <= No_Warn;
            inf.complete  <= 1'b0;
        end else begin
            if ((state == S_IDLE && n_state == S_READ_AR0) || 
                (state == S_READ_R0 && n_state == S_READ_AR1)) begin
                inf.AR_VALID <= 1'b1;
                if (n_state == S_READ_AR0) begin
                    inf.AR_ADDR <= base_addr;
                end else begin
                    inf.AR_ADDR <= base_addr_offset;
                end
            end else if (inf.AR_VALID && inf.AR_READY) begin
                inf.AR_VALID <= 1'b0;
            end

            if ((state == S_READ_AR0 && n_state == S_READ_R0) || 
                (state == S_READ_AR1 && n_state == S_READ_R1)) begin
                inf.R_READY <= 1'b1;
            end else if (inf.R_VALID && inf.R_READY) begin
                inf.R_READY <= 1'b0;
            end

            if ((state == S_PROCESS3 && n_state == S_WRITE_AWW0) || 
                (state == S_WRITE_B0 && n_state == S_WRITE_AWW1)) begin
                inf.AW_VALID <= 1'b1;
                if (n_state == S_WRITE_AWW0) begin
                    inf.AW_ADDR <= base_addr;
                end else begin
                    inf.AW_ADDR <= base_addr_offset;
                end
            end else if (inf.AW_VALID && inf.AW_READY) begin
                inf.AW_VALID <= 1'b0;
            end

            if ((state == S_PROCESS3 && n_state == S_WRITE_AWW0) || 
                (state == S_WRITE_B0 && n_state == S_WRITE_AWW1)) begin
                inf.W_VALID <= 1'b1;
                if (n_state == S_WRITE_AWW0) begin
                    inf.W_DATA <= d_new[63:0];
                end else begin
                    inf.W_DATA <= d_new[127:64];
                end
            end else if (inf.W_VALID && inf.W_READY) begin
                inf.W_VALID <= 1'b0;
            end

            if ((state == S_WRITE_AWW0 && n_state == S_WRITE_B0) || 
                (state == S_WRITE_AWW1 && n_state == S_WRITE_B1)) begin
                inf.B_READY <= 1'b1;
            end else if (inf.B_VALID && inf.B_READY) begin
                inf.B_READY <= 1'b0;
            end

            if (is_out_cycle) begin
                inf.out_valid <= 1'b1;
                inf.warn_msg  <= Warn_Msg'(dp_warn);
                inf.complete  <= dp_comp;
            end else begin
                inf.out_valid <= 1'b0;
                inf.warn_msg  <= No_Warn;
                inf.complete  <= 1'b0;
            end
        end
    end
endmodule


module DSS_INPUT_BUFFER (
    input  logic                  clk,
    input  logic                  rst_n,
    INF.DSS_inf                   inf,
    input  logic                  is_out_cycle,
    output usertype::Action       out_act,
    output usertype::Dessert_Type out_type,
    output usertype::Order_Mode   out_mode,
    output logic [7:0]            out_data_no,
    output logic [6:0]            out_hire,
    output logic [3:0]            out_m,
    output logic [4:0]            out_d,
    output logic [59:0]           out_res_buf,
    output logic                  inputs_ready
);
    import usertype::*;

    logic [3:0] input_cnt;
    logic [3:0] inputs_needed;
    logic       any_valid_in;

    assign any_valid_in = inf.sel_action_valid | 
                          inf.type_valid       | 
                          inf.mode_valid       |
                          inf.staff_valid      | 
                          inf.date_valid       | 
                          inf.data_no_valid    | 
                          inf.restock_valid;

    always_comb begin
        if (input_cnt == inputs_needed) begin
            inputs_ready = 1'b1;
        end else if ((input_cnt == inputs_needed - 4'd1) && any_valid_in) begin
            inputs_ready = 1'b1;
        end else begin
            inputs_ready = 1'b0;
        end
    end

    always_comb begin
        case(out_act)
            Make_and_Sell: begin
                inputs_needed = 4'd5;
            end
            Restock: begin
                inputs_needed = 4'd8;
            end
            Hire_Staff: begin
                inputs_needed = 4'd4;
            end
            Pay_Day: begin
                inputs_needed = 4'd3;
            end
            Check_Valid_Date: begin
                inputs_needed = 4'd3;
            end
            default: begin
                inputs_needed = 4'd15;
            end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_act     <= Make_and_Sell;
            out_type    <= Cookie;
            out_mode    <= Single;
            out_data_no <= 8'd0;
            out_hire    <= 7'd0;
            out_m       <= 4'd0;
            out_d       <= 5'd0;
            out_res_buf <= 60'd0;
            input_cnt   <= 4'd0;
        end else begin
            if (inf.sel_action_valid) begin
                out_act <= Action'(inf.D[2:0]);
            end
            
            if (inf.type_valid) begin
                out_type <= Dessert_Type'(inf.D[2:0]);
            end
            
            if (inf.mode_valid) begin
                out_mode <= Order_Mode'(inf.D[1:0]);
            end
            
            if (inf.data_no_valid) begin
                out_data_no <= inf.D[7:0];
            end
            
            if (inf.staff_valid) begin
                out_hire <= inf.D[6:0];
            end
            
            if (inf.date_valid) begin
                out_m <= inf.D[8:5];
                out_d <= inf.D[4:0];
            end
            
            if (inf.restock_valid && out_act == Restock) begin 
                out_res_buf <= {out_res_buf[47:0], inf.D[11:0]};
            end

            if (is_out_cycle) begin
                input_cnt <= 4'd0;
            end else if (any_valid_in) begin
                input_cnt <= input_cnt + 4'd1;
            end
        end
    end
endmodule


module DSS_EXECUTION_UNIT (
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

    logic [11:0] old_f;
    logic [11:0] old_b;
    logic [11:0] old_m;
    logic [11:0] old_s;
    logic [11:0] old_fr;
    logic [11:0] old_sales;
    logic [7:0]  old_mon;
    logic [7:0]  old_day;
    logic [7:0]  old_staff;
    logic [7:0]  old_level;
    logic [23:0] old_bal;

    assign old_fr    = d_old[127:116];
    assign old_sales = d_old[115:104];
    assign old_staff = d_old[103:96];
    assign old_bal   = d_old[95:72];
    assign old_level = d_old[71:64];

    assign old_f     = d_old[63:52];
    assign old_b     = d_old[51:40];
    assign old_mon   = d_old[39:32];
    assign old_m     = d_old[31:20];
    assign old_s     = d_old[19:8];
    assign old_day   = d_old[7:0];

    logic [4:0]  rc_f;  
    logic [7:0]  rc_b; 
    logic [5:0]  rc_m; 
    logic [4:0]  rc_s; 
    logic [7:0]  rc_fr;
    logic [13:0] h_unit_cost; 
    logic [15:0] p_unit_cost;
    logic [11:0] req_f;
    logic [11:0] req_b;
    logic [11:0] req_m;
    logic [11:0] req_s;
    logic [11:0] req_fr;
    logic [3:0]  scale_val;
    logic [13:0] ms_earn;
    logic [7:0]  lvl_threshold;

    DSS_LUT_ENGINE b_lut (
        .level        (old_level),
        .dessert_type (type_reg),
        .order_mode   (mode_reg),
        .threshold    (lvl_threshold),
        .rc_f         (rc_f), 
        .rc_b         (rc_b), 
        .rc_m         (rc_m), 
        .rc_s         (rc_s), 
        .rc_fr        (rc_fr),
        .h_cost       (h_unit_cost), 
        .p_cost       (p_unit_cost),
        .req_f        (req_f), 
        .req_b        (req_b), 
        .req_m        (req_m), 
        .req_s        (req_s), 
        .req_fr       (req_fr),
        .scale        (scale_val), 
        .ms_earn      (ms_earn)
    );

    logic [11:0] in_f;
    logic [11:0] in_b;
    logic [11:0] in_res_m;
    logic [11:0] in_s;
    logic [11:0] in_fr;
    
    assign in_f     = in_res_buf[59:48];
    assign in_b     = in_res_buf[47:36];
    assign in_res_m = in_res_buf[35:24];
    assign in_s     = in_res_buf[23:12];
    assign in_fr    = in_res_buf[11:0];

    logic        date_warn;
    assign date_warn = ({in_m, in_d} < {old_mon[3:0], old_day[4:0]});

    logic [11:0] op_f;
    logic [11:0] op_b;
    logic [11:0] op_m;
    logic [11:0] op_s;
    logic [11:0] op_fr;

    always_comb begin
        if (act == Make_and_Sell) begin
            op_f  = req_f;
            op_b  = req_b;
            op_m  = req_m;
            op_s  = req_s;
            op_fr = req_fr;
        end else begin
            op_f  = in_f;
            op_b  = in_b;
            op_m  = in_res_m;
            op_s  = in_s;
            op_fr = in_fr;
        end
    end

    logic [12:0] op_f_signed;
    logic [12:0] op_b_signed;
    logic [12:0] op_m_signed;
    logic [12:0] op_s_signed;
    logic [12:0] op_fr_signed;

    always_comb begin
        if (act == Make_and_Sell) begin
            op_f_signed  = (~{1'b0, op_f} + 13'b1);
            op_b_signed  = (~{1'b0, op_b} + 13'b1);
            op_m_signed  = (~{1'b0, op_m} + 13'b1);
            op_s_signed  = (~{1'b0, op_s} + 13'b1);
            op_fr_signed = (~{1'b0, op_fr} + 13'b1);
        end else begin
            op_f_signed  = {1'b0, op_f};
            op_b_signed  = {1'b0, op_b};
            op_m_signed  = {1'b0, op_m};
            op_s_signed  = {1'b0, op_s};
            op_fr_signed = {1'b0, op_fr};
        end
    end

    logic [12:0] res_f;
    logic [12:0] res_b;
    logic [12:0] res_m;
    logic [12:0] res_s;
    logic [12:0] res_fr;

    assign res_f  = {1'b0, old_f}  + op_f_signed;
    assign res_b  = {1'b0, old_b}  + op_b_signed;
    assign res_m  = {1'b0, old_m}  + op_m_signed;
    assign res_s  = {1'b0, old_s}  + op_s_signed;
    assign res_fr = {1'b0, old_fr} + op_fr_signed;

    logic [11:0] a_f;
    logic [11:0] a_b;
    logic [11:0] a_m;
    logic [11:0] a_s;
    logic [11:0] a_fr;

    always_comb begin
        a_f  = (res_f[12]  && act != Make_and_Sell) ? ~old_f  : in_f;
        a_b  = (res_b[12]  && act != Make_and_Sell) ? ~old_b  : in_b;
        a_m  = (res_m[12]  && act != Make_and_Sell) ? ~old_m  : in_res_m;
        a_s  = (res_s[12]  && act != Make_and_Sell) ? ~old_s  : in_s;
        a_fr = (res_fr[12] && act != Make_and_Sell) ? ~old_fr : in_fr;
    end

    logic [8:0]  res_staff;
    logic [6:0]  a_staff;
    
    assign res_staff = {1'b0, old_staff} + {2'd0, in_hire};
    assign a_staff   = (res_staff > 9'd100) ? (7'd100 - old_staff[6:0]) : in_hire;

    logic [12:0] sales_add;
    logic [12:0] sales_rem;
    
    assign sales_add = {1'b0, old_sales} + {9'd0, scale_val};
    assign sales_rem = sales_add - {5'd0, lvl_threshold};

    logic [11:0] p1_a_f;
    logic [11:0] p1_a_b;
    logic [11:0] p1_a_m;
    logic [11:0] p1_a_s;
    logic [11:0] p1_a_fr;
    logic [4:0]  p1_rc_f; 
    logic [7:0]  p1_rc_b; 
    logic [5:0]  p1_rc_m; 
    logic [4:0]  p1_rc_s; 
    logic [7:0]  p1_rc_fr;
    logic [12:0] p1_res_f;
    logic [12:0] p1_res_b;
    logic [12:0] p1_res_m;
    logic [12:0] p1_res_s;
    logic [12:0] p1_res_fr;
    logic [13:0] p1_ms_earn; 
    logic [7:0]  p1_staff_op1; 
    logic [15:0] p1_staff_op2; 
    logic [8:0]  p1_res_staff;
    logic [12:0] p1_sales_add;
    logic [12:0] p1_sales_rem; 
    logic        p1_date_warn;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p1_a_f       <= 12'd0; 
            p1_a_b       <= 12'd0; 
            p1_a_m       <= 12'd0; 
            p1_a_s       <= 12'd0; 
            p1_a_fr      <= 12'd0;
            p1_rc_f      <= 5'd0; 
            p1_rc_b      <= 8'd0; 
            p1_rc_m      <= 6'd0; 
            p1_rc_s      <= 5'd0; 
            p1_rc_fr     <= 8'd0;
            p1_res_f     <= 13'd0; 
            p1_res_b     <= 13'd0; 
            p1_res_m     <= 13'd0; 
            p1_res_s     <= 13'd0; 
            p1_res_fr    <= 13'd0;
            p1_ms_earn   <= 14'd0; 
            p1_staff_op1 <= 8'd0; 
            p1_staff_op2 <= 16'd0; 
            p1_res_staff <= 9'd0;
            p1_sales_add <= 13'd0; 
            p1_sales_rem <= 13'd0; 
            p1_date_warn <= 1'b0;
        end else if (state == 4'd6) begin 
            p1_a_f       <= a_f; 
            p1_a_b       <= a_b; 
            p1_a_m       <= a_m; 
            p1_a_s       <= a_s; 
            p1_a_fr      <= a_fr;
            p1_rc_f      <= rc_f; 
            p1_rc_b      <= rc_b; 
            p1_rc_m      <= rc_m; 
            p1_rc_s      <= rc_s; 
            p1_rc_fr     <= rc_fr;
            p1_res_f     <= res_f; 
            p1_res_b     <= res_b; 
            p1_res_m     <= res_m; 
            p1_res_s     <= res_s; 
            p1_res_fr    <= res_fr;
            p1_ms_earn   <= ms_earn;
            
            if (act == Hire_Staff) begin
                p1_staff_op1 <= {1'b0, a_staff};
                p1_staff_op2 <= {2'd0, h_unit_cost};
            end else begin
                p1_staff_op1 <= old_staff;
                p1_staff_op2 <= p_unit_cost;
            end
            
            p1_res_staff <= res_staff; 
            p1_sales_add <= sales_add; 
            p1_sales_rem <= sales_rem; 
            p1_date_warn <= date_warn;
        end
    end

    logic [20:0] p2_cost_fb; 
    logic [18:0] p2_cost_ms; 
    logic [19:0] p2_cost_fr; 
    logic [23:0] p2_cost_staff;
    logic [12:0] p2_res_f;
    logic [12:0] p2_res_b;
    logic [12:0] p2_res_m;
    logic [12:0] p2_res_s;
    logic [12:0] p2_res_fr;
    logic [13:0] p2_ms_earn; 
    logic [8:0]  p2_res_staff; 
    logic [12:0] p2_sales_add;
    logic [12:0] p2_sales_rem; 
    logic        p2_date_warn;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p2_cost_fb    <= 21'd0; 
            p2_cost_ms    <= 19'd0; 
            p2_cost_fr    <= 20'd0; 
            p2_cost_staff <= 23'd0;
            p2_res_f      <= 13'd0; 
            p2_res_b      <= 13'd0; 
            p2_res_m      <= 13'd0; 
            p2_res_s      <= 13'd0; 
            p2_res_fr     <= 13'd0;
            p2_ms_earn    <= 14'd0; 
            p2_res_staff  <= 9'd0; 
            p2_sales_add  <= 13'd0; 
            p2_sales_rem  <= 13'd0; 
            p2_date_warn  <= 1'b0;
        end else if (state == 4'd7) begin 
            p2_cost_fb    <= ({5'd0, p1_a_f} * p1_rc_f) + ({1'd0, p1_a_b} * p1_rc_b);
            p2_cost_ms    <= ({1'd0, p1_a_m} * p1_rc_m) + ({2'd0, p1_a_s} * p1_rc_s);
            p2_cost_fr    <= (p1_a_fr * p1_rc_fr);
            p2_cost_staff <= p1_staff_op1 * p1_staff_op2;
            
            p2_res_f      <= p1_res_f; 
            p2_res_b      <= p1_res_b; 
            p2_res_m      <= p1_res_m; 
            p2_res_s      <= p1_res_s; 
            p2_res_fr     <= p1_res_fr;
            p2_ms_earn    <= p1_ms_earn; 
            p2_res_staff  <= p1_res_staff;
            p2_sales_add  <= p1_sales_add; 
            p2_sales_rem  <= p1_sales_rem; 
            p2_date_warn  <= p1_date_warn;
        end
    end

    logic [23:0] p3_bal_alu_op2;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p3_bal_alu_op2 <= 24'd0;
        end else if (state == 4'd8) begin 
            if (act == Make_and_Sell) begin
                p3_bal_alu_op2 <= {10'd0, p2_ms_earn};
            end else if (act == Restock) begin
                p3_bal_alu_op2 <= {2'd0, (p2_cost_fb + p2_cost_ms + p2_cost_fr)};
            end else begin
                p3_bal_alu_op2 <= p2_cost_staff;
            end
        end
    end

    logic [24:0] bal_alu_res;
    logic        bal_underflow;
    logic        bal_overflow;
    logic        stock_err;
    logic        staff_err;

    always_comb begin
        if (act == Make_and_Sell) begin
            bal_alu_res = ({1'b0, old_bal} + {1'b0, p3_bal_alu_op2});
        end else begin
            bal_alu_res = ({1'b0, old_bal} - {1'b0, p3_bal_alu_op2});
        end
    end

    assign bal_underflow = (act != Make_and_Sell) && bal_alu_res[24];
    assign bal_overflow  = (act == Make_and_Sell) && bal_alu_res[24];
    
    assign stock_err     = p2_res_f[12] | p2_res_b[12] | p2_res_m[12] | p2_res_s[12] | p2_res_fr[12];
    assign staff_err     = (p2_res_staff > 9'd100);

    assign req_w0        = 1'b1;
    assign req_w1        = (act != Check_Valid_Date) && !p2_date_warn;
    assign early_term    = p2_date_warn && (act != Check_Valid_Date);

    logic [11:0] n_f;
    logic [11:0] n_b;
    logic [11:0] n_m;
    logic [11:0] n_s;
    logic [11:0] n_fr;
    logic [11:0] n_sales;
    logic [7:0]  n_month;
    logic [7:0]  n_day;
    logic [7:0]  n_staff;
    logic [7:0]  n_level;
    logic [23:0] n_bal;

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
        
        warn_out  = 3'b000; 
        comp_out  = 1'b0;

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
                        n_f  = p2_res_f[11:0]; 
                        n_b  = p2_res_b[11:0]; 
                        n_m  = p2_res_m[11:0]; 
                        n_s  = p2_res_s[11:0]; 
                        n_fr = p2_res_fr[11:0];
                        
                        if (bal_overflow) begin
                            n_bal = 24'hFFFFFF;
                        end else begin
                            n_bal = bal_alu_res[23:0];
                        end
                        
                        if (old_level < 8'd100 && !p2_sales_rem[12]) begin
                            n_level = old_level + 8'd1;
                            n_sales = p2_sales_rem[11:0];
                        end else begin
                            if (p2_sales_add[12]) begin
                                n_sales = 12'hFFF;
                            end else begin
                                n_sales = p2_sales_add[11:0];
                            end
                        end
                    end
                end
                
                Restock: begin
                    if (bal_underflow) begin
                        warn_out = 3'b100;
                    end else if (stock_err) begin
                        warn_out = 3'b101;
                        n_f   = p2_res_f[12]  ? 12'hFFF : p2_res_f[11:0]; 
                        n_b   = p2_res_b[12]  ? 12'hFFF : p2_res_b[11:0]; 
                        n_m   = p2_res_m[12]  ? 12'hFFF : p2_res_m[11:0]; 
                        n_s   = p2_res_s[12]  ? 12'hFFF : p2_res_s[11:0]; 
                        n_fr  = p2_res_fr[12] ? 12'hFFF : p2_res_fr[11:0];
                        n_bal = bal_alu_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_f   = p2_res_f[11:0]; 
                        n_b   = p2_res_b[11:0]; 
                        n_m   = p2_res_m[11:0]; 
                        n_s   = p2_res_s[11:0]; 
                        n_fr  = p2_res_fr[11:0];
                        n_bal = bal_alu_res[23:0];
                    end
                end
                
                Hire_Staff: begin
                    if (bal_underflow) begin
                        warn_out = 3'b100;
                    end else if (staff_err) begin
                        warn_out = 3'b110; 
                        n_staff  = 8'd100;
                        n_bal    = bal_alu_res[23:0];
                    end else begin
                        comp_out = 1'b1;
                        n_staff  = p2_res_staff[7:0];
                        n_bal    = bal_alu_res[23:0];
                    end
                end
                
                Pay_Day: begin
                    if (old_staff == 8'd0) begin
                        warn_out = 3'b010;
                    end else if (bal_underflow) begin
                        warn_out = 3'b100;
                        if (old_level < 8'd10) begin
                            n_level = 8'd0;
                        end else begin
                            n_level = old_level - 8'd10;
                        end
                        
                        if (old_staff == 8'd1) begin
                            n_staff = 8'd1;
                        end else begin
                            n_staff = {1'b0, old_staff[7:1]};
                        end
                        n_sales  = 12'd0; 
                    end else begin
                        comp_out = 1'b1;
                        n_bal    = bal_alu_res[23:0];
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

module DSS_LUT_ENGINE (
    input  logic [7:0]            level,
    input  usertype::Dessert_Type dessert_type,
    input  usertype::Order_Mode   order_mode,
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

    logic [3:0]  k;
    logic [4:0]  lvl_factor;
    logic [5:0]  sq_div_200;
    logic [14:0] lvl_x_100;
    logic [11:0] k_x_200;
    logic [7:0]  r_f;
    logic [7:0]  r_b;
    logic [7:0]  r_m;
    logic [7:0]  r_s;
    logic [7:0]  r_fr;
    logic [5:0]  pb_div10;
    logic [10:0] ms_price;

    const logic [5:0] SQ_LUT [0:100] = '{
        6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  
        6'd0,  6'd0,  6'd0,  6'd0,  6'd0,  6'd1,  6'd1,  6'd1,  6'd1,  6'd1, 
        6'd2,  6'd2,  6'd2,  6'd2,  6'd2,  6'd3,  6'd3,  6'd3,  6'd3,  6'd4,  
        6'd4,  6'd4,  6'd5,  6'd5,  6'd5,  6'd6,  6'd6,  6'd6,  6'd7,  6'd7, 
        6'd8,  6'd8,  6'd8,  6'd9,  6'd9,  6'd10, 6'd10, 6'd11, 6'd11, 6'd12, 
        6'd12, 6'd13, 6'd13, 6'd14, 6'd14, 6'd15, 6'd15, 6'd16, 6'd16, 6'd17, 
        6'd18, 6'd18, 6'd19, 6'd19, 6'd20, 6'd21, 6'd21, 6'd22, 6'd23, 6'd23, 
        6'd24, 6'd25, 6'd25, 6'd26, 6'd27, 6'd28, 6'd28, 6'd29, 6'd30, 6'd31, 
        6'd32, 6'd32, 6'd33, 6'd34, 6'd35, 6'd36, 6'd36, 6'd37, 6'd38, 6'd39, 
        6'd40, 6'd41, 6'd42, 6'd43, 6'd44, 6'd45, 6'd46, 6'd47, 6'd48, 6'd49, 
        6'd50 
    };

    always_comb begin
        if (level >= 100) begin
            k = 4'd10;
        end else if (level >= 90) begin
            k = 4'd9;
        end else if (level >= 80) begin
            k = 4'd8;
        end else if (level >= 70) begin
            k = 4'd7;
        end else if (level >= 60) begin
            k = 4'd6;
        end else if (level >= 50) begin
            k = 4'd5;
        end else if (level >= 40) begin
            k = 4'd4;
        end else if (level >= 30) begin
            k = 4'd3;
        end else if (level >= 20) begin
            k = 4'd2;
        end else if (level >= 10) begin
            k = 4'd1;
        end else begin
            k = 4'd0;
        end
    end

    assign lvl_factor = 5'd10 + {1'b0, k};
    
    always_comb begin
        if (level > 100) begin
            sq_div_200 = SQ_LUT[8'd100];
        end else begin
            sq_div_200 = SQ_LUT[level];
        end
    end
    
    always_comb begin
        if (k == 0) begin
            threshold = 8'd10;
        end else begin
            threshold = {4'd0, k} * 8'd10;
        end
    end
    
    assign rc_f       = 5'd15 + {1'b0, k} + {2'b0, k[3:1]};
    assign rc_b       = ({3'd0, lvl_factor} << 2) + ({3'd0, lvl_factor} << 1);
    assign rc_m       = 6'd25 + {1'b0, k, 1'b0} + {3'b0, k[3:1]};
    assign rc_s       = {3'd0, lvl_factor};
    assign rc_fr      = {3'd0, lvl_factor} << 3; 

    assign lvl_x_100  = (level << 6) + (level << 5) + (level << 2);
    assign k_x_200    = (k << 7) + (k << 6) + (k << 3);
    
    assign h_cost     = 14'd2000 + lvl_x_100 + {3'd0, k_x_200};
    assign p_cost     = 16'd20000 + ({1'b0, lvl_x_100} << 1) + ({4'd0, k_x_200} << 2) + {4'd0, k_x_200};

    always_comb begin
        if (order_mode == Party_Pack) begin
            scale = 4'd8;
        end else if (order_mode == Family_Set) begin
            scale = 4'd4;
        end else begin
            scale = 4'd1;
        end
    end

    always_comb begin
        r_f      = 8'd0; 
        r_b      = 8'd0; 
        r_m      = 8'd0; 
        r_s      = 8'd0; 
        r_fr     = 8'd0; 
        pb_div10 = 6'd0;
        
        case(dessert_type)
            Cookie: begin 
                r_f      = 8'd100; 
                r_b      = 8'd50;  
                r_s      = 8'd30;  
                pb_div10 = 6'd12; 
            end 
            Bread: begin 
                r_f      = 8'd200; 
                r_b      = 8'd20;  
                r_m      = 8'd50;  
                r_s      = 8'd10;  
                pb_div10 = 6'd10; 
            end 
            Fruit_Cake: begin 
                r_f      = 8'd150; 
                r_b      = 8'd80;  
                r_m      = 8'd40;  
                r_s      = 8'd60;  
                r_fr     = 8'd100; 
                pb_div10 = 6'd40; 
            end 
            Pudding: begin 
                r_m      = 8'd150; 
                r_s      = 8'd50;  
                r_fr     = 8'd20; 
                pb_div10 = 6'd18; 
            end 
            Macaron: begin 
                r_f      = 8'd40;  
                r_b      = 8'd30;  
                r_s      = 8'd120; 
                pb_div10 = 6'd25; 
            end 
            Pancake: begin 
                r_f      = 8'd120; 
                r_b      = 8'd30;  
                r_m      = 8'd80;  
                r_s      = 8'd20;  
                r_fr     = 8'd40; 
                pb_div10 = 6'd20; 
            end 
            Brownie: begin 
                r_f      = 8'd80;  
                r_b      = 8'd100; 
                r_s      = 8'd100; 
                pb_div10 = 6'd28; 
            end 
            Scone: begin 
                r_f      = 8'd150; 
                r_b      = 8'd60;  
                r_m      = 8'd30;  
                r_s      = 8'd20;  
                r_fr     = 8'd10; 
                pb_div10 = 6'd16; 
            end 
            default: begin
            end
        endcase
    end

    assign ms_price = (pb_div10 * lvl_factor) + sq_div_200;
    
    always_comb begin
        if (order_mode == Party_Pack) begin
            ms_earn = {ms_price[10:0], 3'd0};
        end else if (order_mode == Family_Set) begin
            ms_earn = {1'b0, ms_price[10:0], 2'd0};
        end else begin
            ms_earn = {3'd0, ms_price[10:0]};
        end
    end

    always_comb begin
        if (order_mode == Party_Pack) begin
            req_f  = {1'b0, r_f,  3'd0}; 
            req_b  = {1'b0, r_b,  3'd0}; 
            req_m  = {1'b0, r_m,  3'd0}; 
            req_s  = {1'b0, r_s,  3'd0}; 
            req_fr = {1'b0, r_fr, 3'd0};
        end else if (order_mode == Family_Set) begin
            req_f  = {2'b0, r_f,  2'd0}; 
            req_b  = {2'b0, r_b,  2'd0}; 
            req_m  = {2'b0, r_m,  2'd0}; 
            req_s  = {2'b0, r_s,  2'd0}; 
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