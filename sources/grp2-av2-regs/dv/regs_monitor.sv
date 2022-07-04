
// -------------------------------------------

class regs_monitor_before extends uvm_monitor;


	uvm_analysis_port#(regs_transaction) mon_ap_in;

	virtual regs_if vif;

    `uvm_component_utils(regs_monitor_before)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual regs_if)::read_by_name
			(.scope("ifs"), .name("regs_if"), .val(vif)));
		mon_ap_in = new(.name("mon_ap_in"), .parent(this));
	endfunction: build_phase


	task run_phase(uvm_phase phase);
	 	integer counter = 0;
		regs_transaction tlm;
		tlm = regs_transaction::type_id::create(.name("tlm"), .contxt(get_full_name()));
      	`uvm_info(get_full_name(), "monitor_in: start", UVM_LOW)

		forever begin
			fork
				mon_request();
				mon_reset();
			join


		end

	endtask: run_phase

	// Task when requesting a read o write
	task mon_request();
		regs_transaction tlm;
		tlm = regs_transaction::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));
		forever begin
			@(vif.sig_clk)
			if(vif.sig_req)begin
				if(vif.sig_rd_wr == '1) begin
					tlm.operation = READ;
					tlm.address = vif.sig_addr;
					`uvm_info("regs_monitor_in: READ:", $sformatf("%d >> data:%0d", tlm.address, tlm.data_stream), UVM_LOW);
					mon_ap_in.write(tlm);
				end
				if(vif.sig_rd_wr == '0) begin
					tlm.operation = WRITE;
					tlm.address = vif.sig_addr;
					tlm.data_stream = vif.sig_write_val;
					`uvm_info("regs_monitor_in: WRITE:", $sformatf("%d >> data:%0d", tlm.address, tlm.data_stream), UVM_LOW);
					mon_ap_in.write(tlm);
				end
			end
		end
	endtask

	// Reset
	task mon_reset();
		regs_transaction tlm;
		tlm = regs_transaction::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));
		forever begin
			@(vif.sig_clk)
			if(vif.sig_reset_L == 1)begin
				tlm.operation = RESET;
				`uvm_info("regs_monitor_in: RESET:", $sformatf("%d >> data:%0d", tlm.address, tlm.data_stream), UVM_LOW);
				mon_ap_in.write(tlm);
			end
		end
	endtask


endclass: regs_monitor_before







class regs_monitor_after extends uvm_monitor;


	uvm_analysis_port#(regs_transaction) mon_ap_out;

	virtual regs_if vif;

    `uvm_component_utils(regs_monitor_after)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual regs_if)::read_by_name
			(.scope("ifs"), .name("regs_if"), .val(vif)));
		mon_ap_out = new(.name("mon_ap_out"), .parent(this));
	endfunction: build_phase


	task run_phase(uvm_phase phase);
	 	integer counter = 0;
		regs_transaction tlm;
		tlm = regs_transaction::type_id::create(.name("tlm"), .contxt(get_full_name()));
      	`uvm_info(get_full_name(), "monitor_out: start", UVM_LOW)

		forever begin
			fork
				mon_ack();
			join
		end

	endtask: run_phase

	// ack of a transaction
	task mon_ack();
		regs_transaction tlm;
		tlm = regs_transaction::type_id::create(.name("mon_tlm"), .contxt(get_full_name()));
		forever begin
			@(vif.sig_clk)
			if(vif.sig_ack == 1)begin
				tlm.operation = DONE;
				tlm.data_stream = vif.sig_read_val;
				`uvm_info("regs_monitor_out: ACK:", $sformatf("%d >> data:%0d", tlm.address, tlm.data_stream), UVM_LOW);
				mon_ap_out.write(tlm);
			end
			else begin
				tlm.operation = WAIT;
				`uvm_info("regs_monitor_out: WAIT:", $sformatf("%d >> data:%0d", tlm.address, tlm.data_stream), UVM_LOW);
			end
		end
	endtask


endclass: regs_monitor_after










