interface c3po_if #(PORTS_P = 4, CNT_SIZE_P = 8);
   logic sig_clock;
   logic sig_reset_L;

   logic sig_sop;
   logic sig_eop;
   logic sig_val;
   logic [7:0] sig_vbc;
   logic [3:0] sig_id;
   logic [160*8-1:0] sig_data;

   logic [PORTS_P-1:0] sig_o_sop;
   logic [PORTS_P-1:0] sig_o_eop;
   logic [PORTS_P-1:0] sig_o_val;
   logic [PORTS_P-1:0] [7:0] sig_o_vbc;
   logic [PORTS_P-1:0] [32*8-1:0] sig_o_data;
   logic [PORTS_P-1:0] [CNT_SIZE_P-1:0] sig_cnt0_val;
   logic [PORTS_P-1:0] [CNT_SIZE_P-1:0] sig_cnt1_val;
   logic [PORTS_P-1:0] sig_ready;
endinterface: c3po_if
