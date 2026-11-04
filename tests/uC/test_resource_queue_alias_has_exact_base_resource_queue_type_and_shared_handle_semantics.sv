/*
:name: test_resource_queue_alias_has_exact_base_resource_queue_type_and_shared_handle_semantics
:description: The resource queue typedef is exactly the base-resource uvm_queue specialization
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.2.1 C.2.3.1 1800-2023 6.21 8.20 8.21 8.26
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_queue_alias_has_exact_base_resource_queue_type_and_shared_handle_semantics.expected
*/
module test_resource_queue_alias_has_exact_base_resource_queue_type_and_shared_handle_semantics;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_types::rsrc_q_t declared_alias=new();
    automatic uvm_resource#(int) resource=new("value58");
    uvm_queue#(uvm_resource_base) required_queue;
    required_queue=declared_alias; declared_alias=required_queue;
    required_queue.push_back(resource);
    $display("UT: queue_alias identity %0d base_element %0d",required_queue==declared_alias,
      declared_alias.size()==1 && declared_alias.get(0)==resource);
    $finish;
  end
endmodule
