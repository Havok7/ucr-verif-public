`include "c3po_pkg.sv"
`include "c3po.v"
`include "c3po_if.sv"

`timescale 1ns/1ps

module c3po_tb_top();
   import uvm_pkg::*;
   import c3po_pkg::*;

   c3po_if vif();

   c3po #() dut(
                .clk(vif.sig_clock),
                .reset_L(vif.sig_reset_L),

                .sop(vif.sig_sop),
                .eop(vif.sig_eop),
                .val(vif.sig_val),
                .id(vif.sig_id),
                .vbc(vif.sig_vbc),
                .data(vif.sig_data),

                .o_sop(vif.sig_o_sop),
                .o_eop(vif.sig_o_eop),
                .o_val(vif.sig_o_val),
                .o_vbc(vif.sig_o_vbc),
                .o_data(vif.sig_o_data),
                .cnt0_val(vif.sig_cnt0_val),
                .cnt1_val(vif.sig_cnt1_val),
                .ready(vif.sig_ready));

   initial begin
      //Registers the Interface in the configuration block so that other
      //blocks can use it
      uvm_resource_db#(virtual c3po_if)::set
        (.scope("ifs"), .name("c3po_if"), .val(vif));
      //Executes the test
      run_test();
   end

   initial begin
      vif.sig_clock <= 1'b1;
   end

   // clk gen
   always #5 vif.sig_clock = ~vif.sig_clock;

   initial begin
      $dumpfile("c3po.vcd");
      $dumpvars(0, c3po, c3po_tb_top);
   end

endmodule
