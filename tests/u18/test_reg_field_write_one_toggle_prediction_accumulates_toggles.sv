/*
:name: test_reg_field_write_one_toggle_prediction_accumulates_toggles
:description: W1T write prediction applies the access rule to both model values (IEEE 1800.2-2020 Section 18.5.5.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.17 18.5.4.6 18.5.5.1 18.5.5.3 18.5.5.4 18.5.3.2 18.4.2.2 17.2.2.8 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_write_one_toggle_prediction_accumulates_toggles.expected
*/
// What it checks:
// W1T write prediction toggles selected one bits in the current state.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.17 (UVM-FIELD-W1T-PREDICTION-ACCUMULATION) gives the rule
// above. Setup: Starting a5, predict writes 0f and 30 hex. Expected:
// Desired/mirror become aa then 9a hex.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Selected one bits toggle the state produced by the preceding prediction.
// The input represents an observation, not a physical bus operation.

module test_reg_field_write_one_toggle_prediction_accumulates_toggles;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class model_block extends uvm_reg_block;
    function new(string name="blk"); super.new(name, UVM_NO_COVERAGE); endfunction
  endclass
  class model_reg extends uvm_reg;
    function new(string name="r", int unsigned width=8);
      super.new(name, width, UVM_NO_COVERAGE);
    endfunction
  endclass
  class model_mem extends uvm_mem;
    function new(string name="mem", longint unsigned size=4,
                 int unsigned width=16, string access="RW");
      super.new(name, size, width, access, UVM_NO_COVERAGE);
    endfunction
  endclass

  initial begin
    automatic model_block blk = new("blk");
    automatic model_reg rg = new("r", 8);
    automatic uvm_reg_field field = new("f");
    automatic bit accepted = 0;

    blk.configure();
    rg.configure(blk);
    field.configure(rg, 8, 0, "W1T", 0, 8'ha5, 1, 0, 1);
    field.reset();
    accepted = field.predict(8'h0f, -1, UVM_PREDICT_WRITE);
    $display("UT: step 1 accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());
    accepted = field.predict(8'h30, -1, UVM_PREDICT_WRITE);
    $display("UT: step 2 accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());

    $finish;
  end
endmodule
