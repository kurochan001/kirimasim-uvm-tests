/*
:name: test_pool_global_barrier_explicit_alias_keys_preserve_shared_item_state
:description: Two keys explicitly bound to one item return that same shared item.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.2.2.3 10.4.2.1 10.4.2.2.1 10.4.2.2.2 10.4.2.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_barrier_explicit_alias_keys_preserve_shared_item_state.expected
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_barrier_explicit_alias_keys_preserve_shared_item_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_barrier_pool global_pool=uvm_barrier_pool::get_global_pool();
    automatic uvm_barrier subject=new("subject71");
    automatic uvm_barrier selected;
    automatic uvm_barrier alias_item;
    global_pool.add("selected71",subject);global_pool.add("alias71",subject);
    selected=uvm_barrier_pool::get_global("selected71");
    alias_item=uvm_barrier_pool::get_global("alias71");
    selected.set_threshold(7);
    $display("UT: barrier_alias identity %0d state %0d",
      selected==alias_item && alias_item==subject,alias_item.get_threshold());
    $finish;
  end
endmodule
