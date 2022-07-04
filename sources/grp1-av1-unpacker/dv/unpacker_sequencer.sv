class txn_packet #(max_size=1024) extends uvm_object;
   rand bit [max_size*8-1:0] data;
   rand bit [10:0]   size;

   constraint limit_size { size >= 0; size <= max_size; }
   constraint limit_data { data <= (1 << (size * 8)) - 1; }

   function new(string name = "");
      super.new(name);
   endfunction: new

   function txn_packet clone();
      txn_packet pkt;
      pkt = txn_packet::type_id::create(.name(get_name()), .contxt(get_full_name()));
      pkt.data = data;
      pkt.size = size;
      return pkt;
   endfunction: clone

   `uvm_object_utils_begin(txn_packet)
      `uvm_field_int(data,UVM_ALL_ON)
      `uvm_field_int(size,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: txn_packet

class unpacker_transaction extends uvm_sequence_item;
   typedef enum {
      OP_PACKET
   } op_t;

   op_t op;
   rand txn_packet pkt;

   function new(string name = "");
      super.new(name);
      pkt = new("pkt");
   endfunction: new

   function unpacker_transaction clone();
      unpacker_transaction tx;
      tx = unpacker_transaction::type_id::create(.name(get_name()), .contxt(get_full_name()));
      tx.pkt = pkt.clone();
      return tx;
   endfunction: clone

   `uvm_object_utils_begin(unpacker_transaction)
      `uvm_field_enum(op_t,op,UVM_ALL_ON)
      `uvm_field_object(pkt,UVM_ALL_ON)
   `uvm_object_utils_end
endclass: unpacker_transaction

class unpacker_sequence extends uvm_sequence#(unpacker_transaction);
   `uvm_object_utils(unpacker_sequence)

   rand unpacker_transaction tx;
   integer      num_pkts, low_size, high_size;

   function new(string name = "", integer num_pkts = 10, low_size = 1, high_size = 1024);
      super.new(name);
      this.num_pkts = num_pkts;
      this.low_size = low_size;
      this.high_size = high_size;
      this.tx = unpacker_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
   endfunction: new

   task body();

      repeat(num_pkts) begin
         start_item(tx);
         assert(tx.randomize() with {low_size <= pkt.size && pkt.size <= high_size;});
         finish_item(tx);
      end
   endtask: body
endclass: unpacker_sequence

typedef uvm_sequencer#(unpacker_transaction) unpacker_sequencer;
