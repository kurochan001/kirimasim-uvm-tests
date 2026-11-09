/*
:name: test_link_concrete_subclass_must_implement_do_set_rhs
:description: link concrete subclass must implement do set rhs (IEEE 1800.2-2020 Section 7.3.1.4.4)
:tags: u07 uvm
:type: elaboration
:lrm: 1800.2-2020 7.3.1.4.4 7.3.1.1 7.3.1.2 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_link_concrete_subclass_must_implement_do_set_rhs\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_set_rhs\b).*error
*/
// What it checks:
// A concrete subtype cannot leave the declared pure virtual do_set_rhs method
// unimplemented.
//
// How the expected output follows from the standard:
// 1800.2-2020 7.3.1.4.4
// (UVM-NEGATIVE-LINK-CONCRETE-SUBCLASS-MUST-IMPLEMENT-DO-SET-RHS) gives the
// rule above. Setup: Instantiate an original nonvirtual subtype with this one
// pure method missing; all other required methods have bodies. Expected:
// Compilation rejects the fixture with an error identifying the missing pure
// method; no runtime seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_link_concrete_subclass_must_implement_do_set_rhs;
  import uvm_pkg::*;
  class incomplete_link extends uvm_link_base;
    uvm_object left_value,right_value;
    virtual function uvm_object do_get_lhs(); return left_value; endfunction
    virtual function void do_set_lhs(uvm_object lhs); left_value = lhs; endfunction
    virtual function uvm_object do_get_rhs(); return right_value; endfunction
  endclass
  initial begin
    incomplete_link illegal_value;
    illegal_value = new();
  end
endmodule
