class counter_monitor_before extends uvm_monitor;
    parameter WIDTH_P = 4;
	`uvm_component_utils(counter_monitor_before)

	uvm_analysis_port#(counter_transaction) mon_ap_before;

	virtual counter_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual counter_if)::read_by_name
			(.scope("ifs"), .name("counter_if"), .val(vif)));
		mon_ap_before = new(.name("mon_ap_before"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		integer counter_mon = 0, state = 0;

		counter_transaction sa_tx;
		sa_tx = counter_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clk)
			begin
				// if(vif.sig_en_o==1'b1)
				// begin
				// 	state = 3;
				// end

				// if(state==3)
				// begin
					// sa_tx.val = sa_tx.val << 1;
					sa_tx.inc = vif.sig_inc;
					sa_tx.val = vif.sig_val;
					sa_tx.en = vif.sig_en;
					sa_tx.reset_L = vif.sig_reset_L;


					counter_mon = counter_mon + 1;

					// if(counter_mon==1)
					// begin
						// state = 0;
						counter_mon = 0;

						//Send the transaction to the analysis port
					mon_ap_before.write(sa_tx);
					// end
					
						// `uvm_info("--------- monitor before --------");
					`uvm_info("monitor before", $sformatf("before_inc: %0d", sa_tx.inc), UVM_LOW);
					`uvm_info("monitor before", $sformatf("before_val: %0d", sa_tx.val), UVM_LOW);
                                        `uvm_info("monitor before", $sformatf("before_rst: %0d", sa_tx.reset_L), UVM_LOW);
                                        `uvm_info("monitor before", $sformatf("before_en: %0d", sa_tx.en), UVM_LOW);
				// end
			end
		end
	endtask: run_phase
endclass: counter_monitor_before

class counter_monitor_after extends uvm_monitor;
     parameter WIDTH_P = 4;
	`uvm_component_utils(counter_monitor_after)

	uvm_analysis_port#(counter_transaction) mon_ap_after;

	virtual counter_if vif;

	counter_transaction sa_tx;

	//For coverage
	counter_transaction sa_tx_cg;

	//Define coverpoints
	covergroup counter_cg;
      		inc_cp:     	coverpoint sa_tx_cg.inc;
      		en_cp:     		coverpoint sa_tx_cg.en;
      		reset_L_cp:     coverpoint sa_tx_cg.reset_L;
      		val_cp:     	coverpoint sa_tx_cg.val;
		cross inc_cp, val_cp, en_cp, reset_L_cp;
	endgroup: counter_cg

	function new(string name, uvm_component parent);
		super.new(name, parent);
		counter_cg = new;
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual counter_if)::read_by_name
			(.scope("ifs"), .name("counter_if"), .val(vif)));
		mon_ap_after= new(.name("mon_ap_after"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		// integer counter_mon = 0;
		sa_tx = counter_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clk)
			begin
				//if(vif.sig_en==1'b1)
				//begin
					// sa_tx.inc = WIDTH_P-1'b00;
					// sa_tx.val = WIDTH_P-1'b000;

					sa_tx.inc = vif.sig_inc;
					sa_tx.val = vif.sig_val;
					sa_tx.en = vif.sig_en;
					sa_tx.reset_L = vif.sig_reset_L;

					// sa_tx.en = vif.sig_en;
					// sa_tx.reset_L = vif.sig_reset_L;

					// counter_mon = counter_mon + 1;

					// if(counter_mon==1)
					// begin
						// state = 0;
						// counter_mon = 0;

						//Predict the result
						predictor();
						sa_tx_cg = sa_tx;

						//Coverage
						counter_cg.sample();

						//Send the transaction to the analysis port
						mon_ap_after.write(sa_tx);

						// `uvm_info("--------- monitor after --------");
						`uvm_info("monitor after", $sformatf("after_inc: %0d", sa_tx.inc), UVM_LOW);
						`uvm_info("monitor after", $sformatf("after_val: %0d", sa_tx.val), UVM_LOW);
                                                `uvm_info("monitor after", $sformatf("after_rst: %0d", sa_tx.reset_L), UVM_LOW);
                                                `uvm_info("monitor after", $sformatf("after_en: %0d", sa_tx.en), UVM_LOW);



					// end
				//end
			end
		end
	endtask: run_phase

	virtual function void predictor();
		
		if(sa_tx.en == 1)begin
			sa_tx.val <= sa_tx.val + sa_tx.inc;
		end
		if(sa_tx.reset_L == 0)begin
			sa_tx.val <= 0;
		end

	endfunction: predictor
endclass: counter_monitor_after
