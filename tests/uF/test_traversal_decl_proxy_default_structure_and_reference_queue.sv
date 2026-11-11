/*
:name: test_traversal_decl_proxy_default_structure_and_reference_queue
:description: The proxy default STRUCTURE is compatible with the component-specialized base.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.2.1 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_proxy_default_structure_and_reference_queue.expected
*/
// What it checks:
// The proxy default STRUCTURE is compatible with the component-specialized
// base.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.2.1
// (UVM-TRAVERSAL-DECL-PROXY-DEFAULT-STRUCTURE-AND-REFERENCE-QUEUE) gives the
// rule above. Setup: A complete subtype leaves STRUCTURE omitted; its original
// method delegates to the public component proxy. Expected: The default proxy
// is assignable to the component-specialized base and object view; its
// delegated call returns the two direct child handles in either sibling order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_proxy_default_structure_and_reference_queue;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic component69 root=new("tree69"),a=new("a69",root),b=new("b69",root);
    automatic component_proxy69 subject=new();
    automatic uvm_structure_proxy#(uvm_component) typed=subject;
    automatic uvm_object object_view=typed;
    automatic uvm_component children[$];
    typed.get_immediate_children(root,children);
    $display("UT: proxy_default type %0d children %0d",
      object_view==subject && typed==subject,
      children.size()==2 && ((children[0]==a && children[1]==b) ||
      (children[0]==b && children[1]==a)));
    $finish;
  end
endmodule
