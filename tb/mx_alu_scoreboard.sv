`ifndef MX_ALU_SCOREBOARD__SV
`define MX_ALU_SCOREBOARD__SV
class mx_alu_scoreboard#(
   parameter d=8, k=32, w=8, s=32, 
   localparam size = w+k*d)
   extends uvm_scoreboard;
   mx_alu_transaction  expect_queue[$];
   bit out_scl0_vec1[op_t]; 

   uvm_blocking_get_port #(mx_alu_transaction)  exp_port;
   uvm_blocking_get_port #(mx_alu_transaction)  act_port;
   `uvm_component_utils(mx_alu_scoreboard)

   extern function new(string name, uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
   extern function bit compare(const ref mx_alu_transaction mon,const ref mx_alu_transaction mdl);
   function bit compare8b(bit[7:0] mon, bit[7:0] mdl);
      if(mon==mdl)
         return 1'b1;
      else 
         return 1'b0;
   endfunction
   //Requirement: FP32,BF16 support 
   function bit compareScl(const ref bit[s-1:0] mon,const ref bit[s-1:0] mdl);
      if(mon==mdl)
         return 1'b1;
      else 
         return 1'b0;
   endfunction
   //details on exp MXE8M0 part and k depth vector
   //add MX format compare details:
   //1: 0 value in float compare.
   //2: NaN compare. 
   //3: subnormal.
   function bit compareVec(bit[size-1:0] mon, bit[:0] mdl);
      if(mon==mdl) //add vector compare here
         return 1'b1;
      else 
         return 1'b0;
   endfunction
endclass 

function mx_alu_scoreboard::new(string name, uvm_component parent = null);
   super.new(name, parent);
   out_scl0_vec1[OP_BC] = 1'b1;
   out_scl0_vec1[OP_SUM] = 1'b0;
   out_scl0_vec1[OP_NEG] = 1'b1;
   out_scl0_vec1[OP_EXP] = 1'b1;
   out_scl0_vec1[OP_ADD_BIAS] = 1'b1;
   out_scl0_vec1[OP_SVMUL] = 1'b1;
   out_scl0_vec1[OP_ADD] = 1'b1;
   out_scl0_vec1[OP_SUB] = 1'b1;
   out_scl0_vec1[OP_MUL] = 1'b1;
   out_scl0_vec1[OP_DIV] = 1'b1;
   out_scl0_vec1[OP_DOT] = 1'b0;
endfunction 

function void mx_alu_scoreboard::build_phase(uvm_phase phase);
   super.build_phase(phase);
   exp_port = new("exp_port", this);
   act_port = new("act_port", this);
endfunction 

task mx_alu_scoreboard::main_phase(uvm_phase phase);
   mx_alu_transaction  get_expect,  get_actual, tmp_tran;
   bit result;
 
   super.main_phase(phase);
   fork 
      while (1) begin
         exp_port.get(get_expect);
         expect_queue.push_back(get_expect);
      end
      while (1) begin
         act_port.get(get_actual);
         if(expect_queue.size() > 0) begin
            tmp_tran = expect_queue.pop_front();
            result = compare(get_actual, tmp_tran);
            if(result) begin 
               `uvm_info("mx_alu_scoreboard", "Compare SUCCESSFULLY", UVM_LOW);
            end
            else begin
               `uvm_error("mx_alu_scoreboard", "Compare FAILED");
               $display("the expect pkt is");
               tmp_tran.print();
               $display("the actual pkt is");
               get_actual.print();
            end
         end
         else begin
            `uvm_error("mx_alu_scoreboard", "Received from DUT, while Expect Queue is empty");
            $display("the unexpected pkt is");
            get_actual.print();
         end 
      end
   join
endtask

function bit mx_alu_scoreboard::compare(const ref mx_alu_transaction mon,const ref mx_alu_transaction mdl);
   if(out_scl0_vec1[mdl.op]) begin
      return compareScl(mon.scalar_out, mdl.scalar_out);
   end
   else begin
      return compareVec(mon.vec_out,mdl.vec_out);
   end
endfunction
`endif
