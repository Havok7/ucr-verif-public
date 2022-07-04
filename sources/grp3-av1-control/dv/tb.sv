//////////////////////////////////////////////////////////////////////////////////
//
// melvin.alvarado
// may 2021
//
//////////////////////////////////////////////////////////////////////////////////
`include "control_pkg.svh"
`include "control_if.sv"
`timescale 1ns/1ps

module tb();
	import uvm_pkg::*;
    import control_pkg::*;

    // reg clk;
    // reg reset_L;
    // reg val, sop, eop;
    // reg cfg_port_enable;

    //Interface declaration
	control_if vif();

    initial begin
		//Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual control_if)::set
			(.scope("ifs"), .name("control_if"), .val(vif));

		//Executes the test
		run_test();
	end
    // initial begin
    //     $display("Starting simulation");
    //     #5ns;
    //     clk <= 0;
    //     val <= 0;
    //     sop <= 0;
    //     eop <= 0;

    //     // reset
    //     reset_L <= 0;
    //     #20ns;
    //     reset_L <= 1;

    //     // test
    //     repeat (5) begin
    //         repeat (10) @(posedge clk);
    //         val <= 1;
    //         sop <= 1;
    //         @(posedge clk);
    //         sop <= 0;
    //         repeat (10) @(posedge clk);
    //         eop <= 1;
    //         @(posedge clk);
    //         eop <= 0;
    //         val <= 0;
    //     end
    //     #1000ns;
    //     $finish();
    // end

    // initial begin
    //     cfg_port_enable <= 1;
    //     repeat(5) begin
    //         repeat (15) @(posedge clk);
    //         cfg_port_enable <= ~cfg_port_enable;
    //     end
    // end

	//Variable initialization
	initial begin
		vif.clk <= 1'b1;
		vif.reset_L <= 1'b0;

		#20 vif.reset_L <= 1'b1;
	end

    // clk gen
    always @(*) begin
        #5ns;
        vif.clk <= ~vif.clk;
    end


    control_fsm #(
        //.WIDTH_P(WIDTH_P)
    ) DUT (
        .reset_L(vif.reset_L),
        .clk(vif.clk),
        .sop(vif.sop),
        .eop(vif.eop),
        .val(vif.val),
        .cfg_port_enable(vif.cfg_port_enable),
        .enable(vif.enable),
        .error(vif.err)
    );


    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,tb);
    end


endmodule
