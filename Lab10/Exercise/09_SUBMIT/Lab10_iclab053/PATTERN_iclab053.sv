`include "Usertype.sv"
`ifndef CYCLE_TIME
`define CYCLE_TIME 10.0
`endif

program PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

parameter DRAM_PATH = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE = 1000;
parameter simulation_cycle = `CYCLE_TIME;

integer PATNUM = 10000;
integer total_cycles = 0;

logic [7:0] dram_init_data [((65536+8*256)-1):(65536+0)];

typedef struct packed {
    logic [11:0] flour, butter, milk, sugar, fruit;
    logic [7:0]  M, D;
    logic [11:0] sales;
    logic [7:0]  staff, level;
    logic [23:0] balance;
} Store_Profile;

Store_Profile sim_dram_data[128];
Store_Profile prev_sim_data;

Action cur_in_act;
Dessert_Type cur_in_type;
Order_Mode cur_in_mode;

int in_mth;
int in_day;
int target_shop_id;
int rand_flour, rand_butter, rand_milk, rand_sugar, rand_fruit;
int rand_hire_cnt;

bit expected_comp;
Warn_Msg expected_warn;

int warn_stats[7];
int type_mode_idx;

int base_p_tbl[8];
int req_f_tbl[8], req_b_tbl[8], req_m_tbl[8], req_s_tbl[8], req_fr_tbl[8];

Order_Mode legal_modes[3] = '{Single, Family_Set, Party_Pack};
integer pat;

logic [16:0] write_addr_fifo[$];
bit w0_done;
bit w1_done;

int cov_act_path[25] = '{0,0,1,1,2,2,3,3,4,4,0,2,4,1,3,0,3,1,4,2,0,4,3,2,1};
int stock_seq = 0;

function automatic void generate_inputs();
    int safe_idx, i;
    
    rand_flour = stock_seq; stock_seq = (stock_seq + 1) % 2048;
    rand_butter = stock_seq; stock_seq = (stock_seq + 1) % 2048;
    rand_milk = stock_seq; stock_seq = (stock_seq + 1) % 2048;
    rand_sugar = stock_seq; stock_seq = (stock_seq + 1) % 2048;
    rand_fruit = stock_seq; stock_seq = (stock_seq + 1) % 2048;
    
    rand_hire_cnt  = $urandom_range(1, 30);
    target_shop_id = $urandom_range(0, 127);

    if (pat < 42) begin
        cur_in_act = Make_and_Sell;
        target_shop_id = 0; in_mth = 1; in_day = 1; 
    end 
    else if (pat < 91) begin
        cur_in_act = Pay_Day;
        safe_idx = -1;
        for(i=0; i<128; i++) if(sim_dram_data[i].staff == 0) safe_idx = i;
        target_shop_id = (safe_idx != -1) ? safe_idx : 0;
        in_mth = 12; in_day = 31;
    end 
    else if (pat < 147) begin
        cur_in_act = Make_and_Sell;
        safe_idx = -1;
        for(i=0; i<128; i++) if(sim_dram_data[i].staff > 0 && sim_dram_data[i].flour < 1000) safe_idx = i;
        target_shop_id = (safe_idx != -1) ? safe_idx : 0;
        in_mth = 12; in_day = 31; cur_in_type = Fruit_Cake; cur_in_mode = Party_Pack;
    end 
    else if (pat < 192) begin
        cur_in_act = Restock;
        in_mth = 12; in_day = 31;
        rand_flour = 2047; rand_butter = 2047; rand_milk = 2047; rand_sugar = 2047; rand_fruit = 2047; 
        safe_idx = 0;
        for(i=0; i<128; i++) if(sim_dram_data[i].balance < sim_dram_data[safe_idx].balance) safe_idx = i;
        target_shop_id = safe_idx;
    end 
    else if (pat < 261) begin
        cur_in_act = Hire_Staff; in_mth = 12; in_day = 31; rand_hire_cnt = 30;
        safe_idx = 0;
        for(i=0; i<128; i++) if(sim_dram_data[i].staff > sim_dram_data[safe_idx].staff && sim_dram_data[i].balance > 100000) safe_idx = i;
        target_shop_id = safe_idx;
    end 
    else if (pat < 315) begin
        cur_in_act = Restock;
        in_mth = 12; in_day = 31;
        safe_idx = -1;
        for(i=0; i<128; i++) if(sim_dram_data[i].flour > 2048) begin safe_idx = i; break; end
        if (safe_idx != -1) begin
            rand_flour = 2047; rand_butter = 0; rand_milk = 0; rand_sugar = 0; rand_fruit = 0; 
            target_shop_id = safe_idx;
        end 
        else begin
            rand_flour = 2047; rand_butter = 2047; rand_milk = 2047; rand_sugar = 2047; rand_fruit = 2047; 
        end
    end 
    else if (pat < 5400) begin
        cur_in_act = Action'(cov_act_path[(pat - 315) % 25]);
        in_mth = sim_dram_data[target_shop_id].M + $urandom_range(0, 1);
        if (in_mth > 12) in_mth = 12;
        if (in_mth == sim_dram_data[target_shop_id].M) begin
            in_day = sim_dram_data[target_shop_id].D + $urandom_range(0, 5);
        end 
        else begin
            in_day = $urandom_range(1, 28);
        end
        if (in_day == 0) in_day = 1;
        if (in_mth == 2 && in_day > 28) in_day = 28;
        if ((in_mth == 4 || in_mth == 6 || in_mth == 9 || in_mth == 11) && in_day > 30) in_day = 30;
        if (in_day > 31) in_day = 31;
    end 
    else begin
        cur_in_act = Make_and_Sell;
        in_mth = sim_dram_data[target_shop_id].M + $urandom_range(0, 1);
        if (in_mth > 12) in_mth = 12;
        if (in_mth == sim_dram_data[target_shop_id].M) begin
            in_day = sim_dram_data[target_shop_id].D + $urandom_range(0, 5);
        end 
        else begin
            in_day = $urandom_range(1, 28);
        end
        if (in_day == 0) in_day = 1;
        if (in_mth == 2 && in_day > 28) in_day = 28;
        if ((in_mth == 4 || in_mth == 6 || in_mth == 9 || in_mth == 11) && in_day > 30) in_day = 30;
        if (in_day > 31) in_day = 31;
    end

    if (cur_in_act == Make_and_Sell) begin
        cur_in_type = Dessert_Type'(type_mode_idx % 8);
        cur_in_mode = legal_modes[(type_mode_idx / 8) % 3];
        type_mode_idx++;
    end 
    else begin
        cur_in_type = Dessert_Type'($urandom_range(0, 7));
        cur_in_mode = legal_modes[$urandom_range(0, 2)];
    end
endfunction

task automatic compute_golden();
    Store_Profile cur_shop;
    logic is_early;
    int scale_f;
    int nd_f, nd_b, nd_m, nd_s, nd_fr;
    int u_price, tot_price, lv_thresh;
    int lv_factor, cst_f, cst_b, cst_m, cst_s, cst_fr, tot_cst;
    int ad_f, ad_b, ad_m, ad_s, ad_fr;
    int hr_cost, real_hire;
    int single_salary, tot_salary;
    
    int t_lvl, t_staff, t_sales, t_bal;
    int t_f, t_b, t_m, t_s, t_fr;
    
    cur_shop = sim_dram_data[target_shop_id];
    prev_sim_data = cur_shop;
    
    is_early = 0;
    expected_comp = 0;
    expected_warn = No_Warn;
    
    t_lvl = cur_shop.level;
    t_staff = cur_shop.staff;
    t_sales = cur_shop.sales;
    t_bal = cur_shop.balance;
    t_f = cur_shop.flour;
    t_b = cur_shop.butter;
    t_m = cur_shop.milk;
    t_s = cur_shop.sugar;
    t_fr = cur_shop.fruit;
    
    if (in_mth < cur_shop.M || (in_mth == cur_shop.M && in_day < cur_shop.D)) is_early = 1;
    
    if (cur_in_mode == Single) scale_f = 1;
    else if (cur_in_mode == Family_Set) scale_f = 4;
    else if (cur_in_mode == Party_Pack) scale_f = 8;
    else scale_f = 1;

    if (cur_in_act == Make_and_Sell) begin
        if (is_early) expected_warn = Date_Warn;
        else if (t_staff == 0) expected_warn = No_Staff_Warn;
        else begin
            nd_f = req_f_tbl[cur_in_type] * scale_f;
            nd_b = req_b_tbl[cur_in_type] * scale_f;
            nd_m = req_m_tbl[cur_in_type] * scale_f;
            nd_s = req_s_tbl[cur_in_type] * scale_f;
            nd_fr = req_fr_tbl[cur_in_type] * scale_f;

            if (t_f < nd_f || t_b < nd_b || t_m < nd_m || t_s < nd_s || t_fr < nd_fr) begin
                expected_warn = Stock_Warn;
            end 
            else begin
                expected_comp = 1;
                t_f -= nd_f; t_b -= nd_b; t_m -= nd_m; t_s -= nd_s; t_fr -= nd_fr;
                u_price = (base_p_tbl[cur_in_type] * (10 + (t_lvl / 10))) / 10 + (t_lvl * t_lvl) / 200;
                tot_price = u_price * scale_f;
                
                t_bal += tot_price;
                if (t_bal > 16777215) t_bal = 16777215; 
                
                t_sales += scale_f;
                if (t_lvl < 100) begin
                    lv_thresh = 10 * (t_lvl / 10);
                    if (lv_thresh < 10) lv_thresh = 10;
                    if (t_sales >= lv_thresh) begin
                        t_lvl += 1;
                        t_sales -= lv_thresh;
                    end
                end 
                else begin
                    if (t_sales > 4095) t_sales = 4095;
                end
            end
        end
        if (expected_warn != Date_Warn || cur_in_act == Check_Valid_Date) begin cur_shop.M = in_mth; cur_shop.D = in_day; end
    end 
    else if (cur_in_act == Restock) begin
        if (is_early) expected_warn = Date_Warn;
        else begin
            lv_factor = 10 + (t_lvl / 10);
            cst_f = (15 * lv_factor) / 10;
            cst_b = (60 * lv_factor) / 10;
            cst_m = (25 * lv_factor) / 10;
            cst_s = (10 * lv_factor) / 10;
            cst_fr = (80 * lv_factor) / 10;
            
            ad_f = (t_f + rand_flour > 4095) ? 4095 - t_f : rand_flour;
            ad_b = (t_b + rand_butter > 4095) ? 4095 - t_b : rand_butter;
            ad_m = (t_m + rand_milk > 4095) ? 4095 - t_m : rand_milk;
            ad_s = (t_s + rand_sugar > 4095) ? 4095 - t_s : rand_sugar;
            ad_fr = (t_fr + rand_fruit > 4095) ? 4095 - t_fr : rand_fruit;

            tot_cst = ad_f * cst_f + ad_b * cst_b + ad_m * cst_m + ad_s * cst_s + ad_fr * cst_fr;

            if (t_bal < tot_cst) expected_warn = Balance_Warn;
            else if (t_f + rand_flour > 4095 || t_b + rand_butter > 4095 || t_m + rand_milk > 4095 || t_s + rand_sugar > 4095 || t_fr + rand_fruit > 4095) begin
                expected_warn = Restock_Warn;
            end 
            else expected_comp = 1;
            
            if (expected_warn == Restock_Warn || expected_warn == No_Warn) begin
                t_f += ad_f; t_b += ad_b; t_m += ad_m; t_s += ad_s; t_fr += ad_fr;
                t_bal -= tot_cst;
            end
        end
        if (expected_warn != Date_Warn || cur_in_act == Check_Valid_Date) begin cur_shop.M = in_mth; cur_shop.D = in_day; end
    end 
    else if (cur_in_act == Hire_Staff) begin
        if (is_early) expected_warn = Date_Warn;
        else begin
            hr_cost = 2000 + t_lvl * 100 + (t_lvl / 10) * 200;
            real_hire = (t_staff + rand_hire_cnt > 100) ? 100 - t_staff : rand_hire_cnt;
            tot_cst = real_hire * hr_cost;

            if (t_bal < tot_cst) expected_warn = Balance_Warn;
            else if (t_staff + rand_hire_cnt > 100) expected_warn = Staff_Warn;
            else expected_comp = 1;
            
            if (expected_warn == Staff_Warn || expected_warn == No_Warn) begin
                t_staff += real_hire;
                t_bal -= tot_cst;
            end
        end
        if (expected_warn != Date_Warn || cur_in_act == Check_Valid_Date) begin cur_shop.M = in_mth; cur_shop.D = in_day; end
    end 
    else if (cur_in_act == Pay_Day) begin
        if (is_early) expected_warn = Date_Warn;
        else if (t_staff == 0) expected_warn = No_Staff_Warn;
        else begin
            single_salary = 20000 + t_lvl * 200 + (t_lvl / 10) * 1000;
            tot_salary = t_staff * single_salary;
            
            if (t_bal < tot_salary) begin
                expected_warn = Balance_Warn;
                t_lvl = (t_lvl >= 10) ? t_lvl - 10 : 0;
                t_staff = (t_staff > 1) ? t_staff / 2 : 1;
                t_sales = 0; 
            end 
            else begin
                expected_comp = 1;
                t_bal -= tot_salary;
            end
        end
        if (expected_warn != Date_Warn || cur_in_act == Check_Valid_Date) begin cur_shop.M = in_mth; cur_shop.D = in_day; end
    end 
    else if (cur_in_act == Check_Valid_Date) begin
        if (is_early) expected_warn = Date_Warn;
        else expected_comp = 1;
        cur_shop.M = in_mth; cur_shop.D = in_day;
    end
    
    cur_shop.level = t_lvl;
    cur_shop.staff = t_staff;
    cur_shop.sales = t_sales;
    cur_shop.balance = t_bal;
    cur_shop.flour = t_f;
    cur_shop.butter = t_b;
    cur_shop.milk = t_m;
    cur_shop.sugar = t_s;
    cur_shop.fruit = t_fr;
    
    sim_dram_data[target_shop_id] = cur_shop;
    warn_stats[expected_warn]++;
endtask

task automatic drive_action(Action act);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.sel_action_valid = 1; inf.D = {69'b0, act};
    @(negedge clk); inf.sel_action_valid = 0; inf.D = 'bx;
endtask

task automatic drive_type(Dessert_Type type_in);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.type_valid = 1; inf.D = {69'b0, type_in};
    @(negedge clk); inf.type_valid = 0; inf.D = 'bx;
endtask

task automatic drive_mode(Order_Mode mode_in);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.mode_valid = 1; inf.D = {70'b0, mode_in};
    @(negedge clk); inf.mode_valid = 0; inf.D = 'bx;
endtask

task automatic drive_date(int M, int D);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.date_valid = 1; inf.D = {63'b0, M[3:0], D[4:0]};
    @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
endtask

task automatic drive_data_no(int data_no);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.data_no_valid = 1; inf.D = {64'b0, data_no[7:0]};
    @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
endtask

task automatic drive_restock(int amt);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.restock_valid = 1; inf.D = {60'b0, amt[11:0]};
    @(negedge clk); inf.restock_valid = 0; inf.D = 'bx;
endtask

task automatic drive_staff(int staff);
    int safe_delay = $urandom_range(1, 3); 
    repeat(safe_delay) @(negedge clk);
    inf.staff_valid = 1; inf.D = {64'b0, staff[7:0]};
    @(negedge clk); inf.staff_valid = 0; inf.D = 'bx;
endtask

task automatic wait_out_valid();
    int chk_lat = 0;
    while(inf.out_valid !== 1) begin
        chk_lat++;
        if (chk_lat > 1000) begin
            $display("Wrong Answer");
            $finish;
        end
        @(negedge clk);
    end
    
    if (inf.complete !== expected_comp || inf.warn_msg !== expected_warn) begin
        $display("Wrong Answer");
        $finish;
    end
    
    while(inf.out_valid === 1) @(negedge clk);

    if (expected_warn === Date_Warn && cur_in_act !== Check_Valid_Date) begin
        if (w0_done || w1_done) begin
            $display("Wrong Answer");
            $finish;
        end
    end 
    else begin
        if (!w0_done) begin
            $display("Wrong Answer");
            $finish;
        end
        if ((expected_comp === 1 && cur_in_act !== Check_Valid_Date) ||
            (cur_in_act === Pay_Day && expected_warn === Balance_Warn) ||
            (cur_in_act === Hire_Staff && expected_warn === Staff_Warn) ||
            (cur_in_act === Restock && expected_warn === Restock_Warn)) begin
            if (!w1_done) begin
                $display("Wrong Answer");
                $finish;
            end
        end
    end
endtask

initial begin
    forever begin
        @(posedge clk);
        
        if (inf.AW_VALID && inf.AW_READY) begin
            write_addr_fifo.push_back(inf.AW_ADDR);
        end
        
        if (inf.W_VALID && inf.W_READY) begin
            int act_aw_addr;
            int dram_idx;
            int byte_offset;
            logic [63:0] cmp_data;

            if (write_addr_fifo.size() > 0) begin
                act_aw_addr = write_addr_fifo.pop_front();
            end else begin
                $display("Wrong Answer");
                $finish;
            end

            dram_idx = (act_aw_addr - 17'h10000) / 16;
            byte_offset = (act_aw_addr - 17'h10000) % 16;

            if (dram_idx !== target_shop_id) begin
                $display("Wrong Answer");
                $finish;
            end

            if (byte_offset == 0) begin
                cmp_data = {sim_dram_data[dram_idx].flour, sim_dram_data[dram_idx].butter, sim_dram_data[dram_idx].M, sim_dram_data[dram_idx].milk, sim_dram_data[dram_idx].sugar, sim_dram_data[dram_idx].D};
                w0_done = 1;
            end 
            else begin
                cmp_data = {sim_dram_data[dram_idx].fruit, sim_dram_data[dram_idx].sales, sim_dram_data[dram_idx].staff, sim_dram_data[dram_idx].balance, sim_dram_data[dram_idx].level};
                w1_done = 1;
            end

            if (inf.W_DATA !== cmp_data) begin
                $display("Wrong Answer");
                $finish;
            end
        end
    end
end

initial begin
    int i, bs_addr;
    logic [63:0] w0_rd, w1_rd;

    warn_stats[0]=0; warn_stats[1]=0; warn_stats[2]=0; warn_stats[3]=0; warn_stats[4]=0; warn_stats[5]=0; warn_stats[6]=0;
    type_mode_idx = 0;
    
    base_p_tbl[0]=120; base_p_tbl[1]=100; base_p_tbl[2]=400; base_p_tbl[3]=180; base_p_tbl[4]=250; base_p_tbl[5]=200; base_p_tbl[6]=280; base_p_tbl[7]=160;
    req_f_tbl[0]=100;  req_f_tbl[1]=200;  req_f_tbl[2]=150;  req_f_tbl[3]=0;    req_f_tbl[4]=40;   req_f_tbl[5]=120;  req_f_tbl[6]=80;   req_f_tbl[7]=150;
    req_b_tbl[0]=50;   req_b_tbl[1]=20;   req_b_tbl[2]=80;   req_b_tbl[3]=0;    req_b_tbl[4]=30;   req_b_tbl[5]=30;   req_b_tbl[6]=100;  req_b_tbl[7]=60;
    req_m_tbl[0]=0;    req_m_tbl[1]=50;   req_m_tbl[2]=40;   req_m_tbl[3]=150;  req_m_tbl[4]=0;    req_m_tbl[5]=80;   req_m_tbl[6]=0;    req_m_tbl[7]=30;
    req_s_tbl[0]=30;   req_s_tbl[1]=10;   req_s_tbl[2]=60;   req_s_tbl[3]=50;   req_s_tbl[4]=120;  req_s_tbl[5]=20;   req_s_tbl[6]=100;  req_s_tbl[7]=20;
    req_fr_tbl[0]=0;   req_fr_tbl[1]=0;   req_fr_tbl[2]=100; req_fr_tbl[3]=20;  req_fr_tbl[4]=0;   req_fr_tbl[5]=40;  req_fr_tbl[6]=0;   req_fr_tbl[7]=10;

    inf.rst_n = 1'b1;
    inf.sel_action_valid = 0;
    inf.type_valid = 0;
    inf.mode_valid = 0;
    inf.date_valid = 0;
    inf.data_no_valid = 0;
    inf.staff_valid = 0;
    inf.restock_valid = 0;
    inf.D = 'bx;
    
    force clk = 0;
    #(`CYCLE_TIME) inf.rst_n = 0;
    #(`CYCLE_TIME*3) inf.rst_n = 1;
    release clk;

    $readmemh(DRAM_PATH, dram_init_data);
    for (i=0; i<128; i++) begin
        bs_addr = 65536 + i*16;
        w0_rd = {dram_init_data[bs_addr+7], dram_init_data[bs_addr+6], dram_init_data[bs_addr+5], dram_init_data[bs_addr+4], 
                 dram_init_data[bs_addr+3], dram_init_data[bs_addr+2], dram_init_data[bs_addr+1], dram_init_data[bs_addr+0]};
        w1_rd = {dram_init_data[bs_addr+15], dram_init_data[bs_addr+14], dram_init_data[bs_addr+13], dram_init_data[bs_addr+12], 
                 dram_init_data[bs_addr+11], dram_init_data[bs_addr+10], dram_init_data[bs_addr+9], dram_init_data[bs_addr+8]};
                 
        sim_dram_data[i].flour   = w0_rd[63:52];
        sim_dram_data[i].butter  = w0_rd[51:40];
        sim_dram_data[i].M       = w0_rd[39:32];
        sim_dram_data[i].milk    = w0_rd[31:20];
        sim_dram_data[i].sugar   = w0_rd[19:8];
        sim_dram_data[i].D       = w0_rd[7:0];
        
        sim_dram_data[i].fruit   = w1_rd[63:52];
        sim_dram_data[i].sales   = w1_rd[51:40];
        sim_dram_data[i].staff   = w1_rd[39:32];
        sim_dram_data[i].balance = w1_rd[31:8]; 
        sim_dram_data[i].level   = w1_rd[7:0];  
    end

    for (pat = 0; pat < PATNUM; pat++) begin
        w0_done = 0;
        w1_done = 0;
        
        generate_inputs();
        compute_golden();
        
        drive_action(cur_in_act);
        if (cur_in_act == Make_and_Sell) begin
            drive_type(cur_in_type);
            drive_mode(cur_in_mode);
            drive_date(in_mth, in_day);
            drive_data_no(target_shop_id);
        end 
        else if (cur_in_act == Restock) begin
            drive_date(in_mth, in_day);
            drive_data_no(target_shop_id);
            drive_restock(rand_flour);
            drive_restock(rand_butter);
            drive_restock(rand_milk);
            drive_restock(rand_sugar);
            drive_restock(rand_fruit);
        end 
        else if (cur_in_act == Hire_Staff) begin
            drive_staff(rand_hire_cnt);
            drive_date(in_mth, in_day);
            drive_data_no(target_shop_id);
        end 
        else begin
            drive_date(in_mth, in_day);
            drive_data_no(target_shop_id);
        end
        
        wait_out_valid();
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

endprogram