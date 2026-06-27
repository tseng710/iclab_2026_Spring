module DRAM_CTRL (
    input               clk,
    input               rst_n,
    
    // AXI4-Lite slave interface
    input [31:0]        aw_addr,
    input               aw_valid,
    output reg          aw_ready,
    input [63:0]        w_data,
    input               w_valid,
    output reg          w_ready,
    output wire [1:0]   b_resp,
    output wire         b_valid,
    input               b_ready,
    
    input [31:0]        ar_addr,
    input               ar_valid,
    output reg          ar_ready,
    output reg [63:0]   r_data,
    output wire [1:0]   r_resp,
    output wire         r_valid,
    input               r_ready,

    // DRAM master interface
    output reg  [3:0]   dram_cmd,  // {CS_n, RAS_n, CAS_n, WE_n}
    output reg  [1:0]   dram_ba,
    output reg  [10:0]  dram_addr,
    output reg  [63:0]  dram_wdata,
    input [63:0]        dram_rdata,
    input               dram_valid
);

localparam [3:0] NOP = 4'b0111,
                 ACT = 4'b0011,
                 PRE = 4'b0010,
                 WR  = 4'b0100,
                 RD  = 4'b0101;

reg [31:0] addr_rd_buf [0:15];
reg  [3:0] rd_front, rd_rear;
reg  [4:0] rd_depth;

reg [31:0] addr_wr_buf [0:15];
reg  [3:0] wr_front, wr_rear;
reg  [4:0] wr_depth;

reg [63:0] data_wr_buf [0:15];
reg  [3:0] dat_front, dat_rear;
reg  [4:0] dat_depth;

wire acquire_rd, acquire_wr, acquire_dat;
wire consume_rd, consume_wr, consume_dat;

assign acquire_rd  = ar_valid & ar_ready;
assign acquire_wr  = aw_valid & aw_ready;
assign acquire_dat = w_valid  & w_ready;

always @(posedge clk) begin
    if (acquire_rd)
        addr_rd_buf[rd_rear] <= ar_addr;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_front <= 4'd0;
        rd_rear  <= 4'd0;
        rd_depth <= 5'd0;
    end 
    else begin
        if (acquire_rd)  rd_rear  <= rd_rear  + 4'd1;
        if (consume_rd)  rd_front <= rd_front + 4'd1;

        if (acquire_rd & ~consume_rd) rd_depth <= rd_depth + 5'd1;
        if (~acquire_rd & consume_rd) rd_depth <= rd_depth - 5'd1;
    end
end

// write-address
always @(posedge clk) begin
    if (acquire_wr)
        addr_wr_buf[wr_rear] <= aw_addr;
end

//write-address FIFO
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_front <= 4'd0;
        wr_rear  <= 4'd0;
        wr_depth <= 5'd0;
    end 
    else begin
        if (acquire_wr)  wr_rear  <= wr_rear  + 4'd1;
        if (consume_wr)  wr_front <= wr_front + 4'd1;

        if (acquire_wr & ~consume_wr) wr_depth <= wr_depth + 5'd1;
        if (~acquire_wr & consume_wr) wr_depth <= wr_depth - 5'd1;
    end
end

// write-data FIFO
always @(posedge clk) begin
    if (acquire_dat)
        data_wr_buf[dat_rear] <= w_data;
end

// write-data FIFO
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dat_front <= 4'd0;
        dat_rear  <= 4'd0;
        dat_depth <= 5'd0;
    end else begin
        if (acquire_dat)  dat_rear  <= dat_rear  + 4'd1;
        if (consume_dat)  dat_front <= dat_front + 4'd1;

        if (acquire_dat & ~consume_dat) dat_depth <= dat_depth + 5'd1;
        if (~acquire_dat & consume_dat) dat_depth <= dat_depth - 5'd1;
    end
end

// AXI-3
reg [4:0] pending_aw_cnt;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pending_aw_cnt <= 5'd0;
    else if (acquire_wr & ~acquire_dat)
        pending_aw_cnt <= pending_aw_cnt + 5'd1;
    else if (~acquire_wr & acquire_dat)
        pending_aw_cnt <= pending_aw_cnt - 5'd1;
end

// AXI ready signals
always @(*) begin
    ar_ready = rst_n & (rd_depth  < 5'd15);
    aw_ready = rst_n & (wr_depth  < 5'd15);
    w_ready  = rst_n & (dat_depth < 5'd15) & (pending_aw_cnt > 5'd0);
end


//  Request

reg        req_wr_arr  [0:3];
reg  [1:0] req_ba_arr  [0:3];
reg  [5:0] req_row_arr [0:3];
reg  [7:0] req_col_arr [0:3];
reg  [1:0] req_ptr_arr [0:3];

reg [63:0] payload_ram [0:3];
reg  [1:0] alloc_ptr;

reg  [1:0] req_head, req_tail;
reg  [2:0] req_num;
reg        toggle_rr;

// decode head-of-queue
wire [15:0] rd_addr_val;
wire [15:0] wr_addr_val;
wire [63:0] wr_data_val;

assign rd_addr_val = addr_rd_buf[rd_front][15:0];
assign wr_addr_val = addr_wr_buf[wr_front][15:0];
assign wr_data_val = data_wr_buf[dat_front];

//
wire req_space;
wire issue_rd, issue_wr;
wire enqueue_req, dequeue_req;

assign req_space   = (req_num < 3'd4);
assign issue_rd    = (rd_depth > 0) & req_space & (~toggle_rr | (wr_depth == 0) | (dat_depth == 0));
assign issue_wr    = (wr_depth > 0) & (dat_depth > 0) & req_space & ~issue_rd;
assign enqueue_req = issue_rd | issue_wr;

assign consume_rd  = issue_rd;
assign consume_wr  = issue_wr;
assign consume_dat = issue_wr;

//
wire        next_wr;
wire  [1:0] next_ba;
wire  [5:0] next_row;
wire  [7:0] next_col;

assign next_wr  = issue_wr;
assign next_ba  = issue_wr ? wr_addr_val[15:14] : rd_addr_val[15:14];
assign next_row = issue_wr ? wr_addr_val[13:8]  : rd_addr_val[13:8];
assign next_col = issue_wr ? wr_addr_val[7:0]   : rd_addr_val[7:0];

//
always @(posedge clk) begin
    if (enqueue_req)
        payload_ram[alloc_ptr] <= wr_data_val;
end

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        alloc_ptr <= 2'd0;
    else if (enqueue_req)
        alloc_ptr <= alloc_ptr + 2'd1;
end

//
always @(posedge clk) begin
    if (enqueue_req) begin
        req_wr_arr [req_tail] <= next_wr;
        req_ba_arr [req_tail] <= next_ba;
        req_row_arr[req_tail] <= next_row;
        req_col_arr[req_tail] <= next_col;
        req_ptr_arr[req_tail] <= alloc_ptr;
    end
end

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        req_head <= 2'd0;
        req_tail <= 2'd0;
        req_num  <= 3'd0;
    end else begin
        if (enqueue_req) 
            req_tail <= req_tail + 2'd1;
        if (dequeue_req) 
            req_head <= req_head + 2'd1;

        if (enqueue_req & ~dequeue_req) 
            req_num <= req_num + 3'd1;
        if (~enqueue_req & dequeue_req) 
            req_num <= req_num - 3'd1;
    end
end

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        toggle_rr <= 1'b0;
    else if (enqueue_req)
        toggle_rr <= ~toggle_rr;
end


// Virtual indexing

wire [1:0] id0, id1, id2, id3;
assign id0 = req_head;
assign id1 = req_head + 2'd1;
assign id2 = req_head + 2'd2;
assign id3 = req_head + 2'd3;

wire act0, act1, act2, act3;
assign act0 = (req_num > 3'd0);
assign act1 = (req_num > 3'd1);
assign act2 = (req_num > 3'd2);
assign act3 = (req_num > 3'd3);

// entry 0
wire        wr0;
wire  [1:0] ba0;
wire  [5:0] row0;
wire  [7:0] col0;
wire  [1:0] ptr0;

assign wr0  = req_wr_arr [id0];
assign ba0  = req_ba_arr [id0];
assign row0 = req_row_arr[id0];
assign col0 = req_col_arr[id0];
assign ptr0 = req_ptr_arr[id0];

// entry 1
wire        wr1;
wire  [1:0] ba1;
wire  [5:0] row1;

assign wr1  = req_wr_arr [id1];
assign ba1  = req_ba_arr [id1];
assign row1 = req_row_arr[id1];

// entry 2
wire        wr2;
wire  [1:0] ba2;
wire  [5:0] row2;

assign wr2  = req_wr_arr [id2];
assign ba2  = req_ba_arr [id2];
assign row2 = req_row_arr[id2];

// entry 3
wire        wr3;
wire  [1:0] ba3;
wire  [5:0] row3;

assign wr3  = req_wr_arr [id3];
assign ba3  = req_ba_arr [id3];
assign row3 = req_row_arr[id3];


// DRAM timing counters

reg [1:0] t_rcd [0:3];   // RCD : ACT -> RD/WR
reg [2:0] t_ras [0:3];   // RAS : ACT -> PRE
reg [1:0] t_rp  [0:3];   // RP  : PRE -> ACT

reg       ba_active [0:3];
reg [5:0] ba_row    [0:3];

// cmd_next / ba_next / addr_nex
reg  [3:0] cmd_next;
reg  [1:0] ba_next;
reg [10:0] addr_next;

integer m;

//
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (m = 0; m < 4; m = m + 1) begin
            t_rcd[m]     <= 2'd0;
            t_ras[m]     <= 3'd0;
            t_rp [m]     <= 2'd0;
            ba_active[m] <= 1'b0;
            ba_row[m]    <= 6'd0;
        end
    end 
    else begin
        for (m = 0; m < 4; m = m + 1) begin
            if (t_rcd[m] > 0) t_rcd[m] <= t_rcd[m] - 2'd1;
            if (t_ras[m] > 0) t_ras[m] <= t_ras[m] - 3'd1;
            if (t_rp [m] > 0) t_rp [m] <= t_rp [m] - 2'd1;
        end
        if (cmd_next == ACT) begin
            ba_active[ba_next] <= 1'b1;
            ba_row[ba_next]    <= addr_next[5:0];
            t_rcd[ba_next]     <= 2'd1;
            t_ras[ba_next]     <= 3'd4;
        end
        if (cmd_next == PRE) begin
            ba_active[ba_next] <= 1'b0;
            t_rp[ba_next]      <= 2'd2;
        end
    end
end


//
wire hazard_1, hazard_2, hazard_3;
assign hazard_1 = act0 & (ba0 == ba1);
assign hazard_2 = (act0 & (ba0 == ba2)) | (act1 & (ba1 == ba2));
assign hazard_3 = (act0 & (ba0 == ba3)) | (act1 & (ba1 == ba3)) | (act2 & (ba2 == ba3));

wire ready_0, ready_1, ready_2, ready_3;
assign ready_0 = act0;
assign ready_1 = act1 & ~hazard_1;
assign ready_2 = act2 & ~hazard_2;
assign ready_3 = act3 & ~hazard_3;

// per-entry decoded flags
wire can_exc_0, can_pre_0, can_act_0, is_hit_0;
wire          can_pre_1, can_act_1, is_hit_1;
wire          can_pre_2, can_act_2, is_hit_2;
wire          can_pre_3, can_act_3, is_hit_3;

assign can_exc_0 =  ba_active[ba0] & (t_rcd[ba0] == 2'd0);
assign can_pre_0 =  ba_active[ba0] & (t_ras[ba0] == 3'd0);
assign can_act_0 = ~ba_active[ba0] & (t_rp [ba0] == 2'd0);
assign is_hit_0  = (ba_row[ba0] == row0);

assign can_pre_1 =  ba_active[ba1] & (t_ras[ba1] == 3'd0);
assign can_act_1 = ~ba_active[ba1] & (t_rp [ba1] == 2'd0);
assign is_hit_1  = (ba_row[ba1] == row1);

assign can_pre_2 =  ba_active[ba2] & (t_ras[ba2] == 3'd0);
assign can_act_2 = ~ba_active[ba2] & (t_rp [ba2] == 2'd0);
assign is_hit_2  = (ba_row[ba2] == row2);

assign can_pre_3 =  ba_active[ba3] & (t_ras[ba3] == 3'd0);
assign can_act_3 = ~ba_active[ba3] & (t_rp [ba3] == 2'd0);
assign is_hit_3  = (ba_row[ba3] == row3);

// final per-entry actions
wire exec_0;
wire pre_0,  act_0;
wire pre_1,  act_1;
wire pre_2,  act_2;
wire pre_3,  act_3;

assign exec_0 = ready_0 & can_exc_0 & is_hit_0;
assign pre_0  = ready_0 & can_pre_0 & ~is_hit_0;
assign act_0  = ready_0 & can_act_0;

assign pre_1  = ready_1 & can_pre_1 & ~is_hit_1;
assign act_1  = ready_1 & can_act_1;

assign pre_2  = ready_2 & can_pre_2 & ~is_hit_2;
assign act_2  = ready_2 & can_act_2;

assign pre_3  = ready_3 & can_pre_3 & ~is_hit_3;
assign act_3  = ready_3 & can_act_3;

assign dequeue_req = exec_0;

// 
always @(*) begin
    cmd_next  = NOP;
    ba_next   = 2'd0;
    addr_next = 11'd0;

    if      (exec_0) begin cmd_next = wr0 ? WR : RD; ba_next = ba0; addr_next = {3'b000, col0}; end
    else if (pre_0)  begin cmd_next = PRE;            ba_next = ba0;                             end
    else if (act_0)  begin cmd_next = ACT;            ba_next = ba0; addr_next = {5'b00000, row0}; end
    else if (pre_1)  begin cmd_next = PRE;            ba_next = ba1;                             end
    else if (act_1)  begin cmd_next = ACT;            ba_next = ba1; addr_next = {5'b00000, row1}; end
    else if (pre_2)  begin cmd_next = PRE;            ba_next = ba2;                             end
    else if (act_2)  begin cmd_next = ACT;            ba_next = ba2; addr_next = {5'b00000, row2}; end
    else if (pre_3)  begin cmd_next = PRE;            ba_next = ba3;                             end
    else if (act_3)  begin cmd_next = ACT;            ba_next = ba3; addr_next = {5'b00000, row3}; end
end

// ---------- DRAM command register ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dram_cmd <= NOP;
    else
        dram_cmd <= cmd_next;
end

// ---------- DRAM bank / address ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dram_ba   <= 2'd0;
        dram_addr <= 11'd0;
    end else if (cmd_next == NOP) begin
        dram_ba   <= 2'd0;
        dram_addr <= 11'd0;
    end else begin
        dram_ba   <= ba_next;
        dram_addr <= addr_next;
    end
end

// ---------- DRAM write data ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dram_wdata <= 64'd0;
    else if (cmd_next == WR)
        dram_wdata <= payload_ram[ptr0];
    else
        dram_wdata <= 64'd0;
end


//  Read response

reg [63:0] rd_buf [0:15];
reg  [3:0] rd_rsp_front, rd_rsp_rear;
reg  [4:0] rd_rsp_depth;

wire push_rd_rsp, pop_rd_rsp;
assign push_rd_rsp = dram_valid;
assign pop_rd_rsp  = r_valid & r_ready;

// ---------- data ----------
always @(posedge clk) begin
    if (push_rd_rsp)
        rd_buf[rd_rsp_rear] <= dram_rdata;
end

// ---------- rear pointer ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rd_rsp_rear <= 4'd0;
    else if (push_rd_rsp)
        rd_rsp_rear <= rd_rsp_rear + 4'd1;
end

// ---------- front pointer ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rd_rsp_front <= 4'd0;
    else if (pop_rd_rsp)
        rd_rsp_front <= rd_rsp_front + 4'd1;
end

// ---------- depth ----------
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rd_rsp_depth <= 5'd0;
    else if (push_rd_rsp & ~pop_rd_rsp)
        rd_rsp_depth <= rd_rsp_depth + 5'd1;
    else if (~push_rd_rsp & pop_rd_rsp)
        rd_rsp_depth <= rd_rsp_depth - 5'd1;
end

assign r_valid = rst_n & (rd_rsp_depth > 5'd0);
assign r_resp  = 2'b00;

always @(*) begin
    r_data = (rst_n & (rd_rsp_depth > 5'd0)) ? rd_buf[rd_rsp_front] : 64'd0;
end


// Write response counter

reg [4:0] wr_rsp_cnt;

wire push_wr_rsp, pop_wr_rsp;
assign push_wr_rsp = dequeue_req & wr0;
assign pop_wr_rsp  = b_valid & b_ready;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        wr_rsp_cnt <= 5'd0;
    else if (push_wr_rsp & ~pop_wr_rsp)
        wr_rsp_cnt <= wr_rsp_cnt + 5'd1;
    else if (~push_wr_rsp & pop_wr_rsp)
        wr_rsp_cnt <= wr_rsp_cnt - 5'd1;
end

assign b_valid = rst_n & (wr_rsp_cnt > 5'd0);
assign b_resp  = 2'b00;

endmodule
