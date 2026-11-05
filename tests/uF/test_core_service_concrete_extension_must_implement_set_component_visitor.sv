/*
:name: test_core_service_concrete_extension_must_implement_set_component_visitor
:description: A concrete core-service extension must implement the selected pure method
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.4.1.4.9 F.4.1.1 1800-2023 6.21 8.20 8.21 13.5.2 18.13.3 18.13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers64_decl_control/core_decl_control_bodies64.svh
:should_fail_because: a concrete core-service extension omits the pure set_component_visitor
:expected_stderr_regex: (?i)^(?=.*test_core_service_concrete_extension_must_implement_set_component_visitor\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\bset_component_visitor\b).*error
*/
// Exactly one listed pure method is omitted; the extra pinned hook has a body.
// A compiler acceptance is not a runtime pass.
`define AUDIT64_OMIT_SET_COMPONENT_VISITOR
module test_core_service_concrete_extension_must_implement_set_component_visitor;
  import uvm_pkg::*;
  class incomplete_service extends uvm_coreservice_t;
    `include "core_decl_control_bodies64.svh"
  endclass
  initial begin
    incomplete_service illegal_service;
    illegal_service=new();
  end
endmodule
