/*
:name: test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments
:description: Default precedence wrappers agree with core service and affect future/default assignments without changing peers
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.5.4 C.2.4.5.5 C.2.4.5.6 C.2.4.5.7 C.2.4.3.1 F.4.1.4.23 F.4.1.4.24 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments.expected
*/
module
  test_resource_pool_default_precedence_updates_only_future_resources_implicit_assignments;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t core=uvm_coreservice_t::get();
    automatic uvm_resource_pool pool=uvm_resource_pool::get();
    automatic int unsigned saved=uvm_resource_pool::get_default_precedence();
    automatic uvm_resource#(int) existing=new("existing58");
    automatic uvm_resource#(int) future_resource=new("future58");
    $display("UT: precedence_default initial %0d core_view %0d",saved==1000,
      saved==core.get_resource_pool_default_precedence());
    pool.set_scope(existing,"scope58"); pool.set_precedence(existing,11);
    uvm_resource_pool::set_default_precedence(58); pool.set_scope(future_resource,"scope58");
    $display("UT: precedence_default changed %0d existing %0d future %0d",
      core.get_resource_pool_default_precedence()==58 &&
      uvm_resource_pool::get_default_precedence()==58,
      pool.get_precedence(existing)==11,pool.get_precedence(future_resource)==58);
    core.set_resource_pool_default_precedence(59); pool.set_precedence(existing);
    $display("UT: precedence_default implicit_assignment %0d peer_unchanged %0d",
      pool.get_precedence(existing)==59,pool.get_precedence(future_resource)==58);
    uvm_resource_pool::set_default_precedence(saved); $finish;
  end
endmodule
