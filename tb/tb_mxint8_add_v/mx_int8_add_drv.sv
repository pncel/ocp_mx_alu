`timescale 1ns/1ps
module mx_int8_add_drv #(
    parameter int N = 5, //each case repeat times
    parameter int CYCLE = 100
    )(
    scale_a_drv,
    scale_b_drv,
    mxint8_elements_a_drv,
    mxint8_elements_b_drv,
    clk
);
    localparam int half = CYCLE/2; 
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input  wire clk;
    output wire[`SCALE_WIDTH-1:0]            scale_a_drv;
    output wire[`SCALE_WIDTH-1:0]            scale_b_drv;
    output wire[`MXINT8_ELEMENT_WIDTH-1:0]   mxint8_elements_a_drv [`BLOCK_SIZE-1:0];
    output wire[`MXINT8_ELEMENT_WIDTH-1:0]   mxint8_elements_b_drv [`BLOCK_SIZE-1:0];

    t_mx_int8_vector vector_in_a(.scale(scale_a_drv),
                               .elements(mxint8_elements_a_drv));
    t_mx_int8_vector vector_in_b(.scale(scale_b_drv),
                               .elements(mxint8_elements_b_drv));

    function void normal_case();
        vector_in_a.randomize();
        vector_in_b.randomize();
    endfunction
    function void positive_case();
        vector_in_a.randomize();
        vector_in_a.set_all_positive();
        vector_in_b.randomize();
        vector_in_b.set_all_positive();
    endfunction
    function void negative_case();
        vector_in_a.randomize();
        vector_in_a.set_all_negative();
        vector_in_b.randomize();
        vector_in_b.set_all_negative();
    endfunction
    function void small_case();
        vector_in_a.randomize();
        vector_in_a.set_all_small_elements();
        vector_in_a.set_small_scale();
        vector_in_b.randomize();
        vector_in_b.set_all_small_elements();
        vector_in_b.set_small_scale();
    endfunction
    function void big_case();
        vector_in_a.randomize();
        vector_in_a.set_all_big_elements();
        vector_in_b.randomize();
        vector_in_b.set_all_big_elements();
    endfunction
    function void all_zero_case();
        vector_in_a.randomize();
        vector_in_a.set_all_zero();
        vector_in_b.randomize();
        vector_in_b.set_all_zero();
    endfunction
    function void single_zero_case();
        vector_in_a.randomize();
        vector_in_a.set_zero($random() % `BLOCK_SIZE);
        vector_in_b.randomize();
        vector_in_b.set_zero($random() % `BLOCK_SIZE);
    endfunction
    function void all_nan_case();
        vector_in_a.randomize();
        vector_in_a.set_all_unused_code();//? unused_code is not nan?
        vector_in_b.randomize();
        vector_in_b.set_all_unused_code();
    endfunction
    function void single_nan_case();
        vector_in_a.randomize();
        vector_in_a.set_unused_encode($random() % `BLOCK_SIZE);
        vector_in_b.randomize();
        vector_in_b.set_unused_encode($random() % `BLOCK_SIZE);
    endfunction

   
    function void positive_overflow_case();
        vector_in_a.set_big_positive(3);
        vector_in_b.set_big_positive(2);
    endfunction
    // function void positive_overflow_max_case();
    //     positive_carry_case_p(`BLOCK_SIZE,1);
    // endfunction
    // function void positive_overflow_scale_nan();
    //     positive_carry_case_p(11,0);
    // endfunction
    // function void positive_carry_max_case();
    //     positive_carry_case_p(`BLOCK_SIZE,100);
    // endfunction

    // 
    function void negative_overflow_case();
        vector_in_a.set_big_negative(4);
        vector_in_b.set_big_negative(5);
    endfunction
    
    // function void scale_nan_case();
    //     vector_in.randomize();
    //     vector_in.set_largest_scale();
    // endfunction

    // function void scale_nan_unusedcode_case();
    //     vector_in.randomize();
    //     vector_in.set_largest_scale();
    //     vector_in.set_unused_encode($random() % `BLOCK_SIZE);
    // endfunction

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
        repeat(20*N) begin
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
        // #(half+1) $display("positive carry case");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         positive_carry_case();
        //     end
        // end
        // #(half+1) $display("lagest positive carry");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         positive_carry_max_case();
        //     end
        // end
        #(half+1) $display("positive number overflow");
        repeat(N) begin
            @(posedge clk) begin
                positive_overflow_case();
            end
        end
        // #(half+1) $display("positive overflow with largest carry");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         positive_overflow_max_case();
        //     end
        // end
        // #(half+1) $display("positive overflow with int8 1000_0000");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         positive_overflow_scale_nan();
        //     end
        // end
        // #(half+1) $display("negative carry case");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         negative_carry_case();
        //     end
        // end
        // #(half+1) $display("lagest negative carry");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         negative_carry_max_case();
        //     end
        // end
        #(half+1) $display("negative number overflow");
        repeat(N) begin
            @(posedge clk) begin
                negative_overflow_case();
            end
        end
        // #(half+1) $display("negative overflow with largest carry");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         negative_overflow_max_case();
        //     end
        // end
        // #(half+1) $display("negative overflow with int8 1000_0000");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         negative_overflow_scale_nan();
        //     end
        // end
        // #(half+1) $display("scale 1111_1111 nan case");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         scale_nan_case();
        //     end
        // end
        // #(half+1) $display("scale 1111_1111 and int8 have 1000_0000 case");
        // repeat(N) begin
        //     @(posedge clk) begin
        //         scale_nan_unusedcode_case();
        //     end
        // end
        $finish();
    end
endmodule 