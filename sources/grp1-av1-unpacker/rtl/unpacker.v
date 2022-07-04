`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  UNPACKER FSM
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

module unpacker_fsm #(
    //parameter int WIDTH_P = 4
)(

    input clk,
    input reset_L,

    input val,
    input sop,
    input eop,
    input [7:0] vbc,
    input [160*8-1:0] data,

    output reg o_val,
    output reg o_sop,
    output reg o_eop,
    output reg [7:0] o_vbc,
    output reg [32*8-1:0] o_data,

    output reg idle,
    output reg ready
);

///////////////////////////////////////////////////////
// States
enum {
    RESET,
    IDLE,
    START,
    MID,
    END,
    ERROR
} state_e;
logic [2:0] state, nxt_state;

`ifndef SYNTH
    longint state_debug;

    always_comb begin
        case(state)
        RESET       : state_debug = "RESET";
        IDLE        : state_debug = "IDLE";
        START         : state_debug = "START";
        MID         : state_debug = "MID";
        END         : state_debug = "END";
        ERROR       : state_debug = "ERROR";
        default     : state_debug = "UNKNOWN";
        endcase
    end
`endif

logic val_d, val_lat;
logic sop_d, sop_lat;
logic eop_d, eop_lat;
logic [7:0] vbc_d, vbc_lat, pending, nxt_pending;
logic [160*8-1:0] data_d;

logic [2:0] word, total_word, word_comp, nxt_word;


assign total_word = (vbc_d==160) ? 5 : (vbc_d>>5)+|(vbc_d%32);

//assign nxt_word = (nxt_pending==160) ? 5 : (nxt_pending>>5)+|(nxt_pending%32)-1;
assign nxt_word = (nxt_pending==160) ? 5-1 : (nxt_pending>>5)+|(nxt_pending%32)-(nxt_pending&&1);
assign word_comp = (total_word) ? total_word-word-1 : '0;

assign o_data = data_d[word_comp*32*8 +: 32*8];

always @(posedge clk) begin
    if(reset_L == 1'b0) begin
        state <= RESET;
    end
    else begin
        state <= nxt_state;
        pending <= nxt_pending;
        word <= nxt_word;

        if(ready) begin
            val_d <= val;
            sop_d <= sop;
            eop_d <= eop;
            vbc_d <= vbc;
            data_d <= data;
        end

    end
end

always_comb begin
    nxt_state = state;
    nxt_pending = pending;

    ready = 0;
    idle = 0;

    o_sop = 0;
    o_eop = 0;
    o_val = 0;
    o_vbc = '0;

    case(state)

        RESET: begin
            nxt_state = IDLE;
            nxt_pending = 0;
        end

        IDLE: begin
            if(val && vbc>0) begin
                nxt_state = START;
                nxt_pending = vbc;
            end

            ready = 1;
            idle = 1;
        end

        START: begin
            if(val_d && vbc_d>32)
                nxt_state = (total_word>2) ? MID : END;
            else begin
                if(val && vbc>0) begin
                    nxt_state = START;
                end
                else
                    nxt_state = IDLE;

                ready = 1;
            end

            o_val = val_d;
            o_sop = sop_d;

            if(vbc_d>32) begin
                o_vbc = 32;
                o_eop = 0;
                nxt_pending = vbc_d-32;
            end
            else begin
                nxt_pending = vbc;
                o_vbc = vbc_d;
                o_eop = eop_d;
            end
        end

        MID: begin

            if(pending>32)
                nxt_pending = pending-32;

            if(pending<=64)
                nxt_state = END;


            o_vbc = 32;
            o_sop = 0;
            o_eop = 0;
            o_val = 1;

        end

        END: begin

            if(val && vbc>0)
                nxt_state = START;
            else
                nxt_state = IDLE;

            nxt_pending = vbc;

            o_vbc = pending;
            o_sop = 0;
            o_eop = eop_d;
            o_val = 1;

            ready = 1;

        end

    endcase
end



endmodule
