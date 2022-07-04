class counter_driver extends uvm_driver#(counter_transaction);
	parameter WIDTH_P = 4;

	`uvm_component_utils(counter_driver)

	virtual counter_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		void'(uvm_resource_db#(virtual counter_if)::read_by_name
			(.scope("ifs"), .name("counter_if"), .val(vif)));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		drive();
	endtask: run_phase

	virtual task drive();
		counter_transaction sa_tx;

		integer counter = 0;
		vif.sig_inc = 0;
		vif.sig_en = 1'b1;
		vif.sig_reset_L= 1'b0;

		forever begin
			if(counter==0)

			    begin
				seq_item_port.get_next_item(sa_tx);
				//`uvm_info("Sequencia pedida por driver: sa_driver", sa_tx.sprint(), UVM_LOW);
			    end

			@(posedge vif.sig_clk)
			`uvm_info("sa_driver", $sformatf("sa_driver, counter: %0d", counter), UVM_LOW);
			    begin
				
				if(counter==0)
				begin
					vif.sig_inc = 0;
					vif.sig_reset_L = 1'b1;
					vif.sig_en = 1'b1;
					vif.sig_clr = 1'b1;
				end

				vif.sig_en = sa_tx.en;
				vif.sig_inc = sa_tx.inc;
				counter = counter + 1;
				
				if(counter==1)
				begin
					counter = 0;
					seq_item_port.item_done();
				end
			end
		end
	endtask: drive
endclass: counter_driver
