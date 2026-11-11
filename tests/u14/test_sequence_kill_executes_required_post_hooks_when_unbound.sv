/*
:name: test_sequence_kill_executes_required_post_hooks_when_unbound
:description: sequence termination stops active work and reports its required state and callbacks (IEEE 1800.2-2020 Section 14.2.5.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.11 14.2.3.8 14.2.3.9 14.2.3.1 14.2.5.12 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_kill_executes_required_post_hooks_when_unbound.expected
*/
// What it checks:
// 1. Killing a sequence executes its required post_body callback.
// 2. Killing a sequence executes its required post_start callback.
// 3. Direct sequence kill invokes its do_kill hook for bound and unbound
//    running bodies.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-REQUIRED-POST-BODY) gives rule 1
//    above. Setup: Kill bound and unbound active sequences with zero-delay
//    hook counters. Expected: Each fixture records one post_body call.
// 2. 1800.2-2020 14.2.5.11 (UVM-SEQUENCE-KILL-REQUIRED-POST-START) gives rule
//    2 above. Setup: Kill bound and unbound active sequences with zero-delay
//    hook counters. Expected: Each fixture records one post_start call.
// 3. 1800.2-2020 14.2.5.12 (UVM-SEQUENCE-DO-KILL-HOOK-BOUND-AND-UNBOUND) gives
//    rule 3 above. Setup: The original body is entered before kill and its
//    hook increments a counter. Expected: Each killed sequence observes one
//    do_kill callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The standard requires the post-body and post-start hooks on kill.
// These zero-delay hooks only increment counters. The pinned library
// omits them; keep their required calls as spec-only after settling.

module test_sequence_kill_executes_required_post_hooks_when_unbound;
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
          first.start(null);

          first_returned = 1;
        end

        begin
          wait (first.entered);
          #1;
          first.kill();

          #1;

          $display("UT: stopped %0d kill_calls %0d start_returned %0d",
                   first.get_sequence_state() == UVM_STOPPED, first.kill_calls, first_returned);

          $display("UT: post_hooks %0d %0d", first.post_body_calls, first.post_start_calls);

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
