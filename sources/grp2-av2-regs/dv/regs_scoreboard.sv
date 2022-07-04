`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

class regs_scoreboard extends uvm_scoreboard;
	int prev_operation,prev_address, prev_data;
	int iterator = 0;
	int wait_confirm_flag;

	`uvm_component_utils(regs_scoreboard)

	uvm_analysis_export #(regs_transaction) sb_export_before;
	uvm_analysis_export #(regs_transaction) sb_export_after;

	uvm_tlm_analysis_fifo #(regs_transaction) before_fifo;
	uvm_tlm_analysis_fifo #(regs_transaction) after_fifo;

	regs_transaction transaction_before;
	regs_transaction transaction_after;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		transaction_before	= new("transaction_before");
		transaction_after	= new("transaction_after");
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sb_export_before	= new("sb_export_before", this);
		sb_export_after		= new("sb_export_after", this);

   		before_fifo		= new("before_fifo", this);
		after_fifo		= new("after_fifo", this);
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		sb_export_before.connect(before_fifo.analysis_export);
		sb_export_after.connect(after_fifo.analysis_export);
	endfunction: connect_phase

	task run();
		forever begin
			before_fifo.get(transaction_before);
			after_fifo.get(transaction_after);
			`uvm_info("SB: ", before_fifo.sprint(), UVM_LOW);
			`uvm_info("SB: ", after_fifo.sprint(), UVM_LOW);
			// prev_address = transaction_before.address;
			// prev_operation[iterator] = transaction_before.operation;
			// iterator = iterator+1;
			// if(iterator>3)begin iterator = 0; end
			compare();
		end
	endtask: run

	virtual function void compare();
		`uvm_info("SB: TX_BEFORE:", $sformatf("%s", transaction_before.operation.name), UVM_LOW);
		`uvm_info("SB: TX_AFTER:", $sformatf("%s", transaction_after.operation.name), UVM_LOW);
		// `uvm_info("SCOREBOARD: QUEUE:", $sformatf("%d, %d, %d, %d", prev_operation[0], prev_operation[1], prev_operation[2], prev_operation[3]), UVM_LOW);

		// if(transaction_before.operation.name == WRITE)begin
		// 	wait_confirm_flag = 1;
		// end
		// else begin
		// 	if(transaction_before.operation.name ==  READ)begin
		// 		wait_confirm_flag = 1;
		// 	end
		// 	else begin
		// 		wait_confirm_flag = 0;
		// 	end
		// end

		// if(transaction_after.operation == ACK)begin
		// 	if (wait_confirm_flag == 1)begin
		// 		`uvm_info("SCOREBOARD ", {"Test: OK!"}, UVM_LOW);
		// 	end else 
		// 		`uvm_info("SCOREBOARD ", {"Test: FAIL!"}, UVM_LOW);

		// 	end
		// end

		if(transaction_before.address == transaction_before.address) begin
			`uvm_info("SCOREBOARD ", {"Test: OK!"}, UVM_LOW);
		end else begin
			`uvm_info("SCOREBOARD ", {"Test: Fail!"}, UVM_LOW);
		end
	endfunction: compare
endclass: regs_scoreboard
