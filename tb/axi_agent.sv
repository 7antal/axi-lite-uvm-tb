`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  axi_sequencer sequencer;
  axi_driver    driver;
  axi_monitor   monitor;
  uvm_analysis_port #(axi_seq_item) ap;

  function new(string name = "axi_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor   = axi_monitor::type_id::create("monitor", this);
    ap = new("ap", this);  
    if(is_active == UVM_ACTIVE) begin
      sequencer = axi_sequencer::type_id::create("sequencer", this);
      driver    = axi_driver::type_id::create("driver", this);
    end
    
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.ap.connect(this.ap);
  endfunction
endclass

`endif
