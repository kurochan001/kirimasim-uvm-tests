/*
:name: test_resource_pool_default_accessor_follows_core_service_selection_and_restoration
:description: The resource pool static accessor follows the selected core-service default and can be restored
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.2.2 C.2.4.2.1 C.2.4.1 F.4.1.4.21 F.4.1.4.22 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_default_accessor_follows_core_service_selection_and_restoration.expected
*/
// The active global-default view does not forbid allocating local pools.
module test_resource_pool_default_accessor_follows_core_service_selection_and_restoration;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_resource_pool saved=uvm_resource_pool::get();
    automatic uvm_resource_pool first_pool=new();
    automatic uvm_resource_pool second_pool=new();
    $display("UT: pool_default initial %0d allocations_detached %0d",
      saved==core.get_resource_pool(),
      saved==uvm_resource_pool::get() && first_pool!=second_pool);
    core.set_resource_pool(first_pool);
    $display("UT: pool_default first %0d",uvm_resource_pool::get()==first_pool);
    core.set_resource_pool(second_pool);
    $display("UT: pool_default second %0d",uvm_resource_pool::get()==second_pool);
    core.set_resource_pool(saved);
    $display("UT: pool_default restored %0d",uvm_resource_pool::get()==saved);
    $finish;
  end
endmodule
