class c3po_tlm_slice_filter #(type T = c3po_data_tlm,
                              type F = uvm_tlm_analysis_fifo #(T)) extends uvm_subscriber #(T);
   F fifo;
   integer slice_id;

   function new(string name, uvm_component parent, F fifo, integer slice_id);
      super.new(name, parent);
      this.fifo = fifo;
      this.slice_id = slice_id;
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction: build_phase

   virtual function void write (T t);
      if (t.id == slice_id) begin
         fifo.analysis_export.write(t);
      end
   endfunction: write

endclass: c3po_tlm_slice_filter

class c3po_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(c3po_scoreboard)

   integer slice_id = 0;

   uvm_analysis_export #(c3po_data_tlm) sb_export_in;
   uvm_analysis_export #(c3po_data_tlm) sb_export_out;

   uvm_tlm_analysis_fifo #(c3po_data_tlm) fifo_in;
   uvm_tlm_analysis_fifo #(c3po_data_tlm) fifo_out;
   c3po_tlm_slice_filter slice_filter_in;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_config_db#(integer)::get(this, "", "slice_id", slice_id));

      sb_export_in = new("sb_export_in", this);
      sb_export_out = new("sb_export_out", this);

      fifo_in = new("fifo_in", this);
      fifo_out = new("fifo_out", this);
      slice_filter_in = new("slice_filter_in", this, fifo_in, slice_id);
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      sb_export_in.connect(slice_filter_in.analysis_export);
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

   virtual function int pkt_compare(tlm_packet in, tlm_packet out);
      if (in.compare(out)) begin
         return 0;
      end else begin
         `uvm_info("pkt in", in.sprint(), UVM_LOW);
         `uvm_info("pkt out", out.sprint(), UVM_LOW);
         return 1;
      end
   endfunction: pkt_compare

   task run();
      c3po_data_tlm tlm_in, tlm_out;
      forever begin
         fifo_out.get(tlm_out);
         case(tlm_out.op)
           OP_PACKET:
             if (fifo_in.try_get(tlm_in)) begin
                if (pkt_compare(tlm_in.pkt, tlm_out.pkt)) begin
                   `uvm_error("slice_run", {"pkt_compare FAIL!"});
                end else begin
                   `uvm_info("slice_run", {"pkt_compare OK"}, UVM_LOW);
                end
             end else begin
                `uvm_error("slice_run", {"tlm_in try_get FAIL!"});
             end
           OP_RESET_L:
             // Flush input monitor fifo
             fifo_in.flush();
           OP_MAX:
             return;
         endcase
      end
   endtask: run

endclass: c3po_scoreboard
