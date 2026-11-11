/*
:name: test_sequence_parent_reassignment_updates_calculated_depth_root_and_path
:description: parent changes update automatic sequence hierarchy queries after earlier observations (14.1.2.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.8 14.1.2.7 14.1.2.9 14.1.2.12 14.1.2.13 14.1.2.14 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_parent_reassignment_updates_calculated_depth_root_and_path.expected
*/
// What it checks:
// 1. An inactive sequence can replace and clear its parent reference.
// 2. get_parent_sequence returns the current parent after replacement or
//    clearing.
// 3. Without an explicit set_depth, depth follows the current recursive parent
//    chain after reparenting.
// 4. The root-sequence reference follows the currently selected parent chain.
// 5. The root-sequence name reflects the replacement root.
// 6. The dotted sequence path reflects the replacement parent chain.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.2.8 (UVM-SEQUENCE-PARENT-REASSIGNMENT) gives rule 1
//    above. Setup: Move leaf from middle under first to second, then detach
//    it. Expected: The changed parent is the exact second handle and the
//    detached parent is null.
// 2. 1800.2-2020 14.1.2.7 (UVM-SEQUENCE-PARENT-QUERY-AFTER-REASSIGNMENT) gives
//    rule 2 above. Setup: Query after each parent change. Expected: The getter
//    returns second and then null.
// 3. 1800.2-2020 14.1.2.9 (UVM-SEQUENCE-AUTOMATIC-DEPTH-AFTER-REPARENT) gives
//    rule 3 above. Setup: Observe a depth-three leaf, replace its parent with
//    a root and then clear that parent. Expected: Depth changes from three to
//    two to one.
// 4. 1800.2-2020 14.1.2.13 (UVM-SEQUENCE-ROOT-REFERENCE-AFTER-REPARENT) gives
//    rule 4 above. Setup: Query the original chain and then replace its parent
//    root. Expected: The root changes from exact first to exact second.
// 5. 1800.2-2020 14.1.2.12 (UVM-SEQUENCE-ROOT-NAME-AFTER-REPARENT) gives rule
//    5 above. Setup: Move the leaf below second. Expected: The root name is
//    second.
// 6. 1800.2-2020 14.1.2.14 (UVM-SEQUENCE-PATH-AFTER-REPARENT) gives rule 6
//    above. Setup: Observe first.middle.leaf and then move leaf under second.
//    Expected: The path changes to second.leaf.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned get_depth cache survives parent replacement and clearing.
// With no explicit set_depth, retain the current-chain depth requirement.
module test_sequence_parent_reassignment_updates_calculated_depth_root_and_path;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name); super.new(name); endfunction
    task body(); endtask
  endclass
  // Without a set_depth override, the current parent chain defines depth.
  initial begin
    automatic empty_sequence first = new("first");
    automatic empty_sequence middle = new("middle");
    automatic empty_sequence second = new("second");
    automatic empty_sequence leaf = new("leaf");
    middle.set_parent_sequence(first); leaf.set_parent_sequence(middle);
    $display("UT: initial depth %0d root %0d path %s", leaf.get_depth(),
             leaf.get_root_sequence() == first, leaf.get_sequence_path());
    leaf.set_parent_sequence(second);
    $display("UT: changed depth %0d parent %0d root %0d root_name %s path %s",
             leaf.get_depth(), leaf.get_parent_sequence() == second,
             leaf.get_root_sequence() == second, leaf.get_root_sequence_name(),
             leaf.get_sequence_path());
    leaf.set_parent_sequence(null);
    $display("UT: detached depth %0d parent_null %0d", leaf.get_depth(),
             leaf.get_parent_sequence() == null);
    $finish;
  end
endmodule
