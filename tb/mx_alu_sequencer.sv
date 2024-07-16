`ifndef MX_ALU_SEQUENCER__SV
`define MX_ALU_SEQUENCER__SV

class mx_alu_sequencer extends uvm_sequencer #(mx_alu_transaction);
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(mx_alu_sequencer)
endclass

`endif
