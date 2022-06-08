class unpacker_monitor_in extends uvm_monitor;
   `uvm_component_utils(unpacker_monitor_in)

   uvm_analysis_port#(unpacker_transaction) mon_ap;

   virtual unpacker_if vif;

   covergroup covgrp1_in; //@(posedge vif.sig_clock);
      reset_L :   coverpoint vif.sig_reset_L;
      val :   coverpoint vif.sig_val;
      sop :   coverpoint vif.sig_sop;
      eop :   coverpoint vif.sig_eop;
      vbc :   coverpoint vif.sig_vbc;
   endgroup: covgrp1_in
   

   function new(string name, uvm_component parent);
      super.new(name, parent);
      covgrp1_in = new();
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
      mon_ap = new(.name("mon_ap_in"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer shift = 0;

      unpacker_transaction tx;
      tx = unpacker_transaction::type_id::create
              (.name("tx"), .contxt(get_full_name()));

      `uvm_info(get_full_name(), "monitor_in: start", UVM_LOW)

      forever begin
         @(posedge vif.sig_clock)
         begin
            covgrp1_in.sample();
            if(vif.sig_val==1)
            begin
               if(vif.sig_ready==1)
               begin
                  tx.pkt.size = tx.pkt.size + vif.sig_vbc;
                  shift = shift + 160*8;
                  tx.pkt.data = tx.pkt.data + (vif.sig_data << shift);
                  if (vif.sig_sop==1)
                  begin
                     shift = 0;
                     tx.pkt.size = vif.sig_vbc;
                     tx.pkt.data = vif.sig_data;
                  end
                  if (vif.sig_eop==1)
                  begin
                     mon_ap.write(tx.clone());
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

   covergroup covgrp2_out; //@(posedge vif.sig_clock);
      o_val :   coverpoint vif.sig_o_val;
      o_sop :   coverpoint vif.sig_o_sop;
      o_eop :   coverpoint vif.sig_o_eop;
      o_vbc :   coverpoint vif.sig_o_vbc;
   endgroup: covgrp2_out

   function new(string name, uvm_component parent);
      super.new(name, parent);
      covgrp2_out = new();
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
      mon_ap = new(.name("mon_ap_out"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer shift = 0;

      unpacker_transaction tx;
      tx = unpacker_transaction::type_id::create
              (.name("tx"), .contxt(get_full_name()));

      `uvm_info(get_full_name(), "monitor_out: start", UVM_LOW)

      forever begin
         @(posedge vif.sig_clock)
         begin
            covgrp2_out.sample();
            if(vif.sig_o_val==1)
            begin
               tx.pkt.size = tx.pkt.size + vif.sig_o_vbc;
               shift = shift + 32*8;
               tx.pkt.data = tx.pkt.data + (vif.sig_o_data << shift);
               if (vif.sig_o_sop==1)
               begin
                  shift = 0;
                  tx.pkt.size = vif.sig_o_vbc;
                  tx.pkt.data = vif.sig_o_data;
               end
               if (vif.sig_o_eop==1)
               begin
                  mon_ap.write(tx.clone());
               end
            end
         end
      end
   endtask: run_phase
endclass: unpacker_monitor_out
