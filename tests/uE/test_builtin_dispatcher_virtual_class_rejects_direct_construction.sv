/*
:name: test_builtin_dispatcher_virtual_class_rejects_direct_construction
:description: The printed virtual builtin dispatcher cannot be directly constructed
:tags: uE uvm
:type: elaboration
:lrm: 1800.2-2020 E.8.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the virtual builtin dispatcher is illegal
:expected_stderr_regex: (?i)^(?=.*test_builtin_dispatcher_virtual_class_rejects_direct_construction.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_reg_mem_built_in_seq\b).*error
*/
// What it checks:
// Direct construction of the printed virtual builtin dispatcher is illegal.
//
// How the expected output follows from the standard:
// 1800.2-2020 E.8.1 (UVM-BUILTIN-AUDIT-DISPATCHER-VIRTUAL) gives the rule
// above. Setup: One minimal illegal declaration or external member access is
// isolated; a separate original legal extension is the control. Expected:
// Compilation rejects the named fixture/type/member using the declared
// semantic diagnostic predicate; no runtime seed is executed, including
// illegal acceptance.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_builtin_dispatcher_virtual_class_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_reg_mem_built_in_seq illegal_value;
    illegal_value=new();
    $finish;
  end
endmodule
