class counter_driver extends uvm_driver#(counter_tlm);

	`uvm_component_utils(counter_driver)

	virtual counter_if vif;


	function new(string name, uvm_component parent);
		super.new(name, parent);
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

		vif.en = 0;
		vif.clr = 0;
		vif.inc = 0;
		vif.resetL = 0;

		forever begin
			seq_item_port.get_next_item(tlm);
			`uvm_info("counter_driver3", $sformatf("opcode_size:%0d, d:%0d", tlm.opcode.size(), tlm.data), UVM_LOW);

			@(posedge vif.clk)
			vif.inc = tlm.data;
			foreach (tlm.opcode[i]) begin
				`uvm_info("opcode", $sformatf("%s", tlm.opcode[i].name), UVM_LOW);
				case(tlm.opcode[i])
					ENABLE:
						vif.en = ~vif.en;
					RESET:
						vif.resetL = ~vif.resetL;
					CLEAR:
						vif.clr = ~vif.clr;
				endcase
			end
			seq_item_port.item_done();
		end

	endtask: run_phase


endclass: counter_driver
