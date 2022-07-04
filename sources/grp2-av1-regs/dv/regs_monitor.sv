class regs_monitor_before extends uvm_monitor;
    parameter ADDR_SIZE_P = 4;
	`uvm_component_utils(regs_monitor_before)

	uvm_analysis_port#(regs_transaction) mon_ap_before;

	virtual regs_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual regs_if)::read_by_name
			(.scope("ifs"), .name("regs_if"), .val(vif)));
		mon_ap_before = new(.name("mon_ap_before"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		integer regs_mon = 0, state = 0;

		regs_transaction sa_tx;
		sa_tx = regs_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clk)
			begin
				// // if(vif.sig_en_o==1'b1)
				// // begin
				// // 	state = 3;
				// // end

				// // if(state==3)
				// // begin
				// 	sa_tx.val = sa_tx.val << 1;
				// 	sa_tx.val[0] = vif.sig_val;

				sa_tx.addr = vif.sig_addr;
				sa_tx.rd_wr = vif.sig_rd_wr;
				sa_tx.req = vif.sig_req;
				sa_tx.write_val = vif.sig_write_val; 
				sa_tx.reset_L = vif.sig_reset_L;
				sa_tx.read_val = vif.sig_read_val;

					regs_mon = regs_mon + 1;

					// if(regs_mon==3)
					// begin
						state = 0;
						regs_mon = 0;

						//Send the transaction to the analysis port
						mon_ap_before.write(sa_tx);

					// `uvm_info("--------- monitor before --------");
					`uvm_info("monitor before", $sformatf("before_addr: %0d", sa_tx.addr), UVM_LOW);
					`uvm_info("monitor before", $sformatf("before_write_val: %0d", sa_tx.write_val), UVM_LOW);
                    `uvm_info("monitor before", $sformatf("before_rst: %0d", sa_tx.reset_L), UVM_LOW);
					`uvm_info("monitor before", $sformatf("before_req: %0d", sa_tx.req), UVM_LOW);
					`uvm_info("monitor before", $sformatf("before_R/W: %0d", sa_tx.rd_wr), UVM_LOW);
					`uvm_info("monitor before", $sformatf("before_ack: %0d", sa_tx.ack), UVM_LOW);

					// end
				// end
			end
		end
	endtask: run_phase
endclass: regs_monitor_before

class regs_monitor_after extends uvm_monitor;
     parameter WIDTH_P = 4;
	`uvm_component_utils(regs_monitor_after)

	uvm_analysis_port#(regs_transaction) mon_ap_after;

	virtual regs_if vif;

	regs_transaction sa_tx;

	//For coverage
	regs_transaction sa_tx_cg;

	//Define coverpoints
	covergroup regs_cg;
      		// inc_cp:     coverpoint sa_tx_cg.inc;
      		// val_cp:     coverpoint sa_tx_cg.val;
		// cross inc_cp, val_cp;
	endgroup: regs_cg

	function new(string name, uvm_component parent);
		super.new(name, parent);
		regs_cg = new;
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual regs_if)::read_by_name
			(.scope("ifs"), .name("regs_if"), .val(vif)));
		mon_ap_after= new(.name("mon_ap_after"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		integer regs_mon = 0, state = 0;
		sa_tx = regs_transaction::type_id::create
			(.name("sa_tx"), .contxt(get_full_name()));

		forever begin
			@(posedge vif.sig_clk)
			begin
				// if(vif.sig_en==1'b1)
				// begin
				// 	state = 1;
					// sa_tx.inc = WIDTH_P-1'b00;
					// // sa_tx.inb = 2'b00;
					// sa_tx.val = WIDTH_P-1'b000;
				// end

				sa_tx.addr = vif.sig_addr;
				sa_tx.rd_wr = vif.sig_rd_wr;
				sa_tx.req = vif.sig_req;
				sa_tx.write_val = vif.sig_write_val; 
				sa_tx.reset_L = vif.sig_reset_L;
				sa_tx.read_val = vif.sig_read_val;

				// if(state==1)
				// begin
					// sa_tx.inc = sa_tx.inc << 1;
					// // sa_tx.inb = sa_tx.inb << 1;

					// sa_tx.inc[0] = vif.sig_inc;
					// // sa_tx.inb[0] = vif.sig_inb;

					regs_mon = regs_mon + 1;

					// if(regs_mon==2)
					// begin
						state = 0;
						regs_mon = 0;

						//Predict the result
						predictor();
						sa_tx_cg = sa_tx;

						//Coverage
						regs_cg.sample();

						//Send the transaction to the analysis port
						mon_ap_after.write(sa_tx);

					// `uvm_info("--------- monitor after --------");
					`uvm_info("monitor after", $sformatf("after_addr: %0d", sa_tx.addr), UVM_LOW);
					`uvm_info("monitor after", $sformatf("after_write_val: %0d", sa_tx.write_val), UVM_LOW);
                    `uvm_info("monitor after", $sformatf("after_rst: %0d", sa_tx.reset_L), UVM_LOW);
					`uvm_info("monitor after", $sformatf("after_req: %0d", sa_tx.req), UVM_LOW);
					`uvm_info("monitor after", $sformatf("after_R/W: %0d", sa_tx.rd_wr), UVM_LOW);
					`uvm_info("monitor after", $sformatf("after_ack: %0d", sa_tx.ack), UVM_LOW);

					// end
				// end
			end
		end
	endtask: run_phase

	virtual function void predictor();
		//sa_tx.val = sa_tx.val + sa_tx.inc;
	endfunction: predictor
endclass: regs_monitor_after
