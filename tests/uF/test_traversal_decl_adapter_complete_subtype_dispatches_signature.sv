/*
:name: test_traversal_decl_adapter_complete_subtype_dispatches_signature
:description: A complete adapter subtype retains its typed object ancestry and declared accept interface.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.3.1 F.5.4 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_adapter_complete_subtype_dispatches_signature.expected
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_adapter_complete_subtype_dispatches_signature;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic node69 root=new("root69"),a=new("a69");
    automatic proxy69 proxy=new();
    automatic visitor69 visitor=new();
    automatic complete_adapter69 subject=new();
    automatic uvm_visitor_adapter#(node69,visitor69) typed=subject;
    automatic uvm_object object_view=typed;
    root.children.push_back(a);typed.accept(root,visitor,proxy);
    $display("UT: adapter_complete type %0d context %0d traversed %0d",
      object_view==subject && typed==subject,
      subject.calls==1 && subject.last_s==root && subject.last_v==visitor &&
      subject.last_p==proxy && subject.last_flag==1,
      visitor.visited.size()==2 && visitor.visited[0]==root && visitor.visited[1]==a);
    $finish;
  end
endmodule
