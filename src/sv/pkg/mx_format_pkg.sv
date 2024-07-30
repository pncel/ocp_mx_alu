
`ifndef MX_FORMAT_PKG
`define MX_FORMAT_PKG

package mx_format_pkg;

    // Used to parse FP8 E5M2 elements
    typedef struct packed {
        logic sign;
        logic [4:0] exponent;
        logic [1:0] mantissa;
    } t_mxfp8_e5m2_element;

    // Used to parse FP8 E4M3 elements
    typedef struct packed {
        logic sign;
        logic [3:0] exponent;
        logic [2:0] mantissa;
    } t_mxfp8_e4m3_element;

    parameter MXFP8_ELEMENT_BITS = 8;

    // Used to parse FP6 E3M2 elements
    typedef struct packed {
        logic sign;
        logic [2:0] exponent;
        logic [1:0] mantissa;
    } t_mxfp6_e3m2_element;

    // Used to parse FP6 E2M3 elements
    typedef struct packed {
        logic sign;
        logic [1:0] exponent;
        logic [2:0] mantissa;
    } t_mxfp6_e2m3_element;

    parameter MXFP6_ELEMENT_BITS = 6;

    // Used to parse FP4 E2M1 elements
    typedef struct packed {
        logic sign;
        logic [1:0] exponent;
        logic mantissa;
    } t_mxfp4_e2m1_element;

    parameter MXFP4_ELEMENT_BITS = 4;

    // Used to parse INT8 elements
    typedef logic signed [7:0] t_mxint8_element;

    parameter MXINT8_ELEMENT_BITS = 8;

    // Used to parse the block scale
    typedef logic signed [7:0] t_mx_scale_data;

    parameter MX_SCALE_DATA_BITS = 8;

    // Defined by OCP Microscale specification
    parameter SCALING_BLOCK_SIZE = 32; 

    // Used to parse the MXFP8 E5M2 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxfp8_e5m2_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxfp8_e5m2_vector;

    // Used to parse the MXFP8 E4M3 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxfp8_e4m3_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxfp8_e4m3_vector;

    parameter MXFP8_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP8_ELEMENT_BITS * SCALING_BLOCK_SIZE;
    
    // Used to parse the MXFP6 E3M2 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxfp6_e3m2_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxfp6_e3m2_vector;

    // Used to parse the MXFP6 E2M3 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxfp6_e2m3_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxfp6_e2m3_vector;

    parameter MXFP6_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP6_ELEMENT_BITS * SCALING_BLOCK_SIZE;
    
    // Used to parse the MXFP4 E2M1 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxfp4_e2m1_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxfp4_e2m1_vector;

    parameter MXFP4_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXFP4_ELEMENT_BITS * SCALING_BLOCK_SIZE;

    // Used to parse the MXINT8 vector
    typedef struct {
        t_mx_scale_data scale;
        t_mxint8_element [SCALING_BLOCK_SIZE-1:0] elements;
    } t_mxint8_vector;

    parameter MXINT8_VECTOR_SIZE = MX_SCALE_DATA_BITS + MXINT8_ELEMENT_BITS * SCALING_BLOCK_SIZE;

    // Used largest bit width and then parse down based on input datatype
    parameter LARGEST_VECTOR_SIZE = MXINT8_VECTOR_SIZE;

endpackage

`endif //MX_FORMAT_PKG