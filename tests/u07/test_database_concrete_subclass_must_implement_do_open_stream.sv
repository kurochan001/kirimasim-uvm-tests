/*
:name: test_database_concrete_subclass_must_implement_do_open_stream
:description: database concrete subclass must implement do open stream (IEEE 1800.2-2020 Section 7.1.6.3)
:tags: u07 uvm
:type: elaboration
:lrm: 1800.2-2020 7.1.6.3 7.1.1 7.1.2 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_database_concrete_subclass_must_implement_do_open_stream\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_open_stream\b).*error
*/
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_database_concrete_subclass_must_implement_do_open_stream;
  import uvm_pkg::*;
  class incomplete_database extends uvm_tr_database;
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function bit do_close_db(); return 1; endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  initial begin
    incomplete_database illegal_value;
    illegal_value = new();
  end
endmodule
