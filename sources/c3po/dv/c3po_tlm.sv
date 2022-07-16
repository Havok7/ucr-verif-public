
typedef enum
{
 OP_PACKET,
 OP_RESET_L,
 OP_VAL_L,
 OP_CFG_PORT_ID,
 OP_CFG_PORT_ENABLE,
 OP_MAX
} op_t;

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

class c3po_transaction #(max_id=4) extends uvm_sequence_item;
   // Transaction operation
   rand op_t op;
   // Packet information
   // Ops: [OP_PACKET]
   rand tlm_packet pkt;
   // Slice ID
   // Ops: [OP_PACKET, OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE]
   rand integer id;
   // Port ID to configure in Slice
   // Ops: [OP_CFG_PORT_ID]
   rand integer cfg_id;
   // Port Enable to configure in Slice
   // Ops: [OP_CFG_PORT_ENABLE]
   rand integer cfg_enable;
   // Number of clock cycles before starting signal
   // Ops: [OP_RESET_L, OP_VAL_L, OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE]
   rand integer start;
   // Number of clock cycles to hold signal
   // Ops: [OP_RESET_L, OP_VAL_L]
   rand integer hold;

   constraint op_dist {
      op dist {
            OP_PACKET  := 5,
            OP_RESET_L := 1,
            OP_VAL_L   := 1,
            OP_CFG_PORT_ID := 0,
            OP_CFG_PORT_ENABLE := 0
      };
   }
   constraint limit_start { start >= 0; start <= 10; }
   constraint limit_hold { hold >= 1; hold <= 30; }
   constraint limit_id { id < max_id; }
   constraint limit_cfg_id { cfg_id < max_id; }
   constraint limit_cfg_enable { cfg_enable <= 1; }

   function new(string name = "");
      super.new(name);
      pkt = new("pkt");
   endfunction: new

   function c3po_transaction clone();
      c3po_transaction tlm;
      tlm = c3po_transaction::type_id::create(.name(get_name()), .contxt(get_full_name()));
      tlm.op = op;
      if (tlm.op == OP_PACKET) begin
         tlm.pkt = pkt.clone();
      end
      tlm.id = id;
      tlm.cfg_id = cfg_id;
      tlm.cfg_enable = cfg_enable;
      tlm.start = start;
      tlm.hold = hold;
      return tlm;
   endfunction: clone

   `uvm_object_utils_begin(c3po_transaction)
      `uvm_field_enum(op_t,op,UVM_ALL_ON)
      `uvm_field_object(pkt,UVM_ALL_ON)
      `uvm_field_int(id,UVM_ALL_ON)
      `uvm_field_int(cfg_id,UVM_ALL_ON)
      `uvm_field_int(cfg_enable,UVM_ALL_ON)
      `uvm_field_int(start,UVM_ALL_ON)
      `uvm_field_int(hold,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: c3po_transaction
