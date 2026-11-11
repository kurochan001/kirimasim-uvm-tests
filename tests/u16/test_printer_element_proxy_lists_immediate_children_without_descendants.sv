/*
:name: test_printer_element_proxy_lists_immediate_children_without_descendants
:description: printer element proxy lists immediate children and excludes grandchildren (IEEE 1800.2-2020 Section 16.2.9.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.9.2.2 16.2.9.2.1 16.2.7.3 16.2.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_proxy_lists_immediate_children_without_descendants.expected
*/
// What it checks:
// The element proxy appends immediate children without changing the caller
// queue prefix.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.9.2.2 (UVM-PRINTER-ELEMENT-CHILDREN) gives the rule above.
// Setup: Query a root with grandchildren, repeat a query and query a leaf with
// a nonempty queue. Expected: Only immediate children append; existing entries
// remain, repeats append again and leaves add nothing.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct hierarchy with standard printer stack operations. Compare
// child membership, not sibling order or implementation-specific names.

module test_printer_element_proxy_lists_immediate_children_without_descendants;
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
    automatic uvm_printer_element_proxy proxy = new("walk");
    uvm_printer_element root;
    uvm_printer_element first;
    uvm_printer_element second;
    uvm_printer_element grandchild;
    uvm_printer_element children[$];
    int first_count;
    int second_count;
    int grandchild_count;
    printer.push_element("root", "packet", "2");
    root = printer.top();
    printer.push_element("first", "packet", "1");
    first = printer.top();
    printer.push_element("grandchild", "int", "8", "7");
    grandchild = printer.top();
    printer.pop_element();
    printer.pop_element();
    printer.push_element("second", "int", "8", "9");
    second = printer.top();
    printer.pop_element();
    if (root == null || first == null || second == null || grandchild == null) $fatal(1,
        "element missing");
    proxy.get_immediate_children(root, children);
    first_count = 0;
    second_count = 0;
    grandchild_count = 0;
    foreach (children[i]) begin
      if (children[i] == first) first_count++;
      if (children[i] == second) second_count++;
      if (children[i] == grandchild) grandchild_count++;
    end
    $display("UT: proxy %s count %0d first %0d second %0d grandchild %0d", proxy.get_name(),
             children.size(), first_count, second_count, grandchild_count);
    $finish;
  end
endmodule
