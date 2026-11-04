/*
:name: test_object_virtual_base_rejects_direct_construction
:description: The declared virtual uvm_object cannot be directly constructed
:tags: u05 uvm
:type: elaboration
:lrm: 1800.2-2020 5.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the virtual uvm_object is illegal
:expected_stderr_regex: (?i)^(?=.*test_object_virtual_base_rejects_direct_construction\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_object\b).*error
*/
module test_object_virtual_base_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    uvm_object illegal_value;
    illegal_value=new();
    $finish;
  end
  initial begin #100; $fatal(1,"base-class fixture watchdog expired"); end
endmodule
