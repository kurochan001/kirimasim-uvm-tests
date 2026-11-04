/*
:name: test_factory_single_active_service_view_keeps_explicit_local_instances_detached
:description: factory single active service view keeps explicit local instances detached
:tags: u08 uvm
:type: simulation
:lrm: 1800.2-2020 8.1 8.3.1.2.1 8.3.1.2.2 8.3.3 F.4.1.4.2 F.4.1.4.3 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_factory_single_active_service_view_keeps_explicit_local_instances_detached.expected
*/
module test_factory_single_active_service_view_keeps_explicit_local_instances_detached;
  import uvm_pkg::*;
  initial begin
    automatic uvm_coreservice_t service=uvm_coreservice_t::get();
    automatic uvm_factory saved=service.get_factory();
    automatic uvm_default_factory first=new();
    automatic uvm_default_factory second=new();
    bit detached,selected_first,selected_second;
    detached=first!=second && uvm_factory::get()==saved && service.get_factory()==saved;
    uvm_factory::set(first);
    selected_first=uvm_factory::get()==first && service.get_factory()==first && first!=second;
    service.set_factory(second);
    selected_second=uvm_factory::get()==second && service.get_factory()==second;
    $display("UT: active_factory detached %0d selected_first %0d selected_second %0d",
      detached,selected_first,selected_second);
    uvm_factory::set(saved);
    $display("UT: active_factory restored %0d",uvm_factory::get()==service.get_factory() &&
      service.get_factory()==saved);
    $finish;
  end
endmodule
