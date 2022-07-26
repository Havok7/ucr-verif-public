
class unpacker_pkt_sequence extends uvm_sequence#(unpacker_transaction);
   `uvm_object_utils(unpacker_pkt_sequence)

   integer num_pkts = 10, pkt_size_l = 1, pkt_size_h = 1024;
   integer max_start = 10, max_hold = 30;
   bit     do_reset_l = 0, do_val_l = 0;

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      integer num_pkts_i = 0;
      unpacker_transaction tlm;
      tlm = unpacker_transaction::type_id::create(.name("tlm"),
                                                  .contxt(get_full_name()));
      while (num_pkts_i < num_pkts) begin
         start_item(tlm);
         assert(tlm.randomize() with {
            pkt_size_l <= pkt.size &&
            pkt.size <= pkt_size_h &&
            start <= max_start &&
            hold <= max_hold &&
            op dist {
                OP_PACKET  := 5,
                OP_RESET_L := do_reset_l ? 1 : 0,
                OP_VAL_L := do_val_l ? 1 : 0
            };
         });
         finish_item(tlm);
         if (tlm.op == OP_PACKET) begin
            num_pkts_i += 1;
         end
      end
   endtask: body
endclass: unpacker_pkt_sequence

class unpacker_base_test_sequence extends uvm_sequence #(uvm_sequence_item);
   `uvm_object_utils(unpacker_base_test_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task send_pkt_seq_size_range(integer pkt_size_l,
                                integer pkt_size_h,
                                integer num_pkts,
                                bit do_reset_l=0,
                                bit do_val_l=0);
      unpacker_pkt_sequence seq;
      seq = unpacker_pkt_sequence::type_id::create(.name("pkt_seq"),
                                               .contxt(get_full_name()));
      seq.num_pkts = num_pkts;
      seq.pkt_size_l = pkt_size_l;
      seq.pkt_size_h = pkt_size_h;
      seq.do_reset_l = do_reset_l;
      seq.do_val_l = do_val_l;

      assert(seq.randomize());
      seq.start(.sequencer(m_sequencer), .parent_sequence(this));
   endtask: send_pkt_seq_size_range

   task send_pkt_seq_size(integer pkt_size,
                          integer num_pkts,
                          bit do_reset_l=0,
                          bit do_val_l=0);
      send_pkt_seq_size_range(pkt_size,
                              pkt_size,
                              num_pkts,
                              do_reset_l,
                              do_val_l);
   endtask: send_pkt_seq_size

endclass: unpacker_base_test_sequence

class unpacker_pkt_small_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_small_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size(1, 1);
      send_pkt_seq_size(26, 1);
      send_pkt_seq_size(1, 1);
      send_pkt_seq_size(27, 1);
      send_pkt_seq_size(2, 1);
      send_pkt_seq_size(28, 1);
      send_pkt_seq_size(5, 1);
      send_pkt_seq_size(32, 1);
      send_pkt_seq_size(8, 1);
      send_pkt_seq_size(31, 1);
      send_pkt_seq_size(13, 1);
      send_pkt_seq_size(30, 1);
      send_pkt_seq_size(21, 1);
      send_pkt_seq_size(29, 1);
   endtask: body

endclass: unpacker_pkt_small_sequence

class unpacker_pkt_mid_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_mid_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size(33, 1);
      send_pkt_seq_size(160, 1);
      send_pkt_seq_size(40, 1);
      send_pkt_seq_size(155, 1);
      send_pkt_seq_size(55, 1);
      send_pkt_seq_size(130, 1);
      send_pkt_seq_size(60, 1);
      send_pkt_seq_size(121, 1);
      send_pkt_seq_size(77, 1);
      send_pkt_seq_size(110, 1);
      send_pkt_seq_size(90, 1);
      send_pkt_seq_size(100, 1);
      send_pkt_seq_size(32, 1);
      send_pkt_seq_size(140, 1);
      send_pkt_seq_size(89, 1);
   endtask: body

endclass: unpacker_pkt_mid_sequence

class unpacker_pkt_large_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_large_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size(161, 1);
      send_pkt_seq_size(405, 1);
      send_pkt_seq_size(180, 1);
      send_pkt_seq_size(308, 1);
      send_pkt_seq_size(1017, 1);
      send_pkt_seq_size(513, 1);
      send_pkt_seq_size(950, 1);
      send_pkt_seq_size(721, 1);
      send_pkt_seq_size(1005, 1);
      send_pkt_seq_size(634, 1);
      send_pkt_seq_size(1010, 1);
      send_pkt_seq_size(955, 1);
      send_pkt_seq_size(1023, 1);
      send_pkt_seq_size(889, 1);
   endtask: body

endclass: unpacker_pkt_large_sequence

class unpacker_pkt_all_simple_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_all_simple_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size_range(1, 1024, 1000);
   endtask: body

endclass: unpacker_pkt_all_simple_sequence

class unpacker_pkt_all_reset_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_all_reset_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size_range(1, 1024, 1000, .do_reset_l(1));
   endtask: body

endclass: unpacker_pkt_all_reset_sequence

class unpacker_pkt_all_val_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_all_val_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size_range(1, 1024, 1000, .do_val_l(1));
   endtask: body

endclass: unpacker_pkt_all_val_sequence

class unpacker_pkt_corner_sizes_sequence extends unpacker_base_test_sequence;
  `uvm_object_utils(unpacker_pkt_corner_sizes_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size(1, 1);
      send_pkt_seq_size(31, 1);
      send_pkt_seq_size(32, 1);
      send_pkt_seq_size(33, 1);
      send_pkt_seq_size(159, 1);
      send_pkt_seq_size(160, 1);
      send_pkt_seq_size(161, 1);
      send_pkt_seq_size(1023, 1);
   endtask: body

endclass: unpacker_pkt_corner_sizes_sequence
