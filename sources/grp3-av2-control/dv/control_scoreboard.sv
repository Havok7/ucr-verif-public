`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class control_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(control_scoreboard)

	uvm_analysis_export #(control_tlm) sb_export_in;
	uvm_analysis_export #(control_tlm) sb_export_out;

	uvm_tlm_analysis_fifo #(control_tlm) in_fifo;
	uvm_tlm_analysis_fifo #(control_tlm) out_fifo;

	control_tlm transaction_in;
	control_tlm transaction_out;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		
		transaction_in	= new("transaction_in");
		transaction_out	= new("transaction_out");
		
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		sb_export_in	= new("sb_export_in", this);
		sb_export_out	= new("sb_export_out", this);

   		in_fifo		= new("in_fifo", this);
		out_fifo	= new("out_fifo", this);
		
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		
		sb_export_in.connect(in_fifo.analysis_export);
		sb_export_out.connect(out_fifo.analysis_export);
		
	endfunction: connect_phase

	task run();
		forever begin
			
			in_fifo.get(transaction_in);
			out_fifo.get(transaction_out);
			
			compare();
			
		end
	endtask: run

	virtual function void compare();
		
		case (transaction_in.pkt_type)
			
			PKT_OK: begin
				case (transaction_out.pkt_type)
					
					PKT_OK: begin
						`uvm_info("SCOREBOARD", {"Test: OK!"}, UVM_LOW);
					end

					PKT_ERR_EN: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, enable no mantuvo valor inicial de cfg"}, UVM_LOW);
					end

					PKT_ERR_EOP: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, error incorrecto generado en DUT"}, UVM_LOW);
					end

					default: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, Unknown"}, UVM_LOW);
					end
				endcase
			end

			PKT_ERR_SOP: begin
				case (transaction_out.pkt_type)
					
					PKT_OK: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, error no detectado por el DUT"}, UVM_LOW);
					end

					PKT_ERR_SOP: begin
						`uvm_info("SCOREBOARD", {"Test: OK!"}, UVM_LOW);
					end

					default: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, Unknown"}, UVM_LOW);
					end
				endcase
			end

			PKT_ERR_EOP: begin
				case (transaction_out.pkt_type)

					PKT_OK: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, error no detectado por el DUT"}, UVM_LOW);
					end

					PKT_ERR_EOP: begin
						`uvm_info("SCOREBOARD", {"Test: OK!"}, UVM_LOW);
					end
					
					default: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, Unknown"}, UVM_LOW);
					end
				endcase
			end

			PKT_RESET: begin
				case (transaction_out.pkt_type)

					PKT_RESET: begin
						`uvm_info("SCOREBOARD", {"Test: OK!, in RESET"}, UVM_LOW);
					end
					
					default: begin
						`uvm_info("SCOREBOARD", {"Test: Error!, RESET VIOLATION"}, UVM_LOW);
					end
				endcase
			end
		endcase
		
	endfunction: compare
endclass: control_scoreboard