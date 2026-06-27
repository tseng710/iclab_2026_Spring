`ifdef RTL
    `define CYCLE_TIME 9.5
`elsif GATE
    `define CYCLE_TIME 9.5
`endif

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
always  #(CYCLE/2.0) clk = ~clk; //clock

// ========================================
// integer & parameter
// ========================================

// 填入你 Synthesis Report 中的面積，讓 PATTERN 自動結算 Performance！
parameter real TOTAL_AREA     = 3546295; // 請替換成你最新的 Total cell area
parameter real NON_COMB_AREA  = 459120;  // 請替換成你最新的 Noncombinational area
parameter PAT_NUM = 15; 

int patcount;
int current_iter;
int current_mode;
int out_cnt;
int lat_cnt;
int max_latency;
bit debug_flag = 0;
int seed;

real total_cycles_all_patterns = 0;
real total_iters_all_patterns = 0;
real avg_latency_ns;real avg_latency;
real performance_score;
// ========================================
// Golden Model Storage
// ========================================
logic [7:0] current_image [0:63][0:63];
logic [7:0] golden_output [0:63][0:63];

logic signed [3:0] w_conv_down [0:15][0:2][0:2]; // [out_c][ky][kx]
logic signed [3:0] w_q         [0:15][0:15];     // [i][j]
logic signed [3:0] w_k         [0:15][0:15];
logic signed [3:0] w_v         [0:15][0:15];
logic signed [3:0] w_f         [0:15][0:15];
logic signed [3:0] w_conv_up   [0:15][0:2][0:2]; // [in_c][ky][kx]

//================================================================
// design
//================================================================

initial begin
    // 💡 優化：印出 Random Seed，讓同學踩到 Bug 時能輕易復現
    // 將原本的寫法改成這樣，隨便給個固定種子即可：
    seed = 2335252; // $get_initial_random_seed();
    $display("\033[0;34m[INFO] Simulation starts with Random Seed: %0d\033[0m", seed);

    reset_task();
    generate_weights();
    send_weights();
    
    for (patcount = 0; patcount < PAT_NUM; patcount++) begin
        generate_image_and_config();
        compute_golden();
        
        // Timing Alignment: 完美的 Pattern 切換邊界處理
        if (patcount > 0) begin
            if (o_valid === 1'b1) begin
                $display("\033[1;31mERROR: Design outputs MORE than 4096 valid data!\033[0m");
                $finish;
            end
            // 隨機等待 0~2 個 negedge，補足 1~3 個 negedge 的 Spec 要求
            repeat($urandom_range(0, 2)) @(negedge clk);
        end 
        else begin
            // 傳完 weight 後，等待 1~3 個 negedge 再開始
            repeat($urandom_range(1, 3)) @(negedge clk);
        end
        
        send_image();
        check_output();
        
        // 💡 新增：收集每次測資的 cycles 數與 iteration 數
        total_cycles_all_patterns += lat_cnt;
        total_iters_all_patterns += current_iter;
        
        $display("\033[0;32mPattern %3d passed! (Iter: %0d, Mode: %0d, Latency: %6d)\033[0m", patcount, current_iter, current_mode, lat_cnt);
    end

    // 💡 新增：結算 Performance 總成績與各項指標檢查
    avg_latency_ns = (total_cycles_all_patterns / total_iters_all_patterns) * `CYCLE_TIME;
    avg_latency = (total_cycles_all_patterns / total_iters_all_patterns);
    performance_score = TOTAL_AREA * NON_COMB_AREA * avg_latency_ns;

    $display("\n\033[1;32m============================================================\033[0m");
    $display("\033[1;32m                 Congratulations! All Pass!                 \033[0m");
    $display("\033[1;32m============================================================\033[0m");
    $display("\033[1;36m  [Area Requirements]\033[0m");
    $display("  Total Area       : %10.1f um^2 (Limit: < 9,000,000) %s", TOTAL_AREA, (TOTAL_AREA < 9000000.0) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("  Register Area    : %10.1f um^2 (Limit: < 1,000,000) %s", NON_COMB_AREA, (NON_COMB_AREA < 1000000.0) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("");
    $display("\033[1;36m  [Latency & Timing Requirements]\033[0m");
    $display("  Clock Period     : %6.1f ns (Limit: <= 20.0 ns) %s", `CYCLE_TIME, (`CYCLE_TIME <= 20.0) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("  Average Latency(Number)  : %10.1f (per iteration)", avg_latency);
    $display("  Average Latency(T)  : %10.1f ns", avg_latency_ns);
    $display("                     -> Baseline Limit: < 3,000,000 ns %s", (avg_latency_ns < 3000000.0) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("                     -> Goal Limit    : <   800,000 ns %s", (avg_latency_ns < 800000.0) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("");
    $display("\033[1;36m  [Performance Requirement]\033[0m");
    $display("  Performance Score: %e", performance_score);
    $display("                     -> Goal Limit    : < 8.00e+18     %s", (performance_score < 8.0e18) ? "\033[1;32m[PASS]\033[0m" : "\033[1;31m[FAIL]\033[0m");
    $display("\033[1;32m------------------------------------------------------------\033[0m");
    
    // 💡 綜合評估
    if (TOTAL_AREA < 9000000.0 && NON_COMB_AREA < 1000000.0 && `CYCLE_TIME <= 20.0 && avg_latency_ns < 3000000.0) begin
        if (avg_latency_ns < 800000.0 && performance_score < 8.0e18) begin
            $display("\033[5;1;33m  🌟 STATUS: PERFECT! YOU PASSED BOTH BASELINE AND GOAL! 🌟 \033[0m");
        end else begin
            $display("\033[1;34m  🟢 STATUS: YOU PASSED BASELINE! (But missed the Goal) \033[0m");
            $display("\033[1;33m  -> Hint: Try to reduce your `CYCLE_TIME to reach the Goal.\033[0m");
        end
    end else begin
        $display("\033[1;31m  ❌ STATUS: FAILED BASELINE REQUIREMENTS! \033[0m");
    end
        
    $display("\033[1;32m============================================================\n\033[0m");
    $finish;
end

//================================================================
// Watchdog & Rule Checkers
//================================================================
always @(negedge clk) begin
    // 💡 優化：加入對 unknown 狀態 (x) 的攔截防護
    if (rst_n) begin
        
        if (!o_valid && o_data !== 8'd0) begin
            $display("\033[1;31mERROR: o_data must be 0 when o_valid is low!\033[0m");
            $finish;
        end
        if (i_valid && o_valid) begin
            $display("\033[1;31mERROR: i_valid and o_valid cannot overlap!\033[0m");
            $finish;
        end
    end
end

//================================================================
// Tasks
//================================================================
task reset_task; 
begin
    force clk = 1'b0; 
    rst_n = 1'b1;
    i_valid = 1'b0;
    i_iter = 3'bx;
    i_mode = 2'bx;
    i_data = 8'bx;
    i_weight = 4'bx;

    #(CYCLE);
    rst_n = 1'b0; 

    #(CYCLE * 2.0);
    if (o_valid !== 1'b0 || o_data !== 8'd0) begin
        $display("\033[1;31mERROR: Output signals should be 0 after asynchronous reset!\033[0m");
        $finish;
    end

    rst_n = 1'b1; 

    #(CYCLE);
    release clk;
    
    @(negedge clk);
end 
endtask

task generate_weights;
    int c, y, x, i, j;
begin
    // 使用 0~15 賦值給 4-bit signed，完美對應 -8~7，避開 SystemVerilog 無號數陷阱
    for(c=0; c<16; c++) for(y=0; y<3; y++) for(x=0; x<3; x++) w_conv_down[c][y][x] = $urandom_range(0, 15);
    for(i=0; i<16; i++) for(j=0; j<16; j++) w_q[i][j] = $urandom_range(0, 15);
    for(i=0; i<16; i++) for(j=0; j<16; j++) w_k[i][j] = $urandom_range(0, 15);
    for(i=0; i<16; i++) for(j=0; j<16; j++) w_v[i][j] = $urandom_range(0, 15);
    for(i=0; i<16; i++) for(j=0; j<16; j++) w_f[i][j] = $urandom_range(0, 15);
    for(c=0; c<16; c++) for(y=0; y<3; y++) for(x=0; x<3; x++) w_conv_up[c][y][x] = $urandom_range(0, 15);
end 
endtask

task send_weights; 
    int c, ky, kx, i, j;
begin
    @(negedge clk);
    i_valid = 1;
    
    for(c=0; c<16; c++) for(ky=0; ky<3; ky++) for(kx=0; kx<3; kx++) begin i_weight = w_conv_down[c][ky][kx]; @(negedge clk); end
    for(i=0; i<16; i++) for(j=0; j<16; j++) begin i_weight = w_q[i][j]; @(negedge clk); end
    for(i=0; i<16; i++) for(j=0; j<16; j++) begin i_weight = w_k[i][j]; @(negedge clk); end
    for(i=0; i<16; i++) for(j=0; j<16; j++) begin i_weight = w_v[i][j]; @(negedge clk); end
    for(i=0; i<16; i++) for(j=0; j<16; j++) begin i_weight = w_f[i][j]; @(negedge clk); end
    for(c=0; c<16; c++) for(ky=0; ky<3; ky++) for(kx=0; kx<3; kx++) begin i_weight = w_conv_up[c][ky][kx]; @(negedge clk); end

    i_valid = 0;
    i_weight = 4'dx;
end 
endtask

task generate_image_and_config; 
    int i, j;
    int mode_prob;
begin
    current_iter = $urandom_range(1, 7);
    current_mode = $urandom_range(0, 2);
    
    mode_prob = $urandom_range(0, 9); // 生成極端測資的機率
    
    for(i=0; i<64; i++) begin
        for(j=0; j<64; j++) begin
            if (mode_prob == 0)      // 10% 機率：全黑 (Underflow test)
                current_image[i][j] = 8'd0;
            else if (mode_prob == 1) // 10% 機率：全白 (Overflow test)
                current_image[i][j] = 8'd255;
            else if (mode_prob == 2) // 10% 機率：極端棋盤格 (Max noise test)
                current_image[i][j] = ((i+j)%2 == 0) ? 8'd255 : 8'd0;
            else                     // 70% 機率：一般隨機值
                current_image[i][j] = $urandom_range(0, 255);
        end
    end
end 
endtask

task send_image; 
    int i;
begin
    for (i=0; i<4096; i++) begin
        i_valid = 1;
        
        // 嚴格遵守 i_iter 與 i_mode 只有第一個 cycle 有效
        if (i == 0) begin
            i_iter = current_iter;
            i_mode = current_mode;
        end else begin
            i_iter = 3'dx;
            i_mode = 2'dx;
        end
        
        i_data = current_image[i/64][i%64];
        @(negedge clk);
    end
    
    // 傳輸結束立刻將輸入拉回未知狀態
    i_valid = 0;
    i_iter = 3'dx;
    i_mode = 2'dx;
    i_data = 8'dx;
end 
endtask

task compute_golden;
    logic [7:0] temp_img [0:63][0:63];
    logic [7:0] conv_down [0:15][0:15][0:15];
    logic signed [8:0] trans_mid [0:255][0:15];
    logic signed [7:0] Q[0:255][0:15], K[0:255][0:15], V[0:255][0:15];
    logic [7:0] P[0:255][0:255];
    logic signed [7:0] Z[0:255][0:15];
    logic [7:0] trans_out[0:255][0:15];
    logic [7:0] conv_up [0:15][0:15];
    
    int step, c, y, x, ky, kx, py, px, i, j, d;
    int sum, bn, sq, sk, sv, s, p, interp, y_in, x_in, s_orig; 
    int p0, p1, diff, scaled_diff, noise, denoised;
    int img_val, w_val;
begin
    for(i=0; i<64; i++) for(j=0; j<64; j++) temp_img[i][j] = current_image[i][j];
    
    for(step=0; step<current_iter; step++) begin
        // 1. Down Sampling Conv (Stride 4)
        for(c=0; c<16; c++) begin
            for(y=0; y<16; y++) begin
                for(x=0; x<16; x++) begin
                    sum = 0;
                    for(ky=-1; ky<=1; ky++) begin
                        for(kx=-1; kx<=1; kx++) begin
                            py = y*4 + ky;
                            px = x*4 + kx;
                            if(py>=0 && py<64 && px>=0 && px<64) begin
                                // 確保計算前全部視為嚴謹的有號 int 擴充
                                img_val = temp_img[py][px];
                                w_val = w_conv_down[c][ky+1][kx+1];
                                sum += img_val * w_val;
                            end
                        end
                    end
                    
                    bn = (sum >>> 6) + 128; // Arithmetic shift guaranteed by int
                    conv_down[c][y][x] = (bn < 0) ? 0 : (bn > 255 ? 255 : bn);
                    
                    if (debug_flag && y==0 && x==0) begin
                        $display("  [Step %0d] DownConv(0,0, Ch%2d): Sum = %6d | BN_Out = %3d", 
                                step, c, sum, conv_down[c][y][x]);
                    end
                end
            end
        end

        // 2. Transformer
        // 2a. Reorder & Subtract midpoint
        for(y=0; y<16; y++) begin
            for(x=0; x<16; x++) begin
                for(c=0; c<16; c++) begin
                    trans_mid[y*16+x][c] = int'(conv_down[c][y][x]) - 128;
                end
            end
        end

        // 2b. Q, K, V Projections
        for(i=0; i<256; i++) begin
            for(d=0; d<16; d++) begin
                sq=0; sk=0; sv=0;
                for(j=0; j<16; j++) begin
                    sq += int'(trans_mid[i][j]) * int'(w_q[j][d]);
                    sk += int'(trans_mid[i][j]) * int'(w_k[j][d]);
                    sv += int'(trans_mid[i][j]) * int'(w_v[j][d]);
                end
                sq = sq >>> 4; sk = sk >>> 4; sv = sv >>> 4;
                Q[i][d] = (sq < -128) ? -128 : (sq > 127 ? 127 : sq);
                K[i][d] = (sk < -128) ? -128 : (sk > 127 ? 127 : sk);
                V[i][d] = (sv < -128) ? -128 : (sv > 127 ? 127 : sv);
            end
        end

        // 2c. Attention Score & SoftMax Approx
        for(i=0; i<256; i++) begin
            for(j=0; j<256; j++) begin
                s = 0;
                for(d=0; d<16; d++) s += int'(Q[i][d]) * int'(K[j][d]);
                s = s >>> 2;
                
                s_orig = s; // 暫存 clip 前的數值
                s = (s < -2048) ? -2048 : (s > 2047 ? 2047 : s);
                p = (s >>> 4) + 128;
                
                if (debug_flag && i==0 && j==0) begin
                    $display("  [Step %0d] Attn(0,0): S_orig=%6d, S_clipped=%6d, P_fixed=%3d", step, s_orig, s, p);
                end
                
                P[i][j] = (p < 0) ? 0 : (p > 255 ? 255 : p);
            end
        end

        // 2d. Attention Output
        for(i=0; i<256; i++) begin
            for(d=0; d<16; d++) begin
                s = 0;
                for(j=0; j<256; j++) s += int'(P[i][j]) * int'(V[j][d]);
                s = s >>> 16;
                Z[i][d] = (s < -128) ? -128 : (s > 127 ? 127 : s);
            end
        end

        // 2e. Feed-Forward Network
        for(i=0; i<256; i++) begin
            for(d=0; d<16; d++) begin
                s = 0;
                for(j=0; j<16; j++) s += int'(Z[i][j]) * int'(w_f[j][d]);
                s = s >>> 4;
                s = s + 128;
                trans_out[i][d] = (s < 0) ? 0 : (s > 255 ? 255 : s);
            end
        end

        // 3. Up Sampling Conv (Stride 1)
        for(y=0; y<16; y++) begin
            for(x=0; x<16; x++) begin
                sum = 0;
                for(c=0; c<16; c++) begin
                    for(ky=-1; ky<=1; ky++) begin
                        for(kx=-1; kx<=1; kx++) begin
                            py = y + ky; px = x + kx;
                            if(py>=0 && py<16 && px>=0 && px<16) begin
                                img_val = trans_out[py*16+px][c];
                                w_val = w_conv_up[c][ky+1][kx+1];
                                sum += img_val * w_val;
                            end
                        end
                    end
                end
                bn = (sum >>> 6) + 128;
                conv_up[y][x] = (bn < 0) ? 0 : (bn > 255 ? 255 : bn);
            end
        end

        // 4. Interpolation & Denoise
        for(i=0; i<64; i++) begin
            for(j=0; j<64; j++) begin
                interp = 0;
                y_in = i / 4; x_in = j / 4;
                
                if(current_mode == 0) begin
                    interp = conv_up[y_in][x_in];
                end else if(current_mode == 1) begin
                    p0 = conv_up[y_in][x_in];
                    p1 = (x_in == 15) ? conv_up[y_in][14] : conv_up[y_in][x_in+1];
                    // 在相減之前強制擴展為 32-bit int 阻斷無號數的 Underflow！
                    diff = (x_in == 15) ? (int'(p0) - int'(p1)) : (int'(p1) - int'(p0)); 
                    
                    if (debug_flag && i==0 && j<4) begin
                        $display("[Step %0d] Mode %0d Interp(0,%0d): p0=%4d, p1=%4d, diff=%4d, scaled_diff=%4d, noise=%4d", 
                                step, current_mode, j, p0, p1, diff, diff>>>2, (p0 + (j % 4) * (diff>>>2))>>>3);
                    end
                    
                    scaled_diff = diff >>> 2;
                    interp = p0 + (j % 4) * scaled_diff;
                end else if(current_mode == 2) begin
                    p0 = conv_up[y_in][x_in];
                    p1 = (y_in == 15) ? conv_up[14][x_in] : conv_up[y_in+1][x_in];
                    // 在相減之前強制擴展為 32-bit int 阻斷無號數的 Underflow！
                    diff = (y_in == 15) ? (int'(p0) - int'(p1)) : (int'(p1) - int'(p0)); 
                    scaled_diff = diff >>> 2;
                    interp = p0 + (i % 4) * scaled_diff;
                end
                
                interp = (interp < 0) ? 0 : (interp > 255 ? 255 : interp);
                noise = interp >>> 3;
                denoised = int'(temp_img[i][j]) - noise;
                temp_img[i][j] = (denoised < 0) ? 0 : (denoised > 255 ? 255 : denoised);
            end
        end
    end

    for(i=0; i<64; i++) for(j=0; j<64; j++) golden_output[i][j] = temp_img[i][j];
end 
endtask

task check_output; 
    int r, c;
    int exp_val, got_val; // 暫存變數
begin
    out_cnt = 0;
    lat_cnt = 0;
    max_latency = 150000 * current_iter;

    while (out_cnt < 4096) begin
        @(negedge clk);
        if (o_valid) begin
            r = out_cnt / 64;
            c = out_cnt % 64;
            if (o_data !== golden_output[r][c]) begin
                // A. 暫存資訊
                exp_val = golden_output[r][c];
                got_val = o_data;

                $display("\n\033[1;33m[DEBUG] >>> Mismatch detected! Starting backtrace computation... <<<\033[0m");
                
                // B. 先執行詳細過程列印
                debug_flag = 1;
                compute_golden(); 
                debug_flag = 0;

                // C. 最後才顯示 Golden Answer (大紅框總結)
                $display("\033[1;31m\n============================================================\033[0m");
                $display("\033[1;31m  Simulation Error!                                         \033[0m");
                $display("\033[1;31m  Location: (%3d, %3d)                                      \033[0m", r, c);
                $display("\033[1;31m  Expected (Golden): %3d                                     \033[0m", exp_val);
                $display("\033[1;31m  Received (Design): %3d                                     \033[0m", got_val);
                $display("\033[1;31m============================================================\n\033[0m");
                
                $finish;
            end
            out_cnt++;
        end
        else begin
            // Spec 規定 o_valid 為 low 時才計算 Latency
            lat_cnt++;
            if (lat_cnt > max_latency) begin
                $display("\033[1;31mERROR: Execution Latency exceeded the limit of %0d cycles!\033[0m", max_latency);
                $finish;
            end
        end
    end
    
    // 確保收完 4096 筆後，o_valid 有乖乖降下來
    @(negedge clk);
    if (o_valid === 1'b1) begin
        $display("\033[1;31mERROR: Design outputs MORE than 4096 valid data!\033[0m");
        $finish;
    end
end 
endtask

endmodule