
`ifndef MX_FUNCTION_PKG
`define MX_FUNCTION_PKG

package mx_function_pkg;

    import scalar_format_pkg::*;
    import mx_format_pkg::*;

    function automatic logic [7:0] f_int8_find_largest_value (t_mxfp8_e5m2_vector vector);

    endfunction

    function automatic logic fp32_RNE(
        input t_float32 fl32_i
    );
        if(fl32_i.mantissa[FLOAT32_MANTISSA_WIDTH-1]) begin
            if(!(|fl32_i.mantissa[FLOAT32_MANTISSA_WIDTH-2:0]) begin
                return fl32_i.exponent[0];
            end
            else begin
                return 1'b1;
            end
        end
        else begin
            return 1'b0;
        end
    endfunction

    function automatic t_bfloat16 fp32_RNE_bf16(
        input t_float32 fl32_i
    );
        logic[BFLOAT16_MANTISSA_WIDTH:0] tmp;
        tmp = fl32_i.mantissa[FLOAT32_MANTISSA_WIDTH-1 -: BFLOAT16_MANTISSA_WIDTH] + fp32_RNE(fl32_i);
        //mantissa carry-on effects exponent part changing 
        if(tmp[BFLOAT16_MANTISSA_WIDTH]) begin
            fp32_RNE_bf16.mantissa = tmp[BFLOAT16_MANTISSA_WIDTH:1];
            if(&fl32_i.exponent) begin//NaN condition fp32 conversion: exponent == 1111_1111 (overflow)!
                fp32_RNE_bf16.exponent = fl32_i.exponent;
                fp32_RNE_bf16.mantissa = tmp[BFLOAT16_MANTISSA_WIDTH:1];
            end
            else if(!(|fl32_i.exponent)) begin //sub-normal conversion: mantissa 
                fp32_RNE_bf16.exponent = fl32_i.exponent + 1'b1;
                fp32_RNE_bf16.mantissa = tmp[BFLOAT16_MANTISSA_WIDTH-1:0];
            end
            else begin
                fp32_RNE_bf16.exponent = fl32_i.exponent + 1'b1;
                fp32_RNE_bf16.mantissa = tmp[BFLOAT16_MANTISSA_WIDTH:1];               
            end
        end
        else begin
            fp32_RNE_bf16.mantissa = tmp[BFLOAT16_EXPONENT_WIDTH-1:0];
            fp32_RNE_bf16.exponent = fl32_i.exponent; 
        end
        fp32_RNE_bf16.sign = fl32_i.sign;
    endfunction

    function automatic bit E8_NaN(t_mx_scale_data exp_i);
        return (&exp_i)? 1'b1, 1'b0;
    endfunction

    function automatic logic bf16_RNE(
        input  bf16_i
    );
        if(bf16_i.mantissa[FLOAT32_MANTISSA_WIDTH-1]) begin
            if(!(|bf16_i.mantissa[FLOAT32_MANTISSA_WIDTH-2:0]) begin
                return bf16_i.exponent[0];
            end
            else begin
                return 1'b1;
            end
        end
        else begin
            return 1'b0;
        end
    endfunction

    //output format {mx_e8, mx_int8}
    function automatic logic[15:0] bf16_RNE_int8(input t_bfloat16 bf16_i);
        logic [7:0] tmp; //mx_int8
        logic [7:0] rne;
        logic [6:0] carry_on; 
        //firstly, ignore the signed bit. RNE to bf16 mantissa
        //concatenate
        if(|bf16_i)) 
            tmp = {1'b1,bf16_i.mantissa};
        else //bf16 sub-normal case
            tmp = {1'b0,bf16_i.mantissa};
        //RNE. whether RNE causes carry-on?
        if(tmp[0]) begin
            rne = tmp[7:1] + tmp[1];
        end
        else begin
            rne = {1'b0,tmp[7:1]};
        end
        // Whether carry-on effects exp adding? RNE truncation. 
        if(rne[7]) begin           
            carry_on = rne[7:1];
            if(&bf16_i.exponent) 
                bf16_RNE_int8[15-:8] = 8'b1111_1111;
            else
                bf16_RNE_int8[15-:8] = bf16_i.exponent + 1'b1;
        end
        else begin
            bf16_RNE_int8[15-:8] = bf16_i.exponent;
            carry_on = rne[6:0]
        end
        //sign bit -> complement code 
        if(bf16_i.sign) begin//sign == 1, negative number
            bf16_RNE_int8[7:0] = 1'b1 + {1'b1,~carry_on};
        end
        else
            bf16_RNE_int8[7:0] = {1'b0,carry_on}
    endfunction
    
endpackage

`endif // MX_FUNCTION_PKG