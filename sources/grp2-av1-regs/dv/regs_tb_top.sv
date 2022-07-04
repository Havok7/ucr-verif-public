`timescale 1ns/1ps
`include "regs_pkg.sv"
`include "regs.v"
`include "regs_if.sv"

module regs_tb_top;
	import uvm_pkg::*;
	import regs_pkg::*;
	
	//Interface declaration
	regs_if vif();

	localparam ADDR_SIZE_P = 4;

	//Connects the Interface to the DUT
	regs dut(vif.sig_clk,
			vif.sig_reset_L,
			vif.sig_addr,
			vif.sig_rd_wr,
			vif.sig_req,
			vif.sig_cfg_ctrl_err,
			vif.sig_cfg_ctrl_idle,
			vif.sig_cfg_port_enable,
			vif.sig_cfg_port_id,
			vif.sig_write_val,
			vif.sig_read_val,
			vif.sig_ack);

	initial begin
		//Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual regs_if)::set
			(.scope("ifs"), .name("regs_if"), .val(vif));

		//Executes the test
		run_test();
	end

	//Variable initialization
	initial begin
		vif.sig_clk <= 1'b1;
	end

	//clk generation
	always
		#5 vif.sig_clk = ~vif.sig_clk;

	//Dump variables
	initial begin
		$dumpfile("regs.vcd");
		$dumpvars(0, regs, regs_tb_top);
	end

endmodule
