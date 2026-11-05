/*
:name: test_pool_global_barrier_replacement_binding_keeps_old_reference_independent
:description: After explicit replacement, global lookup returns the new bound item.
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.4.2.2.3 10.4.2.1 10.4.2.2.1 10.4.2.2.2 10.4.2.2.4 11.2.1 11.2.2.3 11.2.2.5 11.2.2.7 11.2.2.8 5.3.4.1 5.3.4.2 10.1.1.2.7 10.1.1.2.8 10.1.1.2.10 10.1.2.2.4 10.3.2.1 10.3.2.2 10.3.2.5 10.3.2.6 10.3.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pool_global_barrier_replacement_binding_keeps_old_reference_independent.expected
*/
// Original observations; printed pool/item return premises stay separate.
module
  test_pool_global_barrier_replacement_binding_keeps_old_reference_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
initial begin
    automatic uvm_barrier_pool global_pool=uvm_barrier_pool::get_global_pool();
    automatic uvm_barrier subject=new("subject71");
    automatic uvm_barrier selected;
    automatic uvm_barrier replacement=new("replacement71");
    global_pool.add("selected71",subject);subject.set_threshold(7);
    global_pool.add("selected71",replacement);
    selected=uvm_barrier_pool::get_global("selected71");
    $display("UT: barrier_replacement selected %0d old %0d fresh %0d",
      selected==replacement,subject.get_threshold(),selected.get_threshold());
    $finish;
  end
endmodule
