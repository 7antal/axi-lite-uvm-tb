`ifndef AXI_READ_SEQ_SV
`define AXI_READ_SEQ_SV

class axi_read_seq extends axi_base_seq;
  `uvm_object_utils(axi_read_seq)

  function new(string name = "axi_read_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;
    for (int i=0; i<2*num_of_transaction; i++) begin
      item = axi_seq_item::type_id::create("item");
      start_item(item);
      void'(item.randomize() with { op == AXI_READ;});
      finish_item(item);

      item = axi_seq_item::type_id::create("item");
      // Some transactions with invalid address:
      start_item(item);
      item.c_addr.constraint_mode(0);
      void'(item.randomize() with { araddr[1:0] != 2'b00; op == AXI_READ; });
      item.c_addr.constraint_mode(1);
      finish_item(item);

    end
    
  endtask
endclass

`endif
