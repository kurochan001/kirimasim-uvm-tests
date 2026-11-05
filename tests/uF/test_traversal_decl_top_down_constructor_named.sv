/*
:name: test_traversal_decl_top_down_constructor_named
:description: The top_down constructor preserves the named name and declared ancestry.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.4.2 F.5.4 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_top_down_constructor_named.expected
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_top_down_constructor_named;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic uvm_top_down_visitor_adapter#() subject=new("named69");
    automatic uvm_visitor_adapter#(uvm_component,uvm_visitor#(uvm_component)) typed=subject;
    automatic uvm_object object_view=typed;
    $display("UT: ctor_top_down_named name %0d ancestry %0d",
      subject.get_name()=="named69",typed==subject && object_view==subject);
    $finish;
  end
endmodule
