`define CYCLE_TIME      9.5
`define SEED_NUMBER     28825252
`define PATTERN_NUMBER  20

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
output reg          clk;
output reg          rst_n;
output reg          i_valid;
output reg    [2:0] i_iter;
output reg    [1:0] i_mode;
output reg    [7:0] i_data;
output reg    [3:0] i_weight;

input               o_valid;
input         [7:0] o_data;

// ========================================
// clock
// ========================================
real CYCLE = `CYCLE_TIME;
initial clk = 1'b0;
always  #(CYCLE/2.0) clk = ~clk;

// ========================================
// integer & parameter
// ========================================
integer pat, i, gap;
integer seed = `SEED_NUMBER;
integer latency;
integer total_latency;

integer current_k; // 全域變數：紀錄目前計算到第幾個 iteration

// ========================================
// Data Arrays (Golden Model)
// ========================================
// --- 測資與正確答案 ---
reg signed [3:0] gold_weight [0:1311]; // 1312 筆權重
reg        [7:0] gold_image  [0:4095]; // 4096 筆初始影像
reg        [2:0] gold_iter;            // [1, 7]
reg        [1:0] gold_mode;            // [0, 2]
reg        [7:0] gold_out    [0:4095]; // 最終降噪答案

// --- 每一輪的輸入/輸出 ---
integer img_in_iter   [0:6][0:63][0:63];
integer denoise_out   [0:6][0:63][0:63];

// --- 階段 1: Down Sampling ---
integer conv_down_out [0:6][0:15][0:15][0:15]; // [iter][ch][r][c]

// --- 階段 2: Transformer Block ---
integer trans_in      [0:6][0:255][0:15];      // [iter][pt][ch]
integer q_mat         [0:6][0:255][0:15];      
integer k_mat         [0:6][0:255][0:15];      
integer v_mat         [0:6][0:255][0:15];      
integer attn_scores   [0:6][0:255][0:255];     
integer attn_out      [0:6][0:255][0:15];      
integer ffn_out       [0:6][0:255][0:15];      

// --- 階段 3 & 4: Up Sampling & Interpolation ---
integer trans_reorder [0:6][0:15][0:15][0:15]; // [iter][ch][r][c]
integer conv_up_out   [0:6][0:15][0:15];       // [iter][r][c]
integer interp_out    [0:6][0:63][0:63];       // [iter][r][c]

//================================================================
// Main Flow
//================================================================
initial begin
    reset_task;
    
    generate_weight_task;
    input_weight_task;
    
    for (pat = 0; pat < `PATTERN_NUMBER; pat = pat + 1) begin
        generate_image_task; 
        cal_task;            
        
        input_image_task;    
        wait_out_valid_task; 
        check_output_task;   
        
        $display("\033[0;34mPASS PATTERN NO.%4d \033[m", pat);
    end
    
    pass_task;
    $finish;
end

//================================================================
// Verification Tasks (I/O, Reset, Check)
//================================================================
task reset_task; begin
    force clk = 0;
    rst_n = 1;
    i_valid = 0;
    i_iter = 3'bx;
    i_mode = 2'bx;
    i_data = 8'bx;
    i_weight = 4'bx;
    total_latency = 0;

    #(`CYCLE_TIME/2.0) rst_n = 0;
    #(`CYCLE_TIME/2.0) rst_n = 1;
    
    if (o_valid !== 0 || o_data !== 0) begin
        $display("[ERROR] Output signals should be 0 during reset.");
        $finish;
    end
    
    #(`CYCLE_TIME/2.0) release clk;
end endtask

task generate_weight_task; begin
    for (i = 0; i < 1312; i = i + 1) begin
        gold_weight[i] = $random(seed) % 8; // 產生 -8 ~ 7 有號數
    end
end endtask

task input_weight_task; begin
    gap = {$random(seed)} % 3 + 1;
    repeat(gap) @(negedge clk);
    
    for (i = 0; i < 1312; i = i + 1) begin
        i_valid = 1'b1;
        i_weight = gold_weight[i];
        @(negedge clk);
    end
    
    i_valid = 1'b0;
    i_weight = 4'bx;
end endtask

task generate_image_task; begin
    gold_iter = ({$random(seed)} % 7) + 1; // 1 ~ 7
    gold_mode = {$random(seed)} % 3;       // 0 ~ 2
    
    for (i = 0; i < 4096; i = i + 1) begin
        gold_image[i] = {$random(seed)} % 256; // 0 ~ 255
    end
end endtask

task input_image_task; begin
    gap = {$random(seed)} % 3 + 1;
    repeat(gap) @(negedge clk);
    
    for (i = 0; i < 4096; i = i + 1) begin
        i_valid = 1'b1;
        i_data  = gold_image[i];
        
        if (i == 0) begin
            i_iter = gold_iter;
            i_mode = gold_mode;
        end else begin
            i_iter = 3'bx;
            i_mode = 2'bx;
        end
        @(negedge clk);
    end
    
    i_valid = 1'b0;
    i_data  = 8'bx;
    i_iter  = 3'bx;
    i_mode  = 2'bx;
end endtask

// --- Wait & Latency Task ---
task wait_out_valid_task; begin
    latency = 0;
    while (o_valid !== 1'b1) begin
        // 規格書規定單次 iteration 延遲上限為 150,000 cycles
        if (latency == (150000 * gold_iter)) begin 
            $display("");
            $display("\033[1;31m===================================================================\033[0m");
            $display("\033[1;31m  ███████╗ ██████╗  ██████╗  ██████╗  ██████╗ \033[0m");
            $display("\033[1;31m  ██╔════╝ ██╔══██╗ ██╔══██╗ ██╔═══██╗ ██╔══██╗\033[0m");
            $display("\033[1;31m  █████╗   ██████╔╝ ██████╔╝ ██║   ██║ ██████╔╝\033[0m");
            $display("\033[1;31m  ██╔══╝   ██╔══██╗ ██╔══██╗ ██║   ██║ ██╔══██╗\033[0m");
            $display("\033[1;31m  ███████╗ ██║  ██║ ██║  ██║ ╚██████╔╝ ██║  ██║\033[0m");
            $display("\033[1;31m  ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝  ╚═════╝  ╚═╝  ╚═╝\033[0m");
            $display("\033[1;31m===================================================================\033[0m");
            $display("\033[1;31m  [FATAL ERROR] Latency exceeded the 150,000 cycles limit!         \033[0m");
            $display("\033[1;31m                Current Pattern No. %0d                            \033[0m", pat);
            $display("\033[1;31m===================================================================\033[0m");
            $display("");
            
            // 呼叫剛剛寫好的 Debug 輸出功能，把死當前的狀況印出來！
            dump_debug_files_task; 
            
            $finish;
        end
        
        if (o_data !== 8'd0) begin
            $display("");
            $display("\033[1;31m===================================================================\033[0m");
            $display("\033[1;31m  [ERROR] o_data should be exactly 0 when o_valid is LOW!          \033[0m");
            $display("\033[1;31m===================================================================\033[0m");
            $display("");
            dump_debug_files_task; 
            $finish;
        end
        
        latency = latency + 1;
        @(negedge clk);
    end
end endtask

task check_output_task; 
    integer out_count;
begin
    out_count = 0;
    while (out_count < 4096) begin
        if (o_valid === 1'b1) begin
            if (o_data !== gold_out[out_count]) begin
                $display("\033[1;31m[ERROR] Output mismatch at Pixel %0d!\033[0m", out_count);
                $display("        Golden : %3d", gold_out[out_count]);
                $display("        Your   : %3d", o_data);
                dump_debug_files_task;
                $finish;
            end
            out_count = out_count + 1;
        end
        @(negedge clk);
    end
    
    if (o_valid !== 1'b0) begin
        $display("[ERROR] o_valid should go low after 4096 outputs!");
        dump_debug_files_task;
        $finish;
    end
    total_latency = total_latency + latency;
end endtask

task pass_task; begin
    $display("\n========================================================");
    $display("                Congratulation!!!                       ");
    $display("     You have passed all patterns!                      ");
    $display("     Total Latency : %0d                                ", total_latency);
    $display("========================================================\n");
end endtask

//================================================================
// Golden Model Calculation Tasks
//================================================================
task cal_task;
    integer r, c;
begin
    // 0. 載入初始影像到第 0 輪輸入
    for (r = 0; r < 64; r = r + 1) begin
        for (c = 0; c < 64; c = c + 1) begin
            img_in_iter[0][r][c] = gold_image[r * 64 + c];
        end
    end
    
    // 1. 開始迭代
    for (current_k = 0; current_k < gold_iter; current_k = current_k + 1) begin
        down_sampling_task;
        
        reorder_pre_trans_task;
        trans_midpoint_task;
        trans_qkv_task;
        trans_attn_task;
        trans_ffn_task;
        reorder_post_trans_task;
        
        up_sampling_task;
        interpolation_task;
        denoise_task;
        
        // 將降噪結果傳給下一輪 (若還有迭代)
        if (current_k < gold_iter - 1) begin
            for (r = 0; r < 64; r = r + 1) begin
                for (c = 0; c < 64; c = c + 1) begin
                    img_in_iter[current_k + 1][r][c] = denoise_out[current_k][r][c];
                end
            end
        end
    end
    
    // 2. 將最後一輪的結果寫入 gold_out
    for (r = 0; r < 64; r = r + 1) begin
        for (c = 0; c < 64; c = c + 1) begin
            gold_out[r * 64 + c] = denoise_out[gold_iter - 1][r][c];
        end
    end
end endtask

// --- Down Sampling ---
task down_sampling_task;
    integer oc, r, c, kr, kc, img_r, img_c, val_in, sum;
begin
    for (oc = 0; oc < 16; oc = oc + 1) begin
        for (r = 0; r < 16; r = r + 1) begin
            for (c = 0; c < 16; c = c + 1) begin
                sum = 0;
                for (kr = 0; kr < 3; kr = kr + 1) begin
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        img_r = r * 4 + kr - 1; 
                        img_c = c * 4 + kc - 1;
                        if (img_r >= 0 && img_r < 64 && img_c >= 0 && img_c < 64)
                            val_in = img_in_iter[current_k][img_r][img_c];
                        else
                            val_in = 0; // Zero padding
                        sum = sum + val_in * gold_weight[oc * 9 + kr * 3 + kc];
                    end
                end
                sum = (sum >>> 6) + 128;
                if (sum < 0) sum = 0; else if (sum > 255) sum = 255;
                conv_down_out[current_k][oc][r][c] = sum;
            end
        end
    end
end endtask

// --- Transformer: Pre-Reorder ---
task reorder_pre_trans_task;
    integer ch, r, c, pt_idx;
begin
    for (r = 0; r < 16; r = r + 1) begin
        for (c = 0; c < 16; c = c + 1) begin
            pt_idx = r * 16 + c; 
            for (ch = 0; ch < 16; ch = ch + 1) begin
                trans_in[current_k][pt_idx][ch] = conv_down_out[current_k][ch][r][c];
            end 
        end
    end
end endtask

// --- Transformer: Midpoint ---
task trans_midpoint_task;
    integer pt, ch;
begin
    for (pt = 0; pt < 256; pt = pt + 1) begin
        for (ch = 0; ch < 16; ch = ch + 1) begin
            trans_in[current_k][pt][ch] = trans_in[current_k][pt][ch] - 128; 
        end
    end
end endtask

// --- Transformer: QKV Generation ---
task trans_qkv_task;
    integer pt, out_ch, in_ch, sum_q, sum_k, sum_v;
    integer w_q, w_k, w_v;
begin
    w_q = 144; w_k = 400; w_v = 656;
    for (pt = 0; pt < 256; pt = pt + 1) begin
        for (out_ch = 0; out_ch < 16; out_ch = out_ch + 1) begin
            sum_q = 0; sum_k = 0; sum_v = 0;
            for (in_ch = 0; in_ch < 16; in_ch = in_ch + 1) begin
                sum_q = sum_q + trans_in[current_k][pt][in_ch] * gold_weight[w_q + in_ch * 16 + out_ch];
                sum_k = sum_k + trans_in[current_k][pt][in_ch] * gold_weight[w_k + in_ch * 16 + out_ch];
                sum_v = sum_v + trans_in[current_k][pt][in_ch] * gold_weight[w_v + in_ch * 16 + out_ch];
            end
            sum_q = sum_q >>> 4;
            if (sum_q > 127) sum_q = 127; else if (sum_q < -128) sum_q = -128;
            q_mat[current_k][pt][out_ch] = sum_q;
            
            sum_k = sum_k >>> 4;
            if (sum_k > 127) sum_k = 127; else if (sum_k < -128) sum_k = -128;
            k_mat[current_k][pt][out_ch] = sum_k;
            
            sum_v = sum_v >>> 4;
            if (sum_v > 127) sum_v = 127; else if (sum_v < -128) sum_v = -128;
            v_mat[current_k][pt][out_ch] = sum_v;
        end
    end
end endtask

// --- Transformer: Attention (MatMul -> SoftMax -> MatMul) ---
task trans_attn_task;
    integer pt_q, pt_k, ch, sum;
begin
    // 1. Q * K^T + Softmax
    for (pt_q = 0; pt_q < 256; pt_q = pt_q + 1) begin
        for (pt_k = 0; pt_k < 256; pt_k = pt_k + 1) begin
            sum = 0;
            for (ch = 0; ch < 16; ch = ch + 1) begin
                sum = sum + q_mat[current_k][pt_q][ch] * k_mat[current_k][pt_k][ch];
            end
            sum = sum >>> 2;
            if (sum > 2047) sum = 2047; else if (sum < -2048) sum = -2048;
            
            sum = (sum >>> 4) + 128;
            if (sum > 255) sum = 255; else if (sum < 0) sum = 0;
            attn_scores[current_k][pt_q][pt_k] = sum;
        end
    end
    
    // 2. Score * V
    for (pt_q = 0; pt_q < 256; pt_q = pt_q + 1) begin
        for (ch = 0; ch < 16; ch = ch + 1) begin
            sum = 0;
            for (pt_k = 0; pt_k < 256; pt_k = pt_k + 1) begin
                sum = sum + attn_scores[current_k][pt_q][pt_k] * v_mat[current_k][pt_k][ch];
            end
            sum = sum >>> 16;
            if (sum > 127) sum = 127; else if (sum < -128) sum = -128;
            attn_out[current_k][pt_q][ch] = sum;
        end
    end
end endtask

// --- Transformer: FFN ---
task trans_ffn_task;
    integer pt, out_ch, in_ch, sum, w_ffn;
begin
    w_ffn = 912;
    for (pt = 0; pt < 256; pt = pt + 1) begin
        for (out_ch = 0; out_ch < 16; out_ch = out_ch + 1) begin
            sum = 0;
            for (in_ch = 0; in_ch < 16; in_ch = in_ch + 1) begin
                sum = sum + attn_out[current_k][pt][in_ch] * gold_weight[w_ffn + in_ch * 16 + out_ch];
            end
            sum = (sum >>> 4) + 128;
            if (sum < 0) sum = 0; else if (sum > 255) sum = 255;
            ffn_out[current_k][pt][out_ch] = sum;
        end
    end
end endtask

// --- Transformer: Post-Reorder ---
task reorder_post_trans_task;
    integer ch, r, c, pt_idx;
begin
    for (r = 0; r < 16; r = r + 1) begin
        for (c = 0; c < 16; c = c + 1) begin
            pt_idx = r * 16 + c;
            for (ch = 0; ch < 16; ch = ch + 1) begin
                trans_reorder[current_k][ch][r][c] = ffn_out[current_k][pt_idx][ch];
            end
        end
    end
end endtask

// --- Up Sampling ---
task up_sampling_task;
    integer r, c, in_c, kr, kc, img_r, img_c, val_in, sum, w_up;
begin
    w_up = 1168; // Up Sampling weights index starts here (144 elements)
    for (r = 0; r < 16; r = r + 1) begin
        for (c = 0; c < 16; c = c + 1) begin
            sum = 0;
            // 跨 16 個 Channel 加總
            for (in_c = 0; in_c < 16; in_c = in_c + 1) begin
                for (kr = 0; kr < 3; kr = kr + 1) begin
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        img_r = r + kr - 1; // Stride 1
                        img_c = c + kc - 1;
                        if (img_r >= 0 && img_r < 16 && img_c >= 0 && img_c < 16)
                            val_in = trans_reorder[current_k][in_c][img_r][img_c];
                        else
                            val_in = 0;
                        sum = sum + val_in * gold_weight[w_up + in_c * 9 + kr * 3 + kc];
                    end
                end
            end
            sum = (sum >>> 6) + 128;
            if (sum < 0) sum = 0; else if (sum > 255) sum = 255;
            conv_up_out[current_k][r][c] = sum;
        end
    end
end endtask

// --- Interpolation ---
task interpolation_task;
    integer r, c, r_up, c_up, step, curr_p, next_p, diff, val;
begin
    for (r = 0; r < 64; r = r + 1) begin
        for (c = 0; c < 64; c = c + 1) begin
            r_up = r / 4;
            c_up = c / 4;
            
            if (gold_mode == 0) begin // Mode 0: Nearest
                interp_out[current_k][r][c] = conv_up_out[current_k][r_up][c_up];
            end
            else if (gold_mode == 1) begin // Mode 1: X-dir
                step = c % 4;
                if (c_up < 15) begin
                    curr_p = conv_up_out[current_k][r_up][c_up];
                    next_p = conv_up_out[current_k][r_up][c_up + 1];
                    diff = (next_p - curr_p) >>>2;
                end else begin
                    curr_p = conv_up_out[current_k][r_up][15];
                    next_p = conv_up_out[current_k][r_up][14]; // Use prev for extrapolation
                    diff = (curr_p - next_p) >>>2; // Extrapolation slope
                end
                val = curr_p + diff * step;
                if (val > 255) val = 255; else if (val < 0) val = 0;
                interp_out[current_k][r][c] = val;
            end
            else if (gold_mode == 2) begin // Mode 2: Y-dir
                step = r % 4;
                if (r_up < 15) begin
                    curr_p = conv_up_out[current_k][r_up][c_up];
                    next_p = conv_up_out[current_k][r_up + 1][c_up];
                    diff = (next_p - curr_p) >>>2;
                end else begin
                    curr_p = conv_up_out[current_k][15][c_up];
                    next_p = conv_up_out[current_k][14][c_up]; // Use prev for extrapolation
                    diff = (curr_p - next_p) >>>2;
                end
                val = curr_p + diff * step;
                if (val > 255) val = 255; else if (val < 0) val = 0;
                interp_out[current_k][r][c] = val;
            end
        end
    end
end endtask

// --- Denoise ---
task denoise_task;
    integer r, c, val;
begin
    for (r = 0; r < 64; r = r + 1) begin
        for (c = 0; c < 64; c = c + 1) begin
            // 縮放雜訊 (>> 3)
            val = img_in_iter[current_k][r][c] - (interp_out[current_k][r][c] >>> 3);
            if (val > 255) val = 255; else if (val < 0) val = 0;
            denoise_out[current_k][r][c] = val;
        end
    end 
end endtask


//================================================================
//      DEBUG TASK (生成終極排版對齊的 txt 檔)
//================================================================
task dump_debug_files_task;
    integer file_out;
    integer k, r, c, ch, pt;
begin
    // 開啟 (或覆寫) debug_golden.txt 檔案
    file_out = $fopen("debug_golden.txt", "w");
    
    // ---------------------------------------------------------
    // 檔頭資訊 (Pattern No., Iterations, Mode)
    // ---------------------------------------------------------
    $fwrite(file_out, "=========================================================\n");
    $fwrite(file_out, "   PATTERN NO. %4d Debug Golden Model\n", pat);
    $fwrite(file_out, "   Target Iterations : %0d\n", gold_iter);
    $fwrite(file_out, "   Interpolation Mode: %0d\n", gold_mode);
    $fwrite(file_out, "=========================================================\n\n");

    // ---------------------------------------------------------
    // 依照 Iteration 順序，印出每一階段的計算矩陣
    // ---------------------------------------------------------
    for (k = 0; k < gold_iter; k = k + 1) begin
        $fwrite(file_out, "#########################################################\n");
        $fwrite(file_out, "                     ITERATION %0d\n", k);
        $fwrite(file_out, "#########################################################\n\n");

        // 1. 本輪輸入影像 (64x64, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 1. Input Image (64x64) ---\n");
        for (r = 0; r < 64; r = r + 1) begin
            $fwrite(file_out, "[R %2d] ", r); // 加入 Row Index
            for (c = 0; c < 64; c = c + 1) begin
                $fwrite(file_out, "%4d ", img_in_iter[k][r][c]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 2. 降採樣卷積輸出 (16x16x16, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 2. Down Sampling Output (16x16x16) ---\n");
        for (ch = 0; ch < 16; ch = ch + 1) begin
            $fwrite(file_out, "[Channel %2d]\n", ch);
            for (r = 0; r < 16; r = r + 1) begin
                $fwrite(file_out, "  [R %2d] ", r); // 加入 Row Index
                for (c = 0; c < 16; c = c + 1) begin
                    $fwrite(file_out, "%4d ", conv_down_out[k][ch][r][c]);
                end
                $fwrite(file_out, "\n");
            end
            $fwrite(file_out, "\n");
        end

        // 3. Transformer - Q 矩陣 (256x16, 有號數 -128~127 -> %5d 預留負號)
        $fwrite(file_out, "--- 3. Transformer: Q Matrix (256x16) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt); // 加入 Point Index (0~255)
            for (ch = 0; ch < 16; ch = ch + 1) begin
                $fwrite(file_out, "%5d ", q_mat[k][pt][ch]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 4. Transformer - K 矩陣 (256x16, 有號數 -128~127 -> %5d)
        $fwrite(file_out, "--- 4. Transformer: K Matrix (256x16) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt);
            for (ch = 0; ch < 16; ch = ch + 1) begin
                $fwrite(file_out, "%5d ", k_mat[k][pt][ch]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 5. Transformer - V 矩陣 (256x16, 有號數 -128~127 -> %5d)
        $fwrite(file_out, "--- 5. Transformer: V Matrix (256x16) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt);
            for (ch = 0; ch < 16; ch = ch + 1) begin
                $fwrite(file_out, "%5d ", v_mat[k][pt][ch]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 6. Transformer - Attention Scores (256x256, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 6. Transformer: Attention Scores (256x256) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt);
            for (c = 0; c < 256; c = c + 1) begin
                $fwrite(file_out, "%4d ", attn_scores[k][pt][c]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 7. Transformer - Attention Output (256x16, 有號數 -128~127 -> %5d)
        $fwrite(file_out, "--- 7. Transformer: Attention Output (256x16) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt);
            for (ch = 0; ch < 16; ch = ch + 1) begin
                $fwrite(file_out, "%5d ", attn_out[k][pt][ch]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 8. Transformer - FFN Output (256x16, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 8. Transformer: FFN Output (256x16) ---\n");
        for (pt = 0; pt < 256; pt = pt + 1) begin
            $fwrite(file_out, "[Pt %3d] ", pt);
            for (ch = 0; ch < 16; ch = ch + 1) begin
                $fwrite(file_out, "%4d ", ffn_out[k][pt][ch]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 9. 升採樣卷積輸出 (16x16, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 9. Up Sampling Output (16x16) ---\n");
        for (r = 0; r < 16; r = r + 1) begin
            $fwrite(file_out, "[R %2d] ", r);
            for (c = 0; c < 16; c = c + 1) begin
                $fwrite(file_out, "%4d ", conv_up_out[k][r][c]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 10. 內插放大輸出 (64x64, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 10. Interpolation Output (64x64) ---\n");
        for (r = 0; r < 64; r = r + 1) begin
            $fwrite(file_out, "[R %2d] ", r);
            for (c = 0; c < 64; c = c + 1) begin
                $fwrite(file_out, "%4d ", interp_out[k][r][c]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

        // 11. 降噪結果輸出 (64x64, 無號數 0~255 -> %4d)
        $fwrite(file_out, "--- 11. Denoise Output (64x64) ---\n");
        for (r = 0; r < 64; r = r + 1) begin
            $fwrite(file_out, "[R %2d] ", r);
            for (c = 0; c < 64; c = c + 1) begin
                $fwrite(file_out, "%4d ", denoise_out[k][r][c]);
            end
            $fwrite(file_out, "\n");
        end
        $fwrite(file_out, "\n");

    end // End of Iteration Loop

    $fclose(file_out);
    $display("\033[1;33m[INFO] Debug file 'debug_golden.txt' has been generated!\033[0m");
end endtask

endmodule