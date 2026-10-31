/*
:name: test_sequence_automatic_objection_raises_and_drops_starting_phase_objection
:description: automatic phase objection setting controls counts throughout sequence execution (IEEE 1800.2-2020 Section 14.2.4.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.4.3 14.2.4.4 14.2.4.1 14.2.4.2 14.2.3.1 14.2.3.2 14.2.3.6 14.2.3.9 9.3.1.7.4 9.3.1.6.1 9.3.1.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_automatic_objection_raises_and_drops_starting_phase_objection.expected
*/
// Use an isolated task-phase node as the starting phase. Observe own
// counts inside pre_start, body and post_start, then after start returns.
// No phase engine or asynchronous objector-list assertion is involved.

module test_sequence_automatic_objection_raises_and_drops_starting_phase_objection;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class probe_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(probe_sequence)
    function new(string name="probe_sequence"); super.new(name); endfunction
    task pre_start();
      uvm_phase phase = get_starting_phase();
      $display("UT: pre_start count %0d", phase.get_objection_count(this));
    endtask
    task body();
      uvm_phase phase = get_starting_phase();
      #1;
      $display("UT: body count %0d", phase.get_objection_count(this));
    endtask
    task post_start();
      uvm_phase phase = get_starting_phase();
      $display("UT: post_start count %0d", phase.get_objection_count(this));
    endtask
  endclass
  initial begin
    automatic uvm_phase schedule = new("local", UVM_PHASE_SCHEDULE);
    automatic uvm_phase node;
    automatic probe_sequence sequence_value = new("sequence_value");
    schedule.add(uvm_main_phase::get());
    node = schedule.find(uvm_main_phase::get());
    if (node == null) $fatal(1, "phase node missing");
    sequence_value.set_starting_phase(node);
    sequence_value.set_automatic_phase_objection(1);

    sequence_value.start(null);
    $display("UT: after_start count %0d", node.get_objection_count(sequence_value));
    $finish;
  end
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
