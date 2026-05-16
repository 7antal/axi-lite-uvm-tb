package axi_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    typedef enum {AXI_WRITE, AXI_READ} axi_op_e;

    // 1. Transaction first
    `include "axi_seq_item.sv"

    // 2. Sequencer before sequences
    `include "axi_sequencer.sv"

    // 3. Sequences — base first
    `include "sequences/axi_base_seq.sv"
    `include "sequences/axi_read_seq.sv"
    `include "sequences/axi_stress_seq.sv"
    `include "sequences/axi_write_read_seq.sv"
    `include "sequences/axi_write_seq.sv"
    `include "sequences/axi_directed_seq.sv"

    // 4. Driver and monitor
    `include "axi_driver.sv"
    `include "axi_monitor.sv"

    // 5. Scoreboard and coverage
    `include "axi_scoreboard.sv"
    `include "axi_cvg_report.sv"
    `include "axi_coverage.sv"

    // 6. Agent then env
    `include "axi_agent.sv"
    `include "axi_env.sv"

    // 7. Test last
    `include "../test/axi_test.sv"
    `include "../test/axi_direct_test.sv"

endpackage : axi_pkg