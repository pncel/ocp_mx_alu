`timescale 1ns/1ps
`include "scalar_includes.v"
`include "mx_general_includes.v"
`include "mxint8_includes.v"
module tb_mx_int8_sum; 
    localparam int CYCLE = 100;
    localparam int N = 5; //each case repeat times
    bit clk;
    wire [`SCALE_WIDTH-1:0]            i_scale;
    wire [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [`BLOCK_SIZE-1:0];
    wire [`FLOAT32_WIDTH-1:0]          o_float32_sum;
    wire                               o_overflow_ref;
    wire [`FLOAT32_WIDTH-1:0]          o_float32_dut;
    wire                               o_overflow_dut;
    wire                               o_is_unused;

    mxint8_sum dut_blk(
    .i_scale(i_scale),
    .i_mxint8_elements(i_mxint8_elements),
    .o_float32(o_float32_dut),
    .o_overflow(o_overflow_dut),
    .o_is_unused(o_is_unused)
    );

    // mx_int8_sum_ref ref_blk(
    // .i_scale(i_scale),
    // .i_mxint8_elements(i_mxint8_elements),
    // .o_float32(o_float32_ref),
    // .o_overflow(o_overflow_ref)
    // );

    mx_int8_sum_drv #(.N(N), .CYCLE(CYCLE)) drv(
    .scale_drv(i_scale),
    .mxint8_elements_drv(i_mxint8_elements),
    .float32_sum_drv(o_float32_sum),
    .clk(clk)
    );

    mx_int8_sum_mon mon(
    .i_scale(i_scale),
    .i_mxint8_elements(i_mxint8_elements),
    .i_float32_dut(o_float32_dut),
    .i_overflow_dut(o_overflow_dut),
    .i_float32_ref(o_float32_sum),
    .i_overflow_ref(o_overflow_ref),
    .i_is_unused(o_is_unused),
    .clk(clk)
    );
    initial begin
        clk = 1'b0;
        forever begin
          #(CYCLE/2)  clk = ~ clk;
        end
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,drv);
    end;
endmodule