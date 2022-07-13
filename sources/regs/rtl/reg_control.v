`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  REG CONTROL
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

import common::*;

module reg_control #(
    parameter REG_SIZE_P = 32,
    parameter ADDR_SIZE_P = 4,
    parameter RESET_PORT_ID = 0,
    parameter RESET_PORT_ENABLE = 1,
    parameter REG_ADDR = 0

)(
    input clk,
    input reset_L,

    input       cfg_ctrl_err,
    input       cfg_ctrl_idle,
    output reg  cfg_port_enable,
    output reg  [3:0] cfg_port_id,

    input                   req,
    input                   rd_wr,
    input [ADDR_SIZE_P-1:0] addr,
    input [REG_SIZE_P-1:0]  write_val,

    output reg                  ack,
    output reg [REG_SIZE_P-1:0] read_val

);

    reg [REG_SIZE_P-1:0] nxt_read_val;
    wire wr_en;
    assign wr_en = (addr==REG_ADDR) ? ~rd_wr&req : 1'b0;

    always @(posedge clk) begin
        ack <= (addr==REG_ADDR) ? req : 1'b0;
        read_val <= nxt_read_val;
    end

    always_comb begin
        nxt_read_val = '0;
        nxt_read_val[0] = cfg_port_enable;
        nxt_read_val[1] = cfg_ctrl_idle_rd;
        nxt_read_val[2] = cfg_ctrl_err_rd;
        nxt_read_val[7:4] = cfg_port_id;
    end


    field #(
        .ACCESS_P(common::RW),
        .SIZE_P(1)
    ) PORT_ENABLE (
        .clk(clk),
        .reset_L(reset_L),
        .wr_en(wr_en),
        .write_val(write_val[0]),
        .sig_val('0),
        .reset_val(RESET_PORT_ENABLE[0]),
        .val(cfg_port_enable)
    );

    field #(
        .ACCESS_P(common::RO),
        .SIZE_P(1)
    ) IDLE (
        .clk(clk),
        .reset_L(reset_L),
        .wr_en('0),
        .write_val('0),
        .sig_val(cfg_ctrl_idle),
        .reset_val('0),
        .val(cfg_ctrl_idle_rd)
    );


    field #(
        .ACCESS_P(common::RO),
        .SIZE_P(1)
    ) ERROR (
        .clk(clk),
        .reset_L(reset_L),
        .wr_en('0),
        .write_val('0),
        .sig_val(cfg_ctrl_err),
        .reset_val('0),
        .val(cfg_ctrl_err_rd)
    );


    field #(
        .ACCESS_P(common::RW),
        .SIZE_P(4)
    ) PORT_ID (
        .clk(clk),
        .reset_L(reset_L),
        .wr_en(wr_en),
        .write_val(write_val[7:4]),
        .sig_val('0),
        .reset_val(RESET_PORT_ID[3:0]),
        .val(cfg_port_id)
    );

endmodule
