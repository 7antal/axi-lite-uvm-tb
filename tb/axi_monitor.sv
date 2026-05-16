`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV

class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)

  virtual axi_if vif;
  uvm_analysis_port #(axi_seq_item) ap;

  function new(string name = "axi_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "axi_if virtual interface was not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    // Wait for reset
    @(posedge vif.clk);
    while(!vif.rst_n) @(posedge vif.clk);

    fork
      forever monitor_write();
      forever monitor_read();
    join_none
  endtask


  task monitor_write();
    axi_seq_item item;
    
    item = axi_seq_item::type_id::create("item");
    item.op = AXI_WRITE;


     @(posedge vif.clk);
    while(!vif.rst_n) @(posedge vif.clk);

    while(!(vif.awvalid && vif.awready)) @(posedge vif.clk);
    item.awaddr = vif.awaddr;
    while (!(vif.wready && vif.wvalid)) @(posedge vif.clk);
    item.wdata = vif.wdata;
    item.wstrb = vif.wstrb;
    while (!(vif.bvalid && vif.bready)) @(posedge vif.clk);
    item.bresp = vif.bresp;
    ap.write(item);

  endtask : monitor_write
      

  task monitor_read();
  
    axi_seq_item item;
    item = axi_seq_item::type_id::create("item");
     @(posedge vif.clk);
    while(!vif.rst_n) @(posedge vif.clk);

    item.op = AXI_READ;
    while(!(vif.arvalid && vif.arready)) @(posedge vif.clk);
    item.araddr = vif.araddr;
    while(!(vif.rvalid && vif.rready)) @(posedge vif.clk);
    item.rdata = vif.rdata;
    item.rresp = vif.rresp;
    ap.write(item);
  endtask: monitor_read



endclass

`endif