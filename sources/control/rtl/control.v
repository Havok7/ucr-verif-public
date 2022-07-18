`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  CONTROL FSM
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

module control_fsm(

    input clk,
    input reset_L,

    input cfg_port_enable,

    input val,
    input sop,
    input eop,

    output reg  error,
    output reg  enable

);

///////////////////////////////////////////////////////
// States
enum {
    RESET,
    IDLE,
    WAIT_EOP,
    ERROR
} state_e;
reg [1:0] state, nxt_state;

`ifndef SYNTH
    longint state_debug;

    always_comb begin
        case(state)
        RESET       : state_debug = "RESET";
        IDLE        : state_debug = "IDLE";
        WAIT_EOP    : state_debug = "WAIT_EOP";
        ERROR       : state_debug = "ERROR";
        default     : state_debug = "UNKNOWN";
        endcase
    end
`endif

wire sop_int, eop_int;

assign sop_int = val & sop;
assign eop_int = val & eop;


always @(posedge clk) begin
    if(reset_L == 1'b0) begin
        state <= RESET;
    end
    else
        state <= nxt_state;
end

always_comb begin
    nxt_state = state;

    case(state)

        RESET: begin // 00
            nxt_state = IDLE;
        end

        IDLE: begin  // 01
            if(!sop_int && eop_int)
                nxt_state = ERROR;
            else if(sop_int && !eop_int)
                nxt_state = WAIT_EOP;
            else if(sop_int && eop_int)
                nxt_state = IDLE;
        end

        WAIT_EOP: begin  // 10
            if(!sop_int && eop_int)
                nxt_state = IDLE;
            else if(sop_int)
                nxt_state = ERROR;
        end

        ERROR: begin  // 11
            if(!sop_int && eop_int)  //Avance_2
                nxt_state = ERROR;
            else if(sop_int && !eop_int) //Avance_2
                nxt_state = WAIT_EOP;
            else
                nxt_state = IDLE;
        end

    endcase
end

always @(posedge clk) begin
    if(reset_L == 1'b0) begin
        enable <= 1'b0;
    end
    else begin
        if(nxt_state == IDLE || nxt_state == ERROR) begin
            enable <= cfg_port_enable;
        end
    end
end

assign error = (nxt_state == ERROR) ? 1'b1 : 1'b0;

endmodule
