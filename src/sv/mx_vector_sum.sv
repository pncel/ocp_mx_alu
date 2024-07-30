
`include "alu_core_pkg.sv";

module mx_vector_sum
import alu_core_pkg::*;
(
    input t_mxint8_vector vector,
    output t_bfloat16 sum
);

    logic signed [31:0] int_elements_sum;

    always_comb begin
        int_elements_sum = vector.elements[0]
    end

endmodule