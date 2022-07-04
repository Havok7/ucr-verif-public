class regs_driver extends uvm_driver#(regs_transaction);
	parameter ADDR_SIZE_P = 4;

	`uvm_component_utils(regs_driver)

        // Instanciate the interface
	virtual regs_if vif;

        // Constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

        // Build Phase
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(uvm_resource_db#(virtual regs_if)::read_by_name(.scope("ifs"), .name("regs_if"), .val(vif)));
	endfunction: build_phase

        // Main task
	task run_phase(uvm_phase phase);

            // Define the incoming transaction
            regs_transaction sa_tx;
	
            // Initialize the interface to a known initial state
            vif.sig_addr = '0;
            vif.sig_req = '0;
            vif.sig_rd_wr = '0;
            vif.sig_write_val = 0;
            vif.sig_cfg_ctrl_err = '0;
            vif.sig_cfg_ctrl_idle = '0;
            vif.sig_reset_L = '1;
            vif.sig_ack = '0;

                // Start the interaction between sequencer and driver
		forever begin

                    // Driver requests transaction from the sequencer
                    seq_item_port.get_next_item(sa_tx);
		    `uvm_info("SECUENCIA PEDIDA POR DRIVER: sa_driver", sa_tx.sprint(), UVM_LOW);

		    @(posedge vif.sig_clk)

                        // DEBUG PRINTS
			// `uvm_info("sa_driver", $sformatf("sa_driver, address: %0d", addr), UVM_LOW);/
			// `uvm_info("sa_driver", $sformatf("sa_driver, W/R: %0d", rd_wr), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, req: %0d", req), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, Reset: %0d", reset_L), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, write_val: %0d", write_val), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, read_val: %0d", read_val), UVM_LOW);
			// `uvm_info("sa_driver", $sformatf("sa_driver, ack: %0d", ack), UVM_LOW);
                            
                        // Load incoming traffic into input value pins
                        vif.sig_write_val = sa_tx.data_stream;
                        vif.sig_addr = sa_tx.address;
                        `uvm_info("OPERACION: ", $sformatf("%s", sa_tx.operation.name), UVM_LOW);

                        // Apply a stimulus per each transaction received
                        // foreach (sa_tx.operation)begin
                            // `uvm_info("Operacion Actual: ", $sformatf("%s", sa_tx.operation[i]), UVM_LOW);

                                    case(sa_tx.operation)

                                        // If operation is read, set to read mode and give the interfase the values to read 
                                        READ:
                                        
                                            begin
                                            vif.sig_req = '1;
			        	                    vif.sig_rd_wr = '1;
			        	                    vif.sig_write_val     = '0;
                                            vif.sig_addr          = sa_tx.address;
			        	                    vif.sig_reset_L       = '0;
                                            end
                                        
                                        // If operation is write, set to write mode and give the interfase the values to write
                                        WRITE:
                                            begin
                                            vif.sig_req           = '1;
			        	                    vif.sig_rd_wr         = '0;
			        	                    vif.sig_write_val     = sa_tx.data_stream;
                                            vif.sig_addr          = sa_tx.address;
			        	                    vif.sig_reset_L       = '0;
                                            end

                                         RW_FIELD:
                                            begin
                                            vif.sig_req           = '1;
			        	                    vif.sig_rd_wr         = '0;
			        	                    vif.sig_write_val     = sa_tx.data_stream;
                                            vif.sig_addr          = sa_tx.address;
			        	                    vif.sig_reset_L       = '0;

                                            @(posedge vif.sig_clk)
                                            @(posedge vif.sig_clk)
                                            @(posedge vif.sig_clk)

                                            vif.sig_req           = '1;
			        	                    vif.sig_rd_wr         = '1;
			        	                    vif.sig_write_val     = sa_tx.data_stream;
                                            vif.sig_addr          = sa_tx.address;
			        	                    vif.sig_reset_L       = '0;

                                            @(posedge vif.sig_clk)
                                            @(posedge vif.sig_clk)
                                            @(posedge vif.sig_clk)
                                            vif.sig_reset_L       = '1;
                                            end
                                            
                                        // If operation is reset, take interfase into reset state
                                        RESET:
                                            begin
                                            vif.sig_req           = '0;
                                            vif.sig_rd_wr         = '0;
                                            vif.sig_write_val     = '0;
                                            vif.sig_cfg_ctrl_err  = '0;
                                            vif.sig_cfg_ctrl_idle = '0;
                                            vif.sig_reset_L       = '1;
                                            vif.sig_ack           = '0;
                                            end

                                    endcase
                            
                            // Driver tells sequencer that current transaction is done
			    seq_item_port.item_done();
			
		end
	endtask: run_phase
endclass: regs_driver
