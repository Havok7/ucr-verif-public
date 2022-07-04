class counter_agent extends uvm_agent;

	`uvm_component_utils(counter_agent)

	uvm_analysis_port#(counter_tlm) agent_ap;

	counter_sequencer		seqr;

	counter_driver			driver;
	counter_monitor			monitor;


	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent_ap    = new(.name("agent_ap"), .parent(this));

		seqr		= counter_sequencer::type_id::create(.name("counter_seqr"), .parent(this));
		driver		= counter_driver::type_id::create(.name("counter_driver"), .parent(this));
		monitor	    = counter_monitor::type_id::create(.name("counter_monitor"), .parent(this));
	endfunction: build_phase


	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		driver.seq_item_port.connect(seqr.seq_item_export);
		monitor.mon_ap.connect(agent_ap);
	endfunction: connect_phase

endclass: counter_agent
