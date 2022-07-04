class control_agent extends uvm_agent;
	`uvm_component_utils(control_agent)

	
	uvm_analysis_port#(control_tlm) agent_ap_in;
	uvm_analysis_port#(control_tlm) agent_ap_out;

	control_sequencer		ctr_seqr;
	control_driver			ctr_drvr;
	control_monitor_in		ctr_mon_in;
	control_monitor_out		ctr_mon_out;
	

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		
		agent_ap_in	=	new(.name("agent_ap_in"), .parent(this));
		agent_ap_out =	new(.name("agent_ap_out"), .parent(this));

		ctr_seqr		= control_sequencer::type_id::create(.name("ctr_seqr"), .parent(this));
		ctr_drvr		= control_driver::type_id::create(.name("ctr_drvr"), .parent(this));
		ctr_mon_in		= control_monitor_in::type_id::create(.name("ctr_mon_in"), .parent(this));
		ctr_mon_out		= control_monitor_out::type_id::create(.name("ctr_mon_out"), .parent(this));

	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		ctr_drvr.seq_item_port.connect(ctr_seqr.seq_item_export);
		ctr_mon_in.mon_ap_in.connect(agent_ap_in);
		ctr_mon_out.mon_ap_out.connect(agent_ap_out);
		
	endfunction: connect_phase
endclass: control_agent
