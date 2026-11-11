/*
:name: test_callback_macro_parameterized_local_typedef_82
:description: A class-local callback typedef supports standard registration and instance dispatch
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.4.1 B.4.3 10.7.2.3.1 1800-2023 6.21 8.20 8.23 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers82/callbacks82.svh
:expected_exit: 0
:expected_stdout: @test_callback_macro_parameterized_local_typedef_82.expected
*/
// What it checks:
// Typedef names permit selected parameterized callback types to be used by the
// registration macro and typed callback interface.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.4.1 (UVM-CALLBACK-PARAMETERIZED-TYPEDEF-MACRO-USABILITY) gives
// the rule above. Setup: Original legal object/callback derivatives use actual
// registration and implicit dispatch macros. Cases include global/class-local
// aliases of parameterized callbacks, shared handles in separate instance
// queues, explicit mode0/1, related/unrelated callback families, inherited
// typewide state and completed-call reconfiguration. METHOD receives original
// object/token and mutable reference arguments. No factory-utility
// prerequisite is added. Expected: Global aliases of two specializations and a
// class-local alias compile and preserve selected type/instance dispatch with
// original arguments.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original callback arithmetic/trace is stimulus; no private registration bits.
module test_callback_macro_parameterized_local_typedef_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic local_alias_owner82 left=new("left82");
    automatic local_alias_owner82 right=new("right82");
    automatic local_alias_owner82::cb_t a=new("A");
    automatic local_alias_owner82::cb_t b=new("B");
    int acc;
    string trace;
    uvm_callbacks#(local_alias_owner82,local_alias_owner82::cb_t)::add(left,a);
    uvm_callbacks#(local_alias_owner82,local_alias_owner82::cb_t)::add(right,b);
    acc=0; trace=""; left.fire82(19,acc,trace);
    $display("UT: cb82 local_alias left %0d scope %0d args %0d",
      acc==13 && trace=="A",a.calls==1 && b.calls==0,
      a.last_owner==left && a.last_token==19);
    acc=0; trace=""; right.fire82(29,acc,trace);
    $display("UT: cb82 local_alias right %0d scope %0d args %0d",
      acc==13 && trace=="B",a.calls==1 && b.calls==1,
      b.last_owner==right && b.last_token==29);
    $finish;
  end
endmodule
