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
`define PATTERN_NUMBER  1000

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
output  logic[7:0]   in_data;

input           out_valid;
input   [11:0]  out_data;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
integer seed = `SEED_NUMBER; // Changed to integer for random seed usage

integer patcount;
integer exe_latency;
integer total_latency;
integer i, j, k;
integer out_idx;
integer wait_cycles;

logic task_num;
logic [7:0] mat_A  [0:3][0:3];
logic [7:0] mat_B  [0:3][0:3];
logic [3:0] mat_F1 [0:3][0:3];
logic [3:0] mat_H1 [0:3][0:3];
logic [3:0] mat_F2 [0:3][0:3];
logic [3:0] mat_H2 [0:3][0:3];

// Intermediate variables for Golden Model calculation
logic [19:0] temp_sum;
logic [3:0]  X1      [0:3][0:3];
logic [7:0]  Y1      [0:3][0:3];
logic [11:0] BX1     [0:3][0:3];
logic [11:0] Mid_A   [0:3][0:3];
logic [11:0] Mid_B   [0:3][0:3];
logic [3:0]  X2      [0:3][0:3];
logic [7:0]  Y2      [0:3][0:3];
logic [11:0] Mid_AX2 [0:3][0:3];

// Golden answers
logic [11:0] gold_OUT_A [0:15];
logic [11:0] gold_OUT_B [0:15];

//---------------------------------------------------------------------
//   CLOCK GENERATION
//---------------------------------------------------------------------
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//---------------------------------------------------------------------
//   MAIN EXECUTION BLOCK
//---------------------------------------------------------------------
initial begin
    reset_task;
    total_latency = 0;
    
    for (patcount = 0; patcount < `PATTERN_NUMBER; patcount = patcount + 1) begin
        input_task;
        golden_task;
        wait_task;
        check_task;
        
        // Random delay between 2 to 5 cycles before next valid input
        wait_cycles = $urandom_range(2, 5);
        repeat(wait_cycles) @(negedge clk);
    end
    
    display_success_msg;
    $finish;
end

//---------------------------------------------------------------------
//   TASKS
//---------------------------------------------------------------------

task reset_task; begin
    // 1. 初始狀態設定
    rst_n = 1;
    in_valid = 0;
    in_data = 0;
    
    // 2. 啟動「時間暫停魔法」：強制沒收 Clock
    force clk = 0;
    #(CYCLE / 2.0); // 稍微等半個 Cycle，確保時脈完全平息
    
    // 3. 在時脈絕對靜止的安全環境下，拉低 Reset
    rst_n = 0;
    #(CYCLE * 3);   // 讓 Reset 訊號維持足夠長的時間
    
    // 4. 進行非同步重置檢查 (此時 Clock 依然是停的)
    if (out_valid !== 0 || out_data !== 0) begin
        $display("-----------------------------------------------------------------");
        $display("   Reset Check Violation: Output should be zero after reset.     ");
        $display("-----------------------------------------------------------------");
        $finish;
    end
    
    // 5. 安全解除 Reset
    #(CYCLE);
    rst_n = 1;      // 放開 Reset！因為 clk 是 0，絕對不會觸發 $recrem
    
    // 6. 解除時間暫停：把 Clock 還給系統
    #(CYCLE / 2.0); // 放開 Reset 後稍微等一下再給 Clock
    release clk;    // 系統的 always #5 clk = ~clk 重新接管
end endtask

// Task 2: Feed inputs to DUT
task input_task; begin
    // Randomize matrix values
    task_num = $urandom_range(0, 1);
    //task_num = 1;
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            mat_A[i][j]  = $urandom_range(0, 255);
            mat_B[i][j]  = $urandom_range(0, 255);
            mat_F1[i][j] = $urandom_range(0, 15);
            mat_H1[i][j] = $urandom_range(0, 15);
            mat_F2[i][j] = $urandom_range(0, 15);
            mat_H2[i][j] = $urandom_range(0, 15);
        end
    end

    // Cycle 1: task_num
    @(negedge clk);
    in_valid = 1;
    in_data = {7'b0, task_num};
    
    // Cycle 2-17: Matrix A
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = mat_A[i][j];
        end
    end
    // Cycle 18-33: Matrix B
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = mat_B[i][j];
        end
    end
    // Cycle 34-49: Matrix F1
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = {4'b0, mat_F1[i][j]};
        end
    end
    // Cycle 50-65: Matrix H1
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = {4'b0, mat_H1[i][j]};
        end
    end
    // Cycle 66-81: Matrix F2
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = {4'b0, mat_F2[i][j]};
        end
    end
    // Cycle 82-97: Matrix H2
    for(i=0; i<4; i=i+1) begin
        for(j=0; j<4; j=j+1) begin
            @(negedge clk);
            in_data = {4'b0, mat_H2[i][j]};
        end
    end
    
    @(negedge clk);
    in_valid = 0;
    in_data = 8'bx;
end endtask

// Task 3: Calculate Golden Answer
task golden_task; begin
    if (task_num == 0) begin
        // --- Forward Network ---
        // X1 & Y1
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_F1[i][k] * mat_A[k][j];
                X1[i][j] = (temp_sum % 15) + 1;
                
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_H1[i][k] * mat_A[k][j];
                Y1[i][j] = (temp_sum % 256);
                
                BX1[i][j] = X1[i][j] * mat_B[i][j];
                Mid_A[i][j] = mat_A[i][j];
                Mid_B[i][j] = BX1[i][j] ^ Y1[i][j];
            end
        end
        // X2 & Y2
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_F2[i][k] * Mid_B[k][j];
                X2[i][j] = (temp_sum % 15) + 1;
                
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_H2[i][k] * Mid_B[k][j];
                Y2[i][j] = (temp_sum % 256);
                
                Mid_AX2[i][j] = X2[i][j] * Mid_A[i][j];
                gold_OUT_A[i*4+j] = Mid_AX2[i][j] ^ Y2[i][j];
                gold_OUT_B[i*4+j] = Mid_B[i][j];
            end
        end
    end else begin
        // --- Backward Network ---
        // X2 & Y2
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_F2[i][k] * mat_B[k][j];
                X2[i][j] = (temp_sum % 15) + 1;
                
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_H2[i][k] * mat_B[k][j];
                Y2[i][j] = (temp_sum % 256);
                
                Mid_AX2[i][j] = mat_A[i][j] ^ Y2[i][j];
                Mid_A[i][j] = Mid_AX2[i][j] / X2[i][j];
                Mid_B[i][j] = mat_B[i][j];
            end
        end
        // X1 & Y1
        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_F1[i][k] * Mid_A[k][j];
                X1[i][j] = (temp_sum % 15) + 1;
                
                temp_sum = 0;
                for(k=0; k<4; k=k+1) temp_sum = temp_sum + mat_H1[i][k] * Mid_A[k][j];
                Y1[i][j] = (temp_sum % 256);
                
                BX1[i][j] = Mid_B[i][j] ^ Y1[i][j];
                gold_OUT_A[i*4+j] = {4'b0, Mid_A[i][j][7:0]}; // Task 1 Output is 8-bit, pad to 12-bit
                gold_OUT_B[i*4+j] = {4'b0, (BX1[i][j] / X1[i][j])}; // Zero padding
            end
        end
    end
end endtask

// Task 4: Wait for execution
task wait_task; begin
    exe_latency = 0;
    while(out_valid !== 1) begin
        exe_latency = exe_latency + 1;
        if(exe_latency > 200) begin
            $display("-----------------------------------------------------------------");
            $display("   Latency constraint violated: Execution took more than 200 cycles! ");
            $display("-----------------------------------------------------------------");
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + exe_latency;
end endtask

// Task 5: Check Answers
task check_task; begin
    // Check OUT_A (first 16 cycles)
    for(out_idx = 0; out_idx < 16; out_idx = out_idx + 1) begin
        if(out_valid !== 1) begin
            $display("-----------------------------------------------------------------");
            $display("   Output Valid should be high for 32 continuous cycles!         ");
            $display("-----------------------------------------------------------------");
            $finish;
        end
        
        if(out_data !== gold_OUT_A[out_idx]) begin
            $display("-----------------------------------------------------------------");
            $display("   Wrong Answer at PATTERN %0d                                   ", patcount);
            $display("   Task_num = %0d, Matrix_A index = %0d                          ", task_num, out_idx);
            $display("   Expected OUT_A = %0d, Your OUT_A = %0d                        ", gold_OUT_A[out_idx], out_data);
            $display("-----------------------------------------------------------------");
            $finish;
        end
        @(negedge clk);
    end
    
    // Check OUT_B (next 16 cycles)
    for(out_idx = 0; out_idx < 16; out_idx = out_idx + 1) begin
        if(out_valid !== 1) begin
            $display("-----------------------------------------------------------------");
            $display("   Output Valid should be high for 32 continuous cycles!         ");
            $display("-----------------------------------------------------------------");
            $finish;
        end
        
        if(out_data !== gold_OUT_B[out_idx]) begin
            $display("-----------------------------------------------------------------");
            $display("   Wrong Answer at PATTERN %0d                                   ", patcount);
            $display("   Task_num = %0d, Matrix_B index = %0d                          ", task_num, out_idx);
            $display("   Expected OUT_B = %0d, Your OUT_B = %0d                        ", gold_OUT_B[out_idx], out_data);
            $display("-----------------------------------------------------------------");
            $finish;
        end
        @(negedge clk);
    end
    
    // Check if valid drops immediately after 32 cycles
    if(out_valid === 1) begin
        $display("-----------------------------------------------------------------");
        $display("   Output Valid should drop immediately after 32 cycles!         ");
        $display("-----------------------------------------------------------------");
        $finish;
    end
end endtask

// Final Display
task display_success_msg; begin
    $display("-----------------------------------------------------------------");
    $display("   Simulation Completed Successfully!                            ");
    $display("   Total Patterns: %0d                                           ", `PATTERN_NUMBER);
    $display("   Total Latency: %0d cycles                                     ", total_latency);
    $display("-----------------------------------------------------------------");
end endtask

endmodule