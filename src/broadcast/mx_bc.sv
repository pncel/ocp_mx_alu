//`include "../pkg/alu_core_pkg.sv";

module mx_bc 
import alu_core_pkg::*; #(
    parameter K = SCALING_BLOCK_SIZE //vector depth 
) (
    input t_scalar_datatype scalar_datatype,
    input logic [LARGEST_FLOAT_WIDTH-1:0] scalar_in,
    output logic [LARGEST_VECTOR_SIZE-1:0] vector_out
);
    logic [15:0] scalar_e8int8;

    always_comb begin 
        case(scalar_datatype)
            BFLOAT16: scalar_e8int8 = bf16_RNE_int8(scalar_in[15:0]);
            FLOAT32: scalar_e8int8 = bf16_RNE_int8(fp32_RNE_bf16(scalar_in));
        endcase
    end
    //
    
    vector_out[MX_SCALE_DATA_BITS-1:0] <= scalar_e8int8[15 -: MX_SCALE_DATA_BITS];
    genvar i; //parallel broadcast
    generate
        for (i = 0; i < K; i = i+1) begin
            vector_out[(i+1)*MXINT8_ELEMENT_BITS+MX_SCALE_DATA_BITS-:MXINT8_ELEMENT_BITS] <= scalar_e8int8[0+:MXINT8_ELEMENT_BITS];
        end
    endgenerate
endmodule