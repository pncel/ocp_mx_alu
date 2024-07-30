
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

    // parse input bits into float structures
    t_bfloat16 bfloat16;
    t_float32 float32;

    always_comb begin : scalar_parser
        unique casez (scalar_datatype)
            BFLOAT16: begin
                // bfloat16.mantissa = scalar_in[6:0];
                // bfloat16.exponent = scalar_in[14:7];
                // bfloat16.sign = scalar_in[15];
                bfloat16 = t_bfloat16'(scalar_in[15:0]);
                float32 = t_float32'('0);
            end
            FLOAT32: begin
                bfloat16 = t_bfloat16'('0);
                // float32.mantissa = scalar_in[22:0];
                // float32.exponent = scalar_in[30:23];
                // float32.sign = scalar_in[31];
                float32 = t_float32'(scalar_in[31:0]);
            end
            default: begin
                bfloat16 = '0;
                float32 = '0;
            end
        endcase
    end

    // parse input bits into vector structures
    t_mxfp8_e5m2_vector mxfp8_e5m2_vector;
    t_mxfp8_e4m3_vector mxfp8_e4m3_vector;
    t_mxfp6_e3m2_vector mxfp6_e3m2_vector;
    t_mxfp6_e2m3_vector mxfp6_e2m3_vector;
    t_mxfp4_e2m1_vector mxfp4_e2m1_vector;
    t_mxint8_vector mxint8_vector;

    generate 
        always_comb begin : vector_parser
            unique casez (vector_datatype)
                MXFP8_E5M2: begin
                    
                end
                MXFP8_E4M3: begin
                    
                end
                MXFP6_E3M2: begin
                    
                end
                MXFP6_E2M3: begin
                    
                end
                MXFP4_E2M1: begin
                    
                end
                MXINT8: begin

                end
                default: begin

                end
            endcase
        end
    endgenerate


endmodule
