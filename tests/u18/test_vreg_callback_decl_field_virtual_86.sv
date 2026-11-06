/*
:name: test_vreg_callback_decl_field_virtual_86
:description: The listed virtual field callback facade rejects direct construction
:tags: u18 uvm
:type: elaboration
:lrm: 1800.2-2020 18.10.6.1 1800-2023 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: direct construction of the standard-declared virtual callback class is illegal
:expected_stderr_regex: (?i)^(?=.*test_vreg_callback_decl_field_virtual_86\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:virtual|abstract)\b)(?=.*\buvm_vreg_field_cbs\b).*error
*/
module test_vreg_callback_decl_field_virtual_86;
  import uvm_pkg::*;
  initial begin
    uvm_vreg_field_cbs illegal_handle;
    illegal_handle=new();
  end
endmodule
