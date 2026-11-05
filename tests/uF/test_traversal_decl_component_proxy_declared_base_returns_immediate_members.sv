/*
:name: test_traversal_decl_component_proxy_declared_base_returns_immediate_members
:description: The component proxy retains its specified structure-proxy base and immediate component members.
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.7.1 F.5.1.1 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.1 F.5.2.2.1 F.5.2.2.2 F.5.3.1 F.5.3.2.1 F.5.3.2.2 F.5.4.1 F.5.4.2 F.5.5.1 F.5.5.2 F.5.6.1 F.5.6.2 F.5.7.2 F.5.7 5.3.1 5.3.2 5.3.4.2 13.1.2.1 1800-2023 6.21 8.13 8.17 8.20 8.21 8.22 8.25 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers69/traversal_fixture69.svh
:expected_exit: 0
:expected_stdout: @test_traversal_decl_component_proxy_declared_base_returns_immediate_members.expected
*/
// Original declarations and observations derived from the cited standards.
module
  test_traversal_decl_component_proxy_declared_base_returns_immediate_members;
  import uvm_pkg::*;
  `include "traversal_fixture69.svh"
  initial begin
    automatic component69 root=new("tree69"),a=new("a69",root),leaf=new("leaf69",a);
    automatic uvm_component_proxy subject=new();
    automatic uvm_structure_proxy#(uvm_component) typed=subject;
    automatic uvm_object object_view=typed;
    automatic uvm_component children[$];
    typed.get_immediate_children(root,children);
    $display("UT: component_proxy_decl type %0d children %0d",
      object_view==subject && typed==subject,children.size()==1 && children[0]==a);
    $finish;
  end
endmodule
