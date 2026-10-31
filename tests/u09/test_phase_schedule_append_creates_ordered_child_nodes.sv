/*
:name: test_phase_schedule_append_creates_ordered_child_nodes
:description: appending phases creates child nodes in serial order (IEEE 1800.2-2020 Section 9.3.1.6.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.6.1 9.3.1.6.2 9.3.1.4.3 9.3.1.4.4 9.3.1.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_schedule_append_creates_ordered_child_nodes.expected
*/
// Build a local schedule without executing its phases. Node identity,
// parentage and ordering follow the graph created by consecutive add calls.

module test_phase_schedule_append_creates_ordered_child_nodes;
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
    schedule.add(second);
    schedule.add(third);

    first_node = schedule.find(first);
    second_node = schedule.find(second);
    third_node = schedule.find(third);
    if (first_node == null || second_node == null || third_node == null)
      $fatal(1, "scheduled node not found");

    $display("UT: parents %0d %0d %0d", first_node.get_parent() == schedule,
             second_node.get_parent() == schedule, third_node.get_parent() == schedule);
    $display("UT: ordered %0d %0d", first_node.is_before(second_node),
        second_node.is_before(third_node));
    $display("UT: named lookup %0d", schedule.find_by_name("two") == second_node);
    $finish;
  end
endmodule
