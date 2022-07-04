`timescale 1ns/1ps
`include "counter_pkg.sv"
`include "counter.v"
`include "counter_if.sv"

module counter_tb_top;
	import uvm_pkg::*;
	import counter_pkg::*;
	
	//Interface declaration
	counter_if vif();

	localparam WIDTH_P = 4;

	//Connects the Interface to the DUT
	counter dut(vif.sig_clk,
			vif.sig_reset_L,
			vif.sig_en,
			vif.sig_clr,
			vif.sig_inc,
			vif.sig_overflow,
            vif.sig_non_zero,
            vif.sig_val);


	initial begin
		//Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual counter_if)::set
			(.scope("ifs"), .name("counter_if"), .val(vif));

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
		$dumpfile("counter.vcd");
		$dumpvars(0, counter, counter_tb_top);
	end

endmodule
