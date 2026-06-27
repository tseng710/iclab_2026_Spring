//###############################################################################################
//***********************************************************************************************
//    File Name   : SORT_IP.v
//    Module Name : SORT_IP
//***********************************************************************************************
//###############################################################################################

module SORT_IP #(parameter IP_WIDTH = 3)(
    // Input signals
    IN_character,
    IN_weight,
    // Output signals
    OUT_character
);

// ======================================================
// Port Declarations
// ======================================================
input  [IP_WIDTH*4-1:0] IN_character;
input  [IP_WIDTH*5-1:0] IN_weight;
output [IP_WIDTH*4-1:0] OUT_character;

// ======================================================
// Internal Signal Declarations
// ======================================================
wire [4:0]          weight_arr [0:IP_WIDTH-1];
wire [3:0]          char_arr   [0:IP_WIDTH-1];
wire [8:0]          val        [0:IP_WIDTH-1];

wire [IP_WIDTH-1:0] cmp        [0:IP_WIDTH-1];
wire [7:0]          padded_cmp [0:IP_WIDTH-1];
wire [3:0]          rank       [0:IP_WIDTH-1];

wire [3:0]          out_mux    [0:IP_WIDTH-1];

genvar gi;
genvar gj;

// ======================================================
// Step 1: Unpack Inputs and Form Comparison Values
// ======================================================
// Concatenate weight and character. 
// This inherently solves the tie-breaker condition:
// If weights are equal, the larger character value takes precedence.
generate
    for (gi = 0; gi < IP_WIDTH; gi = gi + 1) begin : gen_val
        assign char_arr[gi]   = IN_character[(gi*4)+3 : (gi*4)];
        assign weight_arr[gi] = IN_weight[(gi*5)+4 : (gi*5)];
        assign val[gi]        = {weight_arr[gi], char_arr[gi]};
    end
endgenerate

// ======================================================
// Step 2: Comparator Matrix
// ======================================================
// Compare each pair. To optimize area, only instantiate
// half of the matrix. The other half uses the inverted result.
// Diagonal elements are hardwired to 0.
generate
    for (gi = 0; gi < IP_WIDTH; gi = gi + 1) begin : gen_cmp_row
        for (gj = 0; gj < IP_WIDTH; gj = gj + 1) begin : gen_cmp_col
            if (gi == gj) begin
                assign cmp[gi][gj] = 1'b0;
            end 
            else if (gi > gj) begin
                assign cmp[gi][gj] = (val[gi] < val[gj]);
            end 
            else begin
                assign cmp[gi][gj] = ~cmp[gj][gi];
            end
        end
    end
endgenerate

// ======================================================
// Step 3: Rank Calculation (Combinational Adder Tree)
// ======================================================
// Pad the comparator array to 8 bits to allow a fixed-width
// parallel adder tree, helping synthesis tools optimize easily.
generate
    for (gi = 0; gi < IP_WIDTH; gi = gi + 1) begin : gen_pad_cmp
        for (gj = 0; gj < 8; gj = gj + 1) begin : gen_pad_cmp_inner
            if (gj < IP_WIDTH) begin
                assign padded_cmp[gi][gj] = cmp[gi][gj];
            end 
            else begin
                assign padded_cmp[gi][gj] = 1'b0;
            end
        end
        
        // Sum the row to find the rank.
        // Rank 0 means largest (0 elements are strictly greater).
        assign rank[gi] = padded_cmp[gi][0] + padded_cmp[gi][1] + 
                          padded_cmp[gi][2] + padded_cmp[gi][3] + 
                          padded_cmp[gi][4] + padded_cmp[gi][5] + 
                          padded_cmp[gi][6] + padded_cmp[gi][7];
    end
endgenerate

// ======================================================
// Step 4: Output Multiplexing (Sorting by Rank)
// ======================================================
// For each output position, find the character whose rank 
// matches the position index. Use one-hot OR multiplexing.
generate
    for (gi = 0; gi < IP_WIDTH; gi = gi + 1) begin : gen_out_pos
        wire [3:0] match_char   [0:IP_WIDTH-1];
        wire [3:0] padded_match [0:7];

        for (gj = 0; gj < IP_WIDTH; gj = gj + 1) begin : gen_match
            assign match_char[gj] = (rank[gj] == gi) ? char_arr[gj] : 4'd0;
        end

        for (gj = 0; gj < 8; gj = gj + 1) begin : gen_pad_match
            if (gj < IP_WIDTH) begin
                assign padded_match[gj] = match_char[gj];
            end 
            else begin
                assign padded_match[gj] = 4'd0;
            end
        end

        // Parallel OR reduction
        assign out_mux[gi] = padded_match[0] | padded_match[1] | 
                             padded_match[2] | padded_match[3] | 
                             padded_match[4] | padded_match[5] | 
                             padded_match[6] | padded_match[7];
    end
endgenerate

// ======================================================
// Output Assignment
// ======================================================
// Map the multiplexed results to the flat output port.
// Rank 0 is the MSB side (left-most), so position 0 maps
// to the highest bits of OUT_character.
generate
    for (gi = 0; gi < IP_WIDTH; gi = gi + 1) begin : gen_out_assign
        assign OUT_character[ ((IP_WIDTH - 1 - gi)*4) + 3 : ((IP_WIDTH - 1 - gi)*4) ] = out_mux[gi];
    end
endgenerate

endmodule