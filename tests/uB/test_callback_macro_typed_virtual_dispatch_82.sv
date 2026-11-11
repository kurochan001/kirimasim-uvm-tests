/*
:name: test_callback_macro_typed_virtual_dispatch_82
:description: CB filtering selects the requested callback family and invokes actual virtual overrides
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.3 B.4.1 10.7.2.3.1 10.7.2.2.2 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_typed_virtual_dispatch_82.expected
*/
// What it checks:
// Dispatch selects the requested CB family and invokes its actual virtual
// method override.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.3 (UVM-CALLBACK-MACRO-TYPED-VIRTUAL-DISPATCH) gives the rule
// above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: A derived callback receives the selected
// invocation while an unrelated callback with the same method name is excluded
// and remains separately callable.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_typed_virtual_dispatch_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic owner82 target=new();
    automatic derived_callback82 selected=new();
    automatic unrelated_callback82 other=new();
    int acc;
    string trace;
    pool82::add(target,selected);
    uvm_callbacks#(owner82,unrelated_callback82)::add(target,other);
    acc=0; trace=""; target.fire82(53,acc,trace);
    $display("UT: cb82 typed selected %0d virtual %0d excluded %0d args %0d",
      acc==5 && trace=="D",selected.calls==1 && selected.overrides==1,
      other.calls==0,selected.last_owner==target && selected.last_token==53);
    acc=0; trace=""; target.other82(59,acc,trace);
    $display("UT: cb82 typed alternate %0d counts %0d scope %0d",
      acc==99 && trace=="X",selected.calls==1 && other.calls==1,other.last_owner==target);
    $finish;
  end
endmodule
