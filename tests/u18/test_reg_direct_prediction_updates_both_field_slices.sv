/*
:name: test_reg_direct_prediction_updates_both_field_slices
:description: register prediction updates desired and mirrored state in both fields (IEEE 1800.2-2020 Section 18.4.4.15)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.15 18.4.4.1 18.4.4.3 18.5.5.1 18.5.5.3 18.5.3.2 18.4.4.5 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_direct_prediction_updates_both_field_slices.expected
*/
// What it checks:
// Register direct prediction updates each field and assembled desired/mirror
// values.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.4.15 (UVM-REG-PREDICT-MULTIFIELD-SLICES) gives the rule
// above. Setup: Predict b67a hex into two adjacent eight-bit RW fields.
// Expected: Prediction succeeds; low/high are 7a/b6 and both aggregate values
// are b67a.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use explicit values; no hardware read or automatically assigned ID is
// observed.

module test_reg_direct_prediction_updates_both_field_slices;
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
    automatic bit accepted = 0;

    blk.configure();
    rg.configure(blk);
    high.configure(rg, 8, 8, "RW", 0, 8'h12, 1, 0, 1);
    low.configure(rg, 8, 0, "RW", 0, 8'h34, 1, 0, 1);
    rg.reset();
    accepted = rg.predict(16'hb67a);
    $display("UT: accepted %0d desired %0h mirror %0h low %0h high %0h",
             accepted, rg.get(), rg.get_mirrored_value(), low.get_mirrored_value(),
             high.get_mirrored_value());
    $finish;
  end
endmodule
