/*
:name: test_traversal_decl_visitor_default_node
:description: The visitor declaration preserves the selected NODE specialization and object base view.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_visitor_default_node.expected
*/
// What it checks:
// The visitor declaration preserves the selected NODE specialization and
// object base view.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.1.1 (UVM-TRAVERSAL-DECL-VISITOR-DEFAULT-NODE) gives the rule
// above. Setup: Use a complete original visitor with default node; call
// through the exact typed base. Expected: The exact typed visitor and object
// base views identify the same subtype, and one visit delivers the original
// selected node once.
// It also supports, as a control, the setup or conditions of
// UVM-TRAVERSAL-DECL-VISITOR-VIRTUAL-REQUIRES-COMPILE-REJECTION.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_visitor_default_node;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic component69 node=new("node69");
    automatic component_visitor69 subject=new();
    automatic uvm_visitor#(uvm_component) typed=subject;
    automatic uvm_object object_view=typed;
    typed.visit(node);
    $display("UT: visitor_default_node type %0d delivered %0d",
      object_view==subject && typed==subject,
      subject.visited.size()==1 && subject.visited[0]==node);
    $finish;
  end
endmodule
