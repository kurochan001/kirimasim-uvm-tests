/*
:name: test_pool_global_barrier_local_same_key_does_not_shadow_global
:description: A same-key binding in a local pool does not replace the global lookup target.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.2.2.3 10.4.2.1 10.4.2.2.1 10.4.2.2.2 10.4.2.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_barrier_local_same_key_does_not_shadow_global.expected
*/
// What it checks:
// A same-key binding in a local pool does not replace the global lookup
// target.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.2.2.3
// (UVM-GLOBAL-AUDIT-POOL-GLOBAL-BARRIER-LOCAL-SAME-KEY-DOES-NOT-SHADOW-GLOBAL)
// gives the rule above. Setup: Use the same string key in the singleton and an
// independently constructed local pool. Expected: The linked static-admission,
// identity, live-state or bounded-wait observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_barrier_local_same_key_does_not_shadow_global;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_barrier_pool global_pool=uvm_barrier_pool::get_global_pool();
    automatic uvm_barrier subject=new("subject71");
    automatic uvm_barrier selected;
    automatic uvm_barrier_pool local_pool=new("local71");
    automatic uvm_barrier local_item=new("local_item71");
    global_pool.add("selected71",subject);local_pool.add("selected71",local_item);
    selected=uvm_barrier_pool::get_global("selected71");
    $display("UT: barrier_local_shadow global %0d local %0d",
      selected==subject,selected==local_item);
    $finish;
  end
endmodule
