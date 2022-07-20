class c3po_env #(PORTS_P=4) extends uvm_env;
   `uvm_component_utils(c3po_env)

   c3po_in_agent #(.PORTS_P(PORTS_P)) agent_in;
   c3po_out_agent agent_out[PORTS_P];
   c3po_scoreboard sb[PORTS_P];

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent_in = c3po_in_agent::type_id::create(.name("agent_in"), .parent(this));
      for (int i=0; i < PORTS_P; ++i) begin
         agent_out[i] = c3po_out_agent::type_id::create(.name($sformatf("agent_out_%0d", i)), .parent(this));
         sb[i]        = c3po_scoreboard::type_id::create(.name($sformatf("sb_%0d", i)), .parent(this));
         uvm_config_db#(integer)::set(agent_out[i], "", "slice_id", i);
         uvm_config_db#(integer)::set(sb[i], "", "slice_id", i);
      end
   endfunction: build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      for (int i=0; i < PORTS_P; ++i) begin
         agent_in.agent_ap.connect(sb[i].sb_export_in);
         agent_out[i].agent_ap.connect(sb[i].sb_export_out);
      end
   endfunction: connect_phase
endclass: c3po_env
