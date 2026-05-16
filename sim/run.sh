#!/bin/bash
# =============================================================================
# run.sh — VCS simulation script for AXI-Lite UVM testbench
# Usage:
#   cd sim && ./run.sh                    → runs both tests
#   cd sim && ./run.sh axi_test           → runs random test only
#   cd sim && ./run.sh axi_direct_test    → runs directed test only
# =============================================================================

VCS_HOME=$(dirname $(which vcs))/..

# =============================================================================
# Step 1 — Compile (always)
# =============================================================================
vcs                                                     \
    -full64                                             \
    -sverilog                                           \
    -ntb_opts uvm-1.2                                   \
    +incdir+$VCS_HOME/etc/uvm-1.2/src                  \
    +incdir+../tb                                       \
    +incdir+../tb/sequences                             \
    +incdir+../test                                     \
    $VCS_HOME/etc/uvm-1.2/src/uvm_pkg.sv               \
    +define+SIMULATION                                  \
    -timescale=1ns/1ps                                  \
    -cm line+cond+fsm+tgl+branch                        \
    -cm_dir coverage.vdb                                \
    ../rtl/axi_lite_slave.sv                            \
    ../tb/axi_if.sv                                     \
    ../tb/axi_sva.sv                                    \
    ../tb/axi_pkg.sv                                    \
    ../tb/axi_tb_top.sv                                 \
    -top axi_tb_top                                     \
    -o simv

# Check compilation succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Compilation failed"
    exit 1
fi

echo ""
echo "=============================================="
echo " Compilation successful"
echo "=============================================="
echo ""

# =============================================================================
# Step 2 — Run tests
# =============================================================================

# If argument provided, run only that test
if [ $# -eq 1 ]; then
    echo "Running test: $1"
    ./simv                                              \
        +UVM_TESTNAME=$1                                \
        +UVM_VERBOSITY=UVM_LOW                          \
        -cm line+cond+fsm+tgl+branch                    \
        -cm_dir coverage.vdb
    exit $?
fi

# No argument — run ALL tests
echo "=============================================="
echo " Running: axi_test (constrained random)"
echo "=============================================="
./simv                                                  \
    +UVM_TESTNAME=axi_test                              \
    +UVM_VERBOSITY=UVM_LOW                              \
    -cm line+cond+fsm+tgl+branch                        \
    -cm_dir coverage.vdb/axi_test

if [ $? -ne 0 ]; then
    echo "ERROR: axi_test failed"
    exit 1
fi

echo ""
echo "=============================================="
echo " Running: axi_direct_test (directed)"
echo "=============================================="
./simv                                                  \
    +UVM_TESTNAME=axi_direct_test                       \
    +UVM_VERBOSITY=UVM_LOW                              \
    -cm line+cond+fsm+tgl+branch                        \
    -cm_dir coverage.vdb/axi_direct_test

if [ $? -ne 0 ]; then
    echo "ERROR: axi_direct_test failed"
    exit 1
fi

echo ""
echo "=============================================="
echo " ALL TESTS PASSED"
echo "=============================================="