/*
:name: test_resource_pool_bare_class_declaration_rejects_an_object_receiver
:description: resource pool bare class declaration rejects an object receiver
:tags: uC uvm
:type: elaboration
:lrm: 1800.2-2020 C.2.4.1 C.2.4.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: A resource pool has no declared uvm_object ancestry
:expected_stderr_regex: (?i)^(?=.*test_resource_pool_bare_class_declaration_rejects_an_object_receiver\.sv:[0-9]+:[0-9]+:)(?=.*\b(?:assign|convert|class|type|uvm_resource_pool|uvm_object)).*error
*/
// What it checks:
// The printed bare resource-pool class is not an object-derived type.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.4.1 (UVM-RESOURCE-COLLECTION-POOL-BARE-DECLARATION) gives
// the rule above. Setup: Assign a newly constructed resource pool to a
// uvm_object receiver in one isolated illegal elaboration fixture. Expected:
// Compiler rejection matches the declared fixture/type diagnostic; no runtime
// seed executes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_bare_class_declaration_rejects_an_object_receiver;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_object wrong_view;
    pool=new(); wrong_view=pool;
  end
endmodule
