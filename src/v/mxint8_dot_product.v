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
    output reg                                                  o_underflow,
    output reg                                                  o_is_unused,
    output reg                                                  o_is_NaN
);


    wire signed [`SCALE_WIDTH+4:0]   scale_sum;
    reg signed [31:0]               dot_product_sum;
    //reg        [31:0]               positive_sum_reg;
    reg        [31:0]               shifted_sum;
    // reg        [`SCALE_WIDTH-1:0]   scale_sum_clamped; 
    reg        [ 9:0]               scale_tmp;
    wire       [31:0]               positive_sum;
    // wire       [`SCALE_WIDTH+4:0]   scale_sum; 
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
    assign o_is_NaN = (i_scale_a == 8'b1111_1111 || i_scale_b == 8'b1111_1111);
    always @(*) begin //TODO: GenVar performance optimize
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
    assign scale_sum = (i_scale_a + i_scale_b - 127); //signed wire

    assign positive_sum = (dot_product_sum[31]) ? ~dot_product_sum + 1 : dot_product_sum;
    

    always @(*) begin
        
        o_overflow = 0;
        o_underflow = 0;
        shifted_sum = positive_sum;
        
        // pass over the sign from the resulting sum
        o_float32[`FLOAT32_SIGN_BIT] = dot_product_sum[31];

        if (o_is_NaN) begin // TODO: discuss change with Leo
            // if vector is NaN, then float32 is also NaN
            o_float32[`FLOAT32_MANTISSA_BITS] = 23'd1; // does this matter?
            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b1111_1111;
        end

        else if(positive_sum == 32'd0) begin
            //case for ZERO
            o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
        end
        else begin

                casez (positive_sum)
                    32'b0000_0000_0000_0000_0000_0000_0000_0001 : begin //bitcnt1
                        if (scale_sum - 6 > 0) begin
                            if (scale_sum - 6 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd6;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                        // o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                        // scale_tmp = scale_sum_clamped - 8'd6;
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_001? : begin //bitcnt2
                        if (scale_sum - 6 + 1 > 0) begin
                            if (scale_sum - 6 + 1 < 255) begin
                                // o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum_reg << 31;
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[0], 22'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd5;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_01?? : begin //bitcnt3
                        if (scale_sum - 6 + 2 > 0) begin
                            if (scale_sum - 6 + 2 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[1:0], 21'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd4;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0000_0000_1??? : begin
                        if (scale_sum - 6 + 3 > 0) begin
                            if (scale_sum - 6 + 3 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[2:0], 20'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd3;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0000_0001_???? : begin
                        if (scale_sum - 6 + 4 > 0) begin
                            if (scale_sum - 6 + 4 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[3:0], 19'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd2;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end 
                    32'b0000_0000_0000_0000_0000_0000_001?_???? : begin
                        if (scale_sum - 6 + 5 > 0) begin
                            if (scale_sum - 6 + 5 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[4:0], 18'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum - 8'd1;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0000_01??_???? : begin
                        if (scale_sum - 6 + 6 > 0) begin
                            if (scale_sum - 6 + 6 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[5:0], 17'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0000_1???_???? : begin
                        if (scale_sum - 6 + 7 > 0) begin
                            if (scale_sum - 6 + 7 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[6:0], 16'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd1;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_0001_????_???? : begin
                        if (scale_sum - 6 + 8 > 0) begin
                            if (scale_sum - 6 + 8 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[7:0], 15'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd2;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_001?_????_???? : begin
                        if (scale_sum - 6 + 9 > 0) begin
                            if (scale_sum - 6 + 9 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[8:0], 14'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd3;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_01??_????_???? : begin
                        if (scale_sum - 6 + 10 > 0) begin
                            if (scale_sum - 6 + 10 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[9:0], 13'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd4;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0000_1???_????_???? : begin
                        if (scale_sum - 6 + 11 > 0) begin
                            if (scale_sum - 6 + 11 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[10:0], 12'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd5;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_0001_????_????_???? : begin
                        if (scale_sum - 6 + 12 > 0) begin
                            if (scale_sum - 6 + 12 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[11:0], 11'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd6;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_001?_????_????_???? : begin
                        if (scale_sum - 6 + 13 > 0) begin
                            if (scale_sum - 6 + 13 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[12:0], 10'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd7;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end 
                    32'b0000_0000_0000_0000_01??_????_????_???? : begin
                        if (scale_sum - 6 + 14 > 0) begin
                            if (scale_sum - 6 + 14 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[13:0], 9'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd8;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0000_1???_????_????_???? : begin
                        if (scale_sum - 6 + 15 > 0) begin
                            if (scale_sum - 6 + 15 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[14:0], 8'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd9;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_0001_????_????_????_???? : begin
                        if (scale_sum - 6 + 16 > 0) begin
                            if (scale_sum - 6 + 16 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[15:0], 7'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd10;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_001?_????_????_????_???? : begin
                        if (scale_sum - 6 + 17 > 0) begin
                            if (scale_sum - 6 + 17 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[16:0], 6'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd11;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_01??_????_????_????_???? : begin
                        if (scale_sum - 6 + 18 > 0) begin
                            if (scale_sum - 6 + 18 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[17:0], 5'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd12;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0000_1???_????_????_????_???? : begin
                        if (scale_sum - 6 + 19 > 0) begin
                            if (scale_sum - 6 + 19 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[18:0], 4'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd13;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_0001_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 20 > 0) begin
                            if (scale_sum - 6 + 20 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[19:0], 3'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd14;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_001?_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 21 > 0) begin
                            if (scale_sum - 6 + 21 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[20:0], 2'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd15;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_01??_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 22 > 0) begin
                            if (scale_sum - 6 + 22 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[21:0], 1'b0};
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd16;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0000_1???_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 23 > 0) begin
                            if (scale_sum - 6 + 23 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[22:0];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd17;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_0001_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 24 > 0) begin
                            if (scale_sum - 6 + 24 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[23:1];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd18;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_001?_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 25 > 0) begin
                            if (scale_sum - 6 + 25 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[24:2];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd19;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_01??_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 26 > 0) begin
                            if (scale_sum - 6 + 26 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[25:3];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd20;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0000_1???_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 27 > 0) begin
                            if (scale_sum - 6 + 27 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[26:4];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd21;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b0001_????_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 27 > 0) begin
                            if (scale_sum - 6 + 27 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[27:5];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd22;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b001?_????_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 28 > 0) begin
                            if (scale_sum - 6 + 28 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[28:6];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd23;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b01??_????_????_????_????_????_????_???? : begin
                        if (scale_sum - 6 + 29 > 0) begin
                            if (scale_sum - 6 + 29 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[29:7];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd24;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                    32'b1???_????_????_????_????_????_????_???? : begin//
                        if (scale_sum - 6 + 30 > 0) begin
                            if (scale_sum - 6 + 30 < 255) begin
                                o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[30:8];
                                o_float32[`FLOAT32_EXPONENT_BITS] = scale_sum + 8'd25;
                            end
                            else begin
                                // overflow
                                o_float32[`FLOAT32_MANTISSA_BITS] = {`FLOAT32_MANTISSA_WIDTH{1'b1}};
                                o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                                o_overflow = 1;
                            end
                        end
                        else begin
                            // subnormal and underflow cases
                            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                            if ((31 + scale_sum - 6) < 0) shifted_sum = (positive_sum[31:9]) >> (-1 * (31 + scale_sum - 6));
                            else if ((31 + scale_sum - 6) > 0) shifted_sum = positive_sum << (31 + scale_sum - 6);
                            o_float32[`FLOAT32_MANTISSA_BITS] = shifted_sum[31:9];
                            if (shifted_sum[31:9] == 23'b0) o_underflow = 1;
                            
                        end 
                    end
                endcase 
                // o_overflow = o_is_NaN ? 1'b0 : (scale_tmp > 8'b11111110);
                // if(o_overflow)begin
                //     o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                //     o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111110;
                // end
                // else begin
                //     o_float32[`FLOAT32_EXPONENT_BITS] = scale_tmp;
                // end
            //end
        end
    end

endmodule
