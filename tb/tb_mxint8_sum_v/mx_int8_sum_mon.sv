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
    localparam scalar_offset = 8'd127;
    
    input  wire clk;
    input  reg [`SCALE_WIDTH-1:0]            i_scale;
    input  reg [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [`BLOCK_SIZE-1:0];
    input  reg [`FLOAT32_WIDTH-1:0]          i_float32_ref;
    input  reg                               i_overflow_ref;
    input  reg [`FLOAT32_WIDTH-1:0]          i_float32_dut;
    input  reg                               i_overflow_dut;

    int transection_id; 

    initial begin
        transection_id = 0; 
    end

    always @(negedge clk) begin
        print_transection();
        transection_id <= transection_id + 1; 
    end

    function void print_dut_out();
        $display("FP32 DUT SUM OUTPUT:\n%b   %f", i_float32_dut,i_float32_dut);
    endfunction
    function void print_ref_out();
        $display("FP32 REF SUM OUTPUT:\n%b   %f", i_float32_ref,i_float32_ref);
    endfunction
    function void print_input_vector();
        shortreal scale_r;
        //shortreal elements [`BLOCK_SIZE-1:0];
        scale_r = scale_to_shortreal(i_scale);
        $display("INPUT DATA: \nscale:\n%b   %d",i_scale,i_scale - scalar_offset);
        $display("elements:");
        for(int i = 0; i < `BLOCK_SIZE; i = i - 1) begin
            shortreal element_r;
            element_r = INT8_to_shortreal(i_mxint8_elements[i]);
            $display("%b ,  %f,  %f",i_mxint8_elements[i],element_r,scale_r*element_r);
        end
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
    function void print_transection();
        $display("\ntransection id: %d",transection_id);
        print_input_vector();
        print_dut_out();
        print_ref_out();
        if(i_float32_dut != i_float32_ref)
            $display("ERROR case.");
    endfunction

endmodule