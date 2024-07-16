`ifndef MX_ALU_IF__SV
`define MX_ALU_IF__SV
interface mx_alu_if_in #(parameter d=8, k=32, w=8, s=32, localparam size = w+k*d) (input logic clk);

    // Signal declarations
    logic valid_in;
    logic valid_out;
    logic [2:0] dtype; // 6 standard variations
    logic [2:0] op;    // op codes
    logic [s-1:0] scalar_in;
    logic [size-1:0] vec_in_a;
    logic [size-1:0] vec_in_b;

    // Modports for DUT and testbench
    modport DUT (
        input  valid_in, dtype, op, scalar_in, vec_in_a, vec_in_b,
        output valid_out
    );

    modport DRV (
        output valid_in, dtype, op, scalar_in, vec_in_a, vec_in_b,
        input  valid_out
    );

    modport MON (
        input valid_out, valid_in, dtype, op, scalar_in, vec_in_a, vec_in_b
    );
endinterface

interface mx_alu_if_out #(parameter d=8, k=32, w=8, s=32, localparam size = w+k*d) (input logic clk);

    // Signal declarations
    logic valid_out;
    logic [size-1:0] vec_out;
    logic [s-1:0] scalar_out;

    // Modports for DUT and testbench
    modport DUT (
        output valid_out, vec_out, scalar_out
    );

    modport MON (
        input  valid_out, vec_out, scalar_out
    );

endinterface
`endif 