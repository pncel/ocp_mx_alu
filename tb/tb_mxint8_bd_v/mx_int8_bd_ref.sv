module mx_int8_bd_ref (
    i_float32,
    o_scale,
    o_mxint8_elements,
    o_overflow
);

    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    input  wire [`FLOAT32_WIDTH-1:0]         i_float32;
    output reg  [`SCALE_WIDTH-1:0]           o_scale;
    output reg  [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements [`BLOCK_SIZE-1:0];
    output reg                               o_overflow;

    wire [`FLOAT32_MANTISSA_WIDTH-1:0]   fp32_mantissa;
    wire [1+`FLOAT32_MANTISSA_WIDTH-1:0] fp32_m;
    wire fp32_sign;
    wire [`FLOAT32_EXPONENT_WIDTH-1:0]   fp32_scalar;

    assign fp32_sign = i_float32[`FLOAT32_SIGN_BIT];
    assign fp32_scalar = i_float32[`FLOAT32_EXPONENT_BITS];
    assign fp32_mantissa = i_float32[`FLOAT32_MANTISSA_BITS];
    assign fp32_m = (fp32_scalar == `FLOAT32_EXPONENT_WIDTH'd0) ? 
                    {1'b0,fp32_mantissa} : {1'b1,fp32_mantissa};


    wire [`MXINT8_ELEMENT_WIDTH-1:0]     fp_m_high;//{0,LSB 7 bit fp32_m}
    wire [1+`FLOAT32_MANTISSA_WIDTH-`MXINT8_ELEMENT_WIDTH+1-1:0] fp_m_low; 
    reg [`MXINT8_ELEMENT_WIDTH-1:0]     fp_round; 
    reg carry; 
    wire larger; 
    assign larger = ^fp_m_low[`FLOAT32_MANTISSA_WIDTH-`MXINT8_ELEMENT_WIDTH:0];
    
    assign fp_m_high ={1'b0, fp32_m[`FLOAT32_MANTISSA_WIDTH:`FLOAT32_MANTISSA_WIDTH-(`MXINT8_ELEMENT_WIDTH-1)+1]};
    assign fp_m_low = fp32_m[`FLOAT32_MANTISSA_WIDTH-(`MXINT8_ELEMENT_WIDTH-1):0];
    always@(*) begin
        carry <= carry_logic(fp_m_high[0],larger,fp_m_low[`FLOAT32_MANTISSA_WIDTH-(`MXINT8_ELEMENT_WIDTH-1)]);
    end
    always@(*) begin
        fp_round <= carry + fp_m_high;
    end

    wire overflow;
    assign overflow = fp_round[`MXINT8_ELEMENT_WIDTH-1];
    assign o_overflow = overflow&&(&fp32_scalar[`FLOAT32_EXPONENT_WIDTH-1:1])&&(!fp32_scalar[0])? 1'b1: 1'b0; 
    assign o_scale =  (&fp32_scalar)? fp32_scalar :(overflow? fp32_scalar+1'b1 : fp32_scalar);

    wire [`MXINT8_ELEMENT_WIDTH-1:0]     fp_round_unsigned;
    assign fp_round_unsigned = overflow? {1'b0,fp_round[`MXINT8_ELEMENT_WIDTH-1:1]}:{1'b0,fp_round[`MXINT8_ELEMENT_WIDTH-2:0]};

    reg [`MXINT8_ELEMENT_WIDTH-1:0]fp_round_signed;
    always@(*) begin
        fp_round_signed <= sign_conv(fp32_sign,fp_round_unsigned);
    end
    genvar i;
    generate
        for(i=0;i<`BLOCK_SIZE;i=i+1)
            assign o_mxint8_elements[i] = fp_round_signed;
    endgenerate


    function [`MXINT8_ELEMENT_WIDTH-1:0] sign_conv(input sign_bit, input[`MXINT8_ELEMENT_WIDTH-1:0] unsigned_int);
        if(!sign_bit)
            return unsigned_int;
        else
            return (~unsigned_int) + 1'b1; 
    endfunction

    function carry_logic(input high_lsb,
                     input larger,
                     input low_msb);
        if(!low_msb) 
            return 1'b0;
        else if(larger)
            return 1'b1;
        else 
            return high_lsb;
    endfunction 
endmodule
    