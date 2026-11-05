/*
:name: test_traversal_decl_proxy_reference_queue_dispatches_exact_node
:description: The declared proxy method receives the selected node and propagates its reference queue.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.2.2.2 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.1 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_proxy_reference_queue_dispatches_exact_node.expected
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_proxy_reference_queue_dispatches_exact_node;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic node69 root=new("root69"),a=new("a69"),peer=new("peer69");
    automatic proxy69 subject=new();
    automatic uvm_structure_proxy#(node69) typed=subject;
    automatic node69 children[$];
    root.children.push_back(a);children.push_back(peer);
    typed.get_immediate_children(root,children);
    $display("UT: proxy_ref calls %0d updated %0d source %0d",subject.calls,
      children.size()==1 && children[0]==a,
      root.children.size()==1 && root.children[0]==a);
    $finish;
  end
endmodule
