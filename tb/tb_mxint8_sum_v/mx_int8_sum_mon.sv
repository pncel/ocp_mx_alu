`timescale 1ns/1ps
module mx_int8_sum_mon(
    i_scale,
    i_mxint8_elements,
    i_float32_dut,
    i_overflow_dut,
    i_float32_ref,
    i_overflow_ref,
    clk
);
    `include "scalar_includes.v"
    `include "mx_general_includes.v"
    `include "mxint8_includes.v"
    
    input  wire clk;
    input  reg [`SCALE_WIDTH-1:0]            i_scale;
    input  reg [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [`BLOCK_SIZE-1:0];
    input  reg [`FLOAT32_WIDTH-1:0]          i_float32_ref;
    input  reg                               i_overflow_ref;
    input  reg [`FLOAT32_WIDTH-1:0]          i_float32_dut;
    input  reg                               i_overflow_dut;
    
    reg [`FLOAT32_WIDTH-1:0]         float32_conv;/*
    reg  [`SCALE_WIDTH-1:0]           o_scale_conv;
    reg  [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements_conv [`BLOCK_SIZE-1:0];
    
    mxint8_broadcast FP32_to_E8INT8 (
        .i_float32(i_float32_conv),
        .o_scale(o_scale_conv),
        .o_mxint8_elements(o_mxint8_elements_conv)
    );*/ //if need int8 sum

    int transection_id; 

    initial begin
        transection_id = 0; 
    end
    //check and output part in each transection 
    always @(negedge clk) begin : single_transection 
        $display("\ntransection id: %d",transection_id);
        float32_conv = print_input_vector();
        #1;
        $display("%b    :REF FP32 SUM OUT",float32_conv);
        //print_dut_out();
        //print_ref_out();
        /*
        if(float32_conv != i_float32_ref)
            $display("ERROR case.");*/
        transection_id <= transection_id + 1; 
    end

    function void print_dut_out();
        $display("FP32 DUT SUM OUTPUT:\n%b   %f", i_float32_dut,i_float32_dut);
    endfunction
    function void print_ref_out();
        $display("FP32 REF SUM OUTPUT:\n%b   %f", i_float32_ref,i_float32_ref);
    endfunction
    function reg[`FLOAT32_WIDTH-1:0] print_input_vector();
        shortreal scale_r;
        shortreal scale_dec;
        shortreal mantissa_sum;
        shortreal mantissa_sum_raw;
        shortreal mantissa_sum_dec;
        int ceil_sum;
        bit overflow; 
        int carry_num;
        reg [`SCALE_WIDTH-1:0]  scale_E8;
        int carry_neg;
        shortreal ideal_sum;
        reg [63:0] ideal_sum_bin;
        //shortreal elements [`BLOCK_SIZE-1:0];

        mantissa_sum = 0.0;
        scale_r = scale_to_shortreal(i_scale); 
        overflow = is_overflow(scale_r);
        scale_dec = $pow(2.0,scale_r); //$pow(x,y) = x**y LRM 20.8.2 is for real. shortreal also work
        $display("INPUT DATA: \nscale:\n%b   %f\n%f    NaN: %b",i_scale,scale_r,scale_dec,overflow);
        $display("elements:");
        for(int i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            shortreal element_r;
            element_r = INT8_to_shortreal(i_mxint8_elements[i]);
            mantissa_sum += element_r;
            $display("%b ,  %f  ,  %f",i_mxint8_elements[i],element_r,scale_dec*element_r);
        end
        carry_neg = 0;
        mantissa_sum_raw = mantissa_sum;
        while(abs_shortreal(mantissa_sum) <= 0.9921875 && mantissa_sum != 0.0) begin //for higher precision ? (1 63/64) / 2
            mantissa_sum *= 2.0;
            carry_neg += 1;
        end
        ceil_sum = shortreal_ceil_to_int(mantissa_sum);
        carry_num = $clog2(abs_int(ceil_sum)) - 1;
        carry_num -= carry_neg;
        scale_r += itoshortreal(carry_num); //no int to shortreal conversion function
        
        scale_E8 = i_scale + carry_num;
        overflow = is_overflow(scale_r);
        scale_dec = $pow(2.0,scale_r); 

//MODIFY  Add subnormal region treatment method
        mantissa_sum_dec = shortreal_shift(mantissa_sum,-1.0 * (carry_num + carry_neg));

        ideal_sum = mantissa_sum*scale_dec;
        $display("%e  ideal sum. %b:NaN  %f:raw sum dec",ideal_sum,overflow,mantissa_sum_raw);
        $display("%b  :scale,  %f:mantissa_dec_ideal,  %f:scale,  %d:carry_num",scale_E8,mantissa_sum_dec,scale_r,carry_num);
        return ideal_sum;
        //return $shortrealtobits(ideal_sum); //20.5 LRM conversion function 
        
    endfunction
    function automatic shortreal shortreal_shift(shortreal data, int shift_num); 
        while(shift_num != 0) begin
            if(shift_num > 0) begin
                shift_num -= 1;
                data *= 2.0;
            end
            else begin
                shift_num += 1;
                data /= 2.0;
            end
        end
        return data;
    endfunction
    function automatic shortreal itoshortreal(int int_i);
        shortreal sr_o;

        sr_o = 0.0;
        while(int_i!=0) begin
            if(int_i > 0) begin
                sr_o += 1.0;
                int_i -= 1;
            end
            else begin
                sr_o -= 1.0;
                int_i += 1;
            end
        end
        return sr_o;
    endfunction
    function automatic shortreal pow2(shortreal exp_i);
        shortreal pow_o = 1.0;

        while(exp_i!=0) begin
            if(exp_i > 0) begin
                pow_o *= 2.0;
                exp_i -= 1;
            end
            else begin
                pow_o /= 2.0;
                exp_i += 1;
            end
        end
        return pow_o;
    endfunction
    function automatic bit is_overflow(shortreal scale);
        if(scale >= 128.0)
            return 1'b1;
        else 
            return 1'b0;
    endfunction
    function automatic int abs_int(int d_in);
        if(d_in >= 0)
            return d_in;
        else
            return -1*d_in;
    endfunction
    function automatic shortreal abs_shortreal(shortreal d_in);
        if(d_in >= 0.0)
            return d_in;
        else
            return -1.0*d_in;
    endfunction
    function automatic int shortreal_ceil_to_int(shortreal shortreal_i);
        int int_o;

        int_o = 0;
        if( shortreal_i >= 0) begin
            while(shortreal_i > 0.0) begin
                int_o += 1;
                shortreal_i -= 1.0;
            end
        end
        else begin
            while(shortreal_i < 0.0) begin
                int_o -= 1;
                shortreal_i += 1.0;
            end
        end
        return int_o;
    endfunction
    /*function automatic shortreal scale_to_dec(shortreal exp_r);
        shortreal dec_r = 1.0;
        while(exp_r != 0.0) begin
            if(exp_r>0.0) begin
                dec_r *= 2.0;
                exp_r -= 1.0;
            end
            else begin
                dec_r /= 2.0;
                exp_r += 1.0;
            end
        end
        return dec_r;
    endfunction*/
    function automatic shortreal scale_to_shortreal(reg [`SCALE_WIDTH-1:0] scale_int);
        shortreal scale_r;
        shortreal scale;

        scale = 1.0;
        scale_r = 0;
        for(int i = 0; i < `SCALE_WIDTH ; i = i + 1) begin
            if(scale_int[i]==1'b1)
                scale_r += scale;
            scale = scale * 2.0;
        end
        return scale_r - 127.0;
    endfunction
    function automatic shortreal INT8_to_shortreal(reg[`MXINT8_ELEMENT_WIDTH-1:0] element);
        shortreal scale;
        shortreal decimal_data;

        scale = 1.0;
        decimal_data = 0;
        for(int i = `MXINT8_ELEMENT_WIDTH-2 ; i >= 0 ; i = i - 1) begin
            if(element[i]==1'b1)
                decimal_data += scale;
            scale = scale/2;
        end
        if(element[`MXINT8_ELEMENT_WIDTH-1])
            decimal_data -= 2; 
        return decimal_data;
    endfunction 
    /*
    function automatic void print_ref_sum();
        $display("%b  %f    :INT8 element mantissa output binary REF",{7'bXXX_XXXX,data_out},INT8_to_shortreal(data_out));
        $display("%b  %f    :INT8 element mantissa output binary DUT",{7'bXXX_XXXX,data_out_dut},INT8_to_shortreal(data_out_dut));
    endfunction*/ //if need int8 sum 
endmodule