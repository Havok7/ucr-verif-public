//////////////////////////////////////////////////////////////////////////////////
//
// melvin.alvarado
// may 2021
//
//////////////////////////////////////////////////////////////////////////////////
`include "unpacker_pkg.sv"
`include "unpacker.v"
`include "unpacker_if.sv"

`timescale 1ns/1ps

module unpacker_tb_top();
   import uvm_pkg::*;
   import unpacker_pkg::*;

   unpacker_if vif();

   unpacker_fsm dut(
                .clk(vif.sig_clock),
                .reset_L(vif.sig_reset_L),

                .val(vif.sig_val),
                .sop(vif.sig_sop),
                .eop(vif.sig_eop),
                .vbc(vif.sig_vbc),
                .data(vif.sig_data),

                .o_val(vif.sig_o_val),
                .o_sop(vif.sig_o_sop),
                .o_eop(vif.sig_o_eop),
                .o_vbc(vif.sig_o_vbc),
                .o_data(vif.sig_o_data),

                .idle(vif.sig_idle),
                .ready(vif.sig_ready));

   initial begin
      //Registers the Interface in the configuration block so that other
      //blocks can use it
      uvm_resource_db#(virtual unpacker_if)::set
        (.scope("ifs"), .name("unpacker_if"), .val(vif));
      //Executes the test
      run_test();
   end

   initial begin
      vif.sig_clock <= 1'b1;
   end

   // clk gen
   always #5 vif.sig_clock = ~vif.sig_clock;

   initial begin
      $dumpfile("unpacker.vcd");
      $dumpvars(0, unpacker_fsm, unpacker_tb_top);
   end

endmodule
