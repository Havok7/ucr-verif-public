class counter_test extends uvm_test;

	`uvm_component_utils(counter_test)

	counter_env sa_env;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sa_env = counter_env::type_id::create(.name("sa_env"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		counter_sequence sa_seq;

		phase.raise_objection(.obj(this));
			sa_seq = counter_sequence::type_id::create(.name("sa_seq"), .contxt(get_full_name()));
			assert(sa_seq.randomize());
			sa_seq.start(sa_env.sa_agent.sa_seqr);
		phase.drop_objection(.obj(this));
	endtask: run_phase

endclass: counter_test
