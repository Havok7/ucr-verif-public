class control_driver extends uvm_driver#(control_tlm);
	`uvm_component_utils(control_driver)

	virtual control_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		bit found;
		super.build_phase(phase);
		
		found = uvm_resource_db#(virtual control_if)::read_by_name(.scope("ifs"), .name("control_if"), .val(vif));
		`uvm_info("control_driver", $sformatf("ifc found %0d", found), UVM_LOW);
		if(!found) begin
			`uvm_fatal("control_driver", "ifc control_if not found");
		end
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		drive(phase);
	endtask: run_phase

	virtual task drive(uvm_phase phase);
		
		control_tlm	tlm;
		integer counter = 0, state = 0, ciclos = 0, cfg_flag = 0;

		vif.sop = 0;
		vif.eop = 0;
		vif.val = 0;
		vif.cfg_port_enable = 0;
		vif.reset_L = 0;

		forever begin
			if(counter == 0) begin
				seq_item_port.get_next_item(tlm);
			end

			// Creación de señales de inicio y final de paquetes
			@(posedge vif.clk) begin
				if(counter==0) begin
					vif.reset_L = 1;
					state = 1;
				end

				case(state)
					1: begin
						`uvm_info("control_driver", $sformatf("opcode_queue_size:%0d, pkt_type:%s, w_size:%0d", tlm.opcode.size(), tlm.pkt_type.name, tlm.w_size), UVM_LOW);
						foreach (tlm.opcode[i]) begin
							`uvm_info("opcode", $sformatf("toggling %s", tlm.opcode[i].name), UVM_LOW);
							case(tlm.opcode[i])
								RESET:
									vif.reset_L = ~vif.reset_L;
								CFG:
									// vif.cfg_port_enable = ~vif.cfg_port_enable;
									cfg_flag = 1;
								VAL:
									vif.val = ~vif.val;
							endcase
						end

						if(tlm.pkt_type == PKT_ERR_EOP) begin
							vif.eop = 1;
							vif.sop = 0;
						end else begin
							vif.sop = 1;
							vif.eop = 0;
						end

						if( (ciclos == (tlm.w_size-1) && tlm.pkt_type == PKT_OK) || (tlm.pkt_type == PKT_ERR_EOP) ) begin
							vif.eop = 1;
							seq_item_port.item_done();
						end else begin
							counter = counter + 1;
							if(counter==1) state = 2;
						end
					end

					2: begin
						ciclos = ciclos + 1;
						vif.sop = 0;


						if(ciclos >= (tlm.w_size-1)) begin
							if(tlm.pkt_type == PKT_ERR_SOP) begin
								vif.sop = 1;
							end else begin
								vif.eop = 1;
							end
							if(cfg_flag) vif.cfg_port_enable = ~vif.cfg_port_enable;

							cfg_flag = 0;
							counter = 0;
							state = 0;
							ciclos = 0;
							seq_item_port.item_done();
						end
					end

				endcase
			end
		end
	endtask: drive
endclass: control_driver
