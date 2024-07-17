
`ifndef SCALAR_FORMAT_PKG
`define SCALAR_FORMAT_PKG

package scalar_format_pkg;
    // Used to parse bfloat16 scalar
    typedef struct packed {
        logic sign;
        logic [7:0] exponent;
        logic [6:0] mantissa;
    } t_bfloat16;
    
    parameter BFLOAT16_EXPONENT_WIDTH = 8;
    parameter BFLOAT16_MANTISSA_WIDTH = 7;
    parameter BFLOAT16_WIDTH = 1 + BFLOAT16_EXPONENT_WIDTH + BFLOAT16_MANTISSA_WIDTH;

    // Used to parse float32 scalar
    typedef struct packed {
        logic sign;
        logic [7:0] exponent;
        logic [22:0] mantissa;
    } t_float32;

    parameter FLOAT32_EXPONENT_WIDTH = 8;
    parameter FLOAT32_MANTISSA_WIDTH = 23;
    parameter FLOAT32_WIDTH = 1 + FLOAT32_EXPONENT_WIDTH + FLOAT32_MANTISSA_WIDTH;

    // Used largest bit width and then parse down based on input datatype
    parameter LARGEST_FLOAT_WIDTH = FLOAT32_WIDTH;

endpackage

`endif // SCALAR_FORMAT_PKG