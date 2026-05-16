class axi_coverage extends uvm_subscriber #(axi_seq_item);
    `uvm_component_utils(axi_coverage)
    axi_seq_item item;
    covergroup axi_cg;
        cp_op: coverpoint item.op;
        cp_awaddr: coverpoint item.awaddr;
        cp_araddr: coverpoint item.araddr;
        cp_wstrb: coverpoint item.wstrb{
            illegal_bins invalid = {4'b0000};
        }
        cp_bresp: coverpoint item.bresp {
            bins OKAY   = {2'b00};
            bins SLVERR = {2'b10};
            illegal_bins invalid = {2'b01, 2'b11};
        }

        cp_rresp: coverpoint item.rresp {
            bins OKAY   = {2'b00};
            bins SLVERR = {2'b10};
            illegal_bins invalid = {2'b01, 2'b11};
        }

    endgroup

    function new(string name = "axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        axi_cg = new();  
    endfunction

    function void write(axi_seq_item t);
        item = t;
        axi_cg.sample();
    endfunction


    function void report_phase(uvm_phase phase);
        `uvm_info("CVG", "=================================",                                                   UVM_LOW)
        `uvm_info("CVG", "  FUNCTIONAL COVERAGE REPORT",                                                        UVM_LOW)
        `uvm_info("CVG", "=================================",                                                   UVM_LOW)
        `uvm_info("CVG", $sformatf("  Overall     : %0.2f%%", axi_cg.get_coverage()),                           UVM_LOW)
        `uvm_info("CVG", $sformatf("  cp_op       : %0.2f%%", axi_cg.cp_op.get_coverage()),                     UVM_LOW)
        `uvm_info("CVG", $sformatf("  cp_awaddr   : %0.2f%%", axi_cg.cp_awaddr.get_coverage()),                 UVM_LOW)
        `uvm_info("CVG", $sformatf("  cp_araddr   : %0.2f%%", axi_cg.cp_araddr.get_coverage()),                 UVM_LOW)
        `uvm_info("CVG", $sformatf("  cp_bresp    : %0.2f%%", axi_cg.cp_bresp.get_coverage()),                  UVM_LOW)
        `uvm_info("CVG", $sformatf("  cp_rresp    : %0.2f%%", axi_cg.cp_rresp.get_coverage()),                  UVM_LOW)
        `uvm_info("CVG", $sformatf("  wstrb       : %0.2f%%", axi_cg.cp_wstrb.get_coverage()),                     UVM_LOW)
        `uvm_info("CVG", "=================================",                                                   UVM_LOW)
endfunction : report_phase

endclass : axi_coverage