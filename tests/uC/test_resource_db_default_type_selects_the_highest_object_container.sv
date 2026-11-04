/*
:name: test_resource_db_default_type_selects_the_highest_object_container
:description: resource db default type selects the highest object container
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.3.2.3.10 C.3.2.1 C.2.4.5.6 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_db_default_type_selects_the_highest_object_container.expected
*/
module test_resource_db_default_type_selects_the_highest_object_container;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(uvm_object) first,second;
    uvm_resource#(int) unrelated;
    uvm_resource_types::rsrc_q_t values;
    pool=uvm_resource_pool::get(); first=new("first62"); second=new("second62");
    unrelated=new("integer62"); values=new();
    pool.set_scope(first,"scope62"); pool.set_scope(second,"scope62");
    pool.set_scope(unrelated,"scope62");
    pool.set_precedence(first,1); pool.set_precedence(second,9);
    pool.set_precedence(unrelated,100);
    values.push_back(unrelated); values.push_back(first); values.push_back(second);
    $display("UT: default_typed_max same %0d",
      uvm_resource_db#()::get_highest_precedence(values)==second);
    $finish;
  end
endmodule
