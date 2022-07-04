class regs_agent extends uvm_agent;
	`uvm_component_utils(regs_agent)

	uvm_analysis_port#(regs_transaction) agent_ap_before;
	uvm_analysis_port#(regs_transaction) agent_ap_after;

	regs_sequencer		sa_seqr;
	regs_driver		sa_drvr;
	regs_monitor_before	sa_mon_before;
	regs_monitor_after	sa_mon_after;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		agent_ap_before	= new(.name("agent_ap_before"), .parent(this));
		agent_ap_after	= new(.name("agent_ap_after"), .parent(this));

		sa_seqr		= regs_sequencer::type_id::create(.name("sa_seqr"), .parent(this));
		sa_drvr		= regs_driver::type_id::create(.name("sa_drvr"), .parent(this));
		sa_mon_before	= regs_monitor_before::type_id::create(.name("sa_mon_before"), .parent(this));
		sa_mon_after	= regs_monitor_after::type_id::create(.name("sa_mon_after"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		sa_drvr.seq_item_port.connect(sa_seqr.seq_item_export);
		sa_mon_before.mon_ap_before.connect(agent_ap_before);
		sa_mon_after.mon_ap_after.connect(agent_ap_after);
	endfunction: connect_phase
endclass: regs_agent
