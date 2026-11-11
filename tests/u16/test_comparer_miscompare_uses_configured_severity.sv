/*
:name: test_comparer_miscompare_uses_configured_severity
:description: a scalar miscompare report uses the selected comparer severity (IEEE 1800.2-2020 Section 16.3.5.3)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.3 16.3.5.1 16.3.3.2 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_miscompare_uses_configured_severity.expected
*/
// What it checks:
// Comparer-generated mismatch messages use its configured severity.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.5.3 (UVM-COMPARER-MESSAGE-SEVERITY) gives the rule above.
// Setup: Allow a mismatch message at verbosity NONE and set severity WARNING.
// Expected: A mismatch produces one WARNING delta and no INFO delta in this
// controlled fixture.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Allow one miscompare message at verbosity NONE. Count server severity
// deltas while observing the boolean result and the policy mismatch count.

module test_comparer_miscompare_uses_configured_severity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer policy = new;
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int warnings;
    int infos;
    bit result;
    root.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    root.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    policy.set_show_max(1);
    policy.set_verbosity(UVM_NONE);
    policy.set_severity(UVM_WARNING);
    warnings = server.get_severity_count(UVM_WARNING);
    infos = server.get_severity_count(UVM_INFO);
    result = policy.compare_field_int("value", 1, 2, 32);
    $display("UT: result %0d mismatches %0d warning_delta %0d info_delta %0d", result,
        policy.get_result(),
             server.get_severity_count(UVM_WARNING) - warnings,
                 server.get_severity_count(UVM_INFO) - infos);
    $finish;
  end
endmodule
