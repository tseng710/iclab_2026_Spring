// ============================================================================
//  NYCU-EE IC LAB Fall 2026 - Lab07 Exercise
//  Design : Harvester with Clock Domain Crossing
//  File   : PATTERN.v (Auto-Overwrite Debug Version + Floating Point Golden)
// ============================================================================

`ifdef RTL
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_1
    `define CYCLE_TIME_clk1 34.7
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 11.3
`endif
`ifdef Period_2
    `define CYCLE_TIME_clk1 11.3
    `define CYCLE_TIME_clk2 20.1
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef Period_3
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7
`endif
`ifdef GATE
    `define CYCLE_TIME_clk1 20.1
    `define CYCLE_TIME_clk2 11.3
    `define CYCLE_TIME_clk3 34.7

/*
`define CYCLE_TIME_clk1 20.1
`define CYCLE_TIME_clk2 11.3
`define CYCLE_TIME_clk3 34.7*/
`endif

module PATTERN (
           output reg          clk1,
           output reg          clk2,
           output reg          clk3,
           output reg          rst_n,

           input      [31:0]   ar_addr_clk2,
           input               ar_valid_clk2,
           input               ar_ready_clk2,
           input      [63:0]   r_data_clk2,
           input               r_valid_clk2,
           input               r_ready_clk2,

           input      [31:0]   ar_addr_clk3,
           input               ar_valid_clk3,
           input               ar_ready_clk3,
           input      [63:0]   r_data_clk3,
           input               r_valid_clk3,
           input               r_ready_clk3,

           output reg          in_mode_valid,
           output reg          in_mode,
           output reg          in_valid,
           output reg [1:0]    in_bank,
           output reg [5:0]    in_src_row,

           input               out_valid,
           input      [63:0]   out_data
       );

parameter TOTAL_PAT_NUM = 1020;
parameter LATENCY_LIMIT = 90000;
parameter AXI_TIMEOUT1  = 500;
parameter AXI_TIMEOUT2  = 500;

integer i, j, k, b;
integer pat_num;
integer latency_cnt;
integer fout;

// --- 統計用變數 ---
integer calc_latency_sum = 0;
integer gauss_latency_sum = 0;
integer calc_pat_cnt = 0;
integer gauss_pat_cnt = 0;

reg       cur_mode;
reg [1:0] banks_arr [0:3];
reg [5:0] rows_arr  [0:3];

reg [63:0] golden_DRAM [0:3][0:63][0:255];
reg [63:0] golden_ans [0:1024];
integer    golden_num;

reg [63:0]  gauss_words [0:1023];
integer     valid_cnt;
integer     c;

// --- 浮點數運算變數 (堅持使用 real 確保絕對精準度) ---
real r_sum;
real r_mean;
real r_var_sum;
real r_var;
real r_sigma;
real r_lo_thr, r_hi_thr;
real r_val_ext;

reg fail_reset, fail_latency, fail_out_cycle, fail_out_data;
reg fail_axi2_reset, fail_axi2_stable, fail_axi2_range, fail_axi2_timeout1, fail_axi2_timeout2;
reg fail_axi3_reset, fail_axi3_stable, fail_axi3_range, fail_axi3_timeout1, fail_axi3_timeout2;
reg start_bg_check;

reg [31:0] last_ar_addr_clk2;
reg last_ar_valid_clk2;
reg last_ar_ready_clk2;
reg [63:0] last_r_data_clk2;
reg last_r_valid_clk2;
reg last_r_ready_clk2;
reg [31:0] last_ar_addr_clk3;
reg last_ar_valid_clk3;
reg last_ar_ready_clk3;
reg [63:0] last_r_data_clk3;
reg last_r_valid_clk3;
reg last_r_ready_clk3;

integer ar_wait_clk2, r_wait_clk2, ar_wait_clk3, r_wait_clk3;
integer outstanding_clk2, outstanding_clk3, ar_r_delay_clk2, ar_r_delay_clk3;

initial
    clk1 = 1'b0;
always #(`CYCLE_TIME_clk1/2.0) clk1 = ~clk1;

initial
    clk2 = 1'b0;
always #(`CYCLE_TIME_clk2/2.0) clk2 = ~clk2;

initial
    clk3 = 1'b0;
always #(`CYCLE_TIME_clk3/2.0) clk3 = ~clk3;

// ===========================================================================
//  SAFE DEBUG LOGS (RTL Only) - 通用於任何 Design
// ===========================================================================
`ifdef RTL
always @(negedge clk1) begin
    if (start_bg_check && latency_cnt > 0 && fout != 0) begin
        // 任何人都會有 out_valid 和 out_data
        if (out_valid) begin
            $fdisplay(fout, "[Time:%8t] [CLK1] Latency=%05d | out_valid=%b DUT_out=%16x",
                      $time, latency_cnt, out_valid, out_data);
        end
    end
end

always @(negedge clk2) begin
    if (start_bg_check && latency_cnt > 0 && fout != 0) begin
        // 只要 AXI 2 有動作就印出來
        if (ar_valid_clk2 || ar_ready_clk2 || r_valid_clk2 || r_ready_clk2) begin
            $fdisplay(fout, "                  [CLK2 AXI] AR(v:%b rdy:%b addr:%8x) | R(v:%b rdy:%b data:%16x)",
                      ar_valid_clk2, ar_ready_clk2, ar_addr_clk2,
                      r_valid_clk2, r_ready_clk2, r_data_clk2);
        end
    end
end

always @(negedge clk3) begin
    if (start_bg_check && latency_cnt > 0 && fout != 0) begin
        // 只要 AXI 3 有動作就印出來
        if (ar_valid_clk3 || ar_ready_clk3 || r_valid_clk3 || r_ready_clk3) begin
            $fdisplay(fout, "                  [CLK3 AXI] AR(v:%b rdy:%b addr:%8x) | R(v:%b rdy:%b data:%16x)",
                      ar_valid_clk3, ar_ready_clk3, ar_addr_clk3,
                      r_valid_clk3, r_ready_clk3, r_data_clk3);
        end
    end
end
`endif
// ---------------------------------------------------------------------------
//  Priority Fail Watchdog
// ---------------------------------------------------------------------------
always @(negedge clk1) begin
    if (fail_reset)
        show_fail("RESET CHECK FAIL (output not cleared after rst_n asserted)");
    else if (fail_axi2_reset)
        show_fail("AXI RESET CHECK FAIL on clk2 domain (addr/data not 0 when valid low)");
    else if (fail_axi3_reset)
        show_fail("AXI RESET CHECK FAIL on clk3 domain (addr/data not 0 when valid low)");
    else if (fail_axi2_stable)
        show_fail("AXI STABILITY CHECK FAIL on clk2 domain");
    else if (fail_axi3_stable)
        show_fail("AXI STABILITY CHECK FAIL on clk3 domain");
    else if (fail_axi2_range)
        show_fail("AXI ADDR OUT OF RANGE on clk2 domain (ar_addr > 65535)");
    else if (fail_axi3_range)
        show_fail("AXI ADDR OUT OF RANGE on clk3 domain (ar_addr > 65535)");
    else if (fail_axi2_timeout1)
        show_fail("AXI TIMEOUT1 FAIL on clk2 domain (valid wait ready > 500 cycles)");
    else if (fail_axi3_timeout1)
        show_fail("AXI TIMEOUT1 FAIL on clk3 domain (valid wait ready > 500 cycles)");
    else if (fail_axi2_timeout2)
        show_fail("AXI TIMEOUT2 FAIL on clk2 domain (AR->R delay > 500 cycles)");
    else if (fail_axi3_timeout2)
        show_fail("AXI TIMEOUT2 FAIL on clk3 domain (AR->R delay > 500 cycles)");
    else if (fail_latency)
        show_fail("LATENCY LIMIT EXCEED (> 90000 clk1 cycles)");
    else if (fail_out_cycle)
        show_fail("OUT_VALID CYCLE FAIL (unexpected out_valid behavior)");
    else if (fail_out_data)
        show_fail("OUT_DATA MISMATCH (output does not match golden)");
end

task show_fail;
    input [80*8-1:0] msg;
    begin
        $display("\n================================================================================");
        $display("  FAIL at pattern #%0d :", pat_num);
        $display("  %0s", msg);
        $display("================================================================================\n");
        if (fout != 0) begin
            $fdisplay(fout, "\n================================================================================");
            $fdisplay(fout, "  FAIL at pattern #%0d :", pat_num);
            $fdisplay(fout, "  %0s", msg);
            $fdisplay(fout, "================================================================================\n");
            // 注意：不提早 fclose，讓 debug.txt 保留最後寫入的狀態
        end
        #100;
        $finish;
    end
endtask

// ---------------------------------------------------------------------------
//  Main Flow
// ---------------------------------------------------------------------------
initial begin
    // 初次打開給 Reset 用，避免 fout 為空
    fout = $fopen("debug.txt", "w");
    reset_task;

    // ★ 防止 Reset fail 後主執行緒繼續跑去覆寫檔案
    if (fail_reset)
        #10000;

    init_dram_task;
    $fclose(fout);

    for (pat_num = 0; pat_num < TOTAL_PAT_NUM; pat_num = pat_num + 1) begin
        // 每跑一個 Pattern 就重新以 "w" (覆寫) 模式打開
        fout = $fopen("debug.txt", "w");

        input_task;
        cal_golden_task;
        check_output_task;

        // ★ 修改核心防護機制：卡住主執行緒，確保 Show Fail 完全接管
        @(negedge clk1);
        if (fail_reset || fail_latency || fail_out_cycle || fail_out_data ||
                fail_axi2_reset || fail_axi2_stable || fail_axi2_range || fail_axi2_timeout1 || fail_axi2_timeout2 ||
                fail_axi3_reset || fail_axi3_stable || fail_axi3_range || fail_axi3_timeout1 || fail_axi3_timeout2) begin

            #10000; // 在這裡永久等待，讓 watchdog 順利執行 #100 和 $finish
        end

        // 累積統計延遲（走到這裡代表該 Pattern 100% Pass）
        if (cur_mode == 1'b0) begin
            calc_latency_sum = calc_latency_sum + latency_cnt;
            calc_pat_cnt = calc_pat_cnt + 1;
        end
        else begin
            gauss_latency_sum = gauss_latency_sum + latency_cnt;
            gauss_pat_cnt = gauss_pat_cnt + 1;
        end

        $display("\033[0;32m[Pass Pat#%3d]\033[0m mode=%0s  latency=%5d  #out=%0d",
                 pat_num,
                 (cur_mode == 1'b0) ? "CALC " : "GAUSS",
                 latency_cnt,
                 golden_num);

        // Pass 之後關閉檔案，確保下一輪開啟時會清空內容
        $fclose(fout);
    end

    $display("\n================================================================================");
    $display("  Congratulations! All %0d patterns passed.", TOTAL_PAT_NUM);
    $display("--------------------------------------------------------------------------------");
    if (calc_pat_cnt > 0)
        $display("  Average Latency (CALC Mode) : %7.2f cycles", 1.0 * calc_latency_sum / calc_pat_cnt);
    if (gauss_pat_cnt > 0)
        $display("  Average Latency (GAUSS Mode): %7.2f cycles", 1.0 * gauss_latency_sum / gauss_pat_cnt);
    $display("  Overall Average Latency     : %7.2f cycles", 1.0 * (calc_latency_sum + gauss_latency_sum) / TOTAL_PAT_NUM);
    $display("================================================================================\n");
    #(100);
    $finish;
end

// ---------------------------------------------------------------------------
//  Reset Task
// ---------------------------------------------------------------------------
task reset_task;
    begin
        force clk1 = 0;
        force clk2 = 0;
        force clk3 = 0;
        rst_n         = 1'b1;
        in_mode_valid = 1'b0;
        in_mode       = 1'b0;
        in_valid      = 1'b0;
        in_bank       = 2'b0;
        in_src_row    = 6'b0;

        fail_reset         = 1'b0;
        fail_latency       = 1'b0;
        fail_out_cycle     = 1'b0;
        fail_out_data      = 1'b0;
        fail_axi2_reset    = 1'b0;
        fail_axi2_stable   = 1'b0;
        fail_axi2_range    = 1'b0;
        fail_axi2_timeout1 = 1'b0;
        fail_axi2_timeout2 = 1'b0;
        fail_axi3_reset    = 1'b0;
        fail_axi3_stable   = 1'b0;
        fail_axi3_range    = 1'b0;
        fail_axi3_timeout1 = 1'b0;
        fail_axi3_timeout2 = 1'b0;

        start_bg_check = 1'b0;
        pat_num        = 0;
        latency_cnt    = 0;

        last_ar_addr_clk2  = 32'b0;
        last_ar_valid_clk2 = 1'b0;
        last_ar_ready_clk2 = 1'b0;
        last_r_data_clk2   = 64'b0;
        last_r_valid_clk2  = 1'b0;
        last_r_ready_clk2  = 1'b0;
        last_ar_addr_clk3  = 32'b0;
        last_ar_valid_clk3 = 1'b0;
        last_ar_ready_clk3 = 1'b0;
        last_r_data_clk3   = 64'b0;
        last_r_valid_clk3  = 1'b0;
        last_r_ready_clk3  = 1'b0;

        ar_wait_clk2 = 0;
        r_wait_clk2 = 0;
        ar_wait_clk3 = 0;
        r_wait_clk3 = 0;
        outstanding_clk2 = 0;
        outstanding_clk3 = 0;
        ar_r_delay_clk2 = 0;
        ar_r_delay_clk3 = 0;

        #5.0;
        rst_n = 1'b0;
        #200.0;

        if (out_valid     !== 1'b0  || out_data     !== 64'b0 ||
                ar_valid_clk2 !== 1'b0  || ar_addr_clk2 !== 32'b0 || ar_ready_clk2 !== 1'b0 ||
                r_valid_clk2  !== 1'b0  || r_data_clk2  !== 64'b0 || r_ready_clk2  !== 1'b0 ||
                ar_valid_clk3 !== 1'b0  || ar_addr_clk3 !== 32'b0 || ar_ready_clk3 !== 1'b0 ||
                r_valid_clk3  !== 1'b0  || r_data_clk3  !== 64'b0 || r_ready_clk3  !== 1'b0) begin
            fail_reset = 1'b1;
        end

        #50.0;
        rst_n = 1'b1;
        #50.0;
        release clk1;
        release clk2;
        release clk3;
        start_bg_check = 1'b1;
    end
endtask

task init_dram_task;
    begin
        for (b = 0; b < 4; b = b + 1) begin
            for (i = 0; i < 64; i = i + 1) begin
                for (j = 0; j < 256; j = j + 1) begin
                    golden_DRAM[b][i][j] = TESTBED.u_DRAM.DRAM[(b<<14) + (i<<8) + j];
                end
            end
        end
    end
endtask

task input_task;
    integer delay_cnt;
    begin
        @(negedge clk1);
        delay_cnt = $urandom_range(2, 4);
        repeat (delay_cnt) @(negedge clk1);

        if (pat_num < TOTAL_PAT_NUM / 2)
            cur_mode = 1'b0; // CALC
        else
            cur_mode = 1'b1; // GAUSS

        if (cur_mode == 1'b1) begin
            for (i = 0; i < 4; i = i + 1) begin
                banks_arr[i] = i[1:0];
                rows_arr[i]  = $urandom_range(0, 63);
            end
        end
        else begin
            for (i = 0; i < 4; i = i + 1) begin
                banks_arr[i] = $urandom_range(0, 3);
                rows_arr[i]  = $urandom_range(0, 63);
            end
        end

        if (fout != 0) begin
            $fdisplay(fout, "\n================================================================================");
            $fdisplay(fout, "[Time:%8t] [PATTERN] Start Pattern #%0d, Mode: %0s", $time, pat_num, cur_mode ? "GAUSS" : "CALC");
            for (i = 0; i < 4; i = i + 1) begin
                $fdisplay(fout, "                     -> Requesting Bank=%0d, Row=%0d", banks_arr[i], rows_arr[i]);
            end
            $fdisplay(fout, "================================================================================");
        end

        in_mode_valid = 1'b1;
        in_mode = cur_mode;
        @(negedge clk1);
        in_mode_valid = 1'b0;
        in_mode = 1'b0;

        in_valid = 1'b1;
        for (i = 0; i < 4; i = i + 1) begin
            in_bank = banks_arr[i];
            in_src_row = rows_arr[i];
            @(negedge clk1);
        end
        in_valid   = 1'b0;
        in_bank = 2'b0;
        in_src_row = 6'b0;
    end
endtask

task cal_golden_task;
    begin
        if (cur_mode == 1'b0) begin
            for (i = 0; i < 4; i = i + 1) begin
                golden_ans[i] = evaluate_tree(banks_arr[i], rows_arr[i], 8'd0);
            end
            golden_num = 4;
        end
        else begin
            c = 0;
            valid_cnt = 0;
            r_sum = 0.0;

            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 256; j = j + 1) begin
                    gauss_words[c] = golden_DRAM[banks_arr[i]][rows_arr[i]][j];
                    if (gauss_words[c][63] == 1'b0) begin
                        r_sum = r_sum + $itor({33'd0, gauss_words[c][62:32]});
                        valid_cnt = valid_cnt + 1;
                    end
                    c = c + 1;
                end
            end

            if (valid_cnt > 0) begin
                r_mean = r_sum / $itor(valid_cnt);
                r_var_sum = 0.0;

                for (c = 0; c < 1024; c = c + 1) begin
                    if (gauss_words[c][63] == 1'b0) begin
                        r_val_ext = $itor({33'd0, gauss_words[c][62:32]});
                        r_var_sum = r_var_sum + ((r_val_ext - r_mean) * (r_val_ext - r_mean));
                    end
                end

                r_var = r_var_sum / $itor(valid_cnt);
                r_sigma = $sqrt(r_var);

                r_lo_thr = r_mean - r_sigma;
                r_hi_thr = r_mean + r_sigma;
            end
            else begin
                r_lo_thr = 9999999999999999.0;
                r_hi_thr = -1.0;
            end

            // --- 把 Golden 的統計資訊一起印進去 ---
            if (fout != 0) begin
                $fdisplay(fout, "\n==================== [GOLDEN GAUSS STATS] ====================");
                $fdisplay(fout, " Valid Data Count: %0d", valid_cnt);
                $fdisplay(fout, " Sum (real):       %f", r_sum);
                $fdisplay(fout, " Mean (mu):        %f", r_mean);
                $fdisplay(fout, " Variance:         %f", r_var);
                $fdisplay(fout, " Sigma:            %f", r_sigma);
                $fdisplay(fout, " Target Range:     [%f, %f]", r_lo_thr, r_hi_thr);
                $fdisplay(fout, "==============================================================\n");
            end

            golden_num = 0;
            for (c = 0; c < 1024; c = c + 1) begin
                if (gauss_words[c][63] == 1'b0) begin
                    r_val_ext = $itor({33'd0, gauss_words[c][62:32]});
                    if (r_val_ext >= r_lo_thr && r_val_ext <= r_hi_thr) begin
                        golden_ans[golden_num] = gauss_words[c];
                        golden_num = golden_num + 1;
                    end
                end
            end

            begin : check_last_pos
                reg last_in_range;
                last_in_range = 1'b0;
                if (gauss_words[1023][63] == 1'b0) begin
                    r_val_ext = $itor({33'd0, gauss_words[1023][62:32]});
                    if (r_val_ext >= r_lo_thr && r_val_ext <= r_hi_thr)
                        last_in_range = 1'b1;
                end
                if (!last_in_range) begin
                    golden_ans[golden_num] = gauss_words[1023];
                    golden_num = golden_num + 1;
                end
            end
        end
    end
endtask

function automatic signed [63:0] evaluate_tree;
    input [1:0] bnk;
    input [5:0] row;
    input [7:0] col;
    reg [63:0] node;
    reg signed [63:0] lv, rv;
    begin
        node = golden_DRAM[bnk][row][col];
        if (node[63] == 1'b0) begin
            evaluate_tree = { {33{node[62]}}, node[62:32] };
        end
        else begin
            lv = evaluate_tree(node[31:30], node[29:24], node[23:16]);
            rv = evaluate_tree(node[15:14], node[13:8],  node[7:0]);
            case (node[33:32])
                2'b00:
                    evaluate_tree = lv + rv;
                2'b01:
                    evaluate_tree = lv - rv;
                2'b10:
                    evaluate_tree = lv * rv;
                2'b11:
                    evaluate_tree = lv >>> rv[5:0];
            endcase
        end
    end
endfunction

task check_output_task;
    integer out_cnt;
    begin
        out_cnt = 0;
        latency_cnt = 0;
        while (out_cnt < golden_num) begin
            @(negedge clk1);
            latency_cnt = latency_cnt + 1;

            if (latency_cnt > LATENCY_LIMIT) begin
                fail_latency = 1'b1;
                @(negedge clk1);
                disable check_output_task; // ★ 提早跳出，讓外層直接進入 wait block
            end

            if (out_valid === 1'b1) begin
                if (out_data !== golden_ans[out_cnt]) begin
                    $display("\n[ERROR] Output mismatch! DUT=%16x vs GOLDEN=%16x", out_data, golden_ans[out_cnt]);
                    if (fout != 0)
                        $fdisplay(fout, "\n[ERROR] Output mismatch! DUT=%16x vs GOLDEN=%16x", out_data, golden_ans[out_cnt]);
                    fail_out_data = 1'b1;
                    @(negedge clk1);
                    disable check_output_task; // ★ 提早跳出
                end
                out_cnt = out_cnt + 1;
            end
        end

        @(negedge clk1);
        if (out_valid !== 1'b0) begin
            fail_out_cycle = 1'b1;
            disable check_output_task;
        end
    end
endtask

// ===========================================================================
//  AXI Protocol Checks
// ===========================================================================
always @(negedge clk2) begin
    if (start_bg_check) begin
        if (!ar_valid_clk2 && ar_addr_clk2 !== 32'd0)
            fail_axi2_reset = 1'b1;
        if (!r_valid_clk2  && r_data_clk2  !== 64'd0)
            fail_axi2_reset = 1'b1;
        if (ar_valid_clk2 && ar_addr_clk2 > 32'd65535)
            fail_axi2_range = 1'b1;
    end
end
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        last_ar_valid_clk2 <= 0;
        last_ar_ready_clk2 <= 0;
        last_ar_addr_clk2 <= 0;
        last_r_valid_clk2 <= 0;
        last_r_ready_clk2 <= 0;
        last_r_data_clk2 <= 0;
    end
    else if (start_bg_check) begin
        if (last_ar_valid_clk2 && !last_ar_ready_clk2) begin
            if (!ar_valid_clk2 || ar_addr_clk2 !== last_ar_addr_clk2)
                fail_axi2_stable <= 1;
        end
        if (last_r_valid_clk2 && !last_r_ready_clk2) begin
            if (!r_valid_clk2 || r_data_clk2 !== last_r_data_clk2)
                fail_axi2_stable <= 1;
        end
        last_ar_valid_clk2 <= ar_valid_clk2;
        last_ar_ready_clk2 <= ar_ready_clk2;
        last_ar_addr_clk2 <= ar_addr_clk2;
        last_r_valid_clk2 <= r_valid_clk2;
        last_r_ready_clk2 <= r_ready_clk2;
        last_r_data_clk2 <= r_data_clk2;
    end
end
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        ar_wait_clk2 <= 0;
        r_wait_clk2 <= 0;
    end
    else if (start_bg_check) begin
        if (ar_valid_clk2 && !ar_ready_clk2)
            ar_wait_clk2 <= ar_wait_clk2 + 1;
        else
            ar_wait_clk2 <= 0;
        if (r_valid_clk2 && !r_ready_clk2)
            r_wait_clk2 <= r_wait_clk2 + 1;
        else
            r_wait_clk2 <= 0;
        if (ar_wait_clk2 > AXI_TIMEOUT1 || r_wait_clk2 > AXI_TIMEOUT1)
            fail_axi2_timeout1 <= 1;
    end
end
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        outstanding_clk2 <= 0;
    else if (start_bg_check) begin
        case ({ar_valid_clk2 && ar_ready_clk2, r_valid_clk2 && r_ready_clk2})
            2'b10:
                outstanding_clk2 <= outstanding_clk2 + 1;
            2'b01:
                outstanding_clk2 <= outstanding_clk2 - 1;
            default:
                outstanding_clk2 <= outstanding_clk2;
        endcase
    end
end
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n)
        ar_r_delay_clk2 <= 0;
    else if (start_bg_check) begin
        if (outstanding_clk2 > 0) begin
            if (r_valid_clk2 && r_ready_clk2)
                ar_r_delay_clk2 <= 0;
            else
                ar_r_delay_clk2 <= ar_r_delay_clk2 + 1;
        end
        else
            ar_r_delay_clk2 <= 0;
        if (ar_r_delay_clk2 > AXI_TIMEOUT2)
            fail_axi2_timeout2 <= 1;
    end
end
always @(negedge clk3) begin
    if (start_bg_check) begin
        if (!ar_valid_clk3 && ar_addr_clk3 !== 32'd0)
            fail_axi3_reset = 1'b1;
        if (!r_valid_clk3  && r_data_clk3  !== 64'd0)
            fail_axi3_reset = 1'b1;
        if (ar_valid_clk3 && ar_addr_clk3 > 32'd65535)
            fail_axi3_range = 1'b1;
    end
end
always @(posedge clk3 or negedge rst_n) begin
    if (!rst_n) begin
        last_ar_valid_clk3 <= 0;
        last_ar_ready_clk3 <= 0;
        last_ar_addr_clk3 <= 0;
        last_r_valid_clk3 <= 0;
        last_r_ready_clk3 <= 0;
        last_r_data_clk3 <= 0;
    end
    else if (start_bg_check) begin
        if (last_ar_valid_clk3 && !last_ar_ready_clk3) begin
            if (!ar_valid_clk3 || ar_addr_clk3 !== last_ar_addr_clk3)
                fail_axi3_stable <= 1;
        end
        if (last_r_valid_clk3 && !last_r_ready_clk3) begin
            if (!r_valid_clk3 || r_data_clk3 !== last_r_data_clk3)
                fail_axi3_stable <= 1;
        end
        last_ar_valid_clk3 <= ar_valid_clk3;
        last_ar_ready_clk3 <= ar_ready_clk3;
        last_ar_addr_clk3 <= ar_addr_clk3;
        last_r_valid_clk3 <= r_valid_clk3;
        last_r_ready_clk3 <= r_ready_clk3;
        last_r_data_clk3 <= r_data_clk3;
    end
end
always @(posedge clk3 or negedge rst_n) begin
    if (!rst_n) begin
        ar_wait_clk3 <= 0;
        r_wait_clk3 <= 0;
    end
    else if (start_bg_check) begin
        if (ar_valid_clk3 && !ar_ready_clk3)
            ar_wait_clk3 <= ar_wait_clk3 + 1;
        else
            ar_wait_clk3 <= 0;
        if (r_valid_clk3 && !r_ready_clk3)
            r_wait_clk3 <= r_wait_clk3 + 1;
        else
            r_wait_clk3 <= 0;
        if (ar_wait_clk3 > AXI_TIMEOUT1 || r_wait_clk3 > AXI_TIMEOUT1)
            fail_axi3_timeout1 <= 1;
    end
end
always @(posedge clk3 or negedge rst_n) begin
    if (!rst_n)
        outstanding_clk3 <= 0;
    else if (start_bg_check) begin
        case ({ar_valid_clk3 && ar_ready_clk3, r_valid_clk3 && r_ready_clk3})
            2'b10:
                outstanding_clk3 <= outstanding_clk3 + 1;
            2'b01:
                outstanding_clk3 <= outstanding_clk3 - 1;
            default:
                outstanding_clk3 <= outstanding_clk3;
        endcase
    end
end
always @(posedge clk3 or negedge rst_n) begin
    if (!rst_n)
        ar_r_delay_clk3 <= 0;
    else if (start_bg_check) begin
        if (outstanding_clk3 > 0) begin
            if (r_valid_clk3 && r_ready_clk3)
                ar_r_delay_clk3 <= 0;
            else
                ar_r_delay_clk3 <= ar_r_delay_clk3 + 1;
        end
        else
            ar_r_delay_clk3 <= 0;
        if (ar_r_delay_clk3 > AXI_TIMEOUT2)
            fail_axi3_timeout2 <= 1;
    end
end

endmodule
