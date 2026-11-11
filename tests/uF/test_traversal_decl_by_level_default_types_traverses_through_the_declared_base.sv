/*
:name: test_traversal_decl_by_level_default_types_traverses_through_the_declared_base
:description: The by_level adapter preserves its default_types specialization through a live base-view traversal.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.6.1 F.5.6 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_by_level_default_types_traverses_through_the_declared_base.expected
*/
// What it checks:
// The by_level adapter preserves its default_types specialization through a
// live base-view traversal.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.6.1 (UVM-TRAVERSAL-DECL-BY-LEVEL-DEFAULT-TYPES-TRAVERSES-
// THROUGH-THE-DECLARED-BASE) gives the rule above. Setup: Use the selected
// printed type defaults or explicit types and traverse an acyclic original
// tree through its supplied proxy. Expected: The builtin default
// specialization is assignable to the exact component/visitor base and visits
// both root and child once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_by_level_default_types_traverses_through_the_declared_base;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic component69 root=new("tree69"),child=new("child69",root);
    automatic component_visitor69 visitor=new();
    automatic uvm_component_proxy proxy=new();
    automatic uvm_by_level_visitor_adapter#() subject=new();
    automatic uvm_visitor_adapter#(uvm_component,uvm_visitor#(uvm_component)) typed=subject;
    typed.accept(root,visitor,proxy);
    $display("UT: typed_by_level_default_types type %0d members %0d",typed==subject,
      visitor.visited.size()==2 && ((visitor.visited[0]==root &&
      visitor.visited[1]==child) || (visitor.visited[0]==child && visitor.visited[1]==root)));
    $finish;
  end
endmodule
