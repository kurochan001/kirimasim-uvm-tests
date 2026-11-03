/*
:name: test_uvm_scoreboard_abstract_declaration_rejects_direct_construction
:description: uvm scoreboard abstract declaration rejects direct construction
:tags: u13 uvm
:type: elaboration
:lrm: 1800.2-2020 13.6.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the declared virtual component base cannot be directly constructed
:expected_stderr_regex: (?i)(?=.*(?:virtual|abstract))(?=.*\bclass\s+[\'\"]?uvm_scoreboard\b).*
*/
module test_uvm_scoreboard_abstract_declaration_rejects_direct_construction;
  import uvm_pkg::*;
  initial begin
    automatic uvm_scoreboard illegal=new("illegal46",null);
  end
endmodule
