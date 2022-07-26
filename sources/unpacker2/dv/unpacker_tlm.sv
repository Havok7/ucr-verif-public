typedef enum {OP_PACKET, OP_RESET_L, OP_VAL_L, OP_MAX} op_t;

class tlm_packet #(max_size=1024) extends uvm_object;
   rand bit [max_size*8-1:0] data;
   rand bit [9:0]   size;

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
   rand integer start;
   rand integer hold;

   constraint op_dist {
      op dist {
            OP_PACKET  := 5,
            OP_RESET_L := 1,
            OP_VAL_L   := 1
      };
   }
   constraint limit_start { start >= 0; start <= 10; }
   constraint limit_hold { hold >= 1; hold <= 30; }

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
      tlm.start = start;
      tlm.hold = hold;
      return tlm;
   endfunction: clone

   `uvm_object_utils_begin(unpacker_transaction)
      `uvm_field_enum(op_t,op,UVM_ALL_ON)
      `uvm_field_object(pkt,UVM_ALL_ON)
      `uvm_field_int(start,UVM_ALL_ON)
      `uvm_field_int(hold,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: unpacker_transaction
