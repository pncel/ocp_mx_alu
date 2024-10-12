
module mxint8_broadcast (
    i_float32,
    o_scale,
    o_mxint8_elements
);

    // TODO support subnormal numbers

    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    input  wire [`FLOAT32_WIDTH-1:0]         i_float32;
    output reg  [`SCALE_WIDTH-1:0]           o_scale;
    output reg  [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements [`BLOCK_SIZE-1:0];

    reg [`FLOAT32_MANTISSA_WIDTH-1:0] rounded_mantissa;
    reg [`FLOAT32_MANTISSA_WIDTH+1:0] extended_mantissa;
    reg [`FLOAT32_MANTISSA_WIDTH-1:0] clamped_rounded_mantissa;
    reg [`SCALE_WIDTH-1:0]            temp_scale;
    reg                               rounded_mantissa_overflow;

    // extract mantissa from input float32
    // apply round to nearest even
    always @(*) begin
        if (i_float32[`FLOAT32_MANTISSA_MXINT8_LSB-1]) begin
            if (|(i_float32[`FLOAT32_MANTISSA_MXINT8_LSB-2:0])) begin
                // > 0.5
                if (i_float32[`FLOAT32_MANTISSA_MXINT8_BITS] == 6'b11_1111) begin
                    rounded_mantissa = 23'd0;
                    rounded_mantissa_overflow = 1'b1;
                end
                else begin
                    rounded_mantissa = {i_float32[`FLOAT32_MANTISSA_MXINT8_BITS] + 6'd1, 17'b0};
                    rounded_mantissa_overflow = 1'b0;
                end
            end
            else begin
                // = 0.5
                if (i_float32[`FLOAT32_MANTISSA_MXINT8_LSB]) begin
                    // odd so round up
                    if (i_float32[`FLOAT32_MANTISSA_MXINT8_BITS] == 6'b11_1111) begin
                        rounded_mantissa = 23'd0;
                        rounded_mantissa_overflow = 1'b1;
                    end
                    else begin
                        rounded_mantissa = {i_float32[`FLOAT32_MANTISSA_MXINT8_BITS] + 6'd1, 17'b0};
                        rounded_mantissa_overflow = 1'b0;
                    end
                end
                else begin
                    // even so round down
                    rounded_mantissa = {i_float32[`FLOAT32_MANTISSA_MXINT8_BITS], 17'b0};
                    rounded_mantissa_overflow = 1'b0;
                end
            end
        end
        else begin
            // < 0.5
            rounded_mantissa = {i_float32[`FLOAT32_MANTISSA_MXINT8_BITS], 17'b0};
            rounded_mantissa_overflow = 1'b0;
        end
    end

    // shared scale is exact same as the biased exponent of float32
    // pass right through
    // if all 1's then NaN or Inf which matches with MX standard for NaN

    // if scale overflow due to rounding from the beginning, then clamp value to highest possible MXINT8 value
    // there is no output overflow flag because of clamping
    always @(*) begin
        if (i_float32[`FLOAT32_EXPONENT_BITS] == 8'b1111_1111) begin
            o_scale = i_float32[`FLOAT32_EXPONENT_BITS];
            clamped_rounded_mantissa = rounded_mantissa; // don't really care about mantissa here because it is all NaN anyway
        end
        else begin
            if (rounded_mantissa_overflow) begin
                if ((i_float32[`FLOAT32_EXPONENT_BITS] + 8'd1) == 8'b1111_1111) begin
                    // o_scale = i_float32[`FLOAT32_EXPONENT_BITS];
                    o_scale = 8'b1111_1110;
                    clamped_rounded_mantissa = 6'b11_1111;
                end
                else begin
                    o_scale = i_float32[`FLOAT32_EXPONENT_BITS] + 8'd1;
                    clamped_rounded_mantissa = rounded_mantissa;
                end
            end
            else begin
                o_scale = i_float32[`FLOAT32_EXPONENT_BITS];
                clamped_rounded_mantissa = rounded_mantissa;
            end
        end
    end

    // adjust with the sign because mantissa is unsigned in float32 but signed in mxint8
    assign extended_mantissa = i_float32[`FLOAT32_SIGN_BIT] ? ~{2'b01, clamped_rounded_mantissa} + 1 : {2'b01, clamped_rounded_mantissa};

    // convert the mantissa to the mxint8
    // effectively only take 6 MSB of original mantissa because clamping and avoid needs to round
    generate 
        genvar i;
        for (i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            always @(*) begin
                o_mxint8_elements[i] = extended_mantissa[`FLOAT32_MANTISSA_WIDTH+1:`FLOAT32_MANTISSA_MXINT8_LSB];
            end
        end
    endgenerate

endmodule 