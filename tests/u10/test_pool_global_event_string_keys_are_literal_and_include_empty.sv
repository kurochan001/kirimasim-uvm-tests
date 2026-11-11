/*
:name: test_pool_global_event_string_keys_are_literal_and_include_empty
:description: Global lookup treats supplied string keys literally, including the empty key.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.3 10.4.1.1 10.4.1.2.1 10.4.1.2.2 10.4.1.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_event_string_keys_are_literal_and_include_empty.expected
*/
// What it checks:
// Global lookup treats supplied string keys literally, including the empty
// key.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.4.1.2.3 (UVM-GLOBAL-AUDIT-POOL-GLOBAL-EVENT-STRING-KEYS-ARE-
// LITERAL-AND-INCLUDE-EMPTY) gives the rule above. Setup: Explicitly bind
// empty, dotted/wildcard-looking and neighboring string keys to distinct
// items. Expected: The linked static-admission, identity, live-state or
// bounded-wait observations match.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_event_string_keys_are_literal_and_include_empty;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_event_pool global_pool=uvm_event_pool::get_global_pool();
    automatic uvm_event subject=new("subject71");
    automatic uvm_event selected;
    automatic uvm_event star=new("star71"),neighbor=new("neighbor71");
    automatic uvm_event empty_item,star_item,neighbor_item;
    global_pool.add("",subject);global_pool.add("key.*71",star);
    global_pool.add("key.value71",neighbor);
    empty_item=uvm_event_pool::get_global("");star_item=uvm_event_pool::get_global("key.*71");
    neighbor_item=uvm_event_pool::get_global("key.value71");
    $display("UT: event_literal_keys empty %0d star %0d neighbor %0d",
      empty_item==subject,star_item==star,neighbor_item==neighbor);
    $finish;
  end
endmodule
