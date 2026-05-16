`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

// Self-checking scoreboard for the AXI4-Lite slave.
// Keeps a software copy of the 4 register file entries and checks
// every completed transaction against it.
class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    // Receives completed transactions from the monitor
    uvm_analysis_imp #(axi_seq_item, axi_scoreboard) item_export;

    // Mirror of the DUT register file — updated on every write
    bit [31:0] reg_file [4];

    function new(string name = "axi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_export = new("item_export", this);
    endfunction

    // Called automatically by UVM every time the monitor sends a transaction
    function void write(axi_seq_item item);
        case (item.op)

            // ── Write transaction ──────────────────────────────────────────
            AXI_WRITE: begin
                if (is_valid_addr(item.awaddr)) begin
                    // Update our register mirror using the write strobe.
                    // Only bytes with wstrb=1 are written — matches DUT behavior.
                    for (int b = 0; b < 4; b++) begin
                        if (item.wstrb[b])
                            reg_file[item.awaddr[3:2]][b*8 +: 8] = item.wdata[b*8 +: 8];
                    end
                    // DUT must respond with OKAY on a valid address
                    if (item.bresp == 2'b00)
                        `uvm_info("SCB", $sformatf("PASS: addr=0x%0h data=0x%0h",
                            item.awaddr, item.wdata), UVM_LOW)
                    else
                        `uvm_error("SCB", $sformatf("FAIL: valid addr got bresp=%0b",
                            item.bresp))
                end else begin
                    // Bad address — DUT must reply with SLVERR
                    if (item.bresp == 2'b10)
                        `uvm_info("SCB", $sformatf("PASS: invalid addr=0x%0h got SLVERR",
                            item.awaddr), UVM_LOW)
                    else
                        `uvm_error("SCB", $sformatf("FAIL: invalid addr expected SLVERR got %0b",
                            item.bresp))
                end
            end

            // ── Read transaction ───────────────────────────────────────────
            AXI_READ: begin
                if (is_valid_addr(item.araddr)) begin
                    if (item.rresp == 2'b00) begin
                        // Compare DUT output against our register mirror
                        if (item.rdata == reg_file[item.araddr[3:2]])
                            `uvm_info("SCB", $sformatf("PASS: addr=0x%0h expected=0x%0h got=0x%0h",
                                item.araddr, reg_file[item.araddr[3:2]], item.rdata), UVM_LOW)
                        else
                            `uvm_error("SCB", $sformatf("FAIL: addr=0x%0h expected=0x%0h got=0x%0h",
                                item.araddr, reg_file[item.araddr[3:2]], item.rdata))
                    end else
                        `uvm_error("SCB", $sformatf("FAIL: valid addr expected OKAY got %0b",
                            item.rresp))
                end else begin
                    // Bad address — DUT must reply with SLVERR
                    if (item.rresp == 2'b10)
                        `uvm_info("SCB", $sformatf("PASS: invalid addr=0x%0h got SLVERR",
                            item.araddr), UVM_LOW)
                    else
                        `uvm_error("SCB", $sformatf("FAIL: invalid addr expected SLVERR got %0b",
                            item.rresp))
                end
            end

        endcase
    endfunction

    // Address is valid if it is word-aligned (bits[1:0] == 0)
    // and points to one of the 4 registers (bits[3:2] < 4)
    function bit is_valid_addr(logic [3:0] addr);
        return (addr[1:0] == 2'b00) && (addr[3:2] < 4);
    endfunction

endclass
`endif