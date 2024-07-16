`ifndef MX_ALU_MONITOR_IN__SV
`define MX_ALU_MONITOR_IN__SV
class mx_alu_monitor_in extends uvm_monitor;

   virtual mx_alu_if_in vif;

   uvm_analysis_port #(mx_alu_transaction)  ap;
   
   `uvm_component_utils(mx_alu_monitor_in)
   function new(string name = "mx_alu_monitor_in", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //get parameter object first
      if(!uvm_config_db#(virtual mx_alu_if)::get(this, "", "vif", vif))
         `uvm_fatal("mx_alu_monitor_in", "virtual interface must be set for vif!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(mx_alu_transac_intion tr);
endclass

task mx_alu_monitor_in::main_phase(uvm_phase phase);
   mx_alu_transaction tr;
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      ap.write(tr);
   end
endtask

task mx_alu_monitor_in::collect_one_pkt(mx_alu_transacion tr);
   @(posedge vif.valid_in);

   tr.dtype <= vif.dtype;
   tr.op <= vif.op;
   tr.scalar_in <= vif.scalar_in ;
   tr.vec_in_a <= vif.vec_in_a;
   tr.vec_in_b <= vif.vec_in_b;
   `uvm_info("mx_alu_monitor_in", "end collect one pkt", UVM_LOW);
endtask


`endif
