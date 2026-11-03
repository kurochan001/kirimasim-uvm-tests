/*
:name: test_subscriber_concrete_subclass_must_implement_write
:description: subscriber concrete subclass must implement write (IEEE 1800.2-2020 Section 13.9.3.2)
:tags: u13 uvm
:type: elaboration
:lrm: 1800.2-2020 13.9.3.2 13.9.1 13.9.3.1 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_subscriber_concrete_subclass_must_implement_write\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bwrite\b).*error
*/
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_subscriber_concrete_subclass_must_implement_write;
  import uvm_pkg::*;
  class incomplete_subscriber extends uvm_subscriber#(int);
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
  endclass
  initial begin
    incomplete_subscriber illegal_value;
    illegal_value = new("illegal",null);
  end
endmodule
