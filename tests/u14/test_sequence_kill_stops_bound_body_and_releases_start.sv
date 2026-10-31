/*
:name: test_sequence_kill_stops_bound_body_and_releases_start
:description: sequence termination stops active work and reports its required state and callbacks (IEEE 1800.2-2020 Section 14.2.5.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.11 14.2.5.12 14.2.3.1 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_kill_stops_bound_body_and_releases_start.expected
*/
// Kill after the body has entered, then allow a positive settling
// delay before observing state and start return. Sample the body flag
// after its original delay would have completed.

module test_sequence_kill_stops_bound_body_and_releases_start;
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

      fork

        begin
          first.start(sequencer);

          first_returned = 1;
        end

        begin
          wait (first.entered);
          #1;
          first.kill();

          #1;

          $display("UT: stopped %0d kill_calls %0d start_returned %0d",
                   first.get_sequence_state() == UVM_STOPPED, first.kill_calls, first_returned);

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
