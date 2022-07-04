class counter_monitor extends uvm_monitor;


	uvm_analysis_port#(counter_tlm) mon_ap;

	virtual counter_if vif;

    `uvm_component_utils(counter_monitor)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new


	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual counter_if)::read_by_name
			(.scope("ifs"), .name("counter_if"), .val(vif)));
		mon_ap = new(.name("mon_ap"), .parent(this));
	endfunction: build_phase


	task run_phase(uvm_phase phase);
		counter_tlm tlm;
		tlm = counter_tlm::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));

		fork
			// mon_en();
			//mon_clr();
			//mon_overflow();
			// mon_inc();
		join_none

	endtask: run_phase


	// task mon_inc();
	// 	counter_tlm tlm;
	// 	tlm = counter_tlm::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));
	// 	forever begin
	// 		@(vif.inc)
	// 		if(vif.en) begin
	// 			tlm.opcode = INC;
	// 			tlm.data = vif.inc;
	// 			`uvm_info("counter_monitor", $sformatf("%s d:%0d", tlm.opcode.name, tlm.data), UVM_LOW);
	// 			mon_ap.write(tlm);
	// 		end
	// 	end
	// endtask


	// task mon_en();
	// 	counter_tlm tlm;
	// 	tlm = counter_tlm::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));
	// 	forever begin
	// 		@(vif.en)
	// 		tlm.opcode = ENABLE;
	// 		tlm.data = vif.en;
	// 		`uvm_info("counter_monitor", $sformatf("%s d:%0d", tlm.opcode.name, tlm.data), UVM_LOW);
	// 		mon_ap.write(tlm);
	// 	end
	// endtask


endclass: counter_monitor

