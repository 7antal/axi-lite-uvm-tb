// =============================================================================
// Module      : axi_lite_slave
// Description : AXI4-Lite compliant slave with 4 x 32-bit memory-mapped
//               registers. Supports single-beat read and write transactions.
//
// Register Map:
//   Offset 0x00 → REG0 : Control  register (R/W)
//   Offset 0x04 → REG1 : Status   register (R/W)
//   Offset 0x08 → REG2 : Data     register (R/W)
//   Offset 0x0C → REG3 : Scratch  register (R/W)
//
// AXI-Lite Channels:
//   AW  : Write Address  (AWVALID, AWREADY, AWADDR)
//   W   : Write Data     (WVALID,  WREADY,  WDATA, WSTRB)
//   B   : Write Response (BVALID,  BREADY,  BRESP)
//   AR  : Read Address   (ARVALID, ARREADY, ARADDR)
//   R   : Read Data      (RVALID,  RREADY,  RDATA, RRESP)
//
// Response Codes:
//   2'b00 : OKAY   — transaction successful
//   2'b10 : SLVERR — slave error (invalid address)
// =============================================================================

module axi_lite_slave #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 32
) (
    input  logic                    aclk,
    input  logic                    aresetn,

    // Write Address Channel
    input  logic                    awvalid,
    output logic                    awready,
    input  logic [ADDR_WIDTH-1:0]   awaddr,

    // Write Data Channel
    input  logic                    wvalid,
    output logic                    wready,
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic [DATA_WIDTH/8-1:0] wstrb,

    // Write Response Channel
    output logic                    bvalid,
    input  logic                    bready,
    output logic [1:0]              bresp,

    // Read Address Channel
    input  logic                    arvalid,
    output logic                    arready,
    input  logic [ADDR_WIDTH-1:0]   araddr,

    // Read Data Channel
    output logic                    rvalid,
    input  logic                    rready,
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [1:0]              rresp
);

    // -------------------------------------------------------------------------
    // Internal register file — 4 x 32-bit registers
    // -------------------------------------------------------------------------
    logic [DATA_WIDTH-1:0] reg_file [0:3];

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic                  aw_active;
    logic [ADDR_WIDTH-1:0] aw_addr_lat;
    logic                  write_addr_valid;
    logic                  read_addr_valid;

    // Address decode
    assign write_addr_valid = (aw_addr_lat[1:0] == 2'b00) &&
                              (aw_addr_lat[ADDR_WIDTH-1:2] < 4);
    assign read_addr_valid  = (araddr[1:0] == 2'b00) &&
                              (araddr[ADDR_WIDTH-1:2] < 4);

    // -------------------------------------------------------------------------
    // Write Address Channel
    // NOTE: aw_active is driven ONLY in this block — resolves ICPD error
    // -------------------------------------------------------------------------
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            awready     <= 1'b0;
            aw_active   <= 1'b0;
            aw_addr_lat <= '0;
        end else begin
            awready <= 1'b0;

            // Accept new address only when slave is not busy
            if (awvalid && !aw_active) begin
                awready     <= 1'b1;
                aw_active   <= 1'b1;
                aw_addr_lat <= awaddr;
            end

            // Clear aw_active once write response is acknowledged by master
            if (bvalid && bready)
                aw_active <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Write Data Channel + Write Response Channel
    // -------------------------------------------------------------------------
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            wready      <= 1'b0;
            bvalid      <= 1'b0;
            bresp       <= 2'b00;
            reg_file[0] <= '0;
            reg_file[1] <= '0;
            reg_file[2] <= '0;
            reg_file[3] <= '0;
        end else begin
            wready <= 1'b0;

            // Accept write data once address has been latched
            if (wvalid && aw_active && !bvalid) begin
                wready <= 1'b1;

                if (write_addr_valid) begin
                    // Apply write strobe — write only enabled bytes
                    for (int b = 0; b < DATA_WIDTH/8; b++) begin
                        if (wstrb[b])
                            reg_file[aw_addr_lat[3:2]][b*8 +: 8] <= wdata[b*8 +: 8];
                    end
                    bresp <= 2'b00;     // OKAY
                end else begin
                    bresp <= 2'b10;     // SLVERR — invalid address
                end

                bvalid <= 1'b1;
            end

            // Clear response once master acknowledges
            if (bvalid && bready)
                bvalid <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Read Address Channel + Read Data Channel
    // -------------------------------------------------------------------------
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            arready <= 1'b0;
            rvalid  <= 1'b0;
            rdata   <= '0;
            rresp   <= 2'b00;
        end else begin
            arready <= 1'b0;

            if (arvalid && !rvalid) begin
                arready <= 1'b1;

                if (read_addr_valid) begin
                    rdata <= reg_file[araddr[3:2]];
                    rresp <= 2'b00;     // OKAY
                end else begin
                    rdata <= '0;
                    rresp <= 2'b10;     // SLVERR
                end

                rvalid <= 1'b1;
            end

            // Clear read response once master acknowledges
            if (rvalid && rready)
                rvalid <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Simulation-only assertions
    // -------------------------------------------------------------------------
    `ifdef SIMULATION
        property p_wstrb_nonzero;
            @(posedge aclk) disable iff (!aresetn)
            (wvalid && wready) |-> (wstrb != 4'b0000);
        endproperty
        assert property (p_wstrb_nonzero)
            else $error("AXI: WSTRB is all zeros on a valid write");

        property p_awaddr_aligned;
            @(posedge aclk) disable iff (!aresetn)
            awvalid |-> (awaddr[1:0] == 2'b00);
        endproperty
        assert property (p_awaddr_aligned)
            else $warning("AXI: Unaligned write address 0x%0h", awaddr);
    `endif

endmodule : axi_lite_slave