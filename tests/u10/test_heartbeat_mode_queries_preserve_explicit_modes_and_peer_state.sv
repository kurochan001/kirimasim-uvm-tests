/*
:name: test_heartbeat_mode_queries_preserve_explicit_modes_and_peer_state
:description: heartbeat mode queries return the selected per-instance mode (10.6.2.2)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.2.2 10.6.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_mode_queries_preserve_explicit_modes_and_peer_state.expected
*/
// What it checks:
// 1. Heartbeat construction preserves its supplied instance name.
// 2. Calling set_mode without an argument retrieves the current selected mode.
// 3. The explicit UVM_NO_HB_MODE query preserves and returns the selected
//    heartbeat mode.
// 4. An explicitly changed heartbeat mode affects that object independently of
//    a peer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.6.2.1 (UVM-HEARTBEAT-CONSTRUCTOR-NAME) gives rule 1 above.
//    Setup: Two heartbeat objects share a valid context and supplied
//    objection. Expected: Their names remain first and second.
// 2. 1800.2-2020 10.6.2.2 (UVM-HEARTBEAT-MODE-OMITTED-QUERY) gives rule 2
//    above. Setup: ALL_ACTIVE and ONE_ACTIVE are explicitly selected on two
//    objects before querying. Expected: The omitted-argument queries return
//    the two selected modes.
// 3. 1800.2-2020 10.6.2.2 (UVM-HEARTBEAT-MODE-EXPLICIT-QUERY-SENTINEL) gives
//    rule 3 above. Setup: The peer has explicitly selected ONE_ACTIVE.
//    Expected: The explicit query still returns ONE_ACTIVE.
// 4. 1800.2-2020 10.6.2.2 (UVM-HEARTBEAT-MODE-INSTANCE-LOCAL-UPDATE) gives
//    rule 4 above. Setup: The first object changes from ALL_ACTIVE to
//    ANY_ACTIVE while the peer remains ONE_ACTIVE. Expected: Queries show
//    ANY_ACTIVE for the first and ONE_ACTIVE for the peer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicitly select modes before querying; no constructor mode is assumed.
// The return value of a mode-changing call is deliberately not asserted.
module test_heartbeat_mode_queries_preserve_explicit_modes_and_peer_state;
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
      observed = first.set_mode(UVM_ALL_ACTIVE); observed = second.set_mode(UVM_ONE_ACTIVE);
      $display("UT: names %s %s", first.get_name(), second.get_name());
      $display("UT: selected first %0d second %0d", first.set_mode() == UVM_ALL_ACTIVE,
               second.set_mode() == UVM_ONE_ACTIVE);
      observed = first.set_mode(UVM_ANY_ACTIVE);
      $display("UT: changed first %0d peer %0d", first.set_mode() == UVM_ANY_ACTIVE,
               second.set_mode(UVM_NO_HB_MODE) == UVM_ONE_ACTIVE);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
