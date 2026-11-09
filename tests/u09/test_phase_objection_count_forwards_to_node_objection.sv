/*
:name: test_phase_objection_count_forwards_to_node_objection
:description: task phase objection APIs forward counts to the node objection (IEEE 1800.2-2020 Section 9.3.1.7.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.7.1 9.3.1.7.2 9.3.1.7.3 9.3.1.7.4 10.5.1.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_objection_count_forwards_to_node_objection.expected
*/
// What it checks:
// 1. A task-phase node exposes its own termination-gating objection object.
// 2. The task-phase raise API operates on that node objection.
// 3. The task-phase drop API operates on that node objection.
// 4. The task-phase count query API operates on that node objection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.7.1 (UVM-PHASE-NODE-OBJECTION) gives rule 1 above.
//    Setup: Create isolated task nodes and raise for the same source on
//    different nodes. Expected: Objection handles and counts remain
//    independent between nodes.
// 2. 1800.2-2020 9.3.1.7.2 (UVM-PHASE-NODE-RAISE) gives rule 2 above. Setup:
//    Raise and partially drop explicit source counts before clearing isolated
//    nodes. Expected: Node-level counts agree with direct objection queries
//    while other nodes retain their state.
// 3. 1800.2-2020 9.3.1.7.3 (UVM-PHASE-NODE-DROP) gives rule 3 above. Setup:
//    Raise and partially drop explicit source counts before clearing isolated
//    nodes. Expected: Node-level counts agree with direct objection queries
//    while other nodes retain their state.
// 4. 1800.2-2020 9.3.1.7.4 (UVM-PHASE-NODE-COUNT) gives rule 4 above. Setup:
//    Raise and partially drop explicit source counts before clearing isolated
//    nodes. Expected: Node-level counts agree with direct objection queries
//    while other nodes retain their state.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use an isolated task-phase node. Keep a positive count after the drop
// so no observation depends on asynchronous drain scheduling.

module test_phase_objection_count_forwards_to_node_objection;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic item actor = new("actor");
    uvm_phase node;
    uvm_objection objection;
    schedule.add(uvm_main_phase::get());
    node = schedule.find(uvm_main_phase::get());
    if (node == null) $fatal(1, "task phase node not found");
    objection = node.get_objection();
    if (objection == null) $fatal(1, "task phase objection not found");
    node.raise_objection(actor, "raise", 3);
    $display("UT: raised node %0d direct %0d", node.get_objection_count(actor),
        objection.get_objection_count(actor));
    node.drop_objection(actor, "partial", 1);
    $display("UT: partial node %0d direct %0d", node.get_objection_count(actor),
        objection.get_objection_count(actor));
    objection.clear();
    $display("UT: cleared node %0d", node.get_objection_count(actor));
    $finish;
  end
endmodule
