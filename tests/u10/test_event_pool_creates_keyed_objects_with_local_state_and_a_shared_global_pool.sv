/*
:name: test_event_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool
:description: event pool creates per-key objects and keeps local pools distinct from the singleton global pool (IEEE 1800.2-2020 Section 10.4.1.2.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.1.2.4 10.4.1.2.2 11.2.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_event_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool.expected
*/
// What it checks:
// 1. Dedicated pool get creates a missing keyed object and reuses that local
//    key binding.
// 2. The dedicated global pool is a shared singleton of its pool type.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 10.4.1.2.4 (UVM-EVENT-POOL-KEYED-CREATION) gives rule 1
//    above. Setup: Use two keys in one pool and the same key in another pool.
//    Expected: Objects are non-null, repeated keys retain identity and state
//    changes stay local to one keyed object.
// 2. 1800.2-2020 10.4.1.2.2 (UVM-EVENT-POOL-GLOBAL-SINGLETON) gives rule 2
//    above. Setup: Fetch the global pool twice and query one key through each
//    handle. Expected: Both pool handles and keyed object handles agree,
//    independently of local pools.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_event_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool;
  import uvm_pkg::*;
  // Observe new-key growth, independently of initial pool membership.
  initial begin
    automatic uvm_event_pool first_pool = new("first_pool");
    automatic uvm_event_pool second_pool = new("second_pool");
    uvm_event_pool global_first;
    uvm_event_pool global_second;
    uvm_event first_item;
    uvm_event repeated;
    uvm_event peer_item;
    uvm_event other_item;
    uvm_event global_item;
    int first_size;
    int second_size;
    first_size = first_pool.num();
    second_size = second_pool.num();
    first_item = first_pool.get("alpha"); repeated = first_pool.get("alpha");
    peer_item = second_pool.get("alpha"); other_item = first_pool.get("beta");
    $display("UT: identities nonnull %0d repeated %0d local %0d keys %0d growth %0d/%0d",
             first_item != null && peer_item != null && other_item != null,
             first_item == repeated, first_item != peer_item, first_item != other_item,
             first_pool.num() - first_size, second_pool.num() - second_size);
    first_item.trigger();
    $display("UT: local_state active %0d peer_off %0d other_off %0d", first_item.is_on(),
             !peer_item.is_on(), !other_item.is_on());
    global_first = uvm_event_pool::get_global_pool();
    global_second = uvm_event_pool::get_global_pool(); global_item = global_first.get("shared");
    $display("UT: global singleton %0d shared_item %0d independent %0d",
    global_first == global_second,
             global_second.get("shared") == global_item, global_item != first_item);
    $finish;
  end
endmodule
