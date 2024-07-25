
`ifndef ALU_OP_PKG__SV
`define ALU_OP_PKG__SV

package alu_op_pkg;

    // Defined enum for ALU opcode
    typedef enum { 
        SCALAR_BROADCAST_VECTOR,
        VECTOR_SUM_SCALAR,
        VECTOR_NEGATE_VECTOR,
        SCALAR_VECTOR_ADD_VECTOR,
        VECTOR_VECTOR_ADD_VECTOR,
        VECTOR_VECTOR_SUB_VECTOR,
        VECTOR_VECTOR_MUL_VECTOR,
        VECTOR_DOT_SCALAR
    } t_opcode;

    // Defined datatype of input vectors
    typedef enum { 
        MXFP8_E5M2,
        MXFP8_E4M3,
        MXFP6_E3M2,
        MXFP6_E2M3,
        MXFP4_E2M1,
        MXINT8
    } t_vector_datatype;

    // Defined datatype of input scalar
    typedef enum { 
        BFLOAT16,
        FLOAT32
    } t_scalar_datatype;

endpackage

`endif // ALU_OP_PKG