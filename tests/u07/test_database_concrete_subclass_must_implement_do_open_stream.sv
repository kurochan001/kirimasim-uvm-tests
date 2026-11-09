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
// What it checks:
// A concrete subtype cannot leave the declared pure virtual do_open_stream
// method unimplemented.
//
// How the expected output follows from the standard:
// 1800.2-2020 7.1.6.3
// (UVM-NEGATIVE-DATABASE-CONCRETE-SUBCLASS-MUST-IMPLEMENT-DO-OPEN-STREAM)
// gives the rule above. Setup: Instantiate an original nonvirtual subtype with
// this one pure method missing; all other required methods have bodies.
// Expected: Compilation rejects the fixture with an error identifying the
// missing pure method; no runtime seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
