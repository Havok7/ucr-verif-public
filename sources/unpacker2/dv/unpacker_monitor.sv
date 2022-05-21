class unpacker_monitor_in extends uvm_monitor;
   `uvm_component_utils(unpacker_monitor_in)

   uvm_analysis_port#(unpacker_transaction) mon_ap;

   virtual unpacker_if vif;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
      mon_ap = new(.name("mon_ap_in"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer shift = 0, data_temp = 0, unpacker_mon = 0, pkg_size = 0, a = 0, b = 0, size = 0;

      unpacker_transaction tx;
      tx = unpacker_transaction::type_id::create
              (.name("tx"), .contxt(get_full_name()));
      tx.pkt.data = 1280'hCAFEBEBEDEADBEEF4242;
      tx.pkt.size = 10;
      //mon_ap.write(tx);
      //mon_ap.write(tx);

      // `uvm_info(get_full_name(), "monitor_in: start", UVM_LOW)

      forever begin
         @(posedge vif.sig_clock)
         begin
            if(vif.sig_val==1)
            begin
               if(vif.sig_ready==1)
               begin
                  tx.pkt.size = tx.pkt.size + vif.sig_vbc;
                  shift = shift + 160*8;
                  data_temp = vif.sig_data;
                  tx.pkt.data = tx.pkt.data + (vif.sig_data << shift);
                  if (vif.sig_sop==1)
                  begin
                     shift = 0;
                     tx.pkt.size = vif.sig_vbc;
                     tx.pkt.data = vif.sig_data;
                  end
                  if (vif.sig_eop==1)
                  begin
                     /// write transaction ////
                     mon_ap.write(tx);
                  end
               end
            end
         end
      end
      
   endtask: run_phase
endclass: unpacker_monitor_in

class unpacker_monitor_out extends uvm_monitor;
   `uvm_component_utils(unpacker_monitor_out)

   uvm_analysis_port#(unpacker_transaction) mon_ap;

   virtual unpacker_if vif;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
      mon_ap = new(.name("mon_ap_out"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer unpacker_mon = 0, pkg_size = 0, a = 0, b = 0, size = 0;
      enum integer {OVAL_0=0, OVAL_1=1, OSOP_1=2, OSOP_OEOP_0=3, OEOP_1=4} state;


      unpacker_transaction tx;
      tx = unpacker_transaction::type_id::create
              (.name("tx"), .contxt(get_full_name()));
      tx.pkt.data = 1280'hCAFEBEBEDEADBEEF4242;
      tx.pkt.size = 10;
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);
      mon_ap.write(tx);

      // `uvm_info(get_full_name(), "monitor_out: start", UVM_LOW)

      // forever begin
      //    @(posedge vif.sig_clock)
      //    begin
      //       if(vif.sig_val==1'b0)
      //       begin
      //          state = OVAL_0;
      //          tx.pkt.size = 0;
      //          tx.pkt.data = 0;
      //       end else begin
      //          if(vif.sig_sop==1'b1)
      //          begin
      //             state = OSOP_1;
      //          end else begin
      //             if(vif.sig_eop==1'b1)
      //             begin
      //                state = OEOP_1;
      //             end else begin
      //                state = OSOP_OEOP_0;
      //             end
      //          end
      //       end

      //       // state = 2 -> val = 1, sop = 1, eop = 0
      //       if(state == OSOP_1)
      //       begin
      //          tx.pkt.size = vif.sig_o_vbc;
      //          size = vif.sig_o_vbc;
      //          tx.pkt.data = vif.sig_o_data;
      //       end

      //       // state = 3 -> val = 1, sop = 0, eop = 0
      //       if(state == OSOP_OEOP_0)
      //       begin
      //          tx.pkt.size = tx.pkt.size + vif.sig_o_vbc;
      //          tx.pkt.data = tx.pkt.data << vif.sig_o_vbc;
      //          tx.pkt.data = tx.pkt.data + vif.sig_o_data;
      //       end

      //       // state = 4 -> val = 1, sop = 0, eop = 1
      //       if(state == OEOP_1)
      //       begin
      //          tx.pkt.size = tx.pkt.size + vif.sig_o_vbc;
      //          tx.pkt.data = tx.pkt.data << vif.sig_o_vbc;
      //          tx.pkt.data = tx.pkt.data + vif.sig_o_data;
      //          // write transaction ////
      //          mon_ap.write(tx);
      //       end
      //    end
      // end
   endtask: run_phase
endclass: unpacker_monitor_out
