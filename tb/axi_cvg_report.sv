`ifndef AXI_CVG_REPORT_SV
`define AXI_CVG_REPORT_SV

class axi_cvg_report;

  int unsigned sample_count;
  int unsigned write_samples;
  int unsigned read_samples;

  bit hit_op_write;
  bit hit_op_read;
  bit hit_aw_aligned_0;
  bit hit_aw_aligned_4;
  bit hit_aw_aligned_8;
  bit hit_aw_aligned_c;
  bit hit_aw_misaligned;
  bit hit_ar_aligned_0;
  bit hit_ar_aligned_4;
  bit hit_ar_aligned_8;
  bit hit_ar_aligned_c;
  bit hit_ar_misaligned;
  bit hit_bresp_okay;
  bit hit_bresp_slverr;
  bit hit_rresp_okay;
  bit hit_rresp_slverr;

  function void sample(axi_seq_item t);
    sample_count++;
    if (t.op == AXI_WRITE)
      write_samples++;
    else
      read_samples++;

    case (t.op)
      AXI_WRITE: hit_op_write = 1;
      AXI_READ:  hit_op_read  = 1;
    endcase

    case (t.awaddr)
      4'h0: hit_aw_aligned_0 = 1;
      4'h4: hit_aw_aligned_4 = 1;
      4'h8: hit_aw_aligned_8 = 1;
      4'hC: hit_aw_aligned_c = 1;
      default: hit_aw_misaligned = 1;
    endcase

    case (t.araddr)
      4'h0: hit_ar_aligned_0 = 1;
      4'h4: hit_ar_aligned_4 = 1;
      4'h8: hit_ar_aligned_8 = 1;
      4'hC: hit_ar_aligned_c = 1;
      default: hit_ar_misaligned = 1;
    endcase

    case (t.bresp)
      2'b00: hit_bresp_okay   = 1;
      2'b10: hit_bresp_slverr = 1;
    endcase

    case (t.rresp)
      2'b00: hit_rresp_okay   = 1;
      2'b10: hit_rresp_slverr = 1;
    endcase
  endfunction

  function string bin_status(bit hit);
    return hit ? "HIT " : "MISS";
  endfunction

  function void print_section(string title);
    `uvm_info("CVG", "", UVM_LOW)
    `uvm_info("CVG", $sformatf("  %s", title), UVM_LOW)
    `uvm_info("CVG", "  ----------------------------------------", UVM_LOW)
  endfunction

  function void print_cp(string name, real pct);
    `uvm_info("CVG", $sformatf("  %-16s %6.2f%%", name, pct), UVM_LOW)
  endfunction

  function void print_bin(string name, bit hit);
    `uvm_info("CVG", $sformatf("      %-14s %s", name, bin_status(hit)), UVM_LOW)
  endfunction

  function void print(
      real overall,
      real cp_op,
      real cp_awaddr,
      real cp_araddr,
      real cp_wstrb,
      real cp_bresp,
      real cp_rresp
  );
    `uvm_info("CVG", "", UVM_LOW)
    `uvm_info("CVG", "============================================================", UVM_LOW)
    `uvm_info("CVG", "  FUNCTIONAL COVERAGE REPORT", UVM_LOW)
    `uvm_info("CVG", "============================================================", UVM_LOW)

    print_section("Samples");
    `uvm_info("CVG", $sformatf("  Total monitored transactions : %0d", sample_count), UVM_LOW)
    `uvm_info("CVG", $sformatf("    Writes                     : %0d", write_samples), UVM_LOW)
    `uvm_info("CVG", $sformatf("    Reads                      : %0d", read_samples), UVM_LOW)

    print_section("Summary");
    `uvm_info("CVG", $sformatf("  Overall                      %6.2f%%", overall), UVM_LOW)
    `uvm_info("CVG", $sformatf("  Goal (100%%)                 %s",
        overall >= 100.0 ? "MET" : "NOT MET"), UVM_LOW)

    print_section("Coverpoints");
    print_cp("cp_op", cp_op);
    print_bin("write", hit_op_write);
    print_bin("read",  hit_op_read);

    print_cp("cp_awaddr", cp_awaddr);
    print_bin("aligned_0",  hit_aw_aligned_0);
    print_bin("aligned_4",  hit_aw_aligned_4);
    print_bin("aligned_8",  hit_aw_aligned_8);
    print_bin("aligned_c",  hit_aw_aligned_c);
    print_bin("misaligned", hit_aw_misaligned);

    print_cp("cp_araddr", cp_araddr);
    print_bin("aligned_0",  hit_ar_aligned_0);
    print_bin("aligned_4",  hit_ar_aligned_4);
    print_bin("aligned_8",  hit_ar_aligned_8);
    print_bin("aligned_c",  hit_ar_aligned_c);
    print_bin("misaligned", hit_ar_misaligned);

    print_cp("cp_wstrb", cp_wstrb);

    print_cp("cp_bresp", cp_bresp);
    print_bin("OKAY",   hit_bresp_okay);
    print_bin("SLVERR", hit_bresp_slverr);

    print_cp("cp_rresp", cp_rresp);
    print_bin("OKAY",   hit_rresp_okay);
    print_bin("SLVERR", hit_rresp_slverr);

    `uvm_info("CVG", "============================================================", UVM_LOW)
  endfunction

endclass

`endif
