interface counter_if;

	parameter WIDTH_P = 4;

    // input interfaces
	logic				clk;
	logic				resetL;
	logic				en;
	logic				clr;
    logic [WIDTH_P-1:0]	inc;

    // output interfaces
	logic				overflow;
	logic				non_zero;
    logic [WIDTH_P-1:0] val;

endinterface: counter_if
