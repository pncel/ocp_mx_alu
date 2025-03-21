`timescale 1ns/1ps
`define CYCLE 100
module tb_mxint8_bd; 
    
    bit clk;

    wire [`FLOAT32_WIDTH-1:0]         i_float32;
    wire [`SCALE_WIDTH-1:0]           o_scale_ref;
    wire [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements_ref [`BLOCK_SIZE-1:0];
    wire                              o_overflow_dut;
    wire [`SCALE_WIDTH-1:0]           o_scale_dut;
    wire [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements_dut [`BLOCK_SIZE-1:0];

    mxint8_broadcast dut_blk (
        .i_float32(i_float32),
        .o_scale(o_scale_dut),
        .o_mxint8_elements(o_mxint8_elements_dut)
    );

    mx_int8_bd_ref ref_blk (
        .i_float32(i_float32),
        .o_scale(o_scale_ref),
        .o_mxint8_elements(o_mxint8_elements_ref),
        .o_overflow(o_overflow_ref)
    );

    mx_int8_bd_drv drv(
        .gen_float32(i_float32),
        .clk(clk)
    );

    mx_int8_bd_mon mon(
    .i_float32(i_float32),
    .ref_o_scale(o_scale_ref),
    .ref_o_mxint8_elements(o_mxint8_elements_ref),
    .dut_o_scale(o_scale_dut),
    .dut_o_mxint8_elements(o_mxint8_elements_dut),
    .ref_o_overflow(o_overflow_ref),
    .clk(clk)
    );

    initial begin
        clk = 1'b0;
        forever begin
          #(`CYCLE/2)  clk = ~ clk;
        end
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,tb_mxint8_bd);
    end
endmodule
