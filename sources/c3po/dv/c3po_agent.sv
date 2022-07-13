class c3po_agent extends uvm_agent;
   `uvm_component_utils(c3po_agent)

   uvm_analysis_port#(c3po_transaction) agent_ap_in;
   uvm_analysis_port#(c3po_transaction) agent_ap_out;

   c3po_sequencer seqr;
   c3po_driver drvr;
   c3po_monitor_in mon_in;
   // TODO: Array of output monitors?
   c3po_monitor_out mon_out;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent_ap_in = new(.name("agent_ap_in"), .parent(this));
      agent_ap_out = new(.name("agent_ap_out"), .parent(this));

      seqr = c3po_sequencer::type_id::create(.name("seqr"), .parent(this));
      drvr = c3po_driver::type_id::create(.name("drvr"), .parent(this));
      mon_in = c3po_monitor_in::type_id::create(.name("mon_in"), .parent(this));
      mon_out = c3po_monitor_out::type_id::create(.name("mon_out"), .parent(this));
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drvr.seq_item_port.connect(seqr.seq_item_export);
      mon_in.mon_ap.connect(agent_ap_in);
      mon_out.mon_ap.connect(agent_ap_out);
   endfunction: connect_phase
endclass: c3po_agent
