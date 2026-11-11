/*
:name: test_reg_field_reset_kinds_keep_independent_values
:description: hard and soft field resets retain distinct model values (IEEE 1800.2-2020 Section 18.5.5.7)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.7 18.5.5.6 18.5.5.4 18.5.5.1 18.5.5.3 18.5.3.1 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_reset_kinds_keep_independent_values.expected
*/
// What it checks:
// Adding a SOFT reset value preserves the configured HARD value.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.7 (UVM-FIELD-RESET-KIND-INDEPENDENT-VALUES) gives the
// rule above. Setup: Use HARD 35 and SOFT 92 hex, and apply each reset.
// Expected: SOFT restores 92 without changing HARD metadata; HARD later
// restores 35.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Changing the SOFT reset does not replace the configured HARD reset.

module test_reg_field_reset_kinds_keep_independent_values;
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
    automatic uvm_reg_field field = new("f");

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 4, "RW", 0, 8'h35, 1, 0, 0);
    field.reset();
    field.set_reset(8'h92, "SOFT");
    field.reset("SOFT");
    $display("UT: soft desired %0h mirror %0h hard_value %0h soft_value %0h",
             field.get(), field.get_mirrored_value(), field.get_reset(), field.get_reset("SOFT"));
    field.reset();
    $display("UT: hard desired %0h mirror %0h", field.get(), field.get_mirrored_value());
    $finish;
  end
endmodule
