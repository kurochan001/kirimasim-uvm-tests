/*
:name: test_reg_field_set_changes_desired_without_predicting_mirror
:description: set changes desired value while leaving the mirror unchanged (IEEE 1800.2-2020 Section 18.5.5.2)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.2 18.5.5.1 18.5.5.3 18.5.5.8 18.5.3.1 18.5.3.2 18.5.5.4 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_set_changes_desired_without_predicting_mirror.expected
*/
// What it checks:
// RW set changes desired state while retaining the mirror.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.2 (UVM-FIELD-SET-DESIRED-WITHOUT-PREDICTION) gives the
// rule above. Setup: Reset to 35 then set ab hex. Expected: Desired is ab,
// mirror is 35 and needs_update is true.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A writable field becomes dirty after set. Model access is not a DUT read.

module test_reg_field_set_changes_desired_without_predicting_mirror;
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
    field.set(8'hab);
    $display("UT: desired %0h mirror %0h update %0d", field.get(),
             field.get_mirrored_value(), field.needs_update());
    $finish;
  end
endmodule
