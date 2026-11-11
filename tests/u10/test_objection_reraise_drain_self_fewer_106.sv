/*
:name: test_objection_reraise_drain_self_fewer_106
:description: Re-raising across a pending zero-count chain preserves net ancestor counts
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.4 10.5.1.3.3 10.5.1.3.1 10.5.1.3.2 10.5.1.3.5 10.5.1.3.6 10.5.1.3.7 10.5.1.4.3 10.5.1.5.3 10.5.1.5.4 10.5.2.2.1 10.5.2.2.2 10.5.2.2.3 D.4.2 1800-2023 6.21 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers106_objection/objection106.svh
:args: +UVM_TESTNAME=t
:expected_exit: 0
:expected_stdout: @test_objection_reraise_drain_self_fewer_106.expected
*/
// What it checks:
// 1. A new objection during drain cancels the pending zero-count propagation.
//    The pending chain also terminates when the object or a descendant raises
//    during all_dropped.
// 2. Re-raising across a pending zero-count chain compensates the pending drop
//    when propagating the new objection to ancestors.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.5.1.3.4 (UVM-OBJECTION-RERAISE-CANCELS-DRAIN) gives rule 1
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
// 2. 1800.2-2020 10.5.1.3.4 (UVM-OBJECTION-PENDING-DROP-NET-PROPAGATION-106)
//    gives rule 2 above. Setup: Drop D objections at one component, then raise
//    R at that component or a descendant while its drain or all_dropped task
//    is pending. Use D=R, R>D and R<D, with a peer branch holding4 and a
//    separate objection holding7; observe two reuse rounds in normal mode1.
//    Expected: The selected source retains R local objections and the gated
//    subtree/ancestor retain total R; the root retains R+4 and the independent
//    objection remains7. For R>=D the propagated raise amount is R-D, with no
//    propagation at equality and a reduced positive count otherwise. For R<D
//    the signed compensation is checked through public totals without
//    prescribing a compensation callback. Releasing the canceled gate
//    preserves those counts; final selected/peer drops restore the appropriate
//    zero states.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Explicit gates distinguish drain time from the documented task callback.
// Public counts expose pending-drop compensation and source/peer isolation.
// No component task replaces the separately tested printed function hook.
// Negative net adjustments do not prescribe a compensation-hook encoding.
module test_objection_reraise_drain_self_fewer_106;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit CALLBACK106=0,DESCENDANT106=0;
  localparam bit REGISTERED106=0;
  localparam int OLD106=3,NEW106=1,PEER106=4,DRAIN106=2;
  `include "objection106.svh"
  initial run_test();
  initial begin #200; $fatal(1,"pending objection watchdog expired"); end
endmodule
