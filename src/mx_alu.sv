
`include "alu_core_pkg.sv";

module mx_alu 
import alu_core_pkg::*;
(
    input t_opcode opcode,

    input t_scalar_datatype scalar_datatype,
    input logic scalar_in_valid,
    input logic [LARGEST_FLOAT_WIDTH-1:0] scalar_in,
    
    input t_vector_datatype vector_datatype,
    input logic vector_in_a_valid,
    input logic [LARGEST_VECTOR_SIZE-1:0] vector_in_a,
    input logic vector_in_b_valid,
    input logic [LARGEST_VECTOR_SIZE-1:0] vector_in_b,

    output logic scalar_out_valid,
    output logic [LARGEST_FLOAT_WIDTH-1:0] scalar_out,

    output logic vector_out_valid,
    output logic [LARGEST_VECTOR_SIZE-1:0] vector_out
);

    


endmodule
