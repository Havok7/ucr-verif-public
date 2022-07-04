
class control_monitor_in extends uvm_monitor;
	`uvm_component_utils(control_monitor_in)

	uvm_analysis_port#(control_tlm) mon_ap_in;

	virtual control_if vif;

	control_tlm ctr_tx;
	
	//Define coverpoints
	`ifdef COVERAGE_ON
        covergroup covgrp1 ;
			// word_size: coverpoint ctr_tx.w_size;
			seq1: 	coverpoint ctr_tx.pkt_type {bins trans1 = (PKT_ERR_EOP => PKT_ERR_EOP => PKT_ERR_EOP);}  // Error de rtl previo
			seq2:	coverpoint ctr_tx.pkt_type {bins trans2 = (PKT_ERR_EOP => PKT_ERR_SOP => PKT_OK);}  // Error de rtl previo
			seq3:	coverpoint ctr_tx.pkt_type {bins trans3 = (PKT_ERR_SOP => PKT_OK);}  // Error SOP antes de OK
			seq4:	coverpoint ctr_tx.pkt_type {bins trans4 = (PKT_ERR_EOP => PKT_OK);}  // Error EOP antes de OK
			seq5:	coverpoint ctr_tx.pkt_type {bins trans5 = (PKT_RESET => PKT_ERR_SOP => PKT_ERR_EOP);}  // Caso RESET antes de error
			seq6:	coverpoint ctr_tx.pkt_type {bins trans6 = (PKT_RESET => PKT_OK => PKT_ERR_EOP);}  // Caso RESET antes de OK
        endgroup
	`endif

	function new(string name, uvm_component parent);
		super.new(name, parent);
		
		`ifdef COVERAGE_ON
			covgrp1  = new();
		`endif
		
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		// covgrp1 cg1 = new();
		void'(uvm_resource_db#(virtual control_if)::read_by_name
			(.scope("ifs"), .name("control_if"), .val(vif)));
		mon_ap_in = new(.name("mon_ap_in"), .parent(this));
		
	endfunction: build_phase

	task run_phase(uvm_phase phase);

	integer counter_mon = 0, state = 0;

	
	ctr_tx = control_tlm::type_id::create
		(.name("ctr_tx"), .contxt(get_full_name()));

	forever begin
		@(negedge vif.clk) begin
			if(vif.reset_L) begin

			if(counter_mon==0) state = 1;

			case (state)
				1: begin
					if(vif.sop && vif.val) begin
						
						if(vif.eop) begin
						
							ctr_tx.pkt_type = PKT_OK;
							`uvm_info("MONITOR_IN", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
							mon_ap_in.write(ctr_tx);
							covgrp1.sample();
						end else begin
							counter_mon = counter_mon + 1;
							if(counter_mon==1) state = 2;
						end
						
					end

					if(vif.eop && vif.val && !vif.sop) begin
						ctr_tx.pkt_type = PKT_ERR_EOP;
						`uvm_info("MONITOR_IN", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_in.write(ctr_tx);
						covgrp1.sample();
					end
				end

				2: begin
					if(vif.eop && vif.val && !vif.sop) begin
						ctr_tx.pkt_type = PKT_OK;
						counter_mon = 0;
						state = 0;
						`uvm_info("MONITOR_IN", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_in.write(ctr_tx);
						covgrp1.sample();
					end

					if(vif.sop && vif.val) begin
						ctr_tx.pkt_type = PKT_ERR_SOP;
						counter_mon = 0;
						state = 0;
						`uvm_info("MONITOR_IN", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_in.write(ctr_tx);
						covgrp1.sample();
					end
				end
			endcase
			end else begin
				ctr_tx.pkt_type = PKT_RESET;
				`uvm_info("MONITOR_IN", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
				mon_ap_in.write(ctr_tx);
				covgrp1.sample();
			end
		end
	end
		
	endtask: run_phase
endclass: control_monitor_in

class control_monitor_out extends uvm_monitor;
	`uvm_component_utils(control_monitor_out)

	uvm_analysis_port#(control_tlm) mon_ap_out;

	virtual control_if vif;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(uvm_resource_db#(virtual control_if)::read_by_name
			(.scope("ifs"), .name("control_if"), .val(vif)));
		mon_ap_out= new(.name("mon_ap_out"), .parent(this));
	endfunction: build_phase

	task run_phase(uvm_phase phase);

	integer counter_mon = 0, state = 0, en_err_flag = 0;

	logic cfg_start;
	
	control_tlm ctr_tx;
	ctr_tx = control_tlm::type_id::create(.name("ctr_tx"), .contxt(get_full_name()));

	forever begin
		@(negedge vif.clk) begin
			if(vif.reset_L) begin

			if(counter_mon==0) state = 1;

			case (state)
				1: begin

					if(vif.sop && vif.val) begin
						cfg_start = vif.cfg_port_enable;
						if(vif.eop) begin
							if (vif.enable == cfg_start) begin
								ctr_tx.pkt_type = PKT_OK;
							end else begin
								ctr_tx.pkt_type = PKT_ERR_EN;
							end
							`uvm_info("MONITOR_OUT", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
							mon_ap_out.write(ctr_tx);
						end else begin
							counter_mon = counter_mon + 1;
							if(counter_mon==1) state = 2;
						end
					end

					if(vif.eop && vif.val && !vif.sop) begin
						if (vif.err) begin
							ctr_tx.pkt_type = PKT_ERR_EOP;
						end else begin
							ctr_tx.pkt_type = PKT_OK;
						end
						`uvm_info("MONITOR_OUT", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_out.write(ctr_tx);
					end

				end

				2: begin

					if(vif.enable != cfg_start) en_err_flag = 1;

					if(vif.eop && vif.val) begin
						if(vif.sop) begin
							if (vif.err) begin
								ctr_tx.pkt_type = PKT_ERR_SOP;
							end else begin
								ctr_tx.pkt_type = PKT_OK;
							end
						end else begin
							if (en_err_flag) begin
								ctr_tx.pkt_type = PKT_ERR_EN;
							end else if (vif.err) begin
								ctr_tx.pkt_type = PKT_ERR_EOP;
							end else begin
								ctr_tx.pkt_type = PKT_OK;
							end
						end
						counter_mon = 0;
						state = 0;
						en_err_flag = 0;
						`uvm_info("MONITOR_OUT", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_out.write(ctr_tx);
					end

					if(vif.sop && vif.val && !vif.eop) begin
						if (vif.err) begin
							ctr_tx.pkt_type = PKT_ERR_SOP;
						end else begin
							ctr_tx.pkt_type = PKT_OK;
						end
						counter_mon = 0;
						state = 0;
						en_err_flag = 0;
						`uvm_info("MONITOR_OUT", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
						mon_ap_out.write(ctr_tx);
					end

				end
			endcase
			end else begin
				ctr_tx.pkt_type = PKT_RESET;
				`uvm_info("MONITOR_OUT", $sformatf("TLM: %s", ctr_tx.pkt_type.name), UVM_LOW);
				mon_ap_out.write(ctr_tx);
			end
		end
	end
		
	endtask: run_phase

endclass: control_monitor_out
