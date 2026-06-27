`define CYCLE_TIME      29.8
`define SEED_NUMBER     28825252
`define PATTERN_NUMBER  1000

module PATTERN(
    // Output Port (To DUT)
    clk,
    rst_n,
    instruction_in_valid,
    image_in_valid,
    weight_in_valid,
    in_data,
    
    // Input Port (From DUT)
    out_valid,
    out_data
);

// Output Port (To DUT)
output reg clk;
output reg rst_n;
output reg instruction_in_valid;
output reg image_in_valid;
output reg weight_in_valid;
output reg [31:0] in_data;
    
// Input Port (From DUT)
input    out_valid;
input  [31:0]  out_data;

//======================================
//      PARAMETERS & VARIABLES
//======================================
integer pat;
integer i;
integer gap;
integer seed = `SEED_NUMBER;

integer latency;       // 記錄單筆 pattern 的延遲
integer total_latency; // 記錄所有 pattern 的總延遲

// 存放測資的 Array
reg [31:0] inst_data;
reg [31:0] weight_data [0:143];
reg [31:0] image_data  [0:127];

//======================================
//      MULTI-DIMENSIONAL ARRAYS (For Golden Model)
//======================================
// [channel][row][col]
// 0. 原始影像與預處理
reg [31:0] img_map    [0:1][0:7][0:7]; // 8x8
reg [31:0] img_scaled [0:1][0:7][0:7]; // 8x8

// --- Convolution Network (Encoder) ---
// Layer 0
reg [31:0] pad_0      [0:1][0:9][0:9]; // 10x10
reg [31:0] conv_0     [0:1][0:7][0:7]; // 8x8
reg [31:0] pool_0     [0:1][0:3][0:3]; // 4x4
reg [1:0]  pool_0_pos [0:1][0:3][0:3]; // 4x4 (Switch variables: 紀錄 2x2 視窗中的最大值位置 0~3)
reg [31:0] act_0      [0:1][0:3][0:3]; // 4x4

// Layer 1
reg [31:0] pad_1      [0:1][0:5][0:5]; // 6x6
reg [31:0] conv_1     [0:1][0:3][0:3]; // 4x4
reg [31:0] pool_1     [0:1][0:1][0:1]; // 2x2
reg [1:0]  pool_1_pos [0:1][0:1][0:1]; // 2x2 (Switch variables: 紀錄最大值位置 0~3)
reg [31:0] act_1      [0:1][0:1][0:1]; // 2x2

// --- Deconvolution Network (Decoder) ---
// Layer 0
reg [31:0] unpool_0   [0:1][0:3][0:3]; // 4x4
reg [31:0] pad_2      [0:1][0:5][0:5]; // 6x6
reg [31:0] deconv_0   [0:1][0:3][0:3]; // 4x4
reg [31:0] act_2      [0:1][0:3][0:3]; // 4x4

// Layer 1
reg [31:0] unpool_1   [0:1][0:7][0:7]; // 8x8
reg [31:0] pad_3      [0:1][0:9][0:9]; // 10x10
reg [31:0] deconv_1   [0:1][0:7][0:7]; // 8x8
reg [31:0] act_3      [0:1][0:7][0:7]; // 8x8 (Final Output)

//======================================
//      CLOCK GENERATION
//======================================
initial clk = 1'b0;
always #(`CYCLE_TIME/2.0) clk = ~clk;

//======================================
//      MAIN FLOW
//======================================
initial begin
    reset_task;
    
    for (pat = 0; pat < `PATTERN_NUMBER; pat = pat + 1) begin
        generate_data_task; // 未來會在這裡實作：產生 IEEE 754 的亂數測資
        input_task;
        cal_task;           // 未來會在這裡實作：計算 Golden Model (CNN / Deconv)
        wait_task;          // 未來會在這裡實作：等待 out_valid 拉高
        check_task;         // 未來會在這裡實作：比對 DUT 輸出與 Golden Model
        
        $display("\033[0;34mPASS PATTERN NO.%4d \033[m", pat);
    end
    
    pass_task;              // 未來會在這裡實作：印出 Congratulation!
    $finish;
end

//======================================
//      TASKS
//======================================

// --- Reset Task ---
task reset_task; begin
    force clk = 0;
    rst_n = 1;
    instruction_in_valid = 0;
    image_in_valid = 0;
    weight_in_valid = 0;
    in_data = 32'bx;

    total_latency = 0; // ★ 新增這行：初始化總延遲

    #(`CYCLE_TIME/2.0) rst_n = 0;
    #(`CYCLE_TIME/2.0) rst_n = 1;
    
    // 檢查在 Reset 期間，輸出是否正確歸零
    if (out_valid !== 0 || out_data !== 0) begin
        $display("[ERROR] [Reset] Output signal should be 0 during reset.");
        //$finish;
    end
    
    #(`CYCLE_TIME/2.0) release clk;
end endtask

// --- DATA GENERATION TASK ---
task generate_data_task; 
    integer img_idx, w_idx;
    real rand_real;
begin
    // 1. 產生 Instruction (只用到 [2:0]，其餘為 0)
    // [2]   : 0 = Zero padding, 1 = Replication padding
    // [1:0] : 00 = Sigmoid, 01 = Tanh, 10 = ReLU, 11 = Leaky ReLU
    inst_data = {$random(seed)} % 8; // 產生 0~7 的亂數，剛好佔用 3 bits
    
    // 2. 產生 Weight (144 筆，範圍 -1.0 ~ 1.0)
    // 144 = 3(W) * 3(H) * 2(In_CH) * 2(Out_CH) * 4(Layers)
    for (w_idx = 0; w_idx < 144; w_idx = w_idx + 1) begin
        // 隨機產生 -1.0 到 1.0 之間的實數 (Real)
        rand_real = (($random(seed) % 10000) / 10000.0) * 2.0 - 1.0;
        // 將實數轉換成 IEEE-754 32-bit 格式並存入 Array
        weight_data[w_idx] = _realTofloatBits(rand_real);
    end
    
    // 3. 產生 Image (128 筆，範圍 -127.0 ~ 128.0)
    // 128 = 8(W) * 8(H) * 2(In_CH)
    for (img_idx = 0; img_idx < 128; img_idx = img_idx + 1) begin
        // 隨機產生 -127.0 到 128.0 之間的實數 (Real)
        rand_real = (($random(seed) % 10000) / 10000.0) * 255.0 - 127.0;
        // 將實數轉換成 IEEE-754 32-bit 格式並存入 Array
        image_data[img_idx] = _realTofloatBits(rand_real);
    end
end endtask

// --- Input Task ---
task input_task; begin
    // 1. 給予 Instruction (1 cycle)
    @(negedge clk);
    instruction_in_valid = 1'b1;
    in_data = inst_data; // 丟入事前準備好的指令
    
    @(negedge clk);
    instruction_in_valid = 1'b0;
    in_data = 32'bx;     // 沒 valid 的時候給 unknown state
    
    // 2. 等待 2~5 cycles
    gap = {$random(seed)} % 4 + 2;
    repeat(gap) @(negedge clk);
    
    // 3. 給予 Weight (144 cycles)
    for (i = 0; i < 144; i = i + 1) begin
        weight_in_valid = 1'b1;
        in_data = weight_data[i];
        @(negedge clk);
    end
    weight_in_valid = 1'b0;
    in_data = 32'bx;
    
    // 4. 等待 2~5 cycles
    gap = {$random(seed)} % 4 + 2;
    repeat(gap) @(negedge clk);
    
    // 5. 給予 Image (128 cycles)
    for (i = 0; i < 128; i = i + 1) begin
        image_in_valid = 1'b1;
        in_data = image_data[i];
        @(negedge clk);
    end
    image_in_valid = 1'b0;
    in_data = 32'bx;
    
end endtask

//======================================
//      CALCULATION TASK (Golden Model)
//======================================
task cal_task; begin
    // --- Preprocessing ---
    load_image_to_map_task;
    min_max_scaling_task;
    
    // --- Encoder (Layer 0 & 1) ---
    padding_0_task;
    conv_0_task;
    max_pool_0_task;
    activation_0_task;
    
    padding_1_task;
    conv_1_task;
    max_pool_1_task;
    activation_1_task;
    
    // --- Decoder (Layer 2 & 3) ---
    unpool_0_task;
    padding_2_task;
    deconv_0_task;
    activation_2_task;
    
    unpool_1_task;
    padding_3_task;
    deconv_1_task;
    activation_3_task;
end endtask

// --- Load Image 1D to 3D ---
task load_image_to_map_task;
    integer c, r, c_idx;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                // Channel 0: index 0~63, Channel 1: index 64~127
                img_map[c][r][c_idx] = image_data[c*64 + r*8 + c_idx];
            end
        end
    end
end endtask

//===================================
//     Stage 1: Min-Max Scaling 
//===================================
task min_max_scaling_task;
    integer c, r, c_idx;
    real max_val, min_val, current_val, scaled_val;
begin
    for (c = 0; c < 2; c = c + 1) begin
        // 初始化 max_val 和 min_val 為該通道的第一個元素
        max_val = _floatBitsToReal(img_map[c][0][0]);
        min_val = _floatBitsToReal(img_map[c][0][0]);
        
        // 1. 找出該通道的最大值與最小值
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                current_val = _floatBitsToReal(img_map[c][r][c_idx]);
                if (current_val > max_val) max_val = current_val;
                if (current_val < min_val) min_val = current_val;
            end
        end
        
        // 2. 正規化所有像素，並存入 img_scaled
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                current_val = _floatBitsToReal(img_map[c][r][c_idx]);
                // 題目保證分母 (max - min) 不會為 0
                scaled_val = (current_val - min_val) / (max_val - min_val);
                // 算完後，轉回 IEEE-754 的 32-bit 格式存起來
                img_scaled[c][r][c_idx] = _realTofloatBits(scaled_val);
            end
        end
    end
end endtask

//===================================
//         Stage 2: Layer 0 
//===================================
// --- Layer 0: Padding (8x8 -> 10x10) ---
task padding_0_task;
    integer c, r, c_idx;
    integer r_clamp, c_clamp;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 10; r = r + 1) begin
            for (c_idx = 0; c_idx < 10; c_idx = c_idx + 1) begin
                if (r >= 1 && r <= 8 && c_idx >= 1 && c_idx <= 8) begin
                    // 中間原始影像部分
                    pad_0[c][r][c_idx] = img_scaled[c][r-1][c_idx-1];
                end else begin
                    // 邊界 Padding 部分
                    if (inst_data[2] == 1'b0) begin 
                        // Zero padding
                        pad_0[c][r][c_idx] = _realTofloatBits(0.0);
                    end else begin 
                        // Replication padding: 夾擠座標到 1~8 之間
                        r_clamp = (r < 1) ? 1 : ((r > 8) ? 8 : r);
                        c_clamp = (c_idx < 1) ? 1 : ((c_idx > 8) ? 8 : c_idx);
                        pad_0[c][r][c_idx] = img_scaled[c][r_clamp-1][c_clamp-1];
                    end
                end
            end
        end
    end
end endtask

// --- Layer 0: Convolution (10x10 -> 8x8) ---
task conv_0_task;
    integer out_c, in_c, r, c_idx, kr, kc;
    real sum, val_in, val_k;
begin
    for (out_c = 0; out_c < 2; out_c = out_c + 1) begin
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                sum = 0.0;
                // 這裡就是之前提過的「跨通道累加」
                for (in_c = 0; in_c < 2; in_c = in_c + 1) begin
                    for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                            val_in = _floatBitsToReal(pad_0[in_c][r+kr][c_idx+kc]);
                            // 根據 Raster scan order，Kernel_0 的 index 範圍是 0~35
                            val_k = _floatBitsToReal(weight_data[out_c*18 + in_c*9 + kr*3 + kc]);
                            sum = sum + val_in * val_k;
                        end
                    end
                end
                conv_0[out_c][r][c_idx] = _realTofloatBits(sum);
            end
        end
    end
end endtask

// --- Layer 0: Max-Pooling (8x8 -> 4x4) ---
task max_pool_0_task;
    integer c, r, c_idx, wr, wc, max_pos;
    real max_val, current_val;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                for (wr = 0; wr < 2; wr = wr + 1) begin
                    for (wc = 0; wc < 2; wc = wc + 1) begin
                        current_val = _floatBitsToReal(conv_0[c][r*2+wr][c_idx*2+wc]);
                        if (wr == 0 && wc == 0) begin
                            max_val = current_val;
                            max_pos = 0;
                        end else if (current_val > max_val) begin
                            max_val = current_val;
                            // 紀錄最大值在 2x2 視窗內的位置 (0:左上, 1:右上, 2:左下, 3:右下)
                            max_pos = wr * 2 + wc; 
                        end
                    end
                end
                pool_0[c][r][c_idx] = _realTofloatBits(max_val);
                pool_0_pos[c][r][c_idx] = max_pos; // 儲存 switch variables 給 Unpooling 用
            end
        end
    end
end endtask

// --- Layer 0: Activation ---
task activation_0_task;
    integer c, r, c_idx;
    real val_in, val_out;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                val_in = _floatBitsToReal(pool_0[c][r][c_idx]);
                val_out = apply_activation(val_in, inst_data[1:0]);
                act_0[c][r][c_idx] = _realTofloatBits(val_out);
            end
        end
    end
end endtask

//===================================
//         Stage 3: Layer 1
//===================================
// --- Layer 1: Padding (4x4 -> 6x6) ---
task padding_1_task;
    integer c, r, c_idx, r_clamp, c_clamp;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 6; r = r + 1) begin
            for (c_idx = 0; c_idx < 6; c_idx = c_idx + 1) begin
                if (r >= 1 && r <= 4 && c_idx >= 1 && c_idx <= 4) begin
                    pad_1[c][r][c_idx] = act_0[c][r-1][c_idx-1]; // 接續上一層的輸出
                end else begin
                    if (inst_data[2] == 1'b0) begin 
                        pad_1[c][r][c_idx] = _realTofloatBits(0.0);
                    end else begin 
                        r_clamp = (r < 1) ? 1 : ((r > 4) ? 4 : r);
                        c_clamp = (c_idx < 1) ? 1 : ((c_idx > 4) ? 4 : c_idx);
                        pad_1[c][r][c_idx] = act_0[c][r_clamp-1][c_clamp-1];
                    end
                end
            end
        end
    end
end endtask

// --- Layer 1: Convolution (6x6 -> 4x4) ---
task conv_1_task;
    integer out_c, in_c, r, c_idx, kr, kc;
    real sum, val_in, val_k;
begin
    for (out_c = 0; out_c < 2; out_c = out_c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                sum = 0.0;
                for (in_c = 0; in_c < 2; in_c = in_c + 1) begin
                    for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                            val_in = _floatBitsToReal(pad_1[in_c][r+kr][c_idx+kc]);
                            // 注意：Layer 1 的 Kernel 從 index 36 開始！
                            val_k = _floatBitsToReal(weight_data[36 + out_c*18 + in_c*9 + kr*3 + kc]);
                            sum = sum + val_in * val_k;
                        end
                    end
                end
                conv_1[out_c][r][c_idx] = _realTofloatBits(sum);
            end
        end
    end
end endtask

// --- Layer 1: Max-Pooling (4x4 -> 2x2) ---
task max_pool_1_task;
    integer c, r, c_idx, wr, wc, max_pos;
    real max_val, current_val;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 2; r = r + 1) begin
            for (c_idx = 0; c_idx < 2; c_idx = c_idx + 1) begin
                for (wr = 0; wr < 2; wr = wr + 1) begin
                    for (wc = 0; wc < 2; wc = wc + 1) begin
                        current_val = _floatBitsToReal(conv_1[c][r*2+wr][c_idx*2+wc]);
                        if (wr == 0 && wc == 0) begin
                            max_val = current_val;
                            max_pos = 0;
                        end else if (current_val > max_val) begin
                            max_val = current_val;
                            max_pos = wr * 2 + wc;
                        end
                    end
                end
                pool_1[c][r][c_idx] = _realTofloatBits(max_val);
                pool_1_pos[c][r][c_idx] = max_pos; // 儲存第二層的 switch variables
            end
        end
    end
end endtask

// --- Layer 1: Activation ---
task activation_1_task;
    integer c, r, c_idx;
    real val_in, val_out;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 2; r = r + 1) begin
            for (c_idx = 0; c_idx < 2; c_idx = c_idx + 1) begin
                val_in = _floatBitsToReal(pool_1[c][r][c_idx]);
                val_out = apply_activation(val_in, inst_data[1:0]);
                act_1[c][r][c_idx] = _realTofloatBits(val_out);
            end
        end
    end
end endtask

//===================================
//         Stage 4: Layer 2
//===================================
// --- Layer 2: Unpooling_0 (2x2 -> 4x4) ---
task unpool_0_task;
    integer c, r, c_idx, wr, wc, pos;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 2; r = r + 1) begin
            for (c_idx = 0; c_idx < 2; c_idx = c_idx + 1) begin
                // 1. 先把 2x2 的目標視窗全部填 0
                for (wr = 0; wr < 2; wr = wr + 1) begin
                    for (wc = 0; wc < 2; wc = wc + 1) begin
                        unpool_0[c][r*2+wr][c_idx*2+wc] = _realTofloatBits(0.0);
                    end
                end
                // 2. 根據 pool_1_pos 紀錄的位置 (0~3)，把 act_1 的數值放回去
                pos = pool_1_pos[c][r][c_idx]; 
                wr = pos / 2; // 商數代表 row offset (0 或 1)
                wc = pos % 2; // 餘數代表 col offset (0 或 1)
                unpool_0[c][r*2+wr][c_idx*2+wc] = act_1[c][r][c_idx];
            end
        end
    end
end endtask

// --- Layer 2: Padding_2 (4x4 -> 6x6) ---
task padding_2_task;
    integer c, r, c_idx, r_clamp, c_clamp;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 6; r = r + 1) begin
            for (c_idx = 0; c_idx < 6; c_idx = c_idx + 1) begin
                if (r >= 1 && r <= 4 && c_idx >= 1 && c_idx <= 4) begin
                    pad_2[c][r][c_idx] = unpool_0[c][r-1][c_idx-1]; // 接續 unpool_0
                end else begin
                    if (inst_data[2] == 1'b0) begin 
                        pad_2[c][r][c_idx] = _realTofloatBits(0.0);
                    end else begin 
                        r_clamp = (r < 1) ? 1 : ((r > 4) ? 4 : r);
                        c_clamp = (c_idx < 1) ? 1 : ((c_idx > 4) ? 4 : c_idx);
                        pad_2[c][r][c_idx] = unpool_0[c][r_clamp-1][c_clamp-1];
                    end
                end
            end
        end
    end
end endtask

// --- Layer 2: Deconvolution_0 (6x6 -> 4x4) ---
task deconv_0_task;
    integer out_c, in_c, r, c_idx, kr, kc;
    real sum, val_in, val_k;
begin
    for (out_c = 0; out_c < 2; out_c = out_c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                sum = 0.0;
                for (in_c = 0; in_c < 2; in_c = in_c + 1) begin
                    for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                            val_in = _floatBitsToReal(pad_2[in_c][r+kr][c_idx+kc]);
                            // 注意：Deconv_0 的 Kernel 從 index 72 開始！(72 ~ 107)
                            val_k = _floatBitsToReal(weight_data[72 + out_c*18 + in_c*9 + kr*3 + kc]);
                            sum = sum + val_in * val_k;
                        end
                    end
                end
                deconv_0[out_c][r][c_idx] = _realTofloatBits(sum);
            end
        end
    end
end endtask

// --- Layer 2: Activation_2 ---
task activation_2_task;
    integer c, r, c_idx;
    real val_in, val_out;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                val_in = _floatBitsToReal(deconv_0[c][r][c_idx]);
                val_out = apply_activation(val_in, inst_data[1:0]);
                act_2[c][r][c_idx] = _realTofloatBits(val_out);
            end
        end
    end
end endtask

//===================================
//         Stage 5: Layer 3
//===================================
// --- Layer 3: Unpooling_1 (4x4 -> 8x8) ---
task unpool_1_task;
    integer c, r, c_idx, wr, wc, pos;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                // 1. 2x2 視窗先全填 0
                for (wr = 0; wr < 2; wr = wr + 1) begin
                    for (wc = 0; wc < 2; wc = wc + 1) begin
                        unpool_1[c][r*2+wr][c_idx*2+wc] = _realTofloatBits(0.0);
                    end
                end
                // 2. 根據 pool_0_pos 紀錄的位置，還原 act_2 的數值
                pos = pool_0_pos[c][r][c_idx]; 
                wr = pos / 2;
                wc = pos % 2;
                unpool_1[c][r*2+wr][c_idx*2+wc] = act_2[c][r][c_idx];
            end
        end
    end
end endtask

// --- Layer 3: Padding_3 (8x8 -> 10x10) ---
task padding_3_task;
    integer c, r, c_idx, r_clamp, c_clamp;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 10; r = r + 1) begin
            for (c_idx = 0; c_idx < 10; c_idx = c_idx + 1) begin
                if (r >= 1 && r <= 8 && c_idx >= 1 && c_idx <= 8) begin
                    pad_3[c][r][c_idx] = unpool_1[c][r-1][c_idx-1];
                end else begin
                    if (inst_data[2] == 1'b0) begin 
                        pad_3[c][r][c_idx] = _realTofloatBits(0.0);
                    end else begin 
                        r_clamp = (r < 1) ? 1 : ((r > 8) ? 8 : r);
                        c_clamp = (c_idx < 1) ? 1 : ((c_idx > 8) ? 8 : c_idx);
                        pad_3[c][r][c_idx] = unpool_1[c][r_clamp-1][c_clamp-1];
                    end
                end
            end
        end
    end
end endtask

// --- Layer 3: Deconvolution_1 (10x10 -> 8x8) ---
task deconv_1_task;
    integer out_c, in_c, r, c_idx, kr, kc;
    real sum, val_in, val_k;
begin
    for (out_c = 0; out_c < 2; out_c = out_c + 1) begin
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                sum = 0.0;
                for (in_c = 0; in_c < 2; in_c = in_c + 1) begin
                    for (kr = 0; kr < 3; kr = kr + 1) begin
                        for (kc = 0; kc < 3; kc = kc + 1) begin
                            val_in = _floatBitsToReal(pad_3[in_c][r+kr][c_idx+kc]);
                            // 注意：Deconv_1 的 Kernel 從 index 108 開始！(108 ~ 143)
                            val_k = _floatBitsToReal(weight_data[108 + out_c*18 + in_c*9 + kr*3 + kc]);
                            sum = sum + val_in * val_k;
                        end
                    end
                end
                deconv_1[out_c][r][c_idx] = _realTofloatBits(sum);
            end
        end
    end
end endtask

// --- Layer 3: Activation_3 (Final Output) ---
task activation_3_task;
    integer c, r, c_idx;
    real val_in, val_out;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                val_in = _floatBitsToReal(deconv_1[c][r][c_idx]);
                val_out = apply_activation(val_in, inst_data[1:0]);
                act_3[c][r][c_idx] = _realTofloatBits(val_out); // 這個就是最終答案 (Golden)！
            end
        end
    end
end endtask

//======================================
//      WAIT TASK (等待硬體運算)
//======================================
task wait_task;
begin
    latency = 0;
    // 只要 out_valid 還沒拉高，就繼續等
    while (out_valid !== 1'b1) begin
        if (latency == 1200) begin
            $display("\033[1;31m==============================================================\033[0m");
            $display("\033[1;31m[ERROR] The execution latency exceeded 1200 cycles!           \033[0m");
            $display("\033[1;31m==============================================================\033[0m");
            dump_debug_files_task;
            $finish;
        end
        // 檢查如果 out_valid 是 0，out_data 必須也是 0
        if (out_data !== 32'd0) begin
            $display("\033[1;31m==============================================================\033[0m");
            $display("\033[1;31m[ERROR] out_data should be 0 when out_valid is low!           \033[0m");
            $display("\033[1;31m==============================================================\033[0m");
            dump_debug_files_task;
            $finish;
        end
        
        latency = latency + 1;
        @(negedge clk);
    end
end endtask

//======================================
//      CHECK TASK (比對輸出結果)
//======================================
task check_task;
    integer c, r, c_idx;
    real golden_real, your_real, error_val;
    reg [31:0] your_data;
begin
    for (c = 0; c < 2; c = c + 1) begin
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                // 1. 確保 out_valid 連續 128 cycles 都是 high
                if (out_valid !== 1'b1) begin
                    $display("\033[1;31m==============================================================\033[0m");
                    $display("\033[1;31m[ERROR] out_valid should be continuously high for 128 cycles! \033[0m");
                    $display("\033[1;31m==============================================================\033[0m");
                    dump_debug_files_task;
                    $finish;
                end

                // 2. 讀取硬體算出來的值與我們 Golden Model 的標準答案
                your_data = out_data;
                your_real = _floatBitsToReal(your_data);
                golden_real = _floatBitsToReal(act_3[c][r][c_idx]); // act_3 是我們算出來的最終答案

                // 3. 計算誤差 Error = |(golden - ans) / golden|
                if (golden_real != 0.0) begin
                    error_val = (golden_real - your_real) / golden_real;
                    if (error_val < 0) error_val = -error_val; // 取絕對值
                end else begin
                    // 防呆機制：如果標準答案剛好是 0 (例如 ReLU 切掉的)，分母不能為 0
                    // 只要你算出來的不是 0，誤差就是你算出來的絕對值
                    error_val = (your_real < 0) ? -your_real : your_real; 
                end

                // 4. 檢查誤差是否超過 0.002
                if (error_val > 0.002) begin
                    $display("\033[1;31m=========================================\033[0m");
                    $display("\033[1;31m[ERROR] Output mismatch at Channel %0d, Row %0d, Col %0d!\033[0m", c, r, c_idx);
                    $display("        Golden : %f (Hex: %8h)", golden_real, act_3[c][r][c_idx]);
                    $display("        Your   : %f (Hex: %8h)", your_real, your_data);
                    $display("        Error  : %f", error_val);
                    $display("\033[1;31m=========================================\033[0m");
                    dump_debug_files_task; // 未來可以把寫好的 dump file 功能放這裡，出錯就印檔案
                    
                end

                @(negedge clk);
            end
        end
    end
    
    // 128 筆輸出完畢後，檢查 out_valid 是否乖乖降下來
    if (out_valid !== 1'b0) begin
        $display("\033[1;31m==============================================================\033[0m");
        $display("\033[1;31m[ERROR] out_valid should go low immediately after 128 cycles! \033[0m");
        $display("\033[1;31m==============================================================\033[0m");
        dump_debug_files_task;
        $finish;
    end

    // ★ 新增這行：累加這筆 pattern 消耗的 cycle 數
    total_latency = total_latency + latency;
end 
endtask

//======================================
//      PASS TASK
//======================================
task pass_task; begin
    $display("\033[1;33m                `oo+oy+`                            \033[1;35m Congratulation!!! \033[1;0m                                   ");
    $display("\033[1;33m               /h/----+y        `+++++:             \033[1;35m PASS This Lab........Maybe \033[1;0m                          ");
    $display("\033[1;33m             .y------:m/+ydoo+:y:---:+o             \033[1;35m Total Latency : %-10d\033[1;0m                                ", total_latency);
    $display("\033[1;33m              o+------/y--::::::+oso+:/y                                                                                     ");
    $display("\033[1;33m              s/-----:/:----------:+ooy+-                                                                                    ");
    $display("\033[1;33m             /o----------------/yhyo/::/o+/:-.`                                                                              ");
    $display("\033[1;33m            `ys----------------:::--------:::+yyo+                                                                           ");
    $display("\033[1;33m            .d/:-------------------:--------/--/hos/                                                                         ");
    $display("\033[1;33m            y/-------------------::ds------:s:/-:sy-                                                                         ");
    $display("\033[1;33m           +y--------------------::os:-----:ssm/o+`                                                                          ");
    $display("\033[1;33m          `d:-----------------------:-----/+o++yNNmms                                                                        ");
    $display("\033[1;33m           /y-----------------------------------hMMMMN.                                                                      ");
    $display("\033[1;33m           o+---------------------://:----------:odmdy/+.                                                                    ");
    $display("\033[1;33m           o+---------------------::y:------------::+o-/h                                                                    ");
    $display("\033[1;33m           :y-----------------------+s:------------/h:-:d                                                                    ");
    $display("\033[1;33m           `m/-----------------------+y/---------:oy:--/y                                                                    ");
    $display("\033[1;33m            /h------------------------:os++/:::/+o/:--:h-                                                                    ");
    $display("\033[1;33m         `:+ym--------------------------://++++o/:---:h/                                                                     ");
    $display("\033[1;31m        `hhhhhoooo++oo+/:    \033[1;33m--------------------:oo----\033[1;31m+dd+                                                 ");
    $display("\033[1;31m         shyyyhhhhhhhhhhhso/:\033[1;33m---------------:+/---\033[1;31m/ydyyhs:`                                               ");
    $display("\033[1;31m         .mhyyyyyyhhhdddhhhhhs+:\033[1;33m----------------\033[1;31m:sdmhyyyyyyo:                                            ");
    $display("\033[1;31m        `hhdhhyyyyhhhhhddddhyyyyyo++/:\033[1;33m--------\033[1;31m:odmyhmhhyyyyhy                                            ");
    $display("\033[1;31m        -dyyhhyyyyyyhdhyhhddhhyyyyyhhhs+/::\033[1;33m-\033[1;31m:ohdmhdhhhdmdhdmy:                                           ");
    $display("\033[1;31m         hhdhyyyyyyyyyddyyyyhdddhhyyyyyhhhyyhdhdyyhyys+ossyhssy:-`                                                           ");
    $display("\033[1;31m         `Ndyyyyyyyyyyymdyyyyyyyhddddhhhyhhhhhhhhy+/:\033[1;33m-------::/+o++++-`                                       ");
    $display("\033[1;31m          dyyyyyyyyyyyyhNyydyyyyyyyyyyhhhhyyhhy+/\033[1;33m------------------:/ooo:`                                    ");
    $display("\033[1;31m         :myyyyyyyyyyyyyNyhmhhhyyyyyhdhyyyhho/\033[1;33m-------------------------:+o/`                                  ");
    $display("\033[1;31m        /dyyyyyyyyyyyyyyddmmhyyyyyyhhyyyhh+:\033[1;33m-----------------------------:+s-                                 ");
    $display("\033[1;31m      +dyyyyyyyyyyyyyyydmyyyyyyyyyyyyyds:\033[1;33m---------------------------------:s+                                 ");
    $display("\033[1;31m      -ddhhyyyyyyyyyyyyyddyyyyyyyyyyyhd+\033[1;33m------------------------------------:oo             `-++o+:.`         ");
    $display("\033[1;31m       `/dhshdhyyyyyyyyyhdyyyyyyyyyydh:\033[1;33m---------------------------------------s/             -o/://:/+s       ");
    $display("\033[1;31m         os-:/oyhhhhyyyydhyyyyyyyyyds:\033[1;33m----------------------------------------:h:--.`      `y:------+os       ");
    $display("\033[1;33m         h+-----\033[1;31m:/+oosshdyyyyyyyyhds\033[1;33m-------------------------------------------+h//o+s+-.` :o-------s/y  ");
    $display("\033[1;33m         m:------------\033[1;31mdyyyyyyyyymo\033[1;33m--------------------------------------------oh----:://++oo------:s/d  ");
    $display("\033[1;33m        `N/-----------+\033[1;31mmyyyyyyyydo\033[1;33m---------------------------------------------sy---------:/s------+o/d  ");
    $display("\033[1;33m        .m-----------:d\033[1;31mhhyyyyyyd+\033[1;33m----------------------------------------------y+-----------+:-----oo/h  ");
    $display("\033[1;33m        +s-----------+N\033[1;31mhmyyyyhd/\033[1;33m----------------------------------------------:h:-----------::-----+o/m  ");
    $display("\033[1;33m        h/----------:d/\033[1;31mmmhyyhh:\033[1;33m-----------------------------------------------oo-------------------+o/h  ");
    $display("\033[1;33m       `y-----------so /\033[1;31mNhydh:\033[1;33m-----------------------------------------------/h:-------------------:soo  ");
    $display("\033[1;33m    `.:+o:---------+h   \033[1;31mmddhhh/:\033[1;33m---------------:/osssssoo+/::---------------+d+//++///::+++//::::::/y+`  ");
    $display("\033[1;33m   -s+/::/--------+d.   \033[1;31mohso+/+y/:\033[1;33m-----------:yo+/:-----:/oooo/:----------:+s//::-.....--:://////+/:`    ");
    $display("\033[1;33m   s/------------/y`            `/oo:--------:y/-------------:/oo+:------:/s:                                                ");
    $display("\033[1;33m   o+:--------::++`              `:so/:-----s+-----------------:oy+:--:+s/``````                                             ");
    $display("\033[1;33m    :+o++///+oo/.                    .+o+::--os-------------------:oy+oo:`/o+++++o-                                          ");
    $display("\033[1;33m       .---.`                          -+oo/:yo:-------------------:oy-:h/:---:+oyo                                          ");
    $display("\033[1;33m                                          `:+omy/---------------------+h:----:y+//so                                         ");
    $display("\033[1;33m                                              `-ys:-------------------+s-----+s///om                                         ");
    $display("\033[1;33m                                                 -os+::---------------/y-----ho///om                                         ");
    $display("\033[1;33m                                                    -+oo//:-----------:h-----h+///+d                                         ");
    $display("\033[1;33m                                                       `-oyy+:---------s:----s/////y                                         ");
    $display("\033[1;33m                                                          `-/o+::-----:+----oo///+s                                          ");
    $display("\033[1;33m                                                             ./+o+::-------:y///s:                                           ");
    $display("\033[1;33m                                                                 ./+oo/-----oo/+h                                            ");
    $display("\033[1;33m                                                                     `://++++syo`                                            ");
    $display("\033[1;0m"); 
end endtask

//======================================
//      DEBUG TASK (生成中間值 txt 檔)
//======================================
task dump_debug_files_task;
    integer file_out;
    integer c, r, c_idx;
    integer l, out_c, in_c, kr, kc; // 用於讀取 Kernel 的迴圈變數
begin
    // 開啟 (或覆寫) debug_golden.txt 檔案，並指定路徑到 00_TESTBED
    file_out = $fopen("../00_TESTBED/debug_golden.txt", "w");
    
    $fwrite(file_out, "=========================================\n");
    $fwrite(file_out, "   PATTERN NO. %4d Debug Golden Model\n", pat);
    $fwrite(file_out, "=========================================\n\n");

    // ==========================================
    // [新增] Input Settings (Instruction, Image, Weights)
    // ==========================================
    $fwrite(file_out, "--- Input Instruction ---\n");
    // 解析 Padding
    if (inst_data[2] == 1'b0)
        $fwrite(file_out, "Padding Mode        : Zero Padding\n");
    else
        $fwrite(file_out, "Padding Mode        : Replication Padding\n");
    
    // 解析 Activation Function
    case (inst_data[1:0])
        2'b00: $fwrite(file_out, "Activation Function : Sigmoid\n");
        2'b01: $fwrite(file_out, "Activation Function : Tanh\n");
        2'b10: $fwrite(file_out, "Activation Function : ReLU\n");
        2'b11: $fwrite(file_out, "Activation Function : Leaky ReLU\n");
    endcase
    $fwrite(file_out, "\n");

    $fwrite(file_out, "--- Input Image (8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(img_map[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Input Weights (Kernels 3x3) ---\n");
    for (l = 0; l < 4; l = l + 1) begin
        if (l == 0)      $fwrite(file_out, "[Layer 0: Convolution_0 Kernels]\n");
        else if (l == 1) $fwrite(file_out, "[Layer 1: Convolution_1 Kernels]\n");
        else if (l == 2) $fwrite(file_out, "[Layer 2: Deconvolution_0 Kernels]\n");
        else if (l == 3) $fwrite(file_out, "[Layer 3: Deconvolution_1 Kernels]\n");
        
        for (out_c = 0; out_c < 2; out_c = out_c + 1) begin
            for (in_c = 0; in_c < 2; in_c = in_c + 1) begin
                $fwrite(file_out, "  Out_Channel %0d, In_Channel %0d:\n", out_c, in_c);
                for (kr = 0; kr < 3; kr = kr + 1) begin
                    $fwrite(file_out, "  ");
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        // 依照 raster scan order 取出對應的權重
                        $fwrite(file_out, "%-14e ", _floatBitsToReal(weight_data[l*36 + out_c*18 + in_c*9 + kr*3 + kc]));
                    end
                    $fwrite(file_out, "\n");
                end
                $fwrite(file_out, "\n");
            end
        end
    end
    $fwrite(file_out, "=========================================\n\n");

    // ==========================================
    // 0. 影像預處理 (Min-Max Scaling)
    // ==========================================
    $fwrite(file_out, "--- Preprocessing: Min-Max Scaling (8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(img_scaled[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    // ==========================================
    // Layer 0 (Encoder)
    // ==========================================
    $fwrite(file_out, "--- Layer 0: Padding_0 (10x10) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 10; r = r + 1) begin
            for (c_idx = 0; c_idx < 10; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pad_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 0: Convolution_0 (8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(conv_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 0: Max-Pooling_0 (8x8 -> 4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pool_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 0: Activation_0 (4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(act_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    // ==========================================
    // Layer 1 (Encoder)
    // ==========================================
    $fwrite(file_out, "--- Layer 1: Padding_1 (6x6) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 6; r = r + 1) begin
            for (c_idx = 0; c_idx < 6; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pad_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 1: Convolution_1 (4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(conv_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 1: Max-Pooling_1 (4x4 -> 2x2) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 2; r = r + 1) begin
            for (c_idx = 0; c_idx < 2; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pool_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 1: Activation_1 (2x2) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 2; r = r + 1) begin
            for (c_idx = 0; c_idx < 2; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(act_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    // ==========================================
    // Layer 2 (Decoder)
    // ==========================================
    $fwrite(file_out, "--- Layer 2: Unpooling_0 (2x2 -> 4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(unpool_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 2: Padding_2 (6x6) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 6; r = r + 1) begin
            for (c_idx = 0; c_idx < 6; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pad_2[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 2: Deconvolution_0 (4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(deconv_0[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 2: Activation_2 (4x4) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 4; r = r + 1) begin
            for (c_idx = 0; c_idx < 4; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(act_2[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    // ==========================================
    // Layer 3 (Decoder)
    // ==========================================
    $fwrite(file_out, "--- Layer 3: Unpooling_1 (4x4 -> 8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(unpool_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 3: Padding_3 (10x10) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 10; r = r + 1) begin
            for (c_idx = 0; c_idx < 10; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(pad_3[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 3: Deconvolution_1 (8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(deconv_1[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fwrite(file_out, "--- Layer 3: Activation_3 (Final Output 8x8) ---\n");
    for (c = 0; c < 2; c = c + 1) begin
        $fwrite(file_out, "[Channel %0d]\n", c);
        for (r = 0; r < 8; r = r + 1) begin
            for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin
                $fwrite(file_out, "%-14e ", _floatBitsToReal(act_3[c][r][c_idx]));
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");
    end

    $fclose(file_out);
    $display("\033[1;33m[INFO] Debug files 'debug_golden.txt' has been generated in 00_TESTBED/!\033[0m");
end endtask



//======================================
//      UTILITY FUNCTIONS (浮點數轉換)
//======================================
// 借用往年 PATTERN 的實數轉 IEEE-754 32-bit 浮點數函數
function [31:0] _realTofloatBits;
    input real _in;
    reg [63:0] _realBits;
begin
    // 新增：特例處理 0.0
    if (_in == 0.0) begin
        _realTofloatBits = 32'd0;
    end else begin
        _realBits = $realtobits(_in); // 將 real 轉成 64-bit IEEE-754 雙精度
        
        // Sign bit
        _realTofloatBits[31] = _realBits[63];
        // Exponent: Double bias (1023) 轉 Float bias (127) -> - 1023 + 127 = - 896
        _realTofloatBits[30:23] = _realBits[62:52] - 11'd896;
        // Fraction (從 52-bit 截斷成 23-bit)
        _realTofloatBits[22:0]  = _realBits[51:29];
    end
end endfunction

// 借用往年 PATTERN 的 IEEE-754 32-bit 轉實數函數
function real _floatBitsToReal;
    input reg [31:0] _in;
    reg [63:0] _realBits;
begin
    // 新增：特例處理 0.0
    if (_in == 32'd0) begin
        _floatBitsToReal = 0.0;
    end else begin
        _realBits = 64'b0;
        
        // Sign bit
        _realBits[63] = _in[31];
        // Exponent: Float bias (127) 轉 Double bias (1023) -> - 127 + 1023 = + 896
        _realBits[62:52] = _in[30:23] + 11'd896;
        // Fraction (從 23-bit 展開成 52-bit，後面補 0)
        _realBits[51:29] = _in[22:0];
        
        // 若輸入是 unknown ('bx)，回傳 NaN，否則將 bit 轉回 real
        _floatBitsToReal = (_in === 32'bx) ? 0.0/0.0 : $bitstoreal(_realBits);
    end
end endfunction

//=====================================
//     共用的 Activation Function 
//=====================================
function real apply_activation;
    input real x;
    input [1:0] act_type;
    real exp_pos, exp_neg;
begin
    case (act_type)
        2'b00: begin // Sigmoid: 1 / (1 + e^-x)
            exp_neg = $exp(-x);
            apply_activation = 1.0 / (1.0 + exp_neg);
        end
        2'b01: begin // Tanh: (e^x - e^-x) / (e^x + e^-x)
            exp_pos = $exp(x);
            exp_neg = $exp(-x);
            apply_activation = (exp_pos - exp_neg) / (exp_pos + exp_neg);
        end
        2'b10: begin // ReLU: max(0, x)
            apply_activation = (x > 0.0) ? x : 0.0;
        end
        2'b11: begin // Leaky ReLU
            if (x > 0.0) begin
                apply_activation = x;
            end else if (x > -$pow(2.0, -123)) begin 
                // 規格書特例: 若 -2^-123 < x <= 0，則 f(x) = 0
                apply_activation = 0.0;
            end else begin
                apply_activation = 0.125 * x;
            end
        end
    endcase
end endfunction

endmodule