interface counter_if;

parameter WIDTH_P = 4;

    // input interfaces
	logic		sig_clk;
	logic		sig_reset_L;
	logic		sig_en;
	logic		sig_clr;
    logic      [WIDTH_P - 1:0] sig_inc;

    // output interfaces
	logic		sig_overflow;
	logic		sig_non_zero;
    logic 	   [WIDTH_P - 1:0] sig_val;

endinterface: counter_if
