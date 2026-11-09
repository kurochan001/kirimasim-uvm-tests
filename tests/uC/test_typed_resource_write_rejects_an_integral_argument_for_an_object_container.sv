/*
:name: test_typed_resource_write_rejects_an_integral_argument_for_an_object_container
:description: The resource write argument has the declared object type and rejects an integer
:tags: uC uvm
:type: elaboration
:lrm: 1800.2-2020 C.2.5.4 C.2.5.4.2 1800-2023 6.21 8.20 8.21 8.26
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: an integer is not assignment compatible with the object container argument type
:expected_stderr_regex: (?i)^(?=.*test_typed_resource_write_rejects_an_integral_argument_for_an_object_container.sv:[0-9]+:[0-9]+:)(?=.*\buvm_object\b).*error
*/
// What it checks:
// An object resource write rejects an incompatible nonzero integral argument.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.5.4 (UVM-RESOURCE-AUDIT-WRITE-TYPE-SAFETY) gives the rule
// above. Setup: A minimal illegal fixture isolates the named constructor, pure
// hook or typed read/write context. Expected: The compiler rejects the named
// declaration/type at the fixture location using the declared semantic
// diagnostic predicate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_typed_resource_write_rejects_an_integral_argument_for_an_object_container;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource#(uvm_object) resource=new("object58");
    resource.write(58);
    $finish;
  end
endmodule
