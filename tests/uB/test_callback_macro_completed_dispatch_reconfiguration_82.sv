/*
:name: test_callback_macro_completed_dispatch_reconfiguration_82
:description: Repeated completed dispatches use the current deleted and reinserted callback list
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.2.3.1 10.7.2.3.3 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_completed_dispatch_reconfiguration_82.expected
*/
// What it checks:
// A later implicit invocation uses the registrations current after completed
// add/delete operations.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-CURRENT-COMPLETED-REGISTRATIONS) gives
// the rule above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: Delete removes a selected entry from the
// next dispatch; reinsertion affects a later complete trace while an outside
// peer remains untouched.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_completed_dispatch_reconfiguration_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 target=new();
    automatic owner82 peer=new("peer82");
    automatic callback82 a=new("A",3,1);
    automatic callback82 b=new("B",7,1);
    automatic callback82 outside=new("X",11);
    int acc;
    string trace;
    pool82::add(target,a); pool82::add(target,b); pool82::add(peer,outside);
    acc=5; trace=""; target.fire82(71,acc,trace);
    $display("UT: cb82 reconfigure first %0d trace %0d",acc==33,trace=="AB");
    pool82::delete(target,a); acc=5; trace=""; target.fire82(73,acc,trace);
    $display("UT: cb82 reconfigure deleted %0d counts %0d",
      acc==17 && trace=="B",a.calls==1 && b.calls==2);
    pool82::add(target,a,UVM_PREPEND); acc=5; trace=""; target.fire82(79,acc,trace);
    $display("UT: cb82 reconfigure restored %0d counts %0d peer %0d",
      acc==33 && trace=="AB",a.calls==2 && b.calls==3,outside.calls==0);
    $finish;
  end
endmodule
