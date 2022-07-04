class unpacker_agent extends uvm_agent;
   `uvm_component_utils(unpacker_agent)

   uvm_analysis_port#(unpacker_transaction) agent_ap_in;
   uvm_analysis_port#(unpacker_transaction) agent_ap_out;

   unpacker_sequencer seqr;
   unpacker_driver drvr;
   unpacker_monitor_in mon_in;
   unpacker_monitor_out mon_out;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent_ap_in = new(.name("agent_ap_in"), .parent(this));
      agent_ap_out = new(.name("agent_ap_out"), .parent(this));

      seqr = unpacker_sequencer::type_id::create(.name("seqr"), .parent(this));
      drvr = unpacker_driver::type_id::create(.name("drvr"), .parent(this));
      mon_in = unpacker_monitor_in::type_id::create(.name("mon_in"), .parent(this));
      mon_out = unpacker_monitor_out::type_id::create(.name("mon_out"), .parent(this));
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drvr.seq_item_port.connect(seqr.seq_item_export);
      mon_in.mon_ap.connect(agent_ap_in);
      mon_out.mon_ap.connect(agent_ap_out);
   endfunction: connect_phase
endclass: unpacker_agent
