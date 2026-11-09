/*
:name: test_resource_pool_global_precedence_selects_name_maximum_and_keeps_type_priority
:description: The default global resource pool applies name precedence and type priority independently
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.5 C.2.4.5.6 C.2.4.4.4 C.2.4.4.5 C.2.4.4.6 C.2.4.3.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_global_precedence_selects_name_maximum_and_keeps_type_priority.expected
*/
// What it checks:
// 1. Global-pool name selection chooses the highest numeric precedence among
//    matching resources.
// 2. Global-pool type selection returns the first priority-queue resource,
//    unaffected by numeric precedence.
// 3. Priority and numeric precedence govern different selection paths under
//    the explicit type exception.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.2.4.4.4 (UVM-RESOURCE-AUDIT-GLOBAL-NAME-PRECEDENCE) gives
//    rule 1 above. Setup: Earlier/later same-name int resources receive
//    precedence three/nine in an explicit global or directly allocated pool;
//    type collections retain insertion priority. Expected: Name lookup returns
//    the later maximum while type lookup and its collection retain the first
//    resource.
// 2. 1800.2-2020 C.2.4.4.6 (UVM-RESOURCE-AUDIT-GLOBAL-TYPE-PRIORITY) gives
//    rule 2 above. Setup: Earlier/later same-name int resources receive
//    precedence three/nine in an explicit global or directly allocated pool;
//    type collections retain insertion priority. Expected: Name lookup returns
//    the later maximum while type lookup and its collection retain the first
//    resource.
// 3. 1800.2-2020 C.2.4.5 (UVM-RESOURCE-AUDIT-TYPE-PRECEDENCE-BOUNDARY) gives
//    rule 3 above. Setup: Earlier/later same-name int resources receive
//    precedence three/nine in an explicit global or directly allocated pool;
//    type collections retain insertion priority. Expected: Name lookup returns
//    the later maximum while type lookup and its collection retain the first
//    resource.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Type selection follows C.2.4.5 and the individual first-queue rule;
// the broader lookup introduction's highest-precedence wording conflicts.
// Default global pool, independently of the local-pool context fixture.
module test_resource_pool_global_precedence_selects_name_maximum_and_keeps_type_priority;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_pool pool=uvm_resource_pool::get();
    automatic uvm_resource#(int) first_resource=new("slot58");
    automatic uvm_resource#(int) later_resource=new("slot58");
    uvm_resource_types::rsrc_q_t typed;
    uvm_resource_base named_result,type_result;
    pool.set_scope(first_resource,"scope58"); pool.set_scope(later_resource,"scope58");
    pool.set_precedence(first_resource,3); pool.set_precedence(later_resource,9);
    typed=pool.lookup_type("scope58",uvm_resource#(int)::get_type());
    named_result=pool.get_by_name("scope58","slot58",uvm_resource#(int)::get_type(),0);
    type_result=pool.get_by_type("scope58",uvm_resource#(int)::get_type());
    $display("UT: precedence_routes name_highest %0d type_first %0d queue_priority %0d",
      named_result==later_resource,
      type_result==first_resource,
      typed.size()==2 && typed.get(0)==first_resource && typed.get(1)==later_resource);
    $display("UT: precedence_values first %0d later %0d",
      pool.get_precedence(first_resource),pool.get_precedence(later_resource));
    $display("UT: precedence_named first %0d later %0d nonnull %0d",
      named_result==first_resource,named_result==later_resource,named_result!=null);
    $finish;
  end
endmodule
