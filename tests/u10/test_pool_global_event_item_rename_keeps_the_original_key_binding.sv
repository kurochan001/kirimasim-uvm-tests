/*
:name: test_pool_global_event_item_rename_keeps_the_original_key_binding
:description: Renaming a bound item preserves its exact-key global lookup.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.3 10.4.1.1 10.4.1.2.1 10.4.1.2.2 10.4.1.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_event_item_rename_keeps_the_original_key_binding.expected
*/
// What it checks:
// Renaming a bound item preserves its exact-key global lookup.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.1.2.3 (UVM-GLOBAL-AUDIT-POOL-GLOBAL-EVENT-ITEM-RENAME-
// KEEPS-THE-ORIGINAL-KEY-BINDING) gives the rule above. Setup: Keep the
// binding key unchanged while changing the supplied item object name.
// Expected: The linked static-admission, identity, live-state or bounded-wait
// observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_event_item_rename_keeps_the_original_key_binding;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_event_pool global_pool=uvm_event_pool::get_global_pool();
    automatic uvm_event subject=new("subject71");
    automatic uvm_event selected;
    global_pool.add("selected71",subject);subject.set_name("renamed71");
    selected=uvm_event_pool::get_global("selected71");
    $display("UT: event_rename identity %0d current_name %0d",
      selected==subject,selected.get_name()=="renamed71");
    $finish;
  end
endmodule
