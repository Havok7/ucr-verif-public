class unpacker_test extends uvm_test;

   `uvm_component_utils(unpacker_test)

   unpacker_env env;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = unpacker_env::type_id::create(.name("env"), .parent(this));
   endfunction: build_phase

   task send_pkt_seq_size_range(integer low_size,
                                integer high_size,
                                integer num_pkts);
      unpacker_sequence seq = unpacker_sequence::type_id::create(.name("seq"),
                                                                 .contxt(get_full_name()));
      seq.num_pkts = num_pkts;
      seq.low_size = low_size;
      seq.high_size = high_size;
      assert(seq.randomize());
      seq.start(env.agent.seqr);
   endtask: send_pkt_seq_size_range

   task send_pkt_seq_size(integer size, integer num_pkts);
      send_pkt_seq_size_range(size, size, num_pkts);
   endtask: send_pkt_seq_size

   task run_phase(uvm_phase phase);
      unpacker_sequence seq;

      phase.raise_objection(.obj(this));

      // send_pkt_seq_size(32, 5);
      // send_pkt_seq_size(162, 5);
      //send_pkt_seq_size(512, 2);

      ////Secuencia de ejemplo en clase
      //send_pkt_seq_size(32, 5);
      //send_pkt_seq_size(0, 2);
      //send_pkt_seq_size(159, 1);
      //send_pkt_seq_size(479, 1);

      //send_pkt_seq_size(33, 5);

      //send_pkt_seq_size(32, 5);

      // `uvm_info("test", "Testing small packet sizes", UVM_LOW);
      // send_pkt_seq_size_range(1, 159, 10);

      // `uvm_info("test", "Testing large packet sizes", UVM_LOW);
      // send_pkt_seq_size_range(160, 1024, 10);

      // `uvm_info("test", "Testing corner packet sizes", UVM_LOW);
      send_pkt_seq_size(160, 1);
      send_pkt_seq_size(32, 1);
      send_pkt_seq_size(33, 1);
      //send_pkt_seq_size(33, 1);
      send_pkt_seq_size(0, 1);
      send_pkt_seq_size(159, 1);
      send_pkt_seq_size(160, 1);
      send_pkt_seq_size(0, 1);
      send_pkt_seq_size(161, 1);
      send_pkt_seq_size(1024, 1);
      #100
      phase.drop_objection(.obj(this));
   endtask: run_phase

endclass: unpacker_test
