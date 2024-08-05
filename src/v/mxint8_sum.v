
module mxint8_sum (
    i_scale,
    i_mxint8_elements,
    o_float32
);

    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    input  reg [SCALE_WIDTH-1:0]            i_scale;
    input  reg [MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [BLOCK_SIZE-1:0];
    output reg [FLOAT32_WIDTH-1:0]          o_float32;

    // TODO adjust this to consider overflow
    // right now assume there is no overflow
    reg [MXINT8_ELEMENT_WIDTH-1:0] mxint8_elements_sum, normalized_sum;

    // sum up all MXINT8 elements
    integer i;
    always @(*) begin
        mxint8_elements_sum = '0;
        for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
            mxint8_elements_sum = mxint8_elements_sum + i_mxint8_elements[i];
        end
    end

    // need to turn sum into positive 2's complement value because float32 has positive mantissa
    assign normalized_sum = mxint8_elements_sum[`MXINT8_ELEMENT_SIGN_BIT] ? ~mxint8_elements_sum + 1 : mxint8_elements_sum;

    assign o_float32[`FLOAT32_SIGN_BIT] = mxint8_elements_sum[`MXINT8_ELEMENT_SIGN_BIT];
    assign o_float32[`FLOAT32_EXPONENT_BITS] = i_scale;
    assign o_float32[`FLOAT32_MANTISSA_BITS] = {normalized_sum[MXINT8_ELEMENT_WIDTH-2:0], (FLOAT32_MANTISSA_WIDTH-6){1'b0}};

endmodule