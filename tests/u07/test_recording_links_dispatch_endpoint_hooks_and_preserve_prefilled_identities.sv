/*
:name: test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities
:description: link endpoints dispatch through hooks and concrete prefills retain object identities (IEEE 1800.2-2020 Section 7.3.1.3.5)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.1.3.5 7.3.1.3.1 7.3.1.3.2 7.3.1.3.3 7.3.1.3.4 7.3.1.4.1 7.3.1.4.2 7.3.1.4.3 7.3.1.4.4 7.3.2.2.2 7.3.3.2.2 7.3.4.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities.expected
*/
// What it checks:
// 1. Link left-endpoint assignment invokes its setter hook.
// 2. Link right-endpoint assignment invokes its setter hook.
// 3. Link left-endpoint retrieval invokes its getter hook and returns that
//    object.
// 4. Link right-endpoint retrieval invokes its getter hook and returns that
//    object.
// 5. Combined link set passes both supplied endpoints through their setter
//    hooks.
// 6. The concrete get_link helper creates a link initialized with the supplied
//    endpoints and name.
// 7. The concrete get_link helper creates a link initialized with the supplied
//    endpoints and name.
// 8. The concrete get_link helper creates a link initialized with the supplied
//    endpoints and name.
// 9. The link left get operation dispatches its implementation hook.
// 10. The link left set operation dispatches its implementation hook.
// 11. The link right get operation dispatches its implementation hook.
// 12. The link right set operation dispatches its implementation hook.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.3.1.3.2 (UVM-RECORDING-LINK-LEFT-SET) gives rule 1 above.
//    Setup: Assign two distinct objects together, replace the endpoints
//    individually and retrieve both. Expected: Replacement reaches the stored
//    left endpoint and left setter counts include direct and combined calls.
// 2. 1800.2-2020 7.3.1.3.4 (UVM-RECORDING-LINK-RIGHT-SET) gives rule 2 above.
//    Setup: Assign two distinct objects together, replace the endpoints
//    individually and retrieve both. Expected: Replacement reaches the stored
//    right endpoint and right setter counts include direct and combined calls.
// 3. 1800.2-2020 7.3.1.3.1 (UVM-RECORDING-LINK-LEFT-GET) gives rule 3 above.
//    Setup: Assign two distinct objects together, replace the endpoints
//    individually and retrieve both. Expected: Both observed left handles
//    match and the getter count is two.
// 4. 1800.2-2020 7.3.1.3.3 (UVM-RECORDING-LINK-RIGHT-GET) gives rule 4 above.
//    Setup: Assign two distinct objects together, replace the endpoints
//    individually and retrieve both. Expected: Both observed right handles
//    match and the getter count is two.
// 5. 1800.2-2020 7.3.1.3.5 (UVM-RECORDING-LINK-COMBINED-SET) gives rule 5
//    above. Setup: Assign two distinct objects together, replace the endpoints
//    individually and retrieve both. Expected: Both original handles are
//    returned and each setter is counted for combined plus direct assignment.
// 6. 1800.2-2020 7.3.2.2.2 (UVM-RECORDING-PARENT-CHILD-PREFILLED-LINK) gives
//    rule 6 above. Setup: Pass two distinct object handles and an explicit
//    helper name. Expected: The resulting link retains both exact handles and
//    the explicit name.
// 7. 1800.2-2020 7.3.3.2.2 (UVM-RECORDING-CAUSE-EFFECT-PREFILLED-LINK) gives
//    rule 7 above. Setup: Pass two distinct object handles and an explicit
//    helper name. Expected: The resulting link retains both exact handles and
//    the explicit name.
// 8. 1800.2-2020 7.3.4.2.2 (UVM-RECORDING-RELATED-PREFILLED-LINK) gives rule 8
//    above. Setup: Pass two distinct object handles and an explicit helper
//    name. Expected: The resulting link retains both exact handles and the
//    explicit name.
// 9. 1800.2-2020 7.3.1.4.1 (UVM-RECORDING-EXISTING-LINK-LHS-GET) gives rule 9
//    above. Setup: Use the unchanged combined/individual endpoint replacement
//    fixture. Expected: Hook counts are two and exact endpoint identities
//    follow the replacement.
// 10. 1800.2-2020 7.3.1.4.2 (UVM-RECORDING-EXISTING-LINK-LHS-SET) gives rule
//     10 above. Setup: Use the unchanged combined/individual endpoint
//     replacement fixture. Expected: Hook counts are two and exact endpoint
//     identities follow the replacement.
// 11. 1800.2-2020 7.3.1.4.3 (UVM-RECORDING-EXISTING-LINK-RHS-GET) gives rule
//     11 above. Setup: Use the unchanged combined/individual endpoint
//     replacement fixture. Expected: Hook counts are two and exact endpoint
//     identities follow the replacement.
// 12. 1800.2-2020 7.3.1.4.4 (UVM-RECORDING-EXISTING-LINK-RHS-SET) gives rule
//     12 above. Setup: Use the unchanged combined/individual endpoint
//     replacement fixture. Expected: Hook counts are two and exact endpoint
//     identities follow the replacement.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit link names avoid relying on default-name interpretation.
// A combined set invokes both hooks without prescribing their order.
module test_recording_links_dispatch_endpoint_hooks_and_preserve_prefilled_identities;
  import uvm_pkg::*;

  class endpoint extends uvm_object;
    function new(string name="endpoint"); super.new(name); endfunction
  endclass
  class hook_link extends uvm_link_base;
    uvm_object left_value;
    uvm_object right_value;
    int left_sets = 0;
    int right_sets = 0;
    int left_gets = 0;
    int right_gets = 0;
    function new(string name="hook_link"); super.new(name); endfunction
    virtual function void do_set_lhs(uvm_object lhs); left_sets++; left_value = lhs; endfunction
    virtual function void do_set_rhs(uvm_object rhs); right_sets++; right_value = rhs; endfunction
    virtual function uvm_object do_get_lhs(); left_gets++; return left_value; endfunction
    virtual function uvm_object do_get_rhs(); right_gets++; return right_value; endfunction
  endclass
  initial begin
    automatic hook_link probe = new("probe");
    automatic endpoint left_value = new("left");
    automatic endpoint right_value = new("right");
    uvm_link_base prefilled[3];
    probe.set(left_value, right_value);
    $display("UT: combined identity %0d %0d", probe.get_lhs() == left_value,
             probe.get_rhs() == right_value);
    probe.set_lhs(right_value); probe.set_rhs(left_value);
    $display("UT: replaced identity %0d %0d", probe.get_lhs() == right_value,
             probe.get_rhs() == left_value);
    $display("UT: hooks sets %0d/%0d gets %0d/%0d", probe.left_sets, probe.right_sets,
             probe.left_gets, probe.right_gets);
    prefilled[0] = uvm_parent_child_link::get_link(left_value, right_value, "parent_child");
    prefilled[1] = uvm_cause_effect_link::get_link(left_value, right_value, "cause_effect");
    prefilled[2] = uvm_related_link::get_link(left_value, right_value, "related");
    foreach (prefilled[i]) $display("UT: prefilled %0d identity %0d %0d name %s", i,
        prefilled[i].get_lhs() == left_value, prefilled[i].get_rhs() == right_value,
        prefilled[i].get_name());
    $finish;
  end

endmodule
