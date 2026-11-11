/*
:name: test_reg_reset_reassembles_each_fields_configured_reset_value
:description: register reset restores field values and their assembled register value (IEEE 1800.2-2020 Section 18.4.4.5)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.4.4.5 18.4.4.6 18.4.4.15 18.4.4.1 18.4.4.3 18.5.3.2 18.1.2.1 18.1.2.2 18.4.2.1 18.4.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_reset_reassembles_each_fields_configured_reset_value.expected
*/
// What it checks:
// Register reset restores each field and the assembled values.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.4.4.5 (UVM-REG-RESET-ASSEMBLED-FIELD-VALUES) gives the rule
// above. Setup: Predict ffff into a register whose field resets assemble to
// 1234 hex. Expected: Reset metadata, desired and mirror all equal 1234 hex
// after reset.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Reset is checked after a successful prediction dirties both stored fields.

module test_reg_reset_reassembles_each_fields_configured_reset_value;
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
    accepted = rg.predict(16'hffff);
    rg.reset();
    $display("UT: predicted %0d reset_value %0h desired %0h mirror %0h",
             accepted, rg.get_reset(), rg.get(), rg.get_mirrored_value());
    $finish;
  end
endmodule
