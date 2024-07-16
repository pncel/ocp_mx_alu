package mx_alu_isa_pkg;

    typedef enum logic [2:0] {
        DTYPE_MXINT8 = 3'b000,
        DTYPE_MXFP8_E5M2 = 3'b001,
        DTYPE_MXFP8_E4M3 = 3'b010,
        DTYPE_MXFP6_E3M2 = 3'b011,
        DTYPE_MXFP6_E2M3 = 3'b100,
        DTYPE_MXFP4_E2M1 = 3'b101
    } dtype_t;
    //needs more bits 
    typedef enum logic [2:0] {
        OP_BC = 3'b000, //broadcast
        OP_SUM = 3'b001,
        OP_NEG = 3'b010,
        OP_EXP = 3'b011,
        OP_ADD_BIAS = 3'b100,
        OP_SVMUL  = 3'b101 //Scalar-vector multiplication
        OP_ADD = 3'b110,
        OP_SUB = 3'b111,
        OP_MUL = 3'b011,
        OP_DIV = 3'b100,
        OP_DOT  = 3'b101
    } op_t;

endpackage