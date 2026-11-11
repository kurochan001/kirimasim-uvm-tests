/*
:name: test_pool_global_event_explicit_alias_keys_preserve_shared_item_state
:description: Two keys explicitly bound to one item return that same shared item.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.3 10.4.1.1 10.4.1.2.1 10.4.1.2.2 10.4.1.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_event_explicit_alias_keys_preserve_shared_item_state.expected
*/
// What it checks:
// Two keys explicitly bound to one item return that same shared item.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.1.2.3 (UVM-GLOBAL-AUDIT-POOL-GLOBAL-EVENT-EXPLICIT-ALIAS-
// KEYS-PRESERVE-SHARED-ITEM-STATE) gives the rule above. Setup: Use add to
// bind the same caller-supplied handle under two distinct global keys.
// Expected: The linked static-admission, identity, live-state or bounded-wait
// observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_event_explicit_alias_keys_preserve_shared_item_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_event_pool global_pool=uvm_event_pool::get_global_pool();
    automatic uvm_event subject=new("subject71");
    automatic uvm_event selected;
    automatic uvm_event alias_item;
    global_pool.add("selected71",subject);global_pool.add("alias71",subject);
    selected=uvm_event_pool::get_global("selected71");
    alias_item=uvm_event_pool::get_global("alias71");
    selected.trigger();
    $display("UT: event_alias identity %0d state %0d",
      selected==alias_item && alias_item==subject,alias_item.is_on());
    $finish;
  end
endmodule
