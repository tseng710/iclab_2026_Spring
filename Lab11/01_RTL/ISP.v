// ============================================================================
// Module: ISP (Top Level)
// ============================================================================
module ISP(
    input         clk,
    input         rst_n,
    input         in_data_valid,
    input  [11:0] in_data,
    input         cmd_valid,
    input  [5:0]  cmd,
    output        out_valid,
    output [7:0]  r_out,
    output [7:0]  g_out,
    output [7:0]  b_out
);

    // ------------------------------------------------------------------------
    // Interconnect Declarations
    // ------------------------------------------------------------------------
    wire        raw_valid;
    wire [11:0] raw_data;
    
    wire        lsc_valid;
    wire [11:0] lsc_data;
    
    wire        dpc_valid;
    wire [11:0] dpc_data;
    
    wire        dem_valid;
    wire [11:0] dem_r;
    wire [11:0] dem_g;
    wire [11:0] dem_b;

    // ------------------------------------------------------------------------
    // Submodule Instantiations
    // ------------------------------------------------------------------------
    CTRL_STAGE u_ctrl (
        .clk           (clk),
        .rst_n         (rst_n),
        .in_data_valid (in_data_valid),
        .in_data       (in_data),
        .cmd_valid     (cmd_valid),
        .cmd           (cmd),
        .ccm_valid     (out_valid),
        .raw_valid     (raw_valid),
        .raw_data      (raw_data)
    );

    LSC_STAGE u_lsc (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (raw_valid),
        .in_data   (raw_data),
        .out_valid (lsc_valid),
        .out_data  (lsc_data)
    );

    DPC_STAGE u_dpc (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (lsc_valid),
        .in_data   (lsc_data),
        .out_valid (dpc_valid),
        .out_data  (dpc_data)
    );

    DEM_STAGE u_dem (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (dpc_valid),
        .in_data   (dpc_data),
        .out_valid (dem_valid),
        .out_r     (dem_r),
        .out_g     (dem_g),
        .out_b     (dem_b)
    );

    CCM_STAGE u_ccm (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (dem_valid),
        .in_r      (dem_r),
        .in_g      (dem_g),
        .in_b      (dem_b),
        .out_valid (out_valid),
        .out_r     (r_out),
        .out_g     (g_out),
        .out_b     (b_out)
    );

endmodule

// ============================================================================
// Module: CTRL_STAGE (FSM & SRAM Management)
// ============================================================================
module CTRL_STAGE(
    input             clk,
    input             rst_n,
    input             in_data_valid,
    input      [11:0] in_data,
    input             cmd_valid,
    input      [5:0]  cmd,
    input             ccm_valid,
    output reg        raw_valid,
    output     [11:0] raw_data
);

    localparam ST_IDLE  = 3'd0;
    localparam ST_LOAD  = 3'd1;
    localparam ST_WAIT  = 3'd2;
    localparam ST_READ  = 3'd3;
    localparam ST_FLUSH = 3'd4;

    reg  [2:0]  state;
    reg  [2:0]  n_state;
    reg  [13:0] load_cnt;   
    reg  [8:0]  read_cnt;
    reg  [5:0]  cmd_reg;
    reg         ccm_valid_d1;
    wire        frame_done;

    assign frame_done = (ccm_valid_d1 && !ccm_valid);

    always @(*) begin
        case(state)
            ST_IDLE:  n_state = in_data_valid ? ST_LOAD : ST_IDLE;
            ST_LOAD:  n_state = (load_cnt == 14'd16383 && in_data_valid) ? ST_WAIT : ST_LOAD;
            ST_WAIT:  n_state = cmd_valid ? ST_READ : ST_WAIT;
            ST_READ:  n_state = (read_cnt == 9'd255) ? ST_FLUSH : ST_READ;
            ST_FLUSH: n_state = frame_done ? ST_WAIT : ST_FLUSH;
            default:  n_state = ST_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= ST_IDLE;
            load_cnt     <= 14'd0;
            read_cnt     <= 9'd0;
            cmd_reg      <= 6'd0;
            ccm_valid_d1 <= 1'b0;
            raw_valid    <= 1'b0;
        end else begin
            state        <= n_state;
            ccm_valid_d1 <= ccm_valid;
            raw_valid    <= (state == ST_READ);

            if (in_data_valid) begin
                load_cnt <= load_cnt + 14'd1;
            end
            
            if (state == ST_WAIT && cmd_valid) begin
                cmd_reg <= cmd;
            end
            
            if (state == ST_READ) begin
                read_cnt <= read_cnt + 9'd1;
            end else begin
                read_cnt <= 9'd0;
            end
        end
    end

    wire [1:0]  write_sram_idx = load_cnt[13:12];
    wire [11:0] write_addr     = load_cnt[11:0];
    wire [1:0]  read_sram_idx  = cmd_reg[5:4];
    wire [11:0] read_addr      = {cmd_reg[3:0], read_cnt[7:0]};

    wire [11:0] sram_addr [0:3];
    wire        sram_wen  [0:3];
    wire [11:0] sram_q    [0:3];

    genvar j;
    generate
        for (j = 0; j < 4; j = j + 1) begin : SRAM_CTRL
            assign sram_addr[j] = (state == ST_READ) ? read_addr : write_addr;
            assign sram_wen[j]  = ~((state == ST_IDLE || state == ST_LOAD) && (write_sram_idx == j) && in_data_valid);
        end
    endgenerate

    assign raw_data = sram_q[read_sram_idx];

    SUMA180_4096X12 mem0 (.A0(sram_addr[0][0]), .A1(sram_addr[0][1]), .A2(sram_addr[0][2]), .A3(sram_addr[0][3]), .A4(sram_addr[0][4]), .A5(sram_addr[0][5]), .A6(sram_addr[0][6]), .A7(sram_addr[0][7]), .A8(sram_addr[0][8]), .A9(sram_addr[0][9]), .A10(sram_addr[0][10]), .A11(sram_addr[0][11]), .DO0(sram_q[0][0]), .DO1(sram_q[0][1]), .DO2(sram_q[0][2]), .DO3(sram_q[0][3]), .DO4(sram_q[0][4]), .DO5(sram_q[0][5]), .DO6(sram_q[0][6]), .DO7(sram_q[0][7]), .DO8(sram_q[0][8]), .DO9(sram_q[0][9]), .DO10(sram_q[0][10]), .DO11(sram_q[0][11]), .DI0(in_data[0]), .DI1(in_data[1]), .DI2(in_data[2]), .DI3(in_data[3]), .DI4(in_data[4]), .DI5(in_data[5]), .DI6(in_data[6]), .DI7(in_data[7]), .DI8(in_data[8]), .DI9(in_data[9]), .DI10(in_data[10]), .DI11(in_data[11]), .CK(clk), .WEB(sram_wen[0]), .OE(1'b1), .CS(1'b1));
    SUMA180_4096X12 mem1 (.A0(sram_addr[1][0]), .A1(sram_addr[1][1]), .A2(sram_addr[1][2]), .A3(sram_addr[1][3]), .A4(sram_addr[1][4]), .A5(sram_addr[1][5]), .A6(sram_addr[1][6]), .A7(sram_addr[1][7]), .A8(sram_addr[1][8]), .A9(sram_addr[1][9]), .A10(sram_addr[1][10]), .A11(sram_addr[1][11]), .DO0(sram_q[1][0]), .DO1(sram_q[1][1]), .DO2(sram_q[1][2]), .DO3(sram_q[1][3]), .DO4(sram_q[1][4]), .DO5(sram_q[1][5]), .DO6(sram_q[1][6]), .DO7(sram_q[1][7]), .DO8(sram_q[1][8]), .DO9(sram_q[1][9]), .DO10(sram_q[1][10]), .DO11(sram_q[1][11]), .DI0(in_data[0]), .DI1(in_data[1]), .DI2(in_data[2]), .DI3(in_data[3]), .DI4(in_data[4]), .DI5(in_data[5]), .DI6(in_data[6]), .DI7(in_data[7]), .DI8(in_data[8]), .DI9(in_data[9]), .DI10(in_data[10]), .DI11(in_data[11]), .CK(clk), .WEB(sram_wen[1]), .OE(1'b1), .CS(1'b1));
    SUMA180_4096X12 mem2 (.A0(sram_addr[2][0]), .A1(sram_addr[2][1]), .A2(sram_addr[2][2]), .A3(sram_addr[2][3]), .A4(sram_addr[2][4]), .A5(sram_addr[2][5]), .A6(sram_addr[2][6]), .A7(sram_addr[2][7]), .A8(sram_addr[2][8]), .A9(sram_addr[2][9]), .A10(sram_addr[2][10]), .A11(sram_addr[2][11]), .DO0(sram_q[2][0]), .DO1(sram_q[2][1]), .DO2(sram_q[2][2]), .DO3(sram_q[2][3]), .DO4(sram_q[2][4]), .DO5(sram_q[2][5]), .DO6(sram_q[2][6]), .DO7(sram_q[2][7]), .DO8(sram_q[2][8]), .DO9(sram_q[2][9]), .DO10(sram_q[2][10]), .DO11(sram_q[2][11]), .DI0(in_data[0]), .DI1(in_data[1]), .DI2(in_data[2]), .DI3(in_data[3]), .DI4(in_data[4]), .DI5(in_data[5]), .DI6(in_data[6]), .DI7(in_data[7]), .DI8(in_data[8]), .DI9(in_data[9]), .DI10(in_data[10]), .DI11(in_data[11]), .CK(clk), .WEB(sram_wen[2]), .OE(1'b1), .CS(1'b1));
    SUMA180_4096X12 mem3 (.A0(sram_addr[3][0]), .A1(sram_addr[3][1]), .A2(sram_addr[3][2]), .A3(sram_addr[3][3]), .A4(sram_addr[3][4]), .A5(sram_addr[3][5]), .A6(sram_addr[3][6]), .A7(sram_addr[3][7]), .A8(sram_addr[3][8]), .A9(sram_addr[3][9]), .A10(sram_addr[3][10]), .A11(sram_addr[3][11]), .DO0(sram_q[3][0]), .DO1(sram_q[3][1]), .DO2(sram_q[3][2]), .DO3(sram_q[3][3]), .DO4(sram_q[3][4]), .DO5(sram_q[3][5]), .DO6(sram_q[3][6]), .DO7(sram_q[3][7]), .DO8(sram_q[3][8]), .DO9(sram_q[3][9]), .DO10(sram_q[3][10]), .DO11(sram_q[3][11]), .DI0(in_data[0]), .DI1(in_data[1]), .DI2(in_data[2]), .DI3(in_data[3]), .DI4(in_data[4]), .DI5(in_data[5]), .DI6(in_data[6]), .DI7(in_data[7]), .DI8(in_data[8]), .DI9(in_data[9]), .DI10(in_data[10]), .DI11(in_data[11]), .CK(clk), .WEB(sram_wen[3]), .OE(1'b1), .CS(1'b1));

endmodule

// ============================================================================
// Module: XY_CNT
// ============================================================================
module XY_CNT(
    input            clk,
    input            rst_n,
    input            en,
    output reg [3:0] x,
    output reg [3:0] y
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 4'd0;
            y <= 4'd0;
        end else if (en) begin
            if (x == 4'd15) begin
                x <= 4'd0;
                y <= y + 4'd1;
            end else begin
                x <= x + 4'd1;
            end
        end
    end
endmodule

// ============================================================================
// Module: LSC_STAGE
// ============================================================================
module LSC_STAGE(
    input             clk,
    input             rst_n,
    input             in_valid,
    input      [11:0] in_data,
    output reg        out_valid,
    output reg [11:0] out_data
);

    wire [3:0] in_x, in_y;
    XY_CNT u_xy_cnt (.clk(clk), .rst_n(rst_n), .en(in_valid), .x(in_x), .y(in_y));

    wire [1:0]  color_now  = {in_y[0], in_x[0]};
    wire [6:0]  blc_offset = (color_now == 2'b00) ? 7'd64 : 
                             (color_now == 2'b01) ? 7'd48 : 
                             (color_now == 2'b10) ? 7'd52 : 7'd72;
    wire signed [12:0] blc_sub = {1'b0, in_data} - {6'b0, blc_offset};
    wire [11:0] blc_out = (blc_sub < 13'sd0) ? 12'd0 : blc_sub[11:0];

    reg  [2:0] x_0, y_0;
    reg  [1:0] r_x, r_y;

    always @(*) begin
        case(in_x)
            4'd0, 4'd1, 4'd2:    begin x_0 = 3'd0; r_x = in_x[1:0];        end
            4'd3, 4'd4, 4'd5:    begin x_0 = 3'd1; r_x = in_x[1:0] - 2'd3; end
            4'd6, 4'd7, 4'd8:    begin x_0 = 3'd2; r_x = in_x[1:0] - 2'd2; end
            4'd9, 4'd10, 4'd11:  begin x_0 = 3'd3; r_x = in_x[1:0] - 2'd1; end
            4'd12, 4'd13, 4'd14: begin x_0 = 3'd4; r_x = in_x[1:0];        end
            4'd15:               begin x_0 = 3'd4; r_x = 2'd2;             end
            default:             begin x_0 = 3'd0; r_x = 2'd0;             end
        endcase
    end

    always @(*) begin
        case(in_y)
            4'd0, 4'd1, 4'd2:    begin y_0 = 3'd0; r_y = in_y[1:0];        end
            4'd3, 4'd4, 4'd5:    begin y_0 = 3'd1; r_y = in_y[1:0] - 2'd3; end
            4'd6, 4'd7, 4'd8:    begin y_0 = 3'd2; r_y = in_y[1:0] - 2'd2; end
            4'd9, 4'd10, 4'd11:  begin y_0 = 3'd3; r_y = in_y[1:0] - 2'd1; end
            4'd12, 4'd13, 4'd14: begin y_0 = 3'd4; r_y = in_y[1:0];        end
            4'd15:               begin y_0 = 3'd4; r_y = 2'd2;             end
            default:             begin y_0 = 3'd0; r_y = 2'd0;             end
        endcase
    end

    wire [2:0] fold_x0 = (x_0 > 3'd2) ? 3'd5 - x_0 : x_0;
    wire [2:0] fold_y0 = (y_0 > 3'd2) ? 3'd5 - y_0 : y_0;
    wire [2:0] x_1     = x_0 + 3'd1;
    wire [2:0] fold_x1 = (x_1 > 3'd2) ? 3'd5 - x_1 : x_1;
    wire [2:0] y_1     = y_0 + 3'd1;
    wire [2:0] fold_y1 = (y_1 > 3'd2) ? 3'd5 - y_1 : y_1;

    wire [1:0] c_idx = (color_now == 2'b00) ? 2'd0 :
                       (color_now == 2'b11) ? 2'd2 : 2'd1;

    wire [11:0] gain_tab [0:2][0:2][0:2];
    assign gain_tab[0][0][0] = 12'h640; assign gain_tab[0][0][1] = 12'h5DC; assign gain_tab[0][0][2] = 12'h5AA;
    assign gain_tab[0][1][0] = 12'h5DC; assign gain_tab[0][1][1] = 12'h546; assign gain_tab[0][1][2] = 12'h4E2;
    assign gain_tab[0][2][0] = 12'h5AA; assign gain_tab[0][2][1] = 12'h4E2; assign gain_tab[0][2][2] = 12'h44C;
    assign gain_tab[1][0][0] = 12'h5DC; assign gain_tab[1][0][1] = 12'h58C; assign gain_tab[1][0][2] = 12'h550;
    assign gain_tab[1][1][0] = 12'h58C; assign gain_tab[1][1][1] = 12'h500; assign gain_tab[1][1][2] = 12'h4B0;
    assign gain_tab[1][2][0] = 12'h550; assign gain_tab[1][2][1] = 12'h4B0; assign gain_tab[1][2][2] = 12'h438;
    assign gain_tab[2][0][0] = 12'h6A4; assign gain_tab[2][0][1] = 12'h62C; assign gain_tab[2][0][2] = 12'h5DC;
    assign gain_tab[2][1][0] = 12'h62C; assign gain_tab[2][1][1] = 12'h58C; assign gain_tab[2][1][2] = 12'h528;
    assign gain_tab[2][2][0] = 12'h5DC; assign gain_tab[2][2][1] = 12'h528; assign gain_tab[2][2][2] = 12'h47E;

    wire [11:0] g00 = gain_tab[c_idx][fold_y0][fold_x0];
    wire [11:0] g01 = gain_tab[c_idx][fold_y0][fold_x1];
    wire [11:0] g10 = gain_tab[c_idx][fold_y1][fold_x0];
    wire [11:0] g11 = gain_tab[c_idx][fold_y1][fold_x1];

    reg [11:0] blc_s1, g00_s1, g01_s1, g10_s1, g11_s1;
    reg [1:0]  rx_s1, ry_s1;
    reg        valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s1 <= 1'b0;
        else        valid_s1 <= in_valid;
    end

    always @(posedge clk) begin
        blc_s1 <= blc_out;
        g00_s1 <= g00; g01_s1 <= g01; 
        g10_s1 <= g10; g11_s1 <= g11;
        rx_s1  <= r_x; ry_s1  <= r_y;
    end

    wire signed [21:0] diff_x0_ext = $signed({1'b0, g01_s1}) - $signed({1'b0, g00_s1});
    wire signed [21:0] diff_x1_ext = $signed({1'b0, g11_s1}) - $signed({1'b0, g10_s1});
    
    wire signed [21:0] dx0_5   = (diff_x0_ext <<< 2) + diff_x0_ext;
    wire signed [21:0] dx0_85  = (dx0_5 <<< 4) + dx0_5;
    wire signed [21:0] dx0_171 = (dx0_85 <<< 1) + diff_x0_ext;
    
    wire signed [21:0] dx1_5   = (diff_x1_ext <<< 2) + diff_x1_ext;
    wire signed [21:0] dx1_85  = (dx1_5 <<< 4) + dx1_5;
    wire signed [21:0] dx1_171 = (dx1_85 <<< 1) + diff_x1_ext;    

    wire signed [21:0] term_x0 = (rx_s1 == 2'd0) ? 22'sd0 : (rx_s1 == 2'd1) ? dx0_85 : dx0_171;
    wire signed [21:0] term_x1 = (rx_s1 == 2'd0) ? 22'sd0 : (rx_s1 == 2'd1) ? dx1_85 : dx1_171;
    
    wire [21:0] Y0_comb = $unsigned($signed({1'b0, g00_s1, 8'b0}) + term_x0);
    wire [21:0] Y1_comb = $unsigned($signed({1'b0, g10_s1, 8'b0}) + term_x1);

    reg [21:0] Y0_s2, Y1_s2;
    reg [1:0]  ry_s2;
    reg [11:0] blc_s2;
    reg        valid_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s2 <= 1'b0;
        else        valid_s2 <= valid_s1;
    end

    always @(posedge clk) begin
        Y0_s2  <= Y0_comb;
        Y1_s2  <= Y1_comb;
        ry_s2  <= ry_s1;
        blc_s2 <= blc_s1;
    end

    wire signed [31:0] diff_y_ext = $signed({1'b0, Y1_s2}) - $signed({1'b0, Y0_s2});
    wire signed [31:0] dy_5   = (diff_y_ext <<< 2) + diff_y_ext;
    wire signed [31:0] dy_85  = (dy_5 <<< 4) + dy_5;
    wire signed [31:0] dy_171 = (dy_85 <<< 1) + diff_y_ext;

    wire signed [31:0] term_y = (ry_s2 == 2'd0) ? 32'sd0 : (ry_s2 == 2'd1) ? dy_85 : dy_171;
    wire [30:0] G_val_comb = $unsigned($signed({1'b0, Y0_s2, 8'b0}) + term_y + 33'sd32768);

    reg [30:0] G_val_s3;
    reg [11:0] blc_s3;
    reg        valid_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s3 <= 1'b0;
        else        valid_s3 <= valid_s2;
    end

    always @(posedge clk) begin
        G_val_s3 <= G_val_comb;
        blc_s3   <= blc_s2;
    end

    wire [23:0] Pixel_full  = blc_s3 * G_val_s3[27:16] + 24'd512;
    wire [13:0] Pixel_trunc = Pixel_full[23:10];
    wire [11:0] Pixel_prime = (Pixel_trunc > 14'h0fff) ? 12'h0fff : Pixel_trunc[11:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_data  <= 12'd0;
        end else begin
            out_valid <= valid_s3;
            if (valid_s3) begin
                out_data <= Pixel_prime;
            end else begin
                out_data <= 12'd0;
            end
        end
    end

endmodule

// ============================================================================
// Module: DPC_STAGE
// ============================================================================
module DPC_STAGE(
    input             clk,
    input             rst_n,
    input             in_valid,
    input      [11:0] in_data,
    output reg        out_valid,
    output reg [11:0] out_data
);

    reg [11:0] sr_data  [0:68];
    reg [68:0] sr_valid;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sr_valid <= 69'd0;
        end else begin
            sr_valid <= {sr_valid[67:0], in_valid};
        end
    end

    always @(posedge clk) begin
        sr_data[0] <= in_data;
        for (i = 1; i < 69; i = i + 1) begin
            sr_data[i] <= sr_data[i-1];
        end
    end

    wire       valid_center = sr_valid[34];
    wire [3:0] dpc_x, dpc_y;

    XY_CNT u_xy_cnt (.clk(clk), .rst_n(rst_n), .en(valid_center), .x(dpc_x), .y(dpc_y));

    wire [11:0] r0_c0 = sr_data[68], r0_c2 = sr_data[66], r0_c4 = sr_data[64];
    wire [11:0] r1_c1 = sr_data[51], r1_c2 = sr_data[50], r1_c3 = sr_data[49];
    wire [11:0] r2_c0 = sr_data[36], r2_c1 = sr_data[35], r2_c2 = sr_data[34], r2_c3 = sr_data[33], r2_c4 = sr_data[32];
    wire [11:0] r3_c1 = sr_data[19], r3_c2 = sr_data[18], r3_c3 = sr_data[17];
    wire [11:0] r4_c0 = sr_data[4],  r4_c2 = sr_data[2],  r4_c4 = sr_data[0];

    wire [11:0] py0_c0 = (dpc_y == 0)  ? r4_c0 : ((dpc_y == 1)  ? r2_c0 : r0_c0);
    wire [11:0] py0_c2 = (dpc_y == 0)  ? r4_c2 : ((dpc_y == 1)  ? r2_c2 : r0_c2);
    wire [11:0] py0_c4 = (dpc_y == 0)  ? r4_c4 : ((dpc_y == 1)  ? r2_c4 : r0_c4);
    
    wire [11:0] py1_c1 = (dpc_y == 0)  ? r3_c1 : r1_c1;
    wire [11:0] py1_c2 = (dpc_y == 0)  ? r3_c2 : r1_c2;
    wire [11:0] py1_c3 = (dpc_y == 0)  ? r3_c3 : r1_c3;
    
    wire [11:0] py3_c1 = (dpc_y == 15) ? r1_c1 : r3_c1;
    wire [11:0] py3_c2 = (dpc_y == 15) ? r1_c2 : r3_c2;
    wire [11:0] py3_c3 = (dpc_y == 15) ? r1_c3 : r3_c3;
    
    wire [11:0] py4_c0 = (dpc_y == 15) ? r0_c0 : ((dpc_y == 14) ? r2_c0 : r4_c0);
    wire [11:0] py4_c2 = (dpc_y == 15) ? r0_c2 : ((dpc_y == 14) ? r2_c2 : r4_c2);
    wire [11:0] py4_c4 = (dpc_y == 15) ? r0_c4 : ((dpc_y == 14) ? r2_c4 : r4_c4);

    wire [11:0] w00 = (dpc_x == 0)  ? py0_c4 : ((dpc_x == 1)  ? py0_c2 : py0_c0);
    wire [11:0] w02 = py0_c2;
    wire [11:0] w04 = (dpc_x == 15) ? py0_c0 : ((dpc_x == 14) ? py0_c2 : py0_c4);
    
    wire [11:0] w11 = (dpc_x == 0)  ? py1_c3 : py1_c1;
    wire [11:0] w12 = py1_c2;
    wire [11:0] w13 = (dpc_x == 15) ? py1_c1 : py1_c3;

    wire [11:0] w20 = (dpc_x == 0)  ? r2_c4  : ((dpc_x == 1)  ? r2_c2  : r2_c0);
    wire [11:0] w21 = (dpc_x == 0)  ? r2_c3  : r2_c1;
    wire [11:0] w23 = (dpc_x == 15) ? r2_c1  : r2_c3;
    wire [11:0] w24 = (dpc_x == 15) ? r2_c0  : ((dpc_x == 14) ? r2_c2  : r2_c4);

    wire [11:0] w31 = (dpc_x == 0)  ? py3_c3 : py3_c1;
    wire [11:0] w32 = py3_c2;
    wire [11:0] w33 = (dpc_x == 15) ? py3_c1 : py3_c3;
    
    wire [11:0] w40 = (dpc_x == 0)  ? py4_c4 : ((dpc_x == 1)  ? py4_c2 : py4_c0);
    wire [11:0] w42 = py4_c2;
    wire [11:0] w44 = (dpc_x == 15) ? py4_c0 : ((dpc_x == 14) ? py4_c2 : py4_c4);

    reg [11:0] pw [0:15];
    reg [11:0] pc_s1;
    reg        valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s1 <= 1'b0;
        else        valid_s1 <= valid_center;
    end

    always @(posedge clk) begin
        pw[0]  <= w20; pw[1]  <= w21; pw[2]  <= w23; pw[3]  <= w24;
        pw[4]  <= w02; pw[5]  <= w12; pw[6]  <= w32; pw[7]  <= w42;
        pw[8]  <= w44; pw[9]  <= w33; pw[10] <= w11; pw[11] <= w00;
        pw[12] <= w40; pw[13] <= w31; pw[14] <= w13; pw[15] <= w04;
        pc_s1  <= r2_c2;
    end

    wire [11:0] mH_c, mV_c, mD1_c, mD2_c;
    MEDIAN4 mH_inst  (.a(pw[0]), .b(pw[1]), .c(pw[2]),  .d(pw[3]),  .out(mH_c));
    MEDIAN4 mV_inst  (.a(pw[4]), .b(pw[5]), .c(pw[6]),  .d(pw[7]),  .out(mV_c));
    MEDIAN4 mD1_inst (.a(pw[8]), .b(pw[9]), .c(pw[10]), .d(pw[11]), .out(mD1_c));
    MEDIAN4 mD2_inst (.a(pw[12]),.b(pw[13]),.c(pw[14]), .d(pw[15]), .out(mD2_c));

    reg [11:0] median_s2 [0:3]; 
    reg [11:0] pixels_s2 [0:15];  
    reg [11:0] pc_s2;
    reg        valid_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s2 <= 1'b0;
        else        valid_s2 <= valid_s1;
    end

    always @(posedge clk) begin
        median_s2[0] <= mH_c;  median_s2[1] <= mV_c;
        median_s2[2] <= mD1_c; median_s2[3] <= mD2_c;
        pc_s2 <= pc_s1;
        for (i = 0; i < 16; i = i + 1) begin
            pixels_s2[i] <= pw[i];
        end
    end

    wire [11:0] d_s3 [0:15];
    ABS_DIFF ad_0 (.a(pixels_s2[0]), .b(median_s2[0]), .out(d_s3[0]));
    ABS_DIFF ad_1 (.a(pixels_s2[1]), .b(median_s2[0]), .out(d_s3[1]));
    ABS_DIFF ad_2 (.a(pixels_s2[2]), .b(median_s2[0]), .out(d_s3[2]));
    ABS_DIFF ad_3 (.a(pixels_s2[3]), .b(median_s2[0]), .out(d_s3[3]));
    ABS_DIFF ad_4 (.a(pixels_s2[4]), .b(median_s2[1]), .out(d_s3[4]));
    ABS_DIFF ad_5 (.a(pixels_s2[5]), .b(median_s2[1]), .out(d_s3[5]));
    ABS_DIFF ad_6 (.a(pixels_s2[6]), .b(median_s2[1]), .out(d_s3[6]));
    ABS_DIFF ad_7 (.a(pixels_s2[7]), .b(median_s2[1]), .out(d_s3[7]));
    ABS_DIFF ad_8 (.a(pixels_s2[8]), .b(median_s2[2]), .out(d_s3[8]));
    ABS_DIFF ad_9 (.a(pixels_s2[9]), .b(median_s2[2]), .out(d_s3[9]));
    ABS_DIFF ad_10(.a(pixels_s2[10]),.b(median_s2[2]), .out(d_s3[10]));
    ABS_DIFF ad_11(.a(pixels_s2[11]),.b(median_s2[2]), .out(d_s3[11]));
    ABS_DIFF ad_12(.a(pixels_s2[12]),.b(median_s2[3]), .out(d_s3[12]));
    ABS_DIFF ad_13(.a(pixels_s2[13]),.b(median_s2[3]), .out(d_s3[13]));
    ABS_DIFF ad_14(.a(pixels_s2[14]),.b(median_s2[3]), .out(d_s3[14]));
    ABS_DIFF ad_15(.a(pixels_s2[15]),.b(median_s2[3]), .out(d_s3[15]));

    wire [13:0] s_c3 [0:3];
    assign s_c3[0] = ({2'b0, d_s3[0]}  + {2'b0, d_s3[1]})  + ({2'b0, d_s3[2]}  + {2'b0, d_s3[3]});
    assign s_c3[1] = ({2'b0, d_s3[4]}  + {2'b0, d_s3[5]})  + ({2'b0, d_s3[6]}  + {2'b0, d_s3[7]});
    assign s_c3[2] = ({2'b0, d_s3[8]}  + {2'b0, d_s3[9]})  + ({2'b0, d_s3[10]} + {2'b0, d_s3[11]});
    assign s_c3[3] = ({2'b0, d_s3[12]} + {2'b0, d_s3[13]}) + ({2'b0, d_s3[14]} + {2'b0, d_s3[15]});

    reg [13:0] s_s3 [0:3];
    reg [11:0] m_s3 [0:3];
    reg [11:0] pc_s3;
    reg        valid_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s3 <= 1'b0;
        else        valid_s3 <= valid_s2;
    end

    always @(posedge clk) begin
        for (i = 0; i < 4; i = i + 1) begin
            s_s3[i] <= s_c3[i];
            m_s3[i] <= median_s2[i];
        end
        pc_s3 <= pc_s2;
    end

    wire [11:0] diff_c [0:3];
    ABS_DIFF ad_16(pc_s3, m_s3[0], diff_c[0]); 
    ABS_DIFF ad_17(pc_s3, m_s3[1], diff_c[1]);
    ABS_DIFF ad_18(pc_s3, m_s3[2], diff_c[2]);
    ABS_DIFF ad_19(pc_s3, m_s3[3], diff_c[3]);

    wire w0_le_1 = (s_s3[0] <= s_s3[1]);
    wire w2_le_3 = (s_s3[2] <= s_s3[3]);
    
    wire [13:0] min_01 = w0_le_1 ? s_s3[0] : s_s3[1];
    wire [13:0] min_23 = w2_le_3 ? s_s3[2] : s_s3[3];
    wire w01_le_23     = (min_01 <= min_23);
    
    wire [1:0]  dir_sel_c4 = w01_le_23 ? (w0_le_1 ? 2'd0 : 2'd1) : (w2_le_3 ? 2'd2 : 2'd3);
    wire [11:0] dpc_out_c4 = (diff_c[dir_sel_c4] > 12'd320) ? m_s3[dir_sel_c4] : pc_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_data  <= 12'd0;
        end else begin
            out_valid <= valid_s3;
            if (valid_s3) begin
                out_data <= dpc_out_c4;
            end else begin
                out_data <= 12'd0;
            end
        end
    end

endmodule

// ============================================================================
// Module: DEM_STAGE
// ============================================================================
module DEM_STAGE(
    input             clk,
    input             rst_n,
    input             in_valid,
    input      [11:0] in_data,
    output reg        out_valid,
    output reg [11:0] out_r,
    output reg [11:0] out_g,
    output reg [11:0] out_b
);

    reg [11:0] sr_data  [0:34];
    reg [34:0] sr_valid;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sr_valid <= 35'd0;
        end else begin
            sr_valid <= {sr_valid[33:0], in_valid};
        end
    end

    always @(posedge clk) begin
        sr_data[0] <= in_data;
        for (i = 1; i < 35; i = i + 1) begin
            sr_data[i] <= sr_data[i-1];
        end
    end

    wire       valid_center = sr_valid[17];
    wire [3:0] dem_x, dem_y;

    XY_CNT u_xy_cnt (.clk(clk), .rst_n(rst_n), .en(valid_center), .x(dem_x), .y(dem_y));

    wire x0  = ~|dem_x; 
    wire x15 = &dem_x;
    wire y0  = ~|dem_y;
    wire y15 = &dem_y;

    wire [11:0] d_s0_c0 = sr_data[34], d_s0_c1 = sr_data[33], d_s0_c2 = sr_data[32];
    wire [11:0] d_s1_c0 = sr_data[18], d_s1_c1 = sr_data[17], d_s1_c2 = sr_data[16];
    wire [11:0] d_s2_c0 = sr_data[2],  d_s2_c1 = sr_data[1],  d_s2_c2 = sr_data[0];

    wire [11:0] top_c0 = y0  ? d_s2_c0 : d_s0_c0;
    wire [11:0] top_c1 = y0  ? d_s2_c1 : d_s0_c1;
    wire [11:0] top_c2 = y0  ? d_s2_c2 : d_s0_c2;
    wire [11:0] bot_c0 = y15 ? d_s0_c0 : d_s2_c0;
    wire [11:0] bot_c1 = y15 ? d_s0_c1 : d_s2_c1;
    wire [11:0] bot_c2 = y15 ? d_s0_c2 : d_s2_c2;

    wire [11:0] d_NW = x0  ? top_c2 : top_c0;
    wire [11:0] d_N  = top_c1;
    wire [11:0] d_NE = x15 ? top_c0 : top_c2;
    
    wire [11:0] d_W  = x0  ? d_s1_c2 : d_s1_c0;
    wire [11:0] d_C  = d_s1_c1;
    wire [11:0] d_E  = x15 ? d_s1_c0 : d_s1_c2;
    
    wire [11:0] d_SW = x0  ? bot_c2 : bot_c0;
    wire [11:0] d_S  = bot_c1;
    wire [11:0] d_SE = x15 ? bot_c0 : bot_c2;

    wire [13:0] sum_H     = {2'b0, d_W} + {2'b0, d_E};
    wire [13:0] sum_V     = {2'b0, d_N} + {2'b0, d_S};
    wire [13:0] sum_ortho = sum_H + sum_V;
    wire [13:0] sum_diag  = ({2'b0, d_NW} + {2'b0, d_NE}) + ({2'b0, d_SW} + {2'b0, d_SE});

    reg [11:0] aO_s1, aD_s1, aH_s1, aV_s1, dC_s1;
    reg [1:0]  col_s1;
    reg        valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s1 <= 1'b0;
        else        valid_s1 <= valid_center;
    end

    always @(posedge clk) begin
        aO_s1  <= sum_ortho[13:2];
        aD_s1  <= sum_diag[13:2];
        aH_s1  <= sum_H[12:1];       
        aV_s1  <= sum_V[12:1];
        dC_s1  <= d_C;
        col_s1 <= {dem_y[0], dem_x[0]};
    end

    wire same_parity = ~(col_s1[1] ^ col_s1[0]);

    wire [11:0] r_y0 = col_s1[0] ? aH_s1 : dC_s1; 
    wire [11:0] r_y1 = col_s1[0] ? aD_s1 : aV_s1;
    wire [11:0] dR_c = col_s1[1] ? r_y1  : r_y0;

    wire [11:0] b_y0 = col_s1[0] ? aV_s1 : aD_s1;
    wire [11:0] b_y1 = col_s1[0] ? dC_s1 : aH_s1;
    wire [11:0] dB_c = col_s1[1] ? b_y1  : b_y0;
    
    wire [11:0] dG_c = same_parity ? aO_s1 : dC_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_r     <= 12'd0;
            out_g     <= 12'd0;
            out_b     <= 12'd0;
        end else begin
            out_valid <= valid_s1;
            if (valid_s1) begin
                out_r <= dR_c;
                out_g <= dG_c;
                out_b <= dB_c;
            end else begin
                out_r <= 12'd0;
                out_g <= 12'd0;
                out_b <= 12'd0;
            end
        end
    end

endmodule

// ============================================================================
// Module: CCM_STAGE 
// ============================================================================
module CCM_STAGE(
    input             clk,
    input             rst_n,
    input             in_valid,
    input      [11:0] in_r,
    input      [11:0] in_g,
    input      [11:0] in_b,
    output reg        out_valid,
    output reg [7:0]  out_r,
    output reg [7:0]  out_g,
    output reg [7:0]  out_b
);

    wire signed [14:0] sum_c      = $signed({1'b0, in_r}) + $signed({1'b0, in_g}) + $signed({1'b0, in_b});
    wire signed [21:0] common_sub = (sum_c <<< 5) + (sum_c <<< 4) + (sum_c <<< 1);
    
    wire signed [14:0] s_dR = {3'b0, in_r};
    wire signed [14:0] s_dG = {3'b0, in_g};
    wire signed [14:0] s_dB = {3'b0, in_b};

    wire signed [24:0] r_1150 = (s_dR <<< 10) + (s_dR <<< 7) - (s_dR <<< 1);
    wire signed [24:0] g_1150 = (s_dG <<< 10) + (s_dG <<< 7) - (s_dG <<< 1);
    wire signed [24:0] b_1150 = (s_dB <<< 10) + (s_dB <<< 7) - (s_dB <<< 1);

    reg signed [21:0] common_s1;
    reg signed [24:0] r1150_s1, g1150_s1, b1150_s1;
    reg               valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_s1 <= 1'b0;
        else        valid_s1 <= in_valid;
    end

    always @(posedge clk) begin
        common_s1 <= common_sub;
        r1150_s1  <= r_1150;
        g1150_s1  <= g_1150; 
        b1150_s1  <= b_1150;
    end

    wire signed [24:0] cR_full = (r1150_s1 + 25'd512) - common_s1;
    wire signed [24:0] cG_full = (g1150_s1 + 25'd512) - common_s1;
    wire signed [24:0] cB_full = (b1150_s1 + 25'd512) - common_s1;

    wire signed [14:0] r_shift = cR_full >>> 10;
    wire signed [14:0] g_shift = cG_full >>> 10;
    wire signed [14:0] b_shift = cB_full >>> 10;

    wire [11:0] r_out_comb = (r_shift[14]) ? 12'd0 : (|r_shift[13:12]) ? 12'hfff : r_shift[11:0];
    wire [11:0] g_out_comb = (g_shift[14]) ? 12'd0 : (|g_shift[13:12]) ? 12'hfff : g_shift[11:0];
    wire [11:0] b_out_comb = (b_shift[14]) ? 12'd0 : (|b_shift[13:12]) ? 12'hfff : b_shift[11:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_r     <= 8'd0;
            out_g     <= 8'd0;
            out_b     <= 8'd0;
        end else begin
            out_valid <= valid_s1;
            if (valid_s1) begin
                out_r <= r_out_comb[11:4];
                out_g <= g_out_comb[11:4];
                out_b <= b_out_comb[11:4];
            end else begin
                out_r <= 8'd0;
                out_g <= 8'd0;
                out_b <= 8'd0;
            end
        end
    end

endmodule

// ============================================================================
// Sub-Module: MEDIAN4
// ============================================================================
module MEDIAN4(
    input  [11:0] a, b, c, d,
    output [11:0] out
);
    wire [11:0] min1 = (a < b) ? a : b;
    wire [11:0] max1 = (a > b) ? a : b;
    wire [11:0] min2 = (c < d) ? c : d;
    wire [11:0] max2 = (c > d) ? c : d;
    
    wire [11:0] mid1 = (min1 > min2) ? min1 : min2;
    wire [11:0] mid2 = (max1 < max2) ? max1 : max2;
    
    wire [12:0] sum  = {1'b0, mid1} + {1'b0, mid2};
    assign out = sum[12:1];
endmodule

// ============================================================================
// Sub-Module: ABS_DIFF
// ============================================================================
module ABS_DIFF(
    input  [11:0] a, b,
    output [11:0] out
);
    wire [12:0] sub  = {1'b0, a} - {1'b0, b};
    wire        sign = sub[12];
    assign out = (sub[11:0] ^ {12{sign}}) + sign;
endmodule