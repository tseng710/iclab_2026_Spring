`ifdef RTL
    `define CYCLE_TIME 20.0
`endif
`ifdef GATE
    `define CYCLE_TIME 20.0
`endif

module PATTERN(
    // Output signals
    output reg clk,
    output reg rst_n,
    output reg in_valid,
    output reg [2:0] in_weight, 
    output reg out_mode,
    // Input signals
    input out_valid, 
    input out_code
);

// ========================================
// Parameters & Variables
// ========================================
parameter PAT_NUM = 1000;

integer pat_in_fd, pat_out_fd;
integer i, j;
integer latency;
integer scan_ret;

reg [2:0] weights [0:7];
reg       mode;

integer   total_bits;
reg       exp_code;

// ========================================
// Clock Generation
// ========================================
always #(`CYCLE_TIME/2.0) clk = ~clk;

// ========================================
// Main Simulation Block
// ========================================
initial begin
    // ★ 自動呼叫 Python 腳本產生全新測資 ★
    $display("==================================================");
    $display("  [INFO] Calling pattern_gen.py to generate patterns...");
    // 透過 $system 執行 python3 指令 (假設你的 py 檔放在 00_TESTBED 下)
    $system("python3 ../00_TESTBED/pattern_gen.py");
    $display("==================================================");

    // 1. 開啟剛剛被 Python 更新過的檔案
    pat_in_fd  = $fopen("../00_TESTBED/input.txt", "r");
    pat_out_fd = $fopen("../00_TESTBED/output.txt", "r");
    
    if (pat_in_fd == 0 || pat_out_fd == 0) begin
        $display("==================================================");
        $display("  [ERROR] Cannot open input.txt or output.txt!");
        $display("==================================================");
        $finish;
    end

    // 2. 初始化訊號
    clk = 0;
    rst_n = 1;
    in_valid = 0;
    in_weight = 0;
    out_mode = 0;

    // 3. Reset 測試
    force clk = 0;
    #(0.5 * `CYCLE_TIME) rst_n = 0;
    #(2.0 * `CYCLE_TIME) rst_n = 1;
    release clk;
    @(negedge clk);

    // ... (後面的 for 迴圈與比對邏輯保持不變) ...

    // 4. 執行所有的 Patterns
    for (i = 0; i < PAT_NUM; i = i + 1) begin
        drive_input_task;
        check_output_task;
        $display("Pattern [%03d] Pass!", i);
    end

    // 5. 測資全過，印出恭喜訊息
    $display("==================================================");
    $display("    \\(^o^)/  Congratulations! All %0d patterns PASS!", PAT_NUM);
    $display("==================================================");
    $finish;
end

// ========================================
// Task: Drive Input
// ========================================
task drive_input_task; begin
    // 從檔案讀取 8 個 weight 與 1 個 mode
    scan_ret = $fscanf(pat_in_fd, "%d %d %d %d %d %d %d %d %d", 
                       weights[0], weights[1], weights[2], weights[3], 
                       weights[4], weights[5], weights[6], weights[7], mode);
    
    // 等待一段隨機時間後再餵資料
    repeat ($urandom_range(1, 4)) @(negedge clk);

    for (j = 0; j < 8; j = j + 1) begin
        in_valid  <= 1'b1;
        in_weight <= weights[j];
        
        // ★ 修正：在 valid 拉高的第一個 clk (j==0) 給 mode，其餘給 X
        if (j == 0) out_mode <= mode;
        else        out_mode <= 1'bx;
        
        @(negedge clk);
    end
    
    // 輸入結束，把所有訊號歸零 (包含 valid 拉低)
    in_valid  <= 1'b0;
    in_weight <= 3'd0;
    out_mode  <= 1'b0; // 結束後通常拉回乾淨的 0
end endtask

// ========================================
// Task: Check Output
// ========================================
task check_output_task; begin
    latency = 0;
    
    // 讀取該筆 pattern 預期要輸出的總 Bit 數
    scan_ret = $fscanf(pat_out_fd, "%d", total_bits);
    
    // 逐個 Bit 進行比對
    for (j = 0; j < total_bits; j = j + 1) begin
        // 若 valid 尚未拉高，則等待
        while (out_valid === 1'b0) begin
            latency = latency + 1;
            if (latency > 1000) begin
                $display("==================================================");
                $display("  [ERROR] Execution Latency Timeout! (>1000 cycles)");
                $display("==================================================");
                $finish;
            end
            @(negedge clk);
        end
        
        // 此時 valid 為 1，比對 output
        scan_ret = $fscanf(pat_out_fd, "%b", exp_code);
        if (out_code !== exp_code) begin
            $display("==================================================");
            $display("  [ERROR] Pattern [%03d] Bit %0d Failed!", i, j);
            $display("          Expected : %b", exp_code);
            $display("          Your Code: %b", out_code);
            $display("==================================================");
            $finish;
        end
        
        @(negedge clk);
    end
end endtask

endmodule