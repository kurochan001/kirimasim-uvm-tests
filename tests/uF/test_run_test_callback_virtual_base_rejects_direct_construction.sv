/*
:name: test_run_test_callback_virtual_base_rejects_direct_construction
:description: Direct construction of the virtual run-test callback base is illegal
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the standard virtual run-test callback base is illegal
:expected_stderr_regex: (?i)^(?=.*test_run_test_callback_virtual_base_rejects_direct_construction.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_run_test_callback\b).*error
*/
// What it checks:
// Direct construction of the virtual run-test callback base is illegal.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.6.1 (UVM-PACKAGE-AUDIT-CALLBACK-VIRTUAL-BASE) gives the rule
// above. Setup: A minimal illegal design directly constructs
// uvm_run_test_callback. Expected: The compiler rejects the named virtual
// class at the fixture location.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_run_test_callback_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_run_test_callback illegal_callback;
    illegal_callback=new();
    $finish;
  end
endmodule
