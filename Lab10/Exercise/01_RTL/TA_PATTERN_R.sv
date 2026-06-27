`include "Usertype.sv"
`define CYCLE_TIME 7.0

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter MAX_CYCLE = 1000;
parameter simulation_cycle = `CYCLE_TIME;

logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)]; // 0x10000 to 0x107FF
integer PATNUM = 10000;
integer i, j;
integer latency;
integer total_latency;

//================================================================
// class random
//================================================================
class random_data;
    rand Action         act;
    rand Dessert_Type   d_type;
    rand Order_Mode     d_mode;
    rand Month          month;
    rand Day            day;
    rand Staff_t        staff;
    rand Data_No        data_no;
    randc Stock         restock_amount[5];

    // Distribute actions evenly (SPEC 5)
    constraint action_dist {
        act dist { Make_and_Sell:=40, Restock:=20, Hire_Staff:=20, Pay_Day:=20, Check_Valid_Date:=20 };
    }

    constraint limit_shop_no {
        data_no inside {[0:127]};
    }

    // Distribute Order_Mode evenly (SPEC 2 & 3)
    constraint mode_dist {
        d_mode dist { Single:=33, Family_Set:=33, Party_Pack:=34 };
    }

    constraint limit_date {
        month inside {[1:12]};
        if (month == 2) day inside {[1:28]};
        else if (month == 4 || month == 6 || month == 9 || month == 11) day inside {[1:30]};
        else day inside {[1:31]};
    }

    // Uniform distribution for restock_amount (SPEC 6)
    constraint limit_stock { 
        foreach(restock_amount[i]) {
            restock_amount[i] inside {[0:2047]};
        }
    }

    // Limit staff hired per action
    constraint limit_staff { 
        staff inside {[1:30]}; 
    }

    //================================================================
    // post_randomize to prevent Date_Warn deadlock
    //================================================================
    function void post_randomize();
        int base_addr;
        int cur_m, cur_d;

        // Get current date from Golden DRAM
        base_addr = 65536 + (data_no * 16);
        cur_m = golden_DRAM[base_addr+4];
        cur_d = golden_DRAM[base_addr+0]; 

        // 85% chance to overwrite with current date to avoid Date_Warn
        // 15% chance to keep random date for coverage
        if ($urandom() % 100 < 85) begin
            month = cur_m;
            day = cur_d;
        end
    endfunction
    //================================================================

endclass

//================================================================
// DRAM data class
//================================================================
class dram_data;
    rand Month         month;
    rand Day           day;
    rand logic [11:0]  milk, sugar, flour, butter, fruit;
    rand logic [7:0]   level;
    rand logic [7:0]   staff;
    rand logic [11:0]  sales;
    rand logic [23:0]  balance;

    // Concentrate initial dates in Jan-Mar
    constraint limit_date {
        month inside {[1:3]};
        if (month == 2) day inside {[1:28]};
        else day inside {[1:31]};
    }

    // Extreme stock distribution (50% empty, 50% full)
    constraint limit_ingredients {
        milk   dist { [0:150] :/ 50, [3800:4095] :/ 50 };
        sugar  dist { [0:150] :/ 50, [3800:4095] :/ 50 };
        flour  dist { [0:150] :/ 50, [3800:4095] :/ 50 };
        butter dist { [0:150] :/ 50, [3800:4095] :/ 50 };
        fruit  dist { [0:150] :/ 50, [3800:4095] :/ 50 };
    }

    // Staff distribution (15% 0, 35% 1-50, 50% 80-100)
    constraint limit_staff {
        staff dist { 0 := 15, [1:50] :/ 35, [80:100] :/ 50 };
    }

    // Calculate valid sales based on level
    constraint limit_level_sales {
        level inside {[0:100]};
        if (level == 100) {
            sales inside {[0:4095]};
        } else if (level < 10) {
            sales inside {[0:9]};
        } else {
            // sales must be less than upgrade threshold (10 * L)
            sales >= 0;
            sales < (10 * (level / 10)); 
        }
    }

    // Extreme balance distribution (avoid 24-bit sign bug)
    constraint limit_balance {
        balance dist { [0:30000] :/ 50, [1000000:8000000] :/ 50 };
    }
endclass

//================================================================
// initial
//================================================================
initial begin
    random_data rnd_data = new(); 
    
    // 1. Generate and read DRAM at Simulation Time = 0
    initial_task();

    // 2. Reset hardware
    reset_task();
    total_latency = 0;

    for (i = 0; i < PATNUM; i = i + 1) begin
        assert(rnd_data.randomize()) 
        else $fatal(0, "Randomize fail!");

        input_task(rnd_data); 
        wait_out_task();      
        check_task(rnd_data); 

        if (i % 100 == 0) $display("\033[0;32mPattern %0d passed!\033[0m", i);
    end

    $display("========================================");
    $display("  Congratulations! All %0d patterns passed! ", PATNUM);
    $display("  Total Latency: %0d cycles", total_latency);
    $display("========================================");
    $finish;
end

//================================================================
// Generate DRAM Data Task (Procedural Randomization)
//================================================================
function int generate_dram_func();
    integer fd;
    integer addr;
    logic [31:0] word0, word1, word2, word3;
    
    // Instantiate OOP object
    dram_data d_data = new(); 

    fd = $fopen(DRAM_p_r, "w");
    if (fd == 0) begin
        $display("[ERROR] Cannot open %s for writing!", DRAM_p_r);
        return 0;
    end

    for (int i = 0; i < 128; i++) begin
        addr = 'h10000 + i * 16;
        
        // Randomize dram data
        if (!d_data.randomize()) begin
            $display("[ERROR] DRAM Randomize fail!");
            return 0;
        end

        // Combine variables into 32-bit Words
        word0 = (d_data.milk << 20)  | (d_data.sugar << 8)  | d_data.day;
        word1 = (d_data.flour << 20) | (d_data.butter << 8) | d_data.month;
        word2 = (d_data.balance << 8)| d_data.level;
        word3 = (d_data.fruit << 20) | (d_data.sales << 8)  | d_data.staff;

        $fdisplay(fd, "@%5X", addr);
        $fdisplay(fd, "%02X %02X %02X %02X", word0[7:0], word0[15:8], word0[23:16], word0[31:24]);
        $fdisplay(fd, "@%5X", addr + 4);
        $fdisplay(fd, "%02X %02X %02X %02X", word1[7:0], word1[15:8], word1[23:16], word1[31:24]);
        $fdisplay(fd, "@%5X", addr + 8);
        $fdisplay(fd, "%02X %02X %02X %02X", word2[7:0], word2[15:8], word2[23:16], word2[31:24]);
        $fdisplay(fd, "@%5X", addr + 12);
        $fdisplay(fd, "%02X %02X %02X %02X", word3[7:0], word3[15:8], word3[23:16], word3[31:24]);
    end
    
    $fclose(fd);
    $display("\033[0;32m[MAGIC] DRAM Data Generated BEFORE t=0 (OOP Mode)!\033[0m");
    return 1;
endfunction

// Trigger generation before any initial block
int dummy_dram_trigger = generate_dram_func();

//================================================================
// Tasks
//================================================================
task reset_task;
begin
    inf.rst_n = 1;
    inf.sel_action_valid = 0;
    inf.type_valid = 0;
    inf.mode_valid = 0;
    inf.date_valid = 0;
    inf.staff_valid = 0;
    inf.data_no_valid = 0;
    inf.restock_valid = 0;
    inf.D = 'bx;

    #5  inf.rst_n = 0;
    
    // Hold reset for 20 ns
    #20;
    
    // Check output signals before releasing reset
    if (inf.out_valid !== 0 || inf.complete !== 0 || inf.warn_msg !== No_Warn ||
        inf.AR_VALID !== 0 || inf.AR_ADDR !== 0 || inf.R_READY !== 0 ||
        inf.AW_VALID !== 0 || inf.AW_ADDR !== 0 || 
        inf.W_VALID !== 0 || inf.W_DATA !== 0 || inf.B_READY !== 0) begin
        
        $display("\033[0;31m[ERROR] All output signals must be 0 after reset!\033[0m");
        $finish;
    end
    
    // Release reset
    inf.rst_n = 1;
    
    // Align to next negative edge of clock
    @(negedge clk);
end
endtask

task initial_task;
begin
    $readmemh(DRAM_p_r, golden_DRAM);
    $display("Golden DRAM Initialized Successfully!");
end
endtask

// Generate 1 to 4 cycles of random delay
task random_delay;
    integer delay_cycles;
begin
    // 0 means consecutive, 3 means 3 cycles apart (max delay 4)
    delay_cycles = $urandom_range(0, 3);
    for(int k=0; k < delay_cycles; k++) @(negedge clk);
end
endtask

task input_task(random_data rnd_data);
begin
    // 1. Send Action
    random_delay();

    inf.sel_action_valid = 1'b1;
    inf.D = {69'b0, rnd_data.act};
    @(negedge clk);
    inf.sel_action_valid = 1'b0;
    inf.D = 'bx;

    // 2. Send corresponding inputs based on Action
    case(rnd_data.act)
        Make_and_Sell: begin
            random_delay();
            inf.type_valid = 1'b1; inf.D = {69'b0, rnd_data.d_type}; @(negedge clk); inf.type_valid = 0; inf.D = 'bx;
            random_delay();
            inf.mode_valid = 1'b1;
            inf.D = {70'b0, rnd_data.d_mode}; @(negedge clk); inf.mode_valid = 0; inf.D = 'bx;
            random_delay();
            inf.date_valid = 1'b1;
            inf.D = {63'b0, rnd_data.month, rnd_data.day}; @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
            random_delay();
            inf.data_no_valid = 1'b1;
            inf.D = {64'b0, rnd_data.data_no}; @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
        end
        Restock: begin
            random_delay();
            inf.date_valid = 1'b1; inf.D = {63'b0, rnd_data.month, rnd_data.day}; @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
            
            random_delay();
            inf.data_no_valid = 1'b1;
            inf.D = {64'b0, rnd_data.data_no}; @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
            
            // Delay before first restock_valid
            random_delay();
            
            // Send 5 restock amounts sequentially
            for (int k=0; k<5; k++) begin
                inf.restock_valid = 1'b1;
                inf.D = {60'b0, rnd_data.restock_amount[k]}; 
                @(negedge clk); 
                
                // Randomly decide to break valid signal
                if (k < 4) begin
                    int is_continuous = $urandom_range(0, 1);
                    
                    // 50% chance to break
                    if (is_continuous == 0) begin
                        // Break valid and wait
                        inf.restock_valid = 1'b0; 
                        inf.D = 'bx;
                        random_delay();
                    end
                    // Keep valid high for continuous transmission if is_continuous == 1
                end 
                else begin
                    // Pull down valid after last item
                    inf.restock_valid = 1'b0;
                    inf.D = 'bx;
                end
            end
        end
        Hire_Staff: begin
            random_delay();
            inf.staff_valid = 1'b1; inf.D = {64'b0, rnd_data.staff}; @(negedge clk); inf.staff_valid = 0; inf.D = 'bx;
            random_delay();
            inf.date_valid = 1'b1;
            inf.D = {63'b0, rnd_data.month, rnd_data.day}; @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
            random_delay();
            inf.data_no_valid = 1'b1;
            inf.D = {64'b0, rnd_data.data_no}; @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
        end
        Pay_Day, Check_Valid_Date: begin
            random_delay();
            inf.date_valid = 1'b1; inf.D = {63'b0, rnd_data.month, rnd_data.day}; @(negedge clk); inf.date_valid = 0; inf.D = 'bx;
            random_delay();
            inf.data_no_valid = 1'b1;
            inf.D = {64'b0, rnd_data.data_no}; @(negedge clk); inf.data_no_valid = 0; inf.D = 'bx;
        end
    endcase
end
endtask

// Check: output must be 0 when out_valid is low
task check_ans_is_zero_task;
begin
    if (inf.out_valid === 1'b0) begin
        if (inf.complete !== 1'b0 || inf.warn_msg !== No_Warn) begin
            $display("\033[0;31m[ERROR] Output signals must be 0 when out_valid is low!\033[0m");
            $finish;
        end
    end
end
endtask

task wait_out_task;
begin
    latency = 0;
    while(inf.out_valid === 1'b0) begin
        latency = latency + 1;
        if(latency > MAX_CYCLE) begin
            $display("\033[0;31mError: Latency exceeded %0d cycles!\033[0m", MAX_CYCLE);
            $finish;
        end
        
        // Check strictly in each waiting cycle
        check_ans_is_zero_task();
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end
endtask

task check_task(random_data rnd_data);
    int base_addr;
    logic [11:0] dram_milk, dram_sugar, dram_flour, dram_butter, dram_fruit, dram_sales;
    logic [7:0]  dram_day, dram_month, dram_level, dram_staff;
    logic [23:0] dram_balance;
    
    // Use 32-bit int to prevent overflow
    int cur_milk, cur_sugar, cur_flour, cur_butter, cur_fruit, cur_sales;
    int cur_day, cur_month, cur_level, cur_staff;
    int cur_balance;
    
    Warn_Msg expected_warn;
    logic    expected_complete;
    
    int recipe_flour[8]  = '{100, 200, 150,   0,  40, 120,  80, 150};
    int recipe_butter[8] = '{ 50,  20,  80,   0,  30,  30, 100,  60};
    int recipe_milk[8]   = '{  0,  50,  40, 150,   0,  80,   0,  30};
    int recipe_sugar[8]  = '{ 30,  10,  60,  50, 120,  20, 100,  20};
    int recipe_fruit[8]  = '{  0,   0, 100,  20,   0,  40,   0,  10};
    int price_base[8]    = '{120, 100, 400, 180, 250, 200, 280, 160};

    int scale;
    int req_flour, req_butter, req_milk, req_sugar, req_fruit;
    int unit_price, earn_money;
    int L, level_multiplier;
    int cost_f, cost_b, cost_m, cost_s, cost_fr;
    int total_cost;
    int act_add_f, act_add_b, act_add_m, act_add_s, act_add_fr, act_add_staff;
    int hire_fee_per_person, total_salary;
    int upgrade_req;
    
begin
    base_addr = 65536 + (rnd_data.data_no * 16);
    
    // 1. Read current state from Golden DRAM
    {dram_milk, dram_sugar, dram_day}       = {golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]};
    {dram_flour, dram_butter, dram_month}   = {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4]};
    {dram_balance, dram_level}              = {golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9], golden_DRAM[base_addr+8]};
    {dram_fruit, dram_sales, dram_staff}    = {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12]};
    
    // Cast to 32-bit int for safe calculation
    cur_milk = dram_milk; cur_sugar = dram_sugar; cur_day = dram_day;
    cur_flour = dram_flour; cur_butter = dram_butter; cur_month = dram_month;
    cur_balance = dram_balance; cur_level = dram_level;
    cur_fruit = dram_fruit;
    cur_sales = dram_sales; cur_staff = dram_staff;

    expected_warn = No_Warn;
    expected_complete = 1'b1;
    
    // 2. Pre-calculate Table 5 formulas
    L = cur_level / 10;
    level_multiplier = 10 + L;
    cost_f  = (15 * level_multiplier) / 10;
    cost_b  = (60 * level_multiplier) / 10;
    cost_m  = (25 * level_multiplier) / 10;
    cost_s  = (10 * level_multiplier) / 10;
    cost_fr = (80 * level_multiplier) / 10;

    // 3. Priority check: Date_Warn 
    // All actions must be checked for Date_Warn
    if (rnd_data.month < cur_month || (rnd_data.month == cur_month && rnd_data.day < cur_day)) begin
        expected_warn = Date_Warn;
        expected_complete = 1'b0;
    end 
    else begin
        case(rnd_data.act)
            Make_and_Sell: begin
                if (rnd_data.d_mode == Single) scale = 1;
                else if (rnd_data.d_mode == Family_Set) scale = 4;
                else scale = 8;
                
                req_flour  = recipe_flour[rnd_data.d_type]  * scale;
                req_butter = recipe_butter[rnd_data.d_type] * scale;
                req_milk   = recipe_milk[rnd_data.d_type]   * scale;
                req_sugar  = recipe_sugar[rnd_data.d_type]  * scale;
                req_fruit  = recipe_fruit[rnd_data.d_type]  * scale;
                
                if (cur_staff == 0) begin
                    expected_warn = No_Staff_Warn;
                    expected_complete = 1'b0;
                end 
                else if (cur_flour < req_flour || cur_butter < req_butter || cur_milk < req_milk || cur_sugar < req_sugar || cur_fruit < req_fruit) begin
                    expected_warn = Stock_Warn;
                    expected_complete = 1'b0;
                end 
                else begin
                    unit_price = (price_base[rnd_data.d_type] * level_multiplier) / 10 + (cur_level * cur_level) / 200;
                    earn_money = unit_price * scale;
                    
                    cur_flour  -= req_flour;
                    cur_butter -= req_butter;
                    cur_milk   -= req_milk;
                    cur_sugar  -= req_sugar;
                    cur_fruit  -= req_fruit;
                    
                    cur_balance += earn_money;
                    if (cur_balance > 16777215) cur_balance = 16777215;
                    
                    cur_sales += scale;
                    
                    // Upgrade level level-by-level
                    while (cur_level < 100) begin
                        int current_L = cur_level / 10;
                        int current_req = (10 > (10 * current_L)) ? 10 : (10 * current_L);
                        
                        if (cur_sales >= current_req) begin
                            // Level up
                            cur_level += 1;
                            // Deduct sales
                            cur_sales -= current_req;
                        end else begin
                            // Not enough to level up, break loop
                            break;
                        end
                    end
                    
                    if (cur_level >= 100) begin
                        cur_level = 100;
                        if (cur_sales > 4095) cur_sales = 4095;
                    end
                end
            end

            Restock: begin
                act_add_f  = ((cur_flour + rnd_data.restock_amount[0]) > 4095) ?
                             (4095 - cur_flour) : rnd_data.restock_amount[0];
                act_add_b  = ((cur_butter + rnd_data.restock_amount[1]) > 4095) ? (4095 - cur_butter) : rnd_data.restock_amount[1];
                act_add_m  = ((cur_milk + rnd_data.restock_amount[2]) > 4095) ? (4095 - cur_milk) : rnd_data.restock_amount[2];
                act_add_s  = ((cur_sugar + rnd_data.restock_amount[3]) > 4095) ? (4095 - cur_sugar) : rnd_data.restock_amount[3];
                act_add_fr = ((cur_fruit + rnd_data.restock_amount[4]) > 4095) ? (4095 - cur_fruit) : rnd_data.restock_amount[4];
                
                // Calculate actual cost for Balance_Warn
                total_cost = act_add_f*cost_f + act_add_b*cost_b + act_add_m*cost_m + act_add_s*cost_s + act_add_fr*cost_fr;
                
                if (cur_balance < total_cost) begin 
                    expected_warn = Balance_Warn;
                    expected_complete = 1'b0;
                end else if ((cur_flour + rnd_data.restock_amount[0] > 4095) || 
                             (cur_butter + rnd_data.restock_amount[1] > 4095) || 
                             (cur_milk + rnd_data.restock_amount[2] > 4095) || 
                             (cur_sugar + rnd_data.restock_amount[3] > 4095) || 
                             (cur_fruit + rnd_data.restock_amount[4] > 4095)) begin
                    expected_warn = Restock_Warn;
                    expected_complete = 1'b0;
                    cur_flour += act_add_f; cur_butter += act_add_b; cur_milk += act_add_m; 
                    cur_sugar += act_add_s; cur_fruit += act_add_fr;
                    cur_balance -= total_cost;
                end else begin
                    cur_flour += act_add_f;
                    cur_butter += act_add_b; cur_milk += act_add_m; 
                    cur_sugar += act_add_s; cur_fruit += act_add_fr;
                    cur_balance -= total_cost;
                end
            end

            Hire_Staff: begin
                act_add_staff = ((cur_staff + rnd_data.staff) > 100) ?
                                (100 - cur_staff) : rnd_data.staff;
                hire_fee_per_person = 2000 + cur_level*100 + L*200;
                
                // Calculate actual cost for Balance_Warn
                total_cost = hire_fee_per_person * act_add_staff;
                
                if (cur_balance < total_cost) begin 
                    expected_warn = Balance_Warn;
                    expected_complete = 1'b0;
                end else if (cur_staff + rnd_data.staff > 100) begin
                    expected_warn = Staff_Warn;
                    expected_complete = 1'b0;
                    cur_staff += act_add_staff;
                    cur_balance -= total_cost;
                end else begin
                    cur_staff += act_add_staff;
                    cur_balance -= total_cost;
                end
            end

            Pay_Day: begin
                total_salary = (20000 + cur_level*200 + L*1000) * cur_staff;
                
                if (cur_staff == 0) begin
                    expected_warn = No_Staff_Warn;
                    expected_complete = 1'b0;
                end 
                else if (cur_balance < total_salary) begin
                    expected_warn = Balance_Warn;
                    expected_complete = 1'b0;
                    cur_level = (cur_level >= 10) ? (cur_level - 10) : 0;
                    cur_staff = (cur_staff > 1) ?
                                (cur_staff / 2) : 1;
                    cur_sales = 0;
                end 
                else begin
                    cur_balance -= total_salary;
                end
            end

            Check_Valid_Date: begin
                // Handled in outer block
            end
        endcase
    end

    // 4. Compare design outputs
    if (inf.warn_msg !== expected_warn || inf.complete !== expected_complete) begin
        $display("=================================================");
        $display("\033[0;31m[ERROR] Pattern %0d Failed!\033[0m", i);
        $display(" ----------------------------------------------- ");
        $display("Action: %s", rnd_data.act.name());
        $display("Expected: complete=%b, warn_msg=%s", expected_complete, expected_warn.name());
        $display("Your Out: complete=%b, warn_msg=%s", inf.complete, inf.warn_msg.name());
        $display("=================================================");
        $finish;
    end
    
    @(negedge clk);
    
    if (inf.out_valid === 1'b1) begin
        $display("\033[0;31m[ERROR] out_valid should only be HIGH for 1 cycle!\033[0m");
        $finish;
    end

    // 5. Write back to Golden DRAM
    // Spec Rule 3: Update date if no Date_Warn
    // Check_Valid_Date always updates date
    if (expected_warn != Date_Warn || rnd_data.act == Check_Valid_Date) begin
        cur_month = rnd_data.month;
        cur_day = rnd_data.day;
    end

    // Cast int back to corresponding bit width logic
    dram_milk = 12'(cur_milk);
    dram_sugar = 12'(cur_sugar); dram_day = 8'(cur_day);
    dram_flour = 12'(cur_flour); dram_butter = 12'(cur_butter); dram_month = 8'(cur_month);
    dram_balance = 24'(cur_balance);
    dram_level = 8'(cur_level);
    dram_fruit = 12'(cur_fruit); dram_sales = 12'(cur_sales); dram_staff = 8'(cur_staff);

    {golden_DRAM[base_addr+3], golden_DRAM[base_addr+2], golden_DRAM[base_addr+1], golden_DRAM[base_addr+0]} = {dram_milk, dram_sugar, dram_day};
    {golden_DRAM[base_addr+7], golden_DRAM[base_addr+6], golden_DRAM[base_addr+5], golden_DRAM[base_addr+4]} = {dram_flour, dram_butter, dram_month};
    {golden_DRAM[base_addr+11], golden_DRAM[base_addr+10], golden_DRAM[base_addr+9], golden_DRAM[base_addr+8]} = {dram_balance, dram_level};
    {golden_DRAM[base_addr+15], golden_DRAM[base_addr+14], golden_DRAM[base_addr+13], golden_DRAM[base_addr+12]} = {dram_fruit, dram_sales, dram_staff};
end
endtask

endprogram