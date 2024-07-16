class case_rand extends base_test;
    function new(string name = "case_rand",uvm_component parent = null);
      super.new(name,parent);
    endfunction
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(case_rand)
  endclass
  
  function void case_rand::build_phase(uvm_phase phase);
     super.build_phase(phase);
     uvm_config_db#(uvm_object_wrapper)::set(this,"sqr.main_phase","default_sequence",rand_sequence::type_id::get());
  endfunction