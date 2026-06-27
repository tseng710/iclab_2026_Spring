`define CYCLE_TIME  9.5
`define PAT_NUM     10

module PATTERN(
    // output signals
    clk,
    rst_n,
    i_valid,
    i_iter,
    i_mode,
    i_data,
    i_weight,
    
    // input signals
    o_valid,
    o_data
);
// ========================================
// I/O declaration
// ========================================
// Output
output reg          clk;
output reg          rst_n;
output reg          i_valid;
output reg    [2:0] i_iter;
output reg    [1:0] i_mode;
output reg    [7:0] i_data;
output reg    [3:0] i_weight;

// Input
input               o_valid;
input         [7:0] o_data;

// ========================================
// clock
// ========================================
real CYCLE = `CYCLE_TIME;
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk; //clock

// ========================================
// integer & parameter
// ========================================
integer pat_idx, pat_num = `PAT_NUM;
integer i, a, file_in;
integer latency, total_latency;
integer out_count;
integer seed = 2026;

string cmd;
// ========================================
// wire & reg
// ========================================
reg [2:0] cur_iter;
reg [1:0] cur_mode;

// 根據 Python 生成的格式宣告陣列大小
reg [3:0] weight_arr [0:1311];
// 16x3x3*2 + 16x16*4 = 1312 weights
reg [7:0] img_arr    [0:4095];
// 64x64 = 4096 pixels
reg [7:0] golden_arr [0:4095]; // 64x64 = 4096 pixels

//================================================================
// design
//================================================================
initial begin
    // ====================================================
    // 1. 自動呼叫 Python 生成測資
    // ====================================================
    $display("\033[0;34m[INFO] Automatically generating patterns via Python...\033[m");
    // 使用 $sformat 將變數 (pat_num, seed) 填入字串中，-1 代表正常生成測資檔
    $sformat(cmd, "python3 ../00_TESTBED/generate_input.py %0d %0d -1", pat_num, seed);
    // 執行終端機指令
    if ($system(cmd) != 0) begin
        $display("\033[0;31m[ERROR] Failed to execute Python script!\033[m");
        $finish;
    end
    $display("\033[0;34m[INFO] Pattern generation completed!\033[m");

    // ====================================================
    // 2. 開啟 Python 生成的測資檔
    // ====================================================
    file_in = $fopen("input.txt", "r");
    if (file_in == 0) begin
        $display("\033[0;31m[ERROR] Cannot open input.txt! Please check the Python script.\033[m");
        $finish;
    end

    // 3. 初始化訊號與重置
    reset_task();
    total_latency = 0;
    
    // 【修改 1】：權重只在最一開始讀取與傳送一次
    read_weight_and_first_pattern_task();
    input_weight_task();
    
    // Spec: 權重的 valid 降下後，等 1~3 個 negedge 再給第一張影像
    repeat ($urandom_range(1, 3)) @(negedge clk);

    // 4. 開始測試迴圈
    for (pat_idx = 0; pat_idx < pat_num; pat_idx = pat_idx + 1) begin
        
        if (pat_idx > 0) begin
            read_image_pattern_task(); // 後續 Pattern 只讀取設定與影像
        end
        
        input_image_task();
        wait_out_valid_task();
        check_ans_task();
        
        $display("\033[0;32m[PASS] Pattern %0d | Latency: %0d cycles\033[m", pat_idx, latency);
        
        // 【修改 2】：下一個 Pattern 會在 o_valid 降下後等 1~3 個 cycle
        if (pat_idx < pat_num - 1) begin
            while (o_valid === 1'b1) @(negedge clk);
            repeat ($urandom_range(1, 3)) @(negedge clk);
        end
    end

    // 5. 全部通過
    $display("\033[1;33m===================================================\033[m");
    $display("\033[1;33m    Congratulations! All %0d Patterns Passed!      \033[m", pat_num);
    $display("\033[1;33m    Total Latency: %0d cycles                      \033[m", total_latency);
    $display("\033[1;33m===================================================\033[m");
    $finish;
end

// ========================================
// Tasks
// ========================================

task reset_task; begin
    rst_n    = 1'b0;      // ← 直接從 0 開始，不要先 1 再 0
    i_valid  = 1'b0;
    i_iter   = 3'b0;
    i_mode   = 2'b0;
    i_data   = 8'b0;
    i_weight = 4'b0;

    repeat(3) @(negedge clk);   // 持續 reset 3 個 cycle
    rst_n = 1'b1;               // 在 negedge 釋放
    @(negedge clk);             // 等 1 cycle 讓一切穩定
end endtask

// 讀取第一個 Pattern (包含權重)
task read_weight_and_first_pattern_task; begin
    a = $fscanf(file_in, "%d %d\n", cur_iter, cur_mode);
    for (i = 0; i < 1312; i = i + 1) a = $fscanf(file_in, "%h", weight_arr[i]);
    for (i = 0; i < 4096; i = i + 1) a = $fscanf(file_in, "%h", img_arr[i]);
    for (i = 0; i < 4096; i = i + 1) a = $fscanf(file_in, "%h", golden_arr[i]);
end endtask

// 讀取後續的 Pattern (不包含權重)
task read_image_pattern_task; begin
    a = $fscanf(file_in, "%d %d\n", cur_iter, cur_mode);
    for (i = 0; i < 4096; i = i + 1) a = $fscanf(file_in, "%h", img_arr[i]);
    for (i = 0; i < 4096; i = i + 1) a = $fscanf(file_in, "%h", golden_arr[i]);
end endtask

// 傳送權重 Task
task input_weight_task; begin
    for (int i = 0; i < 1312; i = i + 1) begin
        i_valid  = 1'b1;
        i_weight = weight_arr[i];
        
        i_data   = 8'bx;
        i_iter   = 3'bx;
        i_mode   = 2'bx;
        
        @(negedge clk);
    end
    i_valid  = 1'b0;
    i_weight = 4'bx;
end endtask

// 傳送影像 Task
task input_image_task; begin
    for (int i = 0; i < 4096; i = i + 1) begin
        i_valid = 1'b1;
        i_data  = img_arr[i];
        i_weight = 4'bx; 
        
        if (i == 0) begin
            i_iter = cur_iter;
            i_mode = cur_mode;
        end else begin
            i_iter = 3'bx;
            i_mode = 2'bx;
        end
        
        @(negedge clk);
    end
    
    i_valid  = 1'b0;
    i_data   = 8'bx;
    i_weight = 4'bx;
    i_iter   = 3'bx;
    i_mode   = 2'bx;
end endtask

task wait_out_valid_task; begin
    latency = 0;
    while (o_valid !== 1'b1) begin
        latency = latency + 1;
        // 【修改 3】：放寬 Timeout 到容許 7 個 iteration 的極限 1,500,000 cycles
        if (latency > 1500000) begin 
            $display("\033[0;31m[ERROR] Latency Exceeds Timeout limit at Pattern %0d!\033[m", pat_idx);
            trigger_python_debugger();
            $finish;
        end
        @(negedge clk);
    end
end endtask

task check_ans_task; begin
    out_count = 0;
    // 【修改 4】：改為計數 4096，允許 o_valid 斷斷續續
    while (out_count < 4096) begin
        if (o_valid === 1'b1) begin
            if (o_data !== golden_arr[out_count]) begin
                $display("\033[0;31m[ERROR] Pattern %0d failed at Pixel %0d!\033[m", pat_idx, out_count);
                $display("        Expected: %h, Got: %h", golden_arr[out_count], o_data);
                trigger_python_debugger();
                $finish;
            end
            out_count = out_count + 1;
        end else begin
            // Spec 說明：o_valid 為 Low 時才算入 latency
            latency = latency + 1;
            if (latency > 1500000) begin
                $display("\033[0;31m[ERROR] Latency Exceeds Timeout limit at Pattern %0d!\033[m", pat_idx);
                trigger_python_debugger();
                $finish;
            end
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

task trigger_python_debugger; begin
    $display("\033[0;35m[INFO] Triggering Python Debugger for Pattern %0d...\033[m", pat_idx);
    $sformat(cmd, "python3 ../00_TESTBED/generate_input.py %0d %0d %0d", pat_num, seed, pat_idx);
    $system(cmd);
end endtask

endmodule