
class c3po_pkt_sequence extends uvm_sequence#(c3po_transaction);
   `uvm_object_utils(c3po_pkt_sequence)

   integer num_pkts = 10, pkt_size_l = 1, pkt_size_h = 1024;

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      integer num_pkts_i = 0;
      c3po_transaction tlm;
      tlm = c3po_transaction::type_id::create(.name("tlm"), .contxt(get_full_name()));
      while (num_pkts_i < num_pkts) begin
         start_item(tlm);
         assert(tlm.randomize() with {
            pkt_size_l <= pkt.size && pkt.size <= pkt_size_h;
         });
         finish_item(tlm);
         if (tlm.op == OP_PACKET) begin
            num_pkts_i += 1;
         end
      end
   endtask: body
endclass: c3po_pkt_sequence

class c3po_base_sequence extends uvm_sequence#(c3po_transaction);
   `uvm_object_utils(c3po_base_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task send_pkt_seq_size_range(integer pkt_size_l,
                                integer pkt_size_h,
                                integer num_pkts);
      c3po_pkt_sequence seq;
      seq = c3po_pkt_sequence::type_id::create(.name("pkt_seq"),
                                                .contxt(get_full_name()));
      seq.num_pkts = num_pkts;
      seq.pkt_size_l = pkt_size_l;
      seq.pkt_size_h = pkt_size_h;

      assert(seq.randomize());
      seq.start(.sequencer(m_sequencer), .parent_sequence(this));
   endtask: send_pkt_seq_size_range

   task send_pkt_seq_size(integer pkt_size, integer num_pkts);
      send_pkt_seq_size_range(pkt_size, pkt_size, num_pkts);
   endtask: send_pkt_seq_size

endclass: c3po_base_sequence

class c3po_pkt_all_sequence extends c3po_base_sequence;
  `uvm_object_utils(c3po_pkt_all_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      `uvm_info("test", "Testing all packet sizes", UVM_LOW);
      send_pkt_seq_size_range(1, 1024, 100);
   endtask: body

endclass: c3po_pkt_all_sequence

class c3po_pkt_corner_sequence extends c3po_base_sequence;
  `uvm_object_utils(c3po_pkt_corner_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      `uvm_info("test", "Testing corner packet sizes", UVM_LOW);
      send_pkt_seq_size(1, 1);
      send_pkt_seq_size(31, 1);
      send_pkt_seq_size(32, 1);
      send_pkt_seq_size(33, 1);
      send_pkt_seq_size(159, 1);
      send_pkt_seq_size(160, 1);
      send_pkt_seq_size(161, 1);
   endtask: body

endclass: c3po_pkt_corner_sequence
