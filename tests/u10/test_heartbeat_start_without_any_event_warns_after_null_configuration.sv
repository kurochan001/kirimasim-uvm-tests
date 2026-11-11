/*
:name: test_heartbeat_start_without_any_event_warns_after_null_configuration
:description: starting without a configured heartbeat event emits a warning (10.6.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.2.6 10.6.2.3 10.6.2.7 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_start_without_any_event_warns_after_null_configuration.expected
*/
// What it checks:
// Starting a heartbeat without a current or supplied trigger event emits a
// warning.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.6.2.6 (UVM-HEARTBEAT-MISSING-EVENT-WARNING) gives the rule
// above. Setup: An initial null-event configuration is followed by start, stop
// and another start. Expected: Each start with no event adds one warning.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A null initial event does not activate a monitor.
// Only warning counts are compared, without diagnostic text or identifiers.
module test_heartbeat_start_without_any_event_warns_after_null_configuration;
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
      actors.push_back(actor_a); first.set_heartbeat(null, actors);
      before_warnings = server.get_severity_count(UVM_WARNING);
      first.start();
      $display("UT: missing_event warnings %0d",
               server.get_severity_count(UVM_WARNING) - before_warnings);
      first.stop();
      before_warnings = server.get_severity_count(UVM_WARNING);
      first.start();
      $display("UT: still_missing warnings %0d",
               server.get_severity_count(UVM_WARNING) - before_warnings);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
