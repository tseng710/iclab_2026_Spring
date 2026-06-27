`ifdef RTL
    `define CYCLE_TIME 6.0
`endif
`ifdef GATE
    `define CYCLE_TIME 6.0
`endif

module PATTERN #(parameter IP_WIDTH = 5)(
    //Output Port
    IN_character,
	IN_weight,
    //Input Port
	OUT_character
);
// ========================================
// Input & Output
// ========================================
output reg [IP_WIDTH*4-1:0] IN_character;
output reg [IP_WIDTH*5-1:0] IN_weight;

input [IP_WIDTH*4-1:0] OUT_character;
integer pat_idx;
integer i, j;
reg [8:0] temp_swap;
reg [8:0] sort_array [0:IP_WIDTH-1];
reg [IP_WIDTH*4-1:0] golden_character;

integer wrong_count;
integer total_patterns = 10000;


// ========================================
// Pattern Start
// ========================================



initial begin
    // 1. 初始化
    IN_character = 0;
    IN_weight    = 0;
    wrong_count  = 0;

    // 2. 根據規格，將 IN_character 設為固定的遞減數列
    // 例如 IP_WIDTH=5，則 IN_character = {4'd4, 4'd3, 4'd2, 4'd1, 4'd0}
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        IN_character[(i*4)+3 -: 4] = i[3:0]; 
    end

    #10;

    // 3. 開始給予隨機測資
    for (pat_idx = 0; pat_idx < total_patterns; pat_idx = pat_idx + 1) begin
        
        // 隨機生成 Weights (0 ~ 31)
        for (i = 0; i < IP_WIDTH; i = i + 1) begin
            IN_weight[(i*5)+4 -: 5] = $urandom_range(0, 31);
        end

        // 呼叫 Task 計算標準答案 (Golden Model)
        calculate_golden_model();
        
        // 模擬延遲，等待組合邏輯運算完成
        #10;

        // 4. 核對答案
        if (OUT_character !== golden_character) begin
            $display("-----------------------------------------------------------");
            $display("Wrong at Pattern %d", pat_idx);
            $display("IN_weight: %h", IN_weight);
            $display("Expected : %h", golden_character);
            $display("Your OUT : %h", OUT_character);
            $display("-----------------------------------------------------------");
            wrong_count = wrong_count + 1;
            $finish; // 遇到錯誤即停止
        end else begin
            // 🌟 新增這裡：每一筆正確都會印出結果
            $display("Pattern %3d | IN_weight: %h | Expected: %h | OUT: %h", 
                     pat_idx, IN_weight, golden_character, OUT_character);
        end

        #10;
    end

    // 5. 測試結束，印出成功訊息 (避開 P-a-s-s 等字眼)
    if (wrong_count == 0) begin
        $display("-----------------------------------------------------------");
        $display("   Correct! All %d patterns simulated successfully.   ", total_patterns);
        $display("-----------------------------------------------------------");
    end
    
    $finish;
end

// ========================================
// Golden Model Task (計算標準答案)
// ========================================
task calculate_golden_model;
    begin
        // 步驟 A: 將 Weight 與 Character 拼接成 9-bit 鍵值放入陣列
        for (i = 0; i < IP_WIDTH; i = i + 1) begin
            sort_array[i] = { IN_weight[(i*5)+4 -: 5], IN_character[(i*4)+3 -: 4] };
        end

        // 步驟 B: 使用 Bubble Sort 進行遞減排序 (Descending)
        // 因為權重高的排前面，如果權重一樣，Character 編號大的排前面
        for (i = 0; i < IP_WIDTH-1; i = i + 1) begin
            for (j = 0; j < IP_WIDTH-1-i; j = j + 1) begin
                if (sort_array[j] < sort_array[j+1]) begin
                    // 數值較小者往後挪
                    temp_swap       = sort_array[j];
                    sort_array[j]   = sort_array[j+1];
                    sort_array[j+1] = temp_swap;
                end
            end
        end

        // 步驟 C: 將排序完成的 Character 抽出來，放進 golden_character 中
        for (i = 0; i < IP_WIDTH; i = i + 1) begin
            // 注意：因為最大的放在 index 0，但輸出的 MSB 應該要是排第一名的
            // 規格說從左至右 (MSB to LSB) 依序輸出，所以我從 MSB 開始填
            golden_character[((IP_WIDTH-1-i)*4)+3 -: 4] = sort_array[i][3:0];
        end
    end
endtask


endmodule