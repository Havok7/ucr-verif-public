import uvm_pkg::*;
class counter_configuration extends uvm_object;
	`uvm_object_utils(counter_configuration)

	function new(string name = "");
		super.new(name);
	endfunction: new
endclass: counter_configuration
