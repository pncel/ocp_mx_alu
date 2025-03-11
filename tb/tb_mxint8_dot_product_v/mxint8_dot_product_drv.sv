`timescale 1ns/1ps
`include "scalar_includes.v"
`include "mxint8_includes.v"
module mx_int8_dot_product_drv #(
    parameter int N = 5, //each case repeat times
    parameter int CYCLE = 100
    )(
    input  wire clk,
    output reg[`SCALE_WIDTH-1:0]                              scale_a_drv,
    output reg[`SCALE_WIDTH-1:0]                              scale_b_drv,
    output reg[`BLOCK_SIZE-1:0] [`MXINT8_ELEMENT_WIDTH-1:0]   mxint8_elements_a_drv,
    output reg[`BLOCK_SIZE-1:0] [`MXINT8_ELEMENT_WIDTH-1:0]   mxint8_elements_b_drv,
    output reg[`FLOAT32_WIDTH-1:0]                            o_float32_dot_product_drv,
    output reg                                                unused_flag_drv,
    output reg                                                overflow_flag_drv,
    output reg                                                underflow_flag_drv,
    output reg                                                NaN_flag_drv
);
    localparam int half = CYCLE/2; 
    parameter string FILENAME = "dot_testcases_key.txt"; // Default to "dot_testcases_key.txt"
  
   

    /*
    assign scale_drv = vector_in.scale;
    genvar i;
    generate
        for(i = 0 ; i < `BLOCK_SIZE; i = i+1)
            assign mxint8_elements_drv[i]  = vector_in.elements[i];
    endgenerate*/
    // Include your common definitions
    `include "scalar_includes.v"
    `include "mxint8_includes.v"

    // Instantiate the test vector class so its internal
    // fields will drive the outputs
    // t_mx_int8_vector vector_in (
    //     .scale   (scale_drv),
    //     .elements(mxint8_elements_drv)
    // );

    // [Optionally comment out or remove all random test generator functions]
    /*
    function void normal_case();
        vector_in.randomize();
    endfunction
    ...
    */

    // Remove or comment-out your old initial block that called normal_case(), etc.
    // initial begin
    //     $display("normal_case");
    //     repeat(5*N) @(posedge clk) normal_case();
    //     ...
    //     $finish();
    // end

    // -----------------------------------------------------------------------
    // NEW INITIAL BLOCK TO READ FROM TEXT FILE
    // -----------------------------------------------------------------------
    
    initial begin
        
        // Variables for file I/O
        int file_descriptor;
        reg [1023:0] one_line;
        reg [`FLOAT32_WIDTH-1:0] f32_value;
        int case_number;
        int index;
        byte value_a,value_b;
        int scale_value_a;
        int scale_value_b;
        int status;
        int valid_line;
        int unused_flag;
        int overflow_flag;
        int underflow_flag;
        int NaN_flag;
        #half;
        #half;
        // Attempt to open the text file
        file_descriptor = $fopen(FILENAME, "r");
        if (file_descriptor == 0) begin
            $display("ERROR: Could not open file '%0s'", FILENAME);
            $finish;
        end

        // Read until we hit the end of file
        while (!$feof(file_descriptor)) begin
            // Read a line
            status = $fgets(one_line, file_descriptor);
            if (status == 0) begin
                $display("ERROR: Unexpected EOF while reading file");
                $finish;
            end

            // Initialize valid_line flag
            valid_line = 0;

            // Check if the line is "Case = %d"
            if ($sscanf(one_line, "Case = %d", case_number) == 1) begin
                $display("\nReading case = %0d", case_number);
                valid_line = 1; // Mark line as valid
            end

            // Check if the line is "element_a[%d] = %d" element[0] = 7, -89
            if ($sscanf(one_line, "element[%d] = %d, %d", index, value_a, value_b) == 3) begin
                if (index >= `BLOCK_SIZE) begin
                    $display("ERROR: Invalid index %0d in line: '%0s'", index, one_line);
                    $finish;
                end
                mxint8_elements_a_drv[index] = value_a; // Assign to reg
                mxint8_elements_b_drv[index] = value_b;
                // $display("element[%d] = %d, %d",  index, byte'(mxint8_elements_a_drv[index]), byte'(mxint8_elements_b_drv[index]));
                valid_line = 1; // Mark line as valid
            end

            // Check if the line is "scale_a = %d"
            if ($sscanf(one_line, "scale_A = %d", scale_value_a) == 1) begin
                scale_a_drv = scale_value_a; // Assign to reg
                // $display("scale_A = %d", scale_a_drv);
                valid_line = 1; // Mark line as valid
                // @(posedge clk); // Wait for clock edge after processing scale
            end
            
            // Check if the line is "scale_b = %d"
            if ($sscanf(one_line, "scale_B = %d", scale_value_b) == 1) begin
                scale_b_drv = scale_value_b; // Assign to reg
                // $display("scale_B = %d", scale_b_drv);
                valid_line = 1; // Mark line as valid
                // @(posedge clk); // Wait for clock edge after processing scale
            end
            if ($sscanf(one_line, "expected result = %b", f32_value) == 1) begin
                o_float32_dot_product_drv = f32_value; // Assign to reg
                // $display("expected result = %b", o_float32_dot_product_drv);
                valid_line = 1; // Mark line as valid
            end
            if ($sscanf(one_line, "unused flag = %d", unused_flag) == 1) begin
                unused_flag_drv = unused_flag; // Assign to reg
                // $display("unused flag = %d", unused_flag);
                valid_line = 1; // Mark line as valid
            end
            if ($sscanf(one_line, "underflow flag = %d", underflow_flag) == 1) begin
                underflow_flag_drv = underflow_flag; // Assign to reg
                // $display("underflow flag = %d", underflow_flag);
                valid_line = 1; // Mark line as valid
            end
            if ($sscanf(one_line, "overflow flag = %d", overflow_flag) == 1) begin
                overflow_flag_drv = overflow_flag; // Assign to reg
                // $display("overflow flag = %d", overflow_flag);
                valid_line = 1; // Mark line as valid
                @(posedge clk);
            end
            if ($sscanf(one_line, "NaN flag = %d", NaN_flag) == 1) begin
                NaN_flag_drv = NaN_flag; // Assign to reg
                // $display("NaN flag = %d", NaN_flag);
                valid_line = 1; // Mark line as valid
                @(posedge clk); // Wait for clock edge after processing scale
            end
            // If the line is not valid, skip or report an error
            // if (!valid_line) begin
            //     // $display("WARNING: Unrecognized line: '%0s'", one_line);
            // end
        end

        // Close the file
        $fclose(file_descriptor);

        $display("All testcases from '%0s' have been driven. Finishing...", FILENAME);
        $finish();
    end // initial
endmodule 