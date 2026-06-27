module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

reg [WIDTH-1:0] data_reg;
reg dreq_d1;

assign sidle = (!sreq && !sack);

always @(posedge sclk or negedge rst_n) begin
    if (!rst_n) begin
        sreq <= 0; data_reg <= 0;
    end 
    else begin
        if (sidle && sready) begin
            data_reg <= din; sreq <= 1'b1;
        end 
        else if (sack) begin
            sreq <= 1'b0;
        end
    end
end

always @(posedge dclk or negedge rst_n) begin
    if (!rst_n) begin
        dack <= 0; dvalid <= 0; dout <= 0; dreq_d1 <= 0;
    end 
    else begin
        dvalid <= 0; dreq_d1 <= dreq; 

        if (dreq && !dack && !dbusy) begin
            dout <= data_reg; dvalid <= 1'b1; dack <= 1'b1;
        end 
        else if (!dreq && dack) begin
            dack <= 1'b0;
        end
    end
end


NDFF_syn u_NDFF_syn_req ( .D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n) );
NDFF_syn u_NDFF_syn_ack ( .D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n) );

assign flag_handshake_to_clk1 = sack;
assign flag_handshake_to_clk2 = dreq_d1;

endmodule