interface c3po_in_if #(PORTS_P = 4);
   logic sig_clock;
   logic sig_reset_L;
   logic sig_sop;
   logic sig_eop;
   logic sig_val;
   logic [7:0] sig_vbc;
   logic [3:0] sig_id;
   logic [160*8-1:0] sig_data;
   logic [PORTS_P-1:0] sig_ready;
   logic [PORTS_P-1:0] [3:0] sig_cfg_port_id;
   logic [PORTS_P-1:0] sig_ctrl_port_enable;
endinterface: c3po_in_if

interface c3po_out_if #(CNT_SIZE_P = 8);
   logic sig_clock;
   logic sig_reset_L;
   logic sig_o_sop;
   logic sig_o_eop;
   logic sig_o_val;
   logic [7:0] sig_o_vbc;
   logic [32*8-1:0] sig_o_data;
   logic [CNT_SIZE_P-1:0] sig_cnt0_val;
   logic [CNT_SIZE_P-1:0] sig_cnt1_val;
   logic sig_ready;
endinterface: c3po_out_if

interface c3po_reg_if #(ADDR_SIZE_P = 6);
   logic sig_clock;
   logic sig_reset_L;
   logic [ADDR_SIZE_P-1:0] sig_addr;
   logic sig_req;
   logic sig_rd_wr;
   logic [31:0] sig_write_val;
   logic [31:0] sig_read_val;
   logic sig_ack;
endinterface: c3po_reg_if
