`timescale 1ns/1ps
`include "scalar_includes.v"
`include "mx_general_includes.v"
`include "mxint8_includes.v"
module tb_mx_int8_sum; 
    localparam int CYCLE = 100;
    localparam int N = 5; //each case repeat times
    bit clk;
    wire [`SCALE_WIDTH-1:0]            i_scale_a;
    wire [`SCALE_WIDTH-1:0]            i_scale_b;
    wire [`SCALE_WIDTH-1:0]            o_scale;
    wire [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements_a [`BLOCK_SIZE-1:0];
    wire [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements_b [`BLOCK_SIZE-1:0];
    wire [`MXINT8_ELEMENT_WIDTH-1:0]   o_mxint8_elements [`BLOCK_SIZE-1:0];
    wire [`FLOAT32_WIDTH-1:0]          o_float32_ref;
    wire                               o_overflow_ref;
    wire [`FLOAT32_WIDTH-1:0]          o_float32_dut;
    wire                               o_overflow_dut;
    wire                               o_is_unused;
    wire [9:0] normalize_shift;
    wire signed [23:0] temp_add_result [`BLOCK_SIZE-1:0];
    wire signed [23:0] i_mxint8_elements_a_temp [`BLOCK_SIZE-1:0];
    wire signed [23:0] i_mxint8_elements_b_temp [`BLOCK_SIZE-1:0];
    wire [23:0] max_abs_value;

    mxint8_add dut_blk(
    .i_scale_a(i_scale_a),
    .i_scale_b(i_scale_b),
    .i_mxint8_elements_a(i_mxint8_elements_a),
    .i_mxint8_elements_b(i_mxint8_elements_b),
    .o_scale(o_scale),
    .o_mxint8_elements(o_mxint8_elements),
    .o_overflow(o_overflow),
    .o_is_unused(o_is_unused),
    .normalize_shift(normalize_shift),
    .temp_add_result(temp_add_result),
    .max_abs_value(max_abs_value),
    .i_mxint8_elements_a_temp(i_mxint8_elements_a_temp),
    .i_mxint8_elements_b_temp(i_mxint8_elements_b_temp)
    );

    // mx_int8_sum_ref ref_blk(
    // .i_scale(i_scale),
    // .i_mxint8_elements(i_mxint8_elements),
    // .o_float32(o_float32_ref),
    // .o_overflow(o_overflow_ref)
    // );

    mx_int8_add_drv #(.N(N), .CYCLE(CYCLE)) drv(
    .scale_a_drv(i_scale_a),
    .scale_b_drv(i_scale_b),
    .mxint8_elements_a_drv(i_mxint8_elements_a),
    .mxint8_elements_b_drv(i_mxint8_elements_b),
    .clk(clk)
    );

    mx_int8_add_mon mon(
    .normalize_shift(normalize_shift),
    .temp_add_result(temp_add_result),
    .max_abs_value(max_abs_value),
    .i_scale_a(i_scale_a),
    .i_scale_b(i_scale_b),
    .i_scale(o_scale),
    .i_mxint8_elements_a(i_mxint8_elements_a),
    .i_mxint8_elements_b(i_mxint8_elements_b),
    .i_mxint8_elements_a_temp(i_mxint8_elements_a_temp),
    .i_mxint8_elements_b_temp(i_mxint8_elements_b_temp),
    .i_mxint8_elements(o_mxint8_elements),
    // .i_overflow_dut(o_overflow_dut),
    // .i_float32_ref(o_float32_ref),
    // .i_overflow_ref(o_overflow_ref),
    // .i_is_unused(o_is_unused),
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