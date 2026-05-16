module axi_sva #(
    parameter int ADDR_WIDTH = 4,   // covers 0x00 to 0x0F
    parameter int DATA_WIDTH = 32
) (
    input  logic                  aclk,
    input  logic                  aresetn,    // active-low reset (AXI standard)

    // ── Write Address Channel ──────────────────────────────────────────────
    input  logic                  awvalid,
    input logic                  awready,
    input  logic [ADDR_WIDTH-1:0] awaddr,

    // ── Write Data Channel ─────────────────────────────────────────────────
    input  logic                  wvalid,
    input logic                  wready,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic [DATA_WIDTH/8-1:0] wstrb,   // byte enable: 1 bit per byte

    // ── Write Response Channel ─────────────────────────────────────────────
    input logic                  bvalid,
    input  logic                  bready,
    input logic [1:0]            bresp,

    // ── Read Address Channel ───────────────────────────────────────────────
    input  logic                  arvalid,
    input logic                  arready,
    input  logic [ADDR_WIDTH-1:0] araddr,

    // ── Read Data Channel ──────────────────────────────────────────────────
    input logic                  rvalid,
    input  logic                  rready,
    input logic [DATA_WIDTH-1:0] rdata,
    input logic [1:0]            rresp
);


  property p_awvalid_stable;
    @(posedge aclk) disable iff(!aresetn)
      (awvalid && !awready) |=> awvalid;
  endproperty

  property p_wvalid_stable;
    @(posedge aclk) disable iff(!aresetn)
    (wvalid && !wready) |=> wvalid;
  endproperty


  property p_arvalid_stable;
    @(posedge aclk) disable iff(!aresetn)
    (arvalid && !arready) |=> (arvalid);
  endproperty

  property p_bresp_stable;
    logic [1:0] bresp_latch;
    @(posedge aclk) disable iff(!aresetn)
    (bvalid && !bready, bresp_latch = bresp) |=> (bresp == bresp_latch);
  endproperty


  assert property(p_awvalid_stable) else
  $error("SVA: awvalid is changed while awready is 0");
  
  assert property(p_wvalid_stable) else
    $error("SVA: wvalid is changed while wready is 0");
  
  assert property(p_arvalid_stable) else
    $error("SVA: arvalid is changed while arready is 0");
  
  assert property(p_bresp_stable) else
   $error("SVA: bresp is not stable while bvalid is High");
  


endmodule: axi_sva
