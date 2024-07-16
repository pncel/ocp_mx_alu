`ifndef SEQ_LIB__SV
`define SEQ_LIB__SV

class base_sequence extends uvm_sequence #(mx_alu_transaction);
    `uvm_object_utils(base_sequence)
    /*
    virtual mx_alu_if_in #(
        .d(d), .k(k), .w(w), .s(s)
    ) vif;
     void function get_if()
        uvm_config_db#(virtual mx_alu_if_in#(.d(d), .k(k), .w(w), .s(s)).MON )
        ::set(null, get_full_name(), "vif", vif);
    endfunction
    */
    function new(string name="base_sequence");
        super.new(name);
    endfunction
    virtual task pre_body();
        if(get_parent_sequence()==null&&starting_phase != null)
            starting_phase.raise_objection(this);
    endtask
    virtual task post_body();
        if(get_parent_sequence()==null&&starting_phase != null)
            starting_phase.drop_objection(this);
    endtask
endclass

class rand_sequence extends base_sequence;
    my_transaction int8_rand_trans;
    `uvm_object_utils(rand_sequence)
    function new(string name = "rand_sequence");
      super.new(name);
    endfunction
    virtual task body(); //add stimulation 
	    repeat(100) begin
            `uvm_do_with(rand_trans,{dtype == DTYPE_MXINT8;})
            #10; 
        end
    endtask
endclass
`endif 