/*
:name: test_traversal_decl_by_level_constructor_omitted
:description: The by_level constructor preserves the omitted name and declared ancestry.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.6.2 F.5.6 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_by_level_constructor_omitted.expected
*/
// What it checks:
// The by_level constructor preserves the omitted name and declared ancestry.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.6.2 (UVM-TRAVERSAL-DECL-BY-LEVEL-CONSTRUCTOR-OMITTED) gives
// the rule above. Setup: Construct the builtin class directly with the
// selected argument form. The exact tested call is new(). Expected: The
// omitted base constructor name is the empty string. The typed ancestor and
// object views retain the same constructed handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_by_level_constructor_omitted;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic uvm_by_level_visitor_adapter#() subject=new();
    automatic uvm_visitor_adapter#(uvm_component,uvm_visitor#(uvm_component)) typed=subject;
    automatic uvm_object object_view=typed;
    $display("UT: ctor_by_level_omitted name %0d ancestry %0d",
      subject.get_name()=="",typed==subject && object_view==subject);
    $finish;
  end
endmodule
