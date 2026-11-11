/*
:name: test_reg_needs_update_clears_after_prediction_or_restored_desired_value
:description: register update need follows desired versus mirror state (IEEE 1800.2-2020 Section 18.4.4.4)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.4 18.4.4.2 18.4.4.15 18.5.3.2 18.4.4.5 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_needs_update_clears_after_prediction_or_restored_desired_value.expected
*/
// What it checks:
// Register needs_update reflects a changed field and clears after
// reconciliation.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.4.4 (UVM-REG-UPDATE-NEED-FIELD-AGGREGATION) gives the rule
// above. Setup: Change low, predict the aggregate, change high and restore
// high desired. Expected: The update flag follows one/zero/one/zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// One changed field must dirty the whole register. Prediction and restoring
// the desired value are checked as separate ways to remove the difference.

module test_reg_needs_update_clears_after_prediction_or_restored_desired_value;
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
    low.set(8'h56);
    $display("UT: changed update %0d", rg.needs_update());
    accepted = rg.predict(16'h1256);
    $display("UT: predicted %0d update %0d", accepted, rg.needs_update());
    high.set(8'h77);
    $display("UT: second_change update %0d", rg.needs_update());
    high.set(8'h12);
    $display("UT: restored update %0d", rg.needs_update());
    $finish;
  end
endmodule
