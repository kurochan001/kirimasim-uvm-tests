/*
:name: test_automatic_objection_setting_changes_apply_to_each_completed_sequence_reuse
:description: automatic phase objection controls can select later sequence executions (14.2.4.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.4.4 14.2.4.3 14.2.4.2 14.2.3.2 14.2.3.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_automatic_objection_setting_changes_apply_to_each_completed_sequence_reuse.expected
*/
// What it checks:
// 1. Automatic phase objection selection can change between completed sequence
//    executions.
// 2. For each enabled execution, automatic objection is already raised at
//    pre_start and released after completion.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.4.4 (UVM-SEQUENCE-AUTOMATIC-OBJECTION-REUSE-CONTROL)
//    gives rule 1 above. Setup: Run enabled, disabled and enabled on a fixed
//    starting-phase node. Expected: pre_start objection counts follow
//    one/zero/one and each execution releases its objection.
// 2. 1800.2-2020 14.2.4.3 (UVM-SEQUENCE-AUTOMATIC-OBJECTION-REUSED-LIFETIME)
//    gives rule 2 above. Setup: Observe three completed executions with enable
//    states one/zero/one. Expected: Counts at pre_start are one/zero/one and
//    all post-start totals are zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_automatic_objection_setting_changes_apply_to_each_completed_sequence_reuse;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class phase_sequence extends uvm_sequence#(uvm_sequence_item);
    uvm_phase expected;
    int starts = 0;
    int bodies = 0;
    bit phases_exact = 1;
    int counts[$];
    function new(); super.new("phase_sequence"); endfunction
    task pre_start();
      uvm_phase phase_value = get_starting_phase();
      starts++; phases_exact &= phase_value == expected;
      if (phase_value != null) counts.push_back(phase_value.get_objection_count(this));
    endtask
    task body(); #1; bodies++; endtask
  endclass
  initial begin
    automatic phase_sequence sequence_value = new();
    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic uvm_phase node;
    automatic bit dropped = 1;
    schedule.add(uvm_main_phase::get()); node = schedule.find(uvm_main_phase::get());
    if (node == null) $fatal(1, "phase setup failed");
    sequence_value.expected = node;
    for (int i = 0; i < 3; i++) begin
      sequence_value.set_starting_phase(node);
      sequence_value.set_automatic_phase_objection(i != 1);
      sequence_value.start(null);
      dropped &= node.get_objection_count(sequence_value) == 0;
    end
    if (sequence_value.counts.size() != 3) $fatal(1, "missing start observations");
    $display("UT: pre_start_counts %0d %0d %0d dropped_after_each %0d",
             sequence_value.counts[0], sequence_value.counts[1], sequence_value.counts[2], dropped);
    $display("UT: starts %0d bodies %0d exact_contexts %0d", sequence_value.starts,
             sequence_value.bodies, sequence_value.phases_exact);
    $finish;
  end
endmodule
