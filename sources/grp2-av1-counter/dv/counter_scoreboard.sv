`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

class counter_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(counter_scoreboard)

	uvm_analysis_export #(counter_transaction) sb_export_before;
	uvm_analysis_export #(counter_transaction) sb_export_after;

	uvm_tlm_analysis_fifo #(counter_transaction) before_fifo;
	uvm_tlm_analysis_fifo #(counter_transaction) after_fifo;

	counter_transaction transaction_before;
	counter_transaction transaction_after;

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
			
			compare();
		end
	endtask: run

	virtual function void compare();
		`uvm_info("scoreboard", $sformatf("val: %0d", transaction_before.val), UVM_LOW);
		`uvm_info("scoreboard", $sformatf("before_inc: %0d", transaction_before.inc), UVM_LOW);
		`uvm_info("scoreboard", $sformatf("after_val: %0d", transaction_after.val), UVM_LOW);
		`uvm_info("scoreboard", $sformatf("after_inc: %0d", transaction_after.inc), UVM_LOW);
	
		if(transaction_before.reset_L == 1)begin
			if(transaction_before.en == 1)begin
				if(transaction_before.val + transaction_before.inc == transaction_after.val) begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: OK!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end else begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end
			end
			if(transaction_before.en == 0)begin
				if(transaction_before.val == transaction_after.val) begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: OK!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end else begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end
			end
			else begin
					`uvm_info("", {"***************************"}, UVM_LOW);
                                        `uvm_info("compare", {"Test: INVALID"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
			end
		end
		if(transaction_before.reset_L == 0)begin
			if(transaction_after.val == 0) begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: OK!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end else begin
                                        `uvm_info("", {"***************************"}, UVM_LOW);
					`uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
                                        `uvm_info("", {"***************************"}, UVM_LOW);
				end
		end
	endfunction: compare
endclass: counter_scoreboard
