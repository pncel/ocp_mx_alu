`ifndef MX_ALU_MODEL__SV
`define MX_ALU_MODEL__SV

class mx_alu_model extends uvm_component;
   
   uvm_blocking_get_port #(mx_alu_transaction)  port;
   uvm_analysis_port #(mx_alu_transaction)  ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
   extern virtual function void mx_alu(const ref mx_alu_transaction tr);
   `uvm_component_utils(mx_alu_model)
endclass 

function mx_alu_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void mx_alu_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

function void mx_alu(const ref mx_alu_transaction tr);
//add alu model functions 
endfunction

task mx_alu_model::main_phase(uvm_phase phase);
   mx_alu_transaction tr;
   mx_alu_transaction new_tr;
   super.main_phase(phase);
   while(1) begin
      port.get(tr);
      new_tr = new("new_tr");
      new_tr.copy(tr);
      `uvm_info("mx_alu_model", "get one transaction, copy and print it:", UVM_LOW)
      mx_alu(new_tr);
      //new_tr.print();
      ap.write(new_tr);
   end
endtask
`endif
