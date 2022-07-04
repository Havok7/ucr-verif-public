`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  COUNTER
//  melvin.alvarado
//  may 2021
//
//////////////////////////////////////////////////////////////////////////////////

module counter #(
    parameter WIDTH_P = 4
)(
    input clk,
    input reset_L,

    input en,
    input clr,
    input [WIDTH_P-1:0] inc,

    output reg overflow,
    output reg non_zero,
    output reg [WIDTH_P-1:0] val
);

    assign non_zero = |val;

    always @(posedge clk) begin
        if(reset_L == 1'b0) begin
            val <= '0;
            overflow <= '0;
        end
        else
            if(en)
                {overflow,val} <= val + inc;
    end


    `ifdef ASSERT_ON
        ASSERT_001: assert property(
                @(posedge clk) disable iff (reset_L!==1'b1)
                (overflow == 1'b0)
            ) else $error("overflow");
    `endif


    `ifdef COVERAGE_ON
        covergroup covgrp1 @(posedge clk);
            val :   coverpoint val;
            en  :   coverpoint en;
            inc :   coverpoint inc;
        endgroup

        initial begin
            covgrp1 cg1 = new();
        end
    `endif

endmodule
