`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_agent      agent;
  axi_scoreboard scoreboard;
  axi_coverage   coverage;

  function new(string name = "axi_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);    // ← missing!
    agent = axi_agent::type_id::create("agent",this);
    scoreboard = axi_scoreboard::type_id::create("scoreboard",this);
    coverage = axi_coverage::type_id::create("coverage",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.ap.connect(scoreboard.item_export);
    agent.ap.connect(coverage.analysis_export);
    `uvm_info("ENV", "Connections done", UVM_LOW)
  endfunction
endclass

`endif
