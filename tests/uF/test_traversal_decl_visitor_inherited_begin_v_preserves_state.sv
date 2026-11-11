/*
:name: test_traversal_decl_visitor_inherited_begin_v_preserves_state
:description: The inherited visitor begin_v base body leaves selected original state unchanged.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.1.2.1 F.5.1.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_visitor_inherited_begin_v_preserves_state.expected
*/
// What it checks:
// The inherited visitor begin_v base body leaves selected original state
// unchanged.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.1.2.1
// (UVM-TRAVERSAL-DECL-VISITOR-INHERITED-BEGIN-V-PRESERVES-STATE) gives the
// rule above. Setup: Override only visit; inherit the selected default hook
// and call it after one live visit. Expected: The inherited hook preserves the
// one prior visit, selected node and quiet69 name; the following visit
// advances the count to two and keeps the same base view.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_visitor_inherited_begin_v_preserves_state;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic node69 node=new("node69");
    automatic quiet_visitor69 subject=new();
    automatic uvm_visitor#(node69) typed=subject;
    typed.visit(node);typed.begin_v();
    $display("UT: visitor_begin_v retained %0d subsequent %0d",
      subject.calls==1 && subject.last_node==node && subject.get_name()=="quiet69",
      typed==subject);
    typed.visit(node);
    $display("UT: visitor_begin_v visits %0d",subject.calls);
    $finish;
  end
endmodule
