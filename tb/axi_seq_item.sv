`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

class axi_seq_item extends uvm_sequence_item;
  `uvm_object_utils(axi_seq_item)

  rand axi_op_e op;
  rand logic [3:0] awaddr;
  rand logic [3:0] wstrb;
  rand logic [3:0] araddr;
  rand logic [31:0] wdata;
  logic [31:0]      rdata;
  logic [1:0]            bresp;
  logic [1:0]            rresp;
  

  //constraints
  constraint c_wstrb { op == AXI_WRITE -> wstrb != 4'b0000; }
  constraint c_addr  { awaddr inside {4'h0, 4'h4, 4'h8, 4'hC};
                     araddr inside {4'h0, 4'h4, 4'h8, 4'hC}; }



  // cunstructor
  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction : new
  



endclass

`endif
