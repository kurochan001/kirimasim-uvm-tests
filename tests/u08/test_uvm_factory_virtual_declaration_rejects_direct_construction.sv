/*
:name: test_uvm_factory_virtual_declaration_rejects_direct_construction
:description: uvm factory virtual declaration rejects direct construction
:tags: u08 uvm
:type: elaboration
:lrm: 1800.2-2020 8.3.1.1 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of a standard-declared virtual factory is illegal
:expected_stderr_regex: (?i)^(?=.*test_uvm_factory_virtual_declaration_rejects_direct_construction.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_factory\b).*error
*/
module test_uvm_factory_virtual_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_factory illegal_instance;
    illegal_instance=new();
    $finish;
  end
endmodule
