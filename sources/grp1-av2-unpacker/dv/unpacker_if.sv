interface unpacker_if;
   logic sig_clock;
   logic sig_reset_L;

   logic sig_val;
   logic sig_sop;
   logic sig_eop;
   logic [7:0] sig_vbc;
   logic [160*8-1:0] sig_data;

   logic sig_o_val;
   logic sig_o_sop;
   logic sig_o_eop;
   logic [7:0] sig_o_vbc;
   logic [32*8-1:0] sig_o_data;

   logic sig_idle;
   logic sig_ready;
endinterface: unpacker_if
