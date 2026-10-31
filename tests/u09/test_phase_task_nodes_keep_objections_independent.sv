/*
:name: test_phase_task_nodes_keep_objections_independent
:description: different task phase nodes own independent objection counts (IEEE 1800.2-2020 Section 9.3.1.7.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.7.1 9.3.1.7.2 9.3.1.7.3 9.3.1.7.4 10.5.1.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_phase_task_nodes_keep_objections_independent.expected
*/
// Create two task nodes in one isolated schedule. Raise for the same
// source object and observe each node separately without ending a phase.

module test_phase_task_nodes_keep_objections_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic item actor = new("actor");
    uvm_phase main_node;
    uvm_phase reset_node;
    uvm_objection main_objection;
    uvm_objection reset_objection;
    schedule.add(uvm_pre_reset_phase::get());
    schedule.add(uvm_main_phase::get());
    main_node = schedule.find(uvm_main_phase::get());
    reset_node = schedule.find(uvm_pre_reset_phase::get());
    if (main_node == null || reset_node == null) $fatal(1, "task phase node not found");
    main_objection = main_node.get_objection();
    reset_objection = reset_node.get_objection();
    if (main_objection == null || reset_objection == null) $fatal(1,
        "task phase objection not found");
    $display("UT: distinct_objections %0d", main_objection != reset_objection);
    main_node.raise_objection(actor, "main", 2);
    reset_node.raise_objection(actor, "reset", 1);
    $display("UT: raised main %0d reset %0d", main_node.get_objection_count(actor),
        reset_node.get_objection_count(actor));
    main_node.drop_objection(actor, "partial", 1);
    $display("UT: partial main %0d reset %0d", main_node.get_objection_count(actor),
        reset_node.get_objection_count(actor));
    main_objection.clear();
    reset_objection.clear();
    $display("UT: cleared main %0d reset %0d", main_node.get_objection_count(actor),
        reset_node.get_objection_count(actor));
    $finish;
  end
endmodule
