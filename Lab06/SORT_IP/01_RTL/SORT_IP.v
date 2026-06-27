//###############################################################################################
//***********************************************************************************************
//    File Name   : SORT_IP.v
//    Module Name : SORT_TP
//***********************************************************************************************
//###############################################################################################

module SORT_IP #(parameter IP_WIDTH = 3)(
	//Input signals
	IN_character, IN_weight,
	//Output signalsll
	OUT_character
);

// ======================================================
// Input & Output Declaration
// ======================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output [IP_WIDTH*4-1:0] OUT_character;

// ======================================================
// Design start
// ======================================================

wire [4:0]          weight [0:IP_WIDTH-1];
wire [3:0]          char   [0:IP_WIDTH-1];
wire [8:0]          val    [0:IP_WIDTH-1];
wire [IP_WIDTH-1:0] cmp    [0:IP_WIDTH-1];
wire [3:0]          rank   [0:IP_WIDTH-1];


genvar i, j, k;

// Step 1
generate
    for (i = 0; i < IP_WIDTH; i = i + 1) begin 
        assign char   [i]   = IN_character[(i*4)+3 : (i*4)];
        assign weight [i]   = IN_weight   [(i*5)+4 : (i*5)];
        assign val    [i]   = {weight[i], char[i]};
    end
endgenerate

//  Step 2
generate
    for (i = 0; i < IP_WIDTH; i = i + 1) begin 
        for (j = 0; j < IP_WIDTH; j = j + 1) begin
            if (i == j) begin
                assign cmp[i][j] = 1'b0;
            end 
            else if (i < j) begin
                assign cmp[i][j] = (val[i] < val[j]);
            end 
            else begin
                assign cmp[i][j] = ~(val[j] < val[i]);
            end
        end
    end
endgenerate

// Step 3
generate
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        wire [7:0] cmp_padded;
        wire [1:0] sum_01, sum_23, sum_45, sum_67;
        wire [2:0] sum_0123, sum_4567;
        
        for (k = 0; k < 8; k = k + 1) begin
            if (k < IP_WIDTH) begin
                assign cmp_padded[k] = cmp[i][k];
            end 
            else begin
                assign cmp_padded[k] = 1'b0;
            end
        end
        
        assign sum_01 = cmp_padded[0] + cmp_padded[1];
        assign sum_23 = cmp_padded[2] + cmp_padded[3];
        assign sum_45 = cmp_padded[4] + cmp_padded[5];
        assign sum_67 = cmp_padded[6] + cmp_padded[7];
        
        assign sum_0123 = sum_01 + sum_23;
        assign sum_4567 = sum_45 + sum_67;
        
        assign rank[i] = sum_0123 + sum_4567;
    end
endgenerate

// ======================================================
// Step 4
// ======================================================
generate
    for (i = 0; i < IP_WIDTH; i = i + 1) begin
        wire [3:0] target_rank;
        wire [3:0] masked_char [0:7];
        wire [3:0] or_01, or_23, or_45, or_67;
        wire [3:0] or_0123, or_4567;

        assign target_rank = IP_WIDTH - 1 - i;

        for (k = 0; k < 8; k = k + 1) begin
            if (k < IP_WIDTH) begin
                assign masked_char[k] = (rank[k] == target_rank) ? char[k] : 4'd0;
            end 
            else begin
                assign masked_char[k] = 4'd0;
            end
        end
        
        assign or_01 = masked_char[0] | masked_char[1];
        assign or_23 = masked_char[2] | masked_char[3];
        assign or_45 = masked_char[4] | masked_char[5];
        assign or_67 = masked_char[6] | masked_char[7];

        assign or_0123 = or_01 | or_23;
        assign or_4567 = or_45 | or_67;

        assign OUT_character[(i*4)+3 : (i*4)] = or_0123 | or_4567;
    end
endgenerate
endmodule