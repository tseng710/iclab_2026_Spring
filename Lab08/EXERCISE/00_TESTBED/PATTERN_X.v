//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring
//   lab08 Exercise - Coupling Network
//   Author     		: Cho-Hsun Lee
//
//   Fixes vs. original:
//   (1) $urandom(seed) re-seed bug fixed: seed once, then use $urandom()
//   (2) Add explicit "outputs zero after reset" check (SPEC 4)
//   (3) Latency limit tightened to strict < 200 cycles (SPEC 17)
//   (4) Randomize unused upper bits of in_data (test DUT bit-masking)
//   (5) Random idle data when in_valid=0 (avoid X-prop in gate sim)
//   (6) Display messages tagged with SPEC numbers for easier debug
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`define CYCLE_TIME      15.0
`define SEED_NUMBER     69
`define PATTERN_NUMBER  10000
`define LATENCY_LIMIT   200

module PATTERN(
           // Output Port
           clk,
           rst_n,
           in_valid,
           in_data,

           // Input Port
           out_valid,
           out_data
       );

//---------------------------------------------------------------------
//   PORT DECLARATION
//---------------------------------------------------------------------
output  logic        clk, rst_n, in_valid;
output  logic [7:0]  in_data;

input                out_valid;
input         [11:0] out_data;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real    CYCLE = `CYCLE_TIME;
integer seed  = `SEED_NUMBER;
integer pat_num;
integer gap;
integer lat;
integer r, c, k;

//---------------------------------------------------------------------
//   DATA STORAGE
//---------------------------------------------------------------------
logic        task_num;
logic [7:0]  A_mat  [0:3][0:3];
logic [7:0]  B_mat  [0:3][0:3];
logic [3:0]  F1_mat [0:3][0:3];
logic [3:0]  H1_mat [0:3][0:3];
logic [3:0]  F2_mat [0:3][0:3];
logic [3:0]  H2_mat [0:3][0:3];

// Golden model intermediates
logic [3:0]  X1      [0:3][0:3];
logic [7:0]  Y1      [0:3][0:3];
logic [11:0] BX1     [0:3][0:3];
logic [7:0]  Mid_A   [0:3][0:3];
logic [11:0] Mid_B   [0:3][0:3];
logic [3:0]  X2      [0:3][0:3];
logic [7:0]  Y2      [0:3][0:3];
logic [11:0] Mid_AX2 [0:3][0:3];

logic [11:0] OUT_A_mat [0:3][0:3];
logic [11:0] OUT_B_mat [0:3][0:3];
logic [19:0] sum;

//---------------------------------------------------------------------
//   CLOCK & RESET CONTROL
//---------------------------------------------------------------------
logic clk_en;

initial begin
    clk    = 1'b0;
    clk_en = 1'b0;
    forever
        #(CYCLE/2.0) if (clk_en)
             clk = ~clk;
end

initial begin
    // -----------------------------------------------------------------
    // Seed RNG ONCE. Subsequent $urandom() / $urandom_range() calls
    // continue the same deterministic sequence across all patterns.
    // (Calling $urandom(seed) repeatedly with the same constant seed
    //  re-seeds the RNG every time per IEEE 1800 LRM, producing
    //  identical "random" values - that is the bug fixed here.)
    // -----------------------------------------------------------------
    void'($urandom(seed));

    rst_n    = 1'b1;
    in_valid = 1'b0;
    in_data  = 8'h00;

    // Asynchronous active-low reset pulse (SPEC 3)
    #(CYCLE);
    rst_n = 1'b0;
    #(CYCLE * 3);
    rst_n = 1'b1;

    // Start clock after reset is deasserted
    #(CYCLE * 2);
    clk_en = 1'b1;
    @(negedge clk);
    @(negedge clk);

    // SPEC 4: all output registers must be 0 after reset
    if (out_valid !== 1'b0 || out_data !== 12'h000) begin
        $display("\033[1;31m[SPEC 4] outputs not zero after reset: out_valid=%b out_data=%h @%0t\033[0m",
                 out_valid, out_data, $time);
        $finish;
    end

    // Run patterns
    for (pat_num = 0; pat_num < `PATTERN_NUMBER; pat_num = pat_num + 1) begin
        randomize_inputs();
        calculate_golden();
        drive_input();
        wait_and_check_output();
        $display("\033[0;32m[PAT %3d] OK  (task=%0d  latency=%0d)\033[0m",
                 pat_num, task_num, lat);
    end

    $display("\033[1;32m========================================\033[0m");
    $display("\033[1;32m   All %0d patterns matched golden.\033[0m", `PATTERN_NUMBER);
    $display("\033[1;32m========================================\033[0m");
    $finish;
end

//---------------------------------------------------------------------
//   GLOBAL SPEC CHECKERS (active during normal operation)
//---------------------------------------------------------------------
always @(negedge clk) begin
    if (rst_n === 1'b1) begin
        // SPEC 4 / SPEC 22: when out_valid is low, out_data must be 0
        if (out_valid === 1'b0 && out_data !== 12'h000) begin
            $display("\033[1;31m[SPEC 22] out_data must be 0 when out_valid is low: out_data=%h @%0t\033[0m",
                     out_data, $time);
            $finish;
        end
        // SPEC 20: out_valid cannot overlap with in_valid
        if (in_valid === 1'b1 && out_valid === 1'b1) begin
            $display("\033[1;31m[SPEC 20] out_valid overlapped with in_valid @%0t\033[0m", $time);
            $finish;
        end
    end
end

//---------------------------------------------------------------------
//   TASK : RANDOMIZE INPUTS (uses seedless $urandom for portability)
//---------------------------------------------------------------------
task randomize_inputs;
    begin
        task_num = $urandom() & 1'b1;
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                A_mat[r][c]  = $urandom();
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                B_mat[r][c]  = $urandom();
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                F1_mat[r][c] = $urandom();
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                H1_mat[r][c] = $urandom();
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                F2_mat[r][c] = $urandom();
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1)
                H2_mat[r][c] = $urandom();
    end
endtask

//---------------------------------------------------------------------
//   TASK : COMPUTE GOLDEN OUTPUT
//---------------------------------------------------------------------
task calculate_golden;
    begin
        if (task_num == 1'b0) begin
            //==================== Forward (Task 0) ====================
            // X1 = (F1 * A) % 15 + 1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + F1_mat[r][k] * A_mat[k][c];
                    X1[r][c] = (sum % 15) + 1;
                end
            // Y1 = (H1 * A) % 256
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + H1_mat[r][k] * A_mat[k][c];
                    Y1[r][c] = sum[7:0];
                end
            // BX1 = X1 (.) B ;  Mid_A = A ;  Mid_B = BX1 ^ Y1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    BX1[r][c]   = X1[r][c] * B_mat[r][c];
                    Mid_A[r][c] = A_mat[r][c];
                    Mid_B[r][c] = BX1[r][c] ^ {4'b0, Y1[r][c]};
                end
            // X2 = (F2 * Mid_B) % 15 + 1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + F2_mat[r][k] * Mid_B[k][c];
                    X2[r][c] = (sum % 15) + 1;
                end
            // Y2 = (H2 * Mid_B) % 256
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + H2_mat[r][k] * Mid_B[k][c];
                    Y2[r][c] = sum[7:0];
                end
            // Mid_AX2 = X2 (.) Mid_A ;  OUT_A = Mid_AX2 ^ Y2 ;  OUT_B = Mid_B
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    Mid_AX2[r][c]   = X2[r][c] * Mid_A[r][c];
                    OUT_A_mat[r][c] = Mid_AX2[r][c] ^ {4'b0, Y2[r][c]};
                    OUT_B_mat[r][c] = Mid_B[r][c];
                end
        end
        else begin
            //==================== Backward (Task 1) ====================
            // X2 = (F2 * B) % 15 + 1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + F2_mat[r][k] * B_mat[k][c];
                    X2[r][c] = (sum % 15) + 1;
                end
            // Y2 = (H2 * B) % 256
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + H2_mat[r][k] * B_mat[k][c];
                    Y2[r][c] = sum[7:0];
                end
            // Mid_AX2 = A ^ Y2 (8-bit) ;  Mid_A = Mid_AX2 / X2 ;  Mid_B = B
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    Mid_AX2[r][c] = {4'b0, A_mat[r][c]} ^ {4'b0, Y2[r][c]};
                    Mid_A[r][c]   = Mid_AX2[r][c] / X2[r][c];
                    Mid_B[r][c]   = {4'b0, B_mat[r][c]};
                end
            // X1 = (F1 * Mid_A) % 15 + 1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + F1_mat[r][k] * Mid_A[k][c];
                    X1[r][c] = (sum % 15) + 1;
                end
            // Y1 = (H1 * Mid_A) % 256
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    sum = 0;
                    for (k=0; k<4; k=k+1)
                        sum = sum + H1_mat[r][k] * Mid_A[k][c];
                    Y1[r][c] = sum[7:0];
                end
            // BX1 = Mid_B ^ Y1 ;  OUT_A = Mid_A ;  OUT_B = BX1 / X1
            for (r=0; r<4; r=r+1)
                for (c=0; c<4; c=c+1) begin
                    BX1[r][c]       = Mid_B[r][c] ^ {4'b0, Y1[r][c]};
                    OUT_A_mat[r][c] = {4'b0, Mid_A[r][c]};
                    OUT_B_mat[r][c] = BX1[r][c] / X1[r][c];
                end
        end
    end
endtask

//---------------------------------------------------------------------
//   TASK : DRIVE INPUT (97 cycles continuously)
//---------------------------------------------------------------------
task drive_input;
    begin
        // SPEC 9: 2~5 cycle gap before next transaction
        gap = $urandom_range(2, 5);
        repeat (gap) @(negedge clk);

        in_valid = 1'b1;

        // Cycle 1 : task_num. DUT only uses in_data[0]; randomize upper 7 bits
        in_data = ($urandom() & 8'hFE) | task_num;
        @(negedge clk);

        // Cycle 2~17 : matrix A (8-bit, full in_data)
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = A_mat[r][c];
                @(negedge clk);
            end
        // Cycle 18~33 : matrix B (8-bit)
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = B_mat[r][c];
                @(negedge clk);
            end
        // Cycle 34~49 : matrix F1 (4-bit; randomize upper 4 bits)
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = ($urandom() & 8'hF0) | F1_mat[r][c];
                @(negedge clk);
            end
        // Cycle 50~65 : matrix H1
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = ($urandom() & 8'hF0) | H1_mat[r][c];
                @(negedge clk);
            end
        // Cycle 66~81 : matrix F2
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = ($urandom() & 8'hF0) | F2_mat[r][c];
                @(negedge clk);
            end
        // Cycle 82~97 : matrix H2
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                in_data = ($urandom() & 8'hF0) | H2_mat[r][c];
                @(negedge clk);
            end

        in_valid = 1'b0;
        in_data  = $urandom();   // random idle data (avoid X-prop in gate sim)
    end
endtask

//---------------------------------------------------------------------
//   TASK : WAIT & CHECK 32-CYCLE OUTPUT
//---------------------------------------------------------------------
task wait_and_check_output;
    begin
        // SPEC 17 / SPEC 18: latency must be < LATENCY_LIMIT cycles
        lat = 0;
        while (out_valid === 1'b0) begin
            if (lat >= `LATENCY_LIMIT) begin
                $display("\033[1;31m[SPEC 17] latency >= %0d cycles (pat=%0d)\033[0m",
                         `LATENCY_LIMIT, pat_num);
                $finish;
            end
            lat = lat + 1;
            @(negedge clk);
        end

        // OUT_A : first 16 cycles, raster scan
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                if (out_valid !== 1'b1) begin
                    $display("\033[1;31m[SPEC 21] out_valid dropped during OUT_A (pat=%0d r=%0d c=%0d)\033[0m",
                             pat_num, r, c);
                    $finish;
                end
                if (out_data !== OUT_A_mat[r][c]) begin
                    $display("\033[1;31m[DATA] OUT_A mismatch pat=%0d r=%0d c=%0d  golden=%h  dut=%h\033[0m",
                             pat_num, r, c, OUT_A_mat[r][c], out_data);
                    $finish;
                end
                @(negedge clk);
            end

        // OUT_B : next 16 cycles, raster scan
        for (r=0; r<4; r=r+1)
            for (c=0; c<4; c=c+1) begin
                if (out_valid !== 1'b1) begin
                    $display("\033[1;31m[SPEC 21] out_valid dropped during OUT_B (pat=%0d r=%0d c=%0d)\033[0m",
                             pat_num, r, c);
                    $finish;
                end
                if (out_data !== OUT_B_mat[r][c]) begin
                    $display("\033[1;31m[DATA] OUT_B mismatch pat=%0d r=%0d c=%0d  golden=%h  dut=%h\033[0m",
                             pat_num, r, c, OUT_B_mat[r][c], out_data);
                    $finish;
                end
                @(negedge clk);
            end

        // SPEC 21 / SPEC 24: out_valid must drop right after the 32nd cycle
        if (out_valid !== 1'b0) begin
            $display("\033[1;31m[SPEC 21/24] out_valid stayed high beyond 32 cycles (pat=%0d)\033[0m",
                     pat_num);
            $finish;
        end
    end
endtask

endmodule
