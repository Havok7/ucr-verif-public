class regs_driver extends uvm_driver#(regs_transaction);
	parameter ADDR_SIZE_P = 4;

	`uvm_component_utils(regs_driver)

	virtual regs_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual regs_if)::read_by_name
			(.scope("ifs"), .name("regs_if"), .val(vif)));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		drive();
	endtask: run_phase

	virtual task drive();

		regs_transaction sa_tx;
		integer counter = 0, state = 0;
	

        vif.sig_addr = '0;
        vif.sig_req = '0;
        vif.sig_rd_wr = '0;
        vif.sig_write_val = 0;
        vif.sig_cfg_ctrl_err = '0;
        vif.sig_cfg_ctrl_idle = '0;
		vif.sig_reset_L = '0;
		vif.sig_ack = '0;


		forever begin
			if(counter==0)
			begin
				seq_item_port.get_next_item(sa_tx);
				`uvm_info("PEDIDO POR DRIVER: sa_driver", sa_tx.sprint(), UVM_LOW);
			end

			@(posedge vif.sig_clk)
			// `uvm_info("sa_driver", $sformatf("sa_driver, address: %0d", addr), UVM_LOW);/
			// `uvm_info("sa_driver", $sformatf("sa_driver, W/R: %0d", rd_wr), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, req: %0d", req), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, Reset: %0d", reset_L), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, write_val: %0d", write_val), UVM_LOW);

			// `uvm_info("sa_driver", $sformatf("sa_driver, read_val: %0d", read_val), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, ack: %0d", ack), UVM_LOW);


			begin
	
				

				if(counter==0)
				begin
					vif.sig_req = '1;
					vif.sig_rd_wr = '0;
					vif.sig_write_val = '0;
					vif.sig_cfg_ctrl_err = '0;
					vif.sig_cfg_ctrl_idle = '0;
					vif.sig_reset_L = '1;
					vif.sig_ack = '0;
				end

				vif.sig_addr = sa_tx.addr;
				vif.sig_rd_wr = sa_tx.rd_wr;
				vif.sig_req = sa_tx.req;
				vif.sig_write_val = sa_tx.write_val;
				// vif.sig_reset_L = sa_tx.reset_L;
				
				if(counter == 1)
				begin
					vif.sig_req = 0;
				end

				counter = counter + 1;

				if(vif.sig_ack==1)
				begin
					vif.sig_req = '1;
					vif.sig_rd_wr = '1;
					vif.sig_write_val = '0;
					vif.sig_cfg_ctrl_err = '0;
					vif.sig_cfg_ctrl_idle = '0;
					vif.sig_reset_L = '1;
					vif.sig_ack = '0;
				end

				if(counter==8)
				begin
					counter = 0;
					seq_item_port.item_done();
				end
			end
		end
	endtask: drive
endclass: regs_driver
