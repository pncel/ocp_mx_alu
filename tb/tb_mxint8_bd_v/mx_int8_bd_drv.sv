`timescale 1ns/1ps
module mx_int8_bd_drv(
    gen_float32,
    data_ready_o,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input wire clk;
    output [`FLOAT32_WIDTH-1:0] gen_float32;  //same as float in c 
    output data_ready_o; 

    t_fp32_scalar data_in(.f(gen_float32));
    reg rand_ready;
    reg carry_ready;
    reg tie_ready;
    reg overflow_ready;
    reg sub_normal_ready;
    reg scalar_overflow_ready;
    reg NaN_ready; 
    assign data_ready_o = rand_ready || tie_ready || carry_ready|| overflow_ready|| sub_normal_ready|| scalar_overflow_ready|| NaN_ready ; 
    task single_drive();
        data_in.randomize(); 
        @(posedge clk) begin
            data_in.randomize();
            #1;
            rand_ready = 1'b1;
        end
        @(posedge clk) rand_ready = 1'b0;
    endtask

    task n_drive(int n);   
        data_in.set_sign(1'b0);
        repeat(n)
            single_drive();
        data_in.set_sign(1'b1);
        repeat(n)
            single_drive();
    endtask

    task carry_drive();     
        data_in.set_sign(1'b0);
        data_in.set_carry(1'b1);
        repeat(2) begin
            @(posedge clk) begin 
                data_in.randomize();
                #1;
                carry_ready = 1'b1; 
            end
            @(posedge clk) carry_ready = 1'b0;
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task tie_drive();     
        data_in.set_sign(1'b0);
        repeat(4) begin
            @(posedge clk) begin 
                data_in.set_tie2even();
                data_in.randomize();
                #1;
                tie_ready = 1'b1; 
            end
            @(posedge clk) tie_ready = 1'b0;
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task overflow_drive();     
        data_in.set_sign(1'b0);
        data_in.set_overflow(1'b1);
        repeat(2) begin
            @(posedge clk) begin                
                data_in.randomize();
                #1;
                overflow_ready = 1'b1; 
            end
            @(posedge clk) overflow_ready = 1'b0;
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task scalar_overflow_drive();     
        data_in.set_sign(1'b0);
        data_in.set_scalar_overflow(1'b1);
        repeat(2) begin
            @(posedge clk) begin                
                data_in.randomize();
                #1;
                scalar_overflow_ready = 1'b1; 
            end
            @(posedge clk) scalar_overflow_ready = 1'b0;
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task NaN_drive();  
        data_in.set_NaN(1'b1);  
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin 
                data_in.randomize();
                #1;
                NaN_ready = 1'b1;                 
            end
            @(posedge clk) NaN_ready = 1'b0;
            data_in.set_sign(1'b1); 
        end
        $display("NaN carry");
        carry_drive();
        data_in.set_NaN(1'b1);
        $display("NaN overflow"); 
        overflow_drive();
        data_in.set_clean();
    endtask
    task sub_normal_drive();  
        data_in.set_clean();  
        data_in.sub_normal = 1'b1; 
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin       
                data_in.randomize();
                #1;
                sub_normal_ready = 1'b1; 
                @(posedge clk) sub_normal_ready  = 1'b0;
            end
            data_in.set_sign(1'b1); 
        end
        data_in.set_carry(1'b1); 
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin 
                data_in.sub_normal = 1'b1;
                data_in.randomize();
                #1;
                sub_normal_ready = 1'b1; 
                @(posedge clk) sub_normal_ready = 1'b0;
            end
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    initial begin
        rand_ready = 1'b0;
        tie_ready = 1'b0;
        carry_ready = 1'b0;
        overflow_ready = 1'b0;
        sub_normal_ready = 1'b0;
        scalar_overflow_ready = 1'b0; 
        NaN_ready = 1'b0; 
        $display("normal case");
        n_drive(10);
        $display("carry case");
        repeat(3) 
            carry_drive();
        $display("tie to even case");
        repeat(3) 
            tie_drive();
        $display("mantissa overflow case");
        repeat(3) 
            overflow_drive();
        $display("scalar overflow case. due to round and mantissa overflow caused scalar carry. scalar carrys to NaN");
        repeat(3) 
            scalar_overflow_drive();
        $display("scalar NaN case");
        repeat(3) 
            NaN_drive();
        $display("subnormal case");
        repeat(3) 
            sub_normal_drive();
        $finish();
    end
endmodule 