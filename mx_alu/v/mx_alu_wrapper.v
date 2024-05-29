module mx_alu_wrapper 
  import mxfp8_pkg::*;
  #(parameter d=8, k=32, w=8, localparam size = w+k*d) 
(
  input logic clk,
  input logic [2:0] dtype, // 6 standard variations
  input logic [2:0] op,    // op codes
  input logic [31:0] scalar_in,
  input logic [size-1:0] vec_in_a,
  input logic [size-1:0] vec_in_b,
  output logic [size-1:0] vec_out,
  output logic [31:0] scalar_out
);

  logic [2:0] dtype_r; // 6 standard variations
  logic [2:0] op_r;    // op codes
  logic [31:0] scalar_in_r;
  logic [size-1:0] vec_in_a_r;
  logic [size-1:0] vec_in_b_r;

  always_ff @(posedge clk) begin
    dtype_r <= dtype;
    op_r <= op;
    scalar_in_r <= scalar_in;
    vec_in_a_r <= vec_in_a;
    vec_in_b_r <= vec_in_b;
  end

  mx_alu alu (.dtype(dtype_r), .op(op_r), .scalar_in(scalar_in_r), 
              .vec_in_a(vec_in_a_r), .vec_in_b(vec_in_b_r), 
              .vec_out(vec_out), .scalar_out(scalar_out));

endmodule