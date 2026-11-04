/*
:name: test_typed_resource_static_polymorphic_type_handles_are_shared_only_per_specialization
:description: Static resource type tokens agree with virtual base access and distinguish specializations
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.5.3.1 C.2.5.3.2 C.2.3.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_typed_resource_static_polymorphic_type_handles_are_shared_only_per_specialization.expected
*/
module
  test_typed_resource_static_polymorphic_type_handles_are_shared_only_per_specialization;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource#(int) first_resource=new("first58");
    automatic uvm_resource#(int) second_resource=new("second58");
    automatic uvm_resource#(string) other_resource=new("other58");
    uvm_resource#(int) int_token;
    uvm_resource#(string) string_token;
    uvm_resource_base base_view;
    int_token=uvm_resource#(int)::get_type(); string_token=uvm_resource#(string)::get_type();
    base_view=first_resource;
    $display("UT: type_handles nonnull %0d static_shared %0d polymorphic %0d isolated %0d",
      int_token!=null && string_token!=null,
      int_token==uvm_resource#(int)::get_type() && second_resource.get_type_handle()==int_token,
      base_view.get_type_handle()==int_token && other_resource.get_type_handle()==string_token,
      first_resource.get_type_handle()!=other_resource.get_type_handle());
    $finish;
  end
endmodule
