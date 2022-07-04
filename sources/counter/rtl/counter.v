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

        covergroup covgrp2 @(posedge clk);
            coverpoint val {
                bins zero = {0};
                bins lo = {[1:3], 5};
                bins hi = {[8:$]};
                //bins misc = default;
                //illegal_bins four = {4};
            }
        endgroup

        covergroup covgrp3  @(posedge clk);
            coverpoint val {
                bins tr_zero = (1=>0), (2=>0), (3=>0), (15=>0);
            }
        endgroup


        covergroup covgrp4  @(posedge clk);
            en  :   coverpoint en;
            inc :   coverpoint inc {
                bins zero = {0};
                bins non_zero = {[1:$]};
            }
            clr :   coverpoint clr;
            reset_L: coverpoint reset_L;
            cross en, inc, clr, reset_L;
        endgroup

        initial begin
            covgrp1 cg1 = new();
            covgrp2 cg2 = new();
            covgrp3 cg3 = new();
            covgrp4 cg4 = new();
        end
    `endif

endmodule
