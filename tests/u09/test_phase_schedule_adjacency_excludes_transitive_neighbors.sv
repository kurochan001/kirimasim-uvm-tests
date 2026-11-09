/*
:name: test_phase_schedule_adjacency_excludes_transitive_neighbors
:description: adjacent node queries return direct graph neighbors rather than transitive ones (IEEE 1800.2-2020 Section 9.3.1.6.9)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.9 9.3.1.6.10 9.3.1.6.1 9.3.1.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_schedule_adjacency_excludes_transitive_neighbors.expected
*/
// What it checks:
// 1. The adjacency query returns immediate predecessor nodes rather than
//    transitive neighbors.
// 2. The adjacency query returns immediate successor nodes rather than
//    transitive neighbors.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.6.9 (UVM-PHASE-ADJACENT-PREDECESSORS) gives rule 1
//    above. Setup: Inspect the middle of a three-node serial schedule.
//    Expected: Only the immediate neighbor appears even though a longer before
//    relationship exists.
// 2. 1800.2-2020 9.3.1.6.10 (UVM-PHASE-ADJACENT-SUCCESSORS) gives rule 2
//    above. Setup: Inspect the middle of a three-node serial schedule.
//    Expected: Only the immediate neighbor appears even though a longer before
//    relationship exists.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// In a three-node serial path, the middle node has one immediate
// predecessor and successor even though the first also precedes the third.

module test_phase_schedule_adjacency_excludes_transitive_neighbors;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class step extends uvm_topdown_phase;
    function new(string name); super.new(name); endfunction
    function void exec_func(uvm_component comp, uvm_phase phase); endfunction
  endclass

  initial begin

    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic step first = new("one");
    automatic step second = new("two");
    automatic step third = new("three");
    uvm_phase first_node;
    uvm_phase second_node;
    uvm_phase third_node;

    uvm_phase predecessors[];
    uvm_phase successors[];
    automatic bit predecessor_ok = 0;
    automatic bit successor_ok = 0;
    schedule.add(first);
    schedule.add(second);
    schedule.add(third);

    first_node = schedule.find(first);
    second_node = schedule.find(second);
    third_node = schedule.find(third);
    if (first_node == null || second_node == null || third_node == null)
      $fatal(1, "scheduled node not found");

    second_node.get_adjacent_predecessor_nodes(predecessors);
    second_node.get_adjacent_successor_nodes(successors);
    if (predecessors.size() == 1) predecessor_ok = predecessors[0] == first_node;
    if (successors.size() == 1) successor_ok = successors[0] == third_node;
    $display("UT: adjacent predecessor %0d successor %0d", predecessor_ok, successor_ok);
    first_node.get_adjacent_successor_nodes(successors);
    successor_ok = 0;
    if (successors.size() == 1) successor_ok = successors[0] == second_node;
    $display("UT: first_successor_second %0d first_before_third %0d", successor_ok,
        first_node.is_before(third_node));
    $finish;
  end
endmodule
