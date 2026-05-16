`ifndef AXI_STRESS_SEQ_SV
`define AXI_STRESS_SEQ_SV

class axi_stress_seq extends axi_base_seq;
  `uvm_object_utils(axi_stress_seq)

  function new(string name = "axi_stress_seq");
    super.new(name);
  endfunction

  task body();
    axi_seq_item item;
    for (int i=0; i< num_of_transaction * 2; i++) begin
      item = axi_seq_item::type_id::create("item");
      // Some transactions with invalid address:
      start_item(item);
      item.c_addr.constraint_mode(0);
      void'(item.randomize() with { awaddr[1:0] != 2'b00; op == AXI_WRITE; });
      item.c_addr.constraint_mode(1);

      finish_item(item);

      item = axi_seq_item::type_id::create("item");  // fresh!
      start_item(item);
      void'(item.randomize());
      finish_item(item);
    end
    
  endtask
endclass

`endif
