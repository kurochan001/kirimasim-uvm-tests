/*
:name: test_heartbeat_rejects_a_different_running_event_but_accepts_it_after_stop
:description: a running heartbeat rejects event replacement until it is stopped (10.6.2.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.6.2.6 10.6.2.7 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_heartbeat_rejects_a_different_running_event_but_accepts_it_after_stop.expected
*/
// Events are not triggered, so this case tests configuration guards only.
// Positive delays let the stopped process finish before a fresh start.
module test_heartbeat_rejects_a_different_running_event_but_accepts_it_after_stop;
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
      before_errors = server.get_severity_count(UVM_ERROR);
      first.start(event_two);
      $display("UT: running_replacement errors %0d",
               server.get_severity_count(UVM_ERROR) - before_errors);
      first.stop(); #1;
      before_errors = server.get_severity_count(UVM_ERROR);
      first.start(event_two); #1;
      $display("UT: stopped_replacement errors %0d",
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
