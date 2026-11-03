/*
:name: test_database_concrete_subclass_must_implement_do_close_db
:description: database concrete subclass must implement do close db (IEEE 1800.2-2020 Section 7.1.6.2)
:tags: u07 uvm
:type: elaboration
:lrm: 1800.2-2020 7.1.6.2 7.1.1 7.1.2 1800-2023 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete subclass must implement the selected pure virtual method
:expected_stderr_regex: (?i)^(?=.*test_database_concrete_subclass_must_implement_do_close_db\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bdo_close_db\b).*error
*/
// Isolate one forbidden condition; other interfaces have original bodies.
// Rejection must identify this fixture and the selected method or parameter.
// This is a compile-stage expectation, without a runtime binary or seed.
module test_database_concrete_subclass_must_implement_do_close_db;
  import uvm_pkg::*;
  class incomplete_database extends uvm_tr_database;
    protected virtual function bit do_open_db(); return 1; endfunction
    protected virtual function uvm_tr_stream do_open_stream(string name,string scope,
                                                           string type_name);
      return null;
    endfunction
    protected virtual function void do_establish_link(uvm_link_base link); endfunction
  endclass
  initial begin
    incomplete_database illegal_value;
    illegal_value = new();
  end
endmodule
