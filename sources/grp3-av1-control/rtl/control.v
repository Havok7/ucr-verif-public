`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  CONTROL FSM
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

module control_fsm #(
    //parameter int WIDTH_P = 4
)(

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
reg prev_enable;


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

        RESET: begin
            nxt_state = IDLE;
        end

        IDLE: begin
            if(!sop_int && eop_int)
            // if(eop)
                nxt_state = ERROR;
            else if(sop_int && !eop_int)
                nxt_state = WAIT_EOP;
        end

        WAIT_EOP: begin
            if(!sop_int && eop_int)
                nxt_state = IDLE;
            else if(sop_int)
                nxt_state = ERROR;
        end

        ERROR: begin
            nxt_state = IDLE;
        end

    endcase
end


always @(posedge clk) begin
    if(reset_L == 1'b0) begin
        prev_enable <= 1'b0;
        enable <= 1'b0;
    end
    else begin
        if(nxt_state == IDLE) begin
            enable <= cfg_port_enable;
            prev_enable <= enable;
        end
        else
            enable <= prev_enable;
    end
end

assign error = (state == ERROR) ? 1'b1 : 1'b0;


endmodule
