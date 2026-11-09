/*
:name: test_void_virtual_base_rejects_direct_construction
:description: The declared virtual uvm_void cannot be directly constructed
:tags: u05 uvm
:type: elaboration
:lrm: 1800.2-2020 5.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the virtual uvm_void is illegal
:expected_stderr_regex: (?i)^(?=.*test_void_virtual_base_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_void\b).*error
*/
// What it checks:
// Direct construction of virtual uvm_void is illegal.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.2 (UVM-BASE-AUDIT-VOID-VIRTUAL) gives the rule above. Setup:
// One minimal illegal construction/member use is isolated with a separately
// compiled legal extension control. Expected: The declared fixture/type/member
// diagnostic predicate matches compiler rejection; no runtime seed runs, even
// if accepted.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_void_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_void illegal_value;
    illegal_value=new();
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
