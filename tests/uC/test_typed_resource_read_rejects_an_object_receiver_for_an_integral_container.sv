/*
:name: test_typed_resource_read_rejects_an_object_receiver_for_an_integral_container
:description: The resource read return type is int and cannot be assigned to a class handle
:tags: uC uvm
:type: elaboration
:lrm: 1800.2-2020 C.2.5.4 C.2.5.4.1 1800-2023 6.21 8.20 8.21 8.26
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the integral resource result is not assignment compatible with a class receiver
:expected_stderr_regex: (?i)^(?=.*test_typed_resource_read_rejects_an_object_receiver_for_an_integral_container.sv:[0-9]+:[0-9]+:)(?=.*\btoken_type\b).*error
*/
// What it checks:
// An integral resource result cannot be implicitly assigned to a class-handle
// receiver.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.5.4 (UVM-RESOURCE-AUDIT-READ-TYPE-SAFETY) gives the rule
// above. Setup: A minimal illegal fixture isolates the named constructor, pure
// hook or typed read/write context. Expected: The compiler rejects the named
// declaration/type at the fixture location using the declared semantic
// diagnostic predicate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_typed_resource_read_rejects_an_object_receiver_for_an_integral_container;
  import uvm_pkg::*;
  class token_type extends uvm_object;
    function new(); super.new("token58"); endfunction
  endclass
  initial begin
    automatic uvm_resource#(int) resource=new("int58");
    token_type illegal_receiver;
    illegal_receiver=resource.read();
    $finish;
  end
endmodule
