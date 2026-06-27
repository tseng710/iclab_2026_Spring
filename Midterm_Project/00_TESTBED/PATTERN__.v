//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`include "../00_TESTBED/DRAM_MAP_define.v"
`include "../00_TESTBED/pseudo_DRAM_inst1.v"
`include "../00_TESTBED/pseudo_DRAM_inst2.v"
`include "../00_TESTBED/pseudo_DRAM_data.v"

// ================================================================
// USER CUSTOMIZATION AREA 
// ================================================================
`ifdef RTL
    `define CYCLE_TIME 3.7
`elsif GATE
    `define CYCLE_TIME 3.7
`elsif CHIP
    `define CYCLE_TIME 3.7
`elsif POST
    `define CYCLE_TIME 3.7
`endif

//---------------------------------------------------------------------
//   TA DEMO FLAG
//---------------------------------------------------------------------
parameter flag_gen = 0;
integer seed =  233252;

`ifndef FUNC
  `ifndef PERF
    `define FUNC
  `endif
`endif

`ifdef FUNC
    `define PAT_NUM 952
    `define MAX_WAIT_READY_CYCLE 2000
`endif
`ifdef PERF
    `define PAT_NUM 952
    `define MAX_WAIT_READY_CYCLE 100000
`endif

// ========================================
// ANSI Color Macros
// ========================================
`define C_RST  "\033[0m"
`define C_RED  "\033[1;31m"
`define C_GRN  "\033[1;32m"
`define C_YLW  "\033[1;33m"
`define C_CYN  "\033[1;36m"
`define C_WHT  "\033[1;37m"
`define C_PUR  "\033[1;35m"

// ========================================
// Flat Register Array Mapping
// ========================================
`define REG_C1(idx) rtl_core1_r[idx]
`define REG_C2(idx) rtl_core2_r[idx]

module PATTERN(
    output reg clk,
    output reg rst_n,
    input stall_1,
    input stall_2,

    // AXI4 Interface: Instruction DRAM 1 (Slave)
    input  wire [3:0]  awid_s_inf_inst_1, input  wire [31:0] awaddr_s_inf_inst_1, input  wire [6:0]  awlen_s_inf_inst_1, input  wire [2:0]  awsize_s_inf_inst_1, input  wire [1:0]  awburst_s_inf_inst_1, input  wire        awvalid_s_inf_inst_1, output wire        awready_s_inf_inst_1,
    input  wire [15:0] wdata_s_inf_inst_1, input  wire        wlast_s_inf_inst_1, input  wire        wvalid_s_inf_inst_1, output wire        wready_s_inf_inst_1,
    output wire [3:0]  bid_s_inf_inst_1, output wire [1:0]  bresp_s_inf_inst_1, output wire        bvalid_s_inf_inst_1, input  wire        bready_s_inf_inst_1,
    input  wire [3:0]  arid_s_inf_inst_1, input  wire [31:0] araddr_s_inf_inst_1, input  wire [6:0]  arlen_s_inf_inst_1, input  wire [2:0]  arsize_s_inf_inst_1, input  wire [1:0]  arburst_s_inf_inst_1, input  wire        arvalid_s_inf_inst_1, output wire        arready_s_inf_inst_1,
    output wire [3:0]  rid_s_inf_inst_1, output wire [15:0] rdata_s_inf_inst_1, output wire [1:0]  rresp_s_inf_inst_1, output wire        rlast_s_inf_inst_1, output wire        rvalid_s_inf_inst_1, input  wire        rready_s_inf_inst_1,

    // AXI4 Interface: Instruction DRAM 2 (Slave)
    input  wire [3:0]  awid_s_inf_inst_2, input  wire [31:0] awaddr_s_inf_inst_2, input  wire [6:0]  awlen_s_inf_inst_2, input  wire [2:0]  awsize_s_inf_inst_2, input  wire [1:0]  awburst_s_inf_inst_2, input  wire        awvalid_s_inf_inst_2, output wire        awready_s_inf_inst_2,
    input  wire [15:0] wdata_s_inf_inst_2, input  wire        wlast_s_inf_inst_2, input  wire        wvalid_s_inf_inst_2, output wire        wready_s_inf_inst_2,
    output wire [3:0]  bid_s_inf_inst_2, output wire [1:0]  bresp_s_inf_inst_2, output wire        bvalid_s_inf_inst_2, input  wire        bready_s_inf_inst_2,
    input  wire [3:0]  arid_s_inf_inst_2, input  wire [31:0] araddr_s_inf_inst_2, input  wire [6:0]  arlen_s_inf_inst_2, input  wire [2:0]  arsize_s_inf_inst_2, input  wire [1:0]  arburst_s_inf_inst_2, input  wire        arvalid_s_inf_inst_2, output wire        arready_s_inf_inst_2,
    output wire [3:0]  rid_s_inf_inst_2, output wire [15:0] rdata_s_inf_inst_2, output wire [1:0]  rresp_s_inf_inst_2, output wire        rlast_s_inf_inst_2, output wire        rvalid_s_inf_inst_2, input  wire        rready_s_inf_inst_2,

    // AXI4 Interface: Data DRAM (Slave)
    input  wire [3:0]  awid_s_inf_data, input  wire [31:0] awaddr_s_inf_data, input  wire [6:0]  awlen_s_inf_data, input  wire [2:0]  awsize_s_inf_data, input  wire [1:0]  awburst_s_inf_data, input  wire        awvalid_s_inf_data, output wire        awready_s_inf_data,
    input  wire [15:0] wdata_s_inf_data, input  wire        wlast_s_inf_data, input  wire        wvalid_s_inf_data, output wire        wready_s_inf_data,
    output wire [3:0]  bid_s_inf_data, output wire [1:0]  bresp_s_inf_data, output wire        bvalid_s_inf_data, input  wire        bready_s_inf_data,
    input  wire [3:0]  arid_s_inf_data, input  wire [31:0] araddr_s_inf_data, input  wire [6:0]  arlen_s_inf_data, input  wire [2:0]  arsize_s_inf_data, input  wire [1:0]  arburst_s_inf_data, input  wire        arvalid_s_inf_data, output wire        arready_s_inf_data,
    output wire [3:0]  rid_s_inf_data, output wire [15:0] rdata_s_inf_data, output wire [1:0]  rresp_s_inf_data, output wire        rlast_s_inf_data, output wire        rvalid_s_inf_data, input  wire        rready_s_inf_data
);

//
wire [15:0] rtl_core1_r [0:7];
assign rtl_core1_r[0] = TESTBED.u_DCCPU.core_1_r0; assign rtl_core1_r[1] = TESTBED.u_DCCPU.core_1_r1;
assign rtl_core1_r[2] = TESTBED.u_DCCPU.core_1_r2; assign rtl_core1_r[3] = TESTBED.u_DCCPU.core_1_r3;
assign rtl_core1_r[4] = TESTBED.u_DCCPU.core_1_r4; assign rtl_core1_r[5] = TESTBED.u_DCCPU.core_1_r5;
assign rtl_core1_r[6] = TESTBED.u_DCCPU.core_1_r6; assign rtl_core1_r[7] = TESTBED.u_DCCPU.core_1_r7;

wire [15:0] rtl_core2_r [0:7];
assign rtl_core2_r[0] = TESTBED.u_DCCPU.core_2_r0; assign rtl_core2_r[1] = TESTBED.u_DCCPU.core_2_r1;
assign rtl_core2_r[2] = TESTBED.u_DCCPU.core_2_r2; assign rtl_core2_r[3] = TESTBED.u_DCCPU.core_2_r3;
assign rtl_core2_r[4] = TESTBED.u_DCCPU.core_2_r4; assign rtl_core2_r[5] = TESTBED.u_DCCPU.core_2_r5;
assign rtl_core2_r[6] = TESTBED.u_DCCPU.core_2_r6; assign rtl_core2_r[7] = TESTBED.u_DCCPU.core_2_r7;

//
integer total_latency, latency_1, latency_2;
integer i, core1_ic, core2_ic, next_dram_check_ic;
integer flush_timeout;
integer pending_dram_check;
integer halt_grace_period; 

reg signed [15:0] golden_reg_core1 [0:`PAT_NUM-1][0:7];
reg signed [15:0] golden_reg_core2 [0:`PAT_NUM-1][0:7];
reg [15:0] inst_1_mem [0:4095];
reg [15:0] inst_2_mem [0:4095];

reg [15:0] init_dram_data   [0:4095];
reg [15:0] golden_dram_data [0:4095];
reg [15:0] dram_snapshots [1:(`PAT_NUM/50 + 1)][0:4095];
reg [15:0] trace_inst_1 [0:`PAT_NUM-1];
reg [15:0] trace_inst_2 [0:`PAT_NUM-1];

// 
reg [12:0] pc_trace_1 [0:`PAT_NUM-1];
reg [12:0] pc_trace_2 [0:`PAT_NUM-1];

real final_perf_score;

//
reg core1_halted, core2_halted, sim_halt_condition;

always @(*) begin
    core1_halted = (core1_ic > 0) && (pc_trace_1[core1_ic-1] == 4095);
    core2_halted = (core2_ic > 0) && (pc_trace_2[core2_ic-1] == 4095);
    sim_halt_condition = core1_halted && core2_halted && (core1_ic == core2_ic);
end


//
reg [31:0] outstanding_writes;
reg [31:0] outstanding_aw_d;
reg [31:0] outstanding_w_d;
reg [31:0] out_r_1, out_r_2, out_r_d;
reg [31:0] inflight_r_timer_1, inflight_r_timer_2, inflight_r_timer_d;
reg [31:0] inflight_w_timer_d;

reg prev_arvalid_1_track, prev_arready_1_track;
reg prev_arvalid_2_track, prev_arready_2_track;
reg prev_arvalid_d_track, prev_arready_d_track;
reg prev_awvalid_d_track, prev_awready_d_track;
reg prev_wvalid_d_track,  prev_wready_d_track;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        outstanding_aw_d <= 0;
        outstanding_w_d <= 0;
        out_r_1 <= 0; out_r_2 <= 0; out_r_d <= 0;
        inflight_r_timer_1 <= 0; inflight_r_timer_2 <= 0; inflight_r_timer_d <= 0;
        inflight_w_timer_d <= 0;
        
        prev_arvalid_1_track <= 0; prev_arready_1_track <= 0;
        prev_arvalid_2_track <= 0; prev_arready_2_track <= 0;
        prev_arvalid_d_track <= 0; prev_arready_d_track <= 0;
        prev_awvalid_d_track <= 0; prev_awready_d_track <= 0;
        prev_wvalid_d_track  <= 0; prev_wready_d_track  <= 0;
    end 
    else begin
        prev_arvalid_1_track <= arvalid_s_inf_inst_1; prev_arready_1_track <= arready_s_inf_inst_1;
        prev_arvalid_2_track <= arvalid_s_inf_inst_2; prev_arready_2_track <= arready_s_inf_inst_2;
        prev_arvalid_d_track <= arvalid_s_inf_data;   prev_arready_d_track <= arready_s_inf_data;
        prev_awvalid_d_track <= awvalid_s_inf_data;   prev_awready_d_track <= awready_s_inf_data;
        prev_wvalid_d_track  <= wvalid_s_inf_data;    prev_wready_d_track  <= wready_s_inf_data;

        if ((awvalid_s_inf_data && awready_s_inf_data) && !(bvalid_s_inf_data && bready_s_inf_data)) 
            outstanding_aw_d <= outstanding_aw_d + 1;
        else if (!(awvalid_s_inf_data && awready_s_inf_data) && (bvalid_s_inf_data && bready_s_inf_data)) 
            outstanding_aw_d <= outstanding_aw_d - 1;

        if ((wvalid_s_inf_data && wready_s_inf_data && wlast_s_inf_data) && !(bvalid_s_inf_data && bready_s_inf_data)) 
            outstanding_w_d <= outstanding_w_d + 1;
        else if (!(wvalid_s_inf_data && wready_s_inf_data && wlast_s_inf_data) && (bvalid_s_inf_data && bready_s_inf_data)) 
            outstanding_w_d <= outstanding_w_d - 1;

        if (outstanding_aw_d > 0 || outstanding_w_d > 0) 
            inflight_w_timer_d <= inflight_w_timer_d + 1;
        else 
            inflight_w_timer_d <= 0;

        if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1 && !(rvalid_s_inf_inst_1 && rready_s_inf_inst_1 && rlast_s_inf_inst_1)) 
            out_r_1 <= out_r_1 + 1;
        else if (!(arvalid_s_inf_inst_1 && arready_s_inf_inst_1) && (rvalid_s_inf_inst_1 && rready_s_inf_inst_1 && rlast_s_inf_inst_1)) 
            out_r_1 <= out_r_1 - 1;

        if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2 && !(rvalid_s_inf_inst_2 && rready_s_inf_inst_2 && rlast_s_inf_inst_2)) out_r_2 <= out_r_2 + 1;
        else if (!(arvalid_s_inf_inst_2 && arready_s_inf_inst_2) && (rvalid_s_inf_inst_2 && rready_s_inf_inst_2 && rlast_s_inf_inst_2)) out_r_2 <= out_r_2 - 1;

        if (arvalid_s_inf_data && arready_s_inf_data && !(rvalid_s_inf_data && rready_s_inf_data && rlast_s_inf_data)) out_r_d <= out_r_d + 1;
        else if (!(arvalid_s_inf_data && arready_s_inf_data) && (rvalid_s_inf_data && rready_s_inf_data && rlast_s_inf_data)) out_r_d <= out_r_d - 1;

        if (out_r_1 > 0) inflight_r_timer_1 <= inflight_r_timer_1 + 1; else inflight_r_timer_1 <= 0;
        if (out_r_2 > 0) inflight_r_timer_2 <= inflight_r_timer_2 + 1; else inflight_r_timer_2 <= 0;
        if (out_r_d > 0) inflight_r_timer_d <= inflight_r_timer_d + 1; else inflight_r_timer_d <= 0;

        if (inflight_r_timer_1 > 2000 || inflight_r_timer_2 > 2000 || inflight_r_timer_d > 2000 || inflight_w_timer_d > 2000) begin
            $display("\n%s========================================================%s", `C_RED, `C_RST);
            $display("%s   [ERROR] AXI Transaction Deadlock!%s", `C_RED, `C_RST);
            $display("%s   A Read/Write transaction started but never completed (RLAST/BVALID) after 2000 cycles.%s", `C_RED, `C_RST);
            $display("%s   (Check if your state machine is stuck waiting for AXI)%s", `C_RED, `C_RST);
            $display("%s========================================================%s\n", `C_RED, `C_RST);
            
            display_wrong;
            $finish;
        end
    end
end
reg [15:0] b_timeout_1, r_timeout_1;
reg [15:0] b_timeout_2, r_timeout_2;
reg [15:0] b_timeout_d, r_timeout_d;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        b_timeout_1 <= 0; r_timeout_1 <= 0;
        b_timeout_2 <= 0; r_timeout_2 <= 0;
        b_timeout_d <= 0; r_timeout_d <= 0;
    end 
    else begin
        if (bvalid_s_inf_inst_1 && !bready_s_inf_inst_1) b_timeout_1 <= b_timeout_1 + 1; else b_timeout_1 <= 0;
        if (rvalid_s_inf_inst_1 && !rready_s_inf_inst_1) r_timeout_1 <= r_timeout_1 + 1; else r_timeout_1 <= 0;

        if (bvalid_s_inf_inst_2 && !bready_s_inf_inst_2) b_timeout_2 <= b_timeout_2 + 1; else b_timeout_2 <= 0;
        if (rvalid_s_inf_inst_2 && !rready_s_inf_inst_2) r_timeout_2 <= r_timeout_2 + 1; else r_timeout_2 <= 0;

        if (bvalid_s_inf_data && !bready_s_inf_data) b_timeout_d <= b_timeout_d + 1; else b_timeout_d <= 0;
        if (rvalid_s_inf_data && !rready_s_inf_data) r_timeout_d <= r_timeout_d + 1; else r_timeout_d <= 0;

        if (b_timeout_1 > 300 || r_timeout_1 > 300 || 
            b_timeout_2 > 300 || r_timeout_2 > 300 || 
            b_timeout_d > 300 || r_timeout_d > 300) begin
            $display("\n%s========================================================%s", `C_RED, `C_RST);
            $display("%s   [ERROR] AXI Latency Violation! (Spec Rule #20)%s", `C_RED, `C_RST);
            $display("%s   Latency between BVALID/BREADY or RVALID/RREADY exceeded 300 cycles!%s", `C_RED, `C_RST);
            $display("%s========================================================%s\n", `C_RED, `C_RST);
            
            display_wrong;
            $finish;
        end
    end
end

always @(posedge clk) begin
    if (rst_n) begin
        //
        if (prev_arvalid_1_track && !prev_arready_1_track && !arvalid_s_inf_inst_1) begin
            $display("\n%s[AXI FATAL ERROR] Core 1 ARVALID dropped before ARREADY!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        if (prev_arvalid_2_track && !prev_arready_2_track && !arvalid_s_inf_inst_2) begin
            $display("\n%s[AXI FATAL ERROR] Core 2 ARVALID dropped before ARREADY!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        if (prev_arvalid_d_track && !prev_arready_d_track && !arvalid_s_inf_data) begin
            $display("\n%s[AXI FATAL ERROR] Data ARVALID dropped before ARREADY!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        if (prev_awvalid_d_track && !prev_awready_d_track && !awvalid_s_inf_data) begin
            $display("\n%s[AXI FATAL ERROR] Data AWVALID dropped before AWREADY!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        if (prev_wvalid_d_track && !prev_wready_d_track && !wvalid_s_inf_data) begin
            $display("\n%s[AXI FATAL ERROR] Data WVALID dropped before WREADY!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        
        if (awvalid_s_inf_inst_1 || wvalid_s_inf_inst_1 || awvalid_s_inf_inst_2 || wvalid_s_inf_inst_2) begin
            $display("\n%s[ERROR] Instruction DRAM is READ ONLY! You cannot Write to it!%s", `C_RED, `C_RST); display_wrong; $finish;
        end
        
        if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1) begin
            if (arsize_s_inf_inst_1 !== 3'b001) begin $display("\n%s[ERROR] arsize_s_inf_inst_1 MUST be 3'b001 (2 Bytes)%s", `C_RED, `C_RST); display_wrong; $finish; end
            if (arburst_s_inf_inst_1 !== 2'b01) begin $display("\n%s[ERROR] arburst_s_inf_inst_1 MUST be 2'b01 (INCR)%s", `C_RED, `C_RST); display_wrong; $finish; end
        end
        if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2) begin
            if (arsize_s_inf_inst_2 !== 3'b001) begin $display("\n%s[ERROR] arsize_s_inf_inst_2 MUST be 3'b001 (2 Bytes)%s", `C_RED, `C_RST); display_wrong; $finish; end
            if (arburst_s_inf_inst_2 !== 2'b01) begin $display("\n%s[ERROR] arburst_s_inf_inst_2 MUST be 2'b01 (INCR)%s", `C_RED, `C_RST); display_wrong; $finish; end
        end
        if (arvalid_s_inf_data && arready_s_inf_data) begin
            if (arsize_s_inf_data !== 3'b001) begin $display("\n%s[ERROR] arsize_s_inf_data MUST be 3'b001 (2 Bytes)%s", `C_RED, `C_RST); display_wrong; $finish; end
            if (arburst_s_inf_data !== 2'b01) begin $display("\n%s[ERROR] arburst_s_inf_data MUST be 2'b01 (INCR)%s", `C_RED, `C_RST); display_wrong; $finish; end
        end
        if (awvalid_s_inf_data && awready_s_inf_data) begin
            if (awsize_s_inf_data !== 3'b001) begin $display("\n%s[ERROR] awsize_s_inf_data MUST be 3'b001 (2 Bytes)%s", `C_RED, `C_RST); display_wrong; $finish; end
            if (awburst_s_inf_data !== 2'b01) begin $display("\n%s[ERROR] awburst_s_inf_data MUST be 2'b01 (INCR)%s", `C_RED, `C_RST); display_wrong; $finish; end
        end
    end
end

// 
reg prev_stall_1, prev_stall_2;
always @(negedge clk) begin
    if (!rst_n) begin
        prev_stall_1 <= 1;
        prev_stall_2 <= 1;
    end 
    else begin
        if (stall_1 === 0 && prev_stall_1 === 0) $display("\n%s   [WARNING] stall_1 is LOW for 2 consecutive cycles! TA counts this as 2 instructions!%s", `C_YLW, `C_RST);
        if (stall_2 === 0 && prev_stall_2 === 0) $display("\n%s   [WARNING] stall_2 is LOW for 2 consecutive cycles! TA counts this as 2 instructions!%s", `C_YLW, `C_RST);
        prev_stall_1 <= stall_1; prev_stall_2 <= stall_2;
    end
end

pseudo_DRAM_inst1 u_inst1_dram (
    .clk(clk), .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_inst_1), .awaddr_s_inf(awaddr_s_inf_inst_1), .awlen_s_inf(awlen_s_inf_inst_1), .awsize_s_inf(awsize_s_inf_inst_1), .awburst_s_inf(awburst_s_inf_inst_1), .awvalid_s_inf(awvalid_s_inf_inst_1), .awready_s_inf(awready_s_inf_inst_1),
    .wdata_s_inf(wdata_s_inf_inst_1), .wlast_s_inf(wlast_s_inf_inst_1), .wvalid_s_inf(wvalid_s_inf_inst_1), .wready_s_inf(wready_s_inf_inst_1),
    .bid_s_inf(bid_s_inf_inst_1), .bresp_s_inf(bresp_s_inf_inst_1), .bvalid_s_inf(bvalid_s_inf_inst_1), .bready_s_inf(bready_s_inf_inst_1),
    .arid_s_inf(arid_s_inf_inst_1), .araddr_s_inf(araddr_s_inf_inst_1), .arlen_s_inf(arlen_s_inf_inst_1), .arsize_s_inf(arsize_s_inf_inst_1), .arburst_s_inf(arburst_s_inf_inst_1), .arvalid_s_inf(arvalid_s_inf_inst_1), .arready_s_inf(arready_s_inf_inst_1),
    .rid_s_inf(rid_s_inf_inst_1), .rdata_s_inf(rdata_s_inf_inst_1), .rresp_s_inf(rresp_s_inf_inst_1), .rlast_s_inf(rlast_s_inf_inst_1), .rvalid_s_inf(rvalid_s_inf_inst_1), .rready_s_inf(rready_s_inf_inst_1)
);

pseudo_DRAM_inst2 u_inst2_dram (
    .clk(clk), .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_inst_2), .awaddr_s_inf(awaddr_s_inf_inst_2), .awlen_s_inf(awlen_s_inf_inst_2), .awsize_s_inf(awsize_s_inf_inst_2), .awburst_s_inf(awburst_s_inf_inst_2), .awvalid_s_inf(awvalid_s_inf_inst_2), .awready_s_inf(awready_s_inf_inst_2),
    .wdata_s_inf(wdata_s_inf_inst_2), .wlast_s_inf(wlast_s_inf_inst_2), .wvalid_s_inf(wvalid_s_inf_inst_2), .wready_s_inf(wready_s_inf_inst_2),
    .bid_s_inf(bid_s_inf_inst_2), .bresp_s_inf(bresp_s_inf_inst_2), .bvalid_s_inf(bvalid_s_inf_inst_2), .bready_s_inf(bready_s_inf_inst_2),
    .arid_s_inf(arid_s_inf_inst_2), .araddr_s_inf(araddr_s_inf_inst_2), .arlen_s_inf(arlen_s_inf_inst_2), .arsize_s_inf(arsize_s_inf_inst_2), .arburst_s_inf(arburst_s_inf_inst_2), .arvalid_s_inf(arvalid_s_inf_inst_2), .arready_s_inf(arready_s_inf_inst_2),
    .rid_s_inf(rid_s_inf_inst_2), .rdata_s_inf(rdata_s_inf_inst_2), .rresp_s_inf(rresp_s_inf_inst_2), .rlast_s_inf(rlast_s_inf_inst_2), .rvalid_s_inf(rvalid_s_inf_inst_2), .rready_s_inf(rready_s_inf_inst_2)
);

pseudo_DRAM_data u_data_dram (
    .clk(clk), .rst_n(rst_n),
    .awid_s_inf(awid_s_inf_data), .awaddr_s_inf(awaddr_s_inf_data), .awlen_s_inf(awlen_s_inf_data), .awsize_s_inf(awsize_s_inf_data), .awburst_s_inf(awburst_s_inf_data), .awvalid_s_inf(awvalid_s_inf_data), .awready_s_inf(awready_s_inf_data),
    .wdata_s_inf(wdata_s_inf_data), .wlast_s_inf(wlast_s_inf_data), .wvalid_s_inf(wvalid_s_inf_data), .wready_s_inf(wready_s_inf_data),
    .bid_s_inf(bid_s_inf_data), .bresp_s_inf(bresp_s_inf_data), .bvalid_s_inf(bvalid_s_inf_data), .bready_s_inf(bready_s_inf_data),
    .arid_s_inf(arid_s_inf_data), .araddr_s_inf(araddr_s_inf_data), .arlen_s_inf(arlen_s_inf_data), .arsize_s_inf(arsize_s_inf_data), .arburst_s_inf(arburst_s_inf_data), .arvalid_s_inf(arvalid_s_inf_data), .arready_s_inf(arready_s_inf_data),
    .rid_s_inf(rid_s_inf_data), .rdata_s_inf(rdata_s_inf_data), .rresp_s_inf(rresp_s_inf_data), .rlast_s_inf(rlast_s_inf_data), .rvalid_s_inf(rvalid_s_inf_data), .rready_s_inf(rready_s_inf_data)
);

always #(`CYCLE_TIME/2.0) clk = ~clk;

initial begin
    generate_instructions_and_data;

    if (flag_gen) begin
        $display("\n%s[INFO] PATTERN GENERATION MODE: .dat files generated successfully. (flag_gen = 1)%s\n", `C_GRN, `C_RST);
        $finish;
    end

    force clk = 0;
    rst_n = 1;
    total_latency = 0;
    latency_1 = 0;
    latency_2 = 0;
    core1_ic = 0;
    core2_ic = 0; 
    next_dram_check_ic = 50;
    pending_dram_check = 0; 

    #(100 * `CYCLE_TIME); 
    
    reset_task;
    release clk;

    check_execution_task;
    
    $display("%s========================================================%s", `C_GRN, `C_RST);
    $display("%s   [Performance Dashboard]%s", `C_CYN, `C_RST);
    $display("%s   Total Cycles (C)  : %0d %s", `C_WHT, total_latency, `C_RST);
    $display("%s   Clock Period (T)  : %.2f ns %s", `C_WHT, `CYCLE_TIME, `C_RST);
    $display("%s========================================================%s", `C_GRN, `C_RST);
    display_success;
    $finish;
end

task reset_task;
    integer reg_idx;
    begin
        #(10);
        rst_n = 0;
        #(20);
        rst_n = 1;
        #(3 * `CYCLE_TIME);

        if (stall_1 !== 1 || stall_2 !== 1) begin
            $display("\n%s[ERROR] stall_1 & stall_2 MUST be HIGH after reset!%s", `C_RED, `C_RST);
            display_wrong;
            $finish;
        end
        
        if (awvalid_s_inf_inst_1 !== 0 || wvalid_s_inf_inst_1 !== 0 || arvalid_s_inf_inst_1 !== 0 ||
            awvalid_s_inf_inst_2 !== 0 || wvalid_s_inf_inst_2 !== 0 || arvalid_s_inf_inst_2 !== 0 ||
            awvalid_s_inf_data !== 0   || wvalid_s_inf_data !== 0   || arvalid_s_inf_data !== 0) begin
            
            $display("\n%s========================================================%s", `C_RED, `C_RST);
            $display("%s   [ERROR] AXI output signals (Valid DFFs) are NOT zero after reset!%s", `C_RED, `C_RST);
            $display("%s   awvalid_1: %b, wvalid_1: %b, arvalid_1: %b%s", `C_RED, awvalid_s_inf_inst_1, wvalid_s_inf_inst_1, arvalid_s_inf_inst_1, `C_RST);
            $display("%s   awvalid_2: %b, wvalid_2: %b, arvalid_2: %b%s", `C_RED, awvalid_s_inf_inst_2, wvalid_s_inf_inst_2, arvalid_s_inf_inst_2, `C_RST);
            $display("%s   awvalid_d: %b, wvalid_d: %b, arvalid_d: %b%s", `C_RED, awvalid_s_inf_data, wvalid_s_inf_data, arvalid_s_inf_data, `C_RST);
            $display("%s========================================================%s\n", `C_RED, `C_RST);
            
            display_wrong;
            $finish;
        end

        for (reg_idx = 0; reg_idx < 8; reg_idx = reg_idx + 1) begin
            if (`REG_C1(reg_idx) !== 16'd0 || `REG_C2(reg_idx) !== 16'd0) begin
                $display("\n%s[ERROR] All registers must be ZERO after reset!%s", `C_RED, `C_RST);
                display_wrong;
                $finish;
            end
        end
    end
endtask

task generate_instructions_and_data;
    integer ic, j, f1, f2, fd, k;
    integer pc1, pc2, next_pc1, next_pc2;
    integer jump_offset1, jump_offset2;
    integer last_word_offset1, last_word_offset2;
    integer addr1_index, addr2_index;
    
    integer rs1_val, rs2_val; 
    reg signed [15:0] sim_r1 [0:7];
    reg signed [15:0] sim_r2 [0:7];
    reg signed [31:0] mult_res1, mult_res2;

    reg [2:0] op1, rs1, rt1, rd1, rl1, func1;
    integer temp_imm1;
    reg [12:0] jmp_addr1;
    
    reg [2:0] op2, rs2, rt2, rd2, rl2, func2;
    integer temp_imm2;
    reg [12:0] jmp_addr2;

    reg [3:0] valid_rs_list [0:7];
    integer valid_rs_count;
    integer min_imm, max_imm, target_imm2, inject_hazard;
    integer steps_left, max_next_pc;
    integer distance1, distance2;
    
    reg [2:0] prev_rd1, prev_rt1;
    reg [2:0] prev_rd2, prev_rt2;
    reg gen_flag1 [0:4095];
    reg gen_flag2 [0:4095];
    reg is_new_1, is_new_2;
    integer loop_target;
    integer safe_random_val;
    begin
        pc1 = 0; pc2 = 0;
        last_word_offset1 = 0; last_word_offset2 = 0;
        prev_rd1 = 0; prev_rt1 = 0;
        prev_rd2 = 0; prev_rt2 = 0;

        for (j = 0; j < 4096; j = j + 1) begin
            inst_1_mem[j] = 16'd0;
            inst_2_mem[j] = 16'd0;
            safe_random_val = ($random(seed)) % 100;
            init_dram_data[j] = safe_random_val[15:0]; 
            golden_dram_data[j] = init_dram_data[j];
            gen_flag1[j] = 0;
            gen_flag2[j] = 0;
        end

        loop_target = (`PAT_NUM > 4000) ? ((`PAT_NUM - 3900) / 4) : 0;
        
        if (loop_target > 0) begin
            init_dram_data[0] = loop_target[15:0];
            golden_dram_data[0] = loop_target[15:0];
        end

        for (j = 0; j < 8; j = j + 1) begin
            sim_r1[j] = 16'd0;
            sim_r2[j] = 16'd0;
        end

        for (ic = 0; ic < `PAT_NUM; ic = ic + 1) begin
            steps_left = (`PAT_NUM - 1) - ic;
            is_new_1 = 0; is_new_2 = 0;

            if (!gen_flag1[pc1] || steps_left <= 40) begin
                is_new_1 = 1;
                
                if (loop_target > 0 && pc1 < 6) begin
                    if      (pc1 == 0)  begin op1 = 3'b100; rs1 = 0; rt1 = 7; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end 
                    else if (pc1 == 1)  begin op1 = 3'b011; rs1 = 7; rt1 = 7; temp_imm1 = 1; rd1=0; rl1=0; func1=0; jmp_addr1=0; end 
                    else if (pc1 == 2)  begin op1 = 3'b010; rs1 = 0; rt1 = 6; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end 
                    else if (pc1 == 3)  begin op1 = 3'b110; rs1 = 7; rt1 = 6; temp_imm1 = 2; rd1=0; rl1=0; func1=0; jmp_addr1=0; end 
                    else if (pc1 == 4)  begin op1 = 3'b111; jmp_addr1 = 1 * 2; rs1=0; rt1=0; temp_imm1=0; rd1=0; rl1=0; func1=0; end 
                    else if (pc1 == 5)  begin op1 = 3'b010; rs1 = 0; rt1 = 0; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end 
                end
                else if (loop_target == 0 && pc1 < 12) begin
                    if      (pc1 == 0)  begin op1 = 3'b100; rs1 = 0; rt1 = 7; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 1)  begin op1 = 3'b011; rs1 = 7; rt1 = 7; temp_imm1 = 1; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 2)  begin op1 = 3'b110; rs1 = 7; rt1 = 0; temp_imm1 = 1; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 3)  begin op1 = 3'b111; jmp_addr1 = 1 * 2; rs1=0; rt1=0; temp_imm1=0; rd1=0; rl1=0; func1=0; end
                    else if (pc1 == 4)  begin op1 = 3'b010; rs1 = 0; rt1 = 5; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 5)  begin op1 = 3'b010; rs1 = 0; rt1 = 0; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 6)  begin op1 = 3'b010; rs1 = 0; rt1 = 6; temp_imm1 = 1; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 7)  begin op1 = 3'b110; rs1 = 5; rt1 = 6; temp_imm1 = -3; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 8)  begin op1 = 3'b100; rs1 = 0; rt1 = 3; temp_imm1 = 20; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 9)  begin op1 = 3'b101; rs1 = 0; rt1 = 0; temp_imm1 = 21; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 10) begin op1 = 3'b100; rs1 = 0; rt1 = 4; temp_imm1 = 22; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                    else if (pc1 == 11) begin op1 = 3'b010; rs1 = 0; rt1 = 0; temp_imm1 = 0; rd1=0; rl1=0; func1=0; jmp_addr1=0; end
                end 
                else begin
                    op1 = $unsigned($random(seed)) % 8;
                    rs1 = $random(seed) & 3'b111; rt1 = $random(seed) & 3'b111; rd1 = $random(seed) & 3'b111; rl1 = $random(seed) & 3'b111;
                    func1 = $random(seed) & 3'b111;
                    temp_imm1 = ($random(seed) & 7'h7F) - 64;

                    if ((pc1 >= 12 && pc1 < 64) && loop_target > 0) begin
                        if (pc1 % 5 == 4) begin op1 = 3'b000; rs1 = prev_rt1; rt1 = prev_rd1; end 
                        else if (pc1 % 5 == 0) begin op1 = 3'b001; end 
                        else if (pc1 % 5 == 1) begin op1 = 3'b111; end 
                        else if (pc1 % 5 == 2) begin op1 = 3'b100; end 
                        else if (pc1 % 5 == 3) begin op1 = 3'b101; end
                    end else if (pc1 < 50 && loop_target == 0) begin
                        if (pc1 % 5 == 0) begin op1 = 3'b000; rs1 = prev_rt1; rt1 = prev_rd1; end 
                        else if (pc1 % 5 == 1) begin op1 = 3'b001; end 
                        else if (pc1 % 5 == 2) begin op1 = 3'b111; end 
                        else if (pc1 % 5 == 3) begin op1 = 3'b100; end 
                        else if (pc1 % 5 == 4) begin op1 = 3'b101; end
                    end

                    if (((ic % 50 <= 15) || (ic % 50 >= 35)) && (pc1 >= 12)) begin
                        if (op1 == 3'b101) op1 = 3'b100;
                    end

                    max_next_pc = 4095 - steps_left;

                    if (pc1 == 4095) begin
                        op1 = 3'b111;
                        jmp_addr1 = 4095 * 2;
                    end else if (steps_left <= 40) begin
                        distance1 = 4095 - pc1;
                        if (distance1 > steps_left) begin
                            op1 = 3'b111;
                            jump_offset1 = distance1 - steps_left + 1;
                            if (jump_offset1 > distance1) jump_offset1 = distance1;
                            if (jump_offset1 > 120) jump_offset1 = 120; 
                            jmp_addr1 = (pc1 + jump_offset1) * 2;
                        end 
                        else begin
                            op1 = 3'b010;
                            rs1 = 0; rt1 = 0; temp_imm1 = 0;
                        end
                    end 
                    else begin
                        if (op1 == 3'b111) begin
                            min_imm = 1; 
                            max_imm = (4094 - pc1 < 12) ? (4094 - pc1) : 12; 
                            if (pc1 + max_imm > max_next_pc) max_imm = (max_next_pc > pc1) ? (max_next_pc - pc1) : 0;
                            
                            if (min_imm > max_imm) op1 = 3'b000;
                            else begin
                                jump_offset1 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                                jmp_addr1 = (pc1 + jump_offset1) * 2;
                            end
                        end

                        if (op1 == 3'b110) begin
                            min_imm = 1;
                            max_imm = (4094 - pc1 - 1 < 12) ? (4094 - pc1 - 1) : 12;
                            if (pc1 + 1 + max_imm > max_next_pc) 
                                max_imm = (max_next_pc > pc1 + 1) ? (max_next_pc - pc1 - 1) : 0;
                            if (min_imm > max_imm) begin 
                                op1 = 3'b000; 
                            end else begin
                                if (ic % 7 == 0) temp_imm1 = min_imm;
                                else if (ic % 7 == 1) temp_imm1 = max_imm;
                                else temp_imm1 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                            end
                        end
                    end
                    if (op1 == 3'b001) while (rd1 == rl1) rl1 = $random(seed) & 3'b111;

                    if (op1 == 3'b100 || op1 == 3'b101) begin 
                        valid_rs_count = 0;
                        for (k = 0; k < 8; k = k + 1) begin
                            rs1_val = sim_r1[k];
                            if ((rs1_val + 63 >= 0) && (rs1_val - 64 <= 4095)) begin 
                                if ((rs1_val + 63 >= last_word_offset1 - 100) && (rs1_val - 64 <= last_word_offset1 + 100)) begin
                                    valid_rs_list[valid_rs_count] = k;
                                    valid_rs_count = valid_rs_count + 1;
                                end
                            end
                        end
                        if (valid_rs_count == 0) op1 = 3'b010;
                        else begin
                            rs1 = valid_rs_list[$unsigned($random(seed)) % valid_rs_count];
                            rs1_val = sim_r1[rs1];
                            min_imm = (0 - rs1_val > -64) ? (0 - rs1_val) : -64;
                            max_imm = (4095 - rs1_val < 63) ? (4095 - rs1_val) : 63;
                            if ((last_word_offset1 - 100 - rs1_val) > min_imm) min_imm = last_word_offset1 - 100 - rs1_val;
                            if ((last_word_offset1 + 100 - rs1_val) < max_imm) max_imm = last_word_offset1 + 100 - rs1_val;
                            if (ic % 7 == 0) temp_imm1 = min_imm;
                            else if (ic % 7 == 1) temp_imm1 = max_imm;
                            else temp_imm1 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                            last_word_offset1 = rs1_val + temp_imm1;
                        end
                    end
                end
            end 
            else begin
                op1 = inst_1_mem[pc1][15:13];
                rs1 = inst_1_mem[pc1][12:10]; rt1 = inst_1_mem[pc1][9:7];
                rd1 = inst_1_mem[pc1][6:4]; rl1 = inst_1_mem[pc1][3:1]; func1 = inst_1_mem[pc1][3:1];
                jmp_addr1 = inst_1_mem[pc1][12:0];
                temp_imm1 = inst_1_mem[pc1][6:0];
                if (inst_1_mem[pc1][6]) temp_imm1 = temp_imm1 | 32'hFFFFFF80;
            end

            if (!gen_flag2[pc2] || steps_left <= 40) begin
                is_new_2 = 1;
                
                if (loop_target > 0 && pc2 < 6) begin
                    if      (pc2 == 0)  begin op2 = 3'b100; rs2 = 0; rt2 = 7; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 1)  begin op2 = 3'b011; rs2 = 7; rt2 = 7; temp_imm2 = 1; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 2)  begin op2 = 3'b010; rs2 = 0; rt2 = 6; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 3)  begin op2 = 3'b110; rs2 = 7; rt2 = 6; temp_imm2 = 2; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 4)  begin op2 = 3'b111; jmp_addr2 = 1 * 2; rs2=0; rt2=0; temp_imm2=0; rd2=0; rl2=0; func2=0; end 
                    else if (pc2 == 5)  begin op2 = 3'b010; rs2 = 0; rt2 = 0; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                end 
                else if (loop_target == 0 && pc2 < 12) begin
                    if      (pc2 == 0)  begin op2 = 3'b100; rs2 = 0; rt2 = 7; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 1)  begin op2 = 3'b011; rs2 = 7; rt2 = 7; temp_imm2 = 1; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 2)  begin op2 = 3'b110; rs2 = 7; rt2 = 0; temp_imm2 = 1; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 3)  begin op2 = 3'b111; jmp_addr2 = 1 * 2; rs2=0; rt2=0; temp_imm2=0; rd2=0; rl2=0; func2=0; end
                    else if (pc2 == 4)  begin op2 = 3'b010; rs2 = 0; rt2 = 5; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 5)  begin op2 = 3'b010; rs2 = 0; rt2 = 0; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 6)  begin op2 = 3'b010; rs2 = 0; rt2 = 6; temp_imm2 = 1; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 7)  begin op2 = 3'b110; rs2 = 5; rt2 = 6; temp_imm2 = -3; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 8)  begin op2 = 3'b101; rs2 = 0; rt2 = 0; temp_imm2 = 20; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 9)  begin op2 = 3'b100; rs2 = 0; rt2 = 3; temp_imm2 = 21; rd2=0; rl2=0; func2=0; jmp_addr2=0; end 
                    else if (pc2 == 10) begin op2 = 3'b100; rs2 = 0; rt2 = 5; temp_imm2 = 22; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                    else if (pc2 == 11) begin op2 = 3'b010; rs2 = 0; rt2 = 0; temp_imm2 = 0; rd2=0; rl2=0; func2=0; jmp_addr2=0; end
                end 
                else begin
                    op2 = $unsigned($random(seed)) % 8;
                    rs2 = $random(seed) & 3'b111; rt2 = $random(seed) & 3'b111; rd2 = $random(seed) & 3'b111; rl2 = $random(seed) & 3'b111;
                    func2 = $random(seed) & 3'b111;
                    temp_imm2 = ($random(seed) & 7'h7F) - 64;

                    if ((pc2 >= 12 && pc2 < 64) && loop_target > 0) begin
                        if (pc2 % 5 == 4) begin op2 = 3'b000; rs2 = prev_rt2; rt2 = prev_rd2; end 
                        else if (pc2 % 5 == 0) begin op2 = 3'b001; end 
                        else if (pc2 % 5 == 1) begin op2 = 3'b111; end 
                        else if (pc2 % 5 == 2) begin op2 = 3'b100; end 
                        else if (pc2 % 5 == 3) begin op2 = 3'b101; end
                    end else if (pc2 < 50 && loop_target == 0) begin
                        if (pc2 % 5 == 0) begin op2 = 3'b000; rs2 = prev_rt2; rt2 = prev_rd2; end 
                        else if (pc2 % 5 == 1) begin op2 = 3'b001; end 
                        else if (pc2 % 5 == 2) begin op2 = 3'b111; end 
                        else if (pc2 % 5 == 3) begin op2 = 3'b100; end 
                        else if (pc2 % 5 == 4) begin op2 = 3'b101; end
                    end

                    if (((ic % 50 <= 15) || (ic % 50 >= 35)) && (pc2 >= 12)) begin
                        if (op2 == 3'b101) op2 = 3'b100;
                    end

                    if (op1 == 3'b101 && op2 == 3'b101) begin
                        op2 = 3'b100;
                    end

                    max_next_pc = 4095 - steps_left;

                    if (pc2 == 4095) begin
                        op2 = 3'b111;
                        jmp_addr2 = 4095 * 2;
                    end else if (steps_left <= 40) begin
                        distance2 = 4095 - pc2;
                        if (distance2 > steps_left) begin
                            op2 = 3'b111;
                            jump_offset2 = distance2 - steps_left + 1;
                            if (jump_offset2 > distance2) jump_offset2 = distance2;
                            if (jump_offset2 > 120) jump_offset2 = 120;
                            jmp_addr2 = (pc2 + jump_offset2) * 2;
                        end 
                        else begin
                            op2 = 3'b010;
                            rs2 = 0; rt2 = 0; temp_imm2 = 0;
                        end
                    end 
                    else begin
                        if (op2 == 3'b111) begin // JUMP
                            min_imm = 1;
                            max_imm = (4094 - pc2 < 12) ? (4094 - pc2) : 12;
                            if (pc2 + max_imm > max_next_pc) 
                                max_imm = (max_next_pc > pc2) ? (max_next_pc - pc2) : 0;
                                
                            if (min_imm > max_imm) op2 = 3'b000;
                            else begin
                                jump_offset2 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                                jmp_addr2 = (pc2 + jump_offset2) * 2;
                            end
                        end
                        
                        if (op2 == 3'b110) begin // BEQ
                            min_imm = 1;
                            max_imm = (4094 - pc2 - 1 < 12) ? (4094 - pc2 - 1) : 12;
                            if (pc2 + 1 + max_imm > max_next_pc) 
                                max_imm = (max_next_pc > pc2 + 1) ? (max_next_pc - pc2 - 1) : 0;
                                
                            if (min_imm > max_imm) begin 
                                op2 = 3'b000;
                            end else begin
                                if (ic % 7 == 0) temp_imm2 = min_imm;
                                else if (ic % 7 == 1) temp_imm2 = max_imm;
                                else temp_imm2 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                            end
                        end
                    end
                    if (op2 == 3'b001) while (rd2 == rl2) rl2 = $random(seed) & 3'b111;

                    if (op2 == 3'b100 || op2 == 3'b101) begin 
                        valid_rs_count = 0;
                        for (k = 0; k < 8; k = k + 1) begin
                            rs2_val = sim_r2[k];
                            if ((rs2_val + 63 >= 0) && (rs2_val - 64 <= 4095)) begin
                                if ((rs2_val + 63 >= last_word_offset2 - 100) && (rs2_val - 64 <= last_word_offset2 + 100)) begin
                                    valid_rs_list[valid_rs_count] = k;
                                    valid_rs_count = valid_rs_count + 1;
                                end
                            end
                        end
                        if (valid_rs_count == 0) op2 = 3'b010;
                        else begin
                            rs2 = valid_rs_list[$unsigned($random(seed)) % valid_rs_count];
                            rs2_val = sim_r2[rs2];
                            min_imm = (0 - rs2_val > -64) ? (0 - rs2_val) : -64;
                            max_imm = (4095 - rs2_val < 63) ? (4095 - rs2_val) : 63;
                            if ((last_word_offset2 - 100 - rs2_val) > min_imm) min_imm = last_word_offset2 - 100 - rs2_val;
                            if ((last_word_offset2 + 100 - rs2_val) < max_imm) max_imm = last_word_offset2 + 100 - rs2_val;
                            temp_imm2 = min_imm + ($unsigned($random(seed)) % (max_imm - min_imm + 1));
                            last_word_offset2 = rs2_val + temp_imm2;
                        end
                    end
                end
            end 
            else begin
                op2 = inst_2_mem[pc2][15:13];
                rs2 = inst_2_mem[pc2][12:10]; rt2 = inst_2_mem[pc2][9:7];
                rd2 = inst_2_mem[pc2][6:4]; rl2 = inst_2_mem[pc2][3:1]; func2 = inst_2_mem[pc2][3:1];
                jmp_addr2 = inst_2_mem[pc2][12:0];
                temp_imm2 = inst_2_mem[pc2][6:0];
                if (inst_2_mem[pc2][6]) temp_imm2 = temp_imm2 | 32'hFFFFFF80;
            end

            rs1_val = sim_r1[rs1]; rs2_val = sim_r2[rs2];
            addr1_index = (rs1_val + temp_imm1) & 12'hFFF;
            addr2_index = (rs2_val + temp_imm2) & 12'hFFF;

            if (is_new_1 && is_new_2) begin
                if ((op1 == 3'b100 && op2 == 3'b101) || (op1 == 3'b101 && op2 == 3'b100)) begin
                    inject_hazard = (ic < 50) ? 100 : ($unsigned($random(seed)) % 100);
                    if (inject_hazard > 20) begin
                        for (k = 0; k < 8; k = k + 1) begin
                            rs2_val = sim_r2[k];
                            target_imm2 = addr1_index - rs2_val; 
                            if (target_imm2 >= -64 && target_imm2 <= 63) begin
                                rs2 = k; temp_imm2 = target_imm2; addr2_index = addr1_index; 
                            end
                        end
                    end
                end
            end

            if (is_new_1) begin
                if (op1 == 3'b000)      inst_1_mem[pc1] = {op1, rs1, rt1, rd1, func1, 1'b0};
                else if (op1 == 3'b001) inst_1_mem[pc1] = {op1, rs1, rt1, rd1, rl1, 1'b0};
                else if (op1 == 3'b111) inst_1_mem[pc1] = {op1, jmp_addr1};
                else                    inst_1_mem[pc1] = {op1, rs1, rt1, temp_imm1[6:0]};
                gen_flag1[pc1] = 1;
            end
            if (is_new_2) begin
                if (op2 == 3'b000)      inst_2_mem[pc2] = {op2, rs2, rt2, rd2, func2, 1'b0};
                else if (op2 == 3'b001) inst_2_mem[pc2] = {op2, rs2, rt2, rd2, rl2, 1'b0};
                else if (op2 == 3'b111) inst_2_mem[pc2] = {op2, jmp_addr2};
                else                    inst_2_mem[pc2] = {op2, rs2, rt2, temp_imm2[6:0]};
                gen_flag2[pc2] = 1;
            end

            trace_inst_1[ic] = inst_1_mem[pc1];
            trace_inst_2[ic] = inst_2_mem[pc2];
            pc_trace_1[ic] = pc1;
            pc_trace_2[ic] = pc2;

            if (op1 == 3'b000 || op1 == 3'b001) prev_rd1 = rd1; else prev_rd1 = rt1;
            if (op2 == 3'b000 || op2 == 3'b001) prev_rd2 = rd2; else prev_rd2 = rt2;
            prev_rt1 = rt1;
            prev_rt2 = rt2;

            if (op1 == 3'b101) golden_dram_data[addr1_index] = sim_r1[rt1];
            if (op2 == 3'b101) golden_dram_data[addr2_index] = sim_r2[rt2];

            next_pc1 = pc1 + 1;
            if (op1 == 3'b000) begin
                case (func1)
                    3'b000: sim_r1[rd1] = sim_r1[rs1] + sim_r1[rt1];
                    3'b001: sim_r1[rd1] = sim_r1[rs1] - sim_r1[rt1]; 
                    3'b010: sim_r1[rd1] = sim_r1[rs1] & sim_r1[rt1]; 
                    3'b011: sim_r1[rd1] = sim_r1[rs1] | sim_r1[rt1];
                    3'b100: sim_r1[rd1] = ~(sim_r1[rs1] & sim_r1[rt1]); 
                    3'b101: sim_r1[rd1] = ~(sim_r1[rs1] | sim_r1[rt1]); 
                    3'b110: sim_r1[rd1] = sim_r1[rs1] ^ sim_r1[rt1];
                    3'b111: sim_r1[rd1] = ($signed(sim_r1[rs1]) < $signed(sim_r1[rt1])) ? 16'd1 : 16'd0;
                endcase
            end
            else if (op1 == 3'b001) begin
                mult_res1 = $signed(sim_r1[rs1]) * $signed(sim_r1[rt1]);
                sim_r1[rd1] = mult_res1[31:16]; sim_r1[rl1] = mult_res1[15:0];
            end
            else if (op1 == 3'b010) sim_r1[rt1] = sim_r1[rs1] + temp_imm1;
            else if (op1 == 3'b011) sim_r1[rt1] = sim_r1[rs1] - temp_imm1;
            else if (op1 == 3'b100) sim_r1[rt1] = golden_dram_data[addr1_index];
            else if (op1 == 3'b110 && sim_r1[rs1] == sim_r1[rt1]) next_pc1 = pc1 + 1 + temp_imm1;
            else if (op1 == 3'b111) next_pc1 = jmp_addr1 >> 1;
            
            next_pc2 = pc2 + 1;
            if (op2 == 3'b000) begin
                case (func2)
                    3'b000: sim_r2[rd2] = sim_r2[rs2] + sim_r2[rt2];
                    3'b001: sim_r2[rd2] = sim_r2[rs2] - sim_r2[rt2]; 
                    3'b010: sim_r2[rd2] = sim_r2[rs2] & sim_r2[rt2]; 
                    3'b011: sim_r2[rd2] = sim_r2[rs2] | sim_r2[rt2];
                    3'b100: sim_r2[rd2] = ~(sim_r2[rs2] & sim_r2[rt2]); 
                    3'b101: sim_r2[rd2] = ~(sim_r2[rs2] | sim_r2[rt2]); 
                    3'b110: sim_r2[rd2] = sim_r2[rs2] ^ sim_r2[rt2];
                    3'b111: sim_r2[rd2] = ($signed(sim_r2[rs2]) < $signed(sim_r2[rt2])) ? 16'd1 : 16'd0;
                endcase
            end
            else if (op2 == 3'b001) begin
                mult_res2 = $signed(sim_r2[rs2]) * $signed(sim_r2[rt2]);
                sim_r2[rd2] = mult_res2[31:16]; sim_r2[rl2] = mult_res2[15:0];
            end
            else if (op2 == 3'b010) sim_r2[rt2] = sim_r2[rs2] + temp_imm2;
            else if (op2 == 3'b011) sim_r2[rt2] = sim_r2[rs2] - temp_imm2;
            else if (op2 == 3'b100) sim_r2[rt2] = golden_dram_data[addr2_index];
            else if (op2 == 3'b110 && sim_r2[rs2] == sim_r2[rt2]) next_pc2 = pc2 + 1 + temp_imm2;
            else if (op2 == 3'b111) next_pc2 = jmp_addr2 >> 1;

            for (j = 0; j < 8; j = j + 1) begin
                golden_reg_core1[ic][j] = sim_r1[j];
                golden_reg_core2[ic][j] = sim_r2[j];
            end
            
            pc1 = next_pc1;
            pc2 = next_pc2;

            if ((ic + 1) % 50 == 0) begin
                for (j = 0; j < 4096; j = j + 1) dram_snapshots[(ic + 1) / 50][j] = golden_dram_data[j];
            end
        end

        f1 = $fopen("../00_TESTBED/DRAM/inst_1_dram_file.dat", "w");
        if (f1 == 0) begin
            $display("\n%s[WARNING] DRAM directory not found! Writing inst_1 to current directory...%s", `C_YLW, `C_RST);
            f1 = $fopen("inst_1_dram_file.dat", "w");
        end
        for (j = 0; j < 4096; j = j + 1) $fdisplay(f1, "@%05x\n%02x %02x", j*2, inst_1_mem[j][7:0], inst_1_mem[j][15:8]);
        $fclose(f1);

        f2 = $fopen("../00_TESTBED/DRAM/inst_2_dram_file.dat", "w");
        if (f2 == 0) begin
            $display("%s[WARNING] DRAM directory not found! Writing inst_2 to current directory...%s", `C_YLW, `C_RST);
            f2 = $fopen("inst_2_dram_file.dat", "w");
        end
        for (j = 0; j < 4096; j = j + 1) $fdisplay(f2, "@%05x\n%02x %02x", j*2, inst_2_mem[j][7:0], inst_2_mem[j][15:8]);
        $fclose(f2);
        
        fd = $fopen("../00_TESTBED/DRAM/data_dram_file.dat", "w");
        if (fd == 0) begin
            $display("%s[WARNING] DRAM directory not found! Writing data_dram to current directory...%s", `C_YLW, `C_RST);
            fd = $fopen("data_dram_file.dat", "w");
        end
        for (j = 0; j < 4096; j = j + 1) $fdisplay(fd, "@%05x\n%02x %02x", 32'h1000 + j*2, init_dram_data[j][7:0], init_dram_data[j][15:8]);
        $fclose(fd);

        for (j = 0; j < 4096; j = j + 1) begin
            u_inst1_dram.DRAM_r[j*2]               = inst_1_mem[j][7:0];
            u_inst1_dram.DRAM_r[j*2 + 1]           = inst_1_mem[j][15:8];
            u_inst2_dram.DRAM_r[j*2]               = inst_2_mem[j][7:0];
            u_inst2_dram.DRAM_r[j*2 + 1]           = inst_2_mem[j][15:8];
            u_data_dram.DRAM_r[32'h1000 + j*2]     = init_dram_data[j][7:0];
            u_data_dram.DRAM_r[32'h1000 + j*2 + 1] = init_dram_data[j][15:8];
        end
    end
endtask

always @(posedge clk) begin
    if (arvalid_s_inf_inst_1 && arready_s_inf_inst_1) $display("%s   [AXI Snooper] Core 1 Fetch Request @ %04x%s", `C_PUR, araddr_s_inf_inst_1, `C_RST);
    if (arvalid_s_inf_inst_2 && arready_s_inf_inst_2) $display("%s   [AXI Snooper] Core 2 Fetch Request @ %04x%s", `C_PUR, araddr_s_inf_inst_2, `C_RST);
    if (arvalid_s_inf_data && arready_s_inf_data) $display("%s   [AXI Snooper] Data DRAM Read Req  @ %04x%s", `C_CYN, araddr_s_inf_data, `C_RST);
    if (rvalid_s_inf_data && rready_s_inf_data)   $display("%s   [AXI Snooper] Data DRAM Read Back: %04x%s", `C_CYN, rdata_s_inf_data, `C_RST);
    if (wvalid_s_inf_data && wready_s_inf_data)   $display("%s   [AXI Snooper] Data DRAM Write Data: %04x%s", `C_YLW, wdata_s_inf_data, `C_RST);
end

task print_inst_debug;
    input [3:0] core;
    input [15:0] ic;
    input [15:0] inst;
    
    reg [2:0] op, rs, rt, rd, rl, func;
    reg signed [15:0] imm;
    reg [12:0] addr;
    begin
        op = inst[15:13];
        rs = inst[12:10]; rt = inst[9:7];
        rd = inst[6:4]; rl = inst[3:1]; func = inst[3:1];
        imm = $signed({{9{inst[6]}}, inst[6:0]});
        addr = inst[12:0];
        
        $display("   [Core %0d Real Trace] Hex: %04x | IC: %0d", core, inst, ic);
        case (op)
            3'b000: begin
                case(func)
                    3'b000: $display("%s   -> [ADD]    r%0d = r%0d + r%0d%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b001: $display("%s   -> [SUB]    r%0d = r%0d - r%0d%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b010: $display("%s   -> [AND]    r%0d = r%0d & r%0d%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b011: $display("%s   -> [OR]     r%0d = r%0d | r%0d%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b100: $display("%s   -> [NAND]   r%0d = ~(r%0d & r%0d)%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b101: $display("%s   -> [NOR]    r%0d = ~(r%0d | r%0d)%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b110: $display("%s   -> [XOR]    r%0d = r%0d ^ r%0d%s", `C_GRN, rd, rs, rt, `C_RST);
                    3'b111: $display("%s   -> [SLT]    r%0d = (r%0d < r%0d)%s", `C_GRN, rd, rs, rt, `C_RST);
                endcase
            end
            3'b001: $display("%s   -> [MULT]   {r%0d, r%0d} = r%0d * r%0d%s", `C_GRN, rd, rl, rs, rt, `C_RST);
            3'b010: $display("%s   -> [ADDI]   r%0d = r%0d + (%0d)%s", `C_GRN, rt, rs, imm, `C_RST);
            3'b011: $display("%s   -> [SUBI]   r%0d = r%0d - (%0d)%s", `C_GRN, rt, rs, imm, `C_RST);
            3'b100: $display("%s   -> [LOAD]   r%0d = MEM[r%0d + (%0d)]%s", `C_CYN, rt, rs, imm, `C_RST);
            3'b101: $display("%s   -> [STORE]  MEM[r%0d + (%0d)] = r%0d%s", `C_YLW, rs, imm, rt, `C_RST);
            3'b110: $display("%s   -> [BEQ]    IF(r%0d == r%0d) PC = PC + 1 + (%0d)%s", `C_PUR, rs, rt, imm, `C_RST);
            3'b111: $display("%s   -> [JUMP]   PC = %0d%s", `C_PUR, addr, `C_RST);
        endcase
    end
endtask

task check_execution_task;
    begin
        while (!sim_halt_condition) begin
            @(negedge clk);
            if (stall_1 === 1'bx || stall_1 === 1'bz || stall_2 === 1'bx || stall_2 === 1'bz) begin
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Stall signal is Unknown (X) or High-Z!%s", `C_RED, `C_RST);
                $display("%s   stall_1: %b | stall_2: %b%s", `C_RED, stall_1, stall_2, `C_RST);
                $display("%s========================================================%s\n", `C_RED, `C_RST);
                
                display_wrong;
                $finish;
            end

            if (core1_ic >= `PAT_NUM && !core1_halted) begin
                $display("\n%s[FATAL] Array Out of Bounds! Core 1 reached PAT_NUM but hasn't executed PC=4095.%s", `C_RED, `C_RST);
                display_wrong;
                $finish;
            end
            if (core2_ic >= `PAT_NUM && !core2_halted) begin
                $display("\n%s[FATAL] Array Out of Bounds! Core 2 reached PAT_NUM but hasn't executed PC=4095.%s", `C_RED, `C_RST);
                display_wrong;
                $finish;
            end
            if (core1_ic == next_dram_check_ic && core2_ic < next_dram_check_ic) begin
                $display("\n%s   [FATAL WARNING] Core 1 crossed 50-IC boundary (IC=%0d) while Core 2 is behind (IC=%0d).%s", `C_YLW, core1_ic, core2_ic, `C_RST);
                $display("%s   If your RTL does not sync them, Core 1's future STOREs will corrupt the TA's Snapshot!%s", `C_YLW, `C_RST);
            end
            if (core2_ic == next_dram_check_ic && core1_ic < next_dram_check_ic) begin
                $display("\n%s   [FATAL WARNING] Core 2 crossed 50-IC boundary (IC=%0d) while Core 1 is behind (IC=%0d).%s", `C_YLW, core2_ic, core1_ic, `C_RST);
                $display("%s   If your RTL does not sync them, Core 2's future STOREs will corrupt the TA's Snapshot!%s", `C_YLW, `C_RST);
            end

            
            if (stall_1 === 0) begin
                if (core1_halted) begin
                    $display("\n%s========================================================%s", `C_RED, `C_RST);
                    $display("%s   [ERROR] Core 1 executed an instruction AFTER reaching Halt Condition (PC=4095)!%s", `C_RED, `C_RST);
                    $display("%s   When PC=4095 is executed, the Core must maintain Stall=1 indefinitely.%s", `C_RED, `C_RST);
                    $display("%s========================================================%s\n", `C_RED, `C_RST); 
                    display_wrong;
                    $finish;
                end
                check_core1_registers;
                core1_ic = core1_ic + 1; latency_1 = 0;
            end else begin
                if (!core1_halted) latency_1 = latency_1 + 1;
            end
            
            
            if (stall_2 === 0) begin
                if (core2_halted) begin
                    $display("\n%s========================================================%s", `C_RED, `C_RST);
                    $display("%s   [ERROR] Core 2 executed an instruction AFTER reaching Halt Condition (PC=4095)!%s", `C_RED, `C_RST);
                    $display("%s   When PC=4095 is executed, the Core must maintain Stall=1 indefinitely.%s", `C_RED, `C_RST);
                    $display("%s========================================================%s\n", `C_RED, `C_RST); 
                    display_wrong;
                    $finish;
                end
                check_core2_registers;
                
                core2_ic = core2_ic + 1; latency_2 = 0;
                
                if (core2_ic > core1_ic + 1) begin
                    $display("\n%s========================================================%s", `C_RED, `C_RST);
                    $display("%s   [WARNING] Sequence Violation! Core 2 is executing too fast.%s", `C_RED, `C_RST);
                    $display("%s   Core 2 IC: %0d | Core 1 IC: %0d%s", `C_RED, core2_ic, core1_ic, `C_RST);
                    $display("%s   (Rule: 19th inst of Core 1 must execute before 20th of Core 2)%s", `C_RED, `C_RST);
                    $display("%s========================================================%s\n", `C_RED, `C_RST);
                end
            end else begin
                if (!core2_halted) latency_2 = latency_2 + 1;
            end

            if (core1_ic >= next_dram_check_ic && core2_ic >= next_dram_check_ic) begin
                check_dram_snapshot_task(next_dram_check_ic);
                next_dram_check_ic = next_dram_check_ic + 50;
            end

            if ((!core1_halted && latency_1 > `MAX_WAIT_READY_CYCLE) || 
                (!core2_halted && latency_2 > `MAX_WAIT_READY_CYCLE)) begin
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Stall Timed Out! Exceeded %0d cycles!%s", `C_RED, `MAX_WAIT_READY_CYCLE, `C_RST);
                $display("%s   Status -> Core1 IC: %0d, Core2 IC: %0d%s", `C_RED, core1_ic, core2_ic, `C_RST);
                $display("%s========================================================%s\n", `C_RED, `C_RST); 
                display_wrong;
                $finish;
            end
            
            total_latency = total_latency + 1;
        end
        
        flush_timeout = 0;
        halt_grace_period = 0;
        $display("\n%s   [INFO] Entering Final AXI Flush Phase...%s", `C_PUR, `C_RST);
        
        while (outstanding_aw_d > 0 || outstanding_w_d > 0 || out_r_1 > 0 || out_r_2 > 0 || out_r_d > 0 || 
               awvalid_s_inf_data || wvalid_s_inf_data || bvalid_s_inf_data ||
               arvalid_s_inf_inst_1 || arvalid_s_inf_inst_2 || arvalid_s_inf_data) begin
            @(negedge clk);
            halt_grace_period = halt_grace_period + 1;
            
            if (halt_grace_period > 2 && (stall_1 === 0 || stall_2 === 0)) begin
                $display("\n\033[1;31m========================================================\033[0m");
                $display("\033[1;31m   [VIOLATION] RTL is still executing (stall pulled LOW) after hitting the Halt Condition!\033[0m");
                $display("\033[1;31m   This happened during the final AXI Write Flush phase.\033[0m");
                $display("\033[1;31m========================================================\033[0m\n");
                
                display_wrong;
                $finish;
            end
            
            total_latency = total_latency + 1;
            flush_timeout = flush_timeout + 1;
            if (flush_timeout > 500) begin
                $display("\n\033[1;31m========================================================\033[0m");
                $display("\033[1;31m   [VIOLATION] Deadlock during final AXI Flush!\033[0m");
                $display("\033[1;31m   Check if your Valid/Ready logic is stuck or BREADY is not asserted.\033[0m");
                $display("\033[1;31m========================================================\033[0m\n"); 
                
                display_wrong;
                $finish;
            end
        end
        
        #(5 * `CYCLE_TIME);
        if (stall_1 !== 1 || stall_2 !== 1) begin
            $display("\n%s========================================================%s", `C_RED, `C_RST);
            $display("%s   [ERROR] stall_1 and stall_2 MUST remain HIGH after all instructions are completed!%s", `C_RED, `C_RST);
            $display("%s========================================================%s\n", `C_RED, `C_RST);
            display_wrong;
            $finish;
        end
        check_final_dram_task;
    end
endtask

task check_core1_registers;
    integer reg_idx;
    begin
        for (reg_idx = 0; reg_idx < 8; reg_idx = reg_idx + 1) begin
            if (golden_reg_core1[core1_ic][reg_idx] !== `REG_C1(reg_idx)) begin 
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Core 1 Register r%0d mismatch at IC: %0d!%s", `C_RED, reg_idx, core1_ic, `C_RST);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                print_inst_debug(1, core1_ic, trace_inst_1[core1_ic]); 
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                $display("%s   Register Dump:%s", `C_YLW, `C_RST);
                for (reg_idx = 0; reg_idx < 8; reg_idx = reg_idx + 1) begin
                    if (golden_reg_core1[core1_ic][reg_idx] !== `REG_C1(reg_idx)) begin
                        $display("%s     r%0d => Golden: %04x | RTL: %04x  <-- MISMATCH%s", `C_RED, reg_idx, golden_reg_core1[core1_ic][reg_idx], `REG_C1(reg_idx), `C_RST);
                    end 
                    else begin
                        $display("%s     r%0d => Golden: %04x | RTL: %04x%s", `C_WHT, reg_idx, golden_reg_core1[core1_ic][reg_idx], `REG_C1(reg_idx), `C_RST);
                    end
                end
                $display("%s========================================================%s\n", `C_RED, `C_RST);
                display_wrong;
                $finish;
            end
        end
    end
endtask

task check_core2_registers;
    integer reg_idx;
    begin
        for (reg_idx = 0; reg_idx < 8; reg_idx = reg_idx + 1) begin
            if (golden_reg_core2[core2_ic][reg_idx] !== `REG_C2(reg_idx)) begin 
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Core 2 Register r%0d mismatch at IC: %0d!%s", `C_RED, reg_idx, core2_ic, `C_RST);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                print_inst_debug(2, core2_ic, trace_inst_2[core2_ic]);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                $display("%s   Register Dump:%s", `C_YLW, `C_RST);
                for (reg_idx = 0; reg_idx < 8; reg_idx = reg_idx + 1) begin
                    if (golden_reg_core2[core2_ic][reg_idx] !== `REG_C2(reg_idx)) begin
                        $display("%s     r%0d => Golden: %04x | RTL: %04x  <-- MISMATCH%s", `C_RED, reg_idx, golden_reg_core2[core2_ic][reg_idx], `REG_C2(reg_idx), `C_RST);
                    end 
                    else begin
                        $display("%s     r%0d => Golden: %04x | RTL: %04x%s", `C_WHT, reg_idx, golden_reg_core2[core2_ic][reg_idx], `REG_C2(reg_idx), `C_RST);
                    end
                end
                $display("%s========================================================%s\n", `C_RED, `C_RST);
                display_wrong;
                $finish;
            end
        end
    end
endtask

task check_dram_snapshot_task;
    input integer target_ic;
    integer snapshot_idx;
    integer byte_addr;
    integer idx;
    reg [15:0] rtl_dram_data;
    begin
        snapshot_idx = target_ic / 50;
        for (idx = 0; idx < 4096; idx = idx + 1) begin
            byte_addr = 32'h1000 + (idx * 2);
            rtl_dram_data = {u_data_dram.DRAM_r[byte_addr + 1], u_data_dram.DRAM_r[byte_addr]};
            
            if (dram_snapshots[snapshot_idx][idx] !== rtl_dram_data) begin
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Data DRAM mismatch at 50-IC Checkpoint (IC=%0d)!%s", `C_RED, target_ic, `C_RST);
                $display("%s   Word Index %0d (Byte Addr: %04x)%s", `C_RED, idx, byte_addr, `C_RST);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                $display("%s   Golden Expected: %04x%s", `C_WHT, dram_snapshots[snapshot_idx][idx], `C_RST);
                $display("%s   Your RTL Got   : %04x%s", `C_WHT, rtl_dram_data, `C_RST);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                $display("%s   [HINT] If you are sure your STORE logic is correct, check if your Core 1 ran too far ahead%s", `C_YLW, `C_RST);
                $display("%s          and prematurely overwrote the DRAM before Core 2 reached this checkpoint!%s", `C_YLW, `C_RST);
                $display("%s          (Look for the FATAL WARNING in the console above)%s", `C_YLW, `C_RST);
                $display("%s========================================================%s\n", `C_RED, `C_RST); 
                display_wrong;
                $finish;
            end
        end
        $display("%s   [INFO] 50-IC Checkpoint Passed (IC %0d)%s", `C_GRN, target_ic, `C_RST);
    end
endtask

task check_final_dram_task;
    integer byte_addr;
    integer idx;
    reg [15:0] rtl_dram_data;
    begin
        for (idx = 0; idx < 4096; idx = idx + 1) begin
            byte_addr = 32'h1000 + (idx * 2);
            rtl_dram_data = {u_data_dram.DRAM_r[byte_addr + 1], u_data_dram.DRAM_r[byte_addr]};
            
            if (golden_dram_data[idx] !== rtl_dram_data) begin
                $display("\n%s========================================================%s", `C_RED, `C_RST);
                $display("%s   [ERROR] Final Data DRAM mismatch at Word Index %0d (Byte Addr: %04x)!%s", `C_RED, idx, byte_addr, `C_RST);
                $display("%s--------------------------------------------------------%s", `C_RED, `C_RST);
                $display("%s   Golden Expected: %04x%s", `C_WHT, golden_dram_data[idx], `C_RST);
                $display("%s   Your RTL Got   : %04x%s", `C_WHT, rtl_dram_data, `C_RST);
                $display("%s========================================================%s\n", `C_RED, `C_RST); 
                display_wrong;
                $finish;
            end
        end
        $display("%s   [INFO] Final DRAM Validation Passed.%s", `C_GRN, `C_RST);
    end
endtask

task display_success;begin
    //image for success
    end
endtask

task display_wrong;begin
    //image for fail
    end
endtask

endmodule