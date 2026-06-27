module HARVESTER(
    input               clk, 
    input               rst_n,
    input               in_mode_valid,
    input               in_valid,
    input       [1:0]   in_mode,
    input       [1:0]   in_bank,
    input       [5:0]   in_src_row,
    input       [5:0]   in_dst_row,
    input       [63:0]  in_data,
    output reg          out_valid,
    output reg  [63:0]  out_data,
    
    output reg  [31:0]  aw_addr, 
    output reg          aw_valid, 
    input               aw_ready,
    output reg  [63:0]  w_data,  
    output reg          w_valid,  
    input               w_ready,
    input       [1:0]   b_resp,  
    input               b_valid,  
    output reg          b_ready,
    output reg  [31:0]  ar_addr, 
    output reg          ar_valid, 
    input               ar_ready,
    input       [63:0]  r_data,  
    input       [1:0]   r_resp, 
    input wire          r_valid, 
    output reg          r_ready
);


localparam [4:0]
    ST_IDLE = 5'd0,  ST_RD_ADDR = 5'd1,  ST_RD_EMIT = 5'd2,  ST_WR_PROC = 5'd3,
    ST_EXPR_SETUP = 5'd4,  ST_EXPR_EVAL = 5'd5,  ST_EXPR_ADDR = 5'd6,
    ST_EXPR_RESP = 5'd7,  ST_EXPR_DONE = 5'd8,  ST_SORT_LD = 5'd9,
    ST_SORT_RUN = 5'd10,  ST_SORT_ST = 5'd11,  ST_MRG_LOAD = 5'd12,
    ST_MRG_STALL = 5'd13,  ST_MRG_EXEC = 5'd14,  ST_MRG_FIN = 5'd15,
    ST_ALU_PIPE = 5'd16;

reg [4:0] fsm_state, fsm_next;
reg [1:0] mode_store, bank_store;
reg [5:0] row_src_store, row_dst_store;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) 
        mode_store <= 0;
    else if(in_mode_valid) 
        mode_store <= in_mode;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bank_store <= 0;
        row_src_store <= 0;
        row_dst_store <= 0;
    end 
    else if(in_valid && fsm_state == ST_IDLE) begin
        bank_store <= in_bank;
        row_src_store <= in_src_row;
        row_dst_store <= in_dst_row;
    end
end

reg [10:0] txn_ar, txn_r, txn_aw, txn_w, txn_b, txn_out;
reg [8:0] wr_idx;
reg [63:0] mem[0:255];

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) 
        wr_idx <= 0;
    else if(in_mode_valid) 
        wr_idx <= 0;
    else if(in_valid && mode_store == 1) 
        wr_idx <= wr_idx + 1;
end

reg [1:0] active_bank;
reg [8:0] sort_cycle;
reg toggle_phase;
reg [5:0] head[0:3];
reg [6:0] avail[0:3];
reg [8:0] loaded[0:3];

wire refill_req;
wire [1:0] refill_ba;
wire [7:0] refill_addr;

assign refill_req = (avail[0] == 0 && loaded[0] < 256) ||
                    (avail[1] == 0 && loaded[1] < 256) ||
                    (avail[2] == 0 && loaded[2] < 256) ||
                    (avail[3] == 0 && loaded[3] < 256);

assign refill_ba = (avail[0] == 0 && loaded[0] < 256) ? 2'd0 :
                   (avail[1] == 0 && loaded[1] < 256) ? 2'd1 :
                   (avail[2] == 0 && loaded[2] < 256) ? 2'd2 : 2'd3;

assign refill_addr = loaded[refill_ba][7:0] + txn_ar[7:0];

wire [31:0] key_0, key_1, key_2, key_3;
wire cmp_a, cmp_b;
wire [31:0] val_a, val_b;
wire [1:0] idx_a, idx_b;
wire cmp_final;
wire [1:0] winner;
wire [5:0] winner_ptr;
wire [63:0] winner_val;

assign key_0 = (avail[0] > 0) ? {1'b0, mem[{2'd0, head[0]}][62:32]} : 32'hFFFFFFFF;
assign key_1 = (avail[1] > 0) ? {1'b0, mem[{2'd1, head[1]}][62:32]} : 32'hFFFFFFFF;
assign key_2 = (avail[2] > 0) ? {1'b0, mem[{2'd2, head[2]}][62:32]} : 32'hFFFFFFFF;
assign key_3 = (avail[3] > 0) ? {1'b0, mem[{2'd3, head[3]}][62:32]} : 32'hFFFFFFFF;

assign cmp_a = (key_0 <= key_1);
assign cmp_b = (key_2 <= key_3);
assign val_a = cmp_a ? key_0 : key_1;
assign idx_a = cmp_a ? 2'd0 : 2'd1;
assign val_b = cmp_b ? key_2 : key_3;
assign idx_b = cmp_b ? 2'd2 : 2'd3;
assign cmp_final = (val_a <= val_b);
assign winner = cmp_final ? idx_a : idx_b;
assign winner_ptr = head[winner];
assign winner_val = mem[{winner, winner_ptr}];

reg [63:0] pipe_val;
reg [1:0] pipe_sel;
reg pipe_phase;

reg [2:0] tree_num;
reg [63:0] tree_res[0:3];
reg [15:0] stk_a[0:63];
reg [5:0] sp_a;
reg stk_c[0:63];
reg [5:0] sp_c;
reg [1:0] stk_o[0:63];
reg [5:0] sp_o;
reg signed [63:0] stk_v[0:63];
reg [5:0] sp_v;

wire top_ctrl;
wire [15:0] top_addr;
wire [1:0] top_opc;
wire signed [63:0] opd_r, opd_l;

assign top_ctrl = stk_c[sp_c - 1];
assign top_addr = stk_a[sp_a - 1];
assign top_opc = stk_o[sp_o - 1];
assign opd_r = stk_v[sp_v - 1];
assign opd_l = stk_v[sp_v - 2];

reg signed [63:0] alu_a, alu_b;
reg [1:0] alu_op;
reg signed [63:0] alu_y;

always @(*) begin
    case(alu_op)
        2'b00: alu_y = alu_a + alu_b;
        2'b01: alu_y = alu_a - alu_b;
        2'b10: alu_y = alu_a * alu_b;
        2'b11: alu_y = alu_a >>> alu_b[5:0];
        default: alu_y = 0;
    endcase
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) 
        fsm_state <= ST_IDLE;
    else 
        fsm_state <= fsm_next;
end


always @(*) begin
    fsm_next = fsm_state;
    case(fsm_state)
        ST_IDLE: begin
            if(in_valid) begin
                case(mode_store)
                    2'd0: fsm_next = ST_RD_ADDR;
                    2'd1: fsm_next = ST_WR_PROC;
                    2'd2: fsm_next = ST_EXPR_SETUP;
                    2'd3: fsm_next = ST_SORT_LD;
                endcase
            end
        end
        ST_RD_ADDR: if(txn_ar == 256 && txn_r == 256) fsm_next = ST_RD_EMIT;
        ST_RD_EMIT: if(txn_out == 256) fsm_next = ST_IDLE;
        ST_WR_PROC: if(txn_b == 256) fsm_next = ST_IDLE;
        ST_SORT_LD: if(txn_ar == 256 && txn_r == 256) fsm_next = ST_SORT_RUN;
        ST_SORT_RUN: if(sort_cycle == 255) fsm_next = ST_SORT_ST;
        ST_SORT_ST: begin
            if(txn_aw == 256 && txn_b == 256) begin
                fsm_next = (active_bank == 3) ? ST_MRG_LOAD : ST_SORT_LD;
            end
        end
        ST_MRG_LOAD: if(txn_ar == 64 && txn_r == 64) fsm_next = ST_MRG_STALL;
        ST_MRG_STALL: fsm_next = refill_req ? ST_MRG_LOAD : ST_MRG_EXEC;
        ST_MRG_EXEC: begin
            if(txn_b == 1024) fsm_next = ST_MRG_FIN;
            else if(refill_req && txn_aw == txn_w && txn_b == txn_aw) 
                fsm_next = ST_MRG_STALL;
        end
        ST_MRG_FIN: fsm_next = ST_IDLE;
        ST_EXPR_SETUP: fsm_next = ST_EXPR_EVAL;
        ST_EXPR_EVAL: begin
            if(sp_c == 0) begin
                fsm_next = (tree_num == 3) ? ST_EXPR_DONE : ST_EXPR_SETUP;
            end else if(top_ctrl == 1) begin
                fsm_next = ST_ALU_PIPE;
            end else begin
                fsm_next = ST_EXPR_ADDR;
            end
        end
        ST_ALU_PIPE: fsm_next = ST_EXPR_EVAL;
        ST_EXPR_ADDR: if(ar_valid && ar_ready) fsm_next = ST_EXPR_RESP;
        ST_EXPR_RESP: if(r_valid && r_ready) fsm_next = ST_EXPR_EVAL;
        ST_EXPR_DONE: if(txn_r == 4) fsm_next = ST_IDLE;
        default: fsm_next = ST_IDLE;
    endcase
end

integer i;
always @(posedge clk) begin
    if(in_valid && mode_store == 1) begin
        mem[wr_idx[7:0]] <= in_data;
    end else if((fsm_state == ST_RD_ADDR || fsm_state == ST_SORT_LD) && r_valid && r_ready) begin
        mem[txn_r[7:0]] <= r_data;
    end else if(fsm_state == ST_SORT_RUN) begin
        if(toggle_phase) begin
            for(i = 0; i < 127; i = i + 1)
                if(mem[2*i+1][62:32] > mem[2*i+2][62:32]) begin
                    mem[2*i+1] <= mem[2*i+2];
                    mem[2*i+2] <= mem[2*i+1];
                end
        end else begin
            for(i = 0; i < 128; i = i + 1)
                if(mem[2*i][62:32] > mem[2*i+1][62:32]) begin
                    mem[2*i] <= mem[2*i+1];
                    mem[2*i+1] <= mem[2*i];
                end
        end
    end else if(fsm_state == ST_MRG_LOAD && r_valid && r_ready) begin
        mem[{refill_ba, txn_r[5:0]}] <= r_data;
    end
end

integer j;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        txn_ar <= 0; txn_r <= 0; txn_aw <= 0; txn_w <= 0; txn_b <= 0; txn_out <= 0;
        tree_num <= 0; active_bank <= 0; sort_cycle <= 0; toggle_phase <= 0;
        pipe_phase <= 0; pipe_val <= 0; pipe_sel <= 0;
        for(j = 0; j < 4; j = j + 1) begin
            head[j] <= 0; avail[j] <= 0; loaded[j] <= 0;
        end
    end 
    else begin
        if(fsm_state == ST_IDLE) begin
            txn_ar <= 0; txn_r <= 0; txn_aw <= 0; txn_w <= 0; txn_b <= 0; txn_out <= 0;
            tree_num <= 0; active_bank <= 0; pipe_phase <= 0;
            for(j = 0; j < 4; j = j + 1) begin
                head[j] <= 0; avail[j] <= 0; loaded[j] <= 0;
            end
        end 
        else if(fsm_state == ST_SORT_ST && fsm_next == ST_SORT_LD) begin
            txn_ar <= 0; txn_r <= 0; txn_aw <= 0; txn_w <= 0; txn_b <= 0;
            active_bank <= active_bank + 1;
        end 
        else if(fsm_state == ST_SORT_ST && fsm_next == ST_MRG_LOAD) begin
            txn_ar <= 0; txn_r <= 0; txn_aw <= 0; txn_w <= 0; txn_b <= 0;
        end 
        else if(fsm_state == ST_MRG_STALL) begin
            txn_ar <= 0; txn_r <= 0;
        end

        if(ar_valid && ar_ready) txn_ar <= txn_ar + 1;
        if(r_valid && r_ready) txn_r <= txn_r + 1;
        if(aw_valid && aw_ready) txn_aw <= txn_aw + 1;
        if(w_valid && w_ready) txn_w <= txn_w + 1;
        if(b_valid && b_ready) txn_b <= txn_b + 1;

        if(fsm_state == ST_RD_EMIT) txn_out <= txn_out + 1;
        if(fsm_state == ST_SORT_RUN) begin
            sort_cycle <= sort_cycle + 1;
            toggle_phase <= ~toggle_phase;
        end 
        else begin
            sort_cycle <= 0;
            toggle_phase <= 0;
        end

        if(fsm_state == ST_MRG_LOAD && r_valid && r_ready && txn_r == 63) begin
            avail[refill_ba] <= 64;
            head[refill_ba] <= 0;
            loaded[refill_ba] <= loaded[refill_ba] + 64;
        end

        if(fsm_state == ST_MRG_EXEC) begin
            if(pipe_phase == 0) begin
                if(!refill_req) begin
                    pipe_val <= winner_val;
                    pipe_sel <= winner;
                    pipe_phase <= 1;
                end
            end 
            else if(pipe_phase == 1) begin
                if(w_valid && w_ready) begin
                    head[pipe_sel] <= head[pipe_sel] + 1;
                    avail[pipe_sel] <= avail[pipe_sel] - 1;
                    pipe_phase <= 0;
                end
            end
        end 
        else begin
            pipe_phase <= 0;
        end

        if(fsm_state == ST_EXPR_ADDR && ar_valid && ar_ready) txn_ar <= 0;
        if(fsm_state == ST_EXPR_RESP && r_valid && r_ready) txn_r <= 0;
        if(fsm_state == ST_EXPR_EVAL && sp_c == 0 && tree_num < 4) 
            tree_num <= tree_num + 1;
        if(fsm_state == ST_EXPR_DONE) txn_r <= txn_r + 1;
    end
end

integer n;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sp_a <= 0; sp_c <= 0; sp_o <= 0; sp_v <= 0;
        alu_a <= 0; alu_b <= 0; alu_op <= 0;
        for(n = 0; n < 4; n = n + 1) 
            tree_res[n] <= 0;
    end 
    else begin
        if(fsm_state == ST_IDLE) begin
            sp_a <= 0; sp_c <= 0; sp_o <= 0; sp_v <= 0;
        end 
        else if(fsm_state == ST_EXPR_SETUP) begin
            stk_a[0] <= {tree_num[1:0], row_src_store, 8'd0};
            stk_c[0] <= 0;
            sp_a <= 1; sp_c <= 1; sp_o <= 0; sp_v <= 0;
        end 
        else if(fsm_state == ST_EXPR_EVAL) begin
            if(sp_c > 0 && top_ctrl == 1) begin
                alu_a <= opd_l;
                alu_b <= opd_r;
                alu_op <= top_opc;
                sp_v <= sp_v - 1;
                sp_o <= sp_o - 1;
                sp_c <= sp_c - 1;
            end 
            else if(sp_c == 0 && tree_num < 4) begin
                tree_res[tree_num] <= stk_v[0];
            end
        end 
        else if(fsm_state == ST_ALU_PIPE) begin
            stk_v[sp_v - 1] <= alu_y;
        end 
        else if(fsm_state == ST_EXPR_RESP && r_valid && r_ready) begin
            if(r_data[63] == 0) begin
                stk_v[sp_v] <= {{33{r_data[62]}}, r_data[62:32]};
                sp_v <= sp_v + 1;
                sp_a <= sp_a - 1;
                sp_c <= sp_c - 1;
            end 
            else begin
                stk_o[sp_o] <= r_data[33:32];
                sp_o <= sp_o + 1;
                stk_c[sp_c - 1] <= 1;
                stk_c[sp_c] <= 0;
                stk_c[sp_c + 1] <= 0;
                sp_c <= sp_c + 2;
                stk_a[sp_a - 1] <= r_data[15:0];
                stk_a[sp_a] <= r_data[31:16];
                sp_a <= sp_a + 1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        b_ready <= 0;
        r_ready <= 0;
    end 
    else begin
        b_ready <= 1;
        r_ready <= 1;
    end
end

always @(*) begin
    ar_valid = 0;
    ar_addr = 0;
    if(fsm_state == ST_RD_ADDR && txn_ar < 256) begin
        ar_valid = 1;
        ar_addr = {16'b0, bank_store, row_src_store, txn_ar[7:0]};
    end 
    else if(fsm_state == ST_EXPR_ADDR) begin
        ar_valid = 1;
        ar_addr = {16'b0, top_addr};
    end 
    else if(fsm_state == ST_SORT_LD && txn_ar < 256) begin
        ar_valid = 1;
        ar_addr = {16'b0, active_bank, row_src_store, txn_ar[7:0]};
    end 
    else if(fsm_state == ST_MRG_LOAD && txn_ar < 64) begin
        ar_valid = 1;
        ar_addr = {16'b0, refill_ba, 6'h3F, refill_addr};
    end
end
// AW 
always @(*) begin
    aw_valid = 0;
    aw_addr = 0;
    
    if (fsm_state == ST_WR_PROC && txn_aw < 256 && txn_aw < wr_idx) begin
        if (txn_aw <= txn_w) begin
            aw_valid = 1;
            aw_addr = {16'b0, bank_store, row_dst_store, txn_aw[7:0]};
        end
    end 
    else if (fsm_state == ST_SORT_ST && txn_aw < 256) begin
        if (txn_aw <= txn_w) begin
            aw_valid = 1;
            aw_addr = {16'b0, active_bank, 6'h3F, txn_aw[7:0]};
        end
    end 
    else if (fsm_state == ST_MRG_EXEC && txn_aw < 1024) begin
        
        if (txn_aw <= txn_w && pipe_phase == 1 && !refill_req) begin
            aw_valid = 1;
            aw_addr = {16'b0, txn_aw[9:8], row_dst_store, txn_aw[7:0]};
        end 
        
        else if (txn_aw < txn_w) begin
            aw_valid = 1;
            aw_addr = {16'b0, txn_aw[9:8], row_dst_store, txn_aw[7:0]};
        end
    end
end

// W 
always @(*) begin
    w_valid = 0;
    w_data = 0;
    
    if (fsm_state == ST_WR_PROC && txn_w < 256 && txn_w < wr_idx) begin
        if (txn_w <= txn_aw) begin
            w_valid = 1;
            w_data = mem[txn_w[7:0]];
        end
    end 
    else if (fsm_state == ST_SORT_ST && txn_w < 256) begin
        if (txn_w <= txn_aw) begin
            w_valid = 1;
            w_data = mem[txn_w[7:0]];
        end
    end 
    else if (fsm_state == ST_MRG_EXEC && txn_w < 1024) begin
        if (txn_w <= txn_aw && pipe_phase == 1 && !refill_req) begin
            w_valid = 1;
            w_data = pipe_val;
        end 
        else if (txn_w < txn_aw) begin
            w_valid = 1;
            w_data = pipe_val;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_data <= 0;
    end 
    else begin
        out_valid <= 0;
        out_data <= 0;
        if(fsm_state == ST_RD_EMIT && txn_out < 256) begin
            out_valid <= 1;
            out_data <= mem[txn_out[7:0]];
        end 
        else if(fsm_state == ST_WR_PROC && txn_b == 256) begin
            out_valid <= 1;
        end 
        else if(fsm_state == ST_EXPR_DONE && txn_r < 4) begin
            out_valid <= 1;
            out_data <= tree_res[txn_r[1:0]];
        end 
        else if(fsm_state == ST_MRG_FIN) begin
            out_valid <= 1;
        end
    end
end

endmodule
