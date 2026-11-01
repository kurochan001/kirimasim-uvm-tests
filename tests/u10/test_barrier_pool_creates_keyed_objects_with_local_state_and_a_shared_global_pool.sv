/*
:name: test_barrier_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool
:description: barrier pool creates per-key objects and keeps local pools distinct from the singleton global pool (IEEE 1800.2-2020 Section 10.4.2.2.4)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.2.2.4 10.4.2.2.2 11.2.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_barrier_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool.expected
*/
module test_barrier_pool_creates_keyed_objects_with_local_state_and_a_shared_global_pool;
  import uvm_pkg::*;
  initial begin
    automatic uvm_barrier_pool first_pool = new("first_pool");
    automatic uvm_barrier_pool second_pool = new("second_pool");
    uvm_barrier_pool global_first;
    uvm_barrier_pool global_second;
    uvm_barrier first_item;
    uvm_barrier repeated;
    uvm_barrier peer_item;
    uvm_barrier other_item;
    uvm_barrier global_item;
    first_item = first_pool.get("alpha"); repeated = first_pool.get("alpha");
    peer_item = second_pool.get("alpha"); other_item = first_pool.get("beta");
    $display("UT: identities nonnull %0d repeated %0d local %0d keys %0d counts %0d/%0d",
             first_item != null && peer_item != null && other_item != null,
             first_item == repeated, first_item != peer_item, first_item != other_item,
             first_pool.num(), second_pool.num());
    first_item.set_threshold(2);
    $display("UT: local_state threshold %0d peer %0d other %0d", first_item.get_threshold(),
             peer_item.get_threshold(), other_item.get_threshold());
    global_first = uvm_barrier_pool::get_global_pool();
    global_second = uvm_barrier_pool::get_global_pool(); global_item = global_first.get("shared");
    $display("UT: global singleton %0d shared_item %0d independent %0d",
    global_first == global_second,
             global_second.get("shared") == global_item, global_item != first_item);
    $finish;
  end
endmodule
