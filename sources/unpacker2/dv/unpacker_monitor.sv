class unpacker_monitor_in extends uvm_monitor;
   `uvm_component_utils(unpacker_monitor_in)

   uvm_analysis_port#(unpacker_transaction) mon_ap;

   virtual unpacker_if vif;

   unpacker_transaction tlm;

   covergroup covgrp1_in;
      reset_L : coverpoint vif.sig_reset_L {
         bins test_reset = (0=>1=>0=>1=>0=>1);
      }
      zero_zero_zero_vbc : coverpoint vif.sig_vbc {
         bins vbc_in_zeros = (0=>0=>0);
      }
      all_vbc_size :   coverpoint vif.sig_vbc;
      size_vbc_size_vbc  : coverpoint vif.sig_vbc {
         bins small_small = ([1:32]=>[1:32]);
         bins small_large = ([1:32]=>[33:160]);
         bins large_small = ([33:160]=>[1:32]);
         bins large_large = ([33:160]=>[33:160]);
      }
      size_vbc_corner_cases  : coverpoint vif.sig_vbc {
         bins case_1a31_32_33a63 = ([1:31]=>32=>[33:63]);
         bins case_32_32_32 = (32=>32=>32);
         bins case_160_160_160 = (160=>160=>160);
         bins case_1a32_160_1a32 = ([1:32]=>160=>[1:32]);
         bins case_160_32a33_160 = (160=>[1:32]=>160);
         bins case_160_33a63_160 = (160=>[33:63]=>160);
      }
      random_data :   coverpoint vif.sig_data;
      random_data_tlm :   coverpoint tlm.pkt.data;
      all_pkt_size :   coverpoint tlm.pkt.size;
      pkt_pkt  : coverpoint tlm.pkt.size {
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
      pkt_nopkt_pkt : coverpoint tlm.pkt.size {
         bins small_zero_small = ([1:32]=>0=>[1:32]);
         bins small_zero_medium = ([1:32]=>0=>[33:160]);
         bins small_zero_large = ([1:32]=>0=>[161:1024]);
         bins medium_zero_small = ([33:160]=>0=>[1:32]);
         bins medium_zero_medium = ([33:160]=>0=>[33:160]);
         bins medium_zero_large = ([33:160]=>0=>[1:32]);
         bins large_zero_small = ([161:1024]=>0=>[1:32]);
         bins large_zero_medium = ([161:1024]=>0=>[33:160]);
         bins large_zero_large = ([161:1024]=>0=>[161:1024]);
      }
      check_ready  : coverpoint vif.sig_ready {
         bins reset_set = (0=>0=>0=>0=>0);
         bins normal_ready = (0=>1=>0);
         bins val0_or_pkt1_32 = (0=>1=>1=>0);
         bins val0_manycycles = (1=>1=>1);
      }
      check_sop  : coverpoint vif.sig_sop {
         bins val0 = (1=>1=>1=>1=>1=>1);
         bins pre_pkt1_32 = (0=>1=>0);
         bins pre_pkt33_64 = (0=>1=>1=>0);
         bins pre_pkt65_96 = (0=>1=>1=>1=>0);
         bins pre_pkt97_128 = (0=>1=>1=>1=>1=>0);
         bins pre_pkt129_160 = (0=>1=>1=>1=>1=>1=>0);
      }
      check_eop  : coverpoint vif.sig_eop {
         bins small_pkts_or_reset = (1=>1=>1=>1=>1=>1);
         bins pre_pkt160 = (0=>1=>1=>1=>1=>1=>0);
         bins small_pkt_between_zeros = (0=>1=>0);
      }
      check_ready  : coverpoint vif.sig_ready {
         bins pkt129_160 = (1=>0=>0=>0=>0=>1);
         bins pkt97_128 = (1=>0=>0=>0=>1);
         bins pkt65_96 = (1=>0=>0=>1);
         bins pkt33_64 = (1=>0=>1);
         bins pkt1_32_or_val0_reset1 = (1=>1);
      }
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
      zero_zero_zero_o_vbc : coverpoint vif.sig_o_vbc {
         bins o_vbc_in_zeros = (0=>0=>0);
      }
      random_data :   coverpoint vif.sig_o_data;
      all_o_vbc_size :   coverpoint vif.sig_o_vbc;
      size_o_vbc_corner_cases  : coverpoint vif.sig_o_vbc {
         bins o_vbc_small_32 = ([1:32]=>32);
         bins o_vbc_32_small = (32=>[1:32]);
      }
      check_o_sop  : coverpoint vif.sig_o_sop {
         bins normal = (0=>1=>0);
         bins small_pkts = (1=>1);
      }
      check_o_eop  : coverpoint vif.sig_o_eop {
         bins normal = (0=>1=>0);
         bins small_pkts = (1=>1);
      }
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
