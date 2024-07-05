
package mx_format_pkg;

    // Used to parse FP8 E5M2 elements
    typedef struct packed {
        logic sign;
        logic [4:0] exponent;
        logic [1:0] mantissa;
    } mxfp8_e5m2_element;

    // Used to parse FP8 E4M3 elements
    typedef struct packed {
        logic sign;
        logic [3:0] exponent;
        logic [2:0] mantissa;
    } mxfp8_e4m3_element;

    parameter MXFP8_ELEMENT_BITS = 8;

    // Used to parse FP6 E3M2 elements
    typedef struct packed {
        logic sign;
        logic [2:0] exponent;
        logic [1:0] mantissa;
    } mxfp6_e3m2_element;

    // Used to parse FP6 E2M3 elements
    typedef struct packed {
        logic sign;
        logic [1:0] exponent;
        logic [2:0] mantissa;
    } mxfp6_e2m3_element;

    parameter MXFP6_ELEMENT_BITS = 6;

    // Used to parse FP6 E2M1 elements
    typedef struct packed {
        logic sign;
        logic [1:0] exponent;
        logic mantissa;
    } mxfp4_e2m1_element;

    parameter MXFP4_ELEMENT_BITS = 4;

    // Used to parse INT8 elements
    typedef struct packed {
        // logic sign;
        // logic [3:0] exponent;
        // logic [6:0] mantissa;
        logic signed [7:0] int8;
    } mxint8_element;

    parameter MXINT8_ELEMENT_BITS = 8;

    typedef struct packed {
        logic [7:0] exponent;
    } mx_scale_data;

    parameter MX_SCALE_DATA_BITS = 8;

    parameter SCALING_BLOCK_SIZE = 32; 

    typedef struct {
        mx_scale_data scale;
        mxfp8_e5m2_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxfp8_e5m2_vector;

    typedef struct {
        mx_scale_data scale;
        mxfp8_e4m3_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxfp8_e4m3_vector;

    parameter MXFP8_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP8_ELEMENT_BITS * SCALING_BLOCK_SIZE;
    
    typedef struct {
        mx_scale_data scale;
        mxfp6_e3m2_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxfp6_e3m2_vector;

    typedef struct {
        mx_scale_data scale;
        mxfp6_e2m3_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxfp6_e2m3_vector;

    parameter MXFP6_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP6_ELEMENT_BITS * SCALING_BLOCK_SIZE;
    
    typedef struct {
        mx_scale_data scale;
        mxfp4_e2m1_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxfp4_e2m1_vector;

    parameter MXFP4_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP4_ELEMENT_BITS * SCALING_BLOCK_SIZE;

    typedef struct {
        mx_scale_data scale;
        mxint8_element [SCALING_BLOCK_SIZE-1:0] elements;
    } mxint8_vector;

    parameter MXINT8_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXINT8_ELEMENT_BITS * SCALING_BLOCK_SIZE;

endpackage

