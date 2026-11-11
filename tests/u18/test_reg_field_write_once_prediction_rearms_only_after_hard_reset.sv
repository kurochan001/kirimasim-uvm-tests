/*
:name: test_reg_field_write_once_prediction_rearms_only_after_hard_reset
:description: write-once prediction permits a new write after hard reset but not soft reset (IEEE 1800.2-2020 Section 18.5.5.17)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.5.5.17 18.5.4.6 18.5.5.4 18.5.5.7 18.5.5.1 18.5.5.3 18.5.3.2 18.4.2.2 17.2.2.8 18.1.2.1 18.1.2.2 18.4.2.1 18.6.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reg_field_write_once_prediction_rearms_only_after_hard_reset.expected
*/
// What it checks:
// Write-once prediction accepts only the first write after HARD reset.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.5.5.17 (UVM-FIELD-WRITE-ONCE-HARD-REARM) gives the rule
// above. Setup: Write 11/22, reset SOFT to 07 and write 33, then reset HARD
// and write 44 hex. Expected: State is 11 after two writes, 07 after SOFT plus
// ignored write, and 44 after HARD plus write.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The second write is ignored. A SOFT reset restores its value but leaves
// write-once protection active; HARD reset re-enables the next write.

module test_reg_field_write_once_prediction_rearms_only_after_hard_reset;
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
    field.configure(rg, 8, 0, "W1", 0, 8'h35, 1, 0, 1);
    field.set_reset(8'h07, "SOFT");
    field.reset();
    accepted = field.predict(8'h11, -1, UVM_PREDICT_WRITE);
    accepted = field.predict(8'h22, -1, UVM_PREDICT_WRITE) && accepted;
    $display("UT: writes accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());
    field.reset("SOFT");
    accepted = field.predict(8'h33, -1, UVM_PREDICT_WRITE);
    $display("UT: soft accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());
    field.reset();
    accepted = field.predict(8'h44, -1, UVM_PREDICT_WRITE);
    $display("UT: hard accepted %0d desired %0h mirror %0h", accepted,
             field.get(), field.get_mirrored_value());
    $finish;
  end
endmodule
