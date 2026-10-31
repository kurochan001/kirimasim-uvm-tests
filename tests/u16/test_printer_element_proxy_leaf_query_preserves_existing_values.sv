/*
:name: test_printer_element_proxy_leaf_query_preserves_existing_values
:description: querying a leaf adds no children and preserves any existing queue entries (IEEE 1800.2-2020 Section 16.2.9.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.9.2.2 16.2.7.3 16.2.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_proxy_leaf_query_preserves_existing_values.expected
*/
// The leaf is part of a hierarchy, but its parent is not its child.
// Query once with an existing entry and once with an empty queue.

module test_printer_element_proxy_leaf_query_preserves_existing_values;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class stack_printer extends uvm_printer;
    `uvm_object_utils(stack_printer)
    function new(string name="stack_printer"); super.new(name); endfunction
    function uvm_printer_element top(); return get_top_element(); endfunction
    function string emit(); return ""; endfunction
  endclass

  initial begin
    automatic stack_printer printer = new;
    automatic uvm_printer_element_proxy proxy = new;
    automatic uvm_printer_element sentinel = new("sentinel");
    uvm_printer_element leaf;
    uvm_printer_element children[$];
    printer.push_element("root", "packet", "1");
    printer.push_element("leaf", "int", "8", "7");
    leaf = printer.top();
    printer.pop_element();
    if (leaf == null) $fatal(1, "leaf missing");
    children.push_back(sentinel);
    proxy.get_immediate_children(leaf, children);
    if (children.size() < 1) $fatal(1, "queue prefix lost");
    $display("UT: retained_count %0d sentinel_same %0d", children.size(), children[0] == sentinel);
    children.delete();
    proxy.get_immediate_children(leaf, children);
    $display("UT: empty_count %0d", children.size());
    $finish;
  end
endmodule
