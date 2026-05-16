`ifndef AXI_BASE_SEQ_SV
`define AXI_BASE_SEQ_SV

class axi_base_seq extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_base_seq)
  int num_of_transaction = 20;

  function new(string name = "axi_base_seq");
    super.new(name);
  endfunction
  

  task body();
  endtask

endclass

`endif
