module DRCA (
    input [3:0]  drc_sel,
    input [18:0] shape0 ,
    input [18:0] shape1 ,
    input [18:0] shape2 ,
    input [18:0] shape3 ,
    input [18:0] shape4 ,
    input [18:0] shape5 ,
    input [18:0] shape6 ,
    input [18:0] shape7 ,
    input [18:0] shape8 ,
    input [18:0] shape9 ,
    input [18:0] shape10 ,
    input [18:0] shape11 ,
    input [18:0] shape12 ,
    input [18:0] shape13 ,
    input [18:0] shape14 ,
    input [18:0] shape15 ,
    output [4:0] drc_out
);


//**************************************************
// Parameter 
//**************************************************
    
    integer i, r, c;

//**************************************************
// Reg & Wire 
//**************************************************
    wire [18:0] shape_in [0:15];
    wire [2:0] target_layer = drc_sel[3:1] + 3'd1;
    wire spacing = drc_sel[0];

    reg [15:0] x_span [0:15];
    reg [15:0] y_span [0:15];
    
    reg [3:0] limit;

    reg [15:0] is_match;
    reg [3:0] xl,xh,yl,yh;
    //
    wire [15:0] grid_move [0:15];
    wire [25:0] padding_row     [0:15];
    wire [25:0] padding_col     [0:15];
    //
    reg [15:0] violnum_x [0:15];
    reg [15:0] violnum_y [0:15];

    
    reg edge_curr, edge_prev;
    reg [3:0] len_curr, len_prev;
    reg hit_curr, is_thesame;

    
    reg [4:0] violnum_x_toatal [0:15];
    reg [4:0] violnum_y_total [0:15];
//**************************************************
// Design 
//**************************************************
    assign shape_in[0] = shape0;   assign shape_in[1] = shape1;
    assign shape_in[2] = shape2;   assign shape_in[3] = shape3;
    assign shape_in[4] = shape4;   assign shape_in[5] = shape5;
    assign shape_in[6] = shape6;   assign shape_in[7] = shape7;
    assign shape_in[8] = shape8;   assign shape_in[9] = shape9;
    assign shape_in[10]= shape10;  assign shape_in[11]= shape11;
    assign shape_in[12]= shape12;  assign shape_in[13]= shape13;
    assign shape_in[14]= shape14;  assign shape_in[15]= shape15;

    
    always @(*) begin
        case(drc_sel)
            4'b1100: limit = 4'b1111;                             // NW W>=5
            4'b1000, 4'b1010, 4'b1101: limit = 4'b0111;           // NP/PP W>=4, NW S>=4
            4'b0010, 4'b0110, 4'b1001, 4'b1011: limit = 4'b0011;  // OD/M1 W>=3, NP/PP S>=3
            default: limit = 4'b0001;                             // W>=2, S>=2
        endcase
    end

    
    
    always @(*) begin
        for(i = 0; i < 16; i = i + 1) begin
            is_match = (shape_in[i][18:16] == target_layer);
            xl       = shape_in[i][15:12];
            yl       = shape_in[i][11:8];
            xh       = shape_in[i][7:4];
            yh       = shape_in[i][3:0];
            
            if (is_match) begin
                x_span[i] = (16'hFFFF << xl) & ~(16'hFFFF << xh);
            end else begin
                x_span[i] = 16'd0;
            end
    
            y_span[i] = (16'hFFFF << yl) & ~(16'hFFFF << yh);
        end
    end

    /////////////////////////////////////////////
    /////////////////////////////////////////////
    /////////////////////////////////////////////

    

    
    CANVAS_ROW u_row0 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][0]), .y1(y_span[1][0]), .y2(y_span[2][0]), .y3(y_span[3][0]), .y4(y_span[4][0]), .y5(y_span[5][0]), .y6(y_span[6][0]), .y7(y_span[7][0]), .y8(y_span[8][0]), .y9(y_span[9][0]), .y10(y_span[10][0]), .y11(y_span[11][0]), .y12(y_span[12][0]), .y13(y_span[13][0]), .y14(y_span[14][0]), .y15(y_span[15][0]), .row_active(grid_move[0]), .padding_row(padding_row[0]) );

    CANVAS_ROW u_row1 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][1]), .y1(y_span[1][1]), .y2(y_span[2][1]), .y3(y_span[3][1]), .y4(y_span[4][1]), .y5(y_span[5][1]), .y6(y_span[6][1]), .y7(y_span[7][1]), .y8(y_span[8][1]), .y9(y_span[9][1]), .y10(y_span[10][1]), .y11(y_span[11][1]), .y12(y_span[12][1]), .y13(y_span[13][1]), .y14(y_span[14][1]), .y15(y_span[15][1]), .row_active(grid_move[1]), .padding_row(padding_row[1]) );

    CANVAS_ROW u_row2 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][2]), .y1(y_span[1][2]), .y2(y_span[2][2]), .y3(y_span[3][2]), .y4(y_span[4][2]), .y5(y_span[5][2]), .y6(y_span[6][2]), .y7(y_span[7][2]), .y8(y_span[8][2]), .y9(y_span[9][2]), .y10(y_span[10][2]), .y11(y_span[11][2]), .y12(y_span[12][2]), .y13(y_span[13][2]), .y14(y_span[14][2]), .y15(y_span[15][2]), .row_active(grid_move[2]), .padding_row(padding_row[2]) );

    CANVAS_ROW u_row3 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][3]), .y1(y_span[1][3]), .y2(y_span[2][3]), .y3(y_span[3][3]), .y4(y_span[4][3]), .y5(y_span[5][3]), .y6(y_span[6][3]), .y7(y_span[7][3]), .y8(y_span[8][3]), .y9(y_span[9][3]), .y10(y_span[10][3]), .y11(y_span[11][3]), .y12(y_span[12][3]), .y13(y_span[13][3]), .y14(y_span[14][3]), .y15(y_span[15][3]), .row_active(grid_move[3]), .padding_row(padding_row[3]) );

    CANVAS_ROW u_row4 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][4]), .y1(y_span[1][4]), .y2(y_span[2][4]), .y3(y_span[3][4]), .y4(y_span[4][4]), .y5(y_span[5][4]), .y6(y_span[6][4]), .y7(y_span[7][4]), .y8(y_span[8][4]), .y9(y_span[9][4]), .y10(y_span[10][4]), .y11(y_span[11][4]), .y12(y_span[12][4]), .y13(y_span[13][4]), .y14(y_span[14][4]), .y15(y_span[15][4]), .row_active(grid_move[4]), .padding_row(padding_row[4]) );

    CANVAS_ROW u_row5 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][5]), .y1(y_span[1][5]), .y2(y_span[2][5]), .y3(y_span[3][5]), .y4(y_span[4][5]), .y5(y_span[5][5]), .y6(y_span[6][5]), .y7(y_span[7][5]), .y8(y_span[8][5]), .y9(y_span[9][5]), .y10(y_span[10][5]), .y11(y_span[11][5]), .y12(y_span[12][5]), .y13(y_span[13][5]), .y14(y_span[14][5]), .y15(y_span[15][5]), .row_active(grid_move[5]), .padding_row(padding_row[5]) );

    CANVAS_ROW u_row6 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][6]), .y1(y_span[1][6]), .y2(y_span[2][6]), .y3(y_span[3][6]), .y4(y_span[4][6]), .y5(y_span[5][6]), .y6(y_span[6][6]), .y7(y_span[7][6]), .y8(y_span[8][6]), .y9(y_span[9][6]), .y10(y_span[10][6]), .y11(y_span[11][6]), .y12(y_span[12][6]), .y13(y_span[13][6]), .y14(y_span[14][6]), .y15(y_span[15][6]), .row_active(grid_move[6]), .padding_row(padding_row[6]) );

    CANVAS_ROW u_row7 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][7]), .y1(y_span[1][7]), .y2(y_span[2][7]), .y3(y_span[3][7]), .y4(y_span[4][7]), .y5(y_span[5][7]), .y6(y_span[6][7]), .y7(y_span[7][7]), .y8(y_span[8][7]), .y9(y_span[9][7]), .y10(y_span[10][7]), .y11(y_span[11][7]), .y12(y_span[12][7]), .y13(y_span[13][7]), .y14(y_span[14][7]), .y15(y_span[15][7]), .row_active(grid_move[7]), .padding_row(padding_row[7]) );

    CANVAS_ROW u_row8 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][8]), .y1(y_span[1][8]), .y2(y_span[2][8]), .y3(y_span[3][8]), .y4(y_span[4][8]), .y5(y_span[5][8]), .y6(y_span[6][8]), .y7(y_span[7][8]), .y8(y_span[8][8]), .y9(y_span[9][8]), .y10(y_span[10][8]), .y11(y_span[11][8]), .y12(y_span[12][8]), .y13(y_span[13][8]), .y14(y_span[14][8]), .y15(y_span[15][8]), .row_active(grid_move[8]), .padding_row(padding_row[8]) );

    CANVAS_ROW u_row9 ( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][9]), .y1(y_span[1][9]), .y2(y_span[2][9]), .y3(y_span[3][9]), .y4(y_span[4][9]), .y5(y_span[5][9]), .y6(y_span[6][9]), .y7(y_span[7][9]), .y8(y_span[8][9]), .y9(y_span[9][9]), .y10(y_span[10][9]), .y11(y_span[11][9]), .y12(y_span[12][9]), .y13(y_span[13][9]), .y14(y_span[14][9]), .y15(y_span[15][9]), .row_active(grid_move[9]), .padding_row(padding_row[9]) );

    CANVAS_ROW u_row10( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][10]),.y1(y_span[1][10]),.y2(y_span[2][10]),.y3(y_span[3][10]),.y4(y_span[4][10]),.y5(y_span[5][10]),.y6(y_span[6][10]),.y7(y_span[7][10]),.y8(y_span[8][10]),.y9(y_span[9][10]),.y10(y_span[10][10]),.y11(y_span[11][10]),.y12(y_span[12][10]),.y13(y_span[13][10]),.y14(y_span[14][10]),.y15(y_span[15][10]),.row_active(grid_move[10]),.padding_row(padding_row[10]) );

    CANVAS_ROW u_row11( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][11]),.y1(y_span[1][11]),.y2(y_span[2][11]),.y3(y_span[3][11]),.y4(y_span[4][11]),.y5(y_span[5][11]),.y6(y_span[6][11]),.y7(y_span[7][11]),.y8(y_span[8][11]),.y9(y_span[9][11]),.y10(y_span[10][11]),.y11(y_span[11][11]),.y12(y_span[12][11]),.y13(y_span[13][11]),.y14(y_span[14][11]),.y15(y_span[15][11]),.row_active(grid_move[11]),.padding_row(padding_row[11]) );

    CANVAS_ROW u_row12( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][12]),.y1(y_span[1][12]),.y2(y_span[2][12]),.y3(y_span[3][12]),.y4(y_span[4][12]),.y5(y_span[5][12]),.y6(y_span[6][12]),.y7(y_span[7][12]),.y8(y_span[8][12]),.y9(y_span[9][12]),.y10(y_span[10][12]),.y11(y_span[11][12]),.y12(y_span[12][12]),.y13(y_span[13][12]),.y14(y_span[14][12]),.y15(y_span[15][12]),.row_active(grid_move[12]),.padding_row(padding_row[12]) );

    CANVAS_ROW u_row13( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][13]),.y1(y_span[1][13]),.y2(y_span[2][13]),.y3(y_span[3][13]),.y4(y_span[4][13]),.y5(y_span[5][13]),.y6(y_span[6][13]),.y7(y_span[7][13]),.y8(y_span[8][13]),.y9(y_span[9][13]),.y10(y_span[10][13]),.y11(y_span[11][13]),.y12(y_span[12][13]),.y13(y_span[13][13]),.y14(y_span[14][13]),.y15(y_span[15][13]),.row_active(grid_move[13]),.padding_row(padding_row[13]) );

    CANVAS_ROW u_row14( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][14]),.y1(y_span[1][14]),.y2(y_span[2][14]),.y3(y_span[3][14]),.y4(y_span[4][14]),.y5(y_span[5][14]),.y6(y_span[6][14]),.y7(y_span[7][14]),.y8(y_span[8][14]),.y9(y_span[9][14]),.y10(y_span[10][14]),.y11(y_span[11][14]),.y12(y_span[12][14]),.y13(y_span[13][14]),.y14(y_span[14][14]),.y15(y_span[15][14]),.row_active(grid_move[14]),.padding_row(padding_row[14]) );

    CANVAS_ROW u_row15( .spacing(spacing), .x0(x_span[0]), .x1(x_span[1]), .x2(x_span[2]), .x3(x_span[3]), .x4(x_span[4]), .x5(x_span[5]), .x6(x_span[6]), .x7(x_span[7]), .x8(x_span[8]), .x9(x_span[9]), .x10(x_span[10]), .x11(x_span[11]), .x12(x_span[12]), .x13(x_span[13]), .x14(x_span[14]), .x15(x_span[15]),
        .y0(y_span[0][15]),.y1(y_span[1][15]),.y2(y_span[2][15]),.y3(y_span[3][15]),.y4(y_span[4][15]),.y5(y_span[5][15]),.y6(y_span[6][15]),.y7(y_span[7][15]),.y8(y_span[8][15]),.y9(y_span[9][15]),.y10(y_span[10][15]),.y11(y_span[11][15]),.y12(y_span[12][15]),.y13(y_span[13][15]),.y14(y_span[14][15]),.y15(y_span[15][15]),.row_active(grid_move[15]),.padding_row(padding_row[15]) );

    assign padding_col[0]  = { {5{spacing}}, grid_move[15][0],  grid_move[14][0],  grid_move[13][0],  grid_move[12][0],  grid_move[11][0],  grid_move[10][0],  grid_move[9][0],  grid_move[8][0],  grid_move[7][0],  grid_move[6][0],  grid_move[5][0],  grid_move[4][0],  grid_move[3][0],  grid_move[2][0],  grid_move[1][0],  grid_move[0][0],  {5{spacing}} };
    assign padding_col[1]  = { {5{spacing}}, grid_move[15][1],  grid_move[14][1],  grid_move[13][1],  grid_move[12][1],  grid_move[11][1],  grid_move[10][1],  grid_move[9][1],  grid_move[8][1],  grid_move[7][1],  grid_move[6][1],  grid_move[5][1],  grid_move[4][1],  grid_move[3][1],  grid_move[2][1],  grid_move[1][1],  grid_move[0][1],  {5{spacing}} };
    assign padding_col[2]  = { {5{spacing}}, grid_move[15][2],  grid_move[14][2],  grid_move[13][2],  grid_move[12][2],  grid_move[11][2],  grid_move[10][2],  grid_move[9][2],  grid_move[8][2],  grid_move[7][2],  grid_move[6][2],  grid_move[5][2],  grid_move[4][2],  grid_move[3][2],  grid_move[2][2],  grid_move[1][2],  grid_move[0][2],  {5{spacing}} };
    assign padding_col[3]  = { {5{spacing}}, grid_move[15][3],  grid_move[14][3],  grid_move[13][3],  grid_move[12][3],  grid_move[11][3],  grid_move[10][3],  grid_move[9][3],  grid_move[8][3],  grid_move[7][3],  grid_move[6][3],  grid_move[5][3],  grid_move[4][3],  grid_move[3][3],  grid_move[2][3],  grid_move[1][3],  grid_move[0][3],  {5{spacing}} };
    assign padding_col[4]  = { {5{spacing}}, grid_move[15][4],  grid_move[14][4],  grid_move[13][4],  grid_move[12][4],  grid_move[11][4],  grid_move[10][4],  grid_move[9][4],  grid_move[8][4],  grid_move[7][4],  grid_move[6][4],  grid_move[5][4],  grid_move[4][4],  grid_move[3][4],  grid_move[2][4],  grid_move[1][4],  grid_move[0][4],  {5{spacing}} };
    assign padding_col[5]  = { {5{spacing}}, grid_move[15][5],  grid_move[14][5],  grid_move[13][5],  grid_move[12][5],  grid_move[11][5],  grid_move[10][5],  grid_move[9][5],  grid_move[8][5],  grid_move[7][5],  grid_move[6][5],  grid_move[5][5],  grid_move[4][5],  grid_move[3][5],  grid_move[2][5],  grid_move[1][5],  grid_move[0][5],  {5{spacing}} };
    assign padding_col[6]  = { {5{spacing}}, grid_move[15][6],  grid_move[14][6],  grid_move[13][6],  grid_move[12][6],  grid_move[11][6],  grid_move[10][6],  grid_move[9][6],  grid_move[8][6],  grid_move[7][6],  grid_move[6][6],  grid_move[5][6],  grid_move[4][6],  grid_move[3][6],  grid_move[2][6],  grid_move[1][6],  grid_move[0][6],  {5{spacing}} };
    assign padding_col[7]  = { {5{spacing}}, grid_move[15][7],  grid_move[14][7],  grid_move[13][7],  grid_move[12][7],  grid_move[11][7],  grid_move[10][7],  grid_move[9][7],  grid_move[8][7],  grid_move[7][7],  grid_move[6][7],  grid_move[5][7],  grid_move[4][7],  grid_move[3][7],  grid_move[2][7],  grid_move[1][7],  grid_move[0][7],  {5{spacing}} };
    assign padding_col[8]  = { {5{spacing}}, grid_move[15][8],  grid_move[14][8],  grid_move[13][8],  grid_move[12][8],  grid_move[11][8],  grid_move[10][8],  grid_move[9][8],  grid_move[8][8],  grid_move[7][8],  grid_move[6][8],  grid_move[5][8],  grid_move[4][8],  grid_move[3][8],  grid_move[2][8],  grid_move[1][8],  grid_move[0][8],  {5{spacing}} };
    assign padding_col[9]  = { {5{spacing}}, grid_move[15][9],  grid_move[14][9],  grid_move[13][9],  grid_move[12][9],  grid_move[11][9],  grid_move[10][9],  grid_move[9][9],  grid_move[8][9],  grid_move[7][9],  grid_move[6][9],  grid_move[5][9],  grid_move[4][9],  grid_move[3][9],  grid_move[2][9],  grid_move[1][9],  grid_move[0][9],  {5{spacing}} };
    assign padding_col[10] = { {5{spacing}}, grid_move[15][10], grid_move[14][10], grid_move[13][10], grid_move[12][10], grid_move[11][10], grid_move[10][10], grid_move[9][10], grid_move[8][10], grid_move[7][10], grid_move[6][10], grid_move[5][10], grid_move[4][10], grid_move[3][10], grid_move[2][10], grid_move[1][10], grid_move[0][10], {5{spacing}} };
    assign padding_col[11] = { {5{spacing}}, grid_move[15][11], grid_move[14][11], grid_move[13][11], grid_move[12][11], grid_move[11][11], grid_move[10][11], grid_move[9][11], grid_move[8][11], grid_move[7][11], grid_move[6][11], grid_move[5][11], grid_move[4][11], grid_move[3][11], grid_move[2][11], grid_move[1][11], grid_move[0][11], {5{spacing}} };
    assign padding_col[12] = { {5{spacing}}, grid_move[15][12], grid_move[14][12], grid_move[13][12], grid_move[12][12], grid_move[11][12], grid_move[10][12], grid_move[9][12], grid_move[8][12], grid_move[7][12], grid_move[6][12], grid_move[5][12], grid_move[4][12], grid_move[3][12], grid_move[2][12], grid_move[1][12], grid_move[0][12], {5{spacing}} };
    assign padding_col[13] = { {5{spacing}}, grid_move[15][13], grid_move[14][13], grid_move[13][13], grid_move[12][13], grid_move[11][13], grid_move[10][13], grid_move[9][13], grid_move[8][13], grid_move[7][13], grid_move[6][13], grid_move[5][13], grid_move[4][13], grid_move[3][13], grid_move[2][13], grid_move[1][13], grid_move[0][13], {5{spacing}} };
    assign padding_col[14] = { {5{spacing}}, grid_move[15][14], grid_move[14][14], grid_move[13][14], grid_move[12][14], grid_move[11][14], grid_move[10][14], grid_move[9][14], grid_move[8][14], grid_move[7][14], grid_move[6][14], grid_move[5][14], grid_move[4][14], grid_move[3][14], grid_move[2][14], grid_move[1][14], grid_move[0][14], {5{spacing}} };
    assign padding_col[15] = { {5{spacing}}, grid_move[15][15], grid_move[14][15], grid_move[13][15], grid_move[12][15], grid_move[11][15], grid_move[10][15], grid_move[9][15], grid_move[8][15], grid_move[7][15], grid_move[6][15], grid_move[5][15], grid_move[4][15], grid_move[3][15], grid_move[2][15], grid_move[1][15], grid_move[0][15], {5{spacing}} };

    
    /////////////////////////////////////////////
    /////////////////////////////////////////////
    /////////////////////////////////////////////
    

    always @(*) begin
        //Row
        for (r = 0; r < 16; r = r + 1) begin
            for (c = 5; c <= 20; c = c + 1) begin
                edge_curr = ~padding_row[r][c-1] & padding_row[r][c];
    
                len_curr[0] = ~padding_row[r][c+1];
                len_curr[1] =  padding_row[r][c+1] & ~padding_row[r][c+2];
                len_curr[2] =  padding_row[r][c+1] &  padding_row[r][c+2] & ~padding_row[r][c+3];
                len_curr[3] =  padding_row[r][c+1] &  padding_row[r][c+2] &  padding_row[r][c+3] & ~padding_row[r][c+4];
                
                hit_curr = edge_curr & |(len_curr & limit);

                if (r == 0) begin
                    violnum_x[r][c-5] = hit_curr;
                end 
                else begin
                    edge_prev = ~padding_row[r-1][c-1] & padding_row[r-1][c];
                    
                    len_prev[0] = ~padding_row[r-1][c+1];
                    len_prev[1] =  padding_row[r-1][c+1] & ~padding_row[r-1][c+2];
                    len_prev[2] =  padding_row[r-1][c+1] &  padding_row[r-1][c+2] & ~padding_row[r-1][c+3];
                    len_prev[3] =  padding_row[r-1][c+1] &  padding_row[r-1][c+2] &  padding_row[r-1][c+3] & ~padding_row[r-1][c+4];
                    
                    is_thesame = edge_prev & |(len_curr & len_prev);
                    
                    violnum_x[r][c-5] = hit_curr & ~is_thesame;
                end
            end
        end
    
    
        // Col
        for (c = 0; c < 16; c = c + 1) begin
            for (r = 5; r <= 20; r = r + 1) begin
                edge_curr = ~padding_col[c][r-1] & padding_col[c][r];
                
                len_curr[0] = ~padding_col[c][r+1];
                len_curr[1] =  padding_col[c][r+1] & ~padding_col[c][r+2];
                len_curr[2] =  padding_col[c][r+1] &  padding_col[c][r+2] & ~padding_col[c][r+3];
                len_curr[3] =  padding_col[c][r+1] &  padding_col[c][r+2] &  padding_col[c][r+3] & ~padding_col[c][r+4];
                
                hit_curr = edge_curr & |(len_curr & limit);

                if (c == 0) begin
                    violnum_y[c][r-5] = hit_curr;
                end 
                else begin
                    edge_prev = ~padding_col[c-1][r-1] & padding_col[c-1][r];
                    
                    len_prev[0] = ~padding_col[c-1][r+1];
                    len_prev[1] =  padding_col[c-1][r+1] & ~padding_col[c-1][r+2];
                    len_prev[2] =  padding_col[c-1][r+1] &  padding_col[c-1][r+2] & ~padding_col[c-1][r+3];
                    len_prev[3] =  padding_col[c-1][r+1] &  padding_col[c-1][r+2] &  padding_col[c-1][r+3] & ~padding_col[c-1][r+4];
                    
                    is_thesame = edge_prev & |(len_curr & len_prev);
                    
                    violnum_y[c][r-5] = hit_curr & ~ is_thesame;
                end
            end
        end
    end

   
    
    always @(*) begin
        for (i = 0; i < 16; i = i + 1) begin
            violnum_x_toatal[i] = (violnum_x[i][0]  | violnum_x[i][1])  +
                        (violnum_x[i][2]  | violnum_x[i][3])  +
                        (violnum_x[i][4]  | violnum_x[i][5])  +
                        (violnum_x[i][6]  | violnum_x[i][7])  +
                        (violnum_x[i][8]  | violnum_x[i][9])  +
                        (violnum_x[i][10] | violnum_x[i][11]) +
                        (violnum_x[i][12] | violnum_x[i][13]) +
                        (violnum_x[i][14] | violnum_x[i][15]);

            violnum_y_total[i] = (violnum_y[i][0]  | violnum_y[i][1])  +
                        (violnum_y[i][2]  | violnum_y[i][3])  +
                        (violnum_y[i][4]  | violnum_y[i][5])  +
                        (violnum_y[i][6]  | violnum_y[i][7])  +
                        (violnum_y[i][8]  | violnum_y[i][9])  +
                        (violnum_y[i][10] | violnum_y[i][11]) +
                        (violnum_y[i][12] | violnum_y[i][13]) +
                        (violnum_y[i][14] | violnum_y[i][15]);
        end
    end

    
    assign drc_out = violnum_x_toatal[0]  + violnum_x_toatal[1]  + violnum_x_toatal[2]  + violnum_x_toatal[3]  +
                           violnum_x_toatal[4]  + violnum_x_toatal[5]  + violnum_x_toatal[6]  + violnum_x_toatal[7]  +
                           violnum_x_toatal[8]  + violnum_x_toatal[9]  + violnum_x_toatal[10] + violnum_x_toatal[11] +
                           violnum_x_toatal[12] + violnum_x_toatal[13] + violnum_x_toatal[14] + violnum_x_toatal[15] +
                           violnum_y_total[0]  + violnum_y_total[1]  + violnum_y_total[2]  + violnum_y_total[3]  +
                           violnum_y_total[4]  + violnum_y_total[5]  + violnum_y_total[6]  + violnum_y_total[7]  +
                           violnum_y_total[8]  + violnum_y_total[9]  + violnum_y_total[10] + violnum_y_total[11] +
                           violnum_y_total[12] + violnum_y_total[13] + violnum_y_total[14] + violnum_y_total[15];



endmodule


module CANVAS_ROW (
    input         spacing,
    input  [15:0] x0,  x1,  x2,  x3,  x4,  x5,  x6,  x7,
                  x8,  x9,  x10, x11, x12, x13, x14, x15,
    input         y0,  y1,  y2,  y3,  y4,  y5,  y6,  y7,
                  y8,  y9,  y10, y11, y12, y13, y14, y15,
    output [15:0] row_active,
    output [25:0] padding_row
);
    wire [15:0] g0, g1, g2, g3, row_raw;

    MASKED_OR4 grp0 (.x0(x0), .x1(x1),  .x2(x2),  .x3(x3),
                     .y0(y0), .y1(y1),  .y2(y2),  .y3(y3),  .out(g0));
    MASKED_OR4 grp1 (.x0(x4), .x1(x5),  .x2(x6),  .x3(x7),
                     .y0(y4), .y1(y5),  .y2(y6),  .y3(y7),  .out(g1));
    MASKED_OR4 grp2 (.x0(x8), .x1(x9),  .x2(x10), .x3(x11),
                     .y0(y8), .y1(y9),  .y2(y10), .y3(y11), .out(g2));
    MASKED_OR4 grp3 (.x0(x12),.x1(x13), .x2(x14), .x3(x15),
                     .y0(y12),.y1(y13), .y2(y14), .y3(y15), .out(g3));

    assign row_raw = g0 | g1 | g2 | g3;

    ROW_CTRL ctrl (
        .spacing(spacing),
        .row_raw(row_raw),
        .row_active(row_active),
        .padding_row(padding_row)
    );
endmodule

module MASKED_AND (
    input  [15:0] x,
    input         y,
    output [15:0] out
);
    assign out = {16{y}} & x;
endmodule

module MASKED_OR4 (
    input  [15:0] x0, x1, x2, x3,
    input         y0, y1, y2, y3,
    output [15:0] out
);
    wire [15:0] m0, m1, m2, m3;

    MASKED_AND u0 (.x(x0), .y(y0), .out(m0));
    MASKED_AND u1 (.x(x1), .y(y1), .out(m1));
    MASKED_AND u2 (.x(x2), .y(y2), .out(m2));
    MASKED_AND u3 (.x(x3), .y(y3), .out(m3));

    assign out = m0 | m1 | m2 | m3;
endmodule
module ROW_CTRL (
    input         spacing,
    input  [15:0] row_raw,
    output [15:0] row_active,
    output [25:0] padding_row
);
    assign row_active = spacing ? ~row_raw : row_raw;
    assign padding_row    = { {5{spacing}}, row_active, {5{spacing}} };
endmodule