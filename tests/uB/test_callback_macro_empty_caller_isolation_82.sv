/*
:name: test_callback_macro_empty_caller_isolation_82
:description: Empty implicit dispatch does not invoke a peer callback or change METHOD reference arguments
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.2.3.1 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_empty_caller_isolation_82.expected
*/
// What it checks:
// An empty calling-object context supplies no callbacks to the implicit macro.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-EMPTY-CALLER-ISOLATION) gives the rule
// above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: The selected empty caller is
// entered,reference sentinels are retained and a peer-only callback is not
// called.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_empty_caller_isolation_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 empty_owner=new("empty82");
    automatic owner82 peer=new("peer82");
    automatic callback82 outside=new("X",11);
    int acc;
    string trace;
    pool82::add(peer,outside); acc=19; trace="sentinel";
    empty_owner.fire82(83,acc,trace);
    $display("UT: cb82 empty entered %0d retained %0d peer %0d",
      empty_owner.entries==1,acc==19 && trace=="sentinel",outside.calls==0);
    $finish;
  end
endmodule
