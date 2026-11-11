/*
:name: test_policy_clear_absent_extension_is_silent
:description: clearing an absent extension does not produce reports (IEEE 1800.2-2020 Section 16.1.2.3.4)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.1.2.3.4 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_policy_clear_absent_extension_is_silent.expected
*/
// What it checks:
// Clearing one extension removes that type and silently ignores an absent
// type.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.1.2.3.4 (UVM-POLICY-EXTENSION-CLEAR-ONE) gives the rule
// above. Setup: Remove one of two installed types and repeatedly clear an
// absent slot. Expected: The selected type disappears, the other handle
// remains and absent clears emit no report.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Resolve the wrapper before sampling report counts. Repeated deletion
// of that absent slot is ignored without emitting any report severity.

module test_policy_clear_absent_extension_is_silent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class limit_ext extends uvm_object;
    `uvm_object_utils(limit_ext)
    int threshold = 0;
    function new(string name="limit_ext"); super.new(name); endfunction
  endclass
  class derived_limit_ext extends limit_ext;
    `uvm_object_utils(derived_limit_ext)
    function new(string name="derived_limit_ext"); super.new(name); endfunction
  endclass
  class flag_ext extends uvm_object;
    `uvm_object_utils(flag_ext)
    bit enabled = 1;
    function new(string name="flag_ext"); super.new(name); endfunction
  endclass

  function automatic int severity_total(uvm_report_server server);
    return server.get_severity_count(UVM_INFO) + server.get_severity_count(UVM_WARNING) +
           server.get_severity_count(UVM_ERROR) + server.get_severity_count(UVM_FATAL);
  endfunction
  initial begin
    automatic uvm_comparer policy = new;
    automatic uvm_object_wrapper absent_type = flag_ext::get_type();
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int before_count = severity_total(server);
    policy.clear_extension(absent_type);
    policy.clear_extension(absent_type);
    $display("UT: absent %0d report_delta %0d", !policy.extension_exists(absent_type),
             severity_total(server) - before_count);
    $finish;
  end
endmodule
