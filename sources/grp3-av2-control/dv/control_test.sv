class control_test extends uvm_test;

	`uvm_component_utils(control_test)

	control_env ctr_env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		ctr_env = control_env::type_id::create(.name("ctr_env"), .parent(this));
		
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		control_sequence ctr_seq;

        `uvm_info("control_test", "Starting sim", UVM_LOW);
		
		phase.raise_objection(.obj(this));
		ctr_seq = control_sequence::type_id::create(.name("ctr_seq"), .contxt(get_full_name()));
		assert(ctr_seq.randomize());
		ctr_seq.start(ctr_env.ctr_agent.ctr_seqr);
		phase.drop_objection(.obj(this));

		#1000ns;
		`uvm_info("counter_test", "Simulation done", UVM_LOW);
	endtask: run_phase

endclass
