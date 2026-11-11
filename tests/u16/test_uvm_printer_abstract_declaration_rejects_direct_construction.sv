/*
:name: test_uvm_printer_abstract_declaration_rejects_direct_construction
:description: virtual uvm_printer rejects direct construction (16.2.1)
:tags: u16 uvm
:type: elaboration
:lrm: 1800.2-2020 16.2.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the virtual base cannot be directly constructed
:expected_stderr_regex: (?i)^(?=.*test_uvm_printer_abstract_declaration_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_printer\b).*error
*/
// What it checks:
// The declared virtual uvm_printer cannot be directly constructed.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.1 (UVM-PRINTER-AUDIT-UVM-PRINTER-DIRECT-CONSTRUCTION) gives
// the rule above. Setup: Use the original selected fixtures and explicit API
// arguments represented by the observation anchors. Expected: The compiler
// rejects direct new with the targeted virtual/abstract error and no runtime
// seed execution.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_uvm_printer_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_printer illegal_value;
    illegal_value=new();
  end
endmodule
