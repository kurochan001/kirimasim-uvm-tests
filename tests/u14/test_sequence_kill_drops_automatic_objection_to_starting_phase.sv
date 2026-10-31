/*
:name: test_sequence_kill_drops_automatic_objection_to_starting_phase
:description: sequence termination stops active work and reports its required state and callbacks (IEEE 1800.2-2020 Section 14.2.5.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.11 14.2.4.3 14.2.4.4 14.2.4.2 9.3.1.7.4 9.3.1.6.1 9.3.1.4.4 14.2.3.1 14.2.5.12 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_kill_drops_automatic_objection_to_starting_phase.expected
*/
// Assign an isolated task-phase node and enable automatic objection.
// Observe its count inside the active body and after kill, without
// depending on asynchronous objector-list cleanup.

module test_sequence_kill_drops_automatic_objection_to_starting_phase;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class kill_probe extends uvm_sequence#(packet);
    `uvm_object_utils(kill_probe)
    bit entered = 0;
    bit late_write = 0;
    bit take_lock = 0;
    int kill_calls = 0;
    int post_body_calls = 0;
    int post_start_calls = 0;
    function new(string name="kill_probe"); super.new(name); endfunction
    task body();
      if (take_lock) lock();
      entered = 1;
      #20;
      late_write = 1;
      if (take_lock) unlock();
    endtask
    function void do_kill(); kill_calls++; endfunction
    task post_body(); post_body_calls++; endtask
    task post_start(); post_start_calls++; endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    kill_probe first;
    kill_probe second;
    bit first_returned = 0;
    bit second_returned = 0;
    uvm_phase schedule;
    uvm_phase node;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      first = new("first");
      second = new("second");
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      schedule = new("local", UVM_PHASE_SCHEDULE);
      schedule.add(uvm_main_phase::get());
      node = schedule.find(uvm_main_phase::get());
      if (node == null) $fatal(1, "phase node missing");
      first.set_starting_phase(node);
      first.set_automatic_phase_objection(1);

      fork

        begin
          first.start(sequencer);

          first_returned = 1;
        end

        begin
          wait (first.entered);
          #1;
          $display("UT: automatic_count_before %0d", node.get_objection_count(first));
          first.kill();

          #1;

          $display("UT: stopped %0d kill_calls %0d start_returned %0d",
                   first.get_sequence_state() == UVM_STOPPED, first.kill_calls, first_returned);

          $display("UT: automatic_count_after %0d", node.get_objection_count(first));

          #21;
          $display("UT: late_write %0d", first.late_write);

        end
      join
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
