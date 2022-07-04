class control_agent extends uvm_agent;
	`uvm_component_utils(control_agent)

	uvm_analysis_port#(control_transaction) agent_ap_before;
	uvm_analysis_port#(control_transaction) agent_ap_after;

	control_sequencer		ctr_seqr;
	control_driver		ctr_drvr;
	control_monitor_before	ctr_mon_before;
	control_monitor_after	ctr_mon_after;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent_ap_before	= new(.name("agent_ap_before"), .parent(this));
		agent_ap_after	= new(.name("agent_ap_after"), .parent(this));

		ctr_seqr		= control_sequencer::type_id::create(.name("ctr_seqr"), .parent(this));
		ctr_drvr		= control_driver::type_id::create(.name("ctr_drvr"), .parent(this));
		ctr_mon_before	= control_monitor_before::type_id::create(.name("ctr_mon_before"), .parent(this));
		ctr_mon_after	= control_monitor_after::type_id::create(.name("ctr_mon_after"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		ctr_drvr.seq_item_port.connect(ctr_seqr.seq_item_export);
		ctr_mon_before.mon_ap_before.connect(agent_ap_before);
		ctr_mon_after.mon_ap_after.connect(agent_ap_after);
	endfunction: connect_phase
endclass: control_agent
