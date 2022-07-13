`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class c3po_scoreboard #(PORTS_P=4) extends uvm_scoreboard;
   `uvm_component_utils(c3po_scoreboard)

   uvm_analysis_export #(c3po_transaction) sb_export_in[PORTS_P];
   uvm_analysis_export #(c3po_transaction) sb_export_out[PORTS_P];

   uvm_tlm_analysis_fifo #(c3po_transaction) fifo_in[PORTS_P];
   uvm_tlm_analysis_fifo #(c3po_transaction) fifo_out[PORTS_P];

    function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      for (int i=0; i < PORTS_P; ++i) begin
         sb_export_in[i] = new($sformatf("sb_export_in_%0d", i), this);
         sb_export_out[i] = new($sformatf("sb_export_out_%0d", i), this);
      end

      for (int i=0; i < PORTS_P; ++i) begin
         fifo_in[i] = new($sformatf("fifo_in_%0d", i), this);
         fifo_out[i] = new($sformatf("fifo_out_%0d", i), this);
      end
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      for (int i=0; i < PORTS_P; ++i) begin
         sb_export_in[i].connect(fifo_in[i].analysis_export);
         sb_export_out[i].connect(fifo_out[i].analysis_export);
      end
   endfunction: connect_phase

   function void report_phase(uvm_phase phase);
      for (int i=0; i < PORTS_P; ++i) begin
         if (!fifo_in[i].is_empty()) begin
            `uvm_error("report_phase", {$sformatf("fifo_in %0d not empty!", i)});
         end
         if (!fifo_out[i].is_empty()) begin
            `uvm_error("report_phase", {$sformatf("fifo_out %0d not empty!", i)});
         end
      end
   endfunction: report_phase

   task slice_run(integer i);
      automatic c3po_transaction tlm_in;
      automatic c3po_transaction tlm_out;
      forever begin
         fifo_out[i].get(tlm_out);
         case(tlm_out.op)
           OP_PACKET:
             if (fifo_in[i].try_get(tlm_in)) begin
                if (pkt_compare(tlm_in.pkt, tlm_out.pkt)) begin
                   `uvm_error($sformatf("slice_run[%0d]", i), {"pkt_compare FAIL!"});
                end else begin
                   `uvm_info($sformatf("slice_run[%0d]", i), {"pkt_compare OK"}, UVM_LOW);
                end
             end else begin
                `uvm_error($sformatf("slice_run[%0d]", i), {"tlm_in try_get FAIL!"});
             end
           OP_RESET_L:
             // Flush input monitor fifo
             fifo_in[i].flush();
           OP_MAX:
             return;
         endcase
      end
   endtask: slice_run

   task run();
      for (int i=0; i < PORTS_P; ++i) begin
         automatic int i_ = i;
         fork begin
            slice_run(i_);
         end
         join_none
      end
   endtask: run

   virtual function int pkt_compare(tlm_packet in, tlm_packet out);
      if (in.compare(out)) begin
         return 0;
      end else begin
         `uvm_info("pkt in", in.sprint(), UVM_LOW);
         `uvm_info("pkt out", out.sprint(), UVM_LOW);
         return 1;
      end
   endfunction: pkt_compare
endclass: c3po_scoreboard
