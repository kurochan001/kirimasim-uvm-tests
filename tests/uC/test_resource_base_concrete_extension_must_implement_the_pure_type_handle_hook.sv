/*
:name: test_resource_base_concrete_extension_must_implement_the_pure_type_handle_hook
:description: A concrete resource-base extension cannot leave get_type_handle unimplemented
:tags: uC uvm
:type: elaboration
:lrm: 1800.2-2020 C.2.3.2.2 C.2.3.1 1800-2023 6.21 8.20 8.21 8.26
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a concrete extension must implement the standard pure virtual get_type_handle
:expected_stderr_regex: (?i)^(?=.*test_resource_base_concrete_extension_must_implement_the_pure_type_handle_hook.sv:[0-9]+:[0-9]+:)(?=.*\bget_type_handle\b).*error
*/
// What it checks:
// A concrete extension must implement the pure get_type_handle hook.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.3.2.2 (UVM-RESOURCE-AUDIT-PURE-TYPE-HOOK) gives the rule
// above. Setup: A minimal illegal fixture isolates the named constructor, pure
// hook or typed read/write context. Expected: The compiler rejects the named
// declaration/type at the fixture location using the declared semantic
// diagnostic predicate.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Extra original compatibility bodies isolate the standard get_type_handle
// obligation. They do not pass the separate unqualified base-extension case.
module test_resource_base_concrete_extension_must_implement_the_pure_type_handle_hook;
  import uvm_pkg::*;
  class incomplete_resource extends uvm_resource_base;
    function new(); super.new("incomplete58"); endfunction
    virtual function string m_value_type_name(); return "original58"; endfunction
    virtual function string m_value_as_string(); return "original58"; endfunction
    virtual function void set_priority(uvm_resource_types::priority_e pri); endfunction
  endclass
  initial begin
    incomplete_resource illegal_resource;
    illegal_resource=new();
    $finish;
  end
endmodule
