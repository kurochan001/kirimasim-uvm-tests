/*
:name: test_phase_schedule_insert_between_existing_nodes
:description: after and before constraints insert a phase between existing nodes (IEEE 1800.2-2020 Section 9.3.1.6.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.1 9.3.1.4.4 9.3.1.4.6 9.3.1.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_schedule_insert_between_existing_nodes.expected
*/
// What it checks:
// Schedule add places a phase between existing after/before neighbors.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.3.1.6.1 (UVM-PHASE-SCHEDULE-INSERT) gives the rule above.
// Setup: Build an isolated schedule graph without executing its phase
// implementations. Expected: The inserted node lies after its predecessor and
// before its successor.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The explicit neighbors are already schedule nodes. Inserting a new
// implementation between them changes the graph order without executing it.

module test_phase_schedule_insert_between_existing_nodes;
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

    schedule.add(first);
    schedule.add(third);
    first_node = schedule.find(first);
    third_node = schedule.find(third);
    if (first_node == null || third_node == null) $fatal(1, "neighbors not found");
    schedule.add(second, .after_phase(first_node), .before_phase(third_node));

    first_node = schedule.find(first);
    second_node = schedule.find(second);
    third_node = schedule.find(third);
    if (first_node == null || second_node == null || third_node == null)
      $fatal(1, "scheduled node not found");

    $display("UT: before_second %0d after_first %0d before_third %0d",
        first_node.is_before(second_node),
             second_node.is_after(first_node), second_node.is_before(third_node));
    $display("UT: reverse_before %0d", third_node.is_before(second_node));
    $finish;
  end
endmodule
