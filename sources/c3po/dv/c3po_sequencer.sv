typedef uvm_sequencer#(c3po_data_tlm) c3po_sequencer;
typedef uvm_sequencer#(c3po_reg_tlm) c3po_reg_sequencer;

class c3po_virt_sequencer extends uvm_sequencer;
   `uvm_component_utils(c3po_virt_sequencer)

   c3po_sequencer in_seqr;
   c3po_reg_sequencer reg_seqr;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new
endclass
