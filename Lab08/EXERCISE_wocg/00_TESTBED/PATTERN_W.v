//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring
//   lab08 Exercise        
//   Author             : Cho-Hsun Lee 
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`define CYCLE_TIME      15.0
`define SEED_NUMBER     69
`define PATTERN_NUMBER  100

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
real CYCLE = `CYCLE_TIME;
integer seed = `SEED_NUMBER;
integer patnum = `PATTERN_NUMBER;

integer i, j, k;
integer pat_count;
integer total_latency;
integer latency;

logic task_num;
logic [7:0] A [0:3][0:3];
logic [7:0] B [0:3][0:3];
logic [3:0] F1[0:3][0:3];
logic [3:0] H1[0:3][0:3];
logic [3:0] F2[0:3][0:3];
logic [3:0] H2[0:3][0:3];

logic [11:0] golden_out_A [0:3][0:3];
logic [11:0] golden_out_B [0:3][0:3];

//---------------------------------------------------------------------
//   CLOCK GENERATION
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//   INITIAL BLOCK
//---------------------------------------------------------------------
initial begin
    reset_task;
    for (pat_count = 0; pat_count < patnum; pat_count = pat_count + 1) begin
        input_task;
        calculate_golden_task;
        wait_out_valid_task;
        check_ans_task;
        $display("SUCCESS PATTERN NO.%4d, execution cycle : ", pat_count, latency);
    end
    YOU_SUCCESS_task;
end

//---------------------------------------------------------------------
//   TASKS
//---------------------------------------------------------------------
task reset_task; begin
    rst_n = 1'b1;
    in_valid = 1'b0;
    in_data = 'b0;
    #(CYCLE/2.0) rst_n = 1'b0;
    #(CYCLE*2) rst_n = 1'b1;
end endtask

task input_task; 
    integer wait_cycles;
begin
    // wait 2~5 cycles
    wait_cycles = $urandom_range(2, 5);
    #(CYCLE * wait_cycles);

    task_num = $urandom_range(0, 1);
    
    // Cycle 1: task_num
    @(negedge clk);
    in_valid = 1'b1;
    in_data = {7'b0, task_num};
    
    // Cycle 2-17: Matrix A
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            A[i][j] = $urandom_range(0, 255);
            @(negedge clk);
            in_data = A[i][j];
        end
    end
    
    // Cycle 18-33: Matrix B
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            B[i][j] = $urandom_range(0, 255);
            @(negedge clk);
            in_data = B[i][j];
        end
    end
    
    // Cycle 34-49: Matrix F1
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            F1[i][j] = $urandom_range(0, 15);
            @(negedge clk);
            in_data = {4'b0, F1[i][j]};
        end
    end

    // Cycle 50-65: Matrix H1
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            H1[i][j] = $urandom_range(0, 15);
            @(negedge clk);
            in_data = {4'b0, H1[i][j]};
        end
    end

    // Cycle 66-81: Matrix F2
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            F2[i][j] = $urandom_range(0, 15);
            @(negedge clk);
            in_data = {4'b0, F2[i][j]};
        end
    end

    // Cycle 82-97: Matrix H2
    for (i = 0; i < 4; i = i + 1) begin
        for (j = 0; j < 4; j = j + 1) begin
            H2[i][j] = $urandom_range(0, 15);
            @(negedge clk);
            in_data = {4'b0, H2[i][j]};
        end
    end

    @(negedge clk);
    in_valid = 1'b0;
    in_data = 'b0;
end endtask

task calculate_golden_task;
    integer r, c, k_idx;
    integer temp_sum;
    
    integer X1[0:3][0:3];
    integer Y1[0:3][0:3];
    integer BX1[0:3][0:3];
    integer Mid_A[0:3][0:3];
    integer Mid_B[0:3][0:3];
    integer X2[0:3][0:3];
    integer Y2[0:3][0:3];
    integer Mid_AX2[0:3][0:3];
    
begin
    if (task_num == 0) begin
        // Task 0: Forward
        // X1 = (F1 * A) % 15 + 1
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + F1[r][k_idx] * A[k_idx][c];
                X1[r][c] = (temp_sum % 15) + 1;
            end
        end
        // Y1 = (H1 * A) % 256
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + H1[r][k_idx] * A[k_idx][c];
                Y1[r][c] = temp_sum % 256;
            end
        end
        
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                BX1[r][c] = X1[r][c] * B[r][c];
                Mid_A[r][c] = A[r][c];
                Mid_B[r][c] = BX1[r][c] ^ Y1[r][c];
            end
        end

        // X2 = (F2 * Mid_B) % 15 + 1
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + F2[r][k_idx] * Mid_B[k_idx][c];
                X2[r][c] = (temp_sum % 15) + 1;
            end
        end
        // Y2 = (H2 * Mid_B) % 256
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + H2[r][k_idx] * Mid_B[k_idx][c];
                Y2[r][c] = temp_sum % 256;
            end
        end

        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                Mid_AX2[r][c] = X2[r][c] * Mid_A[r][c];
                golden_out_A[r][c] = Mid_AX2[r][c] ^ Y2[r][c];
                golden_out_B[r][c] = Mid_B[r][c];
            end
        end

    end else begin
        // Task 1: Backward
        // X2 = (F2 * B) % 15 + 1
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + F2[r][k_idx] * B[k_idx][c];
                X2[r][c] = (temp_sum % 15) + 1;
            end
        end
        // Y2 = (H2 * B) % 256
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + H2[r][k_idx] * B[k_idx][c];
                Y2[r][c] = temp_sum % 256;
            end
        end

        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                Mid_AX2[r][c] = A[r][c] ^ Y2[r][c];
                Mid_A[r][c] = Mid_AX2[r][c] / X2[r][c];
                Mid_B[r][c] = B[r][c];
            end
        end

        // X1 = (F1 * Mid_A) % 15 + 1
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + F1[r][k_idx] * Mid_A[k_idx][c];
                X1[r][c] = (temp_sum % 15) + 1;
            end
        end
        // Y1 = (H1 * Mid_A) % 256
        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                temp_sum = 0;
                for (k_idx=0; k_idx<4; k_idx=k_idx+1) temp_sum = temp_sum + H1[r][k_idx] * Mid_A[k_idx][c];
                Y1[r][c] = temp_sum % 256;
            end
        end

        for (r=0; r<4; r=r+1) begin
            for (c=0; c<4; c=c+1) begin
                BX1[r][c] = Y1[r][c] ^ Mid_B[r][c];
                golden_out_A[r][c] = Mid_A[r][c];
                golden_out_B[r][c] = BX1[r][c] / X1[r][c];
            end
        end
    end
end endtask

task wait_out_valid_task; begin
    latency = 0;
    while (out_valid !== 1'b1) begin
        latency = latency + 1;
        if (latency > 200) begin
            $display("SPEC 4 IS VIOLATED! (latency > 200)");
            $finish;
        end
        @(negedge clk);
    end
end endtask

task check_ans_task; 
    integer r, c;
begin
    // Check OUT_A
    for (r=0; r<4; r=r+1) begin
        for (c=0; c<4; c=c+1) begin
            if (out_valid !== 1'b1) begin
                $display("SPEC is VIOLATED (out_valid should be high for 32 cycles)");
                $finish;
            end
            if (out_data !== golden_out_A[r][c]) begin
                $display("WRONG! OUT_A[%0d][%0d] is not correct. Golden: %0d, Yours: %0d", r, c, golden_out_A[r][c], out_data);
                $finish;
            end
            @(negedge clk);
        end
    end
    
    // Check OUT_B
    for (r=0; r<4; r=r+1) begin
        for (c=0; c<4; c=c+1) begin
            if (out_valid !== 1'b1) begin
                $display("SPEC is VIOLATED (out_valid should be high for 32 cycles)");
                $finish;
            end
            if (out_data !== golden_out_B[r][c]) begin
                $display("WRONG! OUT_B[%0d][%0d] is not correct. Golden: %0d, Yours: %0d", r, c, golden_out_B[r][c], out_data);
                $finish;
            end
            @(negedge clk);
        end
    end
    
    if (out_valid === 1'b1) begin
        $display("SPEC is VIOLATED (out_valid should go low)");
        $finish;
    end
end endtask

task YOU_SUCCESS_task; begin
    $display("-----------------------------------------------------------------");
    $display("                        Excellent Work!                          ");
    $display("                You have finished all patterns!                  ");
    $display("-----------------------------------------------------------------");
    $finish;
end endtask

always @(negedge clk) begin
    if (out_valid === 1'b0 && out_data !== 12'b0 && rst_n === 1'b1) begin
        $display("SPEC is VIOLATED (out_data should be 0 when out_valid is low)");
        $finish;
    end
end

endmodule
