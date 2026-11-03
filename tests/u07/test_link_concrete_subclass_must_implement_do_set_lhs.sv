/*
:name: test_link_concrete_subclass_must_implement_do_set_lhs
:description: link concrete subclass must implement do set lhs (IEEE 1800.2-2020 Section 7.3.1.4.2)
:tags: u07 uvm
:type: elaboration
:lrm: 1800.2-2020 7.3.1.4.2 7.3.1.1 7.3.1.2 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_link_concrete_subclass_must_implement_do_set_lhs\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_set_lhs\b).*error
*/
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_link_concrete_subclass_must_implement_do_set_lhs;
  import uvm_pkg::*;
  class incomplete_link extends uvm_link_base;
    uvm_object left_value,right_value;
    virtual function uvm_object do_get_lhs(); return left_value; endfunction
    virtual function uvm_object do_get_rhs(); return right_value; endfunction
    virtual function void do_set_rhs(uvm_object rhs); right_value = rhs; endfunction
  endclass
  initial begin
    incomplete_link illegal_value;
    illegal_value = new();
  end
endmodule
