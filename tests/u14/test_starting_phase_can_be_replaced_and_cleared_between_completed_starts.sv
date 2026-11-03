/*
:name: test_starting_phase_can_be_replaced_and_cleared_between_completed_starts
:description: set_starting_phase selects each reused execution context and accepts null (14.2.4.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.4.2 14.2.4.1 14.2.3.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_starting_phase_can_be_replaced_and_cleared_between_completed_starts.expected
*/
module test_starting_phase_can_be_replaced_and_cleared_between_completed_starts;
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
    automatic uvm_phase first, second;
    schedule.add(uvm_main_phase::get()); schedule.add(uvm_shutdown_phase::get());
    first = schedule.find(uvm_main_phase::get());
    second = schedule.find(uvm_shutdown_phase::get());
    if (first == null || second == null) $fatal(1, "phase setup failed");
    sequence_value.set_automatic_phase_objection(0);
    sequence_value.expected = first; sequence_value.set_starting_phase(first);
    sequence_value.start(null);
    sequence_value.expected = second; sequence_value.set_starting_phase(second);
    sequence_value.start(null);
    sequence_value.expected = null; sequence_value.set_starting_phase(null);
    sequence_value.start(null);
    $display("UT: starts %0d bodies %0d exact_contexts %0d cleared %0d", sequence_value.starts,
             sequence_value.bodies, sequence_value.phases_exact,
             sequence_value.get_starting_phase() == null);
    $finish;
  end
endmodule
