class c3po_in_agent #(PORTS_P=4) extends uvm_agent;
   `uvm_component_utils(c3po_in_agent)

   // TODO: Separate reg_if
   uvm_analysis_port#(c3po_transaction) agent_ap;

   c3po_sequencer seqr;
   c3po_driver #(.PORTS_P(PORTS_P)) drvr;
   c3po_monitor_in mon_in;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent_ap = new(.name("agent_ap"), .parent(this));
      seqr = c3po_sequencer::type_id::create(.name("seqr"), .parent(this));
      drvr = c3po_driver::type_id::create(.name("drvr"), .parent(this));
      mon_in = c3po_monitor_in::type_id::create(.name("mon_in"), .parent(this));
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      drvr.seq_item_port.connect(seqr.seq_item_export);
      mon_in.mon_ap.connect(agent_ap);
   endfunction: connect_phase
endclass: c3po_in_agent

class c3po_out_agent extends uvm_agent;
   `uvm_component_utils(c3po_out_agent)

   uvm_analysis_port#(c3po_transaction) agent_ap;

   integer slice_id = 0;
   c3po_monitor_out mon_out;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      void'(uvm_config_db#(integer)::get(this, "", "slice_id", slice_id));

      agent_ap = new(.name("agent_ap"), .parent(this));
      mon_out = c3po_monitor_out::type_id::create(.name("mon_out"), .parent(this));

      uvm_config_db#(integer)::set(mon_out, "", "slice_id", slice_id);
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      mon_out.mon_ap.connect(agent_ap);
   endfunction: connect_phase
endclass: c3po_out_agent
