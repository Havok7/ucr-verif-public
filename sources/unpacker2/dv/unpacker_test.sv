class unpacker_base_test extends uvm_test;
   `uvm_component_utils(unpacker_base_test)

   unpacker_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = unpacker_env::type_id::create(.name("env"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      unpacker_base_test_sequence seq;
      seq = unpacker_base_test_sequence::type_id::create(.name("seq"),
                                                         .contxt(get_full_name()));

      phase.raise_objection(.obj(this));
      assert(seq.randomize());
      seq.start(env.agent.seqr);
      #500
      phase.drop_objection(.obj(this));
   endtask: run_phase

endclass: unpacker_base_test

// Test sending small sized packets to unpacker (0-32B)
class unpacker_pkt_small_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_small_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_small_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_small_test

// Test sending mid sized packets to unpacker (32-160B)
class unpacker_pkt_mid_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_mid_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_mid_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_mid_test

// Test sending large sized packets to unpacker (32-160B)
class unpacker_pkt_large_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_large_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_large_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_large_test

// Test sending random sized packets to unpacker
class unpacker_pkt_all_simple_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_all_simple_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_all_simple_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_all_simple_test

// Test sending random sized packets to unpacker
// but also randomly halt the processing by deasserting val
class unpacker_pkt_all_val_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_all_val_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_all_val_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_all_val_test

// Test sending random sized packets to unpacker
// but also randomly reset the chip
class unpacker_pkt_all_reset_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_all_reset_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_all_reset_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_all_reset_test

// Test sending corner case sized packets to unpacker
class unpacker_pkt_corner_sizes_test extends unpacker_base_test;
   `uvm_component_utils(unpacker_pkt_corner_sizes_test)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      set_type_override_by_type(unpacker_base_test_sequence::get_type(),
                                unpacker_pkt_corner_sizes_sequence::get_type());
   endfunction: build_phase

endclass: unpacker_pkt_corner_sizes_test
