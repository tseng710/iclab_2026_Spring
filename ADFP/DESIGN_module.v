module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid, 
    seed_in, 
    out_idle, 
    out_valid, 
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
) ;

input clk;
input rst_n;
input in_valid;
input seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3; 
output clk1_handshake_flag4;

reg [4:0] cnt_input;
reg [31:0] seed_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        cnt_input <= 0;
    end 
    else begin
        cnt_input <= (in_valid) ? cnt_input + 1 : cnt_input;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        seed_reg <= 0;
    end 
    else begin
        seed_reg <= (in_valid) ? {seed_reg[30:0], seed_in} : seed_reg;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
    end
    else if (in_valid && !out_valid && out_idle && cnt_input == 5'd31) begin
        out_valid <= 1;
    end 
    else begin
        out_valid <= 0;
    end
end

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        seed_out <= 0;
    end 
    else if (in_valid && !out_valid && out_idle) begin
        seed_out <= {seed_out[30:0], seed_in};
    end
end

endmodule


module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output out_valid;
output [31:0] rand_num;
output busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

reg [2:0] state;
reg [8:0] out_cnt;
reg [31:0] temp;
reg [31:0] shift_temp;
wire [31:0] share_temp_next;

parameter a = 13;
parameter b = 17;
parameter c = 5;

assign busy = state != 0 || in_valid;

// state
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state <= 0;
    end
    else begin 
        if(in_valid)begin
            state <= 1;
        end
        else if (out_cnt >= 256)begin
            state <= 0;
        end
        else if (fifo_full)begin
            state <= state;
        end
        else if (state == 4 && out_cnt < 256) begin
            state <= 1;
        end
        else if (out_cnt < 256)begin
            state <= state + 1;
        end
    end
end

// out_cnt
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_cnt <= {9{1'b1}};
    end
    else begin
        if (in_valid)begin
            out_cnt <= 0;
        end
        else if (out_cnt < 256 && state == 4 && !fifo_full)begin
            out_cnt <= out_cnt + 1;
        end
    end
end

//==========================//
//     Finish this part     //
//==========================//

// shift_temp
always @(*) begin
    case (state)
        3'd1: shift_temp = temp << a;
        3'd2: shift_temp = temp >> b;
        3'd3: shift_temp = temp << c;
        default: shift_temp = 32'd0;
    endcase
end

assign share_temp_next = temp ^ shift_temp;

//==========================//

// temp
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        temp <= 0;
    end
    else begin
        if (in_valid)begin
            temp <= seed;
        end
        else begin
            if (!fifo_full)begin
                temp <= share_temp_next;
            end
        end 
    end
end

// out_valid
assign out_valid = (state == 4 && !fifo_full);
assign rand_num  = share_temp_next;

endmodule


module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

reg fifo_rvalid1, fifo_rvalid2;
reg [1:0] curr_state;
reg [4:0] cnt_output;
reg [31:0] rdata_reg;

// fifo rinc
assign fifo_rinc = (curr_state == 0) ? !fifo_empty : 1'b0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        curr_state <= 0; // IDLE
    end
    else begin 
        case (curr_state)
            0: curr_state <= (fifo_empty == 0) ? 1 : 0; // IDLE -> WAIT
            1: curr_state <= 2;                         // WAIT -> OUTPUT
            2: curr_state <= (cnt_output == 0) ? 0 : 2; // OUTPUT
            default: curr_state <= curr_state;
        endcase
    end 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        cnt_output <= 31;
    end
    else begin
        if(curr_state == 2) begin
            cnt_output <= cnt_output - 1;
        end
        else begin
            cnt_output <= cnt_output;
        end   
    end
end

// fifo_rvalid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        fifo_rvalid1 <= 0;
        fifo_rvalid2 <= 0;
    end
    else begin
        fifo_rvalid1 <= fifo_rinc;
        fifo_rvalid2 <= fifo_rvalid1;
    end
end

// out_valid
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        out_valid <= 0;
    end
    else if(curr_state == 2)begin
        out_valid <= 1;
    end
    else begin 
        out_valid <= 0;
    end
end

// rand_num
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin 
        rand_num <= 0;
    end
    else if (curr_state == 2) begin
        rand_num <= fifo_rdata[cnt_output];
    end
    else begin
        rand_num <= 0;
    end
end

endmodule