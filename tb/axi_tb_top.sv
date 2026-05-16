`timescale 1ns/1ps
`include "uvm_macros.svh"

module axi_tb_top;
  import uvm_pkg::*;
  import axi_pkg::*;

  logic aclk;
  logic aresetn;

  axi_if vif();
  assign vif.clk   = aclk;
  assign vif.rst_n = aresetn;
  axi_lite_slave dut (
    .aclk          (aclk),
    .aresetn       (aresetn),
    .awaddr  (vif.awaddr),
    .awvalid (vif.awvalid),
    .awready (vif.awready),
    .wdata   (vif.wdata),
    .wstrb   (vif.wstrb),
    .wvalid  (vif.wvalid),
    .wready  (vif.wready),
    .bresp   (vif.bresp),
    .bvalid  (vif.bvalid),
    .bready  (vif.bready),
    .araddr  (vif.araddr),
    .arvalid (vif.arvalid),
    .arready (vif.arready),
    .rdata   (vif.rdata),
    .rresp   (vif.rresp),
    .rvalid  (vif.rvalid),
    .rready  (vif.rready)
  );

  bind axi_lite_slave axi_sva sva_inst(
      .aclk    (aclk),
      .aresetn (aresetn),
      .awaddr (awaddr),
      .awvalid (awvalid),
      .awready (awready),
      .wdata (wdata),
      .wstrb (wstrb),
      .wvalid (wvalid),
      .wready (wready),
      .bresp (bresp),
      .bvalid (bvalid),
      .bready (bready),
      .araddr (araddr),
      .arvalid (arvalid),
      .arready (arready),
      .rdata (rdata),
      .rresp (rresp),
      .rvalid (rvalid),
      .rready (rready)
  );

   // Clock generation — toggles every 5ns = 100MHz
    initial aclk=0;
    always #5 aclk=~aclk;


        // Reset — hold low for 20ns then release
    initial begin
        aresetn = 0;
        #20;
        aresetn = 1;
    end


    initial begin
      uvm_config_db #(virtual axi_if)::set(null, "*", "vif", vif);
      run_test();
    end

    
    
  endmodule
