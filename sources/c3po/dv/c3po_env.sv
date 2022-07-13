class c3po_env extends uvm_env;
   `uvm_component_utils(c3po_env)

   c3po_agent agent;
   c3po_scoreboard sb;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = c3po_agent::type_id::create(.name("agent"), .parent(this));
      sb    = c3po_scoreboard::type_id::create(.name("sb"), .parent(this));
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // TODO: Array of analysis ports?
      agent.agent_ap_in.connect(sb.sb_export_in);
      agent.agent_ap_out.connect(sb.sb_export_out);
   endfunction: connect_phase
endclass: c3po_env
