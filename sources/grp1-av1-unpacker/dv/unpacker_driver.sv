class unpacker_driver #(max_din_size=160) extends uvm_driver#(unpacker_transaction);
   `uvm_component_utils(unpacker_driver)

   virtual unpacker_if vif;
   unpacker_transaction tx;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      drive();
   endtask: run_phase

   virtual task drive();
      integer iteration = 0;
      integer packet_counter = 0, send = 0, data_size = 0, remaining_bytes = 0;
      bit [max_din_size*8-1:0] temp_data = 0;
      `uvm_info(get_full_name(), "driver: start", UVM_LOW)

      vif.sig_data <= 1280'b0;
      vif.sig_sop <= 1'b0;
      vif.sig_eop <= 1'b0;
      vif.sig_val <= 1'b0;
      vif.sig_vbc <= 8'b0;
      vif.sig_reset_L <= 1'b0;
      #15 vif.sig_reset_L <= 1'b1;
      //#10

      forever begin
         @(posedge vif.sig_clock)
           begin
              vif.sig_eop <= 1'b0;
              vif.sig_val <= 1'b0;
              vif.sig_vbc <= 8'b0;

              if (send == 1)
                begin
                   if (vif.sig_ready == 1)
                     begin
                        vif.sig_sop <= 1'b0;
                        if (remaining_bytes > max_din_size)
                          begin
                             remaining_bytes = remaining_bytes - max_din_size;
                             packet_counter++;
                          end else begin
                             seq_item_port.item_done();
                             packet_counter = 0;
                             remaining_bytes = 0;
                             send = 0;
                          end
                     end
                end

              if (send == 0)
                begin
                   seq_item_port.get_next_item(tx);
                   `uvm_info("driver", tx.sprint(), UVM_LOW);
                   data_size = tx.pkt.size;
                   if (data_size != 0)
                     begin
                        remaining_bytes = data_size;
                        vif.sig_sop <= 1'b1;
                        send = 1;
                     end else begin
                        seq_item_port.item_done();
                     end
                end

              if (send == 1)
                begin
                   vif.sig_val <= 1'b1;
                   vif.sig_eop <= (remaining_bytes <= max_din_size);

                   temp_data = tx.pkt.data[max_din_size*packet_counter*8 +: max_din_size*8];
                   if (remaining_bytes > max_din_size)
                     begin
                        vif.sig_data <= temp_data;
                        vif.sig_vbc <= max_din_size;
                     end else begin
                        vif.sig_data <= temp_data & ((1 << (remaining_bytes * 8)) - 1);
                        vif.sig_vbc <= remaining_bytes;
                     end
                end
           end
         // `uvm_info("driver tx", tx.sprint(), UVM_LOW);
      end
   endtask: drive
endclass: unpacker_driver
