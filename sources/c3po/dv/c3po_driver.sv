class c3po_driver #(max_din_size=160, PORTS_P=4) extends uvm_driver#(c3po_transaction);
   `uvm_component_utils(c3po_driver)

   virtual c3po_in_if vif_in;
   virtual c3po_out_if vif_out[PORTS_P];
   c3po_transaction tlm;
   semaphore pkt_sem;

   function new(string name, uvm_component parent);
      super.new(name, parent);
      pkt_sem = new(1);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual c3po_in_if)::read_by_name
            (.scope("ifs"), .name("c3po_in_if"), .val(vif_in)));

      for (int i=0; i < PORTS_P; ++i) begin
         void'(uvm_resource_db#(virtual c3po_out_if)::read_by_name
               (.scope("ifs"), .name($sformatf("c3po_out_if_%0d", i)), .val(vif_out[i])));
      end
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "driver: start", UVM_LOW)

      vif_in.sig_data <= 1280'b0;
      vif_in.sig_id  <= 4'b0;
      vif_in.sig_sop <= 1'b0;
      vif_in.sig_eop <= 1'b0;
      vif_in.sig_val <= 1'b0;
      vif_in.sig_vbc <= 8'b0;
      vif_in.sig_reset_L <= 1'b0;
      #15 vif_in.sig_reset_L <= 1'b1;
      vif_in.sig_val <= 1'b1;

      forever begin
         seq_item_port.get_next_item(tlm);
         case(tlm.op)
           OP_PACKET: begin
              pkt_sem.get(1);
              fork begin
                 drive_pkt(tlm.clone(), phase);
                 pkt_sem.put(1);
              end
              join_none
           end
           OP_RESET_L: begin
              fork begin
                 drive_reset_l(tlm.clone(), phase);
              end
              join_none
           end
           OP_VAL_L: begin
              fork begin
                 drive_val_l(tlm.clone(), phase);
              end
              join_none
           end
         endcase
         seq_item_port.item_done();
      end
   endtask: run_phase

   function integer in_port_id();
      bit[3:0] id = (vif_in.sig_id !== 'bx) ? vif_in.sig_id : 0;
      id = (id < PORTS_P) ? id : PORTS_P-1;
      return id;
   endfunction: in_port_id

   task drive_pkt(c3po_transaction tlm, uvm_phase phase);
      integer pkt_offset = 0, send = 0, data_size = 0, remaining_bytes = 0;
      bit [max_din_size*8-1:0] temp_data = 0;
      integer port = 0;

      phase.raise_objection(.obj(this));

      forever begin
         vif_in.sig_eop <= 1'b0;
         vif_in.sig_vbc <= 8'b0;
         vif_in.sig_data <= 1280'b0;

         // If not sending packet, start a new one
         if (send == 0)
           begin
              data_size = tlm.pkt.size;
              if (data_size != 0)
                begin
                   remaining_bytes = data_size;
                   vif_in.sig_sop <= 1'b1;
                   send = 1;
                end else begin
                   // Return to fetch new transaction
                   phase.drop_objection(.obj(this));
                   return;
                end
           end
         else begin
            // If already sending a packet
            port = in_port_id();
            if (vif_in.sig_val == 1 &&
                vif_out[port].sig_ready == 1)
              begin
                 // Move data window or finish packet
                 vif_in.sig_sop <= 1'b0;
                 if (remaining_bytes > max_din_size)
                   begin
                      remaining_bytes = remaining_bytes - max_din_size;
                      pkt_offset++;
                   end else begin
                      // Return to fetch new transaction
                      phase.drop_objection(.obj(this));
                      return;
                   end
              end
         end

         // Update packet data and signals
         vif_in.sig_eop <= (remaining_bytes <= max_din_size);

         temp_data = tlm.pkt.data[max_din_size*pkt_offset*8 +: max_din_size*8];
         if (remaining_bytes > max_din_size)
           begin
              vif_in.sig_data <= temp_data;
              vif_in.sig_vbc <= max_din_size;
           end else begin
              vif_in.sig_data <= temp_data & ((1 << (remaining_bytes * 8)) - 1);
              vif_in.sig_vbc <= remaining_bytes;
           end

         @(posedge vif_in.sig_clock);
      end
      phase.drop_objection(.obj(this));
   endtask: drive_pkt

   virtual task drive_reset_l(c3po_transaction tlm, uvm_phase phase);
      phase.raise_objection(.obj(this));

      repeat(tlm.start) @(posedge vif_in.sig_clock);
      vif_in.sig_reset_L <= 1'b0;
      repeat(tlm.hold) @(posedge vif_in.sig_clock);
      vif_in.sig_reset_L <= 1'b1;

      phase.drop_objection(.obj(this));
   endtask: drive_reset_l

   virtual task drive_val_l(c3po_transaction tlm, uvm_phase phase);
      phase.raise_objection(.obj(this));

      repeat(tlm.start) @(posedge vif_in.sig_clock);
      vif_in.sig_val <= 1'b0;
      repeat(tlm.hold) @(posedge vif_in.sig_clock);
      vif_in.sig_val <= 1'b1;

      phase.drop_objection(.obj(this));
   endtask: drive_val_l

endclass: c3po_driver
