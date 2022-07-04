class counter_driver extends uvm_driver#(counter_tlm);

	`uvm_component_utils(counter_driver)

	virtual counter_if vif;
	semaphore key_ctrl;
	semaphore key_inc;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		key_ctrl = new(1);
		key_inc = new(1);
	endfunction: new


	function void build_phase(uvm_phase phase);
		bit found;
		super.build_phase(phase);

		found = uvm_resource_db#(virtual counter_if)::read_by_name(.scope("ifs"), .name("counter_if"), .val(vif));
		`uvm_info("counter_driver", $sformatf("ifc found %0d", found), UVM_LOW);
		if(!found) begin
			`uvm_fatal("counter_driver", "ifc counter_if not found");
		end
	endfunction: build_phase


	task run_phase(uvm_phase phase);
		counter_tlm tlm;
		counter_tlm tlm_inc;
		counter_tlm tlm_ctrl;
		tlm_ctrl = counter_tlm::type_id::create(.name("tlm_inc"), .contxt(get_full_name()));
		tlm_inc = counter_tlm::type_id::create(.name("tlm_ctrl"), .contxt(get_full_name()));

		vif.en = 0;
		vif.clr = 0;
		vif.inc = 0;
		vif.resetL = 0;

		forever begin
			seq_item_port.get_next_item(tlm);
			`uvm_info("counter_driver", $sformatf("%s d:%0d, h:%0d", tlm.opcode.name, tlm.data, tlm.hold), UVM_LOW);
			if( tlm.opcode inside {RESET, ENABLE, CLEAR} ) begin
				key_ctrl.get(1);
				tlm_ctrl.copy(tlm);
				fork begin
					drive_ctrl(tlm_ctrl, phase);
				end
				join_none
			end
			else begin
				key_inc.get(1);
				tlm_inc.copy(tlm);
				fork begin
					drive_inc(tlm_inc, phase);
				end
				join_none
			end
			seq_item_port.item_done();
		end

	endtask: run_phase


	task drive_ctrl(counter_tlm tlm, uvm_phase phase);
		phase.raise_objection(.obj(this));
		@(posedge vif.clk)
		`uvm_info("counter_driver", $sformatf("toggling %s", tlm.opcode.name), UVM_LOW);
		case(tlm.opcode)
			ENABLE:
				vif.en = ~vif.en;
			RESET:
				vif.resetL = ~vif.resetL;
			CLEAR:
				vif.clr = ~vif.clr;
		endcase
		key_ctrl.put(1);
		phase.drop_objection(.obj(this));
	endtask


	task drive_inc(counter_tlm tlm, uvm_phase phase);
		phase.raise_objection(.obj(this));
		@(posedge vif.clk)
		`uvm_info("counter_driver", $sformatf("incrementing %0d", tlm.data), UVM_LOW);
		vif.inc = tlm.data;
		repeat(tlm.hold) @(posedge vif.clk);
		key_inc.put(1);
		phase.drop_objection(.obj(this));
	endtask

endclass: counter_driver
