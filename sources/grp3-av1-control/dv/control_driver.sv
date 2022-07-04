class control_driver extends uvm_driver#(control_transaction);
	`uvm_component_utils(control_driver)

	virtual control_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		void'(uvm_resource_db#(virtual control_if)::read_by_name
			(.scope("ifs"), .name("control_if"), .val(vif)));
		
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		
		drive();
		
	endtask: run_phase

	virtual task drive();
		
		control_transaction ctr_tx;
		integer counter = 0, state = 0;
		// integer cant_ciclos_tot = ctr_tx.tam_palabras ;
		integer ciclos = 0;
		vif.val = 0;
		vif.sop = 0;
		vif.eop = 0;
		vif.cfg_port_enable = 1;


		forever begin
			if(counter==0 && vif.reset_L) //Nueva transaccion
			begin
				seq_item_port.get_next_item(ctr_tx);
				`uvm_info("ctr_driver", ctr_tx.sprint(), UVM_LOW);
				vif.val=1;
			end

			@(posedge vif.clk)
			`uvm_info("ctr_driver", $sformatf("ctr_driver, counter: %0d", counter), UVM_LOW);
			`uvm_info("ctr_driver", $sformatf("ctr_driver, state: %0d", state), UVM_LOW);
			`uvm_info("ctr_ciclos", $sformatf("ctr_driver, ciclos: %0d", ciclos), UVM_LOW);
			begin
				if(counter==0)
				begin
					vif.cfg_port_enable = 1'b1;
					state = 1;
					ciclos = 0;
					vif.eop = 0;
				end

				if(counter==1)
				begin
					vif.cfg_port_enable = 1'b1;
				end
				
				case(state)
					1: begin //Casi incial, inicio del paquete, envia SOP si hay un valid
						if(vif.val == 1)
						begin
							vif.sop = 1 ;
							state = 2;
							ciclos = ciclos + 1;
							counter = 1;
						end
					end

					2: begin //Esperando  que pasen todos los paquetes, solo cuentas si hay un valid
						vif.sop = 0;
						if(vif.val==1)
						begin
							ciclos = ciclos + 1;
						end
						if (ciclos >= (ctr_tx.tam_palabras -1) ) 
						begin //Ya pasaron todos los ciclos necesarios, levante el EOP
							state = 3 ;
						end
					end
					3: begin
						if (vif.val==1) //Ya pasaron todos los paquetes, si es val levante el EOP
						begin
							counter = 0;
							vif.eop = 1 ;
							seq_item_port.item_done();
						end
					end
				endcase
			end
		end
		
	endtask: drive
endclass: control_driver
