`ifndef AXI_WRITE_SEQ_SV
`define AXI_WRITE_SEQ_SV

class axi_write_seq extends axi_base_seq;
  `uvm_object_utils(axi_write_seq)

  function new(string name = "axi_write_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;
    for (int i=0; i<num_of_transaction; i++) begin
      item = axi_seq_item::type_id::create("item");
      start_item(item);
      void'(item.randomize() with { op == AXI_WRITE;});
      finish_item(item);
    end
    
  endtask
endclass

`endif
