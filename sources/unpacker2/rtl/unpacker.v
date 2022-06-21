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

`ifdef ASSERT_ON
  // 1: Verify output sop is seen when expected
  assert_pkt_start_out: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     ((sop && ready && val) |=> o_sop)
    ) else $error("1. assert_pkt_start_out FAIL!");

  // 2: Verify output eop is seen when expected
  assert_pkt_end_out: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((eop && ready && val) |-> ##[1:5] o_eop)
    ) else $error("2. assert_pkt_end_out FAIL!");

  // 3: Verify output is valid while sending packet
  assert_pkt_start_end_val: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     (o_sop |-> (o_val[*1:$] ##[0:1] o_eop))
    ) else $error("3. assert_pkt_start_end_val FAIL!");

  // 4: Verify DUT is idle after ready but invalid input
  assert_pkt_rdy_non_val_idle: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     ((ready && (val===1'b0)) |=> idle)
   ) else $error("4. assert_pkt_rdy_non_val_idle FAIL!");

  // 5: Verify DUT is non idle after starting packet
  assert_pkt_start_non_idle: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     ((sop && ready && val) |=> idle===1'b0)
    ) else $error("5. assert_pkt_start_non_idle FAIL!");

  // 6: Verify DUT is sending data out after starting packet
  assert_pkt_start_vbc_non_zero: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     ((sop && ready && val) |=> o_vbc!==0)
    ) else $error("6. assert_pkt_start_vbc_non_zero FAIL!");

  // 7: Verify DUT is non idle when it is not ready
  assert_non_rdy_non_idle: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     (ready===1'b0 |-> idle===1'b0)
    ) else $error("7. assert_non_rdy_non_idle FAIL!");

  // 8: Verify DUT is not idle after a reset
  assert_rst_non_idle: assert property(
    @(posedge clk)
     (reset_L===1'b0 |=> idle===1'b0)
    ) else $error("8. assert_rst_non_idle FAIL!");

  // 9: Verify DUT is not sending data out when idle
  assert_idle_vbc_zero: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     (idle |-> o_vbc===0)
    ) else $error("9. assert_idle_vbc_zero FAIL!");

  // 10: Verify DUT is not sending data out after a reset
  assert_rst_vbc_zero: assert property(
    @(posedge clk)
     (reset_L===1'b0 |=> o_vbc===0)
    ) else $error("10. assert_rst_vbc_zero FAIL!");

  // 11: Verify output data is stable when idle is stable
  assert_idle_data_stable: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     (idle && $stable(idle)[*2] |-> $stable(o_data))
   ) else $error("11. assert_idle_data_stable FAIL!");

  // 12: Verify output data is changing when valid is stable
  assert_val_data_non_stable: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1)
     (o_val===1'b1 && $stable(o_val)[*2] |-> !$stable(o_data))
   ) else $error("12. assert_val_data_non_stable FAIL!");

   // 13: Verify reset negedge signal propagation
   assert_reset_propagation: assert property(
    @(posedge clk) 
     ($fell(reset_L) |=> state === RESET)
   ) else $error("13. assert_reset_propagation FAIL!");

   // 14: Verify reset posedge triggers idle state
   assert_reset_to_idle: assert property(
    @(posedge clk)
     ($rose(reset_L) |=> state === IDLE)
   ) else $error("14. assert_reset_to_idle FAIL!");

   // 15: Verify invalid transition from idle state
   assert_idle_invalid_transition: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((state === IDLE) |=> (state !== 3 && state !== 4))
   ) else $error("15. assert_idle_invalid_transition FAIL! %d", state);

   // 16: Verify invalid transition from mid state
   assert_mid_invalid_transition: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((state === MID) |=> (state !== START && state !== IDLE))
   ) else $error("16. assert_mid_invalid_transition FAIL!");

   // 17: Verify invalid transitions from end state
   assert_end_invalid_transition: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((state === END) |=> state !== MID)
   ) else $error("17. assert_end_invalid_transition FAIL!");

   // 18: Verify vbc and next pending sync
   assert_vbc_next_pending: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((state === END) && (pending <= 32) |-> nxt_pending === vbc)
   ) else $error("18. assert_vbc_next_pending FAIL!");

   // 19: Verify start to end time completion
   assert_start_to_end_time: assert property(
    @(posedge clk) disable iff ($sampled(reset_L) !== 1'b1 || $sampled(val) !== 1'b1)
     ((state === START) && (vbc > 32) |->  ##[1:5]state === END)
   ) else $error("19. assert_start_to_end_time FAIL! %d", state);

`endif

endmodule
