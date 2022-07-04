interface regs_if;

parameter ADDR_SIZE_P = 4;

    // input interfaces
	logic		sig_clk;
	logic		sig_reset_L;
	logic		[ADDR_SIZE_P-1:0] sig_addr;
	logic		sig_rd_wr;
	logic		sig_req;
	logic       [1:0] sig_cfg_ctrl_err;
    logic       [1:0] sig_cfg_ctrl_idle;
	logic  		[1:0]       sig_cfg_port_enable;
	logic 		[3:0] [1:0] sig_cfg_port_id;
	logic 		[31:0] sig_write_val;

    // output interfaces
	logic		[31:0] sig_read_val;
	logic       sig_ack;

endinterface: regs_if