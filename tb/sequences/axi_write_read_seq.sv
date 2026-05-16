`ifndef AXI_WRITE_READ_SEQ_SV
`define AXI_WRITE_READ_SEQ_SV

class axi_write_read_seq extends axi_base_seq;
  `uvm_object_utils(axi_write_read_seq)

  function new(string name = "axi_write_read_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;
    item = axi_seq_item::type_id::create("item");
    start_item(item);    // handshake with sequencer - request a slot
    void'(item.randomize() with { op == AXI_WRITE; awaddr == 4'h0;});
    finish_item(item);
    item = axi_seq_item::type_id::create("item");
    start_item(item);    // handshake with sequencer - request a slot
    void'(item.randomize() with { op == AXI_WRITE; awaddr == 4'h4;});
    finish_item(item);
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_WRITE; awaddr == 4'h8;});
    finish_item(item);
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_WRITE; awaddr == 4'hC;});
    finish_item(item);
  
    //Read
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_READ; araddr == 4'h0;});
    finish_item(item);
    
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_READ; araddr == 4'h4;});
    finish_item(item);
    
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_READ; araddr == 4'h8;});
    finish_item(item);
    
    item = axi_seq_item::type_id::create("item");
    start_item(item); 
    void'(item.randomize() with { op == AXI_READ; araddr == 4'hC;});
    finish_item(item);
    
    
  endtask
endclass

`endif
