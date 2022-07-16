class c3po_base_test extends uvm_test;
   `uvm_component_utils(c3po_base_test)

   c3po_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = c3po_env::type_id::create(.name("env"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      c3po_base_sequence seq;
      seq = c3po_base_sequence::type_id::create(.name("seq"),
                                                .contxt(get_full_name()));
      phase.raise_objection(.obj(this));
      assert(seq.randomize());
      seq.start(env.agent.seqr);
      #500
      phase.drop_objection(.obj(this));
   endtask: run_phase

endclass: c3po_base_test

class c3po_pkt_all_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_all_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_sequence::get_type(),
                                c3po_pkt_all_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_all_test

class c3po_pkt_corner_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_corner_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_sequence::get_type(),
                                c3po_pkt_corner_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_corner_test
