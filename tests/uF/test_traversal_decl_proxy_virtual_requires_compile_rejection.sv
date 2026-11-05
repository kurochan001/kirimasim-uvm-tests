/*
:name: test_traversal_decl_proxy_virtual_requires_compile_rejection
:description: The printed virtual uvm_structure_proxy base rejects direct construction.
:tags: uF uvm
:type: elaboration
:lrm: 1800.2-2020 F.5.2.1 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: Directly construct the printed virtual base without a derived wrapper.
:expected_stderr_regex: (?i)^(?=.*test_traversal_decl_proxy_virtual_requires_compile_rejection\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:pure|virtual|abstract|missing implementation)\b)(?=.*\buvm_structure_proxy\b).*error
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_proxy_virtual_requires_compile_rejection;
  import uvm_pkg::*;
  initial begin
    uvm_structure_proxy#(uvm_component) illegal_value;
    illegal_value=new();
  end
endmodule
