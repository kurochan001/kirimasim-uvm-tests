/*
:name: test_builtin_memory_walk_protected_child_rejects_external_access
:description: External code cannot read the printed protected mem_seq member
:tags: uE uvm
:type: elaboration
:lrm: 1800.2-2020 E.6.2.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: external access to the protected mem_seq member is illegal
:expected_stderr_regex: (?i)^(?=.*test_builtin_memory_walk_protected_child_rejects_external_access.sv:[0-9]+:[0-9]+:)(?=.*\b(?:protected|private|inaccessible)\b)(?=.*\bmem_seq\b).*error
*/
module test_builtin_memory_walk_protected_child_rejects_external_access;
  import uvm_pkg::*;
  initial begin
    uvm_mem_walk_seq owner;
    uvm_mem_single_walk_seq illegal_read;
    owner=new("owner60"); illegal_read=owner.mem_seq;
    $finish;
  end
endmodule
