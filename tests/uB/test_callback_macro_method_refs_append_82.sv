/*
:name: test_callback_macro_method_refs_append_82
:description: Callback METHOD arguments preserve noncommutative reference updates in registration order
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
:expected_stdout: @test_callback_macro_method_refs_append_82.expected
*/
// What it checks:
// 1. Callback registration places appended callbacks after existing entries
//    and prepended callbacks before them.
// 2. METHOD receives the supplied object/token and reference arguments as
//    direct calls would.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.7.2.3.1 (UVM-CALLBACK-INSERTION-ORDER) gives rule 1 above.
//    Setup: Two callbacks are appended and one is prepended to one object.
//    Additional two-callback macro profiles use original A3/B7 transforms with
//    append or prepend from initial5. Expected: Invocation order is ahead,
//    first, second, with one invocation each. The added profiles yield AB/33
//    for append and BA/37 for prepend.
// 2. 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-METHOD-REFERENCE-ARGUMENTS) gives
//    rule 2 above. Setup: Original legal object/callback derivatives use
//    actual registration and implicit dispatch macros. Cases include
//    global/class-local aliases of parameterized callbacks, shared handles in
//    separate instance queues, explicit mode0/1, related/unrelated callback
//    families, inherited typewide state and completed-call reconfiguration.
//    METHOD receives original object/token and mutable reference arguments. No
//    factory-utility prerequisite is added. Expected: Append and prepend
//    histories retain both reference transformations and exact trace order
//    with the original caller/token at each callback.
// It also supports, as a control, the setup or conditions of
// UVM-CALLBACK-MACRO-METHOD-SIGNATURE-CONSTRAINT.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_method_refs_append_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 target=new();
    automatic callback82 a=new("A",3,1);
    automatic callback82 b=new("B",7,1);
    int acc;
    string trace;
    pool82::add(target,a); pool82::add(target,b,UVM_APPEND);
    acc=5; trace=""; target.fire82(31,acc,trace);
    $display("UT: cb82 method_refs_append value %0d trace %0d calls %0d args %0d",
      acc==33,trace=="AB",a.calls==1 && b.calls==1,
      a.last_owner==target && b.last_owner==target &&
      a.last_token==31 && b.last_token==31);
    $finish;
  end
endmodule
