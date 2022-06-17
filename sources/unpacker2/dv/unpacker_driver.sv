class unpacker_driver #(max_din_size=160) extends uvm_driver#(unpacker_transaction);
   `uvm_component_utils(unpacker_driver)

   virtual unpacker_if vif;
   unpacker_transaction tlm;
   semaphore pkt_sem;

   function new(string name, uvm_component parent);
      super.new(name, parent);
      pkt_sem = new(1);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "driver: start", UVM_LOW)

      vif.sig_data <= 1280'b0;
      vif.sig_sop <= 1'b0;
      vif.sig_eop <= 1'b0;
      vif.sig_val <= 1'b0;
      vif.sig_vbc <= 8'b0;
      vif.sig_reset_L <= 1'b0;
      #15 vif.sig_reset_L <= 1'b1;

      forever begin
         seq_item_port.get_next_item(tlm);
         case(tlm.op)
           OP_PACKET: begin
              pkt_sem.get(1);
              fork begin
                 phase.raise_objection(.obj(this));
                 drive_pkt(tlm.clone(), phase);
                 pkt_sem.put(1);
                 phase.drop_objection(.obj(this));
              end
              join_none
           end
           OP_RESET: begin
              fork begin
                 phase.raise_objection(.obj(this));
                 drive_reset(tlm.clone(), phase);
                 phase.drop_objection(.obj(this));
              end
              join_none
           end
         endcase
         seq_item_port.item_done();
      end
   endtask: run_phase

   task drive_pkt(unpacker_transaction tlm, uvm_phase phase);
      integer pkt_offset = 0, send = 0, data_size = 0, remaining_bytes = 0;
      bit [max_din_size*8-1:0] temp_data = 0;

      forever begin
         vif.sig_eop <= 1'b0;
         vif.sig_val <= 1'b0;
         vif.sig_vbc <= 8'b0;
         vif.sig_data <= 1280'b0;

         // If not sending packet, start a new one
         if (send == 0)
           begin
              `uvm_info("driver", tlm.sprint(), UVM_LOW);
              data_size = tlm.pkt.size;
              if (data_size != 0)
                begin
                   remaining_bytes = data_size;
                   vif.sig_sop <= 1'b1;
                   send = 1;
                end else begin
                   // Return to fetch new transaction
                   return;
                end
           end
         else begin
            // If already sending a packet
            if (vif.sig_ready == 1)
              begin
                 // Move data window or finish packet
                 vif.sig_sop <= 1'b0;
                 if (remaining_bytes > max_din_size)
                   begin
                      remaining_bytes = remaining_bytes - max_din_size;
                      pkt_offset++;
                   end else begin
                      // Return to fetch new transaction
                      return;
                   end
              end
         end

         // Update packet data and signals
         vif.sig_val <= 1'b1;
         vif.sig_eop <= (remaining_bytes <= max_din_size);

         temp_data = tlm.pkt.data[max_din_size*pkt_offset*8 +: max_din_size*8];
         if (remaining_bytes > max_din_size)
           begin
              vif.sig_data <= temp_data;
              vif.sig_vbc <= max_din_size;
           end else begin
              vif.sig_data <= temp_data & ((1 << (remaining_bytes * 8)) - 1);
              vif.sig_vbc <= remaining_bytes;
           end

         @(posedge vif.sig_clock);
      end
   endtask: drive_pkt

   virtual task drive_reset(unpacker_transaction tlm, uvm_phase phase);
      `uvm_info("driver", tlm.sprint(), UVM_LOW);

      repeat(tlm.rst_start) @(posedge vif.sig_clock);
      vif.sig_reset_L <= 1'b0;

      repeat(tlm.rst_hold) @(posedge vif.sig_clock);
      vif.sig_reset_L <= 1'b1;
   endtask: drive_reset

endclass: unpacker_driver
