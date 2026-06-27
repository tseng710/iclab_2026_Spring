`include "Usertype.sv"
`ifndef CYCLE_TIME
`define CYCLE_TIME 10.0
`endif

program PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE = 1000;
parameter simulation_cycle = `CYCLE_TIME;

integer PATNUM = 10000;
integer total_cycles = 0;

logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];

typedef struct packed {
    logic [11:0] flour, butter, milk, sugar, fruit;
    logic [7:0]  M, D;
    logic [11:0] sales;
    logic [7:0]  staff, level;
    logic [23:0] balance;
} Shop_Info;

Shop_Info golden_shop[128];
Shop_Info dbg_shop_before;

Action in_act;
Dessert_Type in_type;
Order_Mode in_mode;

int in_M;
int in_D;
int in_shop_id;
int in_res_f, in_res_b, in_res_m, in_res_s, in_res_fr;
int in_hire;

bit golden_complete;
Warn_Msg golden_warn_msg;

int w_cnt[7];
int type_mode_cnt;

int price_base[8];
int flour_req[8];
int butter_req[8];
int milk_req[8];
int sugar_req[8];
int fruit_req[8];

Order_Mode valid_modes[3] = '{Single, Family_Set, Party_Pack};
integer pat;

bit word0_written;
bit word1_written;

logic [16:0] aw_addr_queue[$];

int trans_seq[25] = '{0,0,1,0,2,0,3,0,4,1,1,2,1,3,1,4,2,2,3,2,4,3,3,4,4};
int res_seq = 0;

// ===============================================================
// Input Generation (Coverage Targeting)
// ===============================================================
function automatic void generate_inputs();
    int safe_shop, i;
    
    in_res_f = res_seq; res_seq = (res_seq + 1) % 2048;
    in_res_b = res_seq; res_seq = (res_seq + 1) % 2048;
    in_res_m = res_seq; res_seq = (res_seq + 1) % 2048;
    in_res_s = res_seq; res_seq = (res_seq + 1) % 2048;
    in_res_fr= res_seq; res_seq = (res_seq + 1) % 2048;
    
    in_hire  = $urandom_range(1, 30);
    in_shop_id = $urandom_range(0, 127);

    if (pat < 50) begin
        in_act = Make_and_Sell; 
        in_shop_id = 0; in_M = 1; in_D = 1; 
    end else if (pat < 100) begin
        in_act = Pay_Day;
        safe_shop = -1;
        for(i=0; i<128; i++) if(golden_shop[i].staff == 0) safe_shop = i;
        in_shop_id = (safe_shop != -1) ? safe_shop : 0;
        in_M = 12; in_D = 31;
    end else if (pat < 150) begin
        in_act = Make_and_Sell;
        safe_shop = -1;
        for(i=0; i<128; i++) if(golden_shop[i].staff > 0 && golden_shop[i].flour < 1000) safe_shop = i;
        in_shop_id = (safe_shop != -1) ? safe_shop : 0;
        in_M = 12; in_D = 31; in_type = Fruit_Cake; in_mode = Party_Pack;
    end else if (pat < 200) begin
        in_act = Restock; in_M = 12; in_D = 31;
        in_res_f = 2047; in_res_b = 2047; in_res_m = 2047; in_res_s = 2047; in_res_fr = 2047; 
        safe_shop = 0;
        for(i=0; i<128; i++) if(golden_shop[i].balance < golden_shop[safe_shop].balance) safe_shop = i;
        in_shop_id = safe_shop;
    end else if (pat < 250) begin
        in_act = Hire_Staff; in_M = 12; in_D = 31; in_hire = 30;
        safe_shop = 0;
        for(i=0; i<128; i++) if(golden_shop[i].staff > golden_shop[safe_shop].staff && golden_shop[i].balance > 100000) safe_shop = i;
        in_shop_id = safe_shop;
    end else if (pat < 300) begin
        in_act = Restock; in_M = 12; in_D = 31;
        safe_shop = -1;
        for(i=0; i<128; i++) if(golden_shop[i].flour > 2048) begin safe_shop = i; break; end
        if (safe_shop != -1) begin
            in_res_f = 2047; in_res_b = 0; in_res_m = 0; in_res_s = 0; in_res_fr = 0; 
            in_shop_id = safe_shop;
        end else begin
            in_res_f = 2047; in_res_b = 2047; in_res_m = 2047; in_res_s = 2047; in_res_fr = 2047; 
        end
    end 
    else if (pat < 5300) begin
        in_act = Action'(trans_seq[(pat - 300) % 25]);
        in_M = golden_shop[in_shop_id].M + $urandom_range(0, 1);
        if (in_M > 12) in_M = 12;
        if (in_M == golden_shop[in_shop_id].M) begin
            in_D = golden_shop[in_shop_id].D + $urandom_range(0, 5);
        end else begin
            in_D = $urandom_range(1, 28);
        end
        if (in_D == 0) in_D = 1;
        if (in_M == 2 && in_D > 28) in_D = 28;
        if ((in_M == 4 || in_M == 6 || in_M == 9 || in_M == 11) && in_D > 30) in_D = 30;
        if (in_D > 31) in_D = 31;
    end 
    else begin
        in_act = Make_and_Sell;
        in_M = golden_shop[in_shop_id].M + $urandom_range(0, 1);
        if (in_M > 12) in_M = 12;
        if (in_M == golden_shop[in_shop_id].M) begin
            in_D = golden_shop[in_shop_id].D + $urandom_range(0, 5);
        end else begin
            in_D = $urandom_range(1, 28);
        end
        if (in_D == 0) in_D = 1;
        if (in_M == 2 && in_D > 28) in_D = 28;
        if ((in_M == 4 || in_M == 6 || in_M == 9 || in_M == 11) && in_D > 30) in_D = 30;
        if (in_D > 31) in_D = 31;
    end

    if (in_act == Make_and_Sell) begin
        in_type = Dessert_Type'(type_mode_cnt % 8);
        in_mode = valid_modes[(type_mode_cnt / 8) % 3];
        type_mode_cnt++;
    end else begin
        in_type = Dessert_Type'($urandom_range(0, 7));
        in_mode = valid_modes[$urandom_range(0, 2)];
    end
endfunction

// ===============================================================
// Golden Computation
// ===============================================================
task automatic compute_golden();
    Shop_Info shop;
    logic early_date;
    int mult;
    int req_f, req_b, req_m, req_s, req_fr;
    int unit_price, total_price, thresh;
    int lf, cost_f, cost_b, cost_m, cost_s, cost_fr, total_cost;
    int act_f, act_b, act_m, act_s, act_fr;
    int hire_fee, actual_hire;
    int salary_per_staff, total_salary;
    
    int cur_lvl, cur_staff, cur_sales, cur_balance;
    int cur_f, cur_b, cur_m, cur_s, cur_fr;
    
    shop = golden_shop[in_shop_id];
    dbg_shop_before = shop;
    
    early_date = 0;
    golden_complete = 0;
    golden_warn_msg = No_Warn;
    
    cur_lvl = shop.level;
    cur_staff = shop.staff;
    cur_sales = shop.sales;
    cur_balance = shop.balance;
    cur_f = shop.flour;
    cur_b = shop.butter;
    cur_m = shop.milk;
    cur_s = shop.sugar;
    cur_fr = shop.fruit;
    
    if (in_M < shop.M || (in_M == shop.M && in_D < shop.D)) early_date = 1;
    
    if (in_mode == Single) mult = 1;
    else if (in_mode == Family_Set) mult = 4;
    else if (in_mode == Party_Pack) mult = 8;
    else mult = 1;
    
    if (in_act == Make_and_Sell) begin
        if (early_date) golden_warn_msg = Date_Warn;
        else if (cur_staff == 0) golden_warn_msg = No_Staff_Warn;
        else begin
            req_f = flour_req[in_type] * mult;
            req_b = butter_req[in_type] * mult;
            req_m = milk_req[in_type] * mult;
            req_s = sugar_req[in_type] * mult;
            req_fr = fruit_req[in_type] * mult;
            
            if (cur_f < req_f || cur_b < req_b || cur_m < req_m || cur_s < req_s || cur_fr < req_fr) begin
                golden_warn_msg = Stock_Warn;
            end else begin
                golden_complete = 1;
                cur_f -= req_f; cur_b -= req_b; cur_m -= req_m; cur_s -= req_s; cur_fr -= req_fr;
                unit_price = (price_base[in_type] * (10 + (cur_lvl / 10))) / 10 + (cur_lvl * cur_lvl) / 200;
                total_price = unit_price * mult;
                
                cur_balance += total_price;
                if (cur_balance > 16777215) cur_balance = 16777215; 
                
                cur_sales += mult;
                if (cur_lvl < 100) begin
                    thresh = 10 * (cur_lvl / 10);
                    if (thresh < 10) thresh = 10;
                    if (cur_sales >= thresh) begin
                        cur_lvl += 1;
                        cur_sales -= thresh;
                    end
                end else begin
                    if (cur_sales > 4095) cur_sales = 4095;
                end
            end
        end
        if (golden_warn_msg != Date_Warn) begin shop.M = in_M; shop.D = in_D; end
        
    end else if (in_act == Restock) begin
        if (early_date) golden_warn_msg = Date_Warn;
        else begin
            lf = 10 + (cur_lvl / 10);
            cost_f = (15 * lf) / 10;
            cost_b = (60 * lf) / 10;
            cost_m = (25 * lf) / 10;
            cost_s = (10 * lf) / 10;
            cost_fr = (80 * lf) / 10;
            
            act_f = (cur_f + in_res_f > 4095) ? 4095 - cur_f : in_res_f;
            act_b = (cur_b + in_res_b > 4095) ? 4095 - cur_b : in_res_b;
            act_m = (cur_m + in_res_m > 4095) ? 4095 - cur_m : in_res_m;
            act_s = (cur_s + in_res_s > 4095) ? 4095 - cur_s : in_res_s;
            act_fr = (cur_fr + in_res_fr > 4095) ? 4095 - cur_fr : in_res_fr;
            
            total_cost = act_f * cost_f + act_b * cost_b + act_m * cost_m + act_s * cost_s + act_fr * cost_fr;
            
            if (cur_balance < total_cost) golden_warn_msg = Balance_Warn;
            else if (cur_f + in_res_f > 4095 || cur_b + in_res_b > 4095 || cur_m + in_res_m > 4095 || cur_s + in_res_s > 4095 || cur_fr + in_res_fr > 4095) begin
                golden_warn_msg = Restock_Warn;
            end else golden_complete = 1;
            
            if (golden_warn_msg == Restock_Warn || golden_warn_msg == No_Warn) begin
                cur_f += act_f; cur_b += act_b;
                cur_m += act_m; cur_s += act_s; cur_fr += act_fr;
                cur_balance -= total_cost;
            end
        end
        if (golden_warn_msg != Date_Warn) begin shop.M = in_M; shop.D = in_D; end
        
    end else if (in_act == Hire_Staff) begin
        if (early_date) golden_warn_msg = Date_Warn;
        else begin
            hire_fee = 2000 + cur_lvl * 100 + (cur_lvl / 10) * 200;
            actual_hire = (cur_staff + in_hire > 100) ? 100 - cur_staff : in_hire;
            total_cost = actual_hire * hire_fee;
            
            if (cur_balance < total_cost) golden_warn_msg = Balance_Warn;
            else if (cur_staff + in_hire > 100) golden_warn_msg = Staff_Warn;
            else golden_complete = 1;
            
            if (golden_warn_msg == Staff_Warn || golden_warn_msg == No_Warn) begin
                cur_staff += actual_hire;
                cur_balance -= total_cost;
            end
        end
        if (golden_warn_msg != Date_Warn) begin shop.M = in_M; shop.D = in_D; end
        
    end else if (in_act == Pay_Day) begin
        if (early_date) golden_warn_msg = Date_Warn;
        else if (cur_staff == 0) golden_warn_msg = No_Staff_Warn;
        else begin
            salary_per_staff = 20000 + cur_lvl * 200 + (cur_lvl / 10) * 1000;
            total_salary = cur_staff * salary_per_staff;
            
            if (cur_balance < total_salary) begin
                golden_warn_msg = Balance_Warn;
                cur_lvl = (cur_lvl >= 10) ? cur_lvl - 10 : 0;
                cur_staff = (cur_staff > 1) ? cur_staff / 2 : 1;
                cur_sales = 0; 
            end else begin
                golden_complete = 1;
                cur_balance -= total_salary;
            end
        end
        if (golden_warn_msg != Date_Warn) begin shop.M = in_M; shop.D = in_D; end
        
    end else if (in_act == Check_Valid_Date) begin
        if (early_date) golden_warn_msg = Date_Warn;
        else golden_complete = 1;
        shop.M = in_M; shop.D = in_D;
    end
    
    shop.level = cur_lvl;
    shop.staff = cur_staff;
    shop.sales = cur_sales;
    shop.balance = cur_balance;
    shop.flour = cur_f;
    shop.butter = cur_b;
    shop.milk = cur_m;
    shop.sugar = cur_s;
    shop.fruit = cur_fr;
    
    golden_shop[in_shop_id] = shop;
    w_cnt[golden_warn_msg]++;
endtask

// ===============================================================
// Output Validation Task (With Universal Debugging)
// ===============================================================
task automatic wait_out_valid();
    int lat = 0;
    while(inf.out_valid !== 1) begin
        lat++;
        if (lat > 1000) begin
            $display("Wrong Answer"); 
            $display("================================================================");
            $display("[DEBUG] ERROR: Execution latency exceeded 1000 cycles.");
            $display("[DEBUG] Pattern No: %0d | Action: %s | Shop ID: %0d", pat, in_act.name(), in_shop_id);
            $display("================================================================\n");
            $finish;
        end
        @(negedge clk);
    end
    
    if (inf.complete !== golden_complete || inf.warn_msg !== golden_warn_msg) begin
        $display("Wrong Answer"); 
        $display("================================================================");
        $display("[DEBUG] ERROR: Output logical mismatch detected.");
        $display("[DEBUG] Pattern No: %0d | Action: %s | Shop ID: %0d", pat, in_act.name(), in_shop_id);
        $display("[DEBUG] Expected -> Complete: %b, Warn_Msg: %s", golden_complete, golden_warn_msg.name());
        $display("[DEBUG] Actual   -> Complete: %b, Warn_Msg: %s", inf.complete, inf.warn_msg.name());
        $display("================================================================\n");
        $finish;
    end
    
    while(inf.out_valid === 1) @(negedge clk);

    if (golden_warn_msg === Date_Warn && in_act !== Check_Valid_Date) begin
        if (word0_written || word1_written) begin
            $display("Wrong Answer"); 
            $display("================================================================");
            $display("[DEBUG] ERROR: Unnecessary DRAM write occurred during Date_Warn.");
            $display("[DEBUG] Only Check_Valid_Date requires DRAM update on Date_Warn.");
            $display("[DEBUG] Pattern No: %0d | Action: %s", pat, in_act.name());
            $display("================================================================\n");
            $finish;
        end
    end else begin
        if (!word0_written) begin
            $display("Wrong Answer"); 
            $display("================================================================");
            $display("[DEBUG] ERROR: Missing DRAM Write for Word 0 (Address + 0).");
            $display("[DEBUG] Check if your AW_VALID/W_VALID successfully fired.");
            $display("[DEBUG] Pattern No: %0d | Action: %s", pat, in_act.name());
            $display("================================================================\n");
            $finish;
        end
        if ((golden_complete === 1 && in_act !== Check_Valid_Date) ||
            (in_act === Pay_Day && golden_warn_msg === Balance_Warn) ||
            (in_act === Hire_Staff && golden_warn_msg === Staff_Warn) ||
            (in_act === Restock && golden_warn_msg === Restock_Warn)) begin
            
            if (!word1_written) begin
                $display("Wrong Answer"); 
                $display("================================================================");
                $display("[DEBUG] ERROR: Missing DRAM Write for Word 1 (Address + 8).");
                $display("[DEBUG] This action modifies shop stats. Both words MUST be written.");
                $display("[DEBUG] Pattern No: %0d | Action: %s", pat, in_act.name());
                $display("================================================================\n");
                $finish;
            end
        end
    end
endtask

// ===============================================================
// Universal AXI Monitor (Robust Queue + Value Checking)
// ===============================================================
initial begin
    forever begin
        @(negedge clk);
        if (inf.AW_VALID && inf.AW_READY) begin
            // 修正 Static 初始化陷阱！將宣告與賦值分開
            int expected_base;
            expected_base = 17'h10000 + (in_shop_id * 16);
            
            if (inf.AW_ADDR !== expected_base && inf.AW_ADDR !== expected_base + 8) begin
                $display("Wrong Answer"); 
                $display("================================================================");
                $display("[DEBUG] ERROR: AW_ADDR wrote to wrong Address!");
                $display("[DEBUG] Pattern No: %0d | Shop ID: %0d", pat, in_shop_id);
                $display("[DEBUG] Expected Base: %h or %h", expected_base, expected_base+8);
                $display("[DEBUG] Actual AW_ADDR: %h", inf.AW_ADDR);
                $display("================================================================\n");
                $finish;
            end
            aw_addr_queue.push_back(inf.AW_ADDR);
        end
    end
end

initial begin
    forever begin
        @(negedge clk);
        if (inf.W_VALID && inf.W_READY) begin
            int current_addr;
            int current_shop;
            int word_offset;
            logic [63:0] gold_data;

            if (aw_addr_queue.size() > 0) begin
                current_addr = aw_addr_queue.pop_front();
            end else if (inf.AW_VALID && inf.AW_READY) begin
                current_addr = inf.AW_ADDR;
            end else begin
                $display("Wrong Answer"); 
                $display("================================================================");
                $display("[DEBUG] ERROR: W_VALID asserted but no AW_ADDR provided!");
                $display("[DEBUG] (Caught TA's Protocol Violation Bug)");
                $display("================================================================\n");
                $finish;
            end

            current_shop = (current_addr - 17'h10000) / 16;
            word_offset = (current_addr - 17'h10000) % 16;

            if (word_offset == 0) begin
                gold_data = {golden_shop[current_shop].flour, golden_shop[current_shop].butter, golden_shop[current_shop].M, golden_shop[current_shop].milk, golden_shop[current_shop].sugar, golden_shop[current_shop].D};
                word0_written = 1;
            end else begin
                gold_data = {golden_shop[current_shop].fruit, golden_shop[current_shop].sales, golden_shop[current_shop].staff, golden_shop[current_shop].balance, golden_shop[current_shop].level};
                word1_written = 1;
            end

            if (inf.W_DATA !== gold_data) begin
                $display("Wrong Answer"); 
                $display("================================================================");
                $display("[DEBUG] ERROR: AXI W_DATA mismatch for Word (offset %0d).", word_offset);
                $display("[DEBUG] Pattern No: %0d | Action: %s | Shop ID: %0d", pat, in_act.name(), current_shop);
                $display("[DEBUG] Expected W_DATA: %h", gold_data);
                $display("[DEBUG] Actual W_DATA  : %h", inf.W_DATA);
                $display("================================================================\n");
                $finish;
            end
        end
    end
end

// ===============================================================
// Main Execution Block
// ===============================================================
initial begin
    int i, base;
    logic [63:0] w0, w1;

    w_cnt[0]=0; w_cnt[1]=0; w_cnt[2]=0; w_cnt[3]=0; w_cnt[4]=0; w_cnt[5]=0; w_cnt[6]=0;
    type_mode_cnt = 0;
    
    price_base[0]=120; price_base[1]=100; price_base[2]=400; price_base[3]=180; price_base[4]=250; price_base[5]=200; price_base[6]=280; price_base[7]=160;
    flour_req[0]=100;  flour_req[1]=200;  flour_req[2]=150;  flour_req[3]=0;    flour_req[4]=40;   flour_req[5]=120;  flour_req[6]=80;   flour_req[7]=150;
    butter_req[0]=50;  butter_req[1]=20;  butter_req[2]=80;  butter_req[3]=0;   butter_req[4]=30;  butter_req[5]=30;  butter_req[6]=100; butter_req[7]=60;
    milk_req[0]=0;     milk_req[1]=50;    milk_req[2]=40;    milk_req[3]=150;   milk_req[4]=0;     milk_req[5]=80;    milk_req[6]=0;     milk_req[7]=30;
    sugar_req[0]=30;   sugar_req[1]=10;   sugar_req[2]=60;   sugar_req[3]=50;   sugar_req[4]=120;  sugar_req[5]=20;   sugar_req[6]=100;  sugar_req[7]=20;
    fruit_req[0]=0;    fruit_req[1]=0;    fruit_req[2]=100;  fruit_req[3]=20;   fruit_req[4]=0;    fruit_req[5]=40;   fruit_req[6]=0;    fruit_req[7]=10;

    inf.rst_n = 1'b1;
    inf.sel_action_valid = 0; inf.type_valid = 0; inf.mode_valid = 0; inf.date_valid = 0;
    inf.data_no_valid = 0; inf.staff_valid = 0; inf.restock_valid = 0;
    inf.D = 'bx;
    
    force clk = 0;
    #(`CYCLE_TIME) inf.rst_n = 0;
    #(`CYCLE_TIME*3) inf.rst_n = 1;
    release clk;

    $readmemh(DRAM_p_r, golden_DRAM);
    for (i=0; i<128; i++) begin
        base = 65536 + i*16;
        w0 = {golden_DRAM[base+7], golden_DRAM[base+6], golden_DRAM[base+5], golden_DRAM[base+4], 
              golden_DRAM[base+3], golden_DRAM[base+2], golden_DRAM[base+1], golden_DRAM[base+0]};
        w1 = {golden_DRAM[base+15], golden_DRAM[base+14], golden_DRAM[base+13], golden_DRAM[base+12], 
              golden_DRAM[base+11], golden_DRAM[base+10], golden_DRAM[base+9], golden_DRAM[base+8]};
              
        golden_shop[i].flour   = w0[63:52];
        golden_shop[i].butter  = w0[51:40];
        golden_shop[i].M       = w0[39:32];
        golden_shop[i].milk    = w0[31:20];
        golden_shop[i].sugar   = w0[19:8];
        golden_shop[i].D       = w0[7:0];
        
        golden_shop[i].fruit   = w1[63:52];
        golden_shop[i].sales   = w1[51:40];
        golden_shop[i].staff   = w1[39:32];
        golden_shop[i].balance = w1[31:8]; 
        golden_shop[i].level   = w1[7:0];  
    end

    for (pat = 0; pat < PATNUM; pat++) begin
        word0_written = 0;
        word1_written = 0;
        aw_addr_queue.delete(); 
        
        generate_inputs();
        compute_golden();
        
        drive_action(in_act);
        if (in_act == Make_and_Sell) begin
            drive_type(in_type);
            drive_mode(in_mode);
            drive_date(in_M, in_D);
            drive_data_no(in_shop_id);
        end else if (in_act == Restock) begin
            drive_date(in_M, in_D);
            drive_data_no(in_shop_id);
            drive_restock(in_res_f);
            drive_restock(in_res_b);
            drive_restock(in_res_m);
            drive_restock(in_res_s);
            drive_restock(in_res_fr);
        end else if (in_act == Hire_Staff) begin
            drive_staff(in_hire);
            drive_date(in_M, in_D);
            drive_data_no(in_shop_id);
        end else begin
            drive_date(in_M, in_D);
            drive_data_no(in_shop_id);
        end
        
        wait_out_valid();

        // [進度條顯示] 每 200 筆顯示一次進度
        if (pat % 200 == 0 && pat != 0) begin
            $display("[INFO] Pattern Progress: %0d / %0d PASSED", pat, PATNUM);
        end
    end

    $display("Congratulations");
    $finish;
end

initial begin
    total_cycles = 0;
    forever begin
        @(posedge clk);
        if (inf.rst_n) total_cycles++;
    end
end

// Driving Tasks
task automatic drive_action(Action act);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.sel_action_valid = 1; inf.D = {69'b0, act};
    @(negedge clk); inf.sel_action_valid = 0; inf.D = 'bx;
endtask
task automatic drive_type(Dessert_Type type_in);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.type_valid = 1; inf.D = {69'b0, type_in};
    @(negedge clk); inf.type_valid = 0; inf.D = 'bx;
endtask
task automatic drive_mode(Order_Mode mode_in);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.mode_valid = 1; inf.D = {70'b0, mode_in};
    @(negedge clk); inf.mode_valid = 0; inf.D = 'bx;
endtask
task automatic drive_date(int M, int D);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.date_valid = 1; inf.D = {63'b0, M[3:0], D[4:0]};
    @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
endtask
task automatic drive_data_no(int data_no);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.data_no_valid = 1; inf.D = {64'b0, data_no[7:0]};
    @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
endtask
task automatic drive_restock(int amt);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.restock_valid = 1; inf.D = {60'b0, amt[11:0]};
    @(negedge clk); inf.restock_valid = 0; inf.D = 'bx;
endtask
task automatic drive_staff(int staff);
    int gap = $urandom_range(1, 3); 
    repeat(gap) @(negedge clk);
    inf.staff_valid = 1; inf.D = {64'b0, staff[7:0]};
    @(negedge clk); inf.staff_valid = 0; inf.D = 'bx;
endtask

endprogram