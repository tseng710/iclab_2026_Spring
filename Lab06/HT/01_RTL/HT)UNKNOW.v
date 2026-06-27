//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       in_valid,
    input  wire [2:0] in_weight, 
    input  wire       out_mode,
    output reg        out_valid, 
    output reg        out_code
);

localparam [2:0] IDLE  = 3'd0;
localparam [2:0] INPUT = 3'd1;
localparam [2:0] SORT  = 3'd2;
localparam [2:0] MERGE = 3'd3;
localparam [2:0] OUT   = 3'd4;

integer i;

reg  [2:0] state;
wire [2:0] n_state;
reg  [2:0] in_cnt;
reg        mode_reg;
reg  [2:0] merge_cnt;

reg  [4:0] in_weights_reg [0:7];
reg  [9:0] q1_val [0:7];
reg  [9:0] q2_val [0:6];
reg  [7:0] q2_msk [0:6];
reg  [7:0] codes  [0:7];
reg  [2:0] lens   [0:7];

reg  [2:0] out_char_cnt;
reg  [2:0] out_bit_cnt;
reg  [7:0] out_shift;

wire [4:0]  cur_w0 = {2'b00, in_weight};
wire [39:0] sort_in_weight = {in_weights_reg[7], in_weights_reg[6], in_weights_reg[5], in_weights_reg[4], in_weights_reg[3], in_weights_reg[2], in_weights_reg[1], in_weights_reg[0]};
wire [31:0] sort_in_char   = {4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};
wire [31:0] sort_out_char;

SORT_IP #(.IP_WIDTH(8)) u_sort (
    .IN_character(sort_in_char),
    .IN_weight(sort_in_weight),
    .OUT_character(sort_out_char)
);

wire [2:0] s_ch0 = sort_out_char[30:28];
wire [2:0] s_ch1 = sort_out_char[26:24];
wire [2:0] s_ch2 = sort_out_char[22:20];
wire [2:0] s_ch3 = sort_out_char[18:16];
wire [2:0] s_ch4 = sort_out_char[14:12];
wire [2:0] s_ch5 = sort_out_char[10:8];
wire [2:0] s_ch6 = sort_out_char[6:4];
wire [2:0] s_ch7 = sort_out_char[2:0];

wire [9:0] v1_0 = q1_val[0];
wire [9:0] v1_1 = q1_val[1];
wire [9:0] v2_0 = q2_val[0];
wire [9:0] v2_1 = q2_val[1];

wire [7:0] m1_0 = 8'd1 << (~v1_0[2:0]);
wire [7:0] m1_1 = 8'd1 << (~v1_1[2:0]);
wire [7:0] m2_0 = q2_msk[0];
wire [7:0] m2_1 = q2_msk[1];

wire q1_w_m1  = (v1_0 < v2_0);
wire [9:0] min1_val = q1_w_m1 ? v1_0 : v2_0;
wire [7:0] min1_msk = q1_w_m1 ? m1_0 : m2_0;

wire [9:0] cand_v2  = q1_w_m1 ? v1_1 : v1_0;
wire [7:0] cand_m2  = q1_w_m1 ? m1_1 : m1_0;

wire [9:0] cand_v3  = q1_w_m1 ? v2_0 : v2_1;
wire [7:0] cand_m3  = q1_w_m1 ? m2_0 : m2_1;

wire q_w_m2   = (cand_v2 < cand_v3);
wire [9:0] min2_val = q_w_m2 ? cand_v2 : cand_v3;
wire [7:0] min2_msk = q_w_m2 ? cand_m2 : cand_m3;

wire [1:0] rem_q1 = q1_w_m1 ? (q_w_m2 ? 2'd2 : 2'd1) : (q_w_m2 ? 2'd1 : 2'd0);
wire [1:0] rem_q2 = 2'd2 - rem_q1;

wire [9:0] nxt_q1_0 = (rem_q1 == 2'd2) ? q1_val[2] : ((rem_q1 == 2'd1) ? q1_val[1] : q1_val[0]);
wire [9:0] nxt_q1_1 = (rem_q1 == 2'd2) ? q1_val[3] : ((rem_q1 == 2'd1) ? q1_val[2] : q1_val[1]);
wire [9:0] nxt_q1_2 = (rem_q1 == 2'd2) ? q1_val[4] : ((rem_q1 == 2'd1) ? q1_val[3] : q1_val[2]);
wire [9:0] nxt_q1_3 = (rem_q1 == 2'd2) ? q1_val[5] : ((rem_q1 == 2'd1) ? q1_val[4] : q1_val[3]);
wire [9:0] nxt_q1_4 = (rem_q1 == 2'd2) ? q1_val[6] : ((rem_q1 == 2'd1) ? q1_val[5] : q1_val[4]);
wire [9:0] nxt_q1_5 = (rem_q1 == 2'd2) ? q1_val[7] : ((rem_q1 == 2'd1) ? q1_val[6] : q1_val[5]);
wire [9:0] nxt_q1_6 = (rem_q1 == 2'd2) ? 10'h3FF   : ((rem_q1 == 2'd1) ? q1_val[7] : q1_val[6]);
wire [9:0] nxt_q1_7 = (rem_q1 == 2'd2) ? 10'h3FF   : ((rem_q1 == 2'd1) ? 10'h3FF   : q1_val[7]);

wire [9:0] rq2_v0 = (rem_q2 == 2'd2) ? q2_val[2] : ((rem_q2 == 2'd1) ? q2_val[1] : q2_val[0]);
wire [7:0] rq2_m0 = (rem_q2 == 2'd2) ? q2_msk[2] : ((rem_q2 == 2'd1) ? q2_msk[1] : q2_msk[0]);
wire [9:0] rq2_v1 = (rem_q2 == 2'd2) ? q2_val[3] : ((rem_q2 == 2'd1) ? q2_val[2] : q2_val[1]);
wire [7:0] rq2_m1 = (rem_q2 == 2'd2) ? q2_msk[3] : ((rem_q2 == 2'd1) ? q2_msk[2] : q2_msk[1]);
wire [9:0] rq2_v2 = (rem_q2 == 2'd2) ? q2_val[4] : ((rem_q2 == 2'd1) ? q2_val[3] : q2_val[2]);
wire [7:0] rq2_m2 = (rem_q2 == 2'd2) ? q2_msk[4] : ((rem_q2 == 2'd1) ? q2_msk[3] : q2_msk[2]);
wire [9:0] rq2_v3 = (rem_q2 == 2'd2) ? q2_val[5] : ((rem_q2 == 2'd1) ? q2_val[4] : q2_val[3]);
wire [7:0] rq2_m3 = (rem_q2 == 2'd2) ? q2_msk[5] : ((rem_q2 == 2'd1) ? q2_msk[4] : q2_msk[3]);
wire [9:0] rq2_v4 = (rem_q2 == 2'd2) ? q2_val[6] : ((rem_q2 == 2'd1) ? q2_val[5] : q2_val[4]);
wire [7:0] rq2_m4 = (rem_q2 == 2'd2) ? q2_msk[6] : ((rem_q2 == 2'd1) ? q2_msk[5] : q2_msk[4]);
wire [9:0] rq2_v5 = (rem_q2 == 2'd2) ? 10'h3FF   : ((rem_q2 == 2'd1) ? q2_val[6] : q2_val[5]);
wire [7:0] rq2_m5 = (rem_q2 == 2'd2) ? 8'd0      : ((rem_q2 == 2'd1) ? q2_msk[6] : q2_msk[5]);
wire [9:0] rq2_v6 = (rem_q2 == 2'd2) ? 10'h3FF   : ((rem_q2 == 2'd1) ? 10'h3FF   : q2_val[6]);
wire [7:0] rq2_m6 = (rem_q2 == 2'd2) ? 8'd0      : ((rem_q2 == 2'd1) ? 8'd0      : q2_msk[6]);

wire [9:0] new_val = { min1_val[9:4] + min2_val[9:4], 1'b0, ~merge_cnt };
wire [7:0] new_msk = min1_msk | min2_msk;

wire c0 = (new_val < rq2_v0);
wire c1 = (new_val < rq2_v1);
wire c2 = (new_val < rq2_v2);
wire c3 = (new_val < rq2_v3);
wire c4 = (new_val < rq2_v4);
wire c5 = (new_val < rq2_v5);
wire c6 = (new_val < rq2_v6);

wire [9:0] nxt_q2_v0 = c0 ? new_val : rq2_v0;
wire [7:0] nxt_q2_m0 = c0 ? new_msk : rq2_m0;
wire [9:0] nxt_q2_v1 = c0 ? rq2_v0 : (c1 ? new_val : rq2_v1);
wire [7:0] nxt_q2_m1 = c0 ? rq2_m0 : (c1 ? new_msk : rq2_m1);
wire [9:0] nxt_q2_v2 = c1 ? rq2_v1 : (c2 ? new_val : rq2_v2);
wire [7:0] nxt_q2_m2 = c1 ? rq2_m1 : (c2 ? new_msk : rq2_m2);
wire [9:0] nxt_q2_v3 = c2 ? rq2_v2 : (c3 ? new_val : rq2_v3);
wire [7:0] nxt_q2_m3 = c2 ? rq2_m2 : (c3 ? new_msk : rq2_m3);
wire [9:0] nxt_q2_v4 = c3 ? rq2_v3 : (c4 ? new_val : rq2_v4);
wire [7:0] nxt_q2_m4 = c3 ? rq2_m3 : (c4 ? new_msk : rq2_m4);
wire [9:0] nxt_q2_v5 = c4 ? rq2_v4 : (c5 ? new_val : rq2_v5);
wire [7:0] nxt_q2_m5 = c4 ? rq2_m4 : (c5 ? new_msk : rq2_m5);
wire [9:0] nxt_q2_v6 = c5 ? rq2_v5 : (c6 ? new_val : rq2_v6);
wire [7:0] nxt_q2_m6 = c5 ? rq2_m5 : (c6 ? new_msk : rq2_m6);

wire [7:0] dl0 = 8'd1 << lens[0];
wire [7:0] dl1 = 8'd1 << lens[1];
wire [7:0] dl2 = 8'd1 << lens[2];
wire [7:0] dl3 = 8'd1 << lens[3];
wire [7:0] dl4 = 8'd1 << lens[4];
wire [7:0] dl5 = 8'd1 << lens[5];
wire [7:0] dl6 = 8'd1 << lens[6];
wire [7:0] dl7 = 8'd1 << lens[7];

wire [2:0] char_map_0 = (out_char_cnt == 0) ? 3'd3 : (out_char_cnt == 1) ? 3'd2 : (out_char_cnt == 2) ? 3'd1 : (out_char_cnt == 3) ? 3'd0 : 3'd4;
wire [2:0] char_map_1 = (out_char_cnt == 0) ? 3'd3 : (out_char_cnt == 1) ? 3'd5 : (out_char_cnt == 2) ? 3'd2 : (out_char_cnt == 3) ? 3'd7 : 3'd6;
wire [2:0] curr_out_char = mode_reg ? char_map_1 : char_map_0;

wire [7:0] target_code   = codes[curr_out_char];
wire [2:0] target_len    = lens[curr_out_char];
wire [3:0] shift_amt     = 4'd8 - {1'b0, target_len};

wire [2:0] first_char    = mode_reg ? 3'd3 : 3'd3;
wire       early_is_m1   = min1_msk[first_char];
wire       early_is_m2   = min2_msk[first_char];
wire [7:0] early_code    = codes[first_char] | (early_is_m1 ? (8'd1 << lens[first_char]) : 8'd0);
wire [2:0] early_len     = lens[first_char] + ((early_is_m1 | early_is_m2) ? 3'd1 : 3'd0);
wire [3:0] early_shift   = 4'd8 - {1'b0, early_len};

wire [7:0] sh_in_c = (state == MERGE) ? early_code : target_code;
wire [3:0] sh_in_a = (state == MERGE) ? early_shift : shift_amt;
wire [7:0] shared_align = sh_in_c << sh_in_a;

assign n_state = (state == IDLE  && in_valid) ? INPUT :
                 (state == INPUT && in_cnt == 3'd7) ? SORT :
                 (state == SORT) ? MERGE :
                 (state == MERGE && merge_cnt == 3'd6) ? OUT :
                 (state == OUT   && out_bit_cnt == 3'd0 && out_char_cnt == 3'd5) ? IDLE :
                 state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state        <= IDLE;
        in_cnt       <= 3'd0;
        mode_reg     <= 1'b0;
        merge_cnt    <= 3'd0;
        out_valid    <= 1'b0;
        out_code     <= 1'b0;
        out_shift    <= 8'd0;
        out_bit_cnt  <= 3'd0;
        out_char_cnt <= 3'd0;
        
        for (i = 0; i < 8; i = i + 1) begin
            in_weights_reg[i] <= 5'd0;
            q1_val[i]         <= 10'h3FF;
            codes[i]          <= 8'd0;
            lens[i]           <= 3'd0;
        end
        for (i = 0; i < 7; i = i + 1) begin
            q2_val[i] <= 10'h3FF;
            q2_msk[i] <= 8'd0;
        end
    end else begin
        state <= n_state;

        if (state == IDLE) begin
            in_cnt <= 3'd0;
            if (in_valid) begin
                in_weights_reg[7] <= cur_w0;
                mode_reg          <= out_mode;
                in_cnt            <= 3'd1;
            end
        end 
        else if (state == INPUT) begin
            if (in_valid) begin
                in_weights_reg[7 - in_cnt] <= cur_w0;
                in_cnt <= in_cnt + 3'd1;
            end
        end 
        else if (state == SORT) begin
            merge_cnt <= 3'd0;
            q1_val[0] <= { 1'b0, in_weights_reg[s_ch7], 1'b1, ~s_ch7 };
            q1_val[1] <= { 1'b0, in_weights_reg[s_ch6], 1'b1, ~s_ch6 };
            q1_val[2] <= { 1'b0, in_weights_reg[s_ch5], 1'b1, ~s_ch5 };
            q1_val[3] <= { 1'b0, in_weights_reg[s_ch4], 1'b1, ~s_ch4 };
            q1_val[4] <= { 1'b0, in_weights_reg[s_ch3], 1'b1, ~s_ch3 };
            q1_val[5] <= { 1'b0, in_weights_reg[s_ch2], 1'b1, ~s_ch2 };
            q1_val[6] <= { 1'b0, in_weights_reg[s_ch1], 1'b1, ~s_ch1 };
            q1_val[7] <= { 1'b0, in_weights_reg[s_ch0], 1'b1, ~s_ch0 };
            
            for (i = 0; i < 7; i = i + 1) begin
                q2_val[i] <= 10'h3FF;
                q2_msk[i] <= 8'd0;
            end
            for (i = 0; i < 8; i = i + 1) begin
                codes[i] <= 8'd0;
                lens[i]  <= 3'd0;
            end
        end
        else if (state == MERGE) begin
            merge_cnt <= merge_cnt + 3'd1;
            
            q1_val[0] <= nxt_q1_0; q1_val[1] <= nxt_q1_1; q1_val[2] <= nxt_q1_2; q1_val[3] <= nxt_q1_3;
            q1_val[4] <= nxt_q1_4; q1_val[5] <= nxt_q1_5; q1_val[6] <= nxt_q1_6; q1_val[7] <= nxt_q1_7;
            
            q2_val[0] <= nxt_q2_v0; q2_msk[0] <= nxt_q2_m0;
            q2_val[1] <= nxt_q2_v1; q2_msk[1] <= nxt_q2_m1;
            q2_val[2] <= nxt_q2_v2; q2_msk[2] <= nxt_q2_m2;
            q2_val[3] <= nxt_q2_v3; q2_msk[3] <= nxt_q2_m3;
            q2_val[4] <= nxt_q2_v4; q2_msk[4] <= nxt_q2_m4;
            q2_val[5] <= nxt_q2_v5; q2_msk[5] <= nxt_q2_m5;
            q2_val[6] <= nxt_q2_v6; q2_msk[6] <= nxt_q2_m6;
            
            if (min1_msk[0]) begin codes[0] <= codes[0] | dl0; lens[0] <= lens[0] + 3'd1; end else if (min2_msk[0]) lens[0] <= lens[0] + 3'd1;
            if (min1_msk[1]) begin codes[1] <= codes[1] | dl1; lens[1] <= lens[1] + 3'd1; end else if (min2_msk[1]) lens[1] <= lens[1] + 3'd1;
            if (min1_msk[2]) begin codes[2] <= codes[2] | dl2; lens[2] <= lens[2] + 3'd1; end else if (min2_msk[2]) lens[2] <= lens[2] + 3'd1;
            if (min1_msk[3]) begin codes[3] <= codes[3] | dl3; lens[3] <= lens[3] + 3'd1; end else if (min2_msk[3]) lens[3] <= lens[3] + 3'd1;
            if (min1_msk[4]) begin codes[4] <= codes[4] | dl4; lens[4] <= lens[4] + 3'd1; end else if (min2_msk[4]) lens[4] <= lens[4] + 3'd1;
            if (min1_msk[5]) begin codes[5] <= codes[5] | dl5; lens[5] <= lens[5] + 3'd1; end else if (min2_msk[5]) lens[5] <= lens[5] + 3'd1;
            if (min1_msk[6]) begin codes[6] <= codes[6] | dl6; lens[6] <= lens[6] + 3'd1; end else if (min2_msk[6]) lens[6] <= lens[6] + 3'd1;
            if (min1_msk[7]) begin codes[7] <= codes[7] | dl7; lens[7] <= lens[7] + 3'd1; end else if (min2_msk[7]) lens[7] <= lens[7] + 3'd1;

            if (merge_cnt == 3'd6) begin
                out_valid    <= 1'b1;
                out_code     <= shared_align[7];
                out_shift    <= shared_align << 1;
                out_bit_cnt  <= early_len - 3'd1;
                out_char_cnt <= 3'd1; 
            end
        end 
        else if (state == OUT) begin
            if (out_bit_cnt > 3'd0) begin
                out_valid   <= 1'b1;
                out_code    <= out_shift[7];
                out_shift   <= out_shift << 1;
                out_bit_cnt <= out_bit_cnt - 3'd1;
            end else begin
                if (out_char_cnt < 3'd5) begin
                    out_valid    <= 1'b1;
                    out_code     <= shared_align[7];
                    out_shift    <= shared_align << 1;
                    out_bit_cnt  <= target_len - 3'd1;
                    out_char_cnt <= out_char_cnt + 3'd1;
                end else begin
                    out_valid    <= 1'b0;
                    out_code     <= 1'b0;
                    out_char_cnt <= 3'd0;
                end
            end
        end 
        else begin
            out_valid    <= 1'b0;
            out_code     <= 1'b0;
            out_char_cnt <= 3'd0;
            out_bit_cnt  <= 3'd0;
        end
    end
end

endmodule