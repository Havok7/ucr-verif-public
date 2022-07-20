class c3po_in_monitor #(PORTS_P=4) extends uvm_monitor;
   `uvm_component_utils(c3po_in_monitor)

   uvm_analysis_port#(c3po_transaction) mon_ap;

   virtual c3po_in_if vif_in;

   c3po_transaction tlm[PORTS_P];
   integer shift[PORTS_P];

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual c3po_in_if)::read_by_name
            (.scope("ifs"), .name("c3po_in_if"), .val(vif_in)));
      mon_ap = new(.name("mon_ap_in"), .parent(this));

      for (int i=0; i < PORTS_P; ++i) begin
         tlm[i] = c3po_transaction::type_id::create
                 (.name($sformatf("tlm_%0d", i)), .contxt(get_full_name()));
         shift[i] = 0;
      end
   endfunction: build_phase

   task reset_tlms();
      // This is just to discard the current pkt TLMs
      for (int i=0; i < PORTS_P; ++i) begin
         tlm[i].op = OP_RESET_L;
      end
   endtask: reset_tlms

   task run_slice_tlm(integer i);
      if(vif_in.sig_val==1 &&
         vif_in.sig_ready[i]==1 &&
         vif_in.sig_cfg_port_id[i]==vif_in.sig_id &&
         vif_in.sig_ctrl_port_enable[i]==1)
        begin
           tlm[i].pkt.size = tlm[i].pkt.size + vif_in.sig_vbc;
           shift[i] = shift[i] + 160*8;
           tlm[i].pkt.data = tlm[i].pkt.data + (vif_in.sig_data << shift[i]);
           if (vif_in.sig_sop==1)
             begin
                shift[i] = 0;
                tlm[i].op = OP_PACKET;
                tlm[i].pkt.size = vif_in.sig_vbc;
                tlm[i].pkt.data = vif_in.sig_data;
             end
           if (vif_in.sig_eop==1 && tlm[i].op==OP_PACKET)
             begin
                tlm[i].id = i;
                mon_ap.write(tlm[i].clone());
             end
        end
   endtask: run_slice_tlm

   task run_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "monitor_in: start", UVM_LOW)

      forever begin
         @(posedge vif_in.sig_clock)
         begin
            if(vif_in.sig_reset_L==0) reset_tlms();
            for (int i=0; i < PORTS_P; ++i) begin
               run_slice_tlm(i);
            end
         end
      end

   endtask: run_phase
endclass: c3po_in_monitor

class c3po_out_monitor extends uvm_monitor;
   `uvm_component_utils(c3po_out_monitor)

   uvm_analysis_port#(c3po_transaction) mon_ap;

   integer slice_id = 0;
   virtual c3po_out_if vif_out;

   c3po_transaction tlm;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_config_db#(integer)::get(this, "", "slice_id", slice_id));

      void'(uvm_resource_db#(virtual c3po_out_if)::read_by_name
            (.scope("ifs"), .name($sformatf("c3po_out_if_%0d", slice_id)), .val(vif_out)));
      mon_ap = new(.name("mon_ap_out"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer shift = 0;

      tlm = c3po_transaction::type_id::create
              (.name("tlm"), .contxt(get_full_name()));
      tlm.op = OP_MAX;

      `uvm_info(get_full_name(), "monitor_out: start", UVM_LOW)

      forever begin
         @(posedge vif_out.sig_clock)
         begin
            if(vif_out.sig_reset_L==0)
              begin
                 tlm.op = OP_RESET_L;
                 continue;
              end
            else if(vif_out.sig_reset_L==1 && tlm.op==OP_RESET_L)
              begin
                 mon_ap.write(tlm.clone());
                 tlm.op = OP_MAX;
              end

            if(vif_out.sig_o_val==1)
              begin
                 tlm.pkt.size = tlm.pkt.size + vif_out.sig_o_vbc;
                 shift = shift + 32*8;
                 tlm.pkt.data = tlm.pkt.data + (vif_out.sig_o_data << shift);

                 if (vif_out.sig_o_sop==1)
                   begin
                      shift = 0;
                      tlm.op = OP_PACKET;
                      tlm.pkt.size = vif_out.sig_o_vbc;
                      tlm.pkt.data = vif_out.sig_o_data;
                   end
                 if (vif_out.sig_o_eop==1 && tlm.op==OP_PACKET)
                   begin
                      mon_ap.write(tlm.clone());
                   end
              end
         end
      end
   endtask: run_phase
endclass: c3po_out_monitor
