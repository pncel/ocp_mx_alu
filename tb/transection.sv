//`ifndef TRANSECTION__SV
//`define TRANSECTION__SV
`include "scalar_includes.v"
`include "mxint8_includes.v"

`define FLOAT32_MANTISSA_MXINT8_WIDTH `MXINT8_ELEMENT_WIDTH-2
`define FLOAT32_MANTISSA_MXINT8_WIDTH_CUT `FLOAT32_MANTISSA_WIDTH-(`FLOAT32_MANTISSA_MXINT8_WIDTH)
typedef reg[`MXINT8_ELEMENT_WIDTH-1:0] t_mx_int8;
typedef reg[`SCALE_WIDTH-1:0] t_scale;

module t_mx_int8_vector(
    output t_scale scale,
    output t_mx_int8 elements[0:`BLOCK_SIZE-1]);
    localparam unused_code = 8'b1000_0000;
    localparam largest_scale = 8'b1111_1111;
    localparam zero_scale = 8'b0000_0000;
    reg is_nan;
    reg [$clog2(`BLOCK_SIZE):0] zero_num;

    function void post_randomize();
        zero_num = 0; 
        foreach (elements[i]) begin
          if (elements[i] == 0) begin
            zero_num++;
          end
        end
    endfunction

    function void randomize();
        scale = $random() % 256;
        foreach(elements[i])
            elements[i] = $random() % 256;
        post_randomize();
    endfunction

    function void set_all_positive();
        foreach(elements[i])
            elements[i][`MXINT8_ELEMENT_WIDTH-1] = 1'b0;
    endfunction

    function void set_all_negative();
        foreach(elements[i])
            elements[i][`MXINT8_ELEMENT_WIDTH-1] = 1'b1;
    endfunction

    function void set_positive_element(int index);
            elements[index][`MXINT8_ELEMENT_WIDTH-1] = 1'b0;
    endfunction

    function void set_negative_element(int index);
            elements[index][`MXINT8_ELEMENT_WIDTH-1] = 1'b1;
    endfunction

    function void set_all_small_elements();
        foreach(elements[i]) begin
            if(elements[i][`MXINT8_ELEMENT_WIDTH-1])
                elements[i][`MXINT8_ELEMENT_WIDTH-2] = 1'b1;
            else
                elements[i][`MXINT8_ELEMENT_WIDTH-2] = 1'b0;
        end
    endfunction

    function void set_all_big_elements();
        foreach(elements[i]) begin
            if(elements[i][`MXINT8_ELEMENT_WIDTH-1])
                elements[i][`MXINT8_ELEMENT_WIDTH-2] = 1'b0;
            else
                elements[i][`MXINT8_ELEMENT_WIDTH-2] = 1'b1;
        end
    endfunction

    function void set_big_element(int index);
        if(elements[index][`MXINT8_ELEMENT_WIDTH-1])
            elements[index][`MXINT8_ELEMENT_WIDTH-2] = 1'b0;
        else
            elements[index][`MXINT8_ELEMENT_WIDTH-2] = 1'b1;
    endfunction

    function void set_big_positive(int index);
        set_positive_element(index);
        set_big_element(index);
    endfunction

    function void set_big_negative(int index);
        set_negative_element(index);
        set_big_element(index);
    endfunction

    function void set_zero(int elem_index);
        if(elements[elem_index] != 0) begin
            elements[elem_index] = 0;
            zero_num++;
        end
    endfunction
    
    function void set_all_zero();
        foreach(elements[i])
            elements[i] = `MXINT8_ELEMENT_WIDTH'd0;
    endfunction

    function void set_unused_encode(int elem_index);
        elements[elem_index] = unused_code;
    endfunction

    function void set_all_unused_code();
        foreach(elements[i])
            elements[i] = unused_code;
    endfunction

    function void set_zero_scale();
        scale = zero_scale;
    endfunction

    function void set_largest_scale();
        scale = largest_scale;
    endfunction

    function void set_sum_positive_carry(int big_positive_num, int is_small_scale);
        set_largest_scale();
        scale -= is_small_scale;
        set_all_small_elements();
        for(int i = 0; i < big_positive_num; i = i + 1)
            set_big_positive(i);
    endfunction

    function void set_sum_negative_carry(int big_negative_num, int is_small_scale);
        set_largest_scale();
        scale -= is_small_scale;
        set_all_small_elements();
        for(int i = 0; i < big_negative_num; i = i + 1)
            set_big_negative(i);
    endfunction
endmodule

module op_negate_int8;
    output wire [7:0] input_scale;
    output wire [7:0] output_scale;
    output wire [7:0] input_elements[0:31];
    output wire [7:0] output_elements[0:31];

    t_mx_int8_vector a(.scale(input_scale),.elements(input_elements));
    t_mx_int8_vector result(.scale(output_scale),.elements(output_elements));

endmodule

module t_fp32_scale(output [`FLOAT32_WIDTH-1:0] f);
    reg sign;
    reg sub_normal;
    reg NaN; 
    reg [`FLOAT32_EXPONENT_WIDTH-1:0] scale;
    reg carry; 
    reg[1:0] tie2even; //lsb: whether valid, MSB whether carry  
    reg overflow; //mantissa overflow, scale carry
    reg scale_overflow;
    reg [`FLOAT32_MANTISSA_MXINT8_WIDTH-1:0] mantissa_high; 
    reg [`FLOAT32_MANTISSA_MXINT8_WIDTH_CUT-2:0] mantissa_low;
    reg mantissa_low_msb;  
    assign f = {sign,scale,mantissa_high,mantissa_low_msb,mantissa_low};
    initial begin
        set_clean();
        randomize();
    end
    function void set_zero();
        {mantissa_high,mantissa_low_msb,mantissa_low} = `FLOAT32_MANTISSA_WIDTH'd0;
    endfunction
    function void set_clean();
        sign = 1'b0;
        sub_normal = 1'b0;
        NaN = 1'b0;
        carry = 1'b0;
        tie2even = 2'b00;
        overflow = 1'b0;
        scale_overflow = 1'b0; 
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
    function void set_scale_overflow(input overflow_i);
        scale_overflow = overflow_i;
        if(scale_overflow) begin
            carry = 1'b1;
            overflow = 1'b1;
            NaN = 1'b0; 
        end
    endfunction
    function void randomize();
        if(sub_normal)
            scale = `FLOAT32_EXPONENT_WIDTH'b0;
        else if(NaN)
            scale = {`FLOAT32_EXPONENT_WIDTH{1'b1}};
        else
            scale = $urandom() % (2<<`FLOAT32_EXPONENT_WIDTH-2) +1'b1;
        if(scale_overflow)
            scale = {`FLOAT32_EXPONENT_WIDTH{1'b1}}-1'b1;
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