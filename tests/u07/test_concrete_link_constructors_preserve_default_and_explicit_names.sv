/*
:name: test_concrete_link_constructors_preserve_default_and_explicit_names
:description: all three concrete link constructors preserve their own defaults and explicit names (7.3.2.2.1)
:tags: u07 uvm
:type: simulation
:lrm: 1800.2-2020 7.3.2.2.1 7.3.3.2.1 7.3.4.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_concrete_link_constructors_preserve_default_and_explicit_names.expected
*/
// What it checks:
// 1. The parent/child link constructor uses its specified default name when
//    the name argument is omitted.
// 2. The parent/child link constructor preserves an explicitly supplied
//    instance name.
// 3. The cause/effect link constructor uses its specified default name when
//    the name argument is omitted.
// 4. The cause/effect link constructor preserves an explicitly supplied
//    instance name.
// 5. The related link constructor uses its specified default name when the
//    name argument is omitted.
// 6. The related link constructor preserves an explicitly supplied instance
//    name.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 7.3.2.2.1 (UVM-PARENT-CHILD-LINK-CONSTRUCTOR-DEFAULT-NAME)
//    gives rule 1 above. Setup: Independent instances are constructed with
//    omitted and explicit name arguments. Expected: The omitted-name instance
//    has the name unnamed-uvm_parent_child_link.
// 2. 1800.2-2020 7.3.2.2.1 (UVM-PARENT-CHILD-LINK-CONSTRUCTOR-EXPLICIT-NAME)
//    gives rule 2 above. Setup: Independent instances are constructed with
//    omitted and explicit name arguments. Expected: The explicit name remains
//    named_pc.
// 3. 1800.2-2020 7.3.3.2.1 (UVM-CAUSE-EFFECT-LINK-CONSTRUCTOR-DEFAULT-NAME)
//    gives rule 3 above. Setup: Independent instances are constructed with
//    omitted and explicit name arguments. Expected: The omitted-name instance
//    has the name unnamed-uvm_cause_effect_link.
// 4. 1800.2-2020 7.3.3.2.1 (UVM-CAUSE-EFFECT-LINK-CONSTRUCTOR-EXPLICIT-NAME)
//    gives rule 4 above. Setup: Independent instances are constructed with
//    omitted and explicit name arguments. Expected: The explicit name remains
//    named_ce.
// 5. 1800.2-2020 7.3.4.2.1 (UVM-RELATED-LINK-CONSTRUCTOR-DEFAULT-NAME) gives
//    rule 5 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The omitted-name instance has the
//    name unnamed-uvm_related_link.
// 6. 1800.2-2020 7.3.4.2.1 (UVM-RELATED-LINK-CONSTRUCTOR-EXPLICIT-NAME) gives
//    rule 6 above. Setup: Independent instances are constructed with omitted
//    and explicit name arguments. Expected: The explicit name remains
//    named_related.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_concrete_link_constructors_preserve_default_and_explicit_names;
  import uvm_pkg::*;
  initial begin
    automatic uvm_parent_child_link pc = new();
    automatic uvm_cause_effect_link ce = new();
    automatic uvm_related_link related = new();
    automatic uvm_parent_child_link named_pc = new("named_pc");
    automatic uvm_cause_effect_link named_ce = new("named_ce");
    automatic uvm_related_link named_related = new("named_related");
    $display("UT: defaults %s %s %s", pc.get_name(), ce.get_name(), related.get_name());
    $display("UT: explicit %s %s %s", named_pc.get_name(), named_ce.get_name(),
             named_related.get_name());
    $display("UT: distinct %0d %0d %0d", pc != named_pc, ce != named_ce,
             related != named_related);
    $finish;
  end
endmodule
