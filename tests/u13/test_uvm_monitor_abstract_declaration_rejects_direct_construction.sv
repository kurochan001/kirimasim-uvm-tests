/*
:name: test_uvm_monitor_abstract_declaration_rejects_direct_construction
:description: uvm monitor abstract declaration rejects direct construction
:tags: u13 uvm
:type: elaboration
:lrm: 1800.2-2020 13.5.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declared virtual component base cannot be directly constructed
:expected_stderr_regex: (?i)(?=.*(?:virtual|abstract))(?=.*\bclass\s+[\'\"]?uvm_monitor\b).*
*/
module test_uvm_monitor_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    automatic uvm_monitor illegal=new("illegal46",null);
  end
endmodule
