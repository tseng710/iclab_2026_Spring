`ifdef RTL
    `define CYCLE_TIME 6.0
`endif
`ifdef GATE
    `define CYCLE_TIME 6.0
`endif

module PATTERN #(parameter IP_WIDTH = 8)(
           //Output Port
           IN_character,
           IN_weight,
           //Input Port
           OUT_character
       );

// ========================================
// Input & Output Declaration
// ========================================
output reg [IP_WIDTH*4-1:0] IN_character;
output reg [IP_WIDTH*5-1:0] IN_weight;

input [IP_WIDTH*4-1:0] OUT_character;

// ========================================
// Integer / Reg Declaration
// ========================================
integer i, j, k;
integer pat_count;
integer PAT_NUM = 10000; // 測試筆數，可依需求自行放大

reg [4:0] weight_arr [0:15]; // 最大支援到 16 個元素，可依需求調整
reg [3:0] char_arr   [0:15];
reg [4:0] tmp_w;
reg [3:0] tmp_c;
reg [3:0] out_c;

// ========================================
// Pattern Start
// ========================================
initial begin
    // 1. 初始化 IN_character
    // 依據 Spec：IN_character 固定是一串由大到小的連續數字 [cite: 109]。
    // 舉例：若 IP_WIDTH 為 5，則為 {4'd4, 4'd3, 4'd2, 4'd1, 4'd0} [cite: 110]。
    for (i=0; i<IP_WIDTH; i=i+1) begin
        IN_character[i*4 +: 4] = i;
    end
    IN_weight = 0;

    #(`CYCLE_TIME); // 等待初始狀態穩定

    // 2. 開始連續灌入測資
    for (pat_count = 0; pat_count < PAT_NUM; pat_count = pat_count + 1) begin

        // 隨機產生每個字元的權重 (0 ~ 31)
        for (i=0; i<IP_WIDTH; i=i+1) begin
            IN_weight[i*5 +: 5] = $urandom_range(0, 31);
        end

        // 給予運算時間：因為 IP 是組合邏輯，必須在一個週期內算完 ，
        // 故等待一個 CYCLE_TIME 讓訊號傳遞完畢。
        #(`CYCLE_TIME);

        // 呼叫 Task 檢查硬體算出來的答案是否正確
        check_ans();
    end

    // 如果順利跑完迴圈沒有被 $finish 終止，代表全數通過！
    $display("\n========================================================");
    $display("   Congratulations! All IP patterns passed successfully!   ");
    $display("   Total test patterns: %0d", PAT_NUM);
    $display("========================================================\n");
    $finish;
end

// ========================================
// Task: Check Answer (軟體黃金模型)
// ========================================
task check_ans;
    begin
        // 步驟 A: 將當前的 IN_weight 與 IN_character 讀進陣列中方便排序
        // 陣列 index 0 對應訊號的最左邊 (MSB)。
        for(j=0; j<IP_WIDTH; j=j+1) begin
            weight_arr[j] = IN_weight[ (IP_WIDTH-1-j)*5 +: 5 ];
            char_arr[j]   = IN_character[ (IP_WIDTH-1-j)*4 +: 4 ];
        end

        // 步驟 B: 實作 Bubble Sort (模擬硬體的排序邏輯)
        for(j=0; j<IP_WIDTH-1; j=j+1) begin
            for(k=0; k<IP_WIDTH-1-j; k=k+1) begin
                // 交換條件 ：
                // 1. 如果右邊的權重比左邊大，需要交換 (確保權重大的在左邊)。
                // 2. 如果權重一樣，但右邊的字元編號比較大，也要交換 (字元編號大的優先)。
                if( (weight_arr[k] < weight_arr[k+1]) ||
                        ((weight_arr[k] == weight_arr[k+1]) && (char_arr[k] < char_arr[k+1])) ) begin

                    // 交換權重
                    tmp_w = weight_arr[k];
                    weight_arr[k] = weight_arr[k+1];
                    weight_arr[k+1] = tmp_w;

                    // 交換字元
                    tmp_c = char_arr[k];
                    char_arr[k] = char_arr[k+1];
                    char_arr[k+1] = tmp_c;
                end
            end
        end

        // 步驟 C: 逐一比對硬體輸出的 OUT_character 是否與陣列相符
        for(j=0; j<IP_WIDTH; j=j+1) begin
            out_c = OUT_character[ (IP_WIDTH-1-j)*4 +: 4 ];
            if(out_c !== char_arr[j]) begin
                $display("\n===================== ERROR =====================");
                $display("Pattern %0d failed!", pat_count);
                $display("Error at position %0d (0 is MSB / Leftmost)", j);
                $display("Expected Char: %0d, but got: %0d", char_arr[j], out_c);
                $display("IN_weight: %h", IN_weight);
                $display("=================================================\n");
                $finish;
            end
        end
    end
endtask

endmodule
