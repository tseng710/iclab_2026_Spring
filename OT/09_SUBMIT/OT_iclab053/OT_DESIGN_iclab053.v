

module OT_DESIGN(
    // input signals
    clk,
    rst_n,
	
    in_valid_data,
	in_data,
	
    in_valid_cmd,
	in_cmd,    
	
    // output signals
	out_valid,	
	out_data
);

input              clk;
input              rst_n;

input              in_valid_data;
input       [7:0]  in_data;

input              in_valid_cmd;
input      [9:0]  in_cmd;

output reg         out_valid;
output reg  [7:0]  out_data;

//==================================================================
// parameter & integer
//==================================================================

parameter IDLE    = 0,IN_DATA = 1, READ_A  = 2, READ_B  = 3, WRITE_B = 4, OUT     = 5;

//==================================================================
// reg & wire
//==================================================================
reg [2:0]  curr_state, next_state;
reg [12:0] cnt;
reg [1:0]  opcode;
reg [3:0]  target1, target2;

reg [7:0]  imgA [0:255];
reg [7:0]  imgB [0:255];

reg [11:0] sram_addr;
reg        sram_web;
reg [7:0]  sram_din;
reg [7:0]  resA;

wire [7:0] valA;
wire [7:0] valB;
wire [8:0] sum;
wire [7:0] diff;
reg [15:0] sumA, sumB;
reg [7:0]  row_max [0:15];
wire [3:0] row_idx;
// -----------------------------------------------------
// MEM
// -----------------------------------------------------

// MEM_0: 8-bit width, 4096 depth
wire        mem0_web;
wire [11:0] mem0_addr;
wire  [7:0] mem0_din;
wire  [7:0] mem0_dout;



//==================================================================
// design
//==================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        opcode  <= 0;
        target1 <= 0;
        target2 <= 0;
    end 
    else if(in_valid_cmd) begin
        opcode  <= in_cmd[9:8];
        target1 <= in_cmd[7:4];
        target2 <= in_cmd[3:0];
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        curr_state <= IDLE;
    end 
    else begin
        curr_state <= next_state;
    end
end

always @(*) begin
    next_state = curr_state;
    case(curr_state)
        IDLE: begin
            if(in_valid_data) 
                next_state = IN_DATA;
            else if(in_valid_cmd) 
                next_state = READ_A;
        end
        IN_DATA: begin
            if(!in_valid_data) 
                next_state = IDLE;
        end
        READ_A: begin
            if(cnt == 256) 
                next_state = READ_B;
        end
        READ_B: begin
            if(cnt == 256) 
                next_state = (opcode == 2'b10) ? WRITE_B : OUT;
        end
        WRITE_B: begin 
            if(cnt == 255) 
                next_state = OUT;
        end
        OUT: begin
            if(cnt == 255) 
                next_state = IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt <= 0;
    end 
    else begin
        case(curr_state)
            IDLE: begin
                if(in_valid_data) 
                    cnt <= 1;
                else 
                    cnt <= 0;
            end
            IN_DATA: begin
                if(in_valid_data) 
                    cnt <= cnt + 1;
                else    
                    cnt <= 0;
            end
            READ_A: begin
                if(cnt == 256) 
                    cnt <= 0;
                else    
                    cnt <= cnt + 1;
            end

            READ_B: begin
                if(cnt == 256) 
                    cnt <= 0;
                else 
                    cnt <= cnt + 1;
            end
            WRITE_B: begin
                if(cnt == 255) 
                    cnt <= 0;
                else 
                    cnt <= cnt + 1;
            end
            OUT: begin
                if(cnt == 255) 
                    cnt <= 0;
                else 
                    cnt <= cnt + 1;
            end
            default: 
                cnt <= 0;
        endcase
    end
end


integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sumA <= 0;
        for(i = 0; i < 256; i = i + 1) begin
            imgA[i] <= 0;
        end
    end
    else if (in_valid_cmd) begin
        sumA <= 0;
        for(i = 0; i < 256; i = i + 1) begin
            imgA[i] <= 0;
        end
    end
    else begin
        if (curr_state == READ_A && cnt > 0 && cnt <= 256) begin
            imgA[cnt - 1] <= mem0_dout;
            sumA <= sumA + mem0_dout; 
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sumB <= 0;
        for(i = 0; i < 256; i = i + 1) begin
            imgB[i] <= 0;
        end
    end
    else if (in_valid_cmd) begin
        sumB <= 0;
        for(i = 0; i < 256; i = i + 1) begin
            imgB[i] <= 0;
        end
    end
    else begin
        if (curr_state == READ_B && cnt > 0 && cnt <= 256) begin
            imgB[cnt - 1] <= mem0_dout;
            sumB <= sumB + mem0_dout; 
        end
    end
end
assign row_idx = (cnt - 1) >> 4;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for(i = 0; i < 16; i = i + 1) begin
            row_max[i] <= 0;
        end
    end
    else if (in_valid_cmd) begin
        for(i = 0; i < 16; i = i + 1) begin
            row_max[i] <= 0;
        end
    end
    else begin
        if (curr_state == READ_A && cnt > 0 && cnt <= 256) begin
            if (mem0_dout > row_max[row_idx]) begin
                row_max[row_idx] <= mem0_dout;
            end
        end
    end
end

assign sum  = valA + valB;
assign diff = (valA >= valB) ? (valA - valB) : (valB - valA);
assign valA = imgA[cnt];
assign valB = imgB[cnt];

always @(*) begin
    case(opcode)
        2'b00: resA = sum >> 1;                            
        2'b01: resA = diff;                                
        2'b10: resA = (sumA > sumB) ? valA : valB; 
        2'b11: resA = row_max[cnt >> 4];          
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_data  <= 0;
    end 
    else begin
        if(curr_state == OUT) begin
            out_valid <= 1;
            out_data  <= resA;
        end 
        else begin
            out_valid <= 0;
            out_data  <= 0;
        end
    end
end

always @(*) begin
    sram_addr = 0;
    sram_web  = 1;
    sram_din  = 0;

    case(curr_state)
        IDLE: begin
            if(in_valid_data) begin
                sram_addr = cnt;
                sram_web  = 0;
                sram_din  = in_data;
            end
        end
        IN_DATA: begin
            sram_addr = cnt;
            sram_web = ~in_valid_data;
            sram_din = in_data;
        end
        READ_A: begin
            sram_addr = target1 * 256 + cnt;
            sram_web  = 1;
        end
        READ_B: begin
            sram_addr = target2 * 256 + cnt;
            sram_web  = 1;
        end
        WRITE_B: begin
            sram_addr = target2 * 256 + cnt;
            sram_web  = 0;
            sram_din  = imgA[cnt]; 
        end
        OUT: begin
            sram_addr = target1 * 256 + cnt;
            sram_web  = (opcode == 2'b10) ? 0 : 1; 
            sram_din  = imgB[cnt]; 
        end
    endcase
end

assign mem0_addr = sram_addr;
assign mem0_web  = sram_web;
assign mem0_din  = sram_din;


// MEM_0, MEM_1, MEM_2, MEM_3, MEM_4, MEM_5, MEM_6, MEM_7 instantiation
SUMA180_4096X8X1BM4 MEM0(
    .A0(mem0_addr[0]), .A1(mem0_addr[1]), .A2(mem0_addr[2]), .A3(mem0_addr[3]), .A4(mem0_addr[4]), .A5(mem0_addr[5]), .A6(mem0_addr[6]), .A7(mem0_addr[7]), 
    .A8(mem0_addr[8]), .A9(mem0_addr[9]), .A10(mem0_addr[10]), .A11(mem0_addr[11]),
    .DO0(mem0_dout[0]), .DO1(mem0_dout[1]), .DO2(mem0_dout[2]), .DO3(mem0_dout[3]), .DO4(mem0_dout[4]), .DO5(mem0_dout[5]), .DO6(mem0_dout[6]), .DO7(mem0_dout[7]),
    .DI0(mem0_din[0]), .DI1(mem0_din[1]), .DI2(mem0_din[2]), .DI3(mem0_din[3]), .DI4(mem0_din[4]), .DI5(mem0_din[5]), .DI6(mem0_din[6]), .DI7(mem0_din[7]),
    .CK(clk), .WEB(mem0_web), .OE(1'b1), .CS(1'b1)
); 

endmodule
