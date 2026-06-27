module FIFO_syn #(parameter WIDTH=32, parameter WORDS=64) (
    wclk,//clk2
    rclk,//clk1
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    flag_fifo_to_clkw,
    flag_clkw_to_fifo,

    flag_fifo_to_clkr,
	flag_clkr_to_fifo
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output reg wfull;
input rinc;
output reg [WIDTH-1:0] rdata;
output reg rempty;

// You can change the input / output of the custom flag ports
output  flag_fifo_to_clkw;
input flag_clkw_to_fifo;

output flag_fifo_to_clkr;
input flag_clkr_to_fifo;

wire [WIDTH-1:0] rdata_q;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr;
reg [$clog2(WORDS):0] rptr;


assign flag_fifo_to_clkw = 0; 
assign flag_fifo_to_clkr = 0;

reg [$clog2(WORDS):0] wbin, rbin;

wire [$clog2(WORDS):0] wbin_next;
wire [$clog2(WORDS):0] rbin_next;
wire [$clog2(WORDS):0] wgray_next;
wire [$clog2(WORDS):0] rgray_next;

wire [$clog2(WORDS):0] rq2_wptr, wq2_rptr;


assign wbin_next = wbin + (winc & ~wfull);
assign rbin_next = rbin + (rinc & ~rempty);
assign wgray_next = (wbin_next >> 1) ^ wbin_next;
assign rgray_next = (rbin_next >> 1) ^ rbin_next;

always @(posedge wclk or negedge rst_n) begin
    if (!rst_n) begin 
        wbin <= 0; 
        wptr <= 0; 
    end 
    else begin 
        wbin <= wbin_next; 
        wptr <= wgray_next; 
    end
end

wire wfull_val;
assign wfull_val = (wgray_next == {~wq2_rptr[$clog2(WORDS):$clog2(WORDS)-1], wq2_rptr[$clog2(WORDS)-2:0]});

always @(posedge wclk or negedge rst_n) begin
    if (!rst_n) 
        wfull <= 0; 
    else 
        wfull <= wfull_val;
end

always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin 
        rbin <= 0; 
        rptr <= 0; 
    end 
    else begin 
        rbin <= rbin_next; 
        rptr <= rgray_next; 
    end
end

wire rempty_val;
assign rempty_val = (rgray_next == rq2_wptr);
always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) 
        rempty <= 1'b1; 
    else 
        rempty <= rempty_val;
end

wire ren_comb;
assign ren_comb = rinc & ~rempty;

reg ren;
always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) 
        ren <= 0; 
    else 
        ren <= ren_comb;
end

wire wen = winc & ~wfull;

always @(posedge rclk, negedge rst_n) begin
    if (!rst_n) 
        rdata <= 0;
    else if (ren)
        rdata <= rdata_q;
end


NDFF_BUS_syn #(.WIDTH(7)) u_NDFF_BUS_w2r (
    .D(wptr),
    .Q(rq2_wptr),
    .clk(rclk),
    .rst_n(rst_n)
);

NDFF_BUS_syn #(.WIDTH(7)) u_NDFF_BUS_r2w (
    .D(rptr),
    .Q(wq2_rptr),
    .clk(wclk),
    .rst_n(rst_n)
);

wire [31:0] dummy_doa;
wire [31:0] dummy_dib;
assign dummy_dib = 32'b0;

DUAL_64X32X1BM1 u_dual_sram (
    .CKA(wclk), .CKB(rclk), .WEAN(~wen), .WEBN(1'b1),
    .CSA(wen), .CSB(ren_comb), .OEA(1'b0), .OEB(1'b1),
    .A0(wbin[0]), .A1(wbin[1]), .A2(wbin[2]), .A3(wbin[3]), .A4(wbin[4]), .A5(wbin[5]),
    .B0(rbin[0]), .B1(rbin[1]), .B2(rbin[2]), .B3(rbin[3]), .B4(rbin[4]), .B5(rbin[5]),
    .DIA0(wdata[0]), .DIA1(wdata[1]), .DIA2(wdata[2]), .DIA3(wdata[3]), .DIA4(wdata[4]), .DIA5(wdata[5]), .DIA6(wdata[6]), .DIA7(wdata[7]),
    .DIA8(wdata[8]), .DIA9(wdata[9]), .DIA10(wdata[10]), .DIA11(wdata[11]), .DIA12(wdata[12]), .DIA13(wdata[13]), .DIA14(wdata[14]), .DIA15(wdata[15]),
    .DIA16(wdata[16]), .DIA17(wdata[17]), .DIA18(wdata[18]), .DIA19(wdata[19]), .DIA20(wdata[20]), .DIA21(wdata[21]), .DIA22(wdata[22]), .DIA23(wdata[23]),
    .DIA24(wdata[24]), .DIA25(wdata[25]), .DIA26(wdata[26]), .DIA27(wdata[27]), .DIA28(wdata[28]), .DIA29(wdata[29]), .DIA30(wdata[30]), .DIA31(wdata[31]),
    .DOB0(rdata_q[0]), .DOB1(rdata_q[1]), .DOB2(rdata_q[2]), .DOB3(rdata_q[3]), .DOB4(rdata_q[4]), .DOB5(rdata_q[5]), .DOB6(rdata_q[6]), .DOB7(rdata_q[7]),
    .DOB8(rdata_q[8]), .DOB9(rdata_q[9]), .DOB10(rdata_q[10]), .DOB11(rdata_q[11]), .DOB12(rdata_q[12]), .DOB13(rdata_q[13]), .DOB14(rdata_q[14]), .DOB15(rdata_q[15]),
    .DOB16(rdata_q[16]), .DOB17(rdata_q[17]), .DOB18(rdata_q[18]), .DOB19(rdata_q[19]), .DOB20(rdata_q[20]), .DOB21(rdata_q[21]), .DOB22(rdata_q[22]), .DOB23(rdata_q[23]),
    .DOB24(rdata_q[24]), .DOB25(rdata_q[25]), .DOB26(rdata_q[26]), .DOB27(rdata_q[27]), .DOB28(rdata_q[28]), .DOB29(rdata_q[29]), .DOB30(rdata_q[30]), .DOB31(rdata_q[31]),
    .DOA0(dummy_doa[0]), .DOA1(dummy_doa[1]), .DOA2(dummy_doa[2]), .DOA3(dummy_doa[3]), .DOA4(dummy_doa[4]), .DOA5(dummy_doa[5]), .DOA6(dummy_doa[6]), .DOA7(dummy_doa[7]),
    .DOA8(dummy_doa[8]), .DOA9(dummy_doa[9]), .DOA10(dummy_doa[10]), .DOA11(dummy_doa[11]), .DOA12(dummy_doa[12]), .DOA13(dummy_doa[13]), .DOA14(dummy_doa[14]), .DOA15(dummy_doa[15]),
    .DOA16(dummy_doa[16]), .DOA17(dummy_doa[17]), .DOA18(dummy_doa[18]), .DOA19(dummy_doa[19]), .DOA20(dummy_doa[20]), .DOA21(dummy_doa[21]), .DOA22(dummy_doa[22]), .DOA23(dummy_doa[23]),
    .DOA24(dummy_doa[24]), .DOA25(dummy_doa[25]), .DOA26(dummy_doa[26]), .DOA27(dummy_doa[27]), .DOA28(dummy_doa[28]), .DOA29(dummy_doa[29]), .DOA30(dummy_doa[30]), .DOA31(dummy_doa[31]),
    .DIB0(dummy_dib[0]), .DIB1(dummy_dib[1]), .DIB2(dummy_dib[2]), .DIB3(dummy_dib[3]), .DIB4(dummy_dib[4]), .DIB5(dummy_dib[5]), .DIB6(dummy_dib[6]), .DIB7(dummy_dib[7]),
    .DIB8(dummy_dib[8]), .DIB9(dummy_dib[9]), .DIB10(dummy_dib[10]), .DIB11(dummy_dib[11]), .DIB12(dummy_dib[12]), .DIB13(dummy_dib[13]), .DIB14(dummy_dib[14]), .DIB15(dummy_dib[15]),
    .DIB16(dummy_dib[16]), .DIB17(dummy_dib[17]), .DIB18(dummy_dib[18]), .DIB19(dummy_dib[19]), .DIB20(dummy_dib[20]), .DIB21(dummy_dib[21]), .DIB22(dummy_dib[22]), .DIB23(dummy_dib[23]),
    .DIB24(dummy_dib[24]), .DIB25(dummy_dib[25]), .DIB26(dummy_dib[26]), .DIB27(dummy_dib[27]), .DIB28(dummy_dib[28]), .DIB29(dummy_dib[29]), .DIB30(dummy_dib[30]), .DIB31(dummy_dib[31])
);
endmodule