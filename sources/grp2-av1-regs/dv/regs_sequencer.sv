
class regs_transaction extends uvm_sequence_item;
parameter ADDR_SIZE_P = 4;


	bit[ADDR_SIZE_P-1:0] addr;
	bit rd_wr;
	rand bit req;
	rand bit [31:0] write_val;
	bit reset_L;
	bit [31:0] read_val;
	bit ack;

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(regs_transaction)
		`uvm_field_int(addr, UVM_ALL_ON)
		`uvm_field_int(rd_wr, UVM_ALL_ON)
		`uvm_field_int(req, UVM_ALL_ON)
		`uvm_field_int(write_val, UVM_ALL_ON)
		`uvm_field_int(reset_L, UVM_ALL_ON)
		`uvm_field_int(read_val, UVM_ALL_ON)
		`uvm_field_int(ack, UVM_ALL_ON)
	`uvm_object_utils_end
endclass: regs_transaction

// class regs_transaction extends uvm_sequence_item;
// parameter ADDR_SIZE_P = 4;


// 	rand bit[ADDR_SIZE_P-1:0] addr;
// 	bit rd_wr;
// 	rand bit req;
// 	rand bit [31:0] write_val;
// 	bit reset_L;
// 	bit [31:0] read_val;
// 	bit ack;

// 	function new(string name = "");
// 		super.new(name);
// 	endfunction: new

// 	`uvm_object_utils_begin(regs_transaction)
// 		`uvm_field_int(addr, UVM_ALL_ON)
// 		`uvm_field_int(rd_wr, UVM_ALL_ON)
// 		`uvm_field_int(req, UVM_ALL_ON)
// 		`uvm_field_int(write_val, UVM_ALL_ON)
// 		`uvm_field_int(reset_L, UVM_ALL_ON)
// 		`uvm_field_int(read_val, UVM_ALL_ON)
// 		`uvm_field_int(ack, UVM_ALL_ON)
// 	`uvm_object_utils_end
// endclass: regs_transaction

class regs_sequence extends uvm_sequence#(regs_transaction);
	`uvm_object_utils(regs_sequence)

	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
		regs_transaction sa_tx;

		repeat(2) begin
		sa_tx = regs_transaction::type_id::create(.name("sa_tx"), .contxt(get_full_name()));
		// sa_tx_2 = regs_transaction::type_id::create(.name("sa_tx"), .contxt(get_full_name()));
		
		start_item(sa_tx);

		assert(sa_tx.randomize());
		// `uvm_info("sa_sequence", sa_tx.sprint(), UVM_LOW);
		finish_item(sa_tx);
		end
	endtask: body
endclass: regs_sequence

typedef uvm_sequencer#(regs_transaction) regs_sequencer;
