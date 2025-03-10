`include "scalar_includes.v"
`include "mxint8_includes.v"
//under `BLOCK_SIZE = 32, INT8 condition
`define INT8_MANTISSA_EXT  13 //($clog2(`BLOCK_SIZE)+2)+6
module mx_int8_sum_ref (
    i_scale,
    i_mxint8_elements,
    o_float32,
    o_overflow
);

    input  reg [`SCALE_WIDTH-1:0]            i_scale;
    input  reg [`MXINT8_ELEMENT_WIDTH-1:0]   i_mxint8_elements [`BLOCK_SIZE-1:0];
    output reg [`FLOAT32_WIDTH-1:0]          o_float32;
    output reg                               o_overflow;

    wire [`INT8_MANTISSA_EXT-1:0] pos_2;
    wire [`INT8_MANTISSA_EXT-1:0] neg_2;
    assign pos_2 = `INT8_MANTISSA_EXT'b000_0001_000000;
    assign neg_2 = (~pos_2) + 1'b1;
    reg [`INT8_MANTISSA_EXT-1:0] neg_sum;
    reg [`INT8_MANTISSA_EXT-1:0] pos_sum;
    always@(*) begin
       // neg_sum <= cal_neg_sum(i_mxint8_elements);
        neg_sum = 0;
        foreach(i_mxint8_elements[i]) begin
            if(i_mxint8_elements[i][`SCALE_WIDTH-1]);
                neg_sum = neg_sum + neg_2; 
        end
    end
    always@(*) begin
        //pos_sum <= cal_pos_sum(i_mxint8_elements);
        pos_sum = 0;
        foreach(i_mxint8_elements[i]) begin
            pos_sum = pos_sum + i_mxint8_elements[i][`SCALE_WIDTH-2:0]; 
        end
    end
    wire [`INT8_MANTISSA_EXT-1:0] sum;
    assign sum = pos_sum + neg_sum;
    reg sum_sign;
    reg [`INT8_MANTISSA_EXT-1:0] sum_abs;
    reg [`INT8_MANTISSA_EXT-`MXINT8_ELEMENT_WIDTH-1:0] scale_carry;
    reg [`FLOAT32_MANTISSA_WIDTH-1:0] float32_mantissa;
    reg carry_flag;
    always@(sum) begin
        sum_decode(sum,sum_sign,sum_abs);
        sum_encode(sum_abs,scale_carry,float32_mantissa,carry_flag);
    end
    always@(*) begin
        if(|float32_scale)
            float32_mantissa <= float32_mantissa;
        else
            float32_mantissa <= {carry_flag,float32_mantissa[`FLOAT32_MANTISSA_WIDTH-1:1]};
    end
    reg [`SCALE_WIDTH:0] scale;
    assign scale = scale + scale_carry;
    reg overflow;
    always@(*) begin
        if(&i_scale)
            overflow <= 1'b0;
        else if(scale[`SCALE_WIDTH] || (&scale[`SCALE_WIDTH-1:0]))
            overflow <= 1'b1;
        else 
            overflow <= 1'b0;
    end
    assign o_overflow = overflow;
    reg [`SCALE_WIDTH-1:0] float32_scale;
    always@(*) begin
        if(&i_scale)
            float32_scale = i_scale;
        else if(scale[`SCALE_WIDTH] || (&scale[`SCALE_WIDTH-1:0]))
            float32_scale <= `SCALE_WIDTH'b1111_1111;
        else 
            float32_scale <= scale[`SCALE_WIDTH-2:0];
    end
    assign o_float32 = {sum_sign,float32_scale,float32_mantissa};
    /*
    function [`INT8_MANTISSA_EXT-1:0] cal_neg_sum(input[`MXINT8_ELEMENT_WIDTH-1:0]   elements [`BLOCK_SIZE-1:0]);
        cal_neg_sum = 0;
        foreach(elements[i]) begin
            if(elements[i][`SCALE_WIDTH-1]);
                cal_neg_sum = cal_neg_sum + neg_2; 
        end
    endfunction
    function [`INT8_MANTISSA_EXT-1:0] cal_pos_sum(input[`MXINT8_ELEMENT_WIDTH-1:0]   elements [`BLOCK_SIZE-1:0]);
        cal_pos_sum = 0;
        foreach(elements[i]) begin
            cal_pos_sum = cal_pos_sum + elements[i][`SCALE_WIDTH-2:0]; 
        end
    endfunction
    */
    task sum_decode (input [`INT8_MANTISSA_EXT-1:0] sum,
                     output  sum_sign,
                     output [`INT8_MANTISSA_EXT-1:0] sum_abs);
        if(sum[`INT8_MANTISSA_EXT-1]) begin
            sum_sign = 1'b1;
            sum_abs = (~sum) + 1'b1;
        end
        else begin
            sum_sign = 1'b0;
            sum_abs = sum; 
        end
    endtask
    task  sum_encode(input [`INT8_MANTISSA_EXT-1:0] sum_abs,
                         output [`INT8_MANTISSA_EXT-`MXINT8_ELEMENT_WIDTH-1:0] carry_num,
                         output [`FLOAT32_MANTISSA_WIDTH-1:0] float32_mantissa,
                         output carry_flag);
        float32_mantissa = {sum_abs,10'd0} ;  //`FLOAT32_MANTISSA_WIDTH-`INT8_MANTISSA_EXT=10
        carry_flag = 0;
        carry_num = 0;
        for(int i = 0; i < `INT8_MANTISSA_EXT - `MXINT8_ELEMENT_WIDTH; i = i+1) begin
            if(carry_flag)
                carry_num = carry_num + 1'b1;
            if(float32_mantissa[`FLOAT32_MANTISSA_WIDTH-1]) 
                carry_flag = 1'b1;
            else
                float32_mantissa = {float32_mantissa[`FLOAT32_MANTISSA_WIDTH-2:0],1'b0};
        end
        float32_mantissa = float32_mantissa<<1'b1;
    endtask
endmodule