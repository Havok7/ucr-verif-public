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
      c3po_base_test_sequence seq;
      seq = c3po_base_test_sequence::type_id::create(.name("seq"),
                                                .contxt(get_full_name()));
      phase.raise_objection(.obj(this));
      assert(seq.randomize());
      seq.start(env.agent.seqr);
      #500
      phase.drop_objection(.obj(this));
   endtask: run_phase

endclass: c3po_base_test

// Test sending random sized packets to random slices
class c3po_pkt_all_simple_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_all_simple_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_all_simple_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_all_simple_test

// Test sending random sized packets to random slices
// but also randomly halt the processing by deasserting val
class c3po_pkt_all_val_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_all_val_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_all_val_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_all_val_test

// Test sending random sized packets to random slices
// but also randomly reset the chip
class c3po_pkt_all_reset_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_all_reset_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_all_reset_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_all_reset_test

// Test sending corner case sized packets to random slices
class c3po_pkt_corner_sizes_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_corner_sizes_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_corner_sizes_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_corner_sizes_test

// Test sending random sized packets to random slices
// while randomly reconfiguring the port enable state
// for random slices
class c3po_pkt_cfg_port_enable_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_cfg_port_enable_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_cfg_port_enable_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_cfg_port_enable_test

// Test sending random sized packets to random slices
// while randomly reconfiguring the port id value
// for random slices
class c3po_pkt_cfg_port_id_test extends c3po_base_test;
   `uvm_component_utils(c3po_pkt_cfg_port_id_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(c3po_base_test_sequence::get_type(),
                                c3po_pkt_cfg_port_id_sequence::get_type());
   endfunction: build_phase

endclass: c3po_pkt_cfg_port_id_test
