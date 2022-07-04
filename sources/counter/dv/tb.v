//////////////////////////////////////////////////////////////////////////////////
//
// melvin.alvarado
// may 2021
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps


module tb();


    localparam WIDTH_P = 4;

    reg clk;
    reg reset_L;
    reg en;


    initial begin
        $display("Starting simulation");
        #5ns;
        en <= 0;
        clk <= 0;
        reset_L <= 0;
        #20ns;
        reset_L <= 1;
        repeat (5) begin
            repeat (10) @(posedge clk);
            en <= 1;
            repeat (10) @(posedge clk);
            en <= 0;
        end
        #1000ns;
        $finish();
    end


     // clk gen
    always @(*) begin
        #5ns;
        clk <= ~clk;
    end


    counter #(
        .WIDTH_P(WIDTH_P)
    ) DUT (
        .clk(clk),
        .reset_L(reset_L),
        .inc('b1),
        .en(en),
        .clr(0),
        .non_zero(),
        .val()
    );


    initial begin
        $dumpfile("sim.vcd");
        $dumpvars(0,tb);
    end

    // initial begin
	// 	// //Registers the Interface in the configuration block so that other
	// 	// //blocks can use it
	// 	// uvm_resource_db#(virtual simpleadder_if)::set
	// 	// 	(.scope("ifs"), .name("simpleadder_if"), .val(vif));

	// 	//Executes the test
	// 	run_test();
	// end


endmodule
