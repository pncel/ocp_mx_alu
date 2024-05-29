
package mxfp8_pkg;

  // MXFP8 block standard
  // scale data type is always E8M0
  typedef struct packed{
    logic [7:0] scale;
    logic [31:0] [7:0] elements ;
  } mxfp8_block;

  // Used to parse FP8 E5M2 elements
  typedef struct packed {
    logic sign;
    logic [4:0] exponent;
    logic [1:0] mantissa;
  } mxfp8_e5m2_element;

  // Used to parse FP8 E4M3 elements
  typedef struct packed {
    logic sign;
    logic [3:0] exponent;
    logic [2:0] mantissa;
  } mxfp8_e4m3_element;

  parameter d = 8;
  parameter k = 32; 
  parameter w = 8; 
  localparam size = w+k*d;

endpackage

