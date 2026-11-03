/*
:name: test_uvm_link_base_abstract_declaration_rejects_direct_construction
:description: uvm link base abstract declaration rejects direct construction
:tags: u07 uvm
:type: elaboration
:lrm: 1800.2-2020 7.3.1.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a declared virtual recording base cannot be directly constructed
:expected_stderr_regex: (?i)(?=.*(?:virtual|abstract))(?=.*\bclass\s+[\'\"]?uvm_link_base\b).*
*/
module test_uvm_link_base_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    automatic uvm_link_base illegal=new("illegal48");
  end
endmodule
