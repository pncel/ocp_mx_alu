
module mxint8_sum (
    i_scale,
    i_mxint8_elements,
    o_float32,
    o_overflow
);

    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    input  wire [`SCALE_WIDTH-1:0]            i_scale;
    input  wire [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [`BLOCK_SIZE-1:0];
    output reg [`FLOAT32_WIDTH-1:0]          o_float32;
    output reg                               o_overflow;
    
    wire [31:0] positive_sum;
    reg [31:0] mxint8_elements_sum;//, positive_sum;
    reg is_NaN;

    // sum up all sign extended MXINT8 elements
    integer i;
    always @(*) begin
        mxint8_elements_sum = '0;
        for (i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            mxint8_elements_sum = mxint8_elements_sum + { {(31-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements[i][`MXINT8_ELEMENT_WIDTH-1]}}, i_mxint8_elements[i][`MXINT8_ELEMENT_WIDTH-2:0] } ;
        end
    end

    // need to turn sum into positive 2's complement value because float32 has positive mantissa
    // MSB is sign bit because sign extension from previous step
    assign positive_sum = mxint8_elements_sum[31] ? ~mxint8_elements_sum + 1 : mxint8_elements_sum;

    // normalize the positive sum of all elements by finding leading 1
    always @(*) begin
        // pass over the sign from the resulting sum
        o_float32[`FLOAT32_SIGN_BIT] = mxint8_elements_sum[31];

        if (i_scale == 8'b11111111) begin
            // if vector is NaN, then float32 is also NaN
            o_float32[`FLOAT32_MANTISSA_BITS] = 23'd1;
            o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111111;
            is_NaN = 1'b1;
        end
        else begin
            unique casez (positive_sum)
                32'b0000_0000_0000_0000_0000_0000_0000_0000 : begin
                    // o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                    // o_float32[`FLOAT32_EXPONENT_BITS] = 8'b0;
                    o_float32[30:0] = {23'b0, 8'b0};
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_0000_0001 : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd6;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_0000_001? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[0], 22'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd5;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_0000_01?? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[1:0], 21'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd4;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_0000_1??? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[2:0], 20'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd3;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_0001_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[3:0], 19'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd2;
                    is_NaN = 1'b0;
                end 
                32'b0000_0000_0000_0000_0000_0000_001?_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[4:0], 18'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale - 8'd1;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_01??_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[5:0], 17'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0000_1???_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[6:0], 16'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd1;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_0001_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[7:0], 15'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd2;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_001?_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[8:0], 14'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd3;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_01??_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[9:0], 13'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd4;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0000_1???_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[10:0], 12'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd5;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_0001_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[11:0], 11'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd6;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_001?_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[12:0], 10'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd7;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_01??_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[13:0], 9'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd8;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0000_1???_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[14:0], 8'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd9;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_0001_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[15:0], 7'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd10;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_001?_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[16:0], 6'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd11;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_01??_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[17:0], 5'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd12;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0000_1???_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[18:0], 4'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd13;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_0001_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[19:0], 3'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd14;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_001?_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[20:0], 2'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd15;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_01??_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = {positive_sum[21:0], 1'b0};
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd16;
                    is_NaN = 1'b0;
                end
                32'b0000_0000_1???_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[22:0];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd17;
                    is_NaN = 1'b0;
                end
                32'b0000_0001_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[23:1];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd18;
                    is_NaN = 1'b0;
                end
                32'b0000_001?_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[24:2];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd19;
                    is_NaN = 1'b0;
                end
                32'b0000_01??_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[25:3];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd20;
                    is_NaN = 1'b0;
                end
                32'b0000_1???_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[26:4];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd17;
                    is_NaN = 1'b0;
                end
                32'b0001_????_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[27:5];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd18;
                    is_NaN = 1'b0;
                end
                32'b001?_????_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[28:6];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd19;
                    is_NaN = 1'b0;
                end
                32'b01??_????_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = positive_sum[29:7];
                    o_float32[`FLOAT32_EXPONENT_BITS] = i_scale + 8'd20;
                    is_NaN = 1'b0;
                end
                32'b1???_????_????_????_????_????_????_???? : begin
                    o_float32[`FLOAT32_MANTISSA_BITS] = 23'b0;
                    o_float32[`FLOAT32_EXPONENT_BITS] = 8'b11111111;
                    is_NaN = 1'b1;
                end
            endcase 
        end
    end

    // calculate overflow flag based on output exponent to float32
    // if either msb of fp32 exponent or msb of scale is different then overflow has occurred
    // except when fp32 is NaN
    assign o_overflow = is_NaN ? 1'b0 : o_float32[`FLOAT32_EXPONENT_MSB] ^ i_scale[`SCALE_WIDTH-1];

endmodule