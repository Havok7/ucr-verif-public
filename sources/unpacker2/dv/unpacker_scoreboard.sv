`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class unpacker_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(unpacker_scoreboard)

   uvm_analysis_export #(unpacker_transaction) sb_export_in;
   uvm_analysis_export #(unpacker_transaction) sb_export_out;

   uvm_tlm_analysis_fifo #(unpacker_transaction) in_fifo;
   uvm_tlm_analysis_fifo #(unpacker_transaction) out_fifo;

   unpacker_transaction tx_in;
   unpacker_transaction tx_out;

    function new(string name, uvm_component parent);
      super.new(name, parent);

      tx_in = new("tx_in");
      tx_out = new("tx_out");
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      sb_export_in  = new("sb_export_in", this);
      sb_export_out  = new("sb_export_out", this);

      in_fifo = new("in_fifo", this);
      out_fifo = new("out_fifo", this);
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      sb_export_in.connect(in_fifo.analysis_export);
      sb_export_out.connect(out_fifo.analysis_export);
   endfunction: connect_phase

   task run();
      forever begin
         in_fifo.get(tx_in);
         out_fifo.get(tx_out);
         compare();
      end
   endtask: run

   virtual function void compare();
         `uvm_info("tx_in", tx_in.sprint(), UVM_LOW);
         ///`uvm_info("tx_out", tx_out.sprint(), UVM_LOW);
      if (tx_in.pkt == tx_out.pkt) begin
         ///`uvm_info("compare", {"Test: OK!"}, UVM_LOW);
      end else begin
         ///`uvm_info("compare", {"Test: Fail!"}, UVM_LOW);
      end
   endfunction: compare
endclass: unpacker_scoreboard
