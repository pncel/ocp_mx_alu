`timescale 1ns/1ps
`define CYCLE 100
module tb_mx_int8_sum; 
    
    bit clk;
    wire [`SCALE_WIDTH-1:0]            i_scale;
    wire [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [BLOCK_SIZE-1:0];
    wire [`FLOAT32_WIDTH-1:0]          o_float32_ref;
    wire                               o_overflow_ref;
    wire [`FLOAT32_WIDTH-1:0]          o_float32_dut;
    wire                               o_overflow_dut;

    mxint8_sum dut_blk(
    .i_scale(i_scale),
    .i_mxint8_elements(i_mxint8_elements),
    .o_float32(o_float32_dut),
    .o_overflow(o_overflow_dut)
    );

    mx_int8_sum_ref ref_blk(
    .i_scale(i_scale),
    .i_mxint8_elements(i_mxint8_elements),
    .o_float32(o_float32_ref),
    .o_overflow(o_overflow_ref)
    );

    mx_int8_sum_drv drv(
    .scale_drv(i_scale),
    .mxint8_elements_drv(i_mxint8_elements),
    .clk(clk)
    );

    mx_int8_sum_mon mon(
    .i_scale(i_scale),
    .i_mxint8_elements(i_mxint8_elements),
    .i_float32_dut(o_float32_dut),
    .i_overflow_dut(o_overflow_dut),
    .i_float32_ref(o_float32_ref),
    .i_overflow_ref(o_overflow_ref),
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
        $dumpvars(0,tb_mx_int8_sum);
    end;
endmodule