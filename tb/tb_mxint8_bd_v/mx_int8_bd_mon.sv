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

    input [`FLOAT32_WIDTH-1:0]              i_float32;  //same as float in c 
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
            $display("%b  :INT8 element mantissa output binary REF",{7'bXXX_XXXX,data_out});
            $display("%b  :INT8 element mantissa output binary DUT",{7'bXXX_XXXX,data_out_dut});
            $display("%b  :E8M0 shared scalar output binary REF",{1'bX,ref_o_scale});
            $display("%b  :E8M0 shared scalar output binary DUT",{1'bX,dut_o_scale});
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

endmodule