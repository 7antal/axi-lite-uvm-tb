`ifndef AXI_DIRECTED_SEQ_SV
`define AXI_DIRECTED_SEQ_SV
class axi_directed_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_directed_seq)
    axi_op_e     op;
    logic [31:0] data;
    logic [3:0]  addr;
    logic [3:0]  strobe;
    function new(string name = "axi_directed_seq");
        super.new(name);
    endfunction
    task body();
        axi_seq_item item;
        item = axi_seq_item::type_id::create("item");
        start_item(item);
        item.op     = op;
        item.awaddr = addr;
        item.araddr = addr;
        item.wdata  = data;
        item.wstrb  = strobe;
        finish_item(item);
    endtask
endclass
`endif