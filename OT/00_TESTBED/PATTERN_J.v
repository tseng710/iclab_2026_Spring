//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2026 Spring
//   OT Exercise		
//   Author     		: Cho-Hsun Lee 
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

`define CYCLE_TIME      20.0
`define SEED_NUMBER     69
`define PATTERN_NUMBER  100

module PATTERN(
    // Output Port
    clk,
    rst_n,
    in_valid_data,
    in_data,
    in_valid_cmd,
    in_cmd,
    
    // Input Port
    out_valid,
    out_data
    );

//---------------------------------------------------------------------
//   PORT DECLARATION          
//---------------------------------------------------------------------
output  logic        clk, rst_n, in_valid_data, in_valid_cmd;
output  logic[7:0]  in_data;
output  logic[9:0]  in_cmd;

input           out_valid;
input   [7:0]   out_data;

//---------------------------------------------------------------------
//   PARAMETER & INTEGER DECLARATION
//---------------------------------------------------------------------
real CYCLE = `CYCLE_TIME;
real seed = `SEED_NUMBER;


integer i,j,k;
integer latency, total_latency;
integer pat_num, PAT_NUM;


//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
logic[7:0]  golden_out[0:15][0:15];

logic[7:0]  golden_Image1[0:15][0:15], golden_Image2[0:15][0:15], golden_Image3[0:15][0:15], golden_Image4[0:15][0:15], golden_Image5[0:15][0:15], golden_Image6[0:15][0:15], golden_Image7[0:15][0:15], golden_Image8[0:15][0:15], golden_Image9[0:15][0:15], golden_Image10[0:15][0:15], golden_Image11[0:15][0:15], golden_Image12[0:15][0:15], golden_Image13[0:15][0:15], golden_Image14[0:15][0:15], golden_Image15[0:15][0:15], golden_Image16[0:15][0:15];

logic[9:0] golden_task_number;

logic[7:0]  golden_ImageA[0:15][0:15], golden_ImageB[0:15][0:15];

logic[50:0] golden_ans1;
logic[50:0] golden_ans2;

logic [10:0] ccntt;

logic [7:0]  temp;

//================================================================
// clock
//================================================================

always #(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

//---------------------------------------------------------------------
//   Pattern_Design
//---------------------------------------------------------------------

initial begin
    force clk = 1'b0;

    reset_task;
    pat_num = 0;
    total_latency = 0;

    input_task1;
    repeat($urandom_range(2, 4)) @(negedge clk);

    for(pat_num=0; pat_num<`PATTERN_NUMBER; pat_num+=1) begin
        ccntt = 0;
        input_task2;

        calculate_task;

        wait_out_valid_task;
        check_ans_task;
        PASS_task;
        repeat($urandom_range(2, 4)) @(negedge clk);

    end

    YOU_PASS_task;

end


/* reset task*/
task reset_task; begin
    rst_n = 'b1;
    in_valid_data = 'b0;
    in_valid_cmd = 'b0;

    ccntt = 0;

    in_data = 'bx;
    in_cmd = 'bx;
    
    #CYCLE; rst_n = 'b0;
    #(3*CYCLE); rst_n = 'b1;
    
    if( (out_valid !== 0) || (out_data !== 0)) begin
        $display("***********************************************************************");
        $display("*                            SPEC FAIL                                  *");
        $display("************** Output signal should be 0 after initial RESET at %4t **************",$time);
        $display("***********************************************************************");
        #(50);
        $finish;
    end
    #CYCLE;
    release clk;
    repeat (5) @(negedge clk);
end endtask

task input_task1; begin                                 //golden_Images1~16 are treated as SRAM for storing 16 images

    for(i=0; i<4096; i=i+1) begin
        in_valid_data = 'b1;
        in_data = $random(seed) % 256;

        if(i<256) begin
            golden_Image1[i/16][i%16] = in_data;
        end
        else if(i >= 256 && i < 512) begin
            golden_Image2[(i-256)/16][(i-256)%16] = in_data;
        end
        else if(i >= 512 && i < 768) begin
            golden_Image3[(i-512)/16][(i-512)%16] = in_data;
        end
        else if(i >= 768 && i < 1024) begin
            golden_Image4[(i-768)/16][(i-768)%16] = in_data;
        end
        else if(i >= 1024 && i < 1280) begin
            golden_Image5[(i-1024)/16][(i-1024)%16] = in_data;
        end
        else if(i >= 1280 && i < 1536) begin
            golden_Image6[(i-1280)/16][(i-1280)%16] = in_data;
        end
        else if(i >= 1536 && i < 1792) begin
            golden_Image7[(i-1536)/16][(i-1536)%16] = in_data;
        end
        else if(i >= 1792 && i < 2048) begin
            golden_Image8[(i-1792)/16][(i-1792)%16] = in_data;
        end
        else if(i >= 2048 && i < 2304) begin
            golden_Image9[(i-2048)/16][(i-2048)%16] = in_data;
        end
        else if(i >= 2304 && i < 2560) begin
            golden_Image10[(i-2304)/16][(i-2304)%16] = in_data;
        end
        else if(i >= 2560 && i < 2816) begin
            golden_Image11[(i-2560)/16][(i-2560)%16] = in_data;
        end
        else if(i >= 2816 && i < 3072) begin
            golden_Image12[(i-2816)/16][(i-2816)%16] = in_data;
        end
        else if(i >= 3072 && i < 3328) begin
            golden_Image13[(i-3072)/16][(i-3072)%16] = in_data; 
        end
        else if(i >= 3328 && i < 3584) begin
            golden_Image14[(i-3328)/16][(i-3328)%16] = in_data;
        end
        else if(i >= 3584 && i < 3840) begin
            golden_Image15[(i-3584)/16][(i-3584)%16] = in_data;
        end
        else if(i >= 3840 && i < 4096) begin
            golden_Image16[(i-3840)/16][(i-3840)%16] = in_data;
        end

        @(negedge clk);
    end


    in_valid_data = 'b0;
    in_data = 'bx;

end endtask

task input_task2; begin                                 //golden_task_number is used for storing cmd
    in_valid_cmd = 'b1;
    in_cmd = $random(seed) % 1024;  // cmd0

    if(in_cmd[7:4] == in_cmd[3:0]) begin
        in_cmd[3:0] = in_cmd[7:4] + 6;
    end

    golden_task_number = in_cmd;

    @(negedge clk);
    in_valid_cmd = 'b0;
    in_cmd = 'bx;
end endtask 

task wait_out_valid_task; begin
  latency = 0;
  while(out_valid !== 1'b1) begin
    if(latency == 2000) begin
        $display("*************************************************************************");
        $display("*                          SPEC FAIL                                    *");
        $display("*                  Latency are over 2000 cycles                          *");
        $display("*************************************************************************");
        repeat(4) @(negedge clk);
        $finish;
    end

    if(out_data !== 0) begin
        $display("*************************************************************************");
        $display("*                          SPEC FAIL                                    *");
        $display("*          out signal should be zero when out_valid is low              *");
        $display("*************************************************************************");
        repeat(4) @(negedge clk);
        $finish;
    end

    latency = latency + 1;
    @(negedge clk);
  end
  total_latency+=latency;
end endtask

task calculate_task; 
    integer r_idx, c_idx;
    logic [3:0] target1, target2;
    logic [1:0] opcode;
    logic [7:0] resA [0:15][0:15];
    logic [7:0] resB [0:15][0:15];
    logic write_B;
begin
    target1 = golden_task_number[7:4];
    target2 = golden_task_number[3:0];
    opcode  = golden_task_number[9:8];
    write_B = 1'b0;

    // Load ImageA
    case(target1)
        4'd0:  golden_ImageA = golden_Image1;
        4'd1:  golden_ImageA = golden_Image2;
        4'd2:  golden_ImageA = golden_Image3;
        4'd3:  golden_ImageA = golden_Image4;
        4'd4:  golden_ImageA = golden_Image5;
        4'd5:  golden_ImageA = golden_Image6;
        4'd6:  golden_ImageA = golden_Image7;
        4'd7:  golden_ImageA = golden_Image8;
        4'd8:  golden_ImageA = golden_Image9;
        4'd9:  golden_ImageA = golden_Image10;
        4'd10: golden_ImageA = golden_Image11;
        4'd11: golden_ImageA = golden_Image12;
        4'd12: golden_ImageA = golden_Image13;
        4'd13: golden_ImageA = golden_Image14;
        4'd14: golden_ImageA = golden_Image15;
        4'd15: golden_ImageA = golden_Image16;
    endcase

    // Load ImageB
    case(target2)
        4'd0:  golden_ImageB = golden_Image1;
        4'd1:  golden_ImageB = golden_Image2;
        4'd2:  golden_ImageB = golden_Image3;
        4'd3:  golden_ImageB = golden_Image4;
        4'd4:  golden_ImageB = golden_Image5;
        4'd5:  golden_ImageB = golden_Image6;
        4'd6:  golden_ImageB = golden_Image7;
        4'd7:  golden_ImageB = golden_Image8;
        4'd8:  golden_ImageB = golden_Image9;
        4'd9:  golden_ImageB = golden_Image10;
        4'd10: golden_ImageB = golden_Image11;
        4'd11: golden_ImageB = golden_Image12;
        4'd12: golden_ImageB = golden_Image13;
        4'd13: golden_ImageB = golden_Image14;
        4'd14: golden_ImageB = golden_Image15;
        4'd15: golden_ImageB = golden_Image16;
    endcase

    for(r_idx=0; r_idx<16; r_idx=r_idx+1) begin
        for(c_idx=0; c_idx<16; c_idx=c_idx+1) begin
            resB[r_idx][c_idx] = golden_ImageB[r_idx][c_idx]; 

            case(opcode)
                2'b00: begin 
                    resA[r_idx][c_idx] = (golden_ImageA[r_idx][c_idx] + golden_ImageB[r_idx][c_idx]) / 2;
                    golden_out[r_idx][c_idx] = resA[r_idx][c_idx];
                end
                2'b01: begin 
                    if(golden_ImageA[r_idx][c_idx] > golden_ImageB[r_idx][c_idx])
                        resA[r_idx][c_idx] = golden_ImageA[r_idx][c_idx] - golden_ImageB[r_idx][c_idx];
                    else
                        resA[r_idx][c_idx] = golden_ImageB[r_idx][c_idx] - golden_ImageA[r_idx][c_idx];
                    golden_out[r_idx][c_idx] = resA[r_idx][c_idx];
                end
                2'b10: begin 
                    resA[r_idx][c_idx] = golden_ImageB[r_idx][c_idx];
                    resB[r_idx][c_idx] = golden_ImageA[r_idx][c_idx];
                    golden_out[r_idx][c_idx] = resA[r_idx][c_idx];
                    write_B = 1'b1;
                end
                2'b11: begin
                    if(golden_ImageA[r_idx][c_idx] > golden_ImageB[r_idx][c_idx])
                        resA[r_idx][c_idx] = golden_ImageA[r_idx][c_idx];
                    else
                        resA[r_idx][c_idx] = golden_ImageB[r_idx][c_idx];
                    golden_out[r_idx][c_idx] = resA[r_idx][c_idx];
                end
            endcase
        end
    end

    
    case(target1)
        4'd0:  golden_Image1  = resA;
        4'd1:  golden_Image2  = resA;
        4'd2:  golden_Image3  = resA;
        4'd3:  golden_Image4  = resA;
        4'd4:  golden_Image5  = resA;
        4'd5:  golden_Image6  = resA;
        4'd6:  golden_Image7  = resA;
        4'd7:  golden_Image8  = resA;
        4'd8:  golden_Image9  = resA;
        4'd9:  golden_Image10 = resA;
        4'd10: golden_Image11 = resA;
        4'd11: golden_Image12 = resA;
        4'd12: golden_Image13 = resA;
        4'd13: golden_Image14 = resA;
        4'd14: golden_Image15 = resA;
        4'd15: golden_Image16 = resA;
    endcase

    
    if (write_B) begin
        case(target2)
            4'd0:  golden_Image1  = resB;
            4'd1:  golden_Image2  = resB;
            4'd2:  golden_Image3  = resB;
            4'd3:  golden_Image4  = resB;
            4'd4:  golden_Image5  = resB;
            4'd5:  golden_Image6  = resB;
            4'd6:  golden_Image7  = resB;
            4'd7:  golden_Image8  = resB;
            4'd8:  golden_Image9  = resB;
            4'd9:  golden_Image10 = resB;
            4'd10: golden_Image11 = resB;
            4'd11: golden_Image12 = resB;
            4'd12: golden_Image13 = resB;
            4'd13: golden_Image14 = resB;
            4'd14: golden_Image15 = resB;
            4'd15: golden_Image16 = resB;
        endcase
    end
end endtask

task check_ans_task; 
    integer r_idx, c_idx;
begin
    for(r_idx=0; r_idx<16; r_idx=r_idx+1) begin
        for(c_idx=0; c_idx<16; c_idx=c_idx+1) begin
            if (out_valid !== 1'b1) begin
                $display("*************************************************************************");
                $display("*                            SPEC FAIL                                  *");
                $display("*            out_valid should be high for 256 consecutive cycles        *");
                $display("*************************************************************************");
                $finish;
            end
            if (out_data !== golden_out[r_idx][c_idx]) begin
                $display("*************************************************************************");
                $display("*                            SPEC FAIL                                  *");
                $display("* Data mismatch at pattern %0d, pixel [%0d][%0d]. Expected %0d, Got %0d *", pat_num, r_idx, c_idx, golden_out[r_idx][c_idx], out_data);
                $display("*************************************************************************");
                $finish;
            end
            @(negedge clk);
        end
    end
    
    
    if (out_valid !== 1'b0) begin
        $display("*************************************************************************");
        $display("*                   SPEC FAIL                                  *");
        $display("*             out_valid should be low after 256 cycles                 *");
        $display("*************************************************************************");
        $finish;
    end
end endtask

task PASS_task; 
  begin
    $display("\033[32m********************** pass pat_num%d | Your execution cycles = %d cycles **********************\033[0m", pat_num, latency);
  end
endtask

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
    $display("                                  --  \033[0;32mSimulation PASS!!\033[m          ");
    $display("                                  --                        --               ");
    $display("                                  --                        --               ");
    $display("                                Total Latency = %d cycles                                    ", total_latency);
    $display("                                  ----------------------------               ");
    // $display("*                  Computation Time = %10d ns          *", total_latency * `CYCLE_TIME);
    // $display("************************************************************************");
    $finish;
end endtask



always @(*) begin
    if(out_valid === 1 && in_valid_data === 1) begin
        $display("*************************************************************************");
        $display("*                            SPEC FAIL                                  *");
        $display("*               out_valid cannot overlap with in_valid                  *");
        $display("*************************************************************************");
        repeat(4) @(negedge clk);
        $finish;
    end

    if(out_valid === 1 && in_valid_cmd === 1) begin
        $display("*************************************************************************");
        $display("*                            SPEC FAIL                                  *");
        $display("*               out_valid cannot overlap with in_valid                  *");
        $display("*************************************************************************");
        repeat(4) @(negedge clk);
        $finish;
    end
end


endmodule

pattern 長這樣 似乎有錯demo不會過 請幫我更正design 跟pattern pattern都要完整 code

