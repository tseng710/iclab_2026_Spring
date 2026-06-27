//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring
//   lab08 Exercise		
//   Author     		: Cho-Hsun Lee 
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`define CYCLE_TIME      15.0
`define SEED_NUMBER     69
`define PATTERN_NUMBER  1000

`define PRINT_PROCESS 1

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
output  logic[7:0]  in_data;

input           out_valid;
input   [11:0]   out_data;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
real seed = `SEED_NUMBER;
integer PATNUM = `PATTERN_NUMBER;


//---------------------------------------------------------------------
//   REGS
//---------------------------------------------------------------------
reg mode;
reg [7:0] A [15:0];
reg [7:0] B [15:0];

reg [3:0] F1 [15:0];
reg [3:0] H1 [15:0];
reg [3:0] F2 [15:0];
reg [3:0] H2 [15:0];

reg [19:0] X1 [15:0];
reg [19:0] Y1 [15:0];
reg [19:0] MX1 [15:0];

reg [19:0] X2 [15:0];
reg [19:0] Y2 [15:0];
reg [19:0] MX2 [15:0];

reg [11:0] golden_A [15:0];
reg [11:0] golden_B [15:0];

reg [11:0] received_A [15:0];
reg [11:0] received_B [15:0];

reg f_flag;

integer i, j, k;

integer latency, total_latency;
integer patnum;

//---------------------------------------------------------------------
//   CLOCK
//---------------------------------------------------------------------
initial	clk = 0;
always #(CYCLE/2.0) clk = ~clk;


//---------------------------------------------------------------------
//   MAIN
//---------------------------------------------------------------------

initial begin
    async_reset_task;
    total_latency = 0;
    for (patnum = 0; patnum < PATNUM; patnum += 1) begin
        generate_pattern_task;
	    await_out_valid;
        solve_pattern;
        verify_answer;

        $display("\033[32mPASS PATTERN %d, latency = %d\033[0m", patnum, latency);
        total_latency += latency;
        repeat($urandom_range(3, 1)) @(negedge clk);
    end

    YOU_PASS_task;
end

task async_reset_task; begin
    in_valid = 0;

    rst_n = 1;
    force clk = 0;

    #(CYCLE * 2.0); rst_n = 0;
    #(20.0); rst_n = 1;
    if (out_valid !== 0 || out_data  !== 0) begin        
        $display("*************************************************************************");
        $display("           ALL output signals should be reset to 0 after reset           ");
        $display("*************************************************************************");
        $finish;
    end

    #(CYCLE * 2.0); release clk;
    repeat($urandom_range(5, 3)) @(negedge clk);
end endtask


task generate_pattern_task; begin
    mode = $urandom_range(1, 0);
    for (i = 0; i < 16; i = i + 1) begin
        A[i] = $urandom_range(255, 0);
        B[i] = $urandom_range(255, 0);

        F1[i] = $urandom_range(15, 0);
        H1[i] = $urandom_range(15, 0);
        F2[i] = $urandom_range(15, 0);
        H2[i] = $urandom_range(15, 0);
    end

    in_valid = 1;
    in_data  = mode;

    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = A[i];
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = B[i];
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = F1[i];
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = H1[i];
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = F2[i];
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clk);
        in_data = H2[i];
    end
    
    @(negedge clk);
    in_valid = 0;
    in_data  = 'bx;
end endtask

task await_out_valid; begin
    latency = 0;
    while (out_valid === 0) begin
        @(negedge clk);
        latency += 1;

        if (latency >= 200) begin
		    $display("*************************************************************************");
            $display("                       Latency exceed 200 cycles                         ");
            $display("*************************************************************************");
            $finish;
        end
    end
end endtask


task solve_pattern; begin
    if (mode == 0) begin
        // Stage 1
        // (F1 * A) % 15 + 1
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                X1[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    X1[4 * i + j] += F1[4 * i + k] * A[4 * k + j];
                X1[4 * i + j] = (X1[4 * i + j] % 15) + 1;
            end
        
        // (H1 * A) % 256
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                Y1[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    Y1[4 * i + j] += H1[4 * i + k] * A[4 * k + j];
                Y1[4 * i + j] = (Y1[4 * i + j] % 256);
            end
        
        // Mult & XOR
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                MX1[4 * i + j]      = X1[4 * i + j] * B[4 * i + j];
                golden_B[4 * i + j] = MX1[4 * i + j] ^ Y1[4 * i + j];
            end
        
        // Stage 2
        // (F2 * gB) % 15 + 1
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                X2[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    X2[4 * i + j] += F2[4 * i + k] * golden_B[4 * k + j];
                X2[4 * i + j] = (X2[4 * i + j] % 15) + 1;
            end
        
        // (H2 * gB) % 256
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                Y2[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    Y2[4 * i + j] += H2[4 * i + k] * golden_B[4 * k + j];
                Y2[4 * i + j] = (Y2[4 * i + j] % 256);
            end
        
        // Mult & XOR
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                MX2[4 * i + j]      = X2[4 * i + j] * A[4 * i + j];
                golden_A[4 * i + j] = MX2[4 * i + j] ^ Y2[4 * i + j];
            end
    end
    else begin
        // Stage 2
        // (F2 * B) % 15 + 1
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                X2[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    X2[4 * i + j] += F2[4 * i + k] * B[4 * k + j];
                X2[4 * i + j] = (X2[4 * i + j] % 15) + 1;
            end
        
        // (H2 * B) % 256
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                Y2[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    Y2[4 * i + j] += H2[4 * i + k] * B[4 * k + j];
                Y2[4 * i + j] = (Y2[4 * i + j] % 256);
            end
        
        // Div & XOR
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                MX2[4 * i + j]      = Y2[4 * i + j] ^ A[4 * i + j];
                golden_A[4 * i + j] = MX2[4 * i + j] / X2[4 * i + j];
            end
        
        // Stage 1
        // (F1 * gA) % 15 + 1
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                X1[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    X1[4 * i + j] += F1[4 * i + k] * golden_A[4 * k + j];
                X1[4 * i + j] = (X1[4 * i + j] % 15) + 1;
            end
        
        // (H1 * gA) % 256
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                Y1[4 * i + j] = 0;
                for (k = 0; k < 4; k = k + 1)
                    Y1[4 * i + j] += H1[4 * i + k] * golden_A[4 * k + j];
                Y1[4 * i + j] = (Y1[4 * i + j] % 256);
            end
        
        // Div & XOR
        for (i = 0; i < 4; i = i + 1)
            for (j = 0; j < 4; j = j + 1) begin
                MX1[4 * i + j]      = Y1[4 * i + j] ^ B[4 * i + j];
                golden_B[4 * i + j] = MX1[4 * i + j] / X1[4 * i + j];
            end
    end
end endtask

task verify_answer; begin
    for (i = 0; i < 16; i = i + 1) begin
        received_A[i] = out_valid? out_data : 'bx;
        @(negedge clk);
    end
    
    for (i = 0; i < 16; i = i + 1) begin
        received_B[i] = out_valid? out_data : 'bx;
        @(negedge clk);
    end

    f_flag = 0;
    for (i = 0; i < 16; i = i + 1) 
        if ((golden_A[i] !== received_A[i]) || golden_B[i] !== received_B[i])
            f_flag = 1;

    if (f_flag) begin
        $display("\033[31m--------------- PATTERN FAIL ---------------\033[0m");
        $display("\033[31m                                            \033[0m");

        $display("Mode = %d", mode);
        
        $display();
        $display("Input");
        $display("%s", {125{"-"}});
        $display("%-20s|%-20s|%-20s|%-20s|%-20s|%-20s", "Matrix A", "Matrix B", "Matrix F1", "Matrix H1", "Matrix F2", "Matrix H2");
        for (i = 0; i < 4; i = i + 1) begin
            $write("  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", A[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", B[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", F1[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", H1[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", F2[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%3d ", H2[4 * i + j]);
            $display();
        end
        
        if (`PRINT_PROCESS) begin
            $display();
            $display("Stage 1");
            $display("%s", {63{"-"}});
            $display("%-20s|%-20s|%-20s", "Matrix X1", "Matrix Y1", "Matrix Mid1");
            for (i = 0; i < 4; i = i + 1) begin
                $write("  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", X1[4 * i + j]);
                $write("  |  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", Y1[4 * i + j]);
                $write("  |  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", MX1[4 * i + j]);
                $display();
            end
            
            $display();
            $display("Stage 2");
            $display("%s", {63{"-"}});
            $display("%-20s|%-20s|%-20s", "Matrix X2", "Matrix Y2", "Matrix Mid2");
            for (i = 0; i < 4; i = i + 1) begin
                $write("  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", X2[4 * i + j]);
                $write("  |  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", Y2[4 * i + j]);
                $write("  |  ");
                for (j = 0; j < 4; j = j + 1) $write("%3d ", MX2[4 * i + j]);
                $display();
            end
        end
        
        $display();
        $display("Output");
        $display("%s", {106{"-"}});
        $display("%-24s|%-24s%8s%-24s|%-24s", "Golden A", "Received A", "", "Golden B", "Received B");
        for (i = 0; i < 4; i = i + 1) begin
            $write("  ");
            for (j = 0; j < 4; j = j + 1) $write("%4d ", golden_A[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%4d ", received_A[4 * i + j]);
            $write("%12s", "");
            for (j = 0; j < 4; j = j + 1) $write("%4d ", golden_B[4 * i + j]);
            $write("  |  ");
            for (j = 0; j < 4; j = j + 1) $write("%4d ", received_B[4 * i + j]);
            $display();
        end

        $display("\033[31m                                            \033[0m");
        $display("\033[31m--------------------------------------------\033[0m");
        $finish;
    end

end endtask

task YOU_PASS_task; begin
    $display("                                                   ....... ... ....... ..... ... ......                 ");
    $display("                                              ......:-+#&@@@&#+-:..-+#@@@@@&+:.....                 ");
    $display("                                        .......:+#@@@@@@&&&&&@@@@@@@@@@&&&&@@@@@*:....              ");
    $display("                                        ....:*@@@@&*=-:::..:*@@@@&+--:::::::::=#@@*....             ");
    $display("                                     .....-&@@@#-::::....-@@@@#-:::::::.........=@@:...             ");
    $display("                                  .  ...=@@@&=::::.....=&@@&=::::::...........:*@@*...              ");
    $display("                                  . ...*@@&-::::.....-&@@&-::::::..........:+&@@@+. ..              ");
    $display("                               .. ....&@@+:::::.....+@@&=::::::.........:*&@@@&-... ..              ");
    $display("                              .. ....&@@=::::.....:+@@&::::::.......:+@@@@@@+......                 ");
    $display("                     ........:-+#@@@@@@=:::...:@@@@@@@@&-::...:-+&@@@@@&*-.......                   ");
    $display("                     ....=*&@@@@@@#*+=:........---::---:......@@@@@@@&+-.........                   ");
    $display("                 ....:*@@@@@&+::..............................::-+#@@@@@@&#-.....                   ");
    $display("              ....:*@@@@&+......::-=+*+:...............................+&@@@@&-........             ");
    $display("             ...=&@@@&+:...:=#@@@@&&###-.................#@@@@&#+-:.......:+#@@@*:.....             ");
    $display("           ...=&@@@*-....-#@@#-:.........................:---=+&@@@&+:.......:=@@@#:......          ");
    $display("         ...:@@@@=.....:&@@+.....................................:#@@@*.........-&@@&:...           ");
    $display("        ...*@@@+......=@@#..........................................=&@@+.........=@@@+... .        ");
    $display("        .:#@@#:......+@@=.............................................=@@#:.........#@@#.....       ");
    $display("    .....&@@+.......-@@=...............................................:&@@:.........+@@&:...       ");
    $display("    ....&@@=........#@#:................................................-&@@:.........+@@#:.        ");
    $display("    ...*@@+........:@@+..................................................=@@#:.........+@@+..       ");
    $display("    ..-@@#:........:@@=...................................................#@@-..........#@@:.       ");
    $display("    .:*@@-..........-=.....................................................+=...........-@@#...     ");
    $display("    .=@@#........................+@@@@#-...................=&@@#:.......................:*@@-...    ");
    $display(" ....#@@-.....................:*@@=..:@@*................*@@*:=#@&:......................=@@#...    ");
    $display(" ...:@@&......................=@@&..-&@@&...............+@@#....#@@......................:&@&:.     ");
    $display(" ...=@@*......................=@@@@@@@@@*...............+@@@@&&@@@@:......................*@@=..    ");
    $display("  ..+@@+.......................*@@+=*@@#:...............:#@&=++#@@=.......................*@@+..    ");
    $display("  ..*@@=............::::::::::...=**+=:...................-#@@@@#-..:::::::::.............*@@+..    ");
    $display(" ...+@@+..........::+@#:::+:::+-...............:*-................::-=:::::::::...........*@@+..    ");
    $display(" ...-@@#.........::=@@-:-@#-:#@+:.........#@=..+@@-..==..........::=@#::&&-:&&-:.........:#@@=..    ");
    $display(" ....&@@..........:#@=::&@=:+@*::.........=@@@&@@@@=#@@-.........:-@#-:*@+:*@*::.........-&@&:..    ");
    $display(" ....+@@+.........::::::-:::::::...........:#@@@@@@@@+...........:=*=::**-:#*:::.........+@@*...    ");
    $display(" ....:&@@-..........:::::::::::.............*@&=&#:@@=............::::::::::::..........:&@@:...    ");
    $display("  ....=@@&:.................................*@&:=::@@=.................::...............#@@-....    ");
    $display("    ...+@@*:................................=@@=:::@@-................................:&@@+....     ");
    $display("    ....*@@&:................................#@&+-#@#:...............................-&@@*....      ");
    $display("     ....=@@@*................................=@@@@#:...............................*@@@=.....      ");
    $display("        ..-&@@@+..............................:...................................*@@@&.....        ");
    $display("         ...+@@@@+:..........................:@&+#&:...........................:+@@@@+......        ");
    $display("         .....+@@@@#=.........................:+*+-..........................=#@@@@+.........       ");
    $display("           .  ..-&@@@@@*:................................................:*&@@@@&-..........        ");
    $display("              .....=&@@@@@@#=-::..................................::-=#@@@@@@&=.....                ");
    $display("                 .....:+#@@@@@@@@&#+=-:::................:::-=+*&@@@@@@@@#+:.......                 ");
    $display("                 ..........:-=#@@@@@@@@@@@@@@&&&&&&&&@@@@@@@@@@@@@@#=-:........                     ");
    $display("                           .........:-=+*#&&&&@@@@@@&&&&#*+--:..... ..                              ");
    $display("                           ..          .. .. ...             .  .. ..                           ");
    $display("                                                     ");
    $display("                                                      ");
    $display("                          \033[0;32m \033[5m    //   ) )     // | |     //   ) )     //   ) )\033[m");
    $display("                          \033[0;32m \033[5m   //___/ /     //__| |    ((           ((\033[m");
    $display("                          \033[0;32m \033[5m  / ____ /     / ___  |      \\           \\\033[m");
    $display("                          \033[0;32m \033[5m //           //    | |        ) )          ) )\033[m");
    $display("                          \033[0;32m \033[5m//           //     | | ((___ / /    ((___ / /\033[m");
    $display("                                  ----------------------------               ");
    $display("                                  --                        --               ");
    $display("                                  --  Congratulations !!    --               ");
    $display("                                  --                        --               ");
    $display("                                Total Latency = %d cycles                                    ", total_latency);
    $display("                                  --                        --               ");
    $display("                                  ----------------------------               ");
    $finish;
end endtask

endmodule




