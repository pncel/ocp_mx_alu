
`include "alu_core_pkg.sv";

module mx_vector_negator
import alu_core_pkg::*;
(
    input t_mxint8_vector vector,
    output t_mxint8_vector negated_vector
);

    t_mxint8_vector tmp;

    assign tmp.scale = vector.scale;

    // use 2's complement to negate an INT8 element in the vector
    generate
        for (genvar i = 0; i < SCALING_BLOCK_SIZE; i++) begin
            tmp.elements[i] = ~vector.elements[i] + 1;
        end
    endgenerate

    assign negated_vector = tmp;

endmodule