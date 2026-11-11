/*
:name: test_objection_drain_time_delays_extract
:description: a configured drain time delays phase completion after the last drop (IEEE 1800.2-2020 Section 10.5.1.3.6)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.6 10.5.1.3.7 10.5.1.3.4 9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_drain_time_delays_extract.expected
*/
// What it checks:
// 1. set_drain_time configures a source drain interval used after its last
//    drop.
// 2. get_drain_time reports the interval configured for the selected source.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.5.1.3.7 (UVM-OBJECTION-DRAIN-CONFIGURATION) gives rule 1
//    above. Setup: Set a positive interval and observe phase completion after
//    the source reaches zero. Expected: The phase waits the configured
//    interval before completing.
// 2. 1800.2-2020 10.5.1.3.6 (UVM-OBJECTION-DRAIN-QUERY) gives rule 2 above.
//    Setup: Set source drain time to 3 and query it before dropping. Expected:
//    The query returns 3.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Drain time starts after the last objection is dropped. The phase stays
// active for the configured interval before extraction can start.

module test_objection_drain_time_delays_extract;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      uvm_objection objections = phase.get_objection();
      objections.set_drain_time(this, 3);
      $display("UT: configured %0d", objections.get_drain_time(this));
      phase.raise_objection(this);
      #2;
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      $display("UT: extract at five %0d", $time == 5);
    endfunction
  endclass
  initial run_test();
endmodule
