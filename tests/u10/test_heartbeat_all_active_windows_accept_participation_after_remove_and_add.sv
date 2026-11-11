/*
:name: test_heartbeat_all_active_windows_accept_participation_after_remove_and_add
:description: all-active heartbeat windows accept balanced participating components after list changes (10.6.2.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.2.3 10.6.2.4 10.6.2.5 10.6.2.7 10.6 10.5.1.3.3 10.5.1.3.4 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_all_active_windows_accept_participation_after_remove_and_add.expected
*/
// What it checks:
// 1. A configured heartbeat event and participating list accept the tested
//    healthy activity windows.
// 2. Removing a component from an active heartbeat excludes its later
//    nonparticipation from the monitored list.
// 3. Adding a currently participating component to an active heartbeat does
//    not invalidate a healthy all-active window.
// 4. The tested all-active heartbeat condition is satisfied when every
//    currently tracked component raises or drops the synchronizing objection.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.6.2.3
//    (UVM-HEARTBEAT-CONFIGURED-PARTICIPANTS-HEALTHY-WINDOWS) gives rule 1
//    above. Setup: Two listed descendants raise/drop the supplied objection
//    between separated event triggers. Expected: The three selected healthy
//    windows add no error or fatal.
// 2. 1800.2-2020 10.6.2.5 (UVM-HEARTBEAT-REMOVE-ACTIVE-PARTICIPANT) gives rule
//    2 above. Setup: After a healthy two-participant window, the second
//    component is removed and only the first participates. Expected: The next
//    selected window remains healthy.
// 3. 1800.2-2020 10.6.2.4 (UVM-HEARTBEAT-ADD-HEALTHY-PARTICIPANT) gives rule 3
//    above. Setup: The removed component is added again and both components
//    participate before the next trigger. Expected: The selected
//    added-participant window has no error or fatal.
// 4. 1800.2-2020 10.6 (UVM-HEARTBEAT-ALL-ACTIVE-POSITIVE-PARTICIPATION) gives
//    rule 4 above. Setup: All current participants are active in each of three
//    windows, including remove/add transitions. Expected: No error or fatal is
//    generated in the selected healthy windows.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original objection/event stimulus with separated simulation times.
// Only healthy ALL_ACTIVE windows are observed; missed-window severity is open.
module test_heartbeat_all_active_windows_accept_participation_after_remove_and_add;
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
      actors.push_back(actor_a); actors.push_back(actor_b);
      before_errors = server.get_severity_count(UVM_ERROR);
      before_fatals = server.get_severity_count(UVM_FATAL);
      first.set_heartbeat(event_one, actors);
      #1; event_one.trigger();
      #1; sync.raise_objection(actor_a); sync.drop_objection(actor_a);
      sync.raise_objection(actor_b); sync.drop_objection(actor_b);
      #1; event_one.trigger();
      #1; first.remove(actor_b);
      sync.raise_objection(actor_a); sync.drop_objection(actor_a);
      #1; event_one.trigger();
      #1; first.add(actor_b);
      sync.raise_objection(actor_a); sync.drop_objection(actor_a);
      sync.raise_objection(actor_b); sync.drop_objection(actor_b);
      #1; event_one.trigger(); #1;
      $display("UT: healthy_windows 3 errors %0d fatals %0d",
               server.get_severity_count(UVM_ERROR) - before_errors,
               server.get_severity_count(UVM_FATAL) - before_fatals);
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
