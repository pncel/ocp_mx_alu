`ifndef MX_ALU_AGENT__SV
`define MX_ALU_AGENT__SV

class mx_alu_agent extends uvm_agent ;
   mx_alu_sequencer  sqr;
   mx_alu_driver     drv;
   mx_alu_monitor_in    mon_in;
   mx_alu_monitor_out    mon_out;

   uvm_analysis_port #(mx_alu_transaction)  ap;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(mx_alu_agent)
endclass 


function void mx_alu_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      sqr = mx_alu_sequencer::type_id::create("sqr", this);
      drv = mx_alu_driver::type_id::create("drv", this);
      mon_in = mx_alu_monitor_in::type_id::create("mon_in", this);
   end 
   else begin
      mon_out = mx_alu_monitor_out::type_id::create("mon_out", this);
   end
endfunction 

function void mx_alu_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
      ap = mon_in.ap;
   end
   else begin
      ap = mon_out.ap;
   end
endfunction

`endif

