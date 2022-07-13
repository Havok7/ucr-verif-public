import uvm_pkg::*;
class c3po_configuration extends uvm_object;
   `uvm_object_utils(c3po_configuration)

   function new(string name = "");
      super.new(name);
   endfunction: new
endclass: c3po_configuration
