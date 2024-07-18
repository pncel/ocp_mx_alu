
`ifndef MX_FUNCTION_PKG
`define MX_FUNCTION_PKG

package mx_function_pkg;

    import mx_format_pkg::*;

    function automatic logic [7:0] f_int8_find_largest_value (t_mxfp8_e5m2_vector vector);

    endfunction

endpackage

`endif // MX_FUNCTION_PKG