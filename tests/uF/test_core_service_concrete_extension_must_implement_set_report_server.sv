/*
:name: test_core_service_concrete_extension_must_implement_set_report_server
:description: A concrete core-service extension must implement the selected pure method
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.4.1.4.5 F.4.1.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers64_decl_control/core_decl_control_bodies64.svh
:should_fail_because: a concrete core-service extension omits the pure set_report_server
:expected_stderr_regex: (?i)^(?=.*test_core_service_concrete_extension_must_implement_set_report_server\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bset_report_server\b).*error
*/
// What it checks:
// A concrete core-service extension must implement the pure set_report_server
// method.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.4.1.4.5 (UVM-CORE-DECL-AUDIT-SET-REPORT-SERVER-PURE) gives the
// rule above. Setup: An original extension implements the other twenty-five
// printed pure methods and the pinned release extra phase-hopper hook,
// omitting only this selected printed method. Expected: Compilation rejects
// the concrete extension and identifies this input and set_report_server; no
// runtime binary is executed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Exactly one listed pure method is omitted; the extra pinned hook has a body.
// A compiler acceptance is not a runtime pass.
`define AUDIT64_OMIT_SET_REPORT_SERVER
module test_core_service_concrete_extension_must_implement_set_report_server;
  import uvm_pkg::*;
  class incomplete_service extends uvm_coreservice_t;
    `include "core_decl_control_bodies64.svh"
  endclass
  initial begin
    incomplete_service illegal_service;
    illegal_service=new();
  end
endmodule
