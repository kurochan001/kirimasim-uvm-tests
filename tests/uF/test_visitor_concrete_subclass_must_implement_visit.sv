/*
:name: test_visitor_concrete_subclass_must_implement_visit
:description: visitor concrete subclass must implement visit (IEEE 1800.2-2020 Section F.5.1.2.3)
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.5.1.2.3 F.5.1.1 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_visitor_concrete_subclass_must_implement_visit\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bvisit\b).*error
*/
// What it checks:
// A concrete subtype cannot leave the declared pure virtual visit method
// unimplemented.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.1.2.3
// (UVM-NEGATIVE-VISITOR-CONCRETE-SUBCLASS-MUST-IMPLEMENT-VISIT) gives the rule
// above. Setup: Instantiate an original nonvirtual subtype with this one pure
// method missing; all other required methods have bodies. Expected:
// Compilation rejects the fixture with an error identifying the missing pure
// method; no runtime seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_visitor_concrete_subclass_must_implement_visit;
  import uvm_pkg::*;
  class incomplete_visitor extends uvm_visitor#(uvm_component);
  endclass
  initial begin
    incomplete_visitor illegal_value;
    illegal_value = new();
  end
endmodule
