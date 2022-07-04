import uvm_pkg::*;
class control_configuration extends uvm_object;
	`uvm_object_utils(control_configuration)

	function new(string name = "");
		super.new(name);
	endfunction: new
endclass: control_configuration
