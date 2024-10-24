`timescale 1ns/1ps
module mx_int8_sum_drv #(
    parameter int N = 5, //each case repeat times
    parameter int CYCLE = 100
    )(
    scale_drv,
    mxint8_elements_drv,
    clk
);
    localparam int half = CYCLE/2; 
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input  wire clk;
    output wire[`SCALE_WIDTH-1:0]            scale_drv;
    output wire[`MXINT8_ELEMENT_WIDTH-1:0]   mxint8_elements_drv [`BLOCK_SIZE-1:0];

    t_mx_int8_vector vector_in(.scale(scale_drv),
                               .elements(mxint8_elements_drv));
    /*
    assign scale_drv = vector_in.scale;
    genvar i;
    generate
        for(i = 0 ; i < `BLOCK_SIZE; i = i+1)
            assign mxint8_elements_drv[i]  = vector_in.elements[i];
    endgenerate*/
    
    function void normal_case();
        vector_in.randomize();
    endfunction
    function void positive_case();
        vector_in.randomize();
        vector_in.set_all_positive();
    endfunction
    function void negative_case();
        vector_in.set_all_negative();
    endfunction
    function void small_case();
        vector_in.randomize();
        vector_in.set_all_small_elements();
    endfunction
    function void big_case();
        vector_in.randomize();
        vector_in.set_all_big_elements();
    endfunction
    function void all_zero_case();
        vector_in.randomize();
        vector_in.set_all_zero();
    endfunction
    function void single_zero_case();
        vector_in.randomize();
        vector_in.set_zero($random() % `BLOCK_SIZE);
    endfunction
    function void all_nan_case();
        vector_in.randomize();
        vector_in.set_all_unused_code();
    endfunction
    function void single_nan_case();
        vector_in.randomize();
        vector_in.set_unused_encode($random() % `BLOCK_SIZE);
    endfunction

    function void positive_carry_case_p(int big_positive_num, int is_small_scale);
        vector_in.randomize();
        vector_in.set_sum_positive_carry(big_positive_num,is_small_scale);//no overflow
    endfunction
    function void positive_carry_case();
        positive_carry_case_p(10,20);
    endfunction
    function void positive_overflow_case();
        positive_carry_case_p(20,2);
    endfunction
    function void positive_overflow_max_case();
        positive_carry_case_p(`BLOCK_SIZE,1);
    endfunction
    function void positive_overflow_scale_nan();
        positive_carry_case_p(11,0);
    endfunction
    function void positive_carry_max_case();
        positive_carry_case_p(`BLOCK_SIZE,100);
    endfunction

    function void negative_carry_case_p(int big_positive_num, int is_small_scale);
        vector_in.randomize();
        vector_in.set_sum_negative_carry(big_positive_num,is_small_scale);//no overflow
    endfunction
    function void negative_carry_case();
        negative_carry_case_p(15,40);
    endfunction
    function void negative_overflow_case();
        negative_carry_case_p(25,3);
    endfunction
    function void negative_overflow_max_case();
        negative_carry_case_p(`BLOCK_SIZE,1);
    endfunction
    function void negative_overflow_scale_nan();
        negative_carry_case_p(21,0);
    endfunction
    function void negative_carry_max_case();
        negative_carry_case_p(`BLOCK_SIZE,120);
    endfunction

    function void scale_nan_case();
        vector_in.randomize();
        vector_in.set_largest_scale();
    endfunction
    function void scale_nan_unusedcode_case();
        vector_in.randomize();
        vector_in.set_largest_scale();
        vector_in.set_unused_encode($random() % `BLOCK_SIZE);
    endfunction

    initial begin
        
        $display("normal_case");
        repeat(5*N) begin
            @(posedge clk) begin
                normal_case();
            end
        end 
        
        #(half+1) $display("all positive number case");
        repeat(N) begin
            @(posedge clk) begin
                positive_case();
            end
        end
        #(half+1) $display("all negative number case");
        repeat(N) begin
            @(posedge clk) begin
                negative_case();
            end
        end
        #(half+1) $display("all small absolute value int8 case");
        repeat(N) begin
            @(posedge clk) begin
                small_case();
            end
        end
        #(half+1) $display("all big absolute value int8 case");
        repeat(N) begin
            @(posedge clk) begin
                big_case();
            end
        end
        #(half+1) $display("all zero value case");
        repeat(N) begin
            @(posedge clk) begin
                all_zero_case();
            end
        end
        #(half+1) $display("1 random 0 case");
        repeat(N) begin
            @(posedge clk) begin
                single_zero_case();
            end
        end
        #(half+1) $display("all int8 1000_0000 case");
        repeat(N) begin
            @(posedge clk) begin
                all_nan_case();
            end
        end
        #(half+1) $display("1 int8 1000_0000 case");
        repeat(N) begin
            @(posedge clk) begin
                single_nan_case();
            end
        end
        #(half+1) $display("positive carry case");
        repeat(N) begin
            @(posedge clk) begin
                positive_carry_case();
            end
        end
        #(half+1) $display("lagest positive carry");
        repeat(N) begin
            @(posedge clk) begin
                positive_carry_max_case();
            end
        end
        #(half+1) $display("positive number overflow");
        repeat(N) begin
            @(posedge clk) begin
                positive_overflow_case();
            end
        end
        #(half+1) $display("positive overflow with largest carry");
        repeat(N) begin
            @(posedge clk) begin
                positive_overflow_max_case();
            end
        end
        #(half+1) $display("positive overflow with int8 1000_0000");
        repeat(N) begin
            @(posedge clk) begin
                positive_overflow_scale_nan();
            end
        end
    #(half+1) $display("negative carry case");
        repeat(N) begin
            @(posedge clk) begin
                negative_carry_case();
            end
        end
        #(half+1) $display("lagest negative carry");
        repeat(N) begin
            @(posedge clk) begin
                negative_carry_max_case();
            end
        end
        #(half+1) $display("negative number overflow");
        repeat(N) begin
            @(posedge clk) begin
                negative_overflow_case();
            end
        end
        #(half+1) $display("negative overflow with largest carry");
        repeat(N) begin
            @(posedge clk) begin
                negative_overflow_max_case();
            end
        end
        #(half+1) $display("negative overflow with int8 1000_0000");
        repeat(N) begin
            @(posedge clk) begin
                negative_overflow_scale_nan();
            end
        end
        #(half+1) $display("scale 1111_1111 nan case");
        repeat(N) begin
            @(posedge clk) begin
                scale_nan_case();
            end
        end
        #(half+1) $display("scale 1111_1111 and int8 have 1000_0000 case");
        repeat(N) begin
            @(posedge clk) begin
                scale_nan_unusedcode_case();
            end
        end
        $finish();
    end
endmodule 