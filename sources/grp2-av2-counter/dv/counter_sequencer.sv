
class counter_transaction extends uvm_sequence_item;
parameter WIDTH_P = 4;

	rand bit[WIDTH_P-1:0] inc;
	rand bit en;
	bit reset_L;
	bit[WIDTH_P-1:0] val;
	// bit overflow;

	function new(string name = "");
		super.new(name);
	endfunction: new

	`uvm_object_utils_begin(counter_transaction)
		`uvm_field_int(inc, UVM_ALL_ON)
		`uvm_field_int(en, UVM_ALL_ON)
		`uvm_field_int(val, UVM_ALL_ON)
		`uvm_field_int(reset_L, UVM_ALL_ON)
	`uvm_object_utils_end

endclass: counter_transaction

class counter_sequence extends uvm_sequence#(counter_transaction);
	`uvm_object_utils(counter_sequence)

	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
		counter_transaction sa_tx;

		repeat(8) begin
		sa_tx = counter_transaction::type_id::create(.name("sa_tx"), .contxt(get_full_name()));

		start_item(sa_tx);
		assert(sa_tx.randomize());
		`uvm_info("Sequencia dada por sequencer: sa_sequence", sa_tx.sprint(), UVM_LOW);
		finish_item(sa_tx);
		end
	endtask: body
endclass: counter_sequence

typedef uvm_sequencer#(counter_transaction) counter_sequencer;
