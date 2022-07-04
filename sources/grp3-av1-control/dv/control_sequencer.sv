class control_transaction extends uvm_sequence_item;
	rand integer tam_palabras ;

	// constraint max_val {tam_palabras inside {[0:3]}}
	
	function new(string name = "");
		super.new(name);
	endfunction: new

	
	`uvm_object_utils_begin(control_transaction)
		`uvm_field_int(tam_palabras, UVM_ALL_ON)
	`uvm_object_utils_end
	
endclass: control_transaction

class control_sequence extends uvm_sequence#(control_transaction);
	`uvm_object_utils(control_sequence)

	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
		
		control_transaction ctr_tx;

		repeat(2) begin
		ctr_tx = control_transaction::type_id::create(.name("ctr_tx"), .contxt(get_full_name()));

		start_item(ctr_tx);
		ctr_tx.randomize() with {tam_palabras == 7; };
		`uvm_info("ctr_sequence", ctr_tx.sprint(), UVM_LOW);
		finish_item(ctr_tx);
		end
		
	endtask: body
endclass: control_sequence

typedef uvm_sequencer#(control_transaction) control_sequencer;
