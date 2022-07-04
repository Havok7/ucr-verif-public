import uvm_pkg::*;
class regs_configuration extends uvm_object;
	`uvm_object_utils(regs_configuration)

	function new(string name = "");
		super.new(name);
	endfunction: new
endclass: regs_configuration
