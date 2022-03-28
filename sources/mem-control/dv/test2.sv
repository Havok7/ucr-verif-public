class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)

  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual mem_intf mem_if;
  memory_env mem_env;

  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if(uvm_config_db #(virtual mem_intf)::get(this, "", "VIRTUAL_INTERFACE", mem_if) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end

      mem_env  = memory_env::type_id::create ("mem_env", this);

      uvm_config_db #(virtual mem_intf)::set (null, "uvm_test_top.mem_env", "VIRTUAL_INTERFACE", mem_if);

  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print();

  endfunction : end_of_elaboration_phase

  gen_item_seq seq;

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);

    uvm_report_info(get_full_name(),"Init Start", UVM_LOW);

    /*set_lp_msg_onoff("LP_PSW_CTRL_INIT_INVALID","OFF");
    set_lp_msg_onoff("LP_ISOEN_INVALID","OFF");
    set_lp_msg_onoff("LP_PSW_CTRL_INVALID","OFF");
    supply_off("VDD");
    supply_off("VSS");

    #100
    //Start VDD power supply
    supply_on("VSS",0);
    #100
    supply_on("VDD",0.95);

    set_lp_msg_onoff("LP_PSW_CTRL_INIT_INVALID","ON");
    set_lp_msg_onoff("LP_ISOEN_INVALID","ON");
    set_lp_msg_onoff("LP_PSW_CTRL_INVALID","ON");

    force tb_top.u_dut.pg_pg_wb2sdrc_en_signal = 0;
    force tb_top.u_dut.pg_pg_sdrc_core_en_signal =0;


    #100
    */
    mem_if.wb_addr_i      = 0;
    mem_if.wb_dat_i      = 0;
    mem_if.wb_sel_i       = 4'h0;
    mem_if.wb_we_i        = 0;
    mem_if.wb_stb_i       = 0;
    mem_if.wb_cyc_i       = 0;

    force tb_top.u_dut.pg_pg_wb2sdrc_en_signal = 1;

    #100

    force tb_top.u_dut.pg_pg_sdrc_core_en_signal =1;

    #100

    mem_if.RESETN    = 1'h1;

    #100
    // Applying reset
    mem_if.RESETN    = 1'h0;
    #10000;
    // Releasing reset
    mem_if.RESETN    = 1'h1;
    #1000;
    wait(tb_top.u_dut.sdr_init_done == 1);

    #1000;
    //mem_env.mem_drv.run_phase();
    uvm_report_info(get_full_name(),"Init Done", UVM_LOW);

    seq = gen_item_seq::type_id::create("seq");

    seq.randomize();
    seq.start(mem_env.mem_ag.mem_seqr);

    phase.drop_objection (this);
  endtask

endclass
