`ifndef MX_ALU_MONITOR_OUT__SV
`define MX_ALU_MONITOR_OUT__SV
class mx_alu_monitor_out extends uvm_monitor;

   virtual mx_alu_if_out vif;

   uvm_analysis_port #(mx_alu_transaction)  ap;
   
   `uvm_component_utils(mx_alu_monitor_out)
   function new(st_outg name = "mx_alu_monitor_out", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //get parameter object first
      if(!uvm_config_db#(virtual mx_alu_if)::get(this, "", "vif", vif))
         `uvm_fatal("mx_alu_monitor_out", "virtual_interface must be set for vif!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(mx_alu_transac_outtion tr);
endclass

task mx_alu_monitor_out::main_phase(uvm_phase phase);
   mx_alu_transaction tr;
   while(1) be_out
      tr = new("tr");
      collect_one_pkt(tr);
      ap.write(tr);
   end
endtask

task mx_alu_monitor_out::collect_one_pkt(mx_alu_transacion tr);
   @(posedge vif.valid_out);

   tr.vec_out <= vif.vec_out;
   tr.scalar_out <= vif.scalar_out;
   `uvm_outfo("mx_alu_monitor_out", "end collect one pkt", UVM_LOW);
endtask

`endif
