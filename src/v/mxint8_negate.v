`ifndef  MXINT8_NEGATE__V
`define  MXINT8_NEGATE__V

module mxint8_negate (
    i_mxint8_elements,
    o_mxint8_elements
);

    `include "mxint8_includes.v"

    input   wire [`MXINT8_ELEMENT_WIDTH-1:0] i_mxint8_elements [`BLOCK_SIZE-1:0];
    output  wire [`MXINT8_ELEMENT_WIDTH-1:0] o_mxint8_elements [`BLOCK_SIZE-1:0];

    genvar i;
    generate
        for (i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            assign o_mxint8_elements[i] = ~i_mxint8_elements[i] + 8'b0000_0001;
        end
    endgenerate

endmodule
`endif 