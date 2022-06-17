
typedef enum {OP_PACKET, OP_RESET, OP_MAX} op_t;

class tlm_packet #(max_size=1024) extends uvm_object;
   rand bit [max_size*8-1:0] data;
   rand bit [10:0]   size;

   constraint limit_size { size >= 0; size <= max_size; }
   constraint limit_data { data <= (1 << (size * 8)) - 1; }

   function new(string name = "");
      super.new(name);
   endfunction: new

   function tlm_packet clone();
      tlm_packet pkt;
      pkt = tlm_packet::type_id::create(.name(get_name()), .contxt(get_full_name()));
      pkt.data = data;
      pkt.size = size;
      return pkt;
   endfunction: clone

   `uvm_object_utils_begin(tlm_packet)
      `uvm_field_int(data,UVM_ALL_ON)
      `uvm_field_int(size,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: tlm_packet

class unpacker_transaction extends uvm_sequence_item;
   rand op_t op;
   rand tlm_packet pkt;
   rand integer rst_start;
   rand integer rst_hold;

   constraint op_dist {
      op dist {
            OP_PACKET := 5,
            OP_RESET  := 1
      };
   }
   constraint limit_reset_start { rst_start >= 0; rst_start <= 10; }
   constraint limit_reset_hold { rst_hold >= 1; rst_hold <= 5; }

   function new(string name = "");
      super.new(name);
      pkt = new("pkt");
   endfunction: new

   function unpacker_transaction clone();
      unpacker_transaction tlm;
      tlm = unpacker_transaction::type_id::create(.name(get_name()), .contxt(get_full_name()));
      tlm.op = op;
      if (tlm.op == OP_PACKET) begin
         tlm.pkt = pkt.clone();
      end
      tlm.rst_start = rst_start;
      tlm.rst_hold = rst_hold;
      return tlm;
   endfunction: clone

   `uvm_object_utils_begin(unpacker_transaction)
      `uvm_field_enum(op_t,op,UVM_ALL_ON)
      `uvm_field_object(pkt,UVM_ALL_ON)
      `uvm_field_int(rst_hold,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: unpacker_transaction

class unpacker_sequence extends uvm_sequence#(unpacker_transaction);
   `uvm_object_utils(unpacker_sequence)

   rand unpacker_transaction tlm;
   integer      num_pkts, pkt_size_l, pkt_size_h;

   function new(string name = "", integer num_pkts = 10, pkt_size_l = 1, pkt_size_h = 1024);
      super.new(name);
      this.num_pkts = num_pkts;
      this.pkt_size_l = pkt_size_l;
      this.pkt_size_h = pkt_size_h;
      this.tlm = unpacker_transaction::type_id::create(.name("tlm"), .contxt(get_full_name()));
   endfunction: new

   task body();
      integer num_pkts_i = 0;
      while (num_pkts_i < num_pkts) begin
         start_item(tlm);
         assert(tlm.randomize() with {pkt_size_l <= pkt.size && pkt.size <= pkt_size_h;});
         finish_item(tlm);
         if (tlm.op == OP_PACKET) begin
            num_pkts_i += 1;
         end
      end
   endtask: body
endclass: unpacker_sequence

typedef uvm_sequencer#(unpacker_transaction) unpacker_sequencer;
