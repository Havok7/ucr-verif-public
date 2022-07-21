
typedef enum
{
 OP_PACKET,
 OP_RESET_L,
 OP_VAL_L,
 OP_CFG_PORT_ID,
 OP_CFG_PORT_ENABLE,
 OP_MAX
} tlm_op_t;

class tlm_packet #(MAX_SIZE=1024) extends uvm_object;
   rand bit [MAX_SIZE*8-1:0] data;
   rand bit [9:0]   size;

   constraint limit_size { size >= 0; size <= MAX_SIZE; }
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

class c3po_data_tlm #(MAX_ID=4) extends uvm_sequence_item;
   // Transaction operation
   rand tlm_op_t op;
   // Packet information
   // Ops: [OP_PACKET]
   rand tlm_packet pkt;
   // Slice ID
   // Ops: [OP_PACKET]
   rand integer id;
   // Number of clock cycles before starting signal
   // Ops: [OP_RESET_L, OP_VAL_L]
   rand integer start;
   // Number of clock cycles to hold signal
   // Ops: [OP_RESET_L, OP_VAL_L]
   rand integer hold;

   constraint min_start { start >= 0; }
   constraint min_hold { hold >= 1; }
   constraint range_id { id >= 0; id < MAX_ID; }

   function new(string name = "");
      super.new(name);
      pkt = new("pkt");
   endfunction: new

   function c3po_data_tlm clone();
      c3po_data_tlm tlm;
      tlm = c3po_data_tlm::type_id::create(.name(get_name()), .contxt(get_full_name()));
      tlm.op = op;
      if (tlm.op == OP_PACKET) begin
         tlm.pkt = pkt.clone();
      end
      tlm.id = id;
      tlm.start = start;
      tlm.hold = hold;
      return tlm;
   endfunction: clone

   `uvm_object_utils_begin(c3po_data_tlm)
      `uvm_field_enum(tlm_op_t,op,UVM_ALL_ON)
      `uvm_field_object(pkt,UVM_ALL_ON)
      `uvm_field_int(id,UVM_ALL_ON)
      `uvm_field_int(start,UVM_ALL_ON)
      `uvm_field_int(hold,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: c3po_data_tlm

class c3po_reg_tlm #(MAX_ID=4) extends uvm_sequence_item;
   // Transaction operation
   rand tlm_op_t op;
   // Slice ID
   // Ops: [OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE]
   rand integer id;
   // Port ID to configure in Slice
   // Ops: [OP_CFG_PORT_ID]
   rand integer cfg_id;
   // Port Enable to configure in Slice
   // Ops: [OP_CFG_PORT_ENABLE]
   rand integer cfg_enable;
   // Number of clock cycles before starting signal
   // Ops: [OP_CFG_PORT_ID, OP_CFG_PORT_ENABLE]
   rand integer start;

   constraint min_start { start >= 0; }
   constraint range_id { id >= 0; id < MAX_ID; }
   constraint range_cfg_id { cfg_id >= 0; cfg_id < MAX_ID; }
   constraint range_cfg_enable { cfg_enable >= 0; cfg_enable <= 1; }

   function new(string name = "");
      super.new(name);
   endfunction: new

   function c3po_reg_tlm clone();
      c3po_reg_tlm tlm = c3po_reg_tlm::type_id::create(.name(get_name()), .contxt(get_full_name()));
      tlm.op = op;
      tlm.id = id;
      tlm.cfg_id = cfg_id;
      tlm.cfg_enable = cfg_enable;
      tlm.start = start;
      return tlm;
   endfunction: clone

   `uvm_object_utils_begin(c3po_reg_tlm)
      `uvm_field_enum(tlm_op_t,op,UVM_ALL_ON)
      `uvm_field_int(id,UVM_ALL_ON)
      `uvm_field_int(cfg_id,UVM_ALL_ON)
      `uvm_field_int(cfg_enable,UVM_ALL_ON)
      `uvm_field_int(start,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: c3po_reg_tlm
