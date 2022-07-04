`include "control_pkg.svh"
`include "control_if.sv"
// `include "control_original.v"
`include "control.v"

module control_tb_top;
	import uvm_pkg::*;
	import control_pkg::*;
	
	enum {
    RESET,
    IDLE,
    WAIT_EOP,
    ERROR
	} state_e;

	//Interface declaration
	control_if vif();
	
	//Connects the Interface to the DUT
	control_fsm dut(vif.clk,
			    vif.reset_L,
			    vif.cfg_port_enable,
			    vif.val,
			    vif.sop,
			    vif.eop,
				vif.err,
				vif.enable);

	`ifdef COVERAGE_ON
        covergroup covgrp3_estados @(posedge vif.clk);
			trans1:		coverpoint dut.state {bins trans1 = (0=>1);}
			trans2:		coverpoint dut.state {bins trans2 = (1=>2);}
			trans3:		coverpoint dut.state {bins trans3 = (1=>3);}
			trans4:		coverpoint dut.state {bins trans4 = (3=>1);}
			trans5:		coverpoint dut.state {bins trans5 = (2=>1);}
			trans6:		coverpoint dut.state {bins trans6 = (2=>3);}
        endgroup
	`endif

	initial begin
		//Registers the Interface in the configuration block so that other
		//blocks can use it
		uvm_resource_db#(virtual control_if)::set
			(.scope("ifs"), .name("control_if"), .val(vif));

		//Executes the test
		run_test();
	end
	
	//Variable initialization
	initial begin
		covgrp3_estados cg3 = new();
		vif.clk <= 1'b1;
		//vif.reset_L <= 1'b0;

		//#20 vif.reset_L <= 1'b1;
	end

	//Clock generation
	always
		#5 vif.clk = ~vif.clk;

	//Dump variables
	initial begin
		$dumpfile("control.vcd");
		$dumpvars(0, control_fsm, control_tb_top);
	end

	
	//Starting assertions:
	`ifdef ASSERT_ON
		//Assert 1: si hay un error, enable sigue al cfg en el proximo ciclo
		ASSERT_001: assert property(@(posedge vif.clk) disable iff (!vif.reset_L) $rose(vif.err) |=> (dut.nxt_state==IDLE) |-> (vif.enable==vif.cfg_port_enable) ) else $error("ASSERT1: Enable no siguió al cfg después del error");
		//Assert 2: Siguiente estado despues del paso de un paquete correcto estando en WAIT_EOP
		ASSERT_002: assert property(@(posedge vif.clk) disable iff (!vif.reset_L) dut.state==WAIT_EOP |-> (vif.val && vif.eop && !vif.sop) |-> dut.nxt_state==IDLE ) else $error ("ASSERT2: No se pasó a IDLE desp de WAIT_EOP");
		//Assert 3: Si esta el reset, enable tiene que ser 0
		ASSERT_003: assert property(@(posedge vif.clk) !vif.reset_L |-> !vif.enable ) else $error ("ASSERT3: enable en uno, pero esta en reset");	
		//Assert 4: Nuevo nxt_state para condicion de error en estado IDLE 
		ASSERT_004: assert property(@(posedge vif.clk) disable iff (!vif.reset_L) dut.state==IDLE |-> (!vif.sop && vif.eop && vif.val) |-> dut.nxt_state==ERROR) else $error ("ASSERT4: nxt_state no paso a ERROR teniendo error en IDLE");	
		//Assert 5: dos eop validos seguidos no provocaron el error
		ASSERT_005: assert property(@(posedge vif.clk) disable iff (!vif.reset_L)((vif.eop && vif.val && !vif.sop) |-> ##1 (vif.eop && vif.val && !vif.sop) |-> vif.err)) else $error ("ASSERT5: dos eop validos seguidos no provocaron el error");	
		//Assert 6: Si esta el reset, error tiene que ser 0
		ASSERT_006: assert property(@(posedge vif.clk) !vif.reset_L |-> !vif.err ) else $error ("ASSERT6: error en uno, pero esta en reset");
		//Assert 7: Si esta en estado RESET, se debe pasar a un IDLE
		ASSERT_007: assert property(@(posedge vif.clk) (dut.state==RESET) |=> !(dut.state==RESET) |-> (dut.state===IDLE) ) else $error("ASSERT7: No se paso de RESET a IDLE");
		//Assert 8: Si el nxt_state esta en error, se debe poner el error en alto
		ASSERT_008: assert property(@(posedge vif.clk) dut.nxt_state==ERROR |-> vif.err) else $error("ASSERT8: Sin señal error estando en ERROR");
		//Assert 9: Verificacion de señal interna sop_int
		ASSERT_009: assert property(@(posedge vif.clk) vif.val |-> vif.sop |-> dut.sop_int) else $error("ASSERT9: Señal interna de sop no se puso en alto");
		//Assert 9: Verificacion de señal interna sop_int
		ASSERT_010: assert property(@(posedge vif.clk) vif.val |-> vif.eop |-> dut.eop_int) else $error("ASSERT10: Señal interna de eop no se puso en alto");
	`endif

endmodule
