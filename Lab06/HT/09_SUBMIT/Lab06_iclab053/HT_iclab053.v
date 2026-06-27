//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on

module HT(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================

localparam [1:0] IDLE  = 2'b00,
                 LOAD  = 2'b01,
                 BUILD = 2'b10,
                 TX    = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;

reg [2:0] load_cnt;
reg       mode_sel_reg;
reg [2:0] build_cnt;

reg [4:0] weight_reg [0:7];

reg [9:0] leaf_q [0:7];
reg [9:0] int_q  [0:6];
reg [7:0] int_m  [0:6];

reg [7:0] hc_val [0:7];
reg [2:0] hc_len [0:7];

reg [2:0] tx_char_cnt;
reg [2:0] tx_bit_cnt;
reg [7:0] tx_shift_reg;

wire [4:0]  w_array [0:7];
wire [39:0] sort_in_w_pack;
wire [31:0] sort_in_c_pack;
wire [31:0] sort_out_c_pack;
wire [2:0]  sorted_c [0:7];

wire [9:0]  leaf_top_0, leaf_top_1;
wire [9:0]  int_top_0, int_top_1;
wire [7:0]  leaf_mask_0, leaf_mask_1;
wire [7:0]  int_mask_0, int_mask_1;

wire [9:0]  min_node_1, min_node_2;
wire [7:0]  min_mask_1, min_mask_2;
wire [1:0]  pop_leaf_num, pop_int_num;

reg  [9:0]  leaf_q_nxt [0:7];
reg  [9:0]  pop_int_q  [0:6];
reg  [7:0]  pop_int_m  [0:6];

wire [9:0]  new_int_node;
wire [7:0]  new_int_mask;
wire [6:0]  insert_cmp;

reg  [9:0]  int_q_nxt [0:6];
reg  [7:0]  int_m_nxt [0:6];

reg  [2:0]  curr_tx_char;
wire [7:0]  target_code;
wire [2:0]  target_len;
wire [3:0]  shift_amt;
wire [7:0]  aligned_code;

wire [7:0]  early_hc_val;
wire [2:0]  early_hc_len;
wire [3:0]  early_shift_amt;
wire [7:0]  early_aligned;

integer i, j;

// ===============================================================
// Design
// ===============================================================

assign w_array[7] = weight_reg[7];
assign w_array[6] = weight_reg[6];
assign w_array[5] = weight_reg[5];
assign w_array[4] = weight_reg[4];
assign w_array[3] = weight_reg[3];
assign w_array[2] = weight_reg[2];
assign w_array[1] = weight_reg[1];
assign w_array[0] = (current_state == LOAD && load_cnt == 3'd7) ? {2'b00, in_weight} : weight_reg[0];

assign sort_in_w_pack = {w_array[7], w_array[6], w_array[5], w_array[4], w_array[3], w_array[2], w_array[1], w_array[0]};
assign sort_in_c_pack = {4'd7, 4'd6, 4'd5, 4'd4, 4'd3, 4'd2, 4'd1, 4'd0};

SORT_IP #(.IP_WIDTH(8)) u_sort_inst (
    .IN_character(sort_in_c_pack),
    .IN_weight(sort_in_w_pack),
    .OUT_character(sort_out_c_pack)
);

assign sorted_c[0] = sort_out_c_pack[30:28];
assign sorted_c[1] = sort_out_c_pack[26:24];
assign sorted_c[2] = sort_out_c_pack[22:20];
assign sorted_c[3] = sort_out_c_pack[18:16];
assign sorted_c[4] = sort_out_c_pack[14:12];
assign sorted_c[5] = sort_out_c_pack[10:8];
assign sorted_c[6] = sort_out_c_pack[6:4];
assign sorted_c[7] = sort_out_c_pack[2:0];

//
assign leaf_top_0  = leaf_q[0];
assign leaf_top_1  = leaf_q[1];
assign int_top_0   = int_q[0];
assign int_top_1   = int_q[1];

assign leaf_mask_0 = 8'd1 << (~leaf_top_0[2:0]);
assign leaf_mask_1 = 8'd1 << (~leaf_top_1[2:0]);
assign int_mask_0  = int_m[0];
assign int_mask_1  = int_m[1];

MIN_FINDER u_min_finder (
    .leaf_0(leaf_top_0),
    .leaf_1(leaf_top_1),
    .int_0(int_top_0),
    .int_1(int_top_1),
    .leaf_m0(leaf_mask_0),
    .leaf_m1(leaf_mask_1),
    .int_m0(int_mask_0),
    .int_m1(int_mask_1),
    .min_node_1(min_node_1),
    .min_node_2(min_node_2),
    .min_mask_1(min_mask_1),
    .min_mask_2(min_mask_2),
    .pop_leaf_num(pop_leaf_num),
    .pop_int_num(pop_int_num)
);

//
always @(*) begin
    next_state = current_state;
    case (current_state)
        IDLE:  if (in_valid) next_state = LOAD;
        LOAD:  if (load_cnt == 3'd7) next_state = BUILD;
        BUILD: if (build_cnt == 3'd6) next_state = TX;
        TX:    if (tx_bit_cnt == 3'd0 && tx_char_cnt == 3'd5) next_state = IDLE;
        default:  next_state = IDLE;
    endcase
end

always @(*) begin
    for (j = 0; j < 8; j = j + 1) leaf_q_nxt[j] = leaf_q[j];
    case (pop_leaf_num)
        2'd1: begin
            for (j = 0; j < 7; j = j + 1) leaf_q_nxt[j] = leaf_q[j+1];
            leaf_q_nxt[7] = 10'h3FF;
        end
        2'd2: begin
            for (j = 0; j < 6; j = j + 1) leaf_q_nxt[j] = leaf_q[j+2];
            leaf_q_nxt[6] = 10'h3FF;
            leaf_q_nxt[7] = 10'h3FF;
        end
        default: ;
    endcase
end

always @(*) begin
    for (j = 0; j < 7; j = j + 1) begin
        pop_int_q[j] = 10'h3FF;
        pop_int_m[j] = 8'd0;
    end
    case (pop_int_num)
        2'd0: for (j = 0; j < 7; j = j + 1) begin 
            pop_int_q[j] = int_q[j];   pop_int_m[j] = int_m[j];   end
        2'd1: for (j = 0; j < 6; j = j + 1) begin 
            pop_int_q[j] = int_q[j+1]; pop_int_m[j] = int_m[j+1]; 
        end
        2'd2: for (j = 0; j < 5; j = j + 1) begin 
            pop_int_q[j] = int_q[j+2]; pop_int_m[j] = int_m[j+2]; 
        end
        default: ;
    endcase
end

assign new_int_node = { min_node_1[9:4] + min_node_2[9:4], 4'd7 - {1'b0, build_cnt} };
assign new_int_mask = min_mask_1 | min_mask_2; 

genvar g_idx;
generate
    for (g_idx = 0; g_idx < 7; g_idx = g_idx + 1) begin : gen_cmp
        assign insert_cmp[g_idx] = (new_int_node < pop_int_q[g_idx]);
    end
endgenerate

always @(*) begin
    for (j = 0; j < 7; j = j + 1) begin
        int_q_nxt[j] = pop_int_q[j];
        int_m_nxt[j] = pop_int_m[j];
    end
    
    if (insert_cmp[0]) begin
        int_q_nxt[0] = new_int_node; int_m_nxt[0] = new_int_mask;
        for(j = 1; j < 7; j = j + 1) begin 
            int_q_nxt[j] = pop_int_q[j-1]; int_m_nxt[j] = pop_int_m[j-1]; 
        end
    end 
    else if (insert_cmp[1]) begin
        int_q_nxt[1] = new_int_node; int_m_nxt[1] = new_int_mask;
        for(j = 2; j < 7; j = j + 1) begin 
            int_q_nxt[j] = pop_int_q[j-1]; int_m_nxt[j] = pop_int_m[j-1]; 
        end
    end 
    else if (insert_cmp[2]) begin
        int_q_nxt[2] = new_int_node; int_m_nxt[2] = new_int_mask;
        for(j = 3; j < 7; j = j + 1) begin 
            int_q_nxt[j] = pop_int_q[j-1]; int_m_nxt[j] = pop_int_m[j-1]; 
        end
    end 
    else if (insert_cmp[3]) begin
        int_q_nxt[3] = new_int_node; int_m_nxt[3] = new_int_mask;
        for(j = 4; j < 7; j = j + 1) begin 
            int_q_nxt[j] = pop_int_q[j-1]; int_m_nxt[j] = pop_int_m[j-1]; 
        end
    end 
    else if (insert_cmp[4]) begin
        int_q_nxt[4] = new_int_node; int_m_nxt[4] = new_int_mask;
        for(j = 5; j < 7; j = j + 1) begin 
            int_q_nxt[j] = pop_int_q[j-1]; int_m_nxt[j] = pop_int_m[j-1]; 
        end
    end 
    else if (insert_cmp[5]) begin
        int_q_nxt[5] = new_int_node; int_m_nxt[5] = new_int_mask;
        int_q_nxt[6] = pop_int_q[5]; int_m_nxt[6] = pop_int_m[5];
    end 
    else if (insert_cmp[6]) begin
        int_q_nxt[6] = new_int_node; int_m_nxt[6] = new_int_mask;
    end
end

always @(*) begin
    if (mode_sel_reg) begin
        case (tx_char_cnt)
            3'd0: curr_tx_char = 3'd3;
            3'd1: curr_tx_char = 3'd5;
            3'd2: curr_tx_char = 3'd2;
            3'd3: curr_tx_char = 3'd7;
            3'd4: curr_tx_char = 3'd6;
            default: curr_tx_char = 3'd0;
        endcase
    end 
    else begin
        case (tx_char_cnt)
            3'd0: curr_tx_char = 3'd3;
            3'd1: curr_tx_char = 3'd2;
            3'd2: curr_tx_char = 3'd1;
            3'd3: curr_tx_char = 3'd0;
            3'd4: curr_tx_char = 3'd4;
            default: curr_tx_char = 3'd0;
        endcase
    end
end

assign target_code  = hc_val[curr_tx_char];
assign target_len   = hc_len[curr_tx_char];
assign shift_amt    = 4'd8 - {1'b0, target_len};
assign aligned_code = target_code << shift_amt;

assign early_hc_val = hc_val[3] | (min_mask_1[3] ? (8'd1 << hc_len[3]) : 8'd0);
assign early_hc_len = hc_len[3] + ((min_mask_1[3] | min_mask_2[3]) ? 3'd1 : 3'd0);
assign early_shift_amt = 4'd8 - {1'b0, early_hc_len};
assign early_aligned   = early_hc_val << early_shift_amt;

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
        current_state <= IDLE;
    else        
        current_state <= next_state;
end

// 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_cnt     <= 3'd0;
        build_cnt    <= 3'd0;
        mode_sel_reg <= 1'b0;
    end 
    else begin
        if (current_state == IDLE) begin
            load_cnt <= 3'd0;
            if (in_valid) begin
                load_cnt     <= 3'd1;
                mode_sel_reg <= out_mode;
            end
        end 
        else if (current_state == LOAD) begin
            if (in_valid) 
                load_cnt <= load_cnt + 3'd1;
            if (load_cnt == 3'd7) 
                build_cnt <= 3'd0;
        end 
        else if (current_state == BUILD) begin
            build_cnt <= build_cnt + 3'd1;
        end
    end
end

// 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 8; i = i + 1) weight_reg[i] <= 5'd0;
    end 
    else begin
        if (current_state == IDLE && in_valid) begin
            weight_reg[7] <= {2'b00, in_weight};
        end 
        else if (current_state == LOAD && in_valid) begin
            weight_reg[7 - load_cnt] <= {2'b00, in_weight};
        end
    end
end

// 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 8; i = i + 1) leaf_q[i] <= 10'h3FF;
    end 
    else begin
        if (current_state == LOAD && load_cnt == 3'd7) begin
            leaf_q[0] <= { 1'b0, w_array[sorted_c[7]], 4'd15 - {1'b0, sorted_c[7]} };
            leaf_q[1] <= { 1'b0, w_array[sorted_c[6]], 4'd15 - {1'b0, sorted_c[6]} };
            leaf_q[2] <= { 1'b0, w_array[sorted_c[5]], 4'd15 - {1'b0, sorted_c[5]} };
            leaf_q[3] <= { 1'b0, w_array[sorted_c[4]], 4'd15 - {1'b0, sorted_c[4]} };
            leaf_q[4] <= { 1'b0, w_array[sorted_c[3]], 4'd15 - {1'b0, sorted_c[3]} };
            leaf_q[5] <= { 1'b0, w_array[sorted_c[2]], 4'd15 - {1'b0, sorted_c[2]} };
            leaf_q[6] <= { 1'b0, w_array[sorted_c[1]], 4'd15 - {1'b0, sorted_c[1]} };
            leaf_q[7] <= { 1'b0, w_array[sorted_c[0]], 4'd15 - {1'b0, sorted_c[0]} };
        end 
        else if (current_state == BUILD) begin
            for (i = 0; i < 8; i = i + 1) leaf_q[i] <= leaf_q_nxt[i];
        end
    end
end

// 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 7; i = i + 1) begin
            int_q[i]  <= 10'h3FF;
            int_m[i]  <= 8'd0;
        end
        for (i = 0; i < 8; i = i + 1) begin
            hc_val[i] <= 8'd0;
            hc_len[i] <= 3'd0;
        end
    end 
    else begin
        if (current_state == LOAD && load_cnt == 3'd7) begin
            for (i = 0; i < 7; i = i + 1) begin
                int_q[i] <= 10'h3FF;
                int_m[i] <= 8'd0;
            end
            for (i = 0; i < 8; i = i + 1) begin
                hc_val[i] <= 8'd0;
                hc_len[i] <= 3'd0;
            end
        end 
        else if (current_state == BUILD) begin
            for (i = 0; i < 7; i = i + 1) begin
                int_q[i] <= int_q_nxt[i];
                int_m[i] <= int_m_nxt[i];
            end
            for (i = 0; i < 8; i = i + 1) begin
                if (min_mask_1[i]) begin
                    hc_val[i] <= hc_val[i] | (8'd1 << hc_len[i]);
                    hc_len[i] <= hc_len[i] + 3'd1;
                end 
                else if (min_mask_2[i]) begin
                    hc_len[i] <= hc_len[i] + 3'd1;
                end
            end
        end
    end
end

//Output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid    <= 1'b0;
        out_code     <= 1'b0;
        tx_shift_reg <= 8'd0;
        tx_bit_cnt   <= 3'd0;
        tx_char_cnt  <= 3'd0;
    end 
    else begin
        if (current_state == BUILD && build_cnt == 3'd6) begin
            out_valid    <= 1'b1;
            out_code     <= early_aligned[7];
            tx_shift_reg <= early_aligned << 1;
            tx_bit_cnt   <= early_hc_len - 3'd1;
            tx_char_cnt  <= 3'd1;
        end 
        else if (current_state == TX) begin
            if (tx_bit_cnt > 3'd0) begin
                out_valid    <= 1'b1;
                out_code     <= tx_shift_reg[7];
                tx_shift_reg <= tx_shift_reg << 1;
                tx_bit_cnt   <= tx_bit_cnt - 3'd1;
            end 
            else begin
                if (tx_char_cnt < 3'd5) begin
                    out_valid    <= 1'b1;
                    out_code     <= aligned_code[7];
                    tx_shift_reg <= aligned_code << 1;
                    tx_bit_cnt   <= target_len - 3'd1;
                    tx_char_cnt  <= tx_char_cnt + 3'd1;
                end 
                else begin
                    out_valid    <= 1'b0;
                    out_code     <= 1'b0;
                    tx_char_cnt  <= 3'd0;
                end
            end
        end 
        else begin
            out_valid    <= 1'b0;
            out_code     <= 1'b0;
            tx_char_cnt  <= 3'd0;
            tx_bit_cnt   <= 3'd0;
        end
    end
end

endmodule


module MIN_FINDER (
    input  wire [9:0] leaf_0,
    input  wire [9:0] leaf_1,
    input  wire [9:0] int_0,
    input  wire [9:0] int_1,
    input  wire [7:0] leaf_m0,
    input  wire [7:0] leaf_m1,
    input  wire [7:0] int_m0,
    input  wire [7:0] int_m1,
    output wire [9:0] min_node_1,
    output wire [9:0] min_node_2,
    output wire [7:0] min_mask_1,
    output wire [7:0] min_mask_2,
    output wire [1:0] pop_leaf_num,
    output wire [1:0] pop_int_num
);

wire cmp_L0_I0;
wire cmp_L1_I0;
wire cmp_L0_I1;

assign cmp_L0_I0 = (leaf_0 < int_0);
assign cmp_L1_I0 = (leaf_1 < int_0);
assign cmp_L0_I1 = (leaf_0 < int_1);

assign min_node_1 = cmp_L0_I0 ? leaf_0  : int_0;
assign min_mask_1 = cmp_L0_I0 ? leaf_m0 : int_m0;

assign min_node_2 = cmp_L0_I0 ? (cmp_L1_I0 ? leaf_1  : int_0)  : (cmp_L0_I1 ? leaf_0  : int_1);
assign min_mask_2 = cmp_L0_I0 ? (cmp_L1_I0 ? leaf_m1 : int_m0) : (cmp_L0_I1 ? leaf_m0 : int_m1);

assign pop_leaf_num = cmp_L0_I0 ? (cmp_L1_I0 ? 2'd2 : 2'd1) : (cmp_L0_I1 ? 2'd1 : 2'd0);
assign pop_int_num  = cmp_L0_I0 ? (cmp_L1_I0 ? 2'd0 : 2'd1) : (cmp_L0_I1 ? 2'd1 : 2'd2);

endmodule
