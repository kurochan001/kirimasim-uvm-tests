/*
:name: test_phase_lookup_finds_future_and_missing_nodes
:description: phase lookup finds a future final node and returns null for a missing name (IEEE 1800.2-2020 Section 9.3.1.4.3)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.3.1.4.3 9.3.1.4.6 9.3.1.4.7 9.8.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_phase_lookup_finds_future_and_missing_nodes.expected
*/
// The common-phase schedule can be searched before final executes.
// Check both directions of ordering and a name absent from that schedule.

module test_phase_lookup_finds_future_and_missing_nodes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void report_phase(uvm_phase phase);
      uvm_phase check = phase.find_by_name("check");
      uvm_phase last = phase.find_by_name("final");
      if (check == null || last == null) $fatal(1, "missing common phase");
      $display("UT: current before final %0d final after current %0d",
               phase.is_before(last), last.is_after(phase));
      $display("UT: current after check %0d missing %0d", phase.is_after(check),
               phase.find_by_name("m1_no_such_phase") == null);
    endfunction
  endclass
  initial run_test();
endmodule
