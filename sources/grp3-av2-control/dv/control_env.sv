class control_env extends uvm_env;
	`uvm_component_utils(control_env)
	
	control_agent ctr_agent;
	control_scoreboard ctr_sb;
	

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		ctr_agent	= control_agent::type_id::create(.name("ctr_agent"), .parent(this));
		ctr_sb		= control_scoreboard::type_id::create(.name("ctr_sb"), .parent(this));
		
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		ctr_agent.agent_ap_in.connect(ctr_sb.sb_export_in);
		ctr_agent.agent_ap_out.connect(ctr_sb.sb_export_out);
		
	endfunction: connect_phase
endclass: control_env
