/*
:name: test_callback_macro_implicit_caller_shared_handle_82
:description: Implicit dispatch uses each calling object even when a callback handle is shared
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
:expected_stdout: @test_callback_macro_implicit_caller_shared_handle_82.expected
*/
// What it checks:
// The implicit callback macro selects callbacks associated with the actual
// calling object.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-IMPLICIT-CALLING-OBJECT) gives the
// rule above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: Separate callers sharing a callback handle
// still deliver their own context and local membership without invoking the
// other caller local callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_implicit_caller_shared_handle_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 left=new("left82");
    automatic owner82 right=new("right82");
    automatic callback82 shared=new("S",2);
    automatic callback82 a=new("A",3);
    automatic callback82 b=new("B",5);
    int acc;
    string trace;
    pool82::add(left,shared); pool82::add(left,a);
    pool82::add(right,shared); pool82::add(right,b);
    acc=0; trace=""; left.fire82(17,acc,trace);
    $display("UT: cb82 caller left %0d counts %0d args %0d",
      acc==5 && trace=="SA",shared.calls==1 && a.calls==1 && b.calls==0,
      shared.last_owner==left && a.last_owner==left && shared.last_token==17);
    acc=0; trace=""; right.fire82(23,acc,trace);
    $display("UT: cb82 caller right %0d counts %0d args %0d",
      acc==7 && trace=="SB",shared.calls==2 && a.calls==1 && b.calls==1,
      shared.last_owner==right && b.last_owner==right && shared.last_token==23);
    $finish;
  end
endmodule
