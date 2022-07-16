`include "c3po_pkg.sv"
`include "c3po.v"
`include "c3po_if.sv"

`timescale 1ns/1ps

module c3po_tb_top #(parameter PORTS_P=4,
                     parameter CNT_SIZE_P=8)();
   import uvm_pkg::*;
   import c3po_pkg::*;

   c3po_in_if vif_in();
   c3po_reg_if vif_reg();
   c3po_out_if vif_out[PORTS_P]();

   wire [PORTS_P-1:0] o_sop;
   wire [PORTS_P-1:0] o_eop;
   wire [PORTS_P-1:0] o_val;
   wire [PORTS_P-1:0] [7:0] o_vbc;
   wire [PORTS_P-1:0] [32*8-1:0] o_data;
   wire [PORTS_P-1:0] [CNT_SIZE_P-1:0] cnt0_val;
   wire [PORTS_P-1:0] [CNT_SIZE_P-1:0] cnt1_val;
   wire [PORTS_P-1:0] ready;
   wire [PORTS_P-1:0] idle;
   wire [PORTS_P-1:0] [3:0] cfg_port_id;
   wire [PORTS_P-1:0] cfg_port_enable;

generate
    // Connect DUT output signals with interfaces
    for(genvar i=0; i < PORTS_P; ++i) begin
       assign vif_out[i].sig_o_sop = o_sop[i];
       assign vif_out[i].sig_o_eop = o_eop[i];
       assign vif_out[i].sig_o_val = o_val[i];
       assign vif_out[i].sig_o_vbc = o_vbc[i];
       assign vif_out[i].sig_o_data = o_data[i];
       assign vif_out[i].sig_cnt0_val = cnt0_val[i];
       assign vif_out[i].sig_cnt1_val = cnt1_val[i];
       assign vif_out[i].sig_ready = ready[i];
       assign vif_out[i].sig_idle = idle[i];
       assign vif_out[i].sig_cfg_port_id = cfg_port_id[i];
       assign vif_out[i].sig_cfg_port_enable = cfg_port_enable[i];
    end
endgenerate

   c3po #() dut(
                .clk(vif_in.sig_clock),
                .reset_L(vif_in.sig_reset_L),

                .reg_addr(vif_reg.sig_addr),
                .reg_req(vif_reg.sig_req),
                .reg_rd_wr(vif_reg.sig_rd_wr),
                .reg_write_val(vif_reg.sig_write_val),
                .reg_read_val(vif_reg.sig_read_val),
                .reg_ack(vif_reg.sig_ack),

                .sop(vif_in.sig_sop),
                .eop(vif_in.sig_eop),
                .val(vif_in.sig_val),
                .id(vif_in.sig_id),
                .vbc(vif_in.sig_vbc),
                .data(vif_in.sig_data),

                .o_sop(o_sop),
                .o_eop(o_eop),
                .o_val(o_val),
                .o_vbc(o_vbc),
                .o_data(o_data),
                .cnt0_val(cnt0_val),
                .cnt1_val(cnt1_val),
                .ready(ready),
                .idle(idle),
                .cfg_port_id(cfg_port_id),
                .cfg_port_enable(cfg_port_enable));

generate
   // Registers the Interfaces in the configuration block so that other
   // blocks can use them
   initial begin
      uvm_resource_db#(virtual c3po_in_if)::set
        (.scope("ifs"), .name("c3po_in_if"), .val(vif_in));
      uvm_resource_db#(virtual c3po_reg_if)::set
        (.scope("ifs"), .name("c3po_reg_if"), .val(vif_reg));
   end

   for(genvar p=0; p < PORTS_P; ++p) begin
      initial begin
         uvm_resource_db#(virtual c3po_out_if)::set
           (.scope("ifs"), .name($sformatf("c3po_out_if_%0d", p)), .val(vif_out[p]));
      end
   end
endgenerate

   initial begin
      //Executes the test
      run_test();
   end

   initial begin
      vif_in.sig_clock <= 1'b1;
   end

   // clk gen
   always #5 vif_in.sig_clock = ~vif_in.sig_clock;

   initial begin
      $dumpfile("c3po.vcd");
      $dumpvars(0, c3po, c3po_tb_top);
   end

endmodule
