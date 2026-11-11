/*
:name: test_reg_set_distributes_desired_slices_without_changing_mirror
:description: register set slices desired data across fields and retains the mirror (IEEE 1800.2-2020 Section 18.4.4.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.2 18.4.4.1 18.4.4.3 18.5.5.1 18.5.3.2 18.4.4.5 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_set_distributes_desired_slices_without_changing_mirror.expected
*/
// What it checks:
// Register set distributes desired bit slices without changing the mirror.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.4.2 (UVM-REG-SET-FIELD-SLICES-RETAIN-MIRROR) gives the rule
// above. Setup: Set abcd on two eight-bit fields after reset 1234 hex.
// Expected: Low/high are cd/ab, desired is abcd and mirror stays 1234 hex.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe both fields and the aggregate value after a model-only set.

module test_reg_set_distributes_desired_slices_without_changing_mirror;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk");
      super.new(name, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=16);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin

    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 16);
    automatic uvm_reg_field low = new("low");
    automatic uvm_reg_field high = new("high");

    blk.configure();
    rg.configure(blk);
    high.configure(rg, 8, 8, "RW", 0, 8'h12, 1, 0, 1);
    low.configure(rg, 8, 0, "RW", 0, 8'h34, 1, 0, 1);
    rg.reset();
    rg.set(16'habcd);
    $display("UT: desired %0h low %0h high %0h mirror %0h", rg.get(), low.get(),
             high.get(), rg.get_mirrored_value());
    $finish;
  end
endmodule
