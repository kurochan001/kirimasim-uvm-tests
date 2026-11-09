/*
:name: test_typed_resource_virtual_interface_values_select_live_original_instances
:description: typed resource virtual interface values select live original instances
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5 C.2.1 C.2.5.1 C.2.5.4.1 C.2.5.4.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_resource_virtual_interface_values_select_live_original_instances.expected
*/
// What it checks:
// A typed resource can retain a selected virtual-interface value.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.5 (UVM-RESOURCE-COLLECTION-TYPED-CONTAINER-INTERFACE) gives
// the rule above. Setup: Store and replace virtual handles for two original
// interface instances and mutate the selected instance through a retrieved
// view. Expected: The retrieved views reach live selected state while a
// previously retrieved view still reaches its original instance.
// These expectations come from the cited clauses, not from the output of a
// simulator.
interface resource_channel62;
  int value=0;
endinterface
module test_typed_resource_virtual_interface_values_select_live_original_instances;
  import uvm_pkg::*;
  resource_channel62 first();
  resource_channel62 second();
  typedef virtual resource_channel62 channel_t;
  initial begin
    uvm_resource#(channel_t) resource;
    channel_t first_view,second_view;
    resource=new("channel62"); first.value=17; second.value=39;
    resource.write(first); first_view=resource.read();
    $display("UT: vif_resource first_live %0d",first_view.value==17);
    resource.write(second); second_view=resource.read(); second_view.value=61;
    $display("UT: vif_resource replacement %0d original_retained %0d",
      second.value==61,first_view.value==17 && first.value==17);
    $finish;
  end
endmodule
