`define CYCLE_TIME      29.8
`define PATTERN_NUMBER  100
`define SEED_NUMBER     28825252

module PATTERN(
    // Output Port (To DUT)
    output reg clk,
    output reg rst_n,
    output reg instruction_in_valid,
    output reg image_in_valid,
    output reg weight_in_valid,
    output reg [31:0] in_data,
    
    // Input Port (From DUT)
    input  wire out_valid,
    input  wire [31:0] out_data
);

//======================================
//   Parameters & Variables
//======================================

integer pat_num = `PATTERN_NUMBER;
integer seed    = `SEED_NUMBER;
integer i, j, pat_idx;
integer a; // 🌟 新增這個用來接 $fscanf 回傳值的變數
integer delay_cycle;
integer latency;
integer total_latency;

// 檔案與測資陣列
integer file_in;
reg [31:0] inst_reg;
reg [31:0] weight_arr [0:143];
reg [31:0] image_arr  [0:127];
reg [31:0] golden_arr [0:127];

// 浮點數比對用變數
real hw_real, golden_real, err_val;
reg [8*100:1] cmd;

//======================================
//   Clock Generation
//======================================
initial clk = 0;
always #(`CYCLE_TIME / 2.0) clk = ~clk;

//======================================
//   Main Execution Flow
//======================================
initial begin
    // 1. 🌟 自動呼叫 Python 腳本生成測資
    $display("\033[0;33m[INFO] Calling Python to generate %0d patterns (Seed: %0d)...\033[m", pat_num, seed);
    $sformat(cmd, "python3 ../00_TESTBED/generate_input.py %0d %0d", pat_num, seed);
    $system(cmd); 
    
    // 2. 開啟生成的檔案
    file_in = $fopen("input.txt", "r");
    if (file_in == 0) begin
        $display("\033[0;31m[ERROR] Failed to open input.txt! Did the Python script crash?\033[m");
        $finish;
    end
    
    // 讀取檔案開頭的總測資數 (可忽略，因為我們用迴圈控制)
    a = $fscanf(file_in, "%d\n", pat_num);

    // 3. 硬體重置
    reset_task();

    // 4. 開始餵測資與驗證
    total_latency = 0;
    for (pat_idx = 0; pat_idx < pat_num; pat_idx = pat_idx + 1) begin
        read_pattern_from_file();
        input_task();
        wait_out_valid_task();
        check_ans_task();
        
        $display("\033[0;32m[PASS] Pattern No.%4d | Latency: %4d cycles\033[m", pat_idx, latency);
    end

    // 5. 全部通過
    YOU_PASS_task();
end

//======================================
//   Tasks
//======================================

// 讀取單筆測資的 Task
task read_pattern_from_file; begin
    a = $fscanf(file_in, "%h\n", inst_reg);
    for (i = 0; i < 144; i = i + 1) a = $fscanf(file_in, "%h\n", weight_arr[i]);
    for (i = 0; i < 128; i = i + 1) a = $fscanf(file_in, "%h\n", image_arr[i]);
    for (i = 0; i < 128; i = i + 1) a = $fscanf(file_in, "%h\n", golden_arr[i]);
end endtask

// 重置 Task
task reset_task; begin
    rst_n = 1'b1;
    instruction_in_valid = 1'b0;
    weight_in_valid = 1'b0;
    image_in_valid = 1'b0;
    in_data = 32'bx;
    
    #( `CYCLE_TIME / 2.0 );
    rst_n = 1'b0;
    #( `CYCLE_TIME * 2.0 );
    rst_n = 1'b1;
end endtask

// 輸入 Task (嚴格遵守 2~5 cycles delay 與 valid 規範)
task input_task; begin
    // 送 Instruction
    delay_cycle = $urandom_range(2, 5); // 產生 2~5 的隨機數
    #(delay_cycle * `CYCLE_TIME);
    @(negedge clk);
    instruction_in_valid = 1'b1;
    in_data = inst_reg;
    @(negedge clk);
    instruction_in_valid = 1'b0;
    in_data = 32'bx;

    // 送 Weights (連續 144 cycles)
    delay_cycle = $urandom_range(2, 5);
    #(delay_cycle * `CYCLE_TIME);
    @(negedge clk);
    weight_in_valid = 1'b1;
    for (i = 0; i < 144; i = i + 1) begin
        in_data = weight_arr[i];
        @(negedge clk);
    end
    weight_in_valid = 1'b0;
    in_data = 32'bx;

    // 送 Images (連續 128 cycles)
    delay_cycle = $urandom_range(2, 5);
    #(delay_cycle * `CYCLE_TIME);
    @(negedge clk);
    image_in_valid = 1'b1;
    for (i = 0; i < 128; i = i + 1) begin
        in_data = image_arr[i];
        @(negedge clk);
    end
    image_in_valid = 1'b0;
    in_data = 32'bx;
end endtask

// 等待輸出 Task (Latency Limit = 1200)
task wait_out_valid_task; begin
    latency = 0;
    while (out_valid === 1'b0) begin
        latency = latency + 1;
        if (latency > 1200) begin
            $display("\033[0;31m[ERROR] Latency Limit Exceeded (1200 cycles) at Pattern %0d!\033[m", pat_idx);
            trigger_python_debugger();
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

// 檢查答案 Task (連續 128 cycles 與 0.002 誤差容忍)
task check_ans_task; begin
    for (i = 0; i < 128; i = i + 1) begin
        if (out_valid === 1'b0) begin
            $display("\033[0;31m[ERROR] out_valid dropped before 128 cycles at Pattern %0d!\033[m", pat_idx);
            trigger_python_debugger();
            $finish;
        end
        
        // 將 32-bit hex 轉換為 real 以便計算誤差
        hw_real = bit32_to_real(out_data);
        golden_real = bit32_to_real(golden_arr[i]);
        
        // 絕對值計算
        err_val = (golden_real - hw_real);
        if (err_val < 0.0) err_val = -err_val;
        
        // 計算相對誤差: | (golden - hw) / golden |
        if (golden_real != 0.0) begin
            err_val = err_val / (golden_real < 0.0 ? -golden_real : golden_real);
        end

        // 判斷是否大於 0.002
        if (err_val > 0.002) begin
            $display("\033[0;31m[ERROR] Value mismatch at Pattern %0d, Output Index %0d!\033[m", pat_idx, i);
            $display("\033[0;31m        Golden: %f (%h) | HW: %f (%h) | Error: %f\033[m", golden_real, golden_arr[i], hw_real, out_data, err_val);
            trigger_python_debugger();
            $finish;
        end
        @(negedge clk);
    end
end endtask

//======================================
//   Helper Functions / Tasks
//======================================

// 🌟 核心小巧思：自動呼叫 Python 印出該筆測資的詳細 Debug 資訊
task trigger_python_debugger; begin
    $display("\033[0;35m[INFO] Triggering Python Debugger for Pattern %0d...\033[m", pat_idx);
    $sformat(cmd, "python3 ../00_TESTBED/generate_input.py %0d %0d %0d", pat_num, seed, pat_idx);
    $system(cmd);
end endtask

// 🌟 自製 32-bit Float to Real 轉換函數 (無須 DesignWare)
function real bit32_to_real;
    input [31:0] in_bits;
    reg sign;
    reg [7:0] exp;
    reg [22:0] frac;
    real res;
begin
    sign = in_bits[31];
    exp  = in_bits[30:23];
    frac = in_bits[22:0];
    
    if (exp == 8'd0 && frac == 23'd0) begin
        res = 0.0;
    end else begin
        // IEEE-754 Single Precision: (-1)^sign * (1 + frac/2^23) * 2^(exp-127)
        res = (1.0 + frac / (2.0**23)) * (2.0**(exp - 127));
        if (sign) res = -res;
    end
    bit32_to_real = res;
end
endfunction

// 通過 Task
task YOU_PASS_task; begin
    $display("=========================================================================");
    $display("                     Congratulations! You Pass Lab04!                    ");
    $display("                     Total Patterns: %0d                                 ", pat_num);
    $display("                     Total Latency : %0d                                 ", total_latency);
    $display("=========================================================================");
    $finish;
end endtask

endmodule