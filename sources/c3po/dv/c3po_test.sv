class c3po_test extends uvm_test;

   `uvm_component_utils(c3po_test)

   c3po_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = c3po_env::type_id::create(.name("env"), .parent(this));
   endfunction: build_phase

   task send_pkt_seq_size_range(integer pkt_size_l,
                                integer pkt_size_h,
                                integer num_pkts);
      c3po_sequence seq = c3po_sequence::type_id::create(.name("seq"),
                                                         .contxt(get_full_name()));
      seq.pkt_size_l = pkt_size_l;
      seq.pkt_size_h = pkt_size_h;
      seq.num_pkts = num_pkts;
      assert(seq.randomize());
      seq.start(env.agent.seqr);
   endtask: send_pkt_seq_size_range

   task send_pkt_seq_size(integer pkt_size, integer num_pkts);
      send_pkt_seq_size_range(pkt_size, pkt_size, num_pkts);
   endtask: send_pkt_seq_size

   task run_phase(uvm_phase phase);
      c3po_sequence seq;

      phase.raise_objection(.obj(this));

      `uvm_info("test", "Testing all packet sizes", UVM_LOW);
      send_pkt_seq_size_range(1, 1024, 1000);

      #500
      phase.drop_objection(.obj(this));
   endtask: run_phase

endclass: c3po_test
