`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  C-3PO REGS
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

//import common::*;
`include "field.v"
`include "reg_control.v"

module c3po_regs #(
    parameter PORTS_P = 4,
    parameter ADDR_OFFSET_P = 10,
    parameter ADDR_SIZE_P = 6
)(
    input clk,
    input reset_L,

    input [ADDR_SIZE_P-1:0] addr,
    input                   rd_wr,
    input                   req,

    input       [PORTS_P-1:0] cfg_ctrl_err,
    input       [PORTS_P-1:0] cfg_ctrl_idle,
    output reg  [PORTS_P-1:0] cfg_port_enable,
    output reg  [PORTS_P-1:0] [3:0] cfg_port_id,

    input      [31:0]       write_val,
    output reg [31:0]       read_val,
    output reg              ack

);

wire [PORTS_P-1:0]  [31:0] read_val_control;
wire [PORTS_P-1:0]  ack_control;

assign ack = |ack_control;

always_comb begin
    for(int i=0; i<PORTS_P; ++i) begin : read_val_inst
        if(ack_control[i])
            read_val = read_val_control[i];
    end
end

generate
    for(genvar i=0; i<PORTS_P; ++i) begin : slice
        reg_control # (
            .ADDR_SIZE_P(ADDR_SIZE_P),
            .RESET_PORT_ID(i%2),
            .REG_ADDR(ADDR_OFFSET_P*i+0)
        ) REG_CONTROL(
            .clk(clk),
            .reset_L(reset_L),

            .cfg_port_enable(cfg_port_enable[i]),
            .cfg_ctrl_err(cfg_ctrl_err[i]),
            .cfg_ctrl_idle(cfg_ctrl_idle[i]),
            .cfg_port_id(cfg_port_id[i]),

            .addr(addr),
            .req(req),
            .rd_wr(rd_wr),
            .write_val(write_val),
            .read_val(read_val_control[i]),
            .ack(ack_control[i])
        );
    end
endgenerate



endmodule
