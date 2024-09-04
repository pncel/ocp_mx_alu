`timescale 1ns/1ps
module mx_int8_bd_mon(
    i_float32,
    ref_o_scale,
    ref_o_mxint8_elements,
    ref_o_overflow,
    data_ready_i,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input wire data_ready_i;  
    input wire clk;

    input [`FLOAT32_WIDTH-1:0]              i_float32;  //same as float in c 
    input reg  [`SCALE_WIDTH-1:0]           ref_o_scale;
    input reg  [`MXINT8_ELEMENT_WIDTH-1:0]  ref_o_mxint8_elements [`BLOCK_SIZE-1:0];
    input reg                               ref_o_overflow;

    reg  [`MXINT8_ELEMENT_WIDTH-1:0] data_out;
    reg shortreal decoded_out;
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
            same = 1'b1;
            data_out = ref_o_mxint8_elements[0];
            decoded_out = decoder(ref_o_mxint8_elements[0]);
            #0; 
            
            //$display("input data: %f, output data:", i_float32);                
            $display("input binary: \n%b",i_float32);
            $display("%b  :INT8 element mantissa output binary REF",{7'bXXX_XXXX,data_out});
            $display("%b  :E8M0 shared scalar output binary REF",{1'bX,ref_o_scale});
            $display("%b  :o_overflow output binary REF",ref_o_overflow);
            for(int i = 0; i < `BLOCK_SIZE-1; i = i + 1) begin
                if(ref_o_mxint8_elements[i] != ref_o_mxint8_elements[i+1]) begin
                    same = 1'b0;
                    $display("ERROR in broadcase e:%d != e:%d",i,i+1);
                end 
            end
            if(!same) begin
                $display("broadcase elements same ERROR");
                same = 1'b1; 
            end 
    endtask

    function automatic decoder(input reg[`MXINT8_ELEMENT_WIDTH-1:0] int8_data);
        shortreal scale;
        shortreal decimal_data;
        scale = 1.0;
        decimal_data = 0;
        for(int i = `MXINT8_ELEMENT_WIDTH-2 ; i >= 0 ; i = i - 1) begin
            if(int8_data[i]==1'b1)
                decimal_data += scale;
            scale = scale/2;
        end
        if(int8_data[`MXINT8_ELEMENT_WIDTH-1])
            decimal_data -= 2; 
        return decimal_data;
    endfunction
endmodule