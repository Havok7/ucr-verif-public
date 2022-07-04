class control_sequence extends uvm_sequence#(control_tlm);
	`uvm_object_utils(control_sequence)

	function new(string name = "");
		super.new(name);
	endfunction: new

	task body();
		
		control_tlm ctr_tx;
		ctr_tx = control_tlm::type_id::create(.name("ctr_tx"), .contxt(get_full_name()));

		repeat(150) begin
		start_item(ctr_tx);
		assert(ctr_tx.randomize());
		finish_item(ctr_tx);
		end
		
	endtask: body
endclass: control_sequence
