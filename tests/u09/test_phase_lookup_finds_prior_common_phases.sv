/*
:name: test_phase_lookup_finds_prior_common_phases
:description: phase lookup finds prior nodes and exposes their relative order (IEEE 1800.2-2020 Section 9.3.1.4.3)
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
:expected_stdout: @test_phase_lookup_finds_prior_common_phases.expected
*/
// What it checks:
// 1. Phase name lookup finds the matching node within the selected
//    schedule/domain scope.
// 2. The phase order predicate identifies whether one node is earlier than
//    another.
// 3. The phase order predicate identifies whether one node is later than
//    another.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.3.1.4.3 (UVM-PHASE-FIND-BY-NAME) gives rule 1 above. Setup:
//    Search prior/future common phases or an isolated schedule by explicit
//    names. Expected: Present names resolve to the expected nodes and the
//    selected absent name resolves to null.
// 2. 1800.2-2020 9.3.1.4.6 (UVM-PHASE-ORDER-BEFORE) gives rule 2 above. Setup:
//    Compare prior/current/future nodes of the common schedule in both
//    directions. Expected: True/false relations agree with schedule order
//    rather than numeric state values.
// 3. 1800.2-2020 9.3.1.4.7 (UVM-PHASE-ORDER-AFTER) gives rule 3 above. Setup:
//    Compare prior/current/future nodes of the common schedule in both
//    directions. Expected: True/false relations agree with schedule order
//    rather than numeric state values.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Search from a running common phase, within its schedule. Check graph
// relationships rather than numeric phase states or printed schedule text.

module test_phase_lookup_finds_prior_common_phases;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void start_of_simulation_phase(uvm_phase phase);
      uvm_phase build = phase.find_by_name("build");
      uvm_phase connect = phase.find_by_name("connect");
      if (build == null || connect == null) $fatal(1, "missing common phase");
      $display("UT: build before connect %0d reverse %0d", build.is_before(connect),
               connect.is_before(build));
      $display("UT: connect after build %0d current after connect %0d",
               connect.is_after(build), phase.is_after(connect));
    endfunction
  endclass
  initial run_test();
endmodule
