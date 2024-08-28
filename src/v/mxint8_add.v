
module mxint8_add (
    i_scale_a,
    i_mxint8_elements_a,
    i_scale_b,
    i_mxint8_elements_b,
    o_scale,
    o_mxint8_elements,
    o_overflow
);

    `include "mxint8_includes.v"

    input  reg  [`SCALE_WIDTH-1:0]           i_scale_a;
    input  reg  [`MXINT8_ELEMENT_WIDTH-1:0]  i_mxint8_elements_a [`BLOCK_SIZE-1:0];
    input  reg  [`SCALE_WIDTH-1:0]           i_scale_b;
    input  reg  [`MXINT8_ELEMENT_WIDTH-1:0]  i_mxint8_elements_b [`BLOCK_SIZE-1:0];
    output reg  [`SCALE_WIDTH-1:0]           o_scale;
    output reg  [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements   [`BLOCK_SIZE-1:0];
    output reg                               o_overflow;
    

    always @(*) begin
        unique casez () 

        endcase
    end

endmodule