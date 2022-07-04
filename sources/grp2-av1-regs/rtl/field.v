`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FIELD
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

import common::*;

module field #(
    parameter SIZE_P    = 1,
    parameter ACCESS_P  = common::RO
)(
    input clk,
    input reset_L,

    input wr_en,

    input [SIZE_P-1:0] sig_val,
    input [SIZE_P-1:0] write_val,
    input [SIZE_P-1:0] reset_val,

    output reg [SIZE_P-1:0] val
);

    always @(posedge clk) begin
        if(reset_L == 1'b0) begin
            val <= reset_val;
        end
        else
            if(ACCESS_P) begin
                if(wr_en)
                    val <= write_val;
            end
            else
                val <= sig_val;
    end


endmodule
