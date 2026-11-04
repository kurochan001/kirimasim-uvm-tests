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
module test_run_test_callback_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_run_test_callback illegal_callback;
    illegal_callback=new();
    $finish;
  end
endmodule
