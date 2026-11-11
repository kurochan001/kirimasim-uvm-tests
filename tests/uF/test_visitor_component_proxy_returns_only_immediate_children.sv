/*
:name: test_visitor_component_proxy_returns_only_immediate_children
:description: component proxy returns direct children and no descendants (IEEE 1800.2-2020 Section F.5.7)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.7 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.2.2 F.5.3.2.2 13.1.2.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_visitor_component_proxy_returns_only_immediate_children.expected
*/
// What it checks:
// The component proxy enumerates immediate children without including deeper
// descendants.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.7 (UVM-VISITOR-COMPONENT-IMMEDIATE-CHILDREN) gives the rule
// above. Setup: Query a root, one child and a leaf in a five-node tree.
// Expected: Root has exactly a/b, a has its exact leaf, and a leaf has no
// children.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Traverse a finite tree through public adapters and a component proxy.
// Check parent/level relationships and membership without sibling ordering.
module test_visitor_component_proxy_returns_only_immediate_children;
  import uvm_pkg::*;

  class component_node extends uvm_component;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class audit_visitor extends uvm_visitor#(uvm_component);
    uvm_component visited[$];
    int begins = 0;
    int ends = 0;
    string trace = "";
    function new(string name="visitor"); super.new(name); endfunction
    virtual function void begin_v(); begins++; trace = {trace, "B"}; endfunction
    virtual function void end_v(); ends++; trace = {trace, "E"}; endfunction
    virtual function void visit(uvm_component node); visited.push_back(node); trace = {trace,
    "V"}; endfunction
    function int count(uvm_component node);
      int result_value = 0;
      foreach (visited[i]) if (visited[i] == node) result_value++;
      return result_value;
    endfunction
    function int position(uvm_component node);
      foreach (visited[i]) if (visited[i] == node) return i;
      return -1;
    endfunction
  endclass

  initial begin

    automatic component_node root = new("tree", null);
    automatic component_node a = new("a", root);
    automatic component_node b = new("b", root);
    automatic component_node a_leaf = new("leaf", a);
    automatic component_node b_leaf = new("leaf", b);
    automatic uvm_component_proxy proxy = new("proxy");
    automatic audit_visitor visitor = new();

    uvm_component children[$];
    uvm_component leaves[$];
    uvm_component empty[$];
    automatic int members = 0;

    proxy.get_immediate_children(root, children);
    foreach (children[i]) begin
      if (children[i] == a) members |= 1;
      if (children[i] == b) members |= 2;
    end
    proxy.get_immediate_children(a, leaves); proxy.get_immediate_children(a_leaf, empty);
    $display("UT: root_children %0d members %0d leaf_children %0d", children.size(), members,
    empty.size());
    $display("UT: child_children %0d exact_leaf %0d", leaves.size(), leaves.size() == 1 &&
    leaves[0] == a_leaf);

    $finish;
  end

endmodule
