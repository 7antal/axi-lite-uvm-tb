`ifndef AXI_DIRECTED_TEST
`define AXI_DIRECTED_TEST

class axi_direct_test extends uvm_test;
  `uvm_component_utils(axi_direct_test)

  axi_env env;

  function new(string name = "axi_direct_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        // T1 — max value
        `uvm_info("DIR", "T1: Writing 0xFFFFFFFF", UVM_LOW)
        send(AXI_WRITE, 4'h0, 32'hFFFFFFFF, 4'b1111);
        send(AXI_WRITE, 4'h4, 32'hFFFFFFFF, 4'b1111);
        send(AXI_WRITE, 4'h8, 32'hFFFFFFFF, 4'b1111);
        send(AXI_WRITE, 4'hC, 32'hFFFFFFFF, 4'b1111);
        send(AXI_READ,  4'h0, 32'h0,        4'b0000);
        send(AXI_READ,  4'h4, 32'h0,        4'b0000);
        send(AXI_READ,  4'h8, 32'h0,        4'b0000);
        send(AXI_READ,  4'hC, 32'h0,        4'b0000);

        // T2 — zero
        `uvm_info("DIR", "T2: Writing 0x00000000", UVM_LOW)
        send(AXI_WRITE, 4'h0, 32'h00000000, 4'b1111);
        send(AXI_WRITE, 4'h4, 32'h00000000, 4'b1111);
        send(AXI_WRITE, 4'h8, 32'h00000000, 4'b1111);
        send(AXI_WRITE, 4'hC, 32'h00000000, 4'b1111);
        send(AXI_READ,  4'h0, 32'h0,        4'b0000);
        send(AXI_READ,  4'h4, 32'h0,        4'b0000);
        send(AXI_READ,  4'h8, 32'h0,        4'b0000);
        send(AXI_READ,  4'hC, 32'h0,        4'b0000);

        // T3 — alternating
        `uvm_info("DIR", "T3: Alternating pattern", UVM_LOW)
        send(AXI_WRITE, 4'h0, 32'hAAAAAAAA, 4'b1111);
        send(AXI_READ,  4'h0, 32'h0,        4'b0000);
        send(AXI_WRITE, 4'h0, 32'h55555555, 4'b1111);
        send(AXI_READ,  4'h0, 32'h0,        4'b0000);

        // T4 — byte strobe
        `uvm_info("DIR", "T4: Byte strobe test", UVM_LOW)
        send(AXI_WRITE, 4'h0, 32'hFFFFFFFF, 4'b1111); // write full word first
        send(AXI_WRITE, 4'h0, 32'h00000000, 4'b0001); // write only byte 0
        send(AXI_READ,  4'h0, 32'h0,        4'b0000); // read back — expect 0xFFFFFF00

        // T5 — invalid address
        `uvm_info("DIR", "T5: Invalid address test", UVM_LOW)
        send(AXI_WRITE, 4'h1, 32'hDEADBEEF, 4'b1111); // expect SLVERR

        phase.drop_objection(this);
    endtask

  task send(axi_op_e op, logic [3:0] addr, logic [31:0] data, logic [3:0] strobe);
    axi_directed_seq item;
    item = axi_directed_seq::type_id::create("item");
    item.op     = op;
    item.addr   = addr;
    item.data   = data;
    item.strobe = strobe;
    item.start(env.agent.sequencer);
endtask


endclass

`endif
