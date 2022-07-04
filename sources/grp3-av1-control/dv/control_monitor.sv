class control_monitor_before extends uvm_monitor;
	`uvm_component_utils(control_monitor_before)

	uvm_analysis_port#(control_transaction) mon_ap_before;

	virtual control_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		void'(uvm_resource_db#(virtual control_if)::read_by_name
			(.scope("ifs"), .name("control_if"), .val(vif)));
		mon_ap_before = new(.name("mon_ap_before"), .parent(this));
		
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		
		// integer counter_mon = 0, state = 0;

		// control_transaction ctr_tx;
		// ctr_tx = control_transaction::type_id::create
		// 	(.name("ctr_tx"), .contxt(get_full_name()));

		// forever begin
		// 	@(posedge vif.clk)
		// 	begin
		// 		/*
		// 		if(vif.enable==1'b1)
		// 		begin
		// 			state = 3;
		// 		end

		// 		if(state==3)
		// 		begin
		// 		*/
		// 			ctr_tx.enable = ctr_tx.enable << 1;
		// 			ctr_tx.enable[0] = vif.enable;

		// 			ctr_tx.err = ctr_tx.err << 1;
		// 			ctr_tx.err[0] = vif.err;

		// 			counter_mon = counter_mon + 1;

		// 			if(counter_mon==3)
		// 			begin
		// 				state = 0;
		// 				counter_mon = 0;

		// 				//Send the transaction to the analysis port
		// 				mon_ap_before.write(ctr_tx);
		// 			end
		// 		//end
		// 	end
		// end
		
	endtask: run_phase
endclass: control_monitor_before

class control_monitor_after extends uvm_monitor;
	`uvm_component_utils(control_monitor_after)

	uvm_analysis_port#(control_transaction) mon_ap_after;

	virtual control_if vif;

	control_transaction ctr_tx;

	//For coverage
	// control_transaction ctr_tx_cg;

	
	//Define coverpoints
	// covergroup control_cg;
    //   		val_cp:     coverpoint ctr_tx_cg.val;
    //   		sop_cp:     coverpoint ctr_tx_cg.sop;
	// 		eop_cp:     coverpoint ctr_tx_cg.eop;
	// 	cross val_cp, sop_cp, eop_cp;
	// endgroup: control_cg
	

	function new(string name, uvm_component parent);
		super.new(name, parent);
		
		// control_cg = new;
		
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		void'(uvm_resource_db#(virtual control_if)::read_by_name
			(.scope("ifs"), .name("control_if"), .val(vif)));
		mon_ap_after= new(.name("mon_ap_after"), .parent(this));
		
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		
		// integer counter_mon = 0, state = 0;
		// ctr_tx = control_transaction::type_id::create
		// 	(.name("ctr_tx"), .contxt(get_full_name()));

		// forever begin
		// 	@(posedge vif.clk)
		// 	begin/*
		// 		if(vif.sig_en_i==1'b1)
		// 		begin*/
		// 			state = 1;
		// 			ctr_tx.val = 2'b00;
		// 			ctr_tx.sop = 2'b00;
		// 			ctr_tx.eop = 2'b00;
		// 			ctr_tx.enable = 3'b000;
		// 			ctr_tx.err = 3'b000;
		// 		//end

		// 		if(state==1)
		// 		begin
		// 			ctr_tx.val = ctr_tx.val << 1;
		// 			ctr_tx.sop = ctr_tx.sop << 1;
		// 			ctr_tx.eop = ctr_tx.eop << 1;

		// 			ctr_tx.val[0] = vif.val;
		// 			ctr_tx.sop[0] = vif.sop;
		// 			ctr_tx.eop[0] = vif.eop;

		// 			counter_mon = counter_mon + 1;

		// 			if(counter_mon==2)
		// 			begin
		// 				state = 0;
		// 				counter_mon = 0;

		// 				//Predict the result
		// 				predictor();
		// 				ctr_tx_cg = ctr_tx;

		// 				//Coverage
		// 				control_cg.sample();

		// 				//Send the transaction to the analysis port
		// 				mon_ap_after.write(ctr_tx);
		// 			end
		// 		end
		// 	end
		// end
		
	endtask: run_phase

	virtual function void predictor();
		
		// ctr_tx.enable = ctr_tx.val + ctr_tx.sop;
		// ctr_tx.err = ctr_tx.val + ctr_tx.eop;
		
	endfunction: predictor
endclass: control_monitor_after
