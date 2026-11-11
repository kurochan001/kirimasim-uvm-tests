/*
:name: test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity
:description: dedicated pool constructors and exact generic bases preserve identity (IEEE 1800.2-2020 Section 10.4.1.2.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.1 10.4.1.1 10.4.2.2.1 10.4.2.1 11.2.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity.expected
*/
// What it checks:
// 1. The event-pool constructor accepts an optional empty-default name.
// 2. The event pool specializes a string-keyed generic pool of object-data
//    events.
// 3. The barrier-pool constructor accepts an optional empty-default name.
// 4. The barrier pool specializes a string-keyed generic pool of barriers.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.4.1.2.1 (UVM-SYNC-REVIEW-EVENT-POOL-NAMES) gives rule 1
//    above. Setup: Create omitted, named and explicitly empty event pools.
//    Expected: All selected names are retained.
// 2. 1800.2-2020 10.4.1.1 (UVM-SYNC-REVIEW-EVENT-POOL-GENERIC-BASE) gives rule
//    2 above. Setup: Assign an event pool to its exact generic pool base.
//    Expected: The generic view preserves identity.
// 3. 1800.2-2020 10.4.2.2.1 (UVM-SYNC-REVIEW-BARRIER-POOL-NAMES) gives rule 3
//    above. Setup: Create omitted, named and explicitly empty barrier pools.
//    Expected: All selected names are retained.
// 4. 1800.2-2020 10.4.2.1 (UVM-SYNC-REVIEW-BARRIER-POOL-GENERIC-BASE) gives
//    rule 4 above. Setup: Assign a barrier pool to its exact generic pool
//    base. Expected: The generic view preserves identity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive dedicated-to-generic pool compatibility and optional names only.
// Initial membership has a separate fixture. The printed get_global return
// signature versus item-return prose is not resolved by these assignments.
module test_dedicated_pool_constructors_and_exact_generic_bases_preserve_identity;
  import uvm_pkg::*;
  initial begin
    automatic uvm_event_pool event_default = new();
    automatic uvm_event_pool event_named = new("events");
    automatic uvm_event_pool event_empty = new("");
    automatic uvm_barrier_pool barrier_default = new();
    automatic uvm_barrier_pool barrier_named = new("barriers");
    automatic uvm_barrier_pool barrier_empty = new("");
    automatic uvm_pool#(string,uvm_event#(uvm_object)) event_view = event_named;
    automatic uvm_pool#(string,uvm_barrier) barrier_view = barrier_named;
    $display("UT: event_pool_names omitted %0d named %0d empty %0d base %0d",
             event_default.get_name() == "",event_named.get_name() == "events",
             event_empty.get_name() == "",event_view == event_named);
    $display("UT: barrier_pool_names omitted %0d named %0d empty %0d base %0d",
             barrier_default.get_name() == "",barrier_named.get_name() == "barriers",
             barrier_empty.get_name() == "",barrier_view == barrier_named);
    $finish;
  end
endmodule
