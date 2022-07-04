import uvm_pkg::*;
class unpacker_configuration extends uvm_object;
   `uvm_object_utils(unpacker_configuration)

   function new(string name = "");
      super.new(name);
   endfunction: new
endclass: unpacker_configuration
