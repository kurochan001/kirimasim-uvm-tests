/*
:name: test_resource_priority_enum_values_select_front_and_back_without_numeric_assumptions
:description: resource priority enum values select front and back without numeric assumptions
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.2.2 C.2.4.5.2 C.2.4.3.1 C.2.4.4.1 C.2.4.4.5 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_priority_enum_values_select_front_and_back_without_numeric_assumptions.expected
*/
// What it checks:
// 1. The typed PRI_HIGH priority value moves the selected resource to the
//    queue front.
// 2. The typed PRI_LOW priority value moves the selected resource to the queue
//    back.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.2.2 (UVM-RESOURCE-COLLECTION-PRIORITY-HIGH) gives rule 1
//    above. Setup: Assign the exact names to a priority_e variable, inspect
//    its symbolic name and pass it to the public name-priority API. Expected:
//    The selected name queue starts with the resource while the type queue
//    keeps its original head.
// 2. 1800.2-2020 C.2.2.2 (UVM-RESOURCE-COLLECTION-PRIORITY-LOW) gives rule 2
//    above. Setup: Assign the exact names to a priority_e variable, inspect
//    its symbolic name and pass it to the public name-priority API. Expected:
//    The selected resource becomes the name queue tail.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_priority_enum_values_select_front_and_back_without_numeric_assumptions;
  import uvm_pkg::*;
  initial begin
    uvm_resource_pool pool;
    uvm_resource#(int) first,second;
    uvm_resource_types::priority_e direction;
    uvm_resource_types::rsrc_q_t named,typed;
    pool=new(); first=new("slot62"); second=new("slot62");
    pool.set_scope(first,"scope62"); pool.set_scope(second,"scope62");
    direction=uvm_resource_types::PRI_HIGH; pool.set_priority_name(second,direction);
    named=pool.lookup_name("scope62","slot62",uvm_resource#(int)::get_type(),0);
    typed=pool.lookup_type("scope62",uvm_resource#(int)::get_type());
    $display("UT: enum_high symbolic %0d front %0d other_map %0d",
      direction.name()=="PRI_HIGH",named.size()==2 && named.get(0)==second,
      typed.size()==2 && typed.get(0)==first);
    direction=uvm_resource_types::PRI_LOW; pool.set_priority_name(second,direction);
    named=pool.lookup_name("scope62","slot62",uvm_resource#(int)::get_type(),0);
    $display("UT: enum_low symbolic %0d back %0d",
      direction.name()=="PRI_LOW",named.size()==2 && named.get(1)==second);
    $finish;
  end
endmodule
