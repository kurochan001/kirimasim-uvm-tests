/*
:name: test_report_catcher_concrete_subclass_must_implement_catch
:description: report catcher concrete subclass must implement catch (IEEE 1800.2-2020 Section 6.6.5)
:tags: u06 uvm
:type: elaboration
:lrm: 1800.2-2020 6.6.5 6.6.1 6.6.2 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_report_catcher_concrete_subclass_must_implement_catch\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bcatch\b).*error
*/
// What it checks:
// A concrete subtype cannot leave the declared pure virtual catch method
// unimplemented.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.6.5
// (UVM-NEGATIVE-REPORT-CATCHER-CONCRETE-SUBCLASS-MUST-IMPLEMENT-CATCH) gives
// the rule above. Setup: Instantiate an original nonvirtual subtype with this
// one pure method missing; all other required methods have bodies. Expected:
// Compilation rejects the fixture with an error identifying the missing pure
// method; no runtime seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_report_catcher_concrete_subclass_must_implement_catch;
  import uvm_pkg::*;
  class incomplete_catcher extends uvm_report_catcher;
  endclass
  initial begin
    incomplete_catcher illegal_value;
    illegal_value = new();
  end
endmodule
