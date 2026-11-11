/*
:name: test_callback_macro_derived_caller_typewide_82
:description: A caller based on T uses inherited typewide and its own instance callback without assumed cross-queue order
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 B.4.2 10.7.2.3.1 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_derived_caller_typewide_82.expected
*/
// What it checks:
// 1. Registering a super-type relationship lets derived objects inherit base
//    typewide callbacks.
// 2. Implicit dispatch includes applicable typewide and calling-instance
//    callbacks.
// 3. The calling object may be derived from the macro T type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.4.2 (UVM-CALLBACK-TYPEWIDE-INHERITANCE) gives rule 1 above.
//    Setup: Declare the relationship with the standard macro and invoke
//    base/derived objects. A new original object-family case combines
//    inherited base typewide membership with an independent derived-local
//    callback and observes the actual receiver. Expected: The callback runs
//    for both without prescribing inherited queue order.
// 2. 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-APPLICABLE-TYPEWIDE-AND-LOCAL)
//    gives rule 2 above. Setup: Original legal object/callback derivatives use
//    actual registration and implicit dispatch macros. Cases include
//    global/class-local aliases of parameterized callbacks, shared handles in
//    separate instance queues, explicit mode0/1, related/unrelated callback
//    families, inherited typewide state and completed-call reconfiguration.
//    METHOD receives original object/token and mutable reference arguments. No
//    factory-utility prerequisite is added. Expected: Selected calls visit
//    both memberships and preserve peer isolation without prescribing their
//    cross-queue enumeration order.
// 3. 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-CALLER-BASED-ON-T) gives rule 3
//    above. Setup: Original legal object/callback derivatives use actual
//    registration and implicit dispatch macros. Cases include
//    global/class-local aliases of parameterized callbacks, shared handles in
//    separate instance queues, explicit mode0/1, related/unrelated callback
//    families, inherited typewide state and completed-call reconfiguration.
//    METHOD receives original object/token and mutable reference arguments. No
//    factory-utility prerequisite is added. Expected: An inherited dispatch
//    body passes the actual derived receiver and reaches its applicable base
//    typewide and derived-local callbacks.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_derived_caller_typewide_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 base_owner=new("base82");
    automatic derived_owner82 derived_owner=new();
    automatic callback82 global_cb=new("G",1);
    automatic callback82 local_cb=new("L",5);
    int acc;
    string trace;
    pool82::add(null,global_cb);
    uvm_callbacks#(derived_owner82,callback82)::add(derived_owner,local_cb);
    acc=0; trace=""; base_owner.fire82(61,acc,trace);
    $display("UT: cb82 derived base %0d counts %0d args %0d",
      acc==1,global_cb.calls==1 && local_cb.calls==0,global_cb.last_owner==base_owner);
    acc=0; trace=""; derived_owner.fire82(67,acc,trace);
    $display("UT: cb82 derived child %0d counts %0d args %0d",
      acc==6,global_cb.calls==2 && local_cb.calls==1,
      global_cb.last_owner==derived_owner && local_cb.last_owner==derived_owner &&
      global_cb.last_token==67 && local_cb.last_token==67);
    $finish;
  end
endmodule
