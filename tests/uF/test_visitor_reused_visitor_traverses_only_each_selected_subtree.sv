/*
:name: test_visitor_reused_visitor_traverses_only_each_selected_subtree
:description: reused visitor accumulates independent traversals of selected subtrees (IEEE 1800.2-2020 Section F.5.3.2.2)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.3.2.2 F.5.4 F.5.5 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.2.2 F.5.7 13.1.2.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_visitor_reused_visitor_traverses_only_each_selected_subtree.expected
*/
// What it checks:
// Each accept traverses its selected structure even when reusing a visitor.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.5.3.2.2 (UVM-VISITOR-ACCEPT-SELECTED-SUBTREE-REUSE) gives the
// rule above. Setup: Visit the whole tree top-down, then only branch a
// bottom-up with the same visitor. Expected: There are seven visits; only a
// and its leaf occur twice, with two begin/end pairs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Traverse a finite tree through public adapters and a component proxy.
// Check parent/level relationships and membership without sibling ordering.
module test_visitor_reused_visitor_traverses_only_each_selected_subtree;
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

    automatic uvm_top_down_visitor_adapter#(uvm_component, audit_visitor) down = new();
    automatic uvm_bottom_up_visitor_adapter#(uvm_component, audit_visitor) up = new();

    down.accept(root, visitor, proxy); up.accept(a, visitor, proxy);
    $display("UT: reused visits %0d begin %0d end %0d", visitor.visited.size(), visitor.begins,
    visitor.ends);
    $display("UT: subtree_members %0d %0d %0d %0d %0d", visitor.count(root), visitor.count(a),
    visitor.count(b), visitor.count(a_leaf), visitor.count(b_leaf));

    $finish;
  end

endmodule
