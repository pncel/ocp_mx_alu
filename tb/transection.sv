//`ifndef TRANSECTION__SV
//`define TRANSECTION__SV
`include "scalar_includes.v"
`include "mxint8_includes.v"

`define FLOAT32_MANTISSA_MXINT8_WIDTH `MXINT8_ELEMENT_WIDTH-2
`define FLOAT32_MANTISSA_MXINT8_WIDTH_CUT `FLOAT32_MANTISSA_WIDTH-(`FLOAT32_MANTISSA_MXINT8_WIDTH)
typedef reg[`MXINT8_ELEMENT_WIDTH-1:0] t_mx_int8;
typedef reg[`SCALE_WIDTH-1:0] t_scalar;

module t_mx_int8_vector(
    output t_scalar scalar,
    output t_mx_int8 elements[0:`BLOCK_SIZE-1]);

    reg is_nan;
    reg [$clog2(`BLOCK_SIZE):0] zero_num;

    task post_randomize();
        zero_num = 0; 
        foreach (elements[i]) begin
          if (elements[i] == 0) begin
            zero_num++;
          end
        end
    endtask

    task randomize();
        scalar = $random() % 256;
        foreach(elements[i])
            elements[i] = $random() % 256;
        post_randomize();
    endtask

    function void set_zero(int elem_index);
        if(elements[elem_index] != 0) begin
            elements[elem_index] = 0;
            zero_num++;
        end
    endfunction

endmodule

module op_negate_int8;
    output wire [7:0] input_scalar;
    output wire [7:0] output_scalar;
    output wire [7:0] input_elements[0:31];
    output wire [7:0] output_elements[0:31];

    t_mx_int8_vector a(.scalar(input_scalar),.elements(input_elements));
    t_mx_int8_vector result(.scalar(output_scalar),.elements(output_elements));

endmodule

module t_fp32_scalar(output [`FLOAT32_WIDTH-1:0] f);
    reg sign;
    reg sub_normal;
    reg NaN; 
    reg [`FLOAT32_EXPONENT_WIDTH-1:0] scalar;
    reg carry; 
    reg[1:0] tie2even; //lsb: whether valid, MSB whether carry  
    reg overflow; //mantissa overflow, scalar carry
    reg scalar_overflow;
    reg [`FLOAT32_MANTISSA_MXINT8_WIDTH-1:0] mantissa_high; 
    reg [`FLOAT32_MANTISSA_MXINT8_WIDTH_CUT-2:0] mantissa_low;
    reg mantissa_low_msb;  
    assign f = {sign,scalar,mantissa_high,mantissa_low_msb,mantissa_low};
    initial begin
        set_clean();
        randomize();
    end
    function void set_clean();
        sign = 1'b0;
        sub_normal = 1'b0;
        NaN = 1'b0;
        carry = 1'b0;
        tie2even = 2'b00;
        overflow = 1'b0;
        scalar_overflow = 1'b0; 
    endfunction
    function [`FLOAT32_MANTISSA_MXINT8_WIDTH-1:0] random_high();
        return $urandom()%(1<<`FLOAT32_MANTISSA_MXINT8_WIDTH);
    endfunction
    function [`FLOAT32_MANTISSA_MXINT8_WIDTH_CUT-2:0] random_low();
        return $urandom()%(1<<(`FLOAT32_MANTISSA_MXINT8_WIDTH_CUT-1));
    endfunction
    function random_bit();
        return $urandom() % 2; 
    endfunction
    function void set_sign(input sign_i);
        sign = sign_i;
    endfunction
    function void set_carry(input c_i);//round causes carry, should't set tie2even = 01
        carry = c_i;
    endfunction
    function void set_overflow(input o_i);//carry causes mantissa overflow 
        overflow = o_i;
        carry = 1'b1; 
    endfunction
    function void set_NaN(input NaN_i);
        NaN = NaN_i; 
    endfunction
    function void set_tie2even();//0.5 whether carry or not// valid when carry == 1
        tie2even = {random_bit(),1'b1};
        carry = 1'b1;   
    endfunction
    function void set_scalar_overflow(input overflow_i);
        scalar_overflow = overflow_i;
        if(scalar_overflow) begin
            carry = 1'b1;
            overflow = 1'b1;
            NaN = 1'b0; 
        end
    endfunction
    function void randomize();
        if(sub_normal)
            scalar = `FLOAT32_EXPONENT_WIDTH'b0;
        else if(NaN)
            scalar = {`FLOAT32_EXPONENT_WIDTH{1'b1}};
        else
            scalar = $urandom() % (2<<`FLOAT32_EXPONENT_WIDTH-2) +1'b1;
        if(scalar_overflow)
            scalar = {`FLOAT32_EXPONENT_WIDTH{1'b1}}-1'b1;
        mantissa_high = random_high();
        mantissa_low = random_low();
        mantissa_low_msb = random_bit();
        if(carry) begin
            mantissa_low_msb = 1'b1;
            while(&mantissa_low)
                mantissa_low = random_low();
            if(tie2even[0]) begin
                mantissa_low_msb = 1'b1;
                mantissa_low = 0;
                mantissa_high[0] = tie2even[1]; 
            end
        end
        if(overflow)
            mantissa_high = (1<<`FLOAT32_MANTISSA_MXINT8_WIDTH) - 1; 
    endfunction
endmodule
//`endif 