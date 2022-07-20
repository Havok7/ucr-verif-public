class c3po_driver #(MAX_DIN_SIZE=160,
                    PORTS_P=4,
                    ADDR_OFFSET_P=10,
                    ADDR_SIZE_P=6,
                    NON_READY_CLKS_TIMEOUT=100) extends uvm_driver#(c3po_transaction);
   `uvm_component_utils(c3po_driver)

   virtual c3po_in_if vif_in;
   // TODO: Separate reg_if
   virtual c3po_reg_if vif_reg;
   c3po_transaction tlm;
   semaphore pkt_sem;
   semaphore reg_sem;

   function new(string name, uvm_component parent);
      super.new(name, parent);
      pkt_sem = new(1);
      reg_sem = new(1);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual c3po_in_if)::read_by_name
            (.scope("ifs"), .name("c3po_in_if"), .val(vif_in)));
      void'(uvm_resource_db#(virtual c3po_reg_if)::read_by_name
            (.scope("ifs"), .name("c3po_reg_if"), .val(vif_reg)));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      `uvm_info(get_full_name(), "driver: start", UVM_LOW)

      vif_reg.sig_req = 1'b0;
      vif_reg.sig_rd_wr = 1'b0;
      vif_reg.sig_addr = 0;
      vif_reg.sig_write_val = 0;

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
           OP_CFG_PORT_ID: begin
              reg_sem.get(1);
              fork begin
                 drive_cfg_port_id(tlm.clone(), phase);
                 reg_sem.put(1);
              end
              join_none
           end
           OP_CFG_PORT_ENABLE: begin
              reg_sem.get(1);
              fork begin
                 drive_cfg_port_enable(tlm.clone(), phase);
                 reg_sem.put(1);
              end
              join_none
           end
         endcase
         seq_item_port.item_done();
      end
   endtask: run_phase

   function bit slices_ready();
      bit      ready = 1;
      for (int i=0; i < PORTS_P; ++i) begin
         if (vif_in.sig_cfg_port_id[i] == vif_in.sig_id) begin
            ready &= vif_in.sig_ready[i];
         end
      end
      return ready;
   endfunction: slices_ready

   task read_reg(bit[ADDR_SIZE_P-1:0] addr, output bit[31:0] val);
      vif_reg.sig_req <= 1'b1;
      vif_reg.sig_rd_wr <= 1'b1;
      vif_reg.sig_addr <= addr;
      @(posedge vif_in.sig_clock);
      vif_reg.sig_req <= 1'b0;
      vif_reg.sig_rd_wr <= 1'b0;
      vif_reg.sig_addr <= 0;
      @(posedge vif_in.sig_clock);
      val = vif_reg.sig_read_val;
   endtask: read_reg

   task write_reg(bit[ADDR_SIZE_P-1:0] addr, bit[31:0] val);
      vif_reg.sig_req <= 1'b1;
      vif_reg.sig_rd_wr <= 1'b0;
      vif_reg.sig_addr <= addr;
      vif_reg.sig_write_val <= val;
      @(posedge vif_in.sig_clock);
      vif_reg.sig_req <= 1'b0;
      vif_reg.sig_rd_wr <= 1'b0;
      vif_reg.sig_addr <= 0;
      vif_reg.sig_write_val <= 0;
   endtask: write_reg

   task drive_pkt(c3po_transaction tlm, uvm_phase phase);
      integer pkt_offset = 0, send = 0, data_size = 0, remaining_bytes = 0;
      bit [MAX_DIN_SIZE*8-1:0] temp_data = 0;
      integer non_ready_clks = 0;

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
                   vif_in.sig_id <= tlm.id;
                   send = 1;
                end else begin
                   // Return to fetch new transaction
                   phase.drop_objection(.obj(this));
                   return;
                end
           end
         else begin
            // If already sending a packet
            if (slices_ready()) begin
               non_ready_clks = 0;
               if (vif_in.sig_val == 1)
                 begin
                    // Move data window or finish packet
                    vif_in.sig_sop <= 1'b0;
                    if (remaining_bytes > MAX_DIN_SIZE)
                      begin
                         remaining_bytes = remaining_bytes - MAX_DIN_SIZE;
                         pkt_offset++;
                      end else begin
                         // Return to fetch new transaction
                         phase.drop_objection(.obj(this));
                         return;
                      end
                 end
            end else begin
               non_ready_clks++;
               if (non_ready_clks >= NON_READY_CLKS_TIMEOUT) begin
                  `uvm_info("driver", "Timeout waiting for slices ready!", UVM_LOW);
                  vif_in.sig_sop <= 1'b0;
                  phase.drop_objection(.obj(this));
                  return;
               end
            end
         end

         // Update packet data and signals
         vif_in.sig_eop <= (remaining_bytes <= MAX_DIN_SIZE);

         temp_data = tlm.pkt.data[MAX_DIN_SIZE*pkt_offset*8 +: MAX_DIN_SIZE*8];
         if (remaining_bytes > MAX_DIN_SIZE)
           begin
              vif_in.sig_data <= temp_data;
              vif_in.sig_vbc <= MAX_DIN_SIZE;
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

   virtual task drive_cfg_port_id(c3po_transaction tlm, uvm_phase phase);
      bit[31:0] reg_val = 0;
      bit[ADDR_SIZE_P-1:0] reg_addr = ADDR_OFFSET_P * tlm.id;

      phase.raise_objection(.obj(this));

      repeat(tlm.start) @(posedge vif_in.sig_clock);

      // Apply Read/Modify/Write to change CFG_PORT_ID field [7:4]
      read_reg(reg_addr, reg_val);
      reg_val[7:4] = tlm.cfg_id;
      write_reg(reg_addr, reg_val);

      phase.drop_objection(.obj(this));
   endtask: drive_cfg_port_id

   virtual task drive_cfg_port_enable(c3po_transaction tlm, uvm_phase phase);
      bit[31:0] reg_val = 0;
      bit[ADDR_SIZE_P-1:0] reg_addr = ADDR_OFFSET_P * tlm.id;

      phase.raise_objection(.obj(this));

      repeat(tlm.start) @(posedge vif_in.sig_clock);

      // Apply Read/Modify/Write to change CFG_PORT_ENABLE field [0]
      read_reg(reg_addr, reg_val);
      reg_val[0] = tlm.cfg_enable;
      write_reg(reg_addr, reg_val);

      phase.drop_objection(.obj(this));
   endtask: drive_cfg_port_enable

endclass: c3po_driver
