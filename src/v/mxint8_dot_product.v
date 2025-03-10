`include "scalar_includes.v"
`include "mxint8_includes.v"
`include "mx_general_includes.v"

module mxint8_dot_product (
    input  wire [`SCALE_WIDTH-1:0]                              i_scale_a,
    input  wire [`SCALE_WIDTH-1:0]                              i_scale_b,
    input  wire [`BLOCK_SIZE-1:0][`MXINT8_ELEMENT_WIDTH-1:0]    i_mxint8_elements_a ,
    input  wire [`BLOCK_SIZE-1:0][`MXINT8_ELEMENT_WIDTH-1:0]    i_mxint8_elements_b,
    output reg  [`FLOAT32_WIDTH-1:0]                            o_float32,
    output reg                                                  o_overflow,
    output reg                                                  o_is_unused,
    output reg                                                  o_is_NaN
);



    reg signed [31:0]               dot_product_sum;
    reg        [31:0]               positive_sum_reg;
    reg        [`SCALE_WIDTH-1:0]   scale_sum_clamped; 
    reg        [ 9:0]               scale_tmp;
    wire       [31:0]               positive_sum;
    wire       [`SCALE_WIDTH+4:0]   scale_sum; 
    wire       [`BLOCK_SIZE-1:0]    is_unused_vec_a; 
    wire       [`BLOCK_SIZE-1:0]    is_unused_vec_b; 

    genvar kk;
    generate
        for (kk = 0; kk < `BLOCK_SIZE; kk = kk+1) begin
            assign is_unused_vec_a[kk] = (i_mxint8_elements_a[kk] == 8'b1000_0000);
            assign is_unused_vec_b[kk] = (i_mxint8_elements_b[kk] == 8'b1000_0000);
        end
    endgenerate
    assign o_is_unused = (|is_unused_vec_a) | (|is_unused_vec_b);

    always @(*) begin
        dot_product_sum =
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[31][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[31][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[31][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[31][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[30][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[30][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[30][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[30][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[29][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[29][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[29][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[29][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[28][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[28][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[28][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[28][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[27][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[27][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[27][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[27][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[26][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[26][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[26][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[26][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[25][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[25][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[25][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[25][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[24][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[24][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[24][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[24][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[23][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[23][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[23][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[23][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[22][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[22][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[22][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[22][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[21][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[21][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[21][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[21][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[20][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[20][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[20][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[20][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[19][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[19][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[19][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[19][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[18][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[18][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[18][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[18][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[17][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[17][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[17][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[17][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[16][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[16][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[16][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[16][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[15][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[15][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[15][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[15][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[14][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[14][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[14][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[14][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[13][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[13][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[13][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[13][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[12][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[12][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[12][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[12][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[11][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[11][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[11][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[11][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[10][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[10][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[10][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[10][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 9][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 9][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 9][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 9][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 8][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 8][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 8][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 8][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 7][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 7][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 7][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 7][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 6][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 6][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 6][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 6][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 5][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 5][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 5][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 5][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 4][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 4][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 4][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 4][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 3][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 3][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 3][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 3][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 2][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 2][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 2][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 2][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 1][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 1][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 1][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 1][`MXINT8_ELEMENT_WIDTH-1:0] })+
            ({ {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[ 0][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_a[ 0][`MXINT8_ELEMENT_WIDTH-1:0] } * 
             { {(32-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[ 0][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements_b[ 0][`MXINT8_ELEMENT_WIDTH-1:0] });
 
    end
  
    // wire [31:0] scaled_dot_product;
    assign scale_sum = i_scale_a + i_scale_b;

    assign positive_sum = (dot_product_sum[31]) ? ~dot_product_sum + 1 : dot_product_sum;
    

    always @(*) begin
        //============================================================================
        // if scale_sum is larger than 1111_1111 bits, clamp it and shift positive_sum 
        //============================================================================
        if(scale_sum > 8'b1111_1111) begin
            scale_sum_clamped     = 8'b1111_1111;
        end
        else begin
            scale_sum_clamped     = scale_sum;
        end
        positive_sum_reg    = positive_sum << (scale_sum - scale_sum_clamped);
        //============================================================================
        
        // pass over the sign from the resulting sum
        o_float32[`FLOAT32_SIGN_BIT] = dot_product_sum[31];


        if (scale_sum_clamped == 8'b1111_1111) begin
            // if vector is NaN, then float32 is also NaN
            o_float32[`FLOAT32_MANTISSA_BITS] = 23'd1;
            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b1111_1111;
            o_is_NaN = 1'b1;
        end
        else if(positive_sum_reg == 32'd0) begin
            //case for zero
            o_float32[30:0] = {23'b0, 8'b0};
            o_is_NaN = 1'b0;
        end
        else begin
            //subnormal case for FP32
            //min for normal case of FP32 is 2^-126 so positive_sum would be subnormal 
            //if positive_sum_reg << scale_sum_clamped-6-127 < 2^-126
            if(((positive_sum_reg << scale_sum_clamped) < 8'd128) && (scale_sum_clamped < 8)) begin
                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b00000000; 
                unique casez (scale_sum_clamped)
                    8'b00000110 : begin //i_scale = 6
                        //the exponent will be 0. 
                        //we shift MANTISSA_BITS right for 1 bit. which is 23-1=22
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 22;
                    end
                    8'b00000101 : begin //i_scale = 5
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 21;
                    end
                    8'b00000100 : begin //i_scale = 4
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 20;
                    end
                    8'b00000011 : begin //i_scale = 3
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 19;
                    end
                    8'b00000010 : begin //i_scale = 2
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 18;
                    end
                    8'b00000001 : begin //i_scale = 1
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 17;
                    end
                    8'b00000000 : begin //i_scale = 0
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 16;
                    end
                endcase
            end
            //normal case for FP32
            else begin
                casez (positive_sum_reg)
                    32'b0000_0000_0000_0000_0000_0000_0000_0001 : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                        scale_tmp = scale_sum_clamped - 8'd6;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_001? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[0], 22'b0};
                        scale_tmp = scale_sum_clamped - 8'd5;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_01?? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[1:0], 21'b0};
                        scale_tmp = scale_sum_clamped - 8'd4;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_1??? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[2:0], 20'b0};
                        scale_tmp = scale_sum_clamped - 8'd3;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_0001_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[3:0], 19'b0};
                        scale_tmp = scale_sum_clamped - 8'd2;
                        o_is_NaN = 1'b0;
                    end 
                    32'b0000_0000_0000_0000_0000_0000_001?_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[4:0], 18'b0};
                        scale_tmp = scale_sum_clamped - 8'd1;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_01??_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[5:0], 17'b0};
                        scale_tmp = scale_sum_clamped;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0000_1???_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[6:0], 16'b0};
                        scale_tmp = scale_sum_clamped + 8'd1;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_0001_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[7:0], 15'b0};
                        scale_tmp = scale_sum_clamped + 8'd2;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_001?_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[8:0], 14'b0};
                        scale_tmp = scale_sum_clamped + 8'd3;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_01??_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[9:0], 13'b0};
                        scale_tmp = scale_sum_clamped + 8'd4;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0000_1???_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[10:0], 12'b0};
                        scale_tmp = scale_sum_clamped + 8'd5;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_0001_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[11:0], 11'b0};
                        scale_tmp = scale_sum_clamped + 8'd6;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_001?_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[12:0], 10'b0};
                        scale_tmp = scale_sum_clamped + 8'd7;
                        o_is_NaN = 1'b0;
                    end 
                    32'b0000_0000_0000_0000_01??_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[13:0], 9'b0};
                        scale_tmp = scale_sum_clamped + 8'd8;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0000_1???_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[14:0], 8'b0};
                        scale_tmp = scale_sum_clamped + 8'd9;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_0001_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[15:0], 7'b0};
                        scale_tmp = scale_sum_clamped + 8'd10;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_001?_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[16:0], 6'b0};
                        scale_tmp = scale_sum_clamped + 8'd11;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_01??_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[17:0], 5'b0};
                        scale_tmp = scale_sum_clamped + 8'd12;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0000_1???_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[18:0], 4'b0};
                        scale_tmp = scale_sum_clamped + 8'd13;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_0001_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[19:0], 3'b0};
                        scale_tmp = scale_sum_clamped + 8'd14;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_001?_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[20:0], 2'b0};
                        scale_tmp = scale_sum_clamped + 8'd15;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_01??_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum_reg[21:0], 1'b0};
                        scale_tmp = scale_sum_clamped + 8'd16;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0000_1???_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[22:0];
                        scale_tmp = scale_sum_clamped + 8'd17;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_0001_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[23:1];
                        scale_tmp = scale_sum_clamped + 8'd18;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_001?_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[24:2];
                        scale_tmp = scale_sum_clamped + 8'd19;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_01??_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[25:3];
                        scale_tmp = scale_sum_clamped + 8'd20;
                        o_is_NaN = 1'b0;
                    end
                    32'b0000_1???_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[26:4];
                        scale_tmp = scale_sum_clamped + 8'd17;
                        o_is_NaN = 1'b0;
                    end
                    32'b0001_????_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[27:5];
                        scale_tmp = scale_sum_clamped + 8'd18;
                        o_is_NaN = 1'b0;
                    end
                    32'b001?_????_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[28:6];
                        scale_tmp = scale_sum_clamped + 8'd19;
                        o_is_NaN = 1'b0;
                    end
                    32'b01??_????_????_????_????_????_????_???? : begin
                        o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg[29:7];
                        scale_tmp = scale_sum_clamped + 8'd20;
                        o_is_NaN = 1'b0;
                    end
                    32'b1???_????_????_????_????_????_????_???? : begin//
                        o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                        scale_tmp = 8'b11111111;
                        o_is_NaN = 1'b1;
                    end
                endcase 
                o_overflow = o_is_NaN ? 1'b0 : (scale_tmp > 8'b11111110);
                if(o_overflow)begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                    o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111111;
                end
                else begin
                    o_float32[`FLOAT32_EXPONENT_BITS] = scale_tmp;
                end
            end
        end
    end

endmodule
