`define CYCLE_TIME      10.0
`define SEED_NUMBER     28825252
`define PATTERN_NUMBER  20

module PATTERN(
           // Output Port (To DUT)
           output reg clk,
           output reg rst_n,
           output reg i_valid,
           output reg [2:0] i_iter,
           output reg [1:0] i_mode,
           output reg [3:0] i_weight,
           output reg [7:0] i_data,

           // Input Port (From DUT)
           input wire o_valid,
           input wire [7:0] o_data
       );

//======================================
//      PARAMETERS & VARIABLES
//======================================
integer pat;
integer i, j, gap;
integer seed = `SEED_NUMBER;

integer latency;
integer total_latency;

// Stored Pattern Inputs
reg [2:0] inst_iter;
reg [1:0] inst_mode;
reg signed [3:0] weight_data [0:1311];
reg [7:0] image_data [0:4095];

//======================================
//      ALGORITHM GOLDEN MODEL ARRAYS
//======================================
integer img_curr   [0:63][0:63];
integer feat_down  [0:15][0:15][0:15];
integer feat_vec   [0:255][0:15];

integer q_mat      [0:255][0:15];
integer k_mat      [0:255][0:15];
integer v_mat      [0:255][0:15];
integer attn_score [0:255][0:255];
integer attn_out   [0:255][0:15];
integer ffn_out    [0:255][0:15];

integer feat_up    [0:15][0:15][0:15];
integer noise_pred [0:15][0:15];
integer noise_interp[0:63][0:63];

// Weights unpacked
integer w_conv1 [0:15][0:2][0:2];
integer w_q     [0:15][0:15];
integer w_k     [0:15][0:15];
integer w_v     [0:15][0:15];
integer w_ffn   [0:15][0:15];
integer w_conv2 [0:15][0:2][0:2];

//======================================
//      CLOCK GENERATION
//======================================
initial
    clk = 1'b0;
always #(`CYCLE_TIME/2.0) clk = ~clk;

//======================================
//      MAIN FLOW
//======================================
initial begin
    reset_task;

    // Generate and send Weights ONLY ONCE
    generate_weights_task;
    send_weights_task;

    for (pat = 0; pat < `PATTERN_NUMBER; pat = pat + 1) begin
        generate_image_task;
        cal_task; // Calculate Golden Model for current pattern AND DUMP debug files
        send_image_task;
        wait_task;
        check_task;

        $display("\033[0;34mPASS PATTERN NO.%4d, Iterations: %0d, Mode: %0d, Latency: %0d\033[m", pat, inst_iter, inst_mode, latency);
    end
    pass_task;
    $finish;
end

//======================================
//      TASKS
//======================================

task reset_task;
    begin
        force clk = 0;
        rst_n    = 1;
        i_valid  = 0;
        i_iter   = 3'bx;
        i_mode   = 2'bx;
        i_weight = 4'bx;
        i_data   = 8'bx;
        total_latency = 0;

        #(`CYCLE_TIME/2.0) rst_n = 0;
        #(`CYCLE_TIME/2.0);

        if (o_valid !== 1'b0 || o_data !== 8'd0) begin
            $display("\033[1;31m[ERROR] Asynchronous reset failed! Output must be 0.\033[0m");
            $finish;
        end

        #(`CYCLE_TIME/2.0) rst_n = 1;
        #(`CYCLE_TIME/2.0) release clk;
    end
endtask

task generate_weights_task;
    integer ptr, ch, r, c, w_val;
    begin
        for (i = 0; i < 1312; i = i + 1) begin
            w_val = $unsigned({$random(seed)}) % 16;
            weight_data[i] = w_val[3:0]; // -8 to 7
        end

        ptr = 0;
        // Down Conv (144)
        for(ch=0; ch<16; ch=ch+1)
            for(r=0; r<3; r=r+1)
                for(c=0; c<3; c=c+1) begin
                    w_conv1[ch][r][c] = weight_data[ptr];
                    ptr = ptr + 1;
                end
        // Q, K, V, FFN (256 each)
        for(r=0; r<16; r=r+1)
            for(c=0; c<16; c=c+1) begin
                w_q[r][c] = weight_data[ptr];
                ptr = ptr + 1;
            end
        for(r=0; r<16; r=r+1)
            for(c=0; c<16; c=c+1) begin
                w_k[r][c] = weight_data[ptr];
                ptr = ptr + 1;
            end
        for(r=0; r<16; r=r+1)
            for(c=0; c<16; c=c+1) begin
                w_v[r][c] = weight_data[ptr];
                ptr = ptr + 1;
            end
        for(r=0; r<16; r=r+1)
            for(c=0; c<16; c=c+1) begin
                w_ffn[r][c] = weight_data[ptr];
                ptr = ptr + 1;
            end
        // Up Conv (144)
        for(ch=0; ch<16; ch=ch+1)
            for(r=0; r<3; r=r+1)
                for(c=0; c<3; c=c+1) begin
                    w_conv2[ch][r][c] = weight_data[ptr];
                    ptr = ptr + 1;
                end
    end
endtask

task generate_image_task;
    begin
        inst_iter = ($unsigned({$random(seed)}) % 7) + 1; // 1 to 7
        inst_mode = $unsigned({$random(seed)}) % 3;       // 0 to 2

        for (i = 0; i < 4096; i = i + 1) begin
            image_data[i] = $unsigned({$random(seed)}) % 256;
        end
    end
endtask

task check_valid_overlap_task;
    begin
        if (o_valid === 1'b1) begin
            $display("\033[1;31m[ERROR] o_valid cannot overlap with i_valid!\033[0m");
            $finish;
        end
    end
endtask

task send_weights_task;
    begin
        gap = $unsigned({$random(seed)}) % 4 + 2;
        repeat(gap) @(negedge clk);

        for (i = 0; i < 1312; i = i + 1) begin
            check_valid_overlap_task;
            i_valid  = 1'b1;
            i_weight = weight_data[i];
            i_iter   = 3'bx;
            i_mode   = 2'bx;
            i_data   = 8'bx;
            @(negedge clk);
        end
        i_valid  = 1'b0;
        i_weight = 4'bx;
    end
endtask

task send_image_task;
    begin
        gap = $unsigned({$random(seed)}) % 3 + 1;
        repeat(gap) @(negedge clk);

        for (i = 0; i < 4096; i = i + 1) begin
            check_valid_overlap_task;
            i_valid = 1'b1;
            i_data  = image_data[i];

            if (i == 0) begin
                i_iter = inst_iter;
                i_mode = inst_mode;
            end
            else begin
                i_iter = 3'bx;
                i_mode = 2'bx;
            end

            @(negedge clk);
        end
        i_valid = 1'b0;
        i_iter  = 3'bx;
        i_mode  = 2'bx;
        i_data  = 8'bx;
    end
endtask

task wait_task;
    begin
        latency = 0; // 🚀 全局 latency 在這裡初始化為 0
        while (o_valid !== 1'b1) begin
            // 👇 就是這裡！把原本寫死的 150000 改掉 👇
            if (latency >= (150000 * inst_iter)) begin
                $display("\033[1;31m[ERROR] Execution latency exceeded %0d cycles!\033[0m", 150000 * inst_iter);
                $finish;
            end
            
            if (o_data !== 8'd0) begin
                $display("\033[1;31m[ERROR] o_data must be 0 when o_valid is low!\033[0m");
                $finish;
            end
            latency = latency + 1; // 第一筆資料出來前，持續累積 latency
            @(negedge clk);
        end
    end
endtask

task check_task;
    integer r, c;
    begin
        r = 0;
        c = 0;

        while (r < 64) begin
            if ((^o_data === 1'bx) || (^o_valid === 1'bx)) begin
                $display("\033[1;31m[ERROR] Output contains Unknown (X) or High-Z (Z)!\033[0m");
                $finish;
            end

            if (o_valid === 1'b1) begin
                if (o_data !== img_curr[r][c]) begin
                    $display("\033[1;31m[ERROR] Mismatch at Output Row %0d, Col %0d!\033[0m", r, c);
                    $display("        Golden : %3d", img_curr[r][c]);
                    $display("        Yours  : %3d", o_data);
                    $finish;
                end

                c = c + 1;
                if (c == 64) begin
                    c = 0;
                    r = r + 1;
                end
            end
            else begin
                // 🛡️ 防禦 1: 確保 Bubble 期間 o_data 為 0
                if (o_data !== 8'd0) begin
                    $display("\033[1;31m[ERROR] o_data must be 0 when o_valid is low during output!\033[0m");
                    $finish;
                end

                // 🛡️ 防禦 2: 全局 Latency 累積與檢查 (完美符合 Spec)
                latency = latency + 1;

                                // 修正：總延遲上限應該是 150000 乘以目前的 iter 次數
                if (latency > (150000 * inst_iter)) begin
                    $display("\n\033[1;31m[ERROR] Execution latency exceeded %0d cycles!\033[0m", 150000 * inst_iter);
                    $finish;
                end
            end
            @(negedge clk);
        end

        // 檢查 4096 筆全部噴完後是否乖乖歸零
        if (o_valid !== 1'b0 || o_data !== 8'd0) begin
            $display("\033[1;31m[ERROR] o_valid should go low and o_data be 0 immediately after 4096 outputs!\033[0m");
            $finish;
        end

        total_latency = total_latency + latency;
    end
endtask

//======================================
//      CALCULATION GOLDEN MODEL
//======================================
task cal_task;
    integer it, r, c, ch, kr, kc, idx, jdx, kdx;
    integer sum, diff, scaled_diff, R_idx, C_idx, rem;
    integer in_r, in_c, pixel, fixp, val, denoise;
    integer sq, sk, sv;
    begin
        // Load initial image
        for (r = 0; r < 64; r = r + 1)
            for (c = 0; c < 64; c = c + 1)
                img_curr[r][c] = image_data[r*64 + c];

        // Iterative Denoising Loop
        for (it = 0; it < inst_iter; it = it + 1) begin

            // 1. Down Sampling Convolution (Stride 4)
            for (ch = 0; ch < 16; ch = ch + 1) begin
                for (r = 0; r < 16; r = r + 1) begin
                    for (c = 0; c < 16; c = c + 1) begin
                        sum = 0;
                        for (kr = -1; kr <= 1; kr = kr + 1) begin
                            for (kc = -1; kc <= 1; kc = kc + 1) begin
                                in_r = r * 4 + kr;
                                in_c = c * 4 + kc;
                                pixel = (in_r >= 0 && in_r < 64 && in_c >= 0 && in_c < 64) ? img_curr[in_r][in_c] : 0;
                                sum = sum + pixel * w_conv1[ch][kr+1][kc+1];
                            end
                        end
                        sum = ($signed(sum) >>> 6) + 128;
                        feat_down[ch][r][c] = (sum < 0) ? 0 : ((sum > 255) ? 255 : sum);
                    end
                end
            end

            // 2. Transformer Block: Reorder & Subtract 128
            for (r = 0; r < 16; r = r + 1) begin
                for (c = 0; c < 16; c = c + 1) begin
                    for (ch = 0; ch < 16; ch = ch + 1) begin
                        feat_vec[r*16+c][ch] = $signed(feat_down[ch][r][c]) - 128;
                    end
                end
            end

            // Q, K, V Linear Transformation
            for (idx = 0; idx < 256; idx = idx + 1) begin
                for (kdx = 0; kdx < 16; kdx = kdx + 1) begin
                    sq = 0;
                    sk = 0;
                    sv = 0;
                    for (jdx = 0; jdx < 16; jdx = jdx + 1) begin
                        sq = sq + feat_vec[idx][jdx] * w_q[jdx][kdx];
                        sk = sk + feat_vec[idx][jdx] * w_k[jdx][kdx];
                        sv = sv + feat_vec[idx][jdx] * w_v[jdx][kdx];
                    end
                    q_mat[idx][kdx] = clip_signed_8bit($signed(sq) >>> 4);
                    k_mat[idx][kdx] = clip_signed_8bit($signed(sk) >>> 4);
                    v_mat[idx][kdx] = clip_signed_8bit($signed(sv) >>> 4);
                end
            end

            // Attention Score (Q * K^T) and Softmax Approx
            for (idx = 0; idx < 256; idx = idx + 1) begin
                for (jdx = 0; jdx < 256; jdx = jdx + 1) begin
                    sum = 0;
                    for (kdx = 0; kdx < 16; kdx = kdx + 1) begin
                        sum = sum + q_mat[idx][kdx] * k_mat[jdx][kdx];
                    end
                    sum = $signed(sum) >>> 2;
                    sum = (sum < -2048) ? -2048 : ((sum > 2047) ? 2047 : sum);
                    fixp = ($signed(sum) >>> 4) + 128;
                    attn_score[idx][jdx] = (fixp < 0) ? 0 : ((fixp > 255) ? 255 : fixp);
                end
            end

            // Attention * V
            for (idx = 0; idx < 256; idx = idx + 1) begin
                for (kdx = 0; kdx < 16; kdx = kdx + 1) begin
                    sum = 0;
                    for (jdx = 0; jdx < 256; jdx = jdx + 1) begin
                        sum = sum + attn_score[idx][jdx] * v_mat[jdx][kdx];
                    end
                    attn_out[idx][kdx] = clip_signed_8bit($signed(sum) >>> 16);
                end
            end

            // FFN
            for (idx = 0; idx < 256; idx = idx + 1) begin
                for (kdx = 0; kdx < 16; kdx = kdx + 1) begin
                    sum = 0;
                    for (jdx = 0; jdx < 16; jdx = jdx + 1) begin
                        sum = sum + attn_out[idx][jdx] * w_ffn[jdx][kdx];
                    end
                    sum = ($signed(sum) >>> 4) + 128;
                    ffn_out[idx][kdx] = (sum < 0) ? 0 : ((sum > 255) ? 255 : sum);
                end
            end

            // Reorder Back
            for (r = 0; r < 16; r = r + 1) begin
                for (c = 0; c < 16; c = c + 1) begin
                    for (ch = 0; ch < 16; ch = ch + 1) begin
                        feat_up[ch][r][c] = ffn_out[r*16+c][ch];
                    end
                end
            end

            // 3. Up Sampling Convolution (Stride 1)
            for (r = 0; r < 16; r = r + 1) begin
                for (c = 0; c < 16; c = c + 1) begin
                    sum = 0;
                    for (ch = 0; ch < 16; ch = ch + 1) begin
                        for (kr = -1; kr <= 1; kr = kr + 1) begin
                            for (kc = -1; kc <= 1; kc = kc + 1) begin
                                in_r = r + kr;
                                in_c = c + kc;
                                pixel = (in_r >= 0 && in_r < 16 && in_c >= 0 && in_c < 16) ? feat_up[ch][in_r][in_c] : 0;
                                sum = sum + pixel * w_conv2[ch][kr+1][kc+1];
                            end
                        end
                    end
                    sum = ($signed(sum) >>> 6) + 128;
                    noise_pred[r][c] = (sum < 0) ? 0 : ((sum > 255) ? 255 : sum);
                end
            end

            // 4. Interpolation
            for (r = 0; r < 64; r = r + 1) begin
                for (c = 0; c < 64; c = c + 1) begin
                    if (inst_mode == 0) begin
                        noise_interp[r][c] = noise_pred[r/4][c/4];
                    end
                    else if (inst_mode == 1) begin
                        C_idx = c / 4;
                        rem = c % 4;
                        if (C_idx < 15)
                            diff = noise_pred[r/4][C_idx+1] - noise_pred[r/4][C_idx];
                        else
                            diff = noise_pred[r/4][15]      - noise_pred[r/4][14];
                        scaled_diff = $signed(diff) >>> 2;
                        val = noise_pred[r/4][C_idx] + rem * scaled_diff;
                        noise_interp[r][c] = (val < 0) ? 0 : ((val > 255) ? 255 : val);
                    end
                    else if (inst_mode == 2) begin
                        R_idx = r / 4;
                        rem = r % 4;
                        if (R_idx < 15)
                            diff = noise_pred[R_idx+1][c/4] - noise_pred[R_idx][c/4];
                        else
                            diff = noise_pred[15][c/4]      - noise_pred[14][c/4];
                        scaled_diff = $signed(diff) >>> 2;
                        val = noise_pred[R_idx][c/4] + rem * scaled_diff;
                        noise_interp[r][c] = (val < 0) ? 0 : ((val > 255) ? 255 : val);
                    end
                end
            end

            // 5. Denoise & Scale Down
            for (r = 0; r < 64; r = r + 1) begin
                for (c = 0; c < 64; c = c + 1) begin
                    denoise = img_curr[r][c] - (noise_interp[r][c] >> 3);
                    img_curr[r][c] = (denoise < 0) ? 0 : ((denoise > 255) ? 255 : denoise);
                end
            end

            // 呼叫 Debug Dump
            //dump_debug_task(pat, it);

        end // End iteration loop
    end
endtask
/*
//======================================
//      DEBUG DUMP TASK
//======================================
task dump_debug_task;
    input integer p_idx;
    input integer i_idx;
    integer fd, tr, tc, ch, k;
    reg [255:0] filename;
    begin
        $sformat(filename, "debug_pat%0d_iter%0d.txt", p_idx, i_idx);
        fd = $fopen(filename, "w");

        $fwrite(fd, "=================================================\n");
        $fwrite(fd, "  PATTERN NO. %0d, ITERATION %0d  Debug Golden\n", p_idx, i_idx);
        $fwrite(fd, "=================================================\n\n");

        $fwrite(fd, "--- 1. Down Conv (feat_down) [16x16x16] ---\n");
        for (ch = 0; ch < 16; ch = ch + 1) begin
            $fwrite(fd, "Channel %0d:\n", ch);
            for (tr = 0; tr < 16; tr = tr + 1) begin
                for (tc = 0; tc < 16; tc = tc + 1) begin
                    $fwrite(fd, "%4d ", feat_down[ch][tr][tc]);
                end
                $fwrite(fd, "\n");
            end
            $fwrite(fd, "\n");
        end

        $fwrite(fd, "--- 2. Q Matrix (q_mat) [256x16] (Token x Channel) ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Tok %3d: ", tr);
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", $signed(q_mat[tr][tc]));
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 3. K Matrix (k_mat) [256x16] ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Tok %3d: ", tr);
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", $signed(k_mat[tr][tc]));
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 4. V Matrix (v_mat) [256x16] ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Tok %3d: ", tr);
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", $signed(v_mat[tr][tc]));
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 5. Attention Score (attn_score) [256x256] ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Row %3d: ", tr);
            for (tc = 0; tc < 256; tc = tc + 1)
                $fwrite(fd, "%4d ", attn_score[tr][tc]);
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 6. Attention Out (attn_out) [256x16] ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Tok %3d: ", tr);
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", $signed(attn_out[tr][tc]));
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 7. FFN Out (ffn_out) [256x16] ---\n");
        for (tr = 0; tr < 256; tr = tr + 1) begin
            $fwrite(fd, "Tok %3d: ", tr);
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", ffn_out[tr][tc]);
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 8. Up Conv (noise_pred) [16x16] ---\n");
        for (tr = 0; tr < 16; tr = tr + 1) begin
            for (tc = 0; tc < 16; tc = tc + 1)
                $fwrite(fd, "%4d ", noise_pred[tr][tc]);
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 9. Interpolation (noise_interp) [64x64] ---\n");
        for (tr = 0; tr < 64; tr = tr + 1) begin
            for (tc = 0; tc < 64; tc = tc + 1)
                $fwrite(fd, "%4d ", noise_interp[tr][tc]);
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fwrite(fd, "--- 10. Denoised Image (img_curr) [64x64] ---\n");
        for (tr = 0; tr < 64; tr = tr + 1) begin
            for (tc = 0; tc < 64; tc = tc + 1)
                $fwrite(fd, "%4d ", img_curr[tr][tc]);
            $fwrite(fd, "\n");
        end
        $fwrite(fd, "\n");

        $fclose(fd);
        $display("\033[1;33m[INFO] Debug file 'debug_pat%0d_iter%0d.txt' has been generated!\033[0m", p_idx, i_idx);
    end
endtask
*/
//======================================
//      UTILITY FUNCTIONS
//======================================
function integer clip_signed_8bit;
    input integer val;
    begin
        if (val > 127)
            clip_signed_8bit = 127;
        else if (val < -128)
            clip_signed_8bit = -128;
        else
            clip_signed_8bit = val;
    end
endfunction

task pass_task;
    begin
        $display("\033[1;35m ============================================\033[1;0m");
        $display("\033[1;35m Congratulation!!!                           \033[1;0m");
        $display("\033[1;35m PASS This Lab (Diffusion Model C-Model)     \033[1;0m");
        $display("\033[1;35m Total Latency : %-10d cycles               \033[1;0m", total_latency);
        $display("\033[1;35m ============================================\033[1;0m");
    end
endtask

endmodule
