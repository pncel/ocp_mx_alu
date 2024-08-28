`timescale 1ns/1ps
module mx_int8_negate_mon(
    dut_in_mxint8_elements,
    dut_out_mxint8_elements,
    data_ready_i,
    clk
);
    `include "scalar_includes.v"
    `include "mxint8_includes.v"
    input wire data_ready_i;  
    input wire clk;
    input wire [`MXINT8_ELEMENT_WIDTH-1:0] dut_in_mxint8_elements[0:`BLOCK_SIZE-1];
    input wire [`MXINT8_ELEMENT_WIDTH-1:0] dut_out_mxint8_elements[0:`BLOCK_SIZE-1];
    reg real decoded_in;
    reg real decoded_out;
    int transection_id; 

    initial begin
        transection_id = 0; 
    end

    always @(posedge data_ready_i) begin
        $display("\ntransection id: %d",transection_id);
        single_mon();
        transection_id <= transection_id + 1; 
    end

    task single_mon;
        for(int i = 0; i < `BLOCK_SIZE; i = i + 1) begin
            @(posedge clk) begin
                decoder(dut_in_mxint8_elements[i],decoded_in);
                decoder(dut_out_mxint8_elements[i],decoded_out);
                #0; 
                $display("element index: %d",i);
                if(decoded_in != (-decoded_out))
                    $display("MXINT8_NEGATE ERROR!");
                $display("input data: %f, output data: %f", decoded_in,decoded_out);
                $display("input binary: \n%b",dut_in_mxint8_elements[i]);
                $display("%b\noutput binary",dut_out_mxint8_elements[i]);
                end
        end
    endtask

    task automatic decoder(input reg[`MXINT8_ELEMENT_WIDTH-1:0] int8_data, output real decimal_data);
        real scale;
        scale = 1.0;
        decimal_data = 0;
        for(int i = `MXINT8_ELEMENT_WIDTH-2 ; i >= 0 ; i = i - 1) begin
            if(int8_data[i]==1'b1)
                decimal_data += scale;
            scale = scale/2;
        end
        if(int8_data[`MXINT8_ELEMENT_WIDTH-1])
            decimal_data -= 2; 
    endtask
endmodule