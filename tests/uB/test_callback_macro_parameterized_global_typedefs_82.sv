/*
:name: test_callback_macro_parameterized_global_typedefs_82
:description: Global typedefs of two callback specializations compile and preserve typed dispatch
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
:expected_stdout: @test_callback_macro_parameterized_global_typedefs_82.expected
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
module test_callback_macro_parameterized_global_typedefs_82;
  import uvm_pkg::*;
  `include "callbacks82.svh"
  initial begin
    automatic alias_owner82 target=new();
    automatic gain3_callback82 three=new("A");
    automatic gain7_callback82 seven=new("B");
    int acc;
    string trace;
    uvm_callbacks#(alias_owner82,gain3_callback82)::add(target,three);
    uvm_callbacks#(alias_owner82,gain7_callback82)::add(target,seven);
    acc=0; trace=""; target.first82(17,acc,trace);
    $display("UT: cb82 global_alias first %0d typed %0d args %0d",
      acc==3 && trace=="A",three.calls==1 && seven.calls==0,
      three.last_owner==target && three.last_token==17);
    acc=0; trace=""; target.second82(23,acc,trace);
    $display("UT: cb82 global_alias second %0d typed %0d args %0d",
      acc==7 && trace=="B",three.calls==1 && seven.calls==1,
      seven.last_owner==target && seven.last_token==23);
    $finish;
  end
endmodule
