//////////////////////////////////////////////////////////////////////////////////
//
// melvin.alvarado
// may 2021
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "counter_pkg.sv"
`include "counter_if.sv"
`include "counter.v"

module tb();
	import uvm_pkg::*;
    import counter_pkg::*;

    counter_if vif();

    localparam WIDTH_P = 4;

    // reg clk;
    // reg reset_L;
    // reg en;

	counter dut(vif.sig_clk,
			vif.sig_reset_L,
			vif.sig_clr,
			vif.sig_inc,
			vif.sig_en,

            vif.sig_overflow,
            vif.sig_non_zero,
			vif.sig_val);


    initial begin
    //     $display("Starting simulation");
    //     #5ns;
    //     en <= 0;
    //     clk <= 0;
    //     reset_L <= 0;
    //     #20ns;
    //     reset_L <= 1;
    //     repeat (5) begin
    //         repeat (10) @(posedge clk);
    //         en <= 1;
    //         repeat (10) @(posedge clk);
    //         en <= 0;
    //     end
    //     #1000ns;
    //     $finish();
    // end


    //  // clk gen
    // always @(*) begin
    //     #5ns;
    //     clk <= ~clk;
    // end


    // counter #(
    //     .WIDTH_P(WIDTH_P)
    // ) DUT (
    //     .clk(clk),
    //     .reset_L(reset_L),
    //     .inc('b1),
    //     .en(en),
    //     .clr(0),
    //     .non_zero(),
    //     .val()
    // );
    //Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual counter_if)::set
			(.scope("ifs"), .name("counter_if"), .val(vif));


    run_test();
    end

    //Variable initialization
	initial begin
		vif.sig_clk <= 1'b1;
	end

	//Clock generation
	always
		#5 vif.sig_clk = ~vif.sig_clk;

    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,tb);
    end
endmodule
