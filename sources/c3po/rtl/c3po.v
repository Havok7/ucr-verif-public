`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  C-3PO
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

`include "control.v"
`include "counter.v"
`include "unpacker.v"
`include "regs.v"

module c3po #(
    parameter PORTS_P = 4,
    parameter CNT_SIZE_P = 8
)(
    input clk,
    input reset_L,

    // packet IN
    input val,
    input sop,
    input eop,
    input [3:0] id,
    input [7:0] vbc,
    input [160*8-1:0] data,

    // packet OUT
    output reg [PORTS_P-1:0] o_val,
    output reg [PORTS_P-1:0] o_sop,
    output reg [PORTS_P-1:0] o_eop,
    output reg [PORTS_P-1:0] [7:0] o_vbc,
    output reg [PORTS_P-1:0] [32*8-1:0] o_data,
    output reg [PORTS_P-1:0] [CNT_SIZE_P-1:0] cnt0_val, cnt1_val,
    output reg [PORTS_P-1:0] ready,
    output reg [PORTS_P-1:0] idle,
    output reg [PORTS_P-1:0] [3:0] cfg_port_id
);

logic [PORTS_P-1:0]       cfg_port_enable;
logic [PORTS_P-1:0] val_inst, val_ctrl;


generate
    for(genvar i=0; i<PORTS_P; ++i) begin : slice

        wire control_ena;

        assign val_inst[i] = (id==cfg_port_id[i]) ? val : '0;
        assign val_ctrl[i] = (control_ena) ? val_inst[i] : '0;

        control_fsm CONTROL(
            .clk(clk),
            .reset_L(reset_L),

            .cfg_port_enable(cfg_port_enable[i]),
            .val(val_inst[i]&ready[i]),
            .sop(sop),
            .eop(eop),

            .error(),
            .enable(control_ena)

        );

        wire [CNT_SIZE_P-1:0] cnt0_inc, cnt1_inc;
        wire cnt0_enable, cnt1_enable;
        assign cnt0_enable = (0) ? val_inst[i]&ready[i] : val_inst[i]&ready[i]&eop;
        assign cnt1_enable = (1) ? val_inst[i]&ready[i] : val_inst[i]&ready[i]&eop;
        assign cnt0_inc = (0) ? vbc : 1;
        assign cnt1_inc = (1) ? vbc : 1;

        counter #(
            .WIDTH_P(CNT_SIZE_P)
        ) CNT0 (
            .clk(clk),
            .reset_L(reset_L),
            .en(cnt0_enable),
            .inc(cnt0_inc),
            .clr(1'b0),

            .overflow(),
            .non_zero(),
            .val(cnt0_val[i])
        );

        counter #(
            .WIDTH_P(CNT_SIZE_P)
        ) CNT1 (
            .clk(clk),
            .reset_L(reset_L),
            .en(cnt1_enable),
            .inc(cnt1_inc),
            .clr(1'b0),

            .overflow(),
            .non_zero(),
            .val(cnt1_val[i])
        );

        unpacker_fsm UNPACKER(
            .clk(clk),
            .reset_L(reset_L),

            .val(val_ctrl[i]),
            .sop(sop),
            .eop(eop),
            .vbc(vbc),
            .data(data),

            .o_val(o_val[i]),
            .o_sop(o_sop[i]),
            .o_eop(o_eop[i]),
            .o_vbc(o_vbc[i]),
            .o_data(o_data[i]),

            .idle(idle[i]),
            .ready(ready[i])
        );

    end
endgenerate

    c3po_regs REG(
        .clk(clk),
        .reset_L(reset_L),
        .cfg_port_id(cfg_port_id),
        .cfg_port_enable(cfg_port_enable)
       // TODO: Connect: addr, rd_wr, req, write_val, read_val
    );


endmodule
