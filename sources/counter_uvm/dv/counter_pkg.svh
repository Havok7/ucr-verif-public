package counter_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "counter_tlm3.sv" // 2-3
	`include "counter_sequence.sv"
	`include "counter_sequencer.sv"
	`include "counter_monitor.sv"
	`include "counter_driver3.sv" // 2-3
	`include "counter_agent.sv"
	// `include "counter_scoreboard.sv"
	`include "counter_env.sv"
	`include "counter_test.sv"

endpackage: counter_pkg
