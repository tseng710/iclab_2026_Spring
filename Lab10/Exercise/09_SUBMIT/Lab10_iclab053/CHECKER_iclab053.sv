`include "Usertype.sv"
module CHECKER(input clk, INF.CHECKER inf);
import usertype::*;

class Config_Data;
    Dessert_Type type_rec;
    Order_Mode mode_rec;
endclass
Config_Data cfg_info = new();

always_ff @(posedge clk) begin
    if (inf.type_valid) cfg_info.type_rec = inf.D.d_type[0];
    if (inf.mode_valid) cfg_info.mode_rec = inf.D.d_mode[0];
end

logic has_any_valid;
assign has_any_valid = inf.sel_action_valid | inf.type_valid | inf.mode_valid | 
                       inf.date_valid | inf.data_no_valid | inf.staff_valid | inf.restock_valid;

Action current_op;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) current_op <= Make_and_Sell;
    else if (inf.sel_action_valid) current_op <= inf.D.d_act[0]; 
end

int rs_counter;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) rs_counter <= 0;
    else if (inf.sel_action_valid) rs_counter <= 0;
    else if (current_op == Restock && inf.restock_valid) rs_counter <= rs_counter + 1;
end

logic finish_input;
always_comb begin
    finish_input = 1'b0;
    if (current_op != Restock && inf.data_no_valid === 1'b1) 
        finish_input = 1'b1;
    else if (current_op == Restock && inf.restock_valid === 1'b1 && rs_counter == 4) 
        finish_input = 1'b1;
end

int out_times;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) out_times <= 0;
    else if (inf.out_valid === 1'b1) out_times <= out_times + 1;
end

logic valid_pulse_flag;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) valid_pulse_flag <= 1'b0;
    else if (inf.sel_action_valid === 1'b1) valid_pulse_flag <= 1'b0;
    else if (inf.out_valid === 1'b1) valid_pulse_flag <= 1'b1;
end

function bit chk_calendar(logic [3:0] mm, logic [4:0] dd);
    if (mm < 1 || mm > 12) return 0;
    if (dd < 1 || dd > 31) return 0;
    if (mm == 2 && dd > 28) return 0;
    if ((mm == 4 || mm == 6 || mm == 9 || mm == 11) && dd > 30) return 0;
    return 1;
endfunction

covergroup CovGrp_Item_Config @(posedge clk iff inf.mode_valid);
    option.per_instance = 1;
    cv_type: coverpoint cfg_info.type_rec {
        bins target_type[] = {[Cookie:Scone]};
        option.at_least = 100;
    }
    cv_mode: coverpoint inf.D.d_mode[0] {
        bins target_mode[] = {[Single:Party_Pack]};
        option.at_least = 100;
    }
    crs_config: cross cv_type, cv_mode {
        option.at_least = 100;
    }
endgroup

covergroup CovGrp_Warn_Types @(posedge clk iff inf.out_valid);
    option.per_instance = 1;
    cv_warn: coverpoint inf.warn_msg {
        bins all_warns[] = {No_Warn, Date_Warn, No_Staff_Warn, Stock_Warn, Balance_Warn, Restock_Warn, Staff_Warn};
        option.at_least = 40;
    }
endgroup

covergroup CovGrp_Action_Flow @(posedge clk iff inf.sel_action_valid);
    option.per_instance = 1;
    cv_flow: coverpoint inf.D.d_act[0] {
        bins transition_paths[] = ([Make_and_Sell:Check_Valid_Date] => [Make_and_Sell:Check_Valid_Date]);
        option.at_least = 200;
    }
endgroup

covergroup CovGrp_Restock_Limit @(posedge clk iff inf.restock_valid);
    option.per_instance = 1;
    cv_stk: coverpoint inf.D.d_stock[0] {
        option.auto_bin_max = 128;
        bins valid_ranges[128] = {[0:2047]};
        option.at_least = 5;
    }
endgroup

covergroup CovGrp_Final_Comp @(posedge clk iff inf.out_valid);
    option.per_instance = 1;
    cv_comp: coverpoint inf.complete {
        bins success_bin = {1};
        option.at_least = 1500;
    }
endgroup

CovGrp_Item_Config inst_cg_cfg = new();
CovGrp_Warn_Types inst_cg_warn = new();
CovGrp_Action_Flow inst_cg_flow = new();
CovGrp_Restock_Limit inst_cg_rstk = new();
CovGrp_Final_Comp inst_cg_comp = new();

property prop_rst_chk;
    @(posedge clk) (inf.rst_n === 1'b0 || $rose(inf.rst_n)) |-> 
    (inf.out_valid === 1'b0 && inf.warn_msg === No_Warn && inf.complete === 1'b0 &&
     inf.AR_VALID === 1'b0 && inf.AR_ADDR === '0 && inf.R_READY === 1'b0 &&
     inf.AW_VALID === 1'b0 && inf.AW_ADDR === '0 && inf.W_VALID === 1'b0 &&
     inf.W_DATA === '0 && inf.B_READY === 1'b0);
endproperty
Ast01_Reset: assert property(prop_rst_chk) else $fatal(0, "Assertion 1 is violated");

property prop_lat_limit;
    @(posedge clk) disable iff (!inf.rst_n)
    (has_any_valid === 1'b1 && finish_input) |-> ##[1:1000] (inf.out_valid === 1'b1);
endproperty
Ast02_Latency: assert property(prop_lat_limit) else $fatal(0, "Assertion 2 is violated");

property prop_comp_warn;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1 && inf.complete === 1'b1) |-> (inf.warn_msg === No_Warn);
endproperty
Ast03_CompWarn: assert property(prop_comp_warn) else $fatal(0, "Assertion 3 is violated");

property prop_valid_spacing;
    @(posedge clk) disable iff (!inf.rst_n)
    (has_any_valid === 1'b1 && !finish_input) |-> ##[1:4] (has_any_valid === 1'b1);
endproperty
Ast04_ValSpace: assert property(prop_valid_spacing) else $fatal(0, "Assertion 4 is violated");

property prop_no_overlap;
    @(posedge clk) disable iff (!inf.rst_n)
    (has_any_valid === 1'b1) |-> $onehot({inf.sel_action_valid, inf.type_valid, inf.mode_valid, 
                                          inf.date_valid, inf.data_no_valid, inf.staff_valid, inf.restock_valid});
endproperty
Ast05_NoOverlap: assert property(prop_no_overlap) else $fatal(0, "Assertion 5 is violated");

property prop_pulse_len_1;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1) |=> (inf.out_valid === 1'b0);
endproperty
Ast06_Pulse1: assert property(prop_pulse_len_1) else $fatal(0, "Assertion 6 is violated");

property prop_pulse_len_2;
    @(negedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1) |-> (valid_pulse_flag === 1'b0);
endproperty
Ast06_Pulse2: assert property(prop_pulse_len_2) else $fatal(0, "Assertion 6 is violated");

property prop_next_op;
    @(posedge clk) disable iff (!inf.rst_n)
    (inf.out_valid === 1'b1 && out_times < 9999) |-> ##[1:4] (inf.sel_action_valid === 1'b1);
endproperty
Ast07_NextOp: assert property(prop_next_op) else $fatal(0, "Assertion 7 is violated");

property prop_date_check;
    @(posedge clk) disable iff (!inf.rst_n)
    (inf.date_valid === 1'b1) |-> chk_calendar(inf.D.d_date[0].M, inf.D.d_date[0].D);
endproperty
Ast08_DateChk: assert property(prop_date_check) else $fatal(0, "Assertion 8 is violated");

property prop_axi_collision;
    @(posedge clk) disable iff (!inf.rst_n)
    !(inf.AR_VALID === 1'b1 && inf.AW_VALID === 1'b1);
endproperty
Ast09_AXIOverlap: assert property(prop_axi_collision) else $fatal(0, "Assertion 9 is violated");

endmodule