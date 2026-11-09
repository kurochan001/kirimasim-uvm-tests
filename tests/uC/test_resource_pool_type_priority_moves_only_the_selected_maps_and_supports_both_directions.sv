/*
:name: test_resource_pool_type_priority_moves_only_the_selected_maps_and_supports_both_directions
:description: Pool type priority changes the specified maps and preserves the other map under equal precedence
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.2.4.5.1 C.2.4.3.1 C.2.4.4.4 C.2.4.4.6 C.2.2.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_resource_pool_type_priority_moves_only_the_selected_maps_and_supports_both_directions.expected
*/
// What it checks:
// type priority moves a resource to the selected map front/back and preserves
// any unselected map.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.2.4.5.1 (UVM-RESOURCE-AUDIT-PRIORITY-TYPE) gives the rule
// above. Setup: Two equal-precedence resources share a name/type; the later
// one is moved HIGH then LOW. Expected: HIGH selects the later resource only
// in the specified maps; LOW restores the first resource in both views.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_resource_pool_type_priority_moves_only_the_selected_maps_and_supports_both_directions;
  import uvm_pkg::*;
  initial begin
    automatic uvm_resource_pool pool=new();
    automatic uvm_resource#(int) first_resource=new("slot58");
    automatic uvm_resource#(int) later_resource=new("slot58");
    pool.set_scope(first_resource,"scope58"); pool.set_scope(later_resource,"scope58");
    pool.set_priority_type(later_resource,uvm_resource_types::PRI_HIGH);
    $display("UT: priority_high name %0d type %0d",
      pool.get_by_name("scope58","slot58",uvm_resource#(int)::get_type(),0)==first_resource,
      pool.get_by_type("scope58",uvm_resource#(int)::get_type())==later_resource);
    pool.set_priority_type(later_resource,uvm_resource_types::PRI_LOW);
    $display("UT: priority_low name %0d type %0d",
      pool.get_by_name("scope58","slot58",uvm_resource#(int)::get_type(),0)==first_resource,
      pool.get_by_type("scope58",uvm_resource#(int)::get_type())==first_resource);
    $finish;
  end
endmodule
