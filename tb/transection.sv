//`ifndef TRANSECTION__SV
//`define TRANSECTION__SV
`include "scalar_includes.v"
`include "mxint8_includes.v"

typedef reg[`MXINT8_ELEMENT_WIDTH-1:0] t_mx_int8;
typedef reg[`SCALE_WIDTH-1:0] t_scalar;

module t_mx_int8_vector(
    output t_scalar scalar,
    output t_mx_int8[0:`BLOCK_SIZE-1] elements);

    reg is_nan;
    reg [$clog2(`BLOCK_SIZE):0] zero_num;

    task post_randomize();
        zero_num = 0; 
        foreach (elements[i]) begin
          if (elements[i] == 0) begin
            zero_num++;
          end
        end
    endtask

    task randomize();
        scalar = $random() % 256;
        foreach(elements[i])
            elements[i] = $random() % 256;
        post_randomize();
    endtask

    function void set_zero(int elem_index);
        if(elements[elem_index] != 0) begin
            elements[elem_index] = 0;
            zero_num++;
        end
    endfunction

endmodule

module op_negate_int8;
    output wire [7:0] input_scalar;
    output wire [7:0] output_scalar;
    output wire [0:31][7:0] input_elements;
    output wire [0:31][7:0] output_elements;

    t_mx_int8_vector a(.scalar(input_scalar),.elements(input_elements));
    t_mx_int8_vector result(.scalar(output_scalar),.elements(output_elements));

endmodule
//`endif 