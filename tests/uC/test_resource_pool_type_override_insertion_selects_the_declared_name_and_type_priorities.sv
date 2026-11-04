/*
:name: test_resource_pool_type_override_insertion_selects_the_declared_name_and_type_priorities
:description: Pool type override inserts with precisely the specified name/type priorities
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.3.4 C.2.4.3.1 C.2.4.4.4 C.2.4.4.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_type_override_insertion_selects_the_declared_name_and_type_priorities.expected
*/
module test_resource_pool_type_override_insertion_selects_the_declared_name_and_type_priorities;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_pool pool=new();
    automatic uvm_resource#(int) first_resource=new("slot58");
    automatic uvm_resource#(int) override_resource=new("slot58");
    pool.set_scope(first_resource,"scope58"); pool.set_type_override(override_resource,"scope58");
    $display("UT: override_insertion name %0d type %0d",
      pool.get_by_name("scope58","slot58",uvm_resource#(int)::get_type(),0)==first_resource,
      pool.get_by_type("scope58",uvm_resource#(int)::get_type())==override_resource);
    $finish;
  end
endmodule
