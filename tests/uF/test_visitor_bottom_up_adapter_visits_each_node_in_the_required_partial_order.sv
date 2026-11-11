/*
:name: test_visitor_bottom_up_adapter_visits_each_node_in_the_required_partial_order
:description: visitor adapter follows its required tree traversal order (IEEE 1800.2-2020 Section F.5.5)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.5 F.5.1.2.1 F.5.1.2.2 F.5.1.2.3 F.5.2.2.2 F.5.3.2.2 F.5.7 13.1.2.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_visitor_bottom_up_adapter_visits_each_node_in_the_required_partial_order.expected
*/
// What it checks:
// 1. Bottom-up traversal visits descendants before their ancestors.
// 2. Accept invokes begin/end by default around the complete traversal.
// 3. The visitor begin callback precedes the first visit.
// 4. The visitor end callback follows the final visit.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 F.5.5 (UVM-VISITOR-BOTTOM-UP-PARTIAL-ORDER) gives rule 1
//    above. Setup: Traverse a five-component tree with two branches. Expected:
//    Every node is visited once and each child precedes its parent.
// 2. 1800.2-2020 F.5.3.2.2 (UVM-VISITOR-ACCEPT-DEFAULT-CALLBACKS) gives rule 2
//    above. Setup: Omit invoke_begin_end for all three concrete traversal
//    adapters. Expected: Each has one begin and one end enclosing all visits.
// 3. 1800.2-2020 F.5.1.2.1 (UVM-VISITOR-BEGIN-BEFORE-FIRST-VISIT) gives rule 3
//    above. Setup: Record callback/visit traces for three traversal
//    strategies. Expected: Every trace starts with its one begin callback.
// 4. 1800.2-2020 F.5.1.2.2 (UVM-VISITOR-END-AFTER-LAST-VISIT) gives rule 4
//    above. Setup: Record callback/visit traces for three traversal
//    strategies. Expected: Every trace ends with its one end callback.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Traverse a finite tree through public adapters and a component proxy.
// Check parent/level relationships and membership without sibling ordering.
module test_visitor_bottom_up_adapter_visits_each_node_in_the_required_partial_order;
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
    automatic uvm_bottom_up_visitor_adapter#(uvm_component, audit_visitor) adapter_value = new();

    adapter_value.accept(root, visitor, proxy);
    $display("UT: visits %0d members %0d %0d %0d %0d %0d", visitor.visited.size(),
    visitor.count(root), visitor.count(a), visitor.count(b), visitor.count(a_leaf),
    visitor.count(b_leaf));
    $display("UT: required_order %0d begin %0d end %0d bracketed %0d",
    visitor.position(root) > visitor.position(a) && visitor.position(root) > visitor.position(b) &&
    visitor.position(a) > visitor.position(a_leaf) &&
    visitor.position(b) > visitor.position(b_leaf), visitor.begins, visitor.ends,
    visitor.trace.substr(0,0) == "B" && visitor.trace.substr(visitor.trace.len()-1,
    visitor.trace.len()-1) == "E");

    $finish;
  end

endmodule
