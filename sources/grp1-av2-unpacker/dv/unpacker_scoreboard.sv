`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class unpacker_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(unpacker_scoreboard)

   uvm_analysis_export #(unpacker_transaction) sb_export_in;
   uvm_analysis_export #(unpacker_transaction) sb_export_out;

   uvm_tlm_analysis_fifo #(unpacker_transaction) fifo_in;
   uvm_tlm_analysis_fifo #(unpacker_transaction) fifo_out;

   unpacker_transaction tlm_in;
   unpacker_transaction tlm_out;

    function new(string name, uvm_component parent);
      super.new(name, parent);

      tlm_in = new("tlm_in");
      tlm_out = new("tlm_out");
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      sb_export_in  = new("sb_export_in", this);
      sb_export_out  = new("sb_export_out", this);

      fifo_in = new("fifo_in", this);
      fifo_out = new("fifo_out", this);
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      sb_export_in.connect(fifo_in.analysis_export);
      sb_export_out.connect(fifo_out.analysis_export);
   endfunction: connect_phase

   function void report_phase(uvm_phase phase);
      if (!fifo_in.is_empty()) begin
         `uvm_error("report_phase", {"fifo_in not empty!"});
      end
      if (!fifo_out.is_empty()) begin
         `uvm_error("report_phase", {"fifo_out not empty!"});
      end
   endfunction: report_phase

   task run();
      forever begin
         fifo_out.get(tlm_out);
         case(tlm_out.op)
           OP_PACKET:
             if (fifo_in.try_get(tlm_in)) begin
                pkt_compare(tlm_in.pkt, tlm_out.pkt);
             end else begin
                `uvm_error("run", {"tlm_in try_get FAIL!"});
             end
           OP_RESET_L:
             // Flush input monitor fifo
             fifo_in.flush();
         endcase
      end
   endtask: run

   virtual function void pkt_compare(tlm_packet in, tlm_packet out);
      if (in.compare(out)) begin
         `uvm_info("pkt_compare", {"OK"}, UVM_LOW);
      end else begin
         `uvm_error("pkt_compare", {"FAIL!"});
         `uvm_info("pkt in", in.sprint(), UVM_LOW);
         `uvm_info("pkt out", out.sprint(), UVM_LOW);
      end
   endfunction: pkt_compare
endclass: unpacker_scoreboard
