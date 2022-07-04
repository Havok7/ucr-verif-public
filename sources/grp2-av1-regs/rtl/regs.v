`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  REGS
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

//import common::*;
`include "field.v"
`include "reg_control.v"

module regs #(
    parameter ADDR_SIZE_P = 4
)(
    input clk,
    input reset_L,

    input [ADDR_SIZE_P-1:0] addr,
    input                   rd_wr,
    input                   req,

    input       [1:0]       cfg_ctrl_err,
    input       [1:0]       cfg_ctrl_idle,
    output reg  [1:0]       cfg_port_enable,
    output reg  [3:0] [1:0] cfg_port_id,

    input      [31:0]       write_val,
    output reg [31:0]       read_val,
    output reg              ack

);

    logic [31:0] [1:0]  read_val_int;
    logic        [1:0]  ack_int;
    logic [31:0]        addr_d;


    always_ff @(posedge clk) begin
        addr_d <= addr;
    end


    always_comb begin
        case(addr_d)
            0:  begin
                    read_val = read_val_int[0];
                    ack = ack_int[0];
            end
            1:  begin
                    read_val = read_val_int[1];
                    ack = ack_int[1];
            end
        endcase
    end


    reg_control # (
        .ADDR_SIZE_P(ADDR_SIZE_P),
        .RESET_PORT_ID(0),
        .REG_ADDR(0)
    ) REG_CONTROL_0(
        .clk(clk),
        .reset_L(reset_L),

        .cfg_port_enable(cfg_port_enable[0]),
        .cfg_ctrl_err(cfg_ctrl_err[0]),
        .cfg_ctrl_idle(cfg_ctrl_idle[0]),
        .cfg_port_id(cfg_port_id[0]),

        .addr(addr),
        .req(req),
        .rd_wr(rd_wr),
        .write_val(write_val),
        .read_val(read_val_int[0]),
        .ack(ack_int[0])

    );


    reg_control # (
        .ADDR_SIZE_P(ADDR_SIZE_P),
        .RESET_PORT_ID(1),
        .REG_ADDR(1)
    ) REG_CONTROL_1(
        .clk(clk),
        .reset_L(reset_L),

        .cfg_port_enable(cfg_port_enable[1]),
        .cfg_ctrl_err(cfg_ctrl_err[1]),
        .cfg_ctrl_idle(cfg_ctrl_idle[1]),
        .cfg_port_id(cfg_port_id[1]),

        .addr(addr),
        .req(req),
        .rd_wr(rd_wr),
        .write_val(write_val),
        .read_val(read_val_int[1]),
        .ack(ack_int[1])

    );



endmodule
