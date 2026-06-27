//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2026 ICLAB Spring Course
//   Lab09      : DSS
//   Author     : Tzu-Yun Huang
//   Editor     : Chia-Hsin Lee (Modified by Expert)
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : PATTERN.sv
//   Module Name : PATTERN
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "Usertype.sv"

`ifndef CYCLE_TIME
`define CYCLE_TIME 10.0
`endif

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE = 1000;
parameter simulation_cycle = `CYCLE_TIME;

logic [7:0] golden_DRAM [65536 : 65536+2047];
logic [7:0] shadow_DRAM [65536 : 65536+2047];

integer PATNUM = 15000; 
integer total_latency, latency;
integer i, pat;
int prev_d_no;

bit golden_complete;
Warn_Msg golden_warn;

longint d_flour, d_butter, d_milk, d_sugar, d_fruit;
longint d_sales, d_staff, d_balance, d_level;
int d_month, d_day;

int restock_amounts[5];
longint dbg_old_f, dbg_old_b, dbg_old_m, dbg_old_s, dbg_old_fr;
longint dbg_old_sales, dbg_old_staff, dbg_old_level, dbg_old_balance;
int     dbg_old_month, dbg_old_day;
longint dbg_req_cost, dbg_req_salary, dbg_earn;

int outstanding_writes = 0;

// -----------------------------------------------------------
// AXI-Lite Snooper & Protocol Checker
// -----------------------------------------------------------
initial begin
    logic [16:0] aw_q [$];
    logic [63:0] w_q  [$];
    
    aw_q.delete();
    w_q.delete();
    outstanding_writes = 0;
    forever begin
        @(negedge clk);
        if (inf.rst_n) begin
            if (inf.AW_VALID && inf.AW_READY) begin
                aw_q.push_back(inf.AW_ADDR);
                outstanding_writes++;
            end
            
            if (inf.W_VALID && inf.W_READY) begin
                w_q.push_back(inf.W_DATA);
            end

            if (inf.B_VALID && inf.B_READY) begin
                outstanding_writes--;
            end
            
            while (aw_q.size() > 0 && w_q.size() > 0) begin
                logic [16:0] addr = aw_q.pop_front();
                logic [63:0] data = w_q.pop_front();
                
                shadow_DRAM[addr+0] = data[7:0];
                shadow_DRAM[addr+1] = data[15:8];
                shadow_DRAM[addr+2] = data[23:16];
                shadow_DRAM[addr+3] = data[31:24];
                shadow_DRAM[addr+4] = data[39:32];
                shadow_DRAM[addr+5] = data[47:40];
                shadow_DRAM[addr+6] = data[55:48];
                shadow_DRAM[addr+7] = data[63:56];
            end
        end else begin
            aw_q.delete();
            w_q.delete();
            outstanding_writes = 0;
        end
    end
end

// -----------------------------------------------------------
// Randomization Classes
// -----------------------------------------------------------
class Rand_Action;
    rand Action act;
    constraint c_act { act inside {Make_and_Sell, Restock, Hire_Staff, Pay_Day, Check_Valid_Date}; }
endclass

class Rand_Dessert;
    rand Dessert_Type dtype;
    constraint c_dtype { dtype inside {Cookie, Bread, Fruit_Cake, Pudding, Macaron, Pancake, Brownie, Scone}; }
endclass

class Rand_Mode;
    rand Order_Mode mode;
    constraint c_mode { mode inside {Single, Family_Set, Party_Pack}; }
endclass

class Rand_Date;
    rand bit [3:0] month;
    rand bit [4:0] day;
    constraint c_month { month >= 1 && month <= 12; }
    constraint c_day {
        (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) -> (day >= 1 && day <= 31);
        (month == 4 || month == 6 || month == 9 || month == 11) -> (day >= 1 && day <= 30);
        (month == 2) -> (day >= 1 && day <= 28);
    }
endclass

class Rand_Staff;
    rand bit [4:0] staff;
    constraint c_staff { staff >= 1 && staff <= 30; }
endclass

class Rand_Restock;
    rand bit [10:0] amount;
    constraint c_amount { amount >= 0 && amount <= 2047; }
endclass

class Rand_DRAM_No;
    rand bit [6:0] d_no;
    constraint c_d_no { d_no >= 0 && d_no <= 127; }
endclass

Rand_Action  r_act = new();
Rand_Dessert r_dtype = new();
Rand_Mode    r_mode = new();
Rand_Date    r_date = new();
Rand_Staff   r_staff = new();
Rand_Restock r_restock = new();
Rand_DRAM_No r_d_no = new();

// -----------------------------------------------------------
// Automatic DRAM Generator
// -----------------------------------------------------------
task generate_dram_dat;
begin
    int fd;
    logic [63:0] w0, w1;
    logic [11:0] r_flour, r_butter, r_milk, r_sugar, r_fruit, r_sales;
    logic [7:0]  r_month, r_day, r_staff, r_level;
    logic [23:0] r_balance;
    int threshold;

    fd = $fopen(DRAM_p_r, "w");
    if (fd == 0) begin
        $display("\033[0;31m[Error] Cannot open %0s for writing. Check directory structure!\033[m", DRAM_p_r);
        $finish;
    end

    for (int idx = 0; idx < 128; idx++) begin
        r_flour   = $urandom_range(100, 4000);
        r_butter  = $urandom_range(100, 4000);
        r_milk    = $urandom_range(100, 4000);
        r_sugar   = $urandom_range(100, 4000);
        r_fruit   = $urandom_range(100, 4000);
        r_month   = $urandom_range(1, 12);
        r_day     = $urandom_range(1, 28);
        r_staff   = $urandom_range(2, 30);
        r_level   = $urandom_range(1, 100);
        r_balance = $urandom_range(100000, 16000000);
        threshold = 10 * (r_level / 10);
        if (threshold < 10) threshold = 10;
        
        if (r_level == 100) begin
            r_sales = $urandom_range(0, 4095);
        end else begin
            r_sales = $urandom_range(0, threshold - 1);
        end

        // Edge Cases Settings
        if (idx == 0) r_staff = 0;
        if (idx == 1) begin r_balance = 0; r_staff = 1; end
        if (idx == 2) r_flour = 0;
        if (idx == 3) begin r_flour = 4095; r_butter = 4095; r_milk = 4095; r_sugar = 4095; r_fruit = 4095; end
        if (idx == 4) begin r_level = 100; r_sales = 4000; end
        if (idx == 5) begin r_level = 99; r_sales = 89; end
        if (idx == 6) r_staff = 100;
        if (idx == 7) r_balance = 16777215;     
        if (idx == 8) begin r_month = 12; r_day = 31; end
        if (idx == 9) begin r_level = 0; r_sales = 0; end
        
        // 🚨 強制產生最惡劣的萬惡之源 (Shop 10) 為了榨出 Warning Priority 的 Bug 🚨
        if (idx == 10) begin
            r_staff = 0;      
            r_flour = 0; r_butter = 0; r_milk = 0; r_sugar = 0; r_fruit = 0;
            r_balance = 0;    
            r_month = 12; r_day = 31;
            r_level = 10; r_sales = 0;
        end

        w0 = {r_flour, r_butter, r_month, r_milk, r_sugar, r_day};
        w1 = {r_fruit, r_sales, r_staff, r_balance, r_level};

        $fdisplay(fd, "@%05X", 17'h10000 + idx * 16);
        $fdisplay(fd, "%02X %02X %02X %02X %02X %02X %02X %02X", w0[7:0], w0[15:8], w0[23:16], w0[31:24], w0[39:32], w0[47:40], w0[55:48], w0[63:56]);
        $fdisplay(fd, "@%05X", 17'h10000 + idx * 16 + 8);
        $fdisplay(fd, "%02X %02X %02X %02X %02X %02X %02X %02X", w1[7:0], w1[15:8], w1[23:16], w1[31:24], w1[39:32], w1[47:40], w1[55:48], w1[63:56]);
    end
    $fclose(fd);
end endtask

// -----------------------------------------------------------
// Main Flow
// -----------------------------------------------------------
initial begin
    $readmemh(DRAM_p_r, golden_DRAM);
    if (golden_DRAM[65536 + 127*16] === 8'hxx) begin
        $display("\n============================================================");
        $display("\033[0;33m[Auto-Generator] Detected uninitialized dram.dat. Updating...\033[m");
        generate_dram_dat();
        $display("\033[0;32m[Success] Generated new test data matching the packed struct!\033[m");
        $display("\033[0;36mPlease run simulation again (make sim).\033[m");
        $display("============================================================\n");
        $finish;
    end
    
    for(int k=65536; k<=65536+2047; k++) begin
        shadow_DRAM[k] = golden_DRAM[k];
    end

    reset_task();
    for (pat = 0; pat < PATNUM; pat = pat + 1) begin
        randomize_inputs();
        input_task();
        calculate_golden();
        wait_out_valid_task();
        $display("\033[0;32mPass Pattern No.%4d \033[m", pat);
    end
    
    display_pass();
end

// -----------------------------------------------------------
// Tasks
// -----------------------------------------------------------
task reset_task; begin
    inf.rst_n = 1'b1;
    inf.sel_action_valid = 1'b0;
    inf.type_valid = 1'b0;
    inf.mode_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.staff_valid = 1'b0;
    inf.data_no_valid = 1'b0;
    inf.restock_valid = 1'b0;
    inf.D = 'bx;
    total_latency = 0;
    prev_d_no = 0;

    // 🚨 修正危機 1：保證 Reset 徹底清除 Pipeline 並等待 3 個完整 cycle 🚨
    @(negedge clk);
    inf.rst_n = 1'b0;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    
    if (inf.out_valid !== 1'b0 || inf.complete !== 1'b0 || inf.warn_msg !== 3'b000) begin
        $display("\033[0;31m[Error] Reset fail! Output signals should be 0 after reset.\033[m");
        $finish;
    end
    inf.rst_n = 1'b1;
end endtask

task randomize_inputs; begin
    int b_addr;
    int d_m, d_d;
    int target_valid;

    r_act.randomize();
    r_d_no.randomize();
    
    // 🚨 修正盲區 1：強制指派「萬惡 Shop 10」來壓榨 Priority Coverage 🚨
    if (pat == 10) begin
        r_d_no.d_no = 10; r_act.act = Make_and_Sell; r_date.month = 1; r_date.day = 1; // 撞出 Date > Staff > Stock
    end else if (pat == 11) begin
        r_d_no.d_no = 10; r_act.act = Pay_Day; r_date.month = 1; r_date.day = 1;       // 撞出 Date > Staff > Balance
    end else if (pat == 12) begin
        r_d_no.d_no = 10; r_act.act = Hire_Staff; r_date.month = 12; r_date.day = 31; r_staff.staff = 30; // 撞出 Balance > Staff
    end else if (pat == 13) begin
        r_d_no.d_no = 10; r_act.act = Restock; r_date.month = 12; r_date.day = 31;     // 撞出 Balance > Restock
    end else if (pat < 20) begin
        r_d_no.d_no = 0; r_act.act = Make_and_Sell;
    end else if (pat < 30) begin
        r_d_no.d_no = 1; r_act.act = Pay_Day;
    end else if (pat < 40) begin
        r_d_no.d_no = 2; r_act.act = Make_and_Sell;
    end else if (pat < 50) begin
        r_d_no.d_no = 3; r_act.act = Restock;
    end else if (pat < 60) begin
        r_d_no.d_no = 4; r_act.act = Make_and_Sell;
    end else if (pat < 70) begin
        r_d_no.d_no = 5; r_act.act = Make_and_Sell;
    end else if (pat < 80) begin
        r_d_no.d_no = 6; r_act.act = Hire_Staff;
    end else if (pat < 90) begin
        r_d_no.d_no = 7; r_act.act = Make_and_Sell;
    end else if (pat >= 90 && pat < 100) begin
        r_d_no.d_no = 8; r_act.act = Check_Valid_Date;   
    end else if (pat >= 100 && pat < 110) begin 
        r_d_no.d_no = 9; r_act.act = Make_and_Sell;      
    end else if (pat >= 110 && pat % 3 == 0) begin
        r_d_no.d_no = prev_d_no;
    end

    prev_d_no = r_d_no.d_no;

    b_addr = 65536 + r_d_no.d_no * 16;
    d_m = golden_DRAM[b_addr+4];
    d_d = golden_DRAM[b_addr+0];
    
    target_valid = ($urandom_range(1, 100) <= 85) ? 1 : 0;
    if (d_m == 12 && d_d == 31) target_valid = 0;
    if (d_m == 1 && d_d == 1) target_valid = 1;
    
    // 只在非強制覆蓋率測資時做動態時間調整
    if (pat < 10 || pat > 13) begin
        if (pat >= 90 && pat < 100) begin
            r_date.month = 1;
            r_date.day = 1; 
        end else if (target_valid) begin
            r_date.randomize() with { month > d_m || (month == d_m && day >= d_d); };
        end else begin
            r_date.randomize() with { month < d_m || (month == d_m && day < d_d); };
        end
    end

    if (r_act.act == Make_and_Sell) begin
        r_dtype.randomize();
        r_mode.randomize();
    end else if (r_act.act == Hire_Staff) begin
        if(pat < 10 || pat > 13) r_staff.randomize();
    end else if (r_act.act == Restock) begin
        for (int j=0; j<5; j++) begin
            r_restock.randomize();
            restock_amounts[j] = r_restock.amount;
        end
    end
end endtask

task check_out_valid;
begin
    if (inf.out_valid === 1'b1 || inf.complete === 1'b1 || inf.warn_msg !== 3'b000) begin
        $display("\033[0;31m[Error] Output signals (out_valid, complete, warn_msg) must remain 0 during input and calculation phases!\033[m");
        $finish;
    end
end endtask

task delay_gap; begin
    int gap = $urandom_range(1, 4);
    repeat(gap) begin
        @(negedge clk);
        check_out_valid();
    end
end endtask

task input_task; begin
    delay_gap();
    inf.sel_action_valid = 1'b1; inf.D = {69'b0, r_act.act}; check_out_valid();
    @(negedge clk); inf.sel_action_valid = 1'b0; inf.D = 'bx;
    case (r_act.act)
        Make_and_Sell: begin
            delay_gap();
            inf.type_valid = 1'b1; inf.D = {69'b0, r_dtype.dtype}; check_out_valid(); @(negedge clk); inf.type_valid = 1'b0; inf.D = 'bx;
            delay_gap(); 
            inf.mode_valid = 1'b1;
            inf.D = {70'b0, r_mode.mode}; check_out_valid(); @(negedge clk); inf.mode_valid = 1'b0; inf.D = 'bx;
            delay_gap(); 
            inf.date_valid = 1'b1;
            inf.D = {63'b0, r_date.month, r_date.day}; check_out_valid(); @(negedge clk); inf.date_valid = 1'b0; inf.D = 'bx;
            delay_gap(); 
            inf.data_no_valid = 1'b1;
            inf.D = {65'b0, r_d_no.d_no}; check_out_valid(); @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 'bx;
        end
        Restock: begin
            delay_gap();
            inf.date_valid = 1'b1; inf.D = {63'b0, r_date.month, r_date.day}; check_out_valid(); @(negedge clk); inf.date_valid = 1'b0; inf.D = 'bx;
            delay_gap();
            inf.data_no_valid = 1'b1; inf.D = {65'b0, r_d_no.d_no}; check_out_valid(); @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 'bx;
            for (int j = 0; j < 5; j++) begin
                delay_gap();
                inf.restock_valid = 1'b1; inf.D = {61'b0, restock_amounts[j]}; check_out_valid(); @(negedge clk); inf.restock_valid = 1'b0; inf.D = 'bx;
            end
        end
        Hire_Staff: begin
            delay_gap();
            inf.staff_valid = 1'b1; inf.D = {67'b0, r_staff.staff}; check_out_valid(); @(negedge clk); inf.staff_valid = 1'b0; inf.D = 'bx;
            delay_gap(); 
            inf.date_valid = 1'b1;
            inf.D = {63'b0, r_date.month, r_date.day}; check_out_valid(); @(negedge clk); inf.date_valid = 1'b0; inf.D = 'bx;
            delay_gap(); 
            inf.data_no_valid = 1'b1;
            inf.D = {65'b0, r_d_no.d_no}; check_out_valid(); @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 'bx;
        end
        Pay_Day, Check_Valid_Date: begin
            delay_gap();
            inf.date_valid = 1'b1; inf.D = {63'b0, r_date.month, r_date.day}; check_out_valid(); @(negedge clk); inf.date_valid = 1'b0; inf.D = 'bx;
            delay_gap();
            inf.data_no_valid = 1'b1; inf.D = {65'b0, r_d_no.d_no}; check_out_valid(); @(negedge clk); inf.data_no_valid = 1'b0; inf.D = 'bx;
        end
    endcase
end endtask

task calculate_golden; begin
    int base_addr = 65536 + r_d_no.d_no * 16;
    logic [63:0] w0, w1;
    bit date_warn;
    longint level_factor;

    w0 = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
          golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
    w1 = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
          golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9], golden_DRAM[base_addr+8]};
          
    d_flour  = w0[63:52];   d_butter = w0[51:40];
    d_month  = w0[39:32];   d_milk   = w0[31:20];
    d_sugar  = w0[19:8];    d_day    = w0[7:0];
    d_fruit   = w1[63:52];  d_sales  = w1[51:40];
    d_staff   = w1[39:32];  d_level  = w1[7:0];
    d_balance = w1[31:8]; 

    if (d_level > 100) d_level = 100;
    if (d_sales > 4095) d_sales = 4095;
    if (d_staff > 100) d_staff = 100;

    dbg_old_f = d_flour; dbg_old_b = d_butter;
    dbg_old_m = d_milk;  dbg_old_s = d_sugar; dbg_old_fr = d_fruit;
    dbg_old_month = d_month; dbg_old_day = d_day;
    dbg_old_sales = d_sales; dbg_old_staff = d_staff; 
    dbg_old_level = d_level; dbg_old_balance = d_balance;
    dbg_req_cost = 0; dbg_req_salary = 0; dbg_earn = 0;
    
    date_warn = (r_date.month < d_month) || ((r_date.month == d_month) && (r_date.day < d_day));
    level_factor = 10 + (d_level / 10);
    golden_complete = 1'b0;
    golden_warn = No_Warn;
    
    // 即使 Date_Warn 也要更新日期，除非不是 Check_Valid_Date
    if (!date_warn || r_act.act == Check_Valid_Date) begin
        d_month = {4'b0, r_date.month};
        d_day = {3'b0, r_date.day};
    end

    case (r_act.act)
        Make_and_Sell: begin
            int req_flour, req_butter, req_milk, req_sugar, req_fruit, price_base;
            int mode_scale, price, lvl_up, denom;
            
            case (r_dtype.dtype)
                Cookie:     begin req_flour=100; req_butter=50; req_milk=0;   req_sugar=30;  req_fruit=0;   price_base=120; end
                Bread:      begin req_flour=200; req_butter=20; req_milk=50;  req_sugar=10;  req_fruit=0;   price_base=100; end
                Fruit_Cake: begin req_flour=150; req_butter=80; req_milk=40;  req_sugar=60;  req_fruit=100; price_base=400; end
                Pudding:    begin req_flour=0;   req_butter=0;  req_milk=150; req_sugar=50;  req_fruit=20;  price_base=180; end
                Macaron:    begin req_flour=40;  req_butter=30; req_milk=0;   req_sugar=120; req_fruit=0;   price_base=250; end
                Pancake:    begin req_flour=120; req_butter=30; req_milk=80;  req_sugar=20;  req_fruit=40;  price_base=200; end
                Brownie:    begin req_flour=80;  req_butter=100;req_milk=0;   req_sugar=100; req_fruit=0;   price_base=280; end
                Scone:      begin req_flour=150; req_butter=60; req_milk=30;  req_sugar=20;  req_fruit=10;  price_base=160; end
            endcase
            
            case (r_mode.mode)
                Single:     mode_scale = 1;
                Family_Set: mode_scale = 4;
                Party_Pack: mode_scale = 8;
            endcase

            req_flour *= mode_scale; req_butter *= mode_scale; req_milk *= mode_scale; 
            req_sugar *= mode_scale; req_fruit *= mode_scale;

            if (date_warn) golden_warn = Date_Warn;
            else if (d_staff == 0) golden_warn = No_Staff_Warn;
            else if (d_flour < req_flour || d_butter < req_butter || d_milk < req_milk || d_sugar < req_sugar || d_fruit < req_fruit) golden_warn = Stock_Warn;
            else begin
                golden_complete = 1'b1;
                d_flour -= req_flour; d_butter -= req_butter; d_milk -= req_milk; d_sugar -= req_sugar; d_fruit -= req_fruit;
                
                price = (price_base * level_factor) / 10 + (d_level * d_level) / 200;
                dbg_earn = (price * mode_scale);
                d_balance += dbg_earn;
                if (d_balance > 16777215) d_balance = 16777215; 
                
                d_sales += mode_scale;
                if (d_sales > 4095) d_sales = 4095;
                
                denom = 10 * (d_level / 10);
                if (denom < 10) denom = 10;
                
                if (d_level < 100) begin
                    lvl_up = d_sales / denom;
                    if (lvl_up > 0) begin
                        d_level += lvl_up;
                        if (d_level >= 100) d_level = 100;
                        d_sales = d_sales % denom;
                    end
                end
            end
        end

        Restock: begin
            longint cost_flour, cost_butter, cost_milk, cost_sugar, cost_fruit, req_total_cost;
            longint act_f, act_b, act_m, act_s, act_fr;
            
            cost_flour = (15 * level_factor) / 10;
            cost_butter= (60 * level_factor) / 10;
            cost_milk  = (25 * level_factor) / 10;
            cost_sugar = (10 * level_factor) / 10;
            cost_fruit = (80 * level_factor) / 10;
            
            // 🚨 修正致命錯誤：優先算出實際數量 (act_*)，並以此計算真正的所需成本 🚨
            act_f  = (d_flour  + restock_amounts[0] > 4095) ? 4095 - d_flour  : restock_amounts[0];
            act_b  = (d_butter + restock_amounts[1] > 4095) ? 4095 - d_butter : restock_amounts[1];
            act_m  = (d_milk   + restock_amounts[2] > 4095) ? 4095 - d_milk   : restock_amounts[2];
            act_s  = (d_sugar  + restock_amounts[3] > 4095) ? 4095 - d_sugar  : restock_amounts[3];
            act_fr = (d_fruit  + restock_amounts[4] > 4095) ? 4095 - d_fruit  : restock_amounts[4];

            req_total_cost = act_f * cost_flour + act_b * cost_butter + act_m * cost_milk + act_s * cost_sugar + act_fr * cost_fruit;
            dbg_req_cost = req_total_cost; 

            if (date_warn) golden_warn = Date_Warn;
            else if (d_balance < req_total_cost) golden_warn = Balance_Warn;
            else if ((d_flour + restock_amounts[0] > 4095) || (d_butter + restock_amounts[1] > 4095) ||
                     (d_milk + restock_amounts[2] > 4095) || (d_sugar + restock_amounts[3] > 4095) ||
                     (d_fruit + restock_amounts[4] > 4095)) golden_warn = Restock_Warn;
            else golden_complete = 1'b1;

            if (!date_warn && d_balance >= req_total_cost) begin
                d_flour += act_f; d_butter += act_b; d_milk += act_m; d_sugar += act_s; d_fruit += act_fr;
                d_balance -= req_total_cost;
            end
        end

        Hire_Staff: begin
            longint cost_per_staff, req_total_cost, actual_hire;
            cost_per_staff = 2000 + d_level * 100 + (d_level / 10) * 200;
            
            // 🚨 修正致命錯誤：優先算出實際能招募的數量，以此計算真正的所需成本 🚨
            actual_hire = (d_staff + r_staff.staff > 100) ? 100 - d_staff : r_staff.staff;
            req_total_cost = actual_hire * cost_per_staff;
            dbg_req_cost = req_total_cost;

            if (date_warn) golden_warn = Date_Warn;
            else if (d_balance < req_total_cost) golden_warn = Balance_Warn;
            else if (d_staff + r_staff.staff > 100) golden_warn = Staff_Warn;
            else golden_complete = 1'b1;

            if (!date_warn && d_balance >= req_total_cost) begin
                d_staff += actual_hire;
                d_balance -= req_total_cost;
            end
        end

        Pay_Day: begin
            longint salary_per_staff, total_salary;
            salary_per_staff = 20000 + d_level * 200 + (d_level / 10) * 1000;
            total_salary = d_staff * salary_per_staff;
            dbg_req_salary = total_salary; 

            if (date_warn) golden_warn = Date_Warn;
            else if (d_staff == 0) golden_warn = No_Staff_Warn;
            else if (d_balance < total_salary) golden_warn = Balance_Warn;
            else golden_complete = 1'b1;

            if (!date_warn && d_staff != 0) begin
                if (d_balance < total_salary) begin
                    d_level = (d_level < 10) ? 0 : d_level - 10;
                    d_staff = (d_staff / 2 < 1) ? 1 : d_staff / 2;
                    d_sales = 0; 
                end else begin
                    d_balance -= total_salary;
                end
            end
        end

        Check_Valid_Date: begin
            if (date_warn) golden_warn = Date_Warn;
            else golden_complete = 1'b1;
        end
    endcase

    w0 = {d_flour[11:0], d_butter[11:0], d_month[7:0], d_milk[11:0], d_sugar[11:0], d_day[7:0]};
    w1 = {d_fruit[11:0], d_sales[11:0], d_staff[7:0], d_balance[23:0], d_level[7:0]};

    {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4],
     golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]} = w0;
    {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12],
     golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9], golden_DRAM[base_addr+8]} = w1;

end endtask

task wait_out_valid_task;
begin
    latency = 0;
    while (inf.out_valid === 1'b0) begin
        latency++;
        if (latency >= MAX_CYCLE) begin
            $display("\033[0;31m[Error] Execution Latency exceeded 1000 cycles!\033[m");
            display_wrong();
        end
        @(negedge clk);
    end
    total_latency += latency;
    
    check_ans_task();
    
    // 🚨 修正危機 2：取代危險的 #1，使用 simulation_cycle/4.0 以徹底錯開 Race Condition 🚨
    #(simulation_cycle/4.0); 
    
    if (outstanding_writes > 0) begin
        $display("\033[0;31m[AXI Protocol Error] out_valid asserted BEFORE receiving B_VALID response!\033[m");
        display_wrong();
    end

    check_dram_task(); 
    
    @(negedge clk);
    if (inf.out_valid === 1'b1 || inf.complete === 1'b1 || inf.warn_msg !== 3'b000) begin
        $display("\033[0;31m[Error] out_valid, complete, and warn_msg MUST reset to 0 in the very next cycle!\033[m");
        display_wrong();
    end
end endtask

task check_ans_task; begin
    if (inf.complete !== golden_complete || inf.warn_msg !== golden_warn) begin
        display_wrong();
    end
end endtask

// -----------------------------------------------------------
// Global DRAM Check
// -----------------------------------------------------------
task check_dram_task; begin
    int err_cnt = 0;
    for (int k = 65536; k <= 65536 + 2047; k++) begin
        if (golden_DRAM[k] !== shadow_DRAM[k]) begin
            $display("\033[0;31m[AXI Write-Back Error]\033[m Corruption detected at Byte Addr: %05X", k);
            $display("  -> Golden Expected : %02X", golden_DRAM[k]);
            $display("  -> RTL Actual Wrote: %02X", shadow_DRAM[k]);
            err_cnt++;
        end
    end
    
    if (err_cnt > 0) begin
        $display("\033[0;31m[Error] RTL internal logic is correct, but AXI4-Lite Write-Back failed or corrupted other shops!\033[m");
        display_wrong();
    end
end endtask

task display_wrong; begin
    $display("\n============================================================");
    $display("\033[0;31m                    PATTERN FAILED                        \033[m");
    $display("============================================================");
    $display(" Failed at Pattern No.%d", pat);
    $display(" Action   : %s", r_act.act.name());
    $display(" Shop_No  : %0d", r_d_no.d_no);
    $display(" In_Date  : %0d/%0d", r_date.month, r_date.day);
    
    if (r_act.act == Make_and_Sell) begin
        $display(" Dessert  : %s, Mode: %s", r_dtype.dtype.name(), r_mode.mode.name());
    end else if (r_act.act == Hire_Staff) begin
        $display(" Req Hire : %0d", r_staff.staff);
    end else if (r_act.act == Restock) begin
        $display(" Restock Req (F,B,M,S,Fr) : %0d, %0d, %0d, %0d, %0d", 
                  restock_amounts[0], restock_amounts[1], restock_amounts[2], restock_amounts[3], restock_amounts[4]);
    end

    $display("------------------------------------------------------------");
    $display(" \033[0;36m[DRAM State BEFORE Action (Shop %0d)]\033[m", r_d_no.d_no);
    $display(" Level: %3d | Staff: %3d | Sales: %4d | Balance: %0d", dbg_old_level, dbg_old_staff, dbg_old_sales, dbg_old_balance);
    $display(" Flour: %3d | Butter: %3d | Milk : %3d | Sugar  : %3d | Fruit: %3d", dbg_old_f, dbg_old_b, dbg_old_m, dbg_old_s, dbg_old_fr);
    $display(" Date : %2d/%2d", dbg_old_month, dbg_old_day);
    
    $display("------------------------------------------------------------");
    $display(" \033[0;35m[Golden Computed Math Details]\033[m");
    if (r_act.act == Pay_Day) begin
        $display(" Salary per Staff : %0d", (dbg_old_staff == 0) ? 0 : (dbg_req_salary / dbg_old_staff));
        $display(" Total Salary Req : %0d", dbg_req_salary);
        $display(" Can Afford?      : %s", (dbg_old_balance >= dbg_req_salary) ? "Yes" : "No (Will Warn 100)");
    end else if (r_act.act == Restock || r_act.act == Hire_Staff) begin
        $display(" Total Cost Req   : %0d", dbg_req_cost);
    end else if (r_act.act == Make_and_Sell) begin
        $display(" Earned Money     : %0d", dbg_earn);
    end

    $display("------------------------------------------------------------");
    $display(" \033[0;33m[Golden Expected]\033[m");
    $display(" Complete : %b", golden_complete);
    $display(" Warn_Msg : %s (%03b)", golden_warn.name(), golden_warn);
    $display("------------------------------------------------------------");
    $display(" \033[0;31m[Your RTL Output]\033[m");
    $display(" Complete : %b", inf.complete);
    $display(" Warn_Msg : %03b", inf.warn_msg);
    $display("============================================================\n");
    $finish;
end endtask

task display_pass;
begin
    $display("\n============================================================");
    $display("\033[0;32m                     PATTERN PASSED !!!                      \033[m");
    $display("                     Total Latency: %0d                      ", total_latency);
    $display("============================================================\n");
    $finish;
end endtask

endprogram