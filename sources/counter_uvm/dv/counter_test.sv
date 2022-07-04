

class counter_test extends uvm_test;

	`uvm_component_utils(counter_test)

	counter_env env;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = counter_env::type_id::create(.name("counter_env"), .parent(this));
	endfunction: build_phase


	task run_phase(uvm_phase phase);
		counter_sequence seq;

		`uvm_info("counter_test", "Starting simulation", UVM_LOW);
		phase.raise_objection(.obj(this));
		seq = counter_sequence::type_id::create(.name("cnt_seq"), .contxt(get_full_name()));
		assert(seq.randomize());
		seq.start(env.cnt_agent.seqr);
		phase.drop_objection(.obj(this));

		#1000ns;
		`uvm_info("counter_test", "Simulation done", UVM_LOW);
	endtask: run_phase

endclass
