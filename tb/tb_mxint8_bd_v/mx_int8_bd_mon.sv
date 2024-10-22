`timescale 1ns/1ps
module mx_int8_bd_mon(
    i_float32,
    ref_o_scale,
    ref_o_mxint8_elements,
    ref_o_overflow,
    dut_o_scale,
    dut_o_mxint8_elements,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input wire clk;

    input reg  [`FLOAT32_WIDTH-1:0]              i_float32;  //same as float in c 
    input reg  [`SCALE_WIDTH-1:0]           ref_o_scale;
    input reg  [`MXINT8_ELEMENT_WIDTH-1:0]  ref_o_mxint8_elements [`BLOCK_SIZE-1:0];
    input reg                               ref_o_overflow;
    input reg  [`SCALE_WIDTH-1:0]           dut_o_scale;
    input reg  [`MXINT8_ELEMENT_WIDTH-1:0]  dut_o_mxint8_elements [`BLOCK_SIZE-1:0];

    reg  [`MXINT8_ELEMENT_WIDTH-1:0] data_out;
    reg  [`MXINT8_ELEMENT_WIDTH-1:0] data_out_dut;
    int transection_id; 

    initial begin
        transection_id = 0; 
    end

    always @(negedge clk) begin
        $display("\ntransection id: %d",transection_id);
        single_mon();
        transection_id <= transection_id + 1; 
    end

    task single_mon;
        reg same;
        reg same_dut;
            same_dut = 1'b1;
            same = 1'b1;
            data_out = ref_o_mxint8_elements[0];
            data_out_dut = dut_o_mxint8_elements[0];
            #0; 
            
            //$display("input data: %f, output data:", i_float32);                
            $display("input binary: \n%b",i_float32);
            float_scale_mantissa_print(i_float32);
            $display("%b  %f    :INT8 element mantissa output binary REF",{7'bXXX_XXXX,data_out},INT8_to_shortreal(data_out));
            $display("%b  %f    :INT8 element mantissa output binary DUT",{7'bXXX_XXXX,data_out_dut},INT8_to_shortreal(data_out_dut));
            $display("%b  %f    :E8M0 shared scalar output binary REF",{1'bX,ref_o_scale},scale_to_shortreal(ref_o_scale));
            $display("%b  %f    :E8M0 shared scalar output binary DUT",{1'bX,dut_o_scale},scale_to_shortreal(dut_o_scale));
            if(data_out!=data_out_dut)
                $display("ERROR elements not match");
            if(ref_o_scale!=dut_o_scale)
                $display("ERROR scale not match");
            $display("%b  :o_overflow output binary REF",ref_o_overflow);
            for(int i = 0; i < `BLOCK_SIZE-1; i = i + 1) begin
                if(ref_o_mxint8_elements[i] != ref_o_mxint8_elements[i+1]) begin
                    same = 1'b0;
                    $display("REF ERROR in broadcase e:%d != e:%d",i,i+1);
                end 
                if(dut_o_mxint8_elements[i] != dut_o_mxint8_elements[i+1]) begin
                    same_dut = 1'b0;
                    $display("DUT ERROR in broadcase e:%d != e:%d",i,i+1);
                end 
            end
            if(!same) begin
                $display("REF broadcase elements same ERROR");
                same = 1'b1; 
            end 
            if(!same_dut) begin
                $display("DUT broadcase elements same ERROR");
                same = 1'b1; 
            end 
    endtask
    function  automatic void float_scale_mantissa_print([`FLOAT32_WIDTH-1:0] fl_data);
        shortreal scale;
        shortreal mantissa;
        bit subnormal; 

        if(fl_data[`FLOAT32_EXPONENT_BITS] == 8'b0000_0000) begin
            scale = -126.0;
            subnormal = 1'b1;
        end
        else begin
            scale = scale_to_shortreal(fl_data[`FLOAT32_EXPONENT_BITS]);
            subnormal = 1'b0;
        end
        $display("%f    : FP32 scale",scale);
        mantissa = FP32_to_mantissa(fl_data,subnormal);
        $display("%f    : FP32 mantissa",mantissa);
        if(subnormal) begin
            $display("in scale: -127 version");
            $display("%f    : FP32 mantissa",mantissa*2.0);
        end
    endfunction
    function automatic shortreal FP32_to_mantissa([`FLOAT32_WIDTH-1:0] fl_data, bit subnormal);
        shortreal scale;
        shortreal decimal_data;

        scale = 0.5;
        decimal_data = 0;
        for(int i = `FLOAT32_MANTISSA_MSB ; i >= `FLOAT32_MANTISSA_LSB ; i = i - 1) begin
            if(fl_data[i]==1'b1)
                decimal_data += scale;
            scale = scale/2;
        end
        if(subnormal) begin
            decimal_data = decimal_data;
        end
        else begin
            decimal_data += 1.0;
        end
        if(fl_data[`FLOAT32_SIGN_BIT])
            decimal_data = decimal_data * (-1.0);
        return decimal_data;
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
endmodule