
module mxint8_broadcast (
    i_float32,
    o_scale,
    o_mxint8_elements
);

    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    input  wire [FLOAT32_WIDTH-1:0]         i_float32;
    output reg  [SCALE_WIDTH-1:0]           o_scale;
    output reg  [MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements [BLOCK_SIZE-1:0];

    reg [FLOAT32_MANTISSA_WIDTH:0] extended_mantissa;

    // extract mantissa from input float32
    // adjust with the sign because mantissa is unsigned in float32 but signed in mxint8
    assign extended_mantissa = i_float32[`FLOAT32_SIGN_BIT] ? ~{1'b1, i_float32[`FLOAT32_MANTISSA_BITS]} + 1 : {1'b1, i_float32[`FLOAT32_MANTISSA_BITS]};

    // shared scale is exact same as the biased exponent of float32
    assign o_scale = i_float32[`FLOAT32_EXPONENT_BITS];

    // convert the mantissa to the mxint8
    generate 
        genvar i;
        for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
            always @(*) begin
                o_mxint8_elements[i] = extended_mantissa[FLOAT32_MANTISSA_WIDTH:FLOAT32_MANTISSA_WIDTH-7];
            end
        end
    endgenerate

endmodule 