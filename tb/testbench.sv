// Oliver Huang 
// pncel
// testbench for mx alu
//`default_nettype None

//next test on TB framework
//1: organize parameters for sv components
//2: using config_db to syn a uvm_object parameter class 
`timescale 1ns/1ps
import mxfp8_pkg::*;

`include "mx_alu_if.sv"

module testbench;

    /* Dump Test Waveform To VPD File */
    initial begin
        $dumpfile("waveform.vcd");
        $fsdbDumpfile("waveform.fsdb");
        $fsdbDumpvars();
        $dumpvars;
    end

    logic clk;
    parameter d = 8; 
    parameter k = 32; 
    parameter w = 8;
    parameter s = 32;
    parameter size = k*d + w;

    parameter T = 20;
    //define simulated clock if sequential logic is used
    initial begin
        clk <= 0;
        forever #(T/2) clk <= ~clk;
    end // initial clock

    mx_alu_if_in #(
        .d(d), .k(k), .w(w), .s(s)
    ) input_if(clk);

    mx_alu_if_out #(
        .d(d), .k(k), .w(w), .s(s)
    ) output_if(clk);
    
    mx_alu_wrapper #(
        .d(d), .k(k), .w(w)
    ) dut (
        .clk(clk),
        .dtype(input_if.dtype), // 6 standard variations
        .op(input_if.op),    // op codes
        .scalar_in(input_if.scalar_in),
        .vec_in_a(input_if.vec_in_a),
        .vec_in_b(input_if.vec_in_b),
        .vec_out(ouput_if.vec_out),
        .scalar_out(ouput_if.scalar_out),
        .valid_out(ouput_if.valid_out),
        .valid_in(input_if.valid_in)
    );
    assign input_if.valid_out = ouput_if.valid_out;

    initial begin
        #1_000_000;
    end
    
    initial begin
        run_test();
    end

    initial begin
        uvm_config_db#(virtual mx_alu_if_in#(.d(d), .k(k), .w(w), .s(s)).DRV )
        ::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
        uvm_config_db#(virtual mx_alu_if_in#(.d(d), .k(k), .w(w), .s(s)).MON)
        ::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
        uvm_config_db#(virtual mx_alu_if_out#(.d(d), .k(k), .w(w), .s(s)).MON)
        ::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
     end

endmodule
