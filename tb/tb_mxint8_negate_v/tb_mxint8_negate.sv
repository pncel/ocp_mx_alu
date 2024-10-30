`timescale 1ns/1ps
`define CYCLE 10
module tb_mxint8_negate; 
    `include "mxint8_negate.v"
    bit clk;
    wire [`MXINT8_ELEMENT_WIDTH-1:0] dut_i_mxint8_elements[0:`BLOCK_SIZE-1];
    wire [`MXINT8_ELEMENT_WIDTH-1:0] dut_o_mxint8_elements[0:`BLOCK_SIZE-1];
    wire data_ready;
   
    mxint8_negate uut (
        .i_mxint8_elements(dut_i_mxint8_elements),
        .i_treat_unused_encode_as_zero(1'b1), // TODO: maybe add tests for both
        .o_mxint8_elements(dut_o_mxint8_elements)
    );

    mx_int8_negate_drv drv(
        .clk(clk),
        .gen_mxint8_elements(dut_i_mxint8_elements),
        .data_ready_o(data_ready)
    );

    mx_int8_negate_mon mon(
      .clk(clk),
      .dut_in_mxint8_elements(dut_i_mxint8_elements),
      .dut_out_mxint8_elements(dut_o_mxint8_elements),
      .data_ready_i(data_ready)
    );

    initial begin
        clk = 1'b0;
        forever begin
          #(`CYCLE/2)  clk = ~ clk;
        end
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,tb_mxint8_negate);
    end
endmodule
