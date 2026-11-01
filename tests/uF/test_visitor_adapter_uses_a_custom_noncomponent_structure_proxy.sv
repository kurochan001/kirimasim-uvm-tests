/*
:name: test_visitor_adapter_uses_a_custom_noncomponent_structure_proxy
:description: visitor adapter traverses custom object nodes through the supplied proxy (IEEE 1800.2-2020 Section F.5.4)
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.5.4 F.5.1.2.3 F.5.2.2.2 F.5.3.2.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_visitor_adapter_uses_a_custom_noncomponent_structure_proxy.expected
*/
// Generic object nodes, a custom proxy and public visitor dispatch only.
// Tree construction is fixture code; the adapter supplies traversal.
module test_visitor_adapter_uses_a_custom_noncomponent_structure_proxy;
  import uvm_pkg::*;

  class tree_node extends uvm_object;
    tree_node children[$];
    function new(string name="node"); super.new(name); endfunction
  endclass
  class tree_proxy extends uvm_structure_proxy#(tree_node);
    int calls = 0;
    function new(); super.new("proxy"); endfunction
    virtual function void get_immediate_children(tree_node s, ref tree_node children[$]);
      calls++; children = s.children;
    endfunction
  endclass
  class tree_visitor extends uvm_visitor#(tree_node);
    tree_node visited[$];
    function new(); super.new("visitor"); endfunction
    virtual function void visit(tree_node node); visited.push_back(node); endfunction
    function int position(tree_node node);
      foreach (visited[i]) if (visited[i] == node) return i;
      return -1;
    endfunction
  endclass
  initial begin
    automatic tree_node root = new("root");
    automatic tree_node a = new("a");
    automatic tree_node b = new("b");
    automatic tree_node leaf = new("leaf");
    automatic tree_proxy proxy = new();
    automatic tree_visitor visitor = new();
    automatic uvm_top_down_visitor_adapter#(tree_node, tree_visitor) adapter_value = new();
    root.children.push_back(a); root.children.push_back(b); a.children.push_back(leaf);
    adapter_value.accept(root, visitor, proxy);
    $display("UT: custom visits %0d all_present %0d proxy_used %0d", visitor.visited.size(),
    visitor.position(root) >= 0 && visitor.position(a) >= 0 && visitor.position(b) >= 0 &&
    visitor.position(leaf) >= 0, proxy.calls > 0);
    $display("UT: custom_parent_order %0d", visitor.position(root) < visitor.position(a) &&
    visitor.position(root) < visitor.position(b) && visitor.position(a) < visitor.position(leaf));
    $finish;
  end

endmodule
