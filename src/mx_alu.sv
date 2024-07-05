
// default parameters for MXFP8 or MXINT8
// d is element bits
// k is scaling block size; # elements
// w is scale bits 
`include "mx_format_pkg.sv";

module mx_alu 
    // #(parameter d=8, k=32, w=8, localparam size = w+k*d) 
(
    input logic [2:0] dtype, // 6 standard variations
    input logic [2:0] op,    // op codes
    input logic [31:0] scalar_in,
    input logic [size-1:0] vec_in_a,
    input logic [size-1:0] vec_in_b,
    output logic [size-1:0] vec_out,
    output logic [31:0] scalar_out
);
    import mx_format_pkg::*;

    // bad style for slides
    mxfp8_block inA;          assign inA = vec_in_a;
    logic [7:0] scale;        assign scale = inA.scale;
    mxfp8_e5m2_element curr;  assign curr = inA.elements[31];
    logic sign;               assign sign = curr.sign;
    logic [4:0] curr_e;       assign curr_e = curr.exponent;
    logic [1:0] curr_m;       assign curr_m = curr.mantissa;

    assign vec_out = '0;
    assign scalar_out = '0;


endmodule
