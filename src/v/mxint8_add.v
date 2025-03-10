
module mxint8_add (
    i_scale_a,
    i_mxint8_elements_a,
    i_scale_b,
    i_mxint8_elements_b,
    o_scale,
    o_mxint8_elements,
    o_overflow,
    o_is_unused,
    max_abs_value,
    normalize_shift,
    temp_add_result,
    i_mxint8_elements_a_temp,
    i_mxint8_elements_b_temp
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    `define BLOCK_SIZE 32
    
    input  wire [`SCALE_WIDTH-1:0]           i_scale_a;
    input  wire [`MXINT8_ELEMENT_WIDTH-1:0]  i_mxint8_elements_a [`BLOCK_SIZE-1:0];
    input  wire [`SCALE_WIDTH-1:0]           i_scale_b;
    input  wire [`MXINT8_ELEMENT_WIDTH-1:0]  i_mxint8_elements_b [`BLOCK_SIZE-1:0];
    output reg  [`SCALE_WIDTH-1:0]           o_scale;
    output reg  [`MXINT8_ELEMENT_WIDTH-1:0]  o_mxint8_elements   [`BLOCK_SIZE-1:0];
    output reg                               o_overflow;
    output reg                               o_is_unused;//For the unused case 10000000
    
    
    
   
    reg [7:0] shift_a,shift_b;
    output reg signed [9:0] normalize_shift;
    output reg signed [23:0] temp_add_result [`BLOCK_SIZE-1:0];
    reg [23:0] abs_value;
    reg [23:0] lower_bits;
    output reg [23:0] max_abs_value;
    output reg signed [23:0] i_mxint8_elements_a_temp [`BLOCK_SIZE-1:0];
    output reg signed [23:0] i_mxint8_elements_b_temp [`BLOCK_SIZE-1:0];

    always @(*)begin
        integer i;
        max_abs_value = 0;
        normalize_shift = 0;
        o_scale = (i_scale_a > i_scale_b) ? i_scale_b : i_scale_a;
        shift_a = i_scale_a - o_scale;
        shift_b = i_scale_b - o_scale;
        $display("shift_a = %d",shift_a);
        $display("shift_b = %d",shift_b);
        for(i = 0; i<`BLOCK_SIZE ;i=i+1)
            o_mxint8_elements[i] = 8'd0;
        //if the difference between i_scale_a and i_scale_b is too large, 
        //the smaller element will be trivial
        if( shift_a >= 4'd14 || shift_b >= 4'd14 )begin
            for(i = 0; i < `BLOCK_SIZE; i=i+1)begin
                //ni need for loop
                o_mxint8_elements[i] = (i_scale_a > i_scale_b) ? i_mxint8_elements_a[i] : i_mxint8_elements_b[i];
                o_scale = (i_scale_a > i_scale_b) ? i_scale_a : i_scale_b;
            end
        end
        else begin
            for(i = 0; i < `BLOCK_SIZE; i=i+1)begin

                i_mxint8_elements_a_temp[i] = ($signed(i_mxint8_elements_a[i]) << shift_a);
                i_mxint8_elements_b_temp[i] = ($signed(i_mxint8_elements_b[i]) << shift_b);

                // temp_add_result = {{(16-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_a[i][`MXINT8_ELEMENT_WIDTH-1]}},i_mxint8_elements_a[i]} + {{(16-`MXINT8_ELEMENT_WIDTH){i_mxint8_elements_b[i][`MXINT8_ELEMENT_WIDTH-1]}},i_mxint8_elements_b[i]};
                temp_add_result[i] = i_mxint8_elements_a_temp[i] + i_mxint8_elements_b_temp[i];
                
                // find max abs(temp_add_result) to shift o_scale
                abs_value = temp_add_result[i][23] ? -temp_add_result[i] : temp_add_result[i];
                max_abs_value = ( abs_value > max_abs_value) ? abs_value : max_abs_value;
              
            end
        
            casez(max_abs_value)
                24'b01??_????_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd16) ? 16 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b001?_????_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd15) ? 15 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0001_????_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd14) ? 14 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_1???_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd13) ? 13 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_01??_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd12) ? 12 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_001?_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd11) ? 11 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0001_????_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale > 5'd10) ? 10 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_1???_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd9) ?  9 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_01??_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd8) ?  8 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_001?_????_????_????:begin 
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd7) ?  7 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0001_????_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd6) ?  6 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_1???_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd5) ?  5 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_01??_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd4) ?  4 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_001?_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd3) ?  3 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_0001_????_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd2) ?  2 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_0000_1???_????:begin
                    normalize_shift = (`SHARED_SCALE_MAX - o_scale >  5'd1) ?  1 : `SHARED_SCALE_MAX - o_scale;
                end
                24'b0000_0000_0000_0000_01??_????:begin
                    normalize_shift = 0 ;
                end
                24'b0000_0000_0000_0000_001?_????:begin
                    normalize_shift = (          o_scale >  5'd0         ) ?  -1 :  - o_scale;
                end
                24'b0000_0000_0000_0000_0001_????:begin
                    normalize_shift = (          o_scale >  5'd1         ) ?  -2 :  - o_scale;
                end
                24'b0000_0000_0000_0000_0000_1???:begin
                    normalize_shift = (          o_scale >  5'd2         ) ?  -3 :  - o_scale;
                end
                24'b0000_0000_0000_0000_0000_01??:begin
                    normalize_shift = (          o_scale >  5'd3         ) ?  -4 :  - o_scale;
                end
                24'b0000_0000_0000_0000_0000_001?:begin
                    normalize_shift = (          o_scale >  5'd4         ) ?  -5 :  - o_scale;
                end
                24'b0000_0000_0000_0000_0000_0001:begin
                    normalize_shift = (          o_scale >  5'd5         ) ?  -6 :  - o_scale;
                end
                default: begin
                    normalize_shift = 0;
                end
            endcase
                    
            o_scale = o_scale + normalize_shift;
            lower_bits = (normalize_shift >= 2'd2) ? ( 1 << (normalize_shift-2'd2) ) - 1'd1 : 'b0;
            for(i = 0; i < `BLOCK_SIZE; i=i+1)begin
                if(normalize_shift < 0) begin // shift left
                    o_mxint8_elements[i] = (temp_add_result[i] << (- normalize_shift));
                end
                //shift o_mxint8_elements right and increace o_scale
                else if ($signed(temp_add_result[i] >>> normalize_shift) <= 8'sb01111111 && $signed(temp_add_result[i] >>> normalize_shift) >= 8'sb10000001) begin
                    
                    // ******************************** round to even ********************************
                    
                    if ( ((temp_add_result[i][normalize_shift-1]) & (|(temp_add_result[i] & lower_bits))) 
                        | ((temp_add_result[i][normalize_shift]) & (temp_add_result[i][normalize_shift-1]) )) begin
                        o_mxint8_elements[i] = (temp_add_result[i] >>> normalize_shift) + 1'b1;
                    end
                    else begin
                        o_mxint8_elements[i] = temp_add_result[i] >>> normalize_shift;
                        
                    end

                    //********************************************************************************
                end
                else begin //clamp
                    o_mxint8_elements[i] = ($signed(temp_add_result[i] >>> normalize_shift) > 8'd127) ? 8'b01111111 : 8'b10000001;
                    
                end

            end
        end

    end
    

endmodule