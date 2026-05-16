`ifndef AXI_TEST_SV
`define AXI_TEST_SV

class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)

  axi_env env;

  function new(string name = "axi_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi_read_seq rseq;
    axi_stress_seq sseq;
    axi_write_read_seq wrseq;
    axi_write_seq wseq;

    phase.raise_objection(this);
    wrseq = axi_write_read_seq::type_id::create("wrseq");
    sseq = axi_stress_seq::type_id::create("sseq");
    rseq = axi_read_seq::type_id::create("rseq");
    wseq = axi_write_seq::type_id::create("wseq");
    
    wseq.start(env.agent.sequencer);
    rseq.start(env.agent.sequencer);
    wrseq.start(env.agent.sequencer);
    sseq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass

`endif
