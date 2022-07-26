class unpacker_monitor_in extends uvm_monitor;
   `uvm_component_utils(unpacker_monitor_in)

   uvm_analysis_port#(unpacker_transaction) mon_ap;

   virtual unpacker_if vif;

   unpacker_transaction tlm;

   covergroup covgrp1_in;
      // 1. Check sizes in the vbc
      vbc_size:   coverpoint vif.sig_vbc {
         bins tiny_size = {[1:32]};
         bins small_size = {[33:64]};
         bins medium_size = {[64:100]};
         bins large_size = {[100:160]};
      }

      // 2. Check transitions between different types of sizes in vbc
      vbc_trans: coverpoint vif.sig_vbc {
         bins small_small = ([1:32]=>[1:32]);
         bins small_large = ([1:32]=>[33:160]);
         bins large_small = ([33:160]=>[1:32]);
         bins large_large = ([33:160]=>[33:160]);
      }

      // 3. Check corner cases in transitions of vbc sizes
      vbc_corner: coverpoint vif.sig_vbc {
         bins case_32_32_32 = (32=>32=>32);
         bins case_160_160_160 = (160=>160=>160);
         bins case_1a32_160_1a32 = ([1:32]=>160=>[1:32]);
         bins case_160_33a63 = (160=>[33:63]);
         bins case_33a63_160 = ([33:63]=>160);
      }

      // 4. Check differents types of transaction ops
      tlm_ops_cases: coverpoint tlm.op {
         bins rst = {OP_RESET_L};
         bins pkt = {OP_PACKET};
      }

      // 5. Check transitions of transaction ops
      tlm_ops_trans:  coverpoint tlm.op {
         bins pkt_rst = (OP_PACKET=>OP_RESET_L);
         bins rst_pkt = (OP_RESET_L=>OP_PACKET);
         bins rst_rst = (OP_RESET_L=>OP_RESET_L);
      }

      // 6. Check different tlm pkt sizes
      pkt_size: coverpoint tlm.pkt.size {
         bins tiny_size = {[1:32]};
         bins small_size = {[33:100]};
         bins medium_size = {[100:160]};
         bins large_size = {[160:1024]};
      }

      // 7. Check transitions between different tlm pkt sizes
      pkt_trans: coverpoint tlm.pkt.size {
         bins small_small = ([1:32]=>[1:32]);
         bins small_medium = ([1:32]=>[33:160]);
         bins small_large = ([1:32]=>[161:1024]);
         bins medium_small = ([33:160]=>[1:32]);
         bins medium_medium = ([33:160]=>[33:160]);
         bins medium_large = ([33:160]=>[1:32]);
         bins large_small = ([161:1024]=>[1:32]);
         bins large_medium = ([161:1024]=>[33:160]);
         bins large_large = ([161:1024]=>[161:1024]);
      }

      // 8. Check different scenarios of SOP
      sop_scenarios: coverpoint vif.sig_sop {
         bins val0 = (1=>1=>1=>1=>1=>1);
         bins pre_pkt1_32 = (0=>1=>0);
         bins pre_pkt33_64 = (0=>1=>1=>0);
         bins pre_pkt65_96 = (0=>1=>1=>1=>0);
         bins pre_pkt97_128 = (0=>1=>1=>1=>1=>0);
         bins pre_pkt129_160 = (0=>1=>1=>1=>1=>1=>0);
      }

      // 9. Check different scenarios of EOP
      eop_scenarios: coverpoint vif.sig_eop {
         bins small_pkts_or_reset = (1=>1=>1=>1=>1=>1);
         bins pre_pkt160 = (0=>1=>1=>1=>1=>1=>0);
      }

      // 10. Check different scenarios of READY
      ready_scenarios: coverpoint vif.sig_ready {
         bins pkt129_160 = (1=>0=>0=>0=>0=>1);
         bins pkt97_128 = (1=>0=>0=>0=>1);
         bins pkt65_96 = (1=>0=>0=>1);
         bins pkt33_64 = (1=>0=>1);
         bins pkt1_32_or_val0_reset1 = (1=>1);
      }

      // 11: Combinations of SOP and EOP
      sop_cases: coverpoint vif.sig_sop {
         option.weight = 0;
      }
      eop_cases: coverpoint vif.sig_eop {
         option.weight = 0;
      }
      sop_x_eop: cross sop_cases, eop_cases;

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

      tlm = unpacker_transaction::type_id::create
              (.name("tlm"), .contxt(get_full_name()));

      `uvm_info(get_full_name(), "monitor_in: start", UVM_LOW)

      forever begin
         @(posedge vif.sig_clock)
         begin
            covgrp1_in.sample();
            if(vif.sig_reset_L==0)
              begin
                 // This is just to discard the current pkt TLM
                 tlm.op = OP_RESET_L;
                 continue;
              end

            if(vif.sig_val==1 && vif.sig_ready==1)
              begin
                 tlm.pkt.size = tlm.pkt.size + vif.sig_vbc;
                 shift = shift + 160*8;
                 tlm.pkt.data = tlm.pkt.data + (vif.sig_data << shift);
                 if (vif.sig_sop==1)
                   begin
                      shift = 0;
                      tlm.op = OP_PACKET;
                      tlm.pkt.size = vif.sig_vbc;
                      tlm.pkt.data = vif.sig_data;
                   end
                 if (vif.sig_eop==1 && tlm.op==OP_PACKET)
                   begin
                      mon_ap.write(tlm.clone());
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

   unpacker_transaction tlm;

   covergroup covgrp1_out;
      // 12. Check all sizes in the o_vbc
      o_vbc_size: coverpoint vif.sig_o_vbc {
         bins tiny_size = {[1:9]};
         bins small_size = {[10:19]};
         bins medium_size = {[20:29]};
         bins large_size = {[30:32]};
      }

      // 13. Check corner cases in transitions of o_vbc sizes
      o_vbc_corner: coverpoint vif.sig_o_vbc {
         bins o_vbc_small_32 = ([1:32]=>32);
         bins o_vbc_32_small = (32=>[1:32]);
      }

      // 14. Check different scenarios of O_SOP
      o_sop_scenarios: coverpoint vif.sig_o_sop {
         bins normal = (0=>1=>0);
         bins small_pkts = (1=>1);
      }

      // 15. Check different scenarios of O_EOP
      o_eop_scenarios: coverpoint vif.sig_o_eop {
         bins normal = (0=>1=>0);
         bins small_pkts = (1=>1);
      }

      // 16: Combinations of O_SOP and O_EOP
      o_sop_cases: coverpoint vif.sig_o_sop {
         option.weight = 0;
      }
      o_eop_cases: coverpoint vif.sig_o_eop {
         option.weight = 0;
      }
      o_sop_x_o_eop: cross o_sop_cases, o_eop_cases;

   endgroup: covgrp1_out 

   function new(string name, uvm_component parent);
      super.new(name, parent);
      covgrp1_out = new();
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_resource_db#(virtual unpacker_if)::read_by_name
            (.scope("ifs"), .name("unpacker_if"), .val(vif)));
      mon_ap = new(.name("mon_ap_out"), .parent(this));
   endfunction: build_phase

   task run_phase(uvm_phase phase);
      integer shift = 0;

      tlm = unpacker_transaction::type_id::create
              (.name("tlm"), .contxt(get_full_name()));
      tlm.op = OP_MAX;

      `uvm_info(get_full_name(), "monitor_out: start", UVM_LOW)

      forever begin
         @(posedge vif.sig_clock)
         begin
            covgrp1_out.sample();
            if(vif.sig_reset_L==0)
              begin
                 tlm.op = OP_RESET_L;
                 continue;
              end
            else if(vif.sig_reset_L==1 && tlm.op==OP_RESET_L)
              begin
                 mon_ap.write(tlm.clone());
                 tlm.op = OP_MAX;
              end

            if(vif.sig_o_val==1)
              begin
                 tlm.pkt.size = tlm.pkt.size + vif.sig_o_vbc;
                 shift = shift + 32*8;
                 tlm.pkt.data = tlm.pkt.data + (vif.sig_o_data << shift);

                 if (vif.sig_o_sop==1)
                   begin
                      shift = 0;
                      tlm.op = OP_PACKET;
                      tlm.pkt.size = vif.sig_o_vbc;
                      tlm.pkt.data = vif.sig_o_data;
                   end
                 if (vif.sig_o_eop==1 && tlm.op==OP_PACKET)
                   begin
                      mon_ap.write(tlm.clone());
                   end
              end
         end
      end
   endtask: run_phase
endclass: unpacker_monitor_out
