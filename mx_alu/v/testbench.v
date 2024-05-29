// Oliver Huang 
// pncel
// testbench for mx alu
//`default_nettype None
//
//`timescale 1ns/1ps
import mxfp8_pkg::*;
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
  parameter size = k*d + w;
  logic [2:0] dtype; // 6 standard variations
  logic [2:0] op;    // op codes
  logic [31:0] scalar_in;
  logic [size-1:0] vec_in_a;
  logic [size-1:0] vec_in_b;
  logic [size-1:0] vec_out;
  logic [31:0] scalar_out;

  parameter T = 20;
  //define simulated clock if sequential logic is used
  initial begin
    clk <= 0;
    forever #(T/2) clk <= ~clk;
  end // initial clock

  mx_alu_wrapper dut (.*);
  
  logic elements;
  integer i;
  
  mxfp8_block input_vec;
  mxfp8_e5m2_element curr_element;
  
  initial begin

    $write("%c[1;32m",27); $display("\nBegin: OCP MX ALU Test Cases\n");
    $write("%c[0m",27);
    input_vec.scale = 'hAA; input_vec.elements[31] = 'b0_11111_00; @(posedge clk);
    vec_in_a = input_vec; @(posedge clk); repeat(10) @(posedge clk);

    // for(i = 0; i < size; i+=) begin
      
      
    // end

    $display("vec_in_a: %h", input_vec.elements[0]);
    // $display("Mean Relative Error Distance (MRED): %f", mred);
    $write("%c[1;32m",27); $display("End: Multiplier Test Cases\n"); @(posedge clk);
    $write("%c[0m",27);
    $finish;
  end

endmodule
