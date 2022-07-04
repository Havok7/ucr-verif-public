interface control_if;
    //INPUTS to DUT
	logic clk;
    logic reset_L;

    logic cfg_port_enable;

    logic val;
    logic sop;
    logic eop;

	//OUPUTS DUT
    logic   err;
    logic   enable;
endinterface: control_if