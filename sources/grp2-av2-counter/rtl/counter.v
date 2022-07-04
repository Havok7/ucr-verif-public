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
        
        // Proprety: Reset 
        property reset_counter;
            @(posedge clk) 
                !reset_L |-> (val == 0 && overflow == 0 && non_zero == 0);
        endproperty

        // Property: Clear Value
        property clear_val;
            @(posedge clk) disable iff (reset_L!==1'b1)
                clr |=> (val == 0);
        endproperty

        // Property: Overflow detection
        property overflow_check;
            @(posedge clk) disable iff (reset_L!==1'b1)
                overflow == 0;
        endproperty

        // Property: Indicate when value is zero
        property zero_value;
            @(posedge clk) disable iff (reset_L!==1'b1)
                non_zero == 1;
        endproperty

        // Property: Increment max range
        property inc_range;
            @(posedge clk) disable iff (reset_L!==1'b1)
            inc <= 4'hFFFF;
        endproperty

        // Property: count when enabled
        property count_increase;
            @(posedge clk) disable iff (reset_L!==1'b1)
                (en && (inc != 0)) |=> !($stable(val));
        endproperty



        assert property(clear_val) else $error("RESET NOT CLEARED");

        assert property(overflow_check) else $error("OVERFLOW DETECTED");

        assert property(zero_value) else $info("CURRENT VALUE IS ZERO");

        assert property(reset_counter) else $warning("RESET NOT DEASSERTED");

        assert property(inc_range) else $error("INCREMENT VALUE OUT OF RANGE");

        assert property(count_increase) else $error("NO COUNT INCREASE WHEN EXPECTED");

    `endif


endmodule
