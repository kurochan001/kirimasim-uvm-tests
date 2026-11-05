/*
:name: test_traversal_decl_bottom_up_default_visitor_traverses_through_the_declared_base
:description: The bottom_up adapter preserves its default_visitor specialization through a live base-view traversal.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.5.1 F.5.5 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_bottom_up_default_visitor_traverses_through_the_declared_base.expected
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_bottom_up_default_visitor_traverses_through_the_declared_base;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic node69 root=new("root69"),a=new("a69"),b=new("b69"),leaf=new("leaf69");
    automatic proxy69 proxy=new();
    automatic visitor69 visitor=new();
    automatic uvm_bottom_up_visitor_adapter#(node69) subject=new();
    automatic uvm_visitor_adapter#(node69,uvm_visitor#(node69)) typed=subject;
    automatic bit members,ordered,callbacks;
    root.children.push_back(a);root.children.push_back(b);a.children.push_back(leaf);
    typed.accept(root,visitor,proxy);
    members=visitor.visited.size()==4 && visitor.count69(root)==1 &&
      visitor.count69(a)==1 && visitor.count69(b)==1 && visitor.count69(leaf)==1;
    ordered=visitor.position69(a)<visitor.position69(root) &&
      visitor.position69(b)<visitor.position69(root) &&
      visitor.position69(leaf)<visitor.position69(a);
    callbacks=visitor.begins==1 && visitor.ends==1 && visitor.before_count==0 &&
      visitor.after_count==4 && proxy.calls>0;
    $display("UT: typed_bottom_up_default_visitor type %0d members %0d order %0d callbacks %0d",
      typed==subject,members,ordered,callbacks);
    $finish;
  end
endmodule
