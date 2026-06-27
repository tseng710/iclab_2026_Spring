`include "Usertype.sv"
module CHECKER(input clk, INF.CHECKER inf);
import usertype::*;

class Type_and_mode;
    Dessert_Type f_type;
    Order_Mode f_mode;
endclass
Type_and_mode fm_info = new();

always_ff @(negedge clk) begin
    if (inf.type_valid) fm_info.f_type = inf.D.d_type[0];
    if (inf.mode_valid) fm_info.f_mode = inf.D.d_mode[0];
end

logic any_valid;
assign any_valid = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                   inf.date_valid | inf.data_no_valid | inf.staff_valid | inf.restock_valid;

Action cur_act;
always_ff @(negedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) cur_act <= Make_and_Sell;
    else if (inf.sel_action_valid) cur_act <= inf.D.d_act[0]; 
end

int restock_cnt;
always_ff @(negedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) restock_cnt <= 0;
    else if (inf.sel_action_valid) restock_cnt <= 0;
    else if (cur_act == Restock && inf.restock_valid) restock_cnt <= restock_cnt + 1;
end

logic is_last_input;
always_comb begin
    is_last_input = 1'b0;
    if (cur_act != Restock && inf.data_no_valid === 1'b1) 
        is_last_input = 1'b1;
    else if (cur_act == Restock && inf.restock_valid === 1'b1 && restock_cnt == 4) 
        is_last_input = 1'b1;
end

int op_count;
always_ff @(negedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) op_count <= 0;
    else if (inf.out_valid === 1'b1) op_count <= op_count + 1;
end

logic out_valid_pulsed;
always_ff @(negedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) out_valid_pulsed <= 1'b0;
    else if (inf.sel_action_valid === 1'b1) out_valid_pulsed <= 1'b0;
    else if (inf.out_valid === 1'b1) out_valid_pulsed <= 1'b1;
end

function bit is_legal_date(logic [3:0] m, logic [4:0] d);
    if (m < 1 || m > 12) return 0;
    if (d < 1 || d > 31) return 0;
    if (m == 2 && d > 28) return 0;
    if ((m == 4 || m == 6 || m == 9 || m == 11) && d > 30) return 0;
    return 1;
endfunction

covergroup CG_TYPE_MODE @(negedge clk iff inf.mode_valid);
    option.per_instance = 1;
    cp_type: coverpoint fm_info.f_type {
        bins b_type[] = {[Cookie:Scone]};
        option.at_least = 100;
    }
    cp_mode: coverpoint inf.D.d_mode[0] {
        bins b_mode[] = {[Single:Party_Pack]};
        option.at_least = 100;
    }
    cr_type_mode: cross cp_type, cp_mode {
        option.at_least = 100;
    }
endgroup

covergroup CG_WARN_MSG @(negedge clk iff inf.out_valid);
    option.per_instance = 1;
    cp_warn: coverpoint inf.warn_msg {
        bins b_warn[] = {No_Warn, Date_Warn, No_Staff_Warn, Stock_Warn, Balance_Warn, Restock_Warn, Staff_Warn};
        option.at_least = 40;
    }
endgroup

covergroup CG_ACTION_TRANS @(negedge clk iff inf.sel_action_valid);
    option.per_instance = 1;
    cp_act: coverpoint inf.D.d_act[0] {
        bins b_trans[] = ([Make_and_Sell:Check_Valid_Date] => [Make_and_Sell:Check_Valid_Date]);
        option.at_least = 200;
    }
endgroup

covergroup CG_RESTOCK_MAT @(negedge clk iff inf.restock_valid);
    option.per_instance = 1;
    cp_stock: coverpoint inf.D.d_stock[0] {
        option.auto_bin_max = 128;
        bins b_stock[128] = {[0:2047]};
        option.at_least = 5;
    }
endgroup

covergroup CG_COMPLETE @(negedge clk iff inf.out_valid);
    option.per_instance = 1;
    cp_comp: coverpoint inf.complete {
        bins b_comp = {1};
        option.at_least = 1500;
    }
endgroup

CG_TYPE_MODE cg_type_mode = new();
CG_WARN_MSG cg_warn_msg = new();
CG_ACTION_TRANS cg_action_trans = new();
CG_RESTOCK_MAT cg_restock_mat = new();
CG_COMPLETE cg_complete = new();

property p_reset;
    @(negedge clk) (inf.rst_n === 1'b0 || $rose(inf.rst_n)) |-> 
    (inf.out_valid === 1'b0 && inf.warn_msg === No_Warn && inf.complete === 1'b0 &&
     inf.AR_VALID === 1'b0 && inf.AR_ADDR === '0 && inf.R_READY === 1'b0 &&
     inf.AW_VALID === 1'b0 && inf.AW_ADDR === '0 && inf.W_VALID === 1'b0 &&
     inf.W_DATA === '0 && inf.B_READY === 1'b0);
endproperty
A_rst: assert property(p_reset) else $fatal(0, "Assertion 1 is violated");

property p_latency;
    @(negedge clk) disable iff (!inf.rst_n)
    (any_valid === 1'b1 && is_last_input) |-> ##[1:1000] (inf.out_valid === 1'b1);
endproperty
A_lat: assert property(p_latency) else $fatal(0, "Assertion 2 is violated");

property p_complete_warn;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1 && inf.complete === 1'b1) |-> (inf.warn_msg === No_Warn);
endproperty
A_comp_warn: assert property(p_complete_warn) else $fatal(0, "Assertion 3 is violated");

property p_input_gap;
    @(negedge clk) disable iff (!inf.rst_n)
    (any_valid === 1'b1 && !is_last_input) |-> ##[1:4] (any_valid === 1'b1);
endproperty
A_input_gap: assert property(p_input_gap) else $fatal(0, "Assertion 4 is violated");

property p_overlap;
    @(negedge clk) disable iff (!inf.rst_n)
    (any_valid === 1'b1) |-> $onehot({inf.sel_action_valid, inf.type_valid, inf.mode_valid, 
                                      inf.date_valid, inf.data_no_valid, inf.staff_valid, inf.restock_valid});
endproperty
A_overlap: assert property(p_overlap) else $fatal(0, "Assertion 5 is violated");

property p_out_valid_length_1;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1) |=> (inf.out_valid === 1'b0);
endproperty
A_out_valid_length_1: assert property(p_out_valid_length_1) else $fatal(0, "Assertion 6 is violated");

property p_out_valid_length_2;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1) |-> (out_valid_pulsed === 1'b0);
endproperty
A_out_valid_length_2: assert property(p_out_valid_length_2) else $fatal(0, "Assertion 6 is violated");

property p_next_op_gap;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1 && op_count < 9999) |-> ##[1:4] (inf.sel_action_valid === 1'b1);
endproperty
A_next_op_gap: assert property(p_next_op_gap) else $fatal(0, "Assertion 7 is violated");

property p_legal_date;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.date_valid === 1'b1) |-> is_legal_date(inf.D.d_date[0].M, inf.D.d_date[0].D);
endproperty
A_legal_date: assert property(p_legal_date) else $fatal(0, "Assertion 8 is violated");

property p_axi_overlap;
    @(negedge clk) disable iff (!inf.rst_n)
    !(inf.AR_VALID === 1'b1 && inf.AW_VALID === 1'b1);
endproperty
A_axi_overlap: assert property(p_axi_overlap) else $fatal(0, "Assertion 9 is violated");

endmodule