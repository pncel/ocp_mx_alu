`timescale 1ns/1ps
module mx_int8_negate_drv(
    gen_mxint8_elements,
    data_ready_o,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input wire clk;
    output wire [`MXINT8_ELEMENT_WIDTH-1:0] gen_mxint8_elements[0:`BLOCK_SIZE-1] ;
    output wire data_ready_o; 
    t_mx_int8_vector data_in(.elements(gen_mxint8_elements));
    reg rand_ready;
    reg zero_ready;
    assign data_ready_o = rand_ready || zero_ready; 
    task single_drive();
        data_in.randomize(); 
        @(posedge clk) begin
            data_in.randomize();
            #1;
            rand_ready = 1'b1;
            repeat(`BLOCK_SIZE) begin
                @(posedge clk) rand_ready = 1'b0;
            end
        end
    endtask

    task n_drive(int n);   
        repeat(n)
            single_drive();
    endtask

    task zero_drive();     
        logic [$clog2(`BLOCK_SIZE)-1:0] zero_index;  
        @(posedge clk) begin
            zero_index = $urandom() % `BLOCK_SIZE;
            data_in.randomize();
            data_in.set_zero(zero_index);
            #1;
            $display("zero element index: %d", zero_index);
            zero_ready = 1'b1; 
            repeat(`BLOCK_SIZE) begin
                @(posedge clk) zero_ready = 1'b0;
            end
        end
    endtask

    initial begin
        rand_ready = 1'b0;
        zero_ready = 1'b0; 
        n_drive(10);
        repeat(3)
            zero_drive();
        $finish();
    end
endmodule 