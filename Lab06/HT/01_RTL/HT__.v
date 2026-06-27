// synopsys translate_off
`include "SORT_IP.v"
// synopsys translate_on

module FIND_MIN_ADD (
    input  wire [9:0] v1_0, v1_1, v2_0, v2_1,
    input  wire [7:0] m1_0, m1_1, m2_0, m2_1,
    input  wire [2:0] m_step,
    output wire [9:0] new_node,
    output wire [7:0] new_msk,
    output wire [7:0] m1_msk,
    output wire [7:0] m2_msk,
    output wire [1:0] pop1,
    output wire [1:0] pop2
);
    wire sel_1 = (v1_0 < v2_0);
    wire [9:0] m1_v = sel_1 ? v1_0 : v2_0;
    assign m1_msk = sel_1 ? m1_0 : m2_0;

    wire [9:0] c2_v = sel_1 ? v1_1 : v1_0;
    wire [7:0] c2_m = sel_1 ? m1_1 : m1_0;
    wire [9:0] c3_v = sel_1 ? v2_0 : v2_1;
    wire [7:0] c3_m = sel_1 ? m2_0 : m2_1;

    wire sel_2 = (c2_v < c3_v);
    wire [9:0] m2_v = sel_2 ? c2_v : c3_v;
    assign m2_msk = sel_2 ? c2_m : c3_m;

    assign pop1 = sel_1 ? (sel_2 ? 2'd2 : 2'd1) : (sel_2 ? 2'd1 : 2'd0);
    assign pop2 = sel_1 ? (sel_2 ? 2'd0 : 2'd1) : (sel_2 ? 2'd1 : 2'd2);

    assign new_node = { m1_v[9:4] + m2_v[9:4], 1'b0, ~m_step };
    assign new_msk  = m1_msk | m2_msk;
endmodule

module SHIFT_INSERT (
    input  wire [9:0] nv,
    input  wire [7:0] nm,
    input  wire [1:0] p2,
    input  wire [9:0] q2_v0, q2_v1, q2_v2, q2_v3, q2_v4, q2_v5, q2_v6,
    input  wire [7:0] q2_m0, q2_m1, q2_m2, q2_m3, q2_m4, q2_m5, q2_m6,
    output wire [9:0] n_v0, n_v1, n_v2, n_v3, n_v4, n_v5, n_v6,
    output wire [7:0] n_m0, n_m1, n_m2, n_m3, n_m4, n_m5, n_m6
);
    wire [9:0] t_v0 = (p2 == 2) ? q2_v2 : ((p2 == 1) ? q2_v1 : q2_v0);
    wire [7:0] t_m0 = (p2 == 2) ? q2_m2 : ((p2 == 1) ? q2_m1 : q2_m0);
    wire [9:0] t_v1 = (p2 == 2) ? q2_v3 : ((p2 == 1) ? q2_v2 : q2_v1);
    wire [7:0] t_m1 = (p2 == 2) ? q2_m3 : ((p2 == 1) ? q2_m2 : q2_m1);
    wire [9:0] t_v2 = (p2 == 2) ? q2_v4 : ((p2 == 1) ? q2_v3 : q2_v2);
    wire [7:0] t_m2 = (p2 == 2) ? q2_m4 : ((p2 == 1) ? q2_m3 : q2_m2);
    wire [9:0] t_v3 = (p2 == 2) ? q2_v5 : ((p2 == 1) ? q2_v4 : q2_v3);
    wire [7:0] t_m3 = (p2 == 2) ? q2_m5 : ((p2 == 1) ? q2_m4 : q2_m3);
    wire [9:0] t_v4 = (p2 == 2) ? q2_v6 : ((p2 == 1) ? q2_v5 : q2_v4);
    wire [7:0] t_m4 = (p2 == 2) ? q2_m6 : ((p2 == 1) ? q2_m5 : q2_m4);
    wire [9:0] t_v5 = (p2 == 2) ? 10'h3FF : ((p2 == 1) ? q2_v6 : q2_v5);
    wire [7:0] t_m5 = (p2 == 2) ? 8'd0    : ((p2 == 1) ? q2_m6 : q2_m5);
    wire [9:0] t_v6 = (p2 == 2) ? 10'h3FF : ((p2 == 1) ? 10'h3FF : q2_v6);
    wire [7:0] t_m6 = (p2 == 2) ? 8'd0    : ((p2 == 1) ? 8'd0    : q2_m6);

    wire c0 = (nv < t_v0); wire c1 = (nv < t_v1); wire c2 = (nv < t_v2);
    wire c3 = (nv < t_v3); wire c4 = (nv < t_v4); wire c5 = (nv < t_v5);
    wire c6 = (nv < t_v6);

    assign n_v0 = c0 ? nv : t_v0; assign n_m0 = c0 ? nm : t_m0;
    assign n_v1 = c0 ? t_v0 : (c1 ? nv : t_v1); assign n_m1 = c0 ? t_m0 : (c1 ? nm : t_m1);
    assign n_v2 = c1 ? t_v1 : (c2 ? nv : t_v2); assign n_m2 = c1 ? t_m1 : (c2 ? nm : t_m2);
    assign n_v3 = c2 ? t_v2 : (c3 ? nv : t_v3); assign n_m3 = c2 ? t_m2 : (c3 ? nm : t_m3);
    assign n_v4 = c3 ? t_v3 : (c4 ? nv : t_v4); assign n_m4 = c3 ? t_m3 : (c4 ? nm : t_m4);
    assign n_v5 = c4 ? t_v4 : (c5 ? nv : t_v5); assign n_m5 = c4 ? t_m4 : (c5 ? nm : t_m5);
    assign n_v6 = c5 ? t_v5 : (c6 ? nv : t_v6); assign n_m6 = c5 ? t_m5 : (c6 ? nm : t_m6);
endmodule

module HT(
    input  clk,
    input  rst_n,
    input  in_valid,
    input  [2:0] in_weight, 
    input  out_mode,
    output reg out_valid, 
    output reg out_code
);

parameter IDLE  = 3'd0;
parameter IN    = 3'd1;
parameter SORT1 = 3'd2;
parameter SORT2 = 3'd3;
parameter MRG   = 3'd4;
parameter OUT   = 3'd5;

reg [2:0] state, n_state;
reg [2:0] in_cnt;
reg mode_flag;
reg [2:0] m_step;
reg m_phase;
reg [7:0] out_sft;
reg [2:0] bit_idx;
reg [2:0] char_idx;

reg [4:0] w_reg [0:7];
reg [2:0] s_ch_reg [0:7];

reg [9:0] q1_dat [0:7];
reg [9:0] q2_dat [0:6];
reg [7:0] q2_m_dat [0:6];
reg [7:0] hc [0:7];
reg [2:0] hl [0:7];

reg [9:0] new_node_reg;
reg [7:0] new_msk_reg;
reg [1:0] pop1_reg;
reg [1:0] pop2_reg;

wire [39:0] sw_pack = {w_reg[7], w_reg[6], w_reg[5], w_reg[4], w_reg[3], w_reg[2], w_reg[1], w_reg[0]};
wire [31:0] sc_pack = {4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};
wire [31:0] sc_out;

SORT_IP #(.IP_WIDTH(8)) u_sort (
    .IN_character(sc_pack),
    .IN_weight(sw_pack),
    .OUT_character(sc_out)
);

wire [9:0] n_node_c;
wire [7:0] n_msk_c;
wire [7:0] m1_m_c;
wire [7:0] m2_m_c;
wire [1:0] p1_c, p2_c;

FIND_MIN_ADD u_fma (
    .v1_0(q1_dat[0]), .v1_1(q1_dat[1]), .v2_0(q2_dat[0]), .v2_1(q2_dat[1]),
    .m1_0(8'd1 << (~q1_dat[0][2:0])), .m1_1(8'd1 << (~q1_dat[1][2:0])),
    .m2_0(q2_m_dat[0]), .m2_1(q2_m_dat[1]),
    .m_step(m_step),
    .new_node(n_node_c), .new_msk(n_msk_c),
    .m1_msk(m1_m_c), .m2_msk(m2_m_c),
    .pop1(p1_c), .pop2(p2_c)
);

wire [9:0] nxt_q2_v0, nxt_q2_v1, nxt_q2_v2, nxt_q2_v3, nxt_q2_v4, nxt_q2_v5, nxt_q2_v6;
wire [7:0] nxt_q2_m0, nxt_q2_m1, nxt_q2_m2, nxt_q2_m3, nxt_q2_m4, nxt_q2_m5, nxt_q2_m6;

SHIFT_INSERT u_si (
    .nv(new_node_reg), .nm(new_msk_reg), .p2(pop2_reg),
    .q2_v0(q2_dat[0]), .q2_v1(q2_dat[1]), .q2_v2(q2_dat[2]), .q2_v3(q2_dat[3]), .q2_v4(q2_dat[4]), .q2_v5(q2_dat[5]), .q2_v6(q2_dat[6]),
    .q2_m0(q2_m_dat[0]), .q2_m1(q2_m_dat[1]), .q2_m2(q2_m_dat[2]), .q2_m3(q2_m_dat[3]), .q2_m4(q2_m_dat[4]), .q2_m5(q2_m_dat[5]), .q2_m6(q2_m_dat[6]),
    .n_v0(nxt_q2_v0), .n_v1(nxt_q2_v1), .n_v2(nxt_q2_v2), .n_v3(nxt_q2_v3), .n_v4(nxt_q2_v4), .n_v5(nxt_q2_v5), .n_v6(nxt_q2_v6),
    .n_m0(nxt_q2_m0), .n_m1(nxt_q2_m1), .n_m2(nxt_q2_m2), .n_m3(nxt_q2_m3), .n_m4(nxt_q2_m4), .n_m5(nxt_q2_m5), .n_m6(nxt_q2_m6)
);

wire [9:0] nxt_q1_0 = (pop1_reg == 2) ? q1_dat[2] : ((pop1_reg == 1) ? q1_dat[1] : q1_dat[0]);
wire [9:0] nxt_q1_1 = (pop1_reg == 2) ? q1_dat[3] : ((pop1_reg == 1) ? q1_dat[2] : q1_dat[1]);
wire [9:0] nxt_q1_2 = (pop1_reg == 2) ? q1_dat[4] : ((pop1_reg == 1) ? q1_dat[3] : q1_dat[2]);
wire [9:0] nxt_q1_3 = (pop1_reg == 2) ? q1_dat[5] : ((pop1_reg == 1) ? q1_dat[4] : q1_dat[3]);
wire [9:0] nxt_q1_4 = (pop1_reg == 2) ? q1_dat[6] : ((pop1_reg == 1) ? q1_dat[5] : q1_dat[4]);
wire [9:0] nxt_q1_5 = (pop1_reg == 2) ? q1_dat[7] : ((pop1_reg == 1) ? q1_dat[6] : q1_dat[5]);
wire [9:0] nxt_q1_6 = (pop1_reg == 2) ? 10'h3FF   : ((pop1_reg == 1) ? q1_dat[7] : q1_dat[6]);
wire [9:0] nxt_q1_7 = (pop1_reg == 2) ? 10'h3FF   : ((pop1_reg == 1) ? 10'h3FF   : q1_dat[7]);

wire [7:0] d_len_0 = 8'd1 << hl[0]; wire [7:0] d_len_1 = 8'd1 << hl[1];
wire [7:0] d_len_2 = 8'd1 << hl[2]; wire [7:0] d_len_3 = 8'd1 << hl[3];
wire [7:0] d_len_4 = 8'd1 << hl[4]; wire [7:0] d_len_5 = 8'd1 << hl[5];
wire [7:0] d_len_6 = 8'd1 << hl[6]; wire [7:0] d_len_7 = 8'd1 << hl[7];

reg [2:0] curr_char;
always @(*) begin
    if(mode_flag) begin
        case(char_idx)
            0: curr_char = 3; 1: curr_char = 5; 2: curr_char = 2;
            3: curr_char = 7; 4: curr_char = 6; default: curr_char = 0;
        endcase
    end else begin
        case(char_idx)
            0: curr_char = 3; 1: curr_char = 2; 2: curr_char = 1;
            3: curr_char = 0; 4: curr_char = 4; default: curr_char = 0;
        endcase
    end
end

wire [7:0] c_hc = hc[curr_char];
wire [2:0] c_hl = hl[curr_char];
wire [7:0] shared_align = c_hc << (4'd8 - {1'b0, c_hl});

always @(*) begin
    n_state = state;
    case(state)
        IDLE:  if(in_valid) n_state = IN;
        IN:    if(in_cnt == 7) n_state = SORT1;
        SORT1: n_state = SORT2;
        SORT2: n_state = MRG;
        MRG:   if(m_step == 6 && m_phase == 1) n_state = OUT;
        OUT:   if(bit_idx == 0 && char_idx == 5) n_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) state <= IDLE;
    else       state <= n_state;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_cnt <= 0; m_step <= 0; m_phase <= 0;
        mode_flag <= 0; char_idx <= 0; bit_idx <= 0;
    end else begin
        if(state == IDLE) begin
            in_cnt <= 0;
            if(in_valid) begin
                mode_flag <= out_mode;
                in_cnt <= 1;
            end
        end else if(state == IN && in_valid) begin
            in_cnt <= in_cnt + 1;
        end else if(state == SORT1) begin
            m_step <= 0; m_phase <= 0;
        end else if(state == MRG) begin
            if(m_phase == 0) m_phase <= 1;
            else begin
                m_phase <= 0;
                m_step <= m_step + 1;
                if(m_step == 6) begin
                    char_idx <= 1;
                    bit_idx <= hl[curr_char] - 1;
                end
            end
        end else if(state == OUT) begin
            if(bit_idx > 0) bit_idx <= bit_idx - 1;
            else begin
                if(char_idx < 5) begin
                    bit_idx <= hl[curr_char] - 1;
                    char_idx <= char_idx + 1;
                end else begin
                    char_idx <= 0;
                end
            end
        end else begin
            char_idx <= 0; bit_idx <= 0;
        end
    end
end

integer i;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<8; i=i+1) w_reg[i] <= 0;
        for(i=0; i<8; i=i+1) s_ch_reg[i] <= 0;
        for(i=0; i<8; i=i+1) q1_dat[i] <= 10'h3FF;
        for(i=0; i<7; i=i+1) begin q2_dat[i] <= 10'h3FF; q2_m_dat[i] <= 0; end
        new_node_reg <= 0; new_msk_reg <= 0; pop1_reg <= 0; pop2_reg <= 0;
    end else begin
        if(state == IDLE && in_valid) begin
            w_reg[7] <= {2'b00, in_weight};
        end else if(state == IN && in_valid) begin
            w_reg[7 - in_cnt] <= {2'b00, in_weight};
        end else if(state == SORT1) begin
            s_ch_reg[0] <= sc_out[30:28]; s_ch_reg[1] <= sc_out[26:24];
            s_ch_reg[2] <= sc_out[22:20]; s_ch_reg[3] <= sc_out[18:16];
            s_ch_reg[4] <= sc_out[14:12]; s_ch_reg[5] <= sc_out[10:8];
            s_ch_reg[6] <= sc_out[6:4];   s_ch_reg[7] <= sc_out[2:0];
        end else if(state == SORT2) begin
            q1_dat[0] <= { 1'b0, w_reg[s_ch_reg[7]], 1'b1, ~s_ch_reg[7] };
            q1_dat[1] <= { 1'b0, w_reg[s_ch_reg[6]], 1'b1, ~s_ch_reg[6] };
            q1_dat[2] <= { 1'b0, w_reg[s_ch_reg[5]], 1'b1, ~s_ch_reg[5] };
            q1_dat[3] <= { 1'b0, w_reg[s_ch_reg[4]], 1'b1, ~s_ch_reg[4] };
            q1_dat[4] <= { 1'b0, w_reg[s_ch_reg[3]], 1'b1, ~s_ch_reg[3] };
            q1_dat[5] <= { 1'b0, w_reg[s_ch_reg[2]], 1'b1, ~s_ch_reg[2] };
            q1_dat[6] <= { 1'b0, w_reg[s_ch_reg[1]], 1'b1, ~s_ch_reg[1] };
            q1_dat[7] <= { 1'b0, w_reg[s_ch_reg[0]], 1'b1, ~s_ch_reg[0] };
            for(i=0; i<7; i=i+1) begin q2_dat[i] <= 10'h3FF; q2_m_dat[i] <= 0; end
        end else if(state == MRG) begin
            if(m_phase == 0) begin
                new_node_reg <= n_node_c;
                new_msk_reg  <= n_msk_c;
                pop1_reg     <= p1_c;
                pop2_reg     <= p2_c;
            end else begin
                q1_dat[0] <= nxt_q1_0; q1_dat[1] <= nxt_q1_1; q1_dat[2] <= nxt_q1_2; q1_dat[3] <= nxt_q1_3;
                q1_dat[4] <= nxt_q1_4; q1_dat[5] <= nxt_q1_5; q1_dat[6] <= nxt_q1_6; q1_dat[7] <= nxt_q1_7;
                
                q2_dat[0] <= nxt_q2_v0; q2_m_dat[0] <= nxt_q2_m0;
                q2_dat[1] <= nxt_q2_v1; q2_m_dat[1] <= nxt_q2_m1;
                q2_dat[2] <= nxt_q2_v2; q2_m_dat[2] <= nxt_q2_m2;
                q2_dat[3] <= nxt_q2_v3; q2_m_dat[3] <= nxt_q2_m3;
                q2_dat[4] <= nxt_q2_v4; q2_m_dat[4] <= nxt_q2_m4;
                q2_dat[5] <= nxt_q2_v5; q2_m_dat[5] <= nxt_q2_m5;
                q2_dat[6] <= nxt_q2_v6; q2_m_dat[6] <= nxt_q2_m6;
            end
        end
    end
end

integer k;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0; out_code <= 0; out_sft <= 0;
        for(k=0; k<8; k=k+1) begin hc[k] <= 0; hl[k] <= 0; end
    end else begin
        if(state == SORT2) begin
            for(k=0; k<8; k=k+1) begin hc[k] <= 0; hl[k] <= 0; end
        end else if(state == MRG) begin
            if(m_phase == 0) begin
                if(m1_m_c[0]) begin hc[0] <= hc[0] | d_len_0; hl[0] <= hl[0] + 1; end else if(m2_m_c[0]) hl[0] <= hl[0] + 1;
                if(m1_m_c[1]) begin hc[1] <= hc[1] | d_len_1; hl[1] <= hl[1] + 1; end else if(m2_m_c[1]) hl[1] <= hl[1] + 1;
                if(m1_m_c[2]) begin hc[2] <= hc[2] | d_len_2; hl[2] <= hl[2] + 1; end else if(m2_m_c[2]) hl[2] <= hl[2] + 1;
                if(m1_m_c[3]) begin hc[3] <= hc[3] | d_len_3; hl[3] <= hl[3] + 1; end else if(m2_m_c[3]) hl[3] <= hl[3] + 1;
                if(m1_m_c[4]) begin hc[4] <= hc[4] | d_len_4; hl[4] <= hl[4] + 1; end else if(m2_m_c[4]) hl[4] <= hl[4] + 1;
                if(m1_m_c[5]) begin hc[5] <= hc[5] | d_len_5; hl[5] <= hl[5] + 1; end else if(m2_m_c[5]) hl[5] <= hl[5] + 1;
                if(m1_m_c[6]) begin hc[6] <= hc[6] | d_len_6; hl[6] <= hl[6] + 1; end else if(m2_m_c[6]) hl[6] <= hl[6] + 1;
                if(m1_m_c[7]) begin hc[7] <= hc[7] | d_len_7; hl[7] <= hl[7] + 1; end else if(m2_m_c[7]) hl[7] <= hl[7] + 1;
            end
            if(m_step == 6 && m_phase == 1) begin
                out_valid <= 1;
                out_code  <= shared_align[7];
                out_sft   <= shared_align << 1;
            end
        end else if(state == OUT) begin
            if(bit_idx > 0) begin
                out_valid <= 1;
                out_code  <= out_sft[7];
                out_sft   <= out_sft << 1;
            end else begin
                if(char_idx < 5) begin
                    out_valid <= 1;
                    out_code  <= shared_align[7];
                    out_sft   <= shared_align << 1;
                end else begin
                    out_valid <= 0;
                    out_code  <= 0;
                end
            end
        end else begin
            out_valid <= 0;
            out_code  <= 0;
        end
    end
end

endmodule