`ifdef RTL
    `define CYCLE_TIME 6.0
`endif
`ifdef GATE
    `define CYCLE_TIME 6.0
`endif

module PATTERN #(parameter IP_WIDTH = 3)(
    // Output Port (To IP)
    output reg [IP_WIDTH*4-1:0] IN_character,
    output reg [IP_WIDTH*5-1:0] IN_weight,
    // Input Port (From IP)
    input [IP_WIDTH*4-1:0] OUT_character
);

// ========================================
// Parameters & Variables
// ========================================
parameter PATNUM = 100;
parameter SEED   = 1;

integer i, pat_i;
integer fp_in, fp_golden, r;
reg clk;

// 用來存放解答與暫存讀取資料
reg [IP_WIDTH*4-1:0] golden_OUT_character;
reg [3:0] temp_char;
reg [4:0] temp_weight;

// ========================================
// Clock Generation
// ========================================
// 雖然 Soft IP 是 Combinational，但 Testbench 需要 Clock 來控制餵資料與檢查的節拍
real CYCLE = `CYCLE_TIME;
initial clk = 1'b0;
always #(CYCLE/2.0) clk = ~clk;

// ========================================
// Pattern Start
// ========================================
initial begin
    // 1. 呼叫 Python 腳本生成測資 (動態傳遞參數)
    $display("==================================================");
    $display(" Generating Test Patterns via Python Script...");
    $display("==================================================");
    $system($sformatf("python3 pattern_ip.py %0d %0d %0d", PATNUM, SEED, IP_WIDTH));

    // 2. 開啟生成的測資與解答檔
    fp_in = $fopen("../00_TESTBED/input.txt", "r");
    fp_golden = $fopen("../00_TESTBED/golden.txt", "r");
    
    if (fp_in == 0 || fp_golden == 0) begin
        $display("❌ Error: Cannot open input.txt or golden.txt!");
        $display("Please check if the Python script generated them correctly.");
        $finish;
    end

    // 3. 初始化訊號
    IN_character = 0;
    IN_weight = 0;
    @(negedge clk); // 等待電路初始穩定

    // 4. 開始執行比對迴圈
    for (pat_i = 0; pat_i < PATNUM; pat_i = pat_i + 1) begin
        input_task;
        check_ans_task;
    end

    // 5. 測資全數通過
    YOU_PASS_task;
    
    // 收尾關閉檔案
    $fclose(fp_in);
    $fclose(fp_golden);
    $finish;
end

// ========================================
// Tasks
// ========================================
task input_task; begin
    // 隨機延遲，模擬現實中資料可能不是連續進來的狀況
    repeat($urandom_range(1, 3)) @(negedge clk);
    
    // 讀取 IN_character
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        r = $fscanf(fp_in, "%d", temp_char);
        // 使用 +: 語法將讀取到的 4-bit 放回正確的高地位元段
        IN_character[((IP_WIDTH-1-i)*4) +: 4] = temp_char;
    end

    // 讀取 IN_weight
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        r = $fscanf(fp_in, "%d", temp_weight);
        IN_weight[((IP_WIDTH-1-i)*5) +: 5] = temp_weight;
    end
end endtask

task check_ans_task; begin
    // 讀取這筆測資對應的 Golden 答案
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        r = $fscanf(fp_golden, "%d", temp_char);
        golden_OUT_character[((IP_WIDTH-1-i)*4) +: 4] = temp_char;
    end

    // 給予一個 Cycle 的時間讓 SORT_IP 的組合邏輯運算穩定
    @(negedge clk); 

    // 比對輸出
    if (OUT_character !== golden_OUT_character) begin
        $display("==================================================");
        $display("❌ Error at Pattern %0d!", pat_i);
        $display("IN_weight:    %h", IN_weight);
        $display("IN_character: %h", IN_character);
        $display("Expected:     %h", golden_OUT_character);
        $display("Your Output:  %h", OUT_character);
        $display("==================================================");
        $finish;
    end else begin
        // 你可以把這行打開來觀察每筆 pattern 通過的狀況
        // $display("Pattern %0d: Pass", pat_i);
    end
end endtask

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("* Congratulations!                              *");
    $display("* All %0d patterns successfully PASSED!                 *", PATNUM);
    $display("*************************************************************************");
end endtask

endmodule