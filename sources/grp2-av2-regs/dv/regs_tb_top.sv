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

	`ifdef COVERAGE_ON
        covergroup covgrp @(posedge vif.sig_clk);
            reset_L :   coverpoint vif.sig_reset_L;
            addr  :   coverpoint vif.sig_addr;
            req :   coverpoint vif.sig_req;
			rd_wr :   coverpoint vif.sig_rd_wr;
			cfg_ctrl_idle: coverpoint vif.sig_cfg_ctrl_idle;
			cfg_ctrl_err: coverpoint vif.sig_cfg_ctrl_err;
			ack: coverpoint vif.sig_ack;
			port_enable: coverpoint vif.sig_cfg_port_enable;
			reqtwo: coverpoint vif.sig_req{
				bins reqt=(1 [* 2]) ;}
			reset_L_c :   coverpoint vif.sig_reset_L {
                bins resettwo = (0=>1);
                bins start = (1 [* 2]);
            }
			write_val: coverpoint vif.sig_write_val{
				bins zero = {0};
                bins non_zero = {[1:$]};
			}
			read_val: coverpoint vif.sig_read_val{
				bins zero = {0};
                bins non_zero = {[1:$]};
			}
			cross reqtwo, rd_wr;
			cross addr, rd_wr,req ;
			cross reset_L_c, rd_wr,req ;
			cross port_enable, ack;
			cross write_val, rd_wr,req ;
        endgroup

        initial begin
            covgrp cg1 = new();
        end
    `endif

	//Dump variables
	initial begin
		$dumpfile("regs.vcd");
		$dumpvars(0, regs, regs_tb_top);
	end

endmodule
