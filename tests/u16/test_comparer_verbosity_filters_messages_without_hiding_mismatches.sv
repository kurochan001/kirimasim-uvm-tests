/*
:name: test_comparer_verbosity_filters_messages_without_hiding_mismatches
:description: verbosity filtering suppresses comparer reports while retaining comparison results (IEEE 1800.2-2020 Section 16.3.5.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.3.5.2 16.3.5.1 16.3.3.9 6.3.4.2 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_comparer_verbosity_filters_messages_without_hiding_mismatches.expected
*/
// What it checks:
// Configured comparer verbosity controls reporting without hiding comparison
// failures.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.3.5.2 (UVM-COMPARER-MESSAGE-VERBOSITY) gives the rule above.
// Setup: Filter one high-verbosity mismatch, then permit a NONE-verbosity
// mismatch. Expected: Both mismatches update policy state, but only the
// enabled message reaches the report server.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A high-verbosity mismatch is filtered by the root report object. A
// second mismatch at verbosity NONE is reported within the two-message limit.

module test_comparer_verbosity_filters_messages_without_hiding_mismatches;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_comparer policy = new;
    automatic uvm_root root = uvm_root::get();
    automatic uvm_report_server server = uvm_report_server::get_server();
    int infos;
    bit result;
    root.set_report_verbosity_level(UVM_NONE);
    root.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    policy.set_show_max(2);
    policy.set_severity(UVM_INFO);
    policy.set_verbosity(UVM_HIGH);
    infos = server.get_severity_count(UVM_INFO);
    result = policy.compare_field_int("hidden", 1, 2, 32);
    $display("UT: filtered result %0d count %0d report_delta %0d", result, policy.get_result(),
             server.get_severity_count(UVM_INFO) - infos);
    policy.set_verbosity(UVM_NONE);
    result = policy.compare_field_int("visible", 3, 4, 32);
    $display("UT: visible result %0d count %0d report_delta %0d nonempty_text %0d",
        result, policy.get_result(),
             server.get_severity_count(UVM_INFO) - infos, policy.get_miscompares() != "");
    $finish;
  end
endmodule
