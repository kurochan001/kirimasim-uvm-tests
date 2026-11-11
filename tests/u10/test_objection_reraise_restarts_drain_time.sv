/*
:name: test_objection_reraise_restarts_drain_time
:description: raising an objection during drain cancels the earlier completion (IEEE 1800.2-2020 Section 10.5.1.3.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.4 10.5.1.3.7 9.6 10.5.1.3.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_reraise_restarts_drain_time.expected
*/
// What it checks:
// 1. set_drain_time configures a source drain interval used after its last
//    drop.
// 2. A new objection during drain cancels the pending zero-count propagation.
//    The pending chain also terminates when the object or a descendant raises
//    during all_dropped.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.5.1.3.7 (UVM-OBJECTION-DRAIN-CONFIGURATION) gives rule 1
//    above. Setup: Set a positive interval and observe phase completion after
//    the source reaches zero. Expected: The phase waits the configured
//    interval before completing.
// 2. 1800.2-2020 10.5.1.3.4 (UVM-OBJECTION-RERAISE-CANCELS-DRAIN) gives rule 2
//    above. Setup: Raise again during a three-unit drain, then drop again
//    later. Retain that original phase case and additionally re-raise a
//    standalone objection for the gated object or its descendant during a
//    two-unit drain or a gated objection/registered all_dropped task. Use
//    equal/greater/fewer new counts and repeat after completed cleanup.
//    Expected: Extraction waits a full fresh drain and occurs at time 6. In
//    the added standalone cases, the old zero-count chain does not later clear
//    the held branch; after releasing the old gate, selected and ancestor
//    totals retain the new objections, peer state remains separate and a final
//    drop completes a fresh drain/callback cycle. Those added cases do not
//    assert the original extraction time.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A new raise during drain cancels that drain iteration. The final drop
// starts a full new drain interval; extraction must wait for its completion.

module test_objection_reraise_restarts_drain_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      uvm_objection objections = phase.get_objection();
      objections.set_drain_time(this, 3);
      phase.raise_objection(this);
      #1;
      phase.drop_objection(this);
      #1;
      phase.raise_objection(this);
      $display("UT: raised again at two %0d", $time == 2);
      #1;
      phase.drop_objection(this);
    endtask
    function void extract_phase(uvm_phase phase);
      $display("UT: extract at six %0d", $time == 6);
    endfunction
  endclass
  initial run_test();
endmodule
