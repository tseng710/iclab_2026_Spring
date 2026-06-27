module CLK_1_MODULE (
	input               clk, 
    input               rst_n,
    input               in_mode_valid,
    input       	    in_mode,
	
    input               in_valid,
    input       [1:0]   in_bank,
    input       [5:0]   in_src_row,

    output reg          out_valid,
    output reg  [63:0]  out_data,

	input out_idle,
	output reg handshake_sready,
	output reg [8:0] handshake_din,
	// You can use the the custom flag ports for your design
	input  flag_handshake_to_clk1,
	output flag_clk1_to_handshake,

	input fifo_empty,
	input [31:0] fifo_rdata,
	output fifo_rinc,
	// You can use the the custom flag ports for your design
	output flag_clk1_to_fifo,
	input flag_fifo_to_clk1

);

assign flag_clk1_to_handshake = handshake_sready; 
assign flag_clk1_to_fifo = fifo_rinc;

reg [1:0] in_bk_arr [0:3];
reg [5:0] in_rw_arr [0:3];
reg [2:0] c1_wptr;
reg [2:0] c1_rptr;
reg       c1_op_mode;

reg [4:0] pending_req_cnt;
assign fifo_rinc = !fifo_empty && (pending_req_cnt < 4);

reg r_dly_1, r_dly_2;
reg [31:0] rdata_lo_buf;
reg        data_mrg_st;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c1_wptr <= 3'b0;
        c1_op_mode <= 1'b0;
    end 
    else begin
        if (in_mode_valid) begin
            c1_op_mode <= in_mode;
            c1_wptr <= 3'b0;
        end
        if (in_valid) begin
            in_bk_arr[c1_wptr] <= in_bank;
            in_rw_arr[c1_wptr] <= in_src_row;
            c1_wptr <= c1_wptr + 1;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c1_rptr <= 3'b0;
        handshake_sready <= 1'b0;
        handshake_din <= 9'b0;
    end 
    else begin
        if (in_mode_valid) begin
            c1_rptr <= 3'b0;
        end
        if (c1_rptr < c1_wptr) begin
            if (out_idle && !handshake_sready) begin       
                handshake_sready <= 1'b1;
                handshake_din <= {c1_op_mode, in_bk_arr[c1_rptr], in_rw_arr[c1_rptr]};
            end 
            else if (!out_idle && handshake_sready) begin 
                handshake_sready <= 1'b0;
                c1_rptr <= c1_rptr + 1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pending_req_cnt <= 5'b0;
        r_dly_1 <= 1'b0;
        r_dly_2 <= 1'b0;
    end 
    else begin
        if (fifo_rinc && !r_dly_2) 
            pending_req_cnt <= pending_req_cnt + 1;
        else if (!fifo_rinc && r_dly_2) 
            pending_req_cnt <= pending_req_cnt - 1;

        r_dly_1 <= fifo_rinc;
        r_dly_2 <= r_dly_1;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_mrg_st <= 0;
        out_valid <= 0;
        out_data <= 0;
        rdata_lo_buf <= 0;
    end 
    else begin
        out_valid <= 0;
        out_data  <= 0;

        if (r_dly_2) begin 
            if (data_mrg_st == 0) begin
                rdata_lo_buf <= fifo_rdata;
                data_mrg_st <= 1;
            end 
            else begin
                out_data <= {fifo_rdata, rdata_lo_buf};
                out_valid <= 1; 
                data_mrg_st <= 0;
            end
        end
    end
end
endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    
	//INPUT
	busy,
    in_valid,
    in_data,
	flag_handshake_to_clk2,
    flag_clk2_to_handshake,

	//OUTPUT
    out_fifo_full,
    out_valid,
    out_data,
    flag_fifo_to_clk2,
    flag_clk2_to_fifo,

	//AR
    ar_fifo_full,
    ar_out_valid,
    ar_out_data,
    ar_flag_fifo_to_wclk,
    ar_flag_wclk_to_fifo,

    //R
	r_fifo_empty,
    r_fifo_rdata,
    r_fifo_rinc,
    r_flag_fifo_to_rclk,
    r_flag_rclk_to_fifo,

	ar_addr, 
    ar_valid, 
    ar_ready,
    r_data,  
    // r_resp, 
    r_valid, 
    r_ready
);
input clk;
input rst_n;

output  busy;
input in_valid;
input [8:0] in_data;
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input out_fifo_full;
output reg out_valid;
output reg [31:0] out_data;
input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

//AR
input    	ar_fifo_full;
output reg  ar_out_valid;
output reg [31:0]    ar_out_data;
input    	ar_flag_fifo_to_wclk;
output    	ar_flag_wclk_to_fifo;

//R
input	r_fifo_empty;
input [31:0]   r_fifo_rdata;
output    r_fifo_rinc;
input    r_flag_fifo_to_rclk;
output    r_flag_rclk_to_fifo;

output   [31:0]  ar_addr;
output           ar_valid; 
output           ar_ready;
output reg  [63:0]  r_data;  
// input       [1:0]   r_resp; 
output reg       r_valid; 
output           r_ready;

assign flag_clk2_to_fifo = out_valid;            
assign ar_flag_wclk_to_fifo = ar_out_valid; 
assign r_flag_rclk_to_fifo = r_fifo_rinc;        
assign flag_clk2_to_handshake = 0;

wire c2_hsk_req;
reg [1:0] hsk_bk_reg [0:3];
reg [5:0] hsk_rw_reg  [0:3];
reg [2:0] in_hsk_cnt;
reg [2:0] proc_task_cnt;
reg curr_op_md;

reg [63:0] snoop_q_mem [0:1];
reg sq_wptr, sq_rptr;
reg [1:0] sq_lvl_cnt; 
reg [1:0] ar_in_flight;
wire [2:0] total_rx_pend;

assign total_rx_pend = {sq_lvl_cnt, 1'b0} + {1'b0, ar_in_flight};
assign c2_hsk_req = flag_handshake_to_clk2;
assign r_fifo_rinc = !r_fifo_empty && (total_rx_pend < 4); 

reg rin_dly_1, rin_dly_2, rx_mrg_st, sq_dat_vld, sq_pop_cmd;
reg [31:0] rdata_lsb_hold; 
reg [63:0] merged_rdata_full;
wire sq_empty;
wire [63:0] sq_head_dat;

reg [4:0] ar_pend_limiter;
wire ar_grant; 

reg [2:0] c2_main_st;
localparam S_IDLE  = 0, S_FTCH  = 1, S_EVAL  = 2;
localparam S_REDUC = 3, S_G_SCN = 4, S_G_WAI = 5;

assign sq_empty = (sq_lvl_cnt == 0);
assign sq_head_dat = snoop_q_mem[sq_rptr];
assign ar_grant = (!ar_fifo_full && ar_pend_limiter < 15);

reg [1:0]  tree_op   [0:7];
reg [15:0] tree_ptr  [0:7];
reg signed [63:0] tree_val  [0:7];
reg [1:0]  tree_st   [0:7];
reg [3:0]  tree_ptr_idx;
reg signed [63:0] tree_acc; 
reg [15:0] target_adr_reg;

reg [10:0]  g_total_cnt;
reg [41:0]  g_sum;
reg [72:0]  g_sq_sum;
reg signed [85:0] g_thr_var;
reg [1:0]   g_st_phase;
reg [10:0]  g_fetch_idx, g_rsp_idx;

reg req_push_tx, tx_hi_st;
reg [63:0] flit_tmp_dat, tx_flit_buf;
reg c_ar_vld; 
reg [31:0] c_ar_adr;
integer i;

reg p1_vld;
reg p1_eof;
reg p1_is_num;
reg [63:0] p1_dat_hold;
reg signed [42:0] p1_sub_diff; 

wire [41:0] math_nx;
wire signed [85:0] math_base_var; 
wire signed [63:0] mat_in_1; 
wire signed [63:0] mat_in_2; 
wire signed [127:0] mat_out_prod;
wire f_pass_cond;
wire f_stall_cond;

assign math_nx = g_total_cnt * sq_head_dat[62:32];
assign math_base_var = $signed({1'b0, g_total_cnt}) * $signed({1'b0, g_sq_sum}); 

assign mat_in_1 = (curr_op_md == 0)  ? tree_val[tree_ptr_idx-1] :
                  (c2_main_st == S_G_WAI) ? $signed({22'b0, g_sum}) :
                  (curr_op_md == 1 && g_st_phase == 3) ? $signed({{21{p1_sub_diff[42]}}, p1_sub_diff}) 
                                                   :$signed({33'b0, sq_head_dat[62:32]}); 

assign mat_in_2 =  (curr_op_md == 0) ? tree_acc :
                   (c2_main_st == S_G_WAI)  ? $signed({22'b0, g_sum}) :
                   (curr_op_md == 1 && g_st_phase == 3) ? $signed({{21{p1_sub_diff[42]}}, p1_sub_diff}) 
                                                    : $signed({33'b0, sq_head_dat[62:32]}); 

assign mat_out_prod = mat_in_1 * mat_in_2;

assign f_pass_cond = p1_vld && (
    (p1_is_num && (mat_out_prod <= $signed(g_thr_var) || p1_eof)) ||
    (!p1_is_num && p1_eof)
);

assign f_stall_cond = f_pass_cond && (out_fifo_full || tx_hi_st);
assign busy = (in_hsk_cnt == 4 || c2_main_st != S_IDLE || tx_hi_st || req_push_tx);

always @(*) begin
    sq_pop_cmd = 0;
    req_push_tx = 0; 
    flit_tmp_dat = 0;
    
    if (c2_main_st == S_EVAL && !sq_empty) begin
        if (sq_head_dat[63] == 1) begin
            if (ar_grant) sq_pop_cmd = 1;
        end 
        else begin
            sq_pop_cmd = 1;
        end
    end
    
    if (c2_main_st == S_REDUC && tree_ptr_idx == 0 && !out_fifo_full && !tx_hi_st) begin
        req_push_tx = 1;
        flit_tmp_dat = tree_acc;
    end
    
    if (c2_main_st == S_G_SCN) begin
        if (g_st_phase == 1) begin
            if (!sq_empty && g_rsp_idx < 1024) 
                sq_pop_cmd = 1;
        end 
        else if (g_st_phase == 3) begin
            if (!sq_empty && !f_stall_cond && g_rsp_idx < 1024) 
                sq_pop_cmd = 1;
            if (f_pass_cond && !f_stall_cond) begin
                req_push_tx = 1;
                flit_tmp_dat = p1_dat_hold;
            end
        end
    end
end

always @(*) begin
    c_ar_vld = 0; 
    c_ar_adr = 0;
    if (c2_main_st == S_FTCH) begin
        c_ar_vld = 1; 
        c_ar_adr = {16'b0, target_adr_reg};
    end 
    else if (c2_main_st == S_EVAL && !sq_empty && sq_head_dat[63] == 1) begin
        c_ar_vld = 1;
        c_ar_adr = {16'b0, sq_head_dat[31:16]};
    end
    else if (c2_main_st == S_REDUC && tree_ptr_idx > 0 && tree_st[tree_ptr_idx-1] == 0) begin
        c_ar_vld = 1;
        c_ar_adr = {16'b0, tree_ptr[tree_ptr_idx-1]};
    end
    else if (c2_main_st == S_G_SCN && g_fetch_idx < 1024) begin
        c_ar_vld = 1;
        c_ar_adr = {16'b0, hsk_bk_reg[g_fetch_idx[9:8]], hsk_rw_reg[g_fetch_idx[9:8]], g_fetch_idx[7:0]};
    end
end

assign ar_ready = rst_n ? (!ar_fifo_full) : 0;
assign ar_valid = rst_n ? (c_ar_vld && ar_grant) : 0;
assign ar_addr  = rst_n ? (ar_valid ? c_ar_adr : 32'b0) : 0;
assign r_ready  = rst_n ? 1 : 0;

always @(*) begin
    ar_out_valid = ar_valid; 
    ar_out_data  = ar_addr;
    r_valid      = rst_n ? sq_dat_vld : 0;
    r_data       = rst_n ? (sq_dat_vld ? merged_rdata_full : 0) : 0;
end


always @(*) begin
    out_valid = 0;
    out_data  = 0;
    if (rst_n) begin
        if (req_push_tx && !out_fifo_full) begin
            out_valid = 1;
            out_data  = flit_tmp_dat[31:0];
        end 
        else if (tx_hi_st && !out_fifo_full) begin
            out_valid = 1;
            out_data  = tx_flit_buf[63:32];
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_hsk_cnt <= 0;
        proc_task_cnt <= 0;
        curr_op_md <= 0;
        for (i = 0; i < 4; i = i + 1) begin
            hsk_bk_reg[i] <= 0; 
            hsk_rw_reg[i] <= 0;
        end
    end 
    else begin
        if (in_valid) begin
            if (in_hsk_cnt == 0) curr_op_md <= in_data[8];
            hsk_bk_reg[in_hsk_cnt[1:0]] <= in_data[7:6];
            hsk_rw_reg[in_hsk_cnt[1:0]]  <= in_data[5:0];
            in_hsk_cnt <= in_hsk_cnt + 1;
        end
        if (c2_main_st == S_REDUC && tree_ptr_idx == 0 && !out_fifo_full && !tx_hi_st && proc_task_cnt == 4) begin
            in_hsk_cnt <= 0;
            proc_task_cnt <= 0;
        end 
        else if (c2_main_st == S_G_SCN && g_st_phase == 3 && p1_vld && p1_eof && !f_stall_cond) begin
            in_hsk_cnt <= 0;
            proc_task_cnt <= 0;
        end 
        else if (c2_main_st == S_IDLE && proc_task_cnt < in_hsk_cnt && curr_op_md == 0) begin
            proc_task_cnt <= proc_task_cnt + 1;
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        c2_main_st <= S_IDLE;
        target_adr_reg <= 0;
    end 
    else begin
        case (c2_main_st)
            S_IDLE: begin
                if (proc_task_cnt < in_hsk_cnt && curr_op_md == 0) begin 
                    c2_main_st <= S_FTCH;
                    target_adr_reg <= {hsk_bk_reg[proc_task_cnt[1:0]], hsk_rw_reg[proc_task_cnt[1:0]], 8'h00};
                end 
                else if (in_hsk_cnt == 4 && curr_op_md == 1) begin 
                    c2_main_st <= S_G_SCN;
                end
            end
            S_FTCH: if (ar_valid) c2_main_st <= S_EVAL;
            S_EVAL: begin
                if (sq_pop_cmd) begin
                    if (sq_head_dat[63] == 0) c2_main_st <= S_REDUC;
                    else begin
                        target_adr_reg <= sq_head_dat[31:16];
                        c2_main_st <= S_EVAL;
                    end
                end
            end
            S_REDUC: begin
                if (tree_ptr_idx == 0) begin
                    if (!out_fifo_full && !tx_hi_st) c2_main_st <= S_IDLE;
                end 
                else if (tree_st[tree_ptr_idx-1] == 0) begin
                    if (ar_grant) begin 
                        target_adr_reg <= tree_ptr[tree_ptr_idx-1]; 
                        c2_main_st <= S_EVAL; 
                    end
                end 
            end
            S_G_SCN: begin
                if (sq_pop_cmd && g_st_phase == 1 && g_rsp_idx == 1023) c2_main_st <= S_G_WAI;
                if (g_st_phase == 3 && p1_vld && p1_eof && !f_stall_cond) c2_main_st <= S_IDLE;
            end
            S_G_WAI: c2_main_st <= S_G_SCN;
        endcase
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tree_ptr_idx <= 0;
        tree_acc <= 0;
        for (i = 0; i < 8; i = i + 1) begin
            tree_op[i] <= 0; tree_ptr[i] <= 0; tree_val[i] <= 0; tree_st[i] <= 0;
        end
    end 
    else begin
        if (c2_main_st == S_IDLE && proc_task_cnt < in_hsk_cnt && curr_op_md == 0) begin
            tree_ptr_idx <= 0;
        end 
        else if (c2_main_st == S_EVAL && sq_pop_cmd) begin
            if (sq_head_dat[63] == 0) begin 
                tree_acc <= $signed({ {33{sq_head_dat[62]}}, sq_head_dat[62:32] });
            end 
            else begin
                tree_op[tree_ptr_idx] <= sq_head_dat[33:32];
                tree_ptr[tree_ptr_idx] <= sq_head_dat[15:0];
                tree_st[tree_ptr_idx] <= 0; 
                tree_ptr_idx <= tree_ptr_idx + 1;
            end
        end 
        else if (c2_main_st == S_REDUC && tree_ptr_idx > 0) begin
            if (tree_st[tree_ptr_idx-1] == 0) begin
                if (ar_grant) begin 
                    tree_val[tree_ptr_idx-1] <= tree_acc;
                    tree_st[tree_ptr_idx-1] <= 1; 
                end
            end 
            else begin
                case(tree_op[tree_ptr_idx-1])
                    2'b00: tree_acc <= tree_val[tree_ptr_idx-1] + tree_acc;
                    2'b01: tree_acc <= tree_val[tree_ptr_idx-1] - tree_acc;
                    2'b10: tree_acc <= mat_out_prod[63:0];
                    2'b11: tree_acc <= $signed(tree_val[tree_ptr_idx-1]) >>> tree_acc[5:0];
                endcase
                tree_ptr_idx <= tree_ptr_idx - 1;
            end
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        g_st_phase <= 0; 
        g_fetch_idx <= 0; g_rsp_idx <= 0;
        g_sum <= 0; g_total_cnt <= 0; g_sq_sum <= 0;
        g_thr_var <= 0;
        p1_vld <= 0; p1_eof <= 0; p1_is_num <= 0;
        p1_dat_hold <= 0; p1_sub_diff <= 0;
    end 
    else begin
        if (c2_main_st == S_IDLE && in_hsk_cnt == 4 && curr_op_md == 1) begin
            g_st_phase <= 1; 
            g_sum <= 0; g_total_cnt <= 0; g_sq_sum <= 0;
            g_fetch_idx <= 0; g_rsp_idx <= 0;
        end 
        else if (c2_main_st == S_G_WAI) begin
            g_thr_var <= math_base_var - mat_out_prod[85:0]; 
            g_st_phase <= 3;
            g_fetch_idx <= 0; g_rsp_idx <= 0;
        end

        if (c2_main_st == S_G_SCN) begin
            if (g_fetch_idx < 1024 && ar_valid) 
                g_fetch_idx <= g_fetch_idx + 1;
            if (sq_pop_cmd) begin
                g_rsp_idx <= g_rsp_idx + 1;
                if (g_st_phase == 1 && sq_head_dat[63] == 0) begin
                    g_sum <= g_sum + sq_head_dat[62:32];
                    g_total_cnt <= g_total_cnt + 1;
                    g_sq_sum <= g_sq_sum + mat_out_prod[61:0]; 
                end
            end
            
            if (!f_stall_cond) begin
                if (sq_pop_cmd && g_st_phase == 3) begin
                    p1_vld <= 1;
                    p1_eof <= (g_rsp_idx == 1023); 
                    p1_dat_hold <= sq_head_dat;
                    if (sq_head_dat[63] == 0) begin
                        p1_is_num <= 1;
                        p1_sub_diff <= $signed({1'b0, math_nx}) - $signed({1'b0, g_sum}); 
                    end 
                    else begin
                        p1_is_num <= 0;
                    end
                end 
                else begin
                    p1_vld <= 1'b0;
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx_hi_st <= 0;
        tx_flit_buf <= 0;
        ar_in_flight <= 0;
        rin_dly_1 <= 0; rin_dly_2 <= 0;
        rx_mrg_st <= 0; sq_dat_vld <= 0; 
        rdata_lsb_hold <= 0; merged_rdata_full <= 0;
        sq_lvl_cnt <= 0; sq_wptr <= 0; sq_rptr <= 0; 
        ar_pend_limiter <= 0;
        snoop_q_mem[0] <= 0; snoop_q_mem[1] <= 0;
    end 
    else begin
        if (req_push_tx && !out_fifo_full) begin
            tx_flit_buf <= flit_tmp_dat;
            tx_hi_st <= 1;
        end 
        else if (tx_hi_st && !out_fifo_full) begin
            tx_hi_st <= 0;
        end

        if (r_fifo_rinc && !rin_dly_2) 
            ar_in_flight <= ar_in_flight + 1;
        else if (!r_fifo_rinc && rin_dly_2) 
            ar_in_flight <= ar_in_flight - 1;

        rin_dly_1 <= r_fifo_rinc; 
        rin_dly_2 <= rin_dly_1; 
        sq_dat_vld <= 0;
        
        if (rin_dly_2) begin 
            if (rx_mrg_st == 0) begin
                rdata_lsb_hold <= r_fifo_rdata;
                rx_mrg_st <= 1;
            end 
            else begin
                merged_rdata_full <= {r_fifo_rdata, rdata_lsb_hold};
                sq_dat_vld <= 1; 
                rx_mrg_st <= 0;
            end
        end

        if (sq_dat_vld && !sq_pop_cmd) 
            sq_lvl_cnt <= sq_lvl_cnt + 1;
        else if (!sq_dat_vld && sq_pop_cmd) 
            sq_lvl_cnt <= sq_lvl_cnt - 1;
        
        if (sq_dat_vld) begin
            snoop_q_mem[sq_wptr] <= merged_rdata_full;
            sq_wptr <= sq_wptr + 1;
        end
        if (sq_pop_cmd) 
            sq_rptr <= sq_rptr + 1;
        
        if (ar_valid && !sq_pop_cmd) 
            ar_pend_limiter <= ar_pend_limiter + 1;
        else if (!ar_valid && sq_pop_cmd) 
            ar_pend_limiter <= ar_pend_limiter - 1;
    end
end
endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    
    r_fifo_full,
    r_out_valid,
    r_out_data,

	ar_fifo_empty,
    ar_fifo_rdata,
    ar_fifo_rinc,

    ar_flag_fifo_to_rclk,
    ar_flag_rclk_to_fifo,

	r_flag_fifo_to_wclk,
    r_flag_wclk_to_fifo,

	ar_addr, 
    ar_valid, 
    ar_ready,
    r_data,  
    // r_resp, 
    r_valid, 
    r_ready,

	dram_cmd,  // {CS_n, RAS_n, CAS_n, WE_n}
    dram_ba,
    dram_addr,
    dram_wdata,
    dram_rdata,
    dram_valid
);
input 			clk;
input 			rst_n;

input  		ar_fifo_empty;
output reg		ar_fifo_rinc;
input [31:0] 	ar_fifo_rdata;

input 			r_fifo_full;
output reg 		r_out_valid;
output reg [31:0] r_out_data;
// You can use the the custom flag ports for your design
input  			ar_flag_fifo_to_rclk,r_flag_fifo_to_wclk;
output 			ar_flag_rclk_to_fifo,r_flag_wclk_to_fifo;


output [31:0] ar_addr;
output reg    ar_valid;
output        ar_ready;
output [63:0] r_data;
output        r_valid;
output reg    r_ready;

output reg  [3:0]  dram_cmd;  // {CS_n, RAS_n, CAS_n, WE_n}
output reg  [1:0]  dram_ba;
output reg  [10:0] dram_addr;
output reg  [63:0] dram_wdata;
input [63:0] dram_rdata;
input        dram_valid;

assign ar_flag_rclk_to_fifo = ar_fifo_rinc;  
assign r_flag_wclk_to_fifo = r_out_valid;    

localparam D_NOP  = 4'b0111, D_ACT  = 4'b0011, D_READ = 4'b0101, D_PRE  = 4'b0010;
localparam C_IDLE = 0, C_ACT = 1, C_WAIT_RCD = 2, C_READ = 3, C_WAIT_GAP = 4, C_PRE = 5, C_WAIT_RP = 6;

reg [2:0] mem_fsm;
reg [2:0] mem_tmr;
reg [1:0] trg_bk; 
reg [5:0] trg_rw; 
reg [7:0] trg_cl;
reg       bk_open_st [0:3]; 
reg [5:0] bk_row_id  [0:3];

reg [31:0] ar_cmd_q [0:1];
reg q_wr_idx, q_rd_idx;
reg [1:0] q_count, rx_flight_ar;

wire q_not_empty;
wire [31:0] active_cmd;
wire [2:0] total_ar_inbound;
wire  fsm_takes_cmd;

assign q_not_empty = (q_count > 0);
assign active_cmd = ar_cmd_q[q_rd_idx];
assign total_ar_inbound = {1'b0, q_count} + {1'b0, rx_flight_ar};
assign fsm_takes_cmd = q_not_empty && (mem_fsm == C_IDLE || mem_fsm == C_WAIT_GAP);

reg ar_dly1, ar_dly2;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_flight_ar <= 0;
        q_count <= 0; 
        q_wr_idx <= 0; 
        q_rd_idx <= 0;
        ar_dly1 <= 0; 
        ar_dly2 <= 0;
        ar_cmd_q[0] <= 0;
        ar_cmd_q[1] <= 0;
    end 
    else begin
        if (ar_fifo_rinc && !ar_dly2) 
            rx_flight_ar <= rx_flight_ar + 1;
        else if (!ar_fifo_rinc && ar_dly2) 
            rx_flight_ar <= rx_flight_ar - 1;

        ar_dly1 <= ar_fifo_rinc; 
        ar_dly2 <= ar_dly1;
        
        if (ar_dly2 && !fsm_takes_cmd) 
            q_count <= q_count + 1;
        else if (!ar_dly2 && fsm_takes_cmd) 
            q_count <= q_count - 1;
        
        if (ar_dly2) begin
            ar_cmd_q[q_wr_idx] <= ar_fifo_rdata;
            q_wr_idx <= q_wr_idx + 1;
        end
        if (fsm_takes_cmd) 
            q_rd_idx <= q_rd_idx + 1;
    end
end

assign ar_ready = rst_n ? 1 : 0;
assign ar_addr  = rst_n ? (ar_valid ? active_cmd : 0) : 0;

always @(*) begin
    ar_fifo_rinc = rst_n ? (!ar_fifo_empty && (total_ar_inbound < 2)) : 0;
    ar_valid     = rst_n ? fsm_takes_cmd : 0;
    r_ready      = rst_n ? 1 : 0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem_fsm <= C_IDLE;
        mem_tmr <= 0; 
        dram_cmd <= D_NOP;
        dram_wdata <= 0; 
        dram_ba <= 2'b0; 
        dram_addr <= 11'b0;
        bk_open_st[0] <= 0; bk_open_st[1] <= 0; bk_open_st[2] <= 0; bk_open_st[3] <= 0;
        bk_row_id[0] <= 0; bk_row_id[1] <= 0; bk_row_id[2] <= 0; bk_row_id[3] <= 0;
        trg_bk <= 0; trg_rw <= 0; trg_cl <= 0;
    end 
    else begin
        dram_cmd <= D_NOP; 
        dram_wdata <= 0;
        
        case (mem_fsm)
            C_IDLE: begin
                if (q_not_empty) begin
                    trg_bk <= active_cmd[15:14];
                    trg_rw <= active_cmd[13:8]; 
                    trg_cl <= active_cmd[7:0];
                    if (!bk_open_st[active_cmd[15:14]]) 
                        mem_fsm <= C_ACT; 
                    else if (bk_row_id[active_cmd[15:14]] == active_cmd[13:8]) 
                        mem_fsm <= C_READ;
                    else 
                        mem_fsm <= C_PRE;
                end
            end
            C_ACT: begin
                dram_cmd <= D_ACT;
                dram_ba <= trg_bk; 
                dram_addr <= {5'b0, trg_rw};
                mem_tmr <= 0; 
                mem_fsm <= C_WAIT_RCD;
            end
            C_WAIT_RCD: begin
                if (mem_tmr == 0) mem_fsm <= C_READ;
                else mem_tmr <= mem_tmr - 1;
            end
            C_READ: begin
                dram_cmd <= D_READ;
                dram_ba <= trg_bk; 
                dram_addr <= {3'b0, trg_cl};
                bk_open_st[trg_bk] <= 1'b1; 
                bk_row_id[trg_bk] <= trg_rw;
                mem_fsm <= C_WAIT_GAP;
            end
            C_WAIT_GAP: begin
                if (q_not_empty) begin
                    trg_bk <= active_cmd[15:14];
                    trg_rw <= active_cmd[13:8]; 
                    trg_cl <= active_cmd[7:0];
                    if (!bk_open_st[active_cmd[15:14]]) 
                        mem_fsm <= C_ACT; 
                    else if (bk_row_id[active_cmd[15:14]] == active_cmd[13:8]) 
                        mem_fsm <= C_READ;
                    else 
                        mem_fsm <= C_PRE; 
                end 
                else mem_fsm <= C_IDLE;
            end
            C_PRE: begin
                dram_cmd <= D_PRE;
                dram_ba <= trg_bk;
                bk_open_st[trg_bk] <= 0; 
                mem_tmr <= 1; 
                mem_fsm <= C_WAIT_RP;
            end
            C_WAIT_RP: begin
                if (mem_tmr == 0) 
                    mem_fsm <= C_ACT;
                else 
                    mem_tmr <= mem_tmr - 1;
            end
        endcase
    end
end

reg out_slice_st;
reg [63:0] sram_hi_hold;
reg d_vld_buf; 
reg [63:0] d_dat_buf;

always @(*) begin
    r_out_valid = 0;
    r_out_data  = 0;
    if (rst_n) begin
        if (out_slice_st == 0) begin
            if (d_vld_buf && !r_fifo_full) begin
                r_out_valid = 1;
                r_out_data  = d_dat_buf[31:0];
            end
        end 
        else begin
            if (!r_fifo_full) begin
                r_out_valid = 1;
                r_out_data  = sram_hi_hold[63:32];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_slice_st <= 0; 
        sram_hi_hold <= 0;
        d_vld_buf <= 0; 
        d_dat_buf <= 0;
    end 
    else begin
        d_vld_buf <= dram_valid; 
        d_dat_buf <= dram_rdata;
        if (out_slice_st == 0) begin
            if (d_vld_buf && !r_fifo_full) begin
                sram_hi_hold <= d_dat_buf; 
                out_slice_st <= 1;
            end
        end 
        else begin
            if (!r_fifo_full) begin
                out_slice_st <= 0;
            end
        end
    end
end

assign r_valid = rst_n ? d_vld_buf : 0;
assign r_data  = rst_n ? (d_vld_buf ? d_dat_buf : 0) : 0;

endmodule