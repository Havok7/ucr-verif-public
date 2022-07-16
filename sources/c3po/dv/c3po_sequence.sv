
class c3po_pkt_sequence extends uvm_sequence#(c3po_transaction);
   `uvm_object_utils(c3po_pkt_sequence)

   integer num_pkts = 10, pkt_size_l = 1, pkt_size_h = 1024;
   integer max_start = 10, max_hold = 30;
   bit     do_reset_l = 0, do_val_l = 0;
   integer slice_id = -1;

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      integer num_pkts_i = 0;
      c3po_transaction tlm;
      tlm = c3po_transaction::type_id::create(.name("tlm"),
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
         if (slice_id > 0) begin
            tlm.id = slice_id;
         end
         finish_item(tlm);
         if (tlm.op == OP_PACKET) begin
            num_pkts_i += 1;
         end
      end
   endtask: body
endclass: c3po_pkt_sequence

class c3po_cfg_port_sequence extends uvm_sequence#(c3po_transaction);
   `uvm_object_utils(c3po_cfg_port_sequence)
   integer num_cfgs = 10;
   integer max_start = 10;
   integer slice_id = -1;
   tlm_op_t cfg_op = OP_MAX;

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      integer num_pkts_i = 0;
      c3po_transaction tlm;
      tlm = c3po_transaction::type_id::create(.name("tlm"),
                                              .contxt(get_full_name()));
      repeat(num_cfgs) begin
         start_item(tlm);
         assert(tlm.randomize() with {
            start <= max_start &&
            op inside {OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE};
         });
         if (cfg_op inside {OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE}) begin
            tlm.op = cfg_op;
         end
         if (slice_id > 0) begin
            tlm.id = slice_id;
         end
         finish_item(tlm);
      end
   endtask: body
endclass: c3po_cfg_port_sequence

class c3po_base_test_sequence extends uvm_sequence#(c3po_transaction);
   `uvm_object_utils(c3po_base_test_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task send_cfg_port_id_seq(integer num_cfgs, integer slice_id=-1);
      c3po_cfg_port_sequence seq;
      seq = c3po_cfg_port_sequence::type_id::create(.name("cfg_port_seq"),
                                                    .contxt(get_full_name()));
      seq.cfg_op = OP_CFG_PORT_ID;
      seq.num_cfgs = num_cfgs;
      seq.slice_id = slice_id;

      assert(seq.randomize());
      seq.start(.sequencer(m_sequencer), .parent_sequence(this));
   endtask: send_cfg_port_id_seq

   task send_cfg_port_enable_seq(integer num_cfgs, integer slice_id=-1);
      c3po_cfg_port_sequence seq;
      seq = c3po_cfg_port_sequence::type_id::create(.name("cfg_port_seq"),
                                                    .contxt(get_full_name()));
      seq.cfg_op = OP_CFG_PORT_ENABLE;
      seq.num_cfgs = num_cfgs;
      seq.slice_id = slice_id;

      assert(seq.randomize());
      seq.start(.sequencer(m_sequencer), .parent_sequence(this));
   endtask: send_cfg_port_enable_seq

   task send_pkt_seq_size_range(integer pkt_size_l,
                                integer pkt_size_h,
                                integer num_pkts,
                                bit do_reset_l=0,
                                bit do_val_l=0,
                                integer slice_id=-1);
      c3po_pkt_sequence seq;
      seq = c3po_pkt_sequence::type_id::create(.name("pkt_seq"),
                                               .contxt(get_full_name()));
      seq.num_pkts = num_pkts;
      seq.pkt_size_l = pkt_size_l;
      seq.pkt_size_h = pkt_size_h;
      seq.do_reset_l = do_reset_l;
      seq.do_val_l = do_val_l;
      seq.slice_id = slice_id;

      assert(seq.randomize());
      seq.start(.sequencer(m_sequencer), .parent_sequence(this));
   endtask: send_pkt_seq_size_range

   task send_pkt_seq_size(integer pkt_size,
                          integer num_pkts,
                          bit do_reset_l=0,
                          bit do_val_l=0,
                          integer slice_id=-1);
      send_pkt_seq_size_range(pkt_size,
                              pkt_size,
                              num_pkts,
                              do_reset_l,
                              do_val_l,
                              slice_id);
   endtask: send_pkt_seq_size

endclass: c3po_base_test_sequence

class c3po_pkt_all_sequence extends c3po_base_test_sequence;
  `uvm_object_utils(c3po_pkt_all_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size_range(1, 1024, 100, .do_reset_l(0), .do_val_l(1));
   endtask: body

endclass: c3po_pkt_all_sequence

class c3po_pkt_all_reset_sequence extends c3po_base_test_sequence;
  `uvm_object_utils(c3po_pkt_all_reset_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      send_pkt_seq_size_range(1, 1024, 100, .do_reset_l(1), .do_val_l(1));
   endtask: body

endclass: c3po_pkt_all_reset_sequence

class c3po_pkt_corner_sequence extends c3po_base_test_sequence;
  `uvm_object_utils(c3po_pkt_corner_sequence)

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
   endtask: body

endclass: c3po_pkt_corner_sequence

class c3po_pkt_cfg_port_enable_sequence extends c3po_base_test_sequence;
  `uvm_object_utils(c3po_pkt_cfg_port_enable_sequence)

   function new(string name = "");
      super.new(name);
   endfunction: new

   task body();
      fork
         send_cfg_port_enable_seq(100);
         send_pkt_seq_size_range(1, 1024, 100);
      join
   endtask: body

endclass: c3po_pkt_cfg_port_enable_sequence
