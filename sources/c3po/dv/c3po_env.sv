class c3po_env #(PORTS_P=4) extends uvm_env;
   `uvm_component_utils(c3po_env)

   c3po_agent #(.PORTS_P(PORTS_P)) agent;
   c3po_scoreboard #(.PORTS_P(PORTS_P)) sb;

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
      for (int i=0; i < PORTS_P; ++i) begin
         agent.agent_ap_in[i].connect(sb.sb_export_in[i]);
         agent.agent_ap_out[i].connect(sb.sb_export_out[i]);
      end
   endfunction: connect_phase
endclass: c3po_env
