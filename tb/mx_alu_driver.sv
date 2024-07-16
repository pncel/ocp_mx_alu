`ifndef MX_ALU_DRIVER__SV
`define MX_ALU_DRIVER__SV
class mx_alu_driver extends uvm_driver#(mx_alu_transaction);

   virtual mx_alu_if_in vif;

   `uvm_component_utils(mx_alu_driver)
   function new(string name = "mx_alu_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual mx_alu_if)::get(this, "", "vif", vif))
         `uvm_fatal("mx_alu_driver", "virtual interface must be set for vif!!!")
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(mx_alu_transaction tr);
endclass

task mx_alu_driver::main_phase(uvm_phase phase);
   vif.valid_in <= 1'b0;
   //while(!vif.rst_n)
      @(posedge vif.clk);
   while(1) begin
      seq_item_port.get_next_item(req);
      drive_one_pkt(req);
      seq_item_port.item_done();
   end
endtask

task mx_alu_driver::drive_one_pkt(mx_alu_transaction tr);
   
   if(vif.valid_out == 1'b0)
      @(posedge vif.valid_out);

   `uvm_info("mx_alu_driver", "begin to drive one pkt", UVM_LOW);
   repeat(1) @(posedge vif.clk);
   vif.valid_in <= 1'b1;
   vif.dtype <= tr.dtype;
   vif.op <= tr.op;
   vif.scalar_in <= tr.scalar_in;
   vif.vec_in_a <= tr.vec_in_a;
   vif.vec_in_b <= tr.vec_in_b;

   @(posedge vif.clk);
   vif.valid_in <= 1'b0;
   `uvm_info("mx_alu_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
