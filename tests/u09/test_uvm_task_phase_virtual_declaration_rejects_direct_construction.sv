/*
:name: test_uvm_task_phase_virtual_declaration_rejects_direct_construction
:description: uvm task phase virtual declaration rejects direct construction
:tags: u09 uvm
:type: elaboration
:lrm: 1800.2-2020 9.6.1 9.6.2.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of a standard-declared virtual phase class is illegal
:expected_stderr_regex: (?i)^(?=.*test_uvm_task_phase_virtual_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_task_phase\b).*error
*/
// What it checks:
// Direct construction of the declared virtual uvm_task_phase is illegal.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.6.1 (UVM-PHASE-CONTRACT-TASK-VIRTUAL) gives the rule above.
// Setup: A minimal negative fixture directly constructs the base; the separate
// legal extension supplies a runtime control. Expected: Compilation rejects
// the named virtual class at the fixture location.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compiler rejection only; no runtime seed or expected stdout exists.
module test_uvm_task_phase_virtual_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_task_phase illegal_handle;
    illegal_handle=new("illegal53");
  end
endmodule
