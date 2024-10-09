`ifndef  MXINT8_NEGATE__V
`define  MXINT8_NEGATE__V

module mxint8_negate (
    i_mxint8_elements,
    o_mxint8_elements
);

    `include "mxint8_includes.v"

    input   wire [`MXINT8_ELEMENT_WIDTH-1:0] i_mxint8_elements [`BLOCK_SIZE-1:0];
    input   wire                             i_treat_unused_encode_as_zero;
    output  wire [`MXINT8_ELEMENT_WIDTH-1:0] o_mxint8_elements [`BLOCK_SIZE-1:0];

    genvar i;
    generate
        for (i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            always @(*) begin
                if (i_mxint8_elements[i] == 8'b1000_0000) begin
                    o_mxint8_elements[i] = i_treat_unused_encode_as_zero ? 8'b0000_0000 : 8'b1000_0000;
                end
                else begin
                    o_mxint8_elements[i] = ~i_mxint8_elements[i] + 8'b0000_0001;
                end
            end
        end
    endgenerate

endmodule
`endif 