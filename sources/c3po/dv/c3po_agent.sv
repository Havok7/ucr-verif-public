class c3po_agent #(PORTS_P=4) extends uvm_agent;
   `uvm_component_utils(c3po_agent)

   uvm_analysis_port#(c3po_transaction) agent_ap_in[PORTS_P];
   uvm_analysis_port#(c3po_transaction) agent_ap_out[PORTS_P];

   c3po_sequencer seqr;
   c3po_driver #(.PORTS_P(PORTS_P)) drvr;
   c3po_monitor_in mon_in[PORTS_P];
   c3po_monitor_out mon_out[PORTS_P];

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      for (int i=0; i < PORTS_P; ++i) begin
         agent_ap_in[i] = new(.name($sformatf("agent_ap_in_%0d", i)), .parent(this));
         agent_ap_out[i] = new(.name($sformatf("agent_ap_out_%0d", i)), .parent(this));
      end

      seqr = c3po_sequencer::type_id::create(.name("seqr"), .parent(this));
      drvr = c3po_driver::type_id::create(.name("drvr"), .parent(this));

      for (int i=0; i < PORTS_P; ++i) begin
         mon_in[i] = c3po_monitor_in::type_id::create(.name($sformatf("mon_in_%0d", i)),
                                                      .parent(this));
         mon_out[i] = c3po_monitor_out::type_id::create(.name($sformatf("mon_out_%0d", i)),
                                                        .parent(this));
         uvm_config_db#(integer)::set(mon_in[i], "", "slice_id", i);
         uvm_config_db#(integer)::set(mon_out[i], "", "slice_id", i);
      end
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drvr.seq_item_port.connect(seqr.seq_item_export);
      for (int i=0; i < PORTS_P; ++i) begin
         mon_in[i].mon_ap.connect(agent_ap_in[i]);
         mon_out[i].mon_ap.connect(agent_ap_out[i]);
      end
   endfunction: connect_phase
endclass: c3po_agent
