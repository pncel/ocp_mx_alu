`timescale 1ns/1ps
`include "scalar_includes.v"
`include "mx_general_includes.v"
`include "mxint8_includes.v"
module tb_mxint8_dot_product; 
    localparam int CYCLE = 100;
    localparam int N = 5; //each case repeat times
    bit clk;
    wire [`SCALE_WIDTH-1:0]                              i_scale_a;
    wire [`SCALE_WIDTH-1:0]                              i_scale_b;
    wire [`BLOCK_SIZE-1:0][`MXINT8_ELEMENT_WIDTH-1:0]    i_mxint8_elements_a;
    wire [`BLOCK_SIZE-1:0][`MXINT8_ELEMENT_WIDTH-1:0]    i_mxint8_elements_b;
    wire [`FLOAT32_WIDTH-1:0]                            o_float32_dut;
    wire [`FLOAT32_WIDTH-1:0]                            o_float32_ref;
    wire                                                 o_overflow_dut;
    wire                                                 o_overflow_ref;
    wire                                                 o_underflow_dut;
    wire                                                 o_underflow_ref;
    wire                                                 o_unused_dut;
    wire                                                 o_unused_ref;
    wire                                                 o_NaN_dut;
    wire                                                 o_NaN_ref;


    mxint8_dot_product dut_blk(
    .i_scale_a              (i_scale_a),
    .i_scale_b              (i_scale_b),
    .i_mxint8_elements_a    (i_mxint8_elements_a),
    .i_mxint8_elements_b    (i_mxint8_elements_b),
    .o_float32              (o_float32_dut),
    .o_overflow             (o_overflow_dut),
    .o_underflow            (o_underflow_dut),
    .o_is_unused            (o_unused_dut),
    .o_is_NaN               (o_NaN_dut)
        
    );

    // mx_int8_sum_ref ref_blk(
    // .i_scale(i_scale),
    // .i_mxint8_elements(i_mxint8_elements),
    // .o_float32(o_float32_ref),
    // .o_overflow(o_overflow_ref)
    // );

    mx_int8_dot_product_drv #(.N(N), .CYCLE(CYCLE)) drv(
    .scale_a_drv                (i_scale_a),
    .scale_b_drv                (i_scale_b),
    .mxint8_elements_a_drv      (i_mxint8_elements_a),
    .mxint8_elements_b_drv      (i_mxint8_elements_b),
    .o_float32_dot_product_drv  (o_float32_ref),
    .unused_flag_drv            (o_unused_ref),
    .overflow_flag_drv          (o_overflow_ref),
    .underflow_flag_drv         (o_underflow_ref),
    .NaN_flag_drv               (o_NaN_ref),
    .clk                        (clk)
    );

    mx_int8_dot_product_mon mon(
    .i_scale_a                  (i_scale_a),
    .i_scale_b                  (i_scale_b),
    .i_mxint8_elements_a        (i_mxint8_elements_a),
    .i_mxint8_elements_b        (i_mxint8_elements_b),
    .i_float32_dut              (o_float32_dut),
    .i_overflow_dut             (o_overflow_dut),
    .i_underflow_dut             (o_underflow_dut),
    .i_unused_dut               (o_unused_dut),
    .i_NaN_dut                  (o_NaN_dut),
    .i_float32_ref              (o_float32_ref),
    .i_overflow_ref             (o_overflow_ref),
    .i_underflow_ref             (o_underflow_ref),
    .i_unused_ref               (o_unused_ref),
    .i_NaN_ref                  (o_NaN_ref),
    .clk                        (clk)
    );
    initial begin
        clk = 1'b0;
        forever begin
          #(CYCLE/2)  clk = ~ clk;
        //   $display("element sum = %d", dut_blk.dot_product_sum);
        end
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,drv);
    end;
endmodule