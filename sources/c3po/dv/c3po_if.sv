interface c3po_in_if;
   logic sig_clock;
   logic sig_reset_L;

   logic sig_sop;
   logic sig_eop;
   logic sig_val;
   logic [7:0] sig_vbc;
   logic [3:0] sig_id;
   logic [160*8-1:0] sig_data;
endinterface: c3po_in_if

interface c3po_out_if #(CNT_SIZE_P = 8);
   logic sig_o_sop;
   logic sig_o_eop;
   logic sig_o_val;
   logic [7:0] sig_o_vbc;
   logic [32*8-1:0] sig_o_data;
   logic [CNT_SIZE_P-1:0] sig_cnt0_val;
   logic [CNT_SIZE_P-1:0] sig_cnt1_val;
   logic sig_ready;
   logic sig_idle;
   logic [3:0] sig_cfg_port_id;
endinterface: c3po_out_if
