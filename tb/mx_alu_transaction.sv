`ifndef MX_ALU_TRANSACTION__SV
`define MX_ALU_TRANSACTION__SV

class mx_alu_transaction#(
   parameter d=8, k=32, w=8, s=32, 
   localparam size = w+k*d) 
   extends uvm_sequence_item;

   rand bit[2:0] op;
   rand bit[2:0] dtype;
   rand bit[s-1:0] scalar_in;
   rand bit[size-1:0] vec_in_a;
   rand bit[size-1:0] vec_in_b;
   bit[s-1:0] scalar_out;
   bit[size-1:0] vec_out,

   `uvm_object_utils_begin(my_transaction)
      `uvm_field_int(op, UVM_ALL_ON)
      `uvm_field_int(dtype, UVM_ALL_ON)
      `uvm_field_int(scalar_in, UVM_ALL_ON)
      `uvm_field_int(vec_in_a, UVM_ALL_ON)
      `uvm_field_int(vec_in_b, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "mx_alu_transaction");
      super.new();
   endfunction

   virtual function bit
endclass

class MXINT8_BF16_transaction #(
   parameter d=8, k=32, w=8, s=16, 
   localparam size = w+k*d) 
   extends mx_alu_transaction;
   constraint pload_cons{
      dtype == DTYPE_MXINT8;
   }
endclass
`endif
