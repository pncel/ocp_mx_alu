`timescale 1ns/1ps
module mx_int8_bd_drv(
    gen_float32,
    data_ready_o,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    `include "transection.sv"
    input wire clk;
    output [`FLOAT32_WIDTH-1:0] gen_float32;  //same as float in c 
    output data_ready_o; 


    t_fp32_scale data_in(.f(gen_float32));
    task single_drive();
        data_in.randomize(); 
        @(posedge clk) begin
            data_in.randomize();
            #1;
        end
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
            end
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
                data_in.set_sign(~data_in.sign);
            end
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
            end
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task scale_overflow_drive();     
        data_in.set_sign(1'b0);
        data_in.set_scale_overflow(1'b1);
        repeat(2) begin
            @(posedge clk) begin                
                data_in.randomize();
                #1;
            end
            data_in.set_sign(1'b1); 
        end
        data_in.set_clean();
    endtask
    task NaN_drive();  
        data_in.set_NaN(1'b1);  
        $display("NaN normal case"); 
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin 
                data_in.randomize();
                #1;
            end
            data_in.set_sign(1'b1); 
        end
        $display("NaN carry case");
        carry_drive();
        data_in.set_NaN(1'b1);
        $display("NaN overflow case"); 
        overflow_drive();
        $display("NaN zero case"); 
        zero_drive();
        data_in.set_clean();
    endtask
    task zero_drive();  
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin 
                data_in.randomize();
                data_in.set_zero();
                #1;
            end
            data_in.set_sign(1'b1); 
        end
    endtask
    task sub_normal_drive();  
        data_in.set_clean();  
        data_in.sub_normal = 1'b1; 
        $display("subnormal normal case"); 
        data_in.set_sign(1'b0);
        repeat(2) begin
            @(posedge clk) begin       
                data_in.randomize();
                #1;
            end
            data_in.set_sign(1'b1); 
        end
        data_in.set_carry(1'b1); 
        data_in.set_sign(1'b0);
        $display("subnormal carry case"); 
        repeat(2) begin
            @(posedge clk) begin 
                data_in.sub_normal = 1'b1;
                data_in.randomize();
                #1;
            end
            data_in.set_sign(1'b1); 
        end
        $display("subnormal zero case"); 
        zero_drive();
        $display("subnormal tie to even case");
        tie_drive(); 
        data_in.sub_normal = 1'b1; 
        $display("subnormal scale carry case");
        overflow_drive();
        data_in.set_clean();
    endtask
    initial begin
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
            scale_overflow_drive();
        $display("scalar NaN case");
        repeat(3) 
            NaN_drive();
        $display("subnormal case");
        repeat(3) 
            sub_normal_drive(); //FP32 +0, -0. is in this case's zero drive case. 
        $display("zero case");
        repeat(5) 
            zero_drive(); //this is FP32 mantissa zero cases
        $finish();
    end
endmodule 