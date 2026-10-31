/*
:name: test_phase_schedule_parallel_nodes_share_a_successor
:description: parallel phases are unordered with respect to each other and both precede their successor (IEEE 1800.2-2020 Section 9.3.1.6.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.1 9.3.1.4.6 9.3.1.4.7 9.3.1.6.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_schedule_parallel_nodes_share_a_successor.expected
*/
// A with_phase insertion shares predecessor and successor positions.
// Count predecessor membership without fixing associative iteration order.

module test_phase_schedule_parallel_nodes_share_a_successor;
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
    automatic int first_seen = 0;
    automatic int second_seen = 0;
    schedule.add(first);
    first_node = schedule.find(first);
    if (first_node == null) $fatal(1, "first node not found");
    schedule.add(second, .with_phase(first_node));
    schedule.add(third);

    first_node = schedule.find(first);
    second_node = schedule.find(second);
    third_node = schedule.find(third);
    if (first_node == null || second_node == null || third_node == null)
      $fatal(1, "scheduled node not found");

    third_node.get_adjacent_predecessor_nodes(predecessors);
    foreach (predecessors[i]) begin
      if (predecessors[i] == first_node) first_seen++;
      if (predecessors[i] == second_node) second_seen++;
    end
    $display("UT: parallel before %0d after %0d", first_node.is_before(second_node),
        first_node.is_after(second_node));
    $display("UT: successor order %0d %0d", first_node.is_before(third_node),
        second_node.is_before(third_node));
    $display("UT: predecessors %0d first %0d second %0d", predecessors.size(), first_seen,
        second_seen);
    $finish;
  end
endmodule
