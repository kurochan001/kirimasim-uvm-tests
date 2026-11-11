/*
:name: test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop
:description: an omitted heartbeat start event reuses the previously selected event (10.6.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.2.6 10.6.2.7 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop.expected
*/
// What it checks:
// 1. An omitted start event reuses the selected event rather than requesting a
//    different event while running.
// 2. Starting with an omitted event after stop reuses the previously
//    configured event.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.6.2.6 (UVM-HEARTBEAT-ACTIVE-DEFAULT-EVENT-REUSE) gives
//    rule 1 above. Setup: Stopped reuse and explicit same-event controls
//    precede an omitted-event call on the running monitor. Expected: The
//    running default-event reuse returns without adding an error.
// 2. 1800.2-2020 10.6.2.6 (UVM-HEARTBEAT-STOPPED-DEFAULT-EVENT-REUSE) gives
//    rule 2 above. Setup: A configured event is stopped, then start is called
//    without an argument. Expected: Stopped default reuse adds no error; the
//    explicit same-event control also returns normally.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An omitted event selects the previous event, rather than a new event.
// Observe stopped and explicit-event controls before the running default call.
// The pinned running guard dereferences the omitted event while forming
// an error.
module test_heartbeat_default_start_reuses_its_event_while_running_and_after_stop;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class participant extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_heartbeat first, second;
    uvm_objection sync;
    uvm_event#(uvm_object) event_one, event_two;
    participant actor_a, actor_b;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sync = new("sync");
      first = new("first", this, sync); second = new("second", this, sync);
      event_one = new("event_one"); event_two = new("event_two");
      actor_a = new("actor_a", this); actor_b = new("actor_b", this);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_report_server server;
      uvm_heartbeat_modes observed;
      uvm_component actors[$];
      int before_errors, before_warnings, before_fatals;
      phase.raise_objection(this);
      server = uvm_report_server::get_server();
      set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
      set_report_severity_action(UVM_FATAL, UVM_DISPLAY);
      observed = first.set_mode(UVM_ALL_ACTIVE);
      first.start(event_one); #1;
      first.stop(); #1;
      before_errors = server.get_severity_count(UVM_ERROR);
      first.start(); #1;
      $display("UT: stopped_reuse errors %0d",
               server.get_severity_count(UVM_ERROR) - before_errors);
      before_errors = server.get_severity_count(UVM_ERROR);
      first.start(event_one); #1;
      $display("UT: explicit_same_event errors %0d",
               server.get_severity_count(UVM_ERROR) - before_errors);
      before_errors = server.get_severity_count(UVM_ERROR);
      first.start();
      $display("UT: running_reuse errors %0d",
               server.get_severity_count(UVM_ERROR) - before_errors);
      first.stop();
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
