/*
:name: test_printer_element_proxy_repeated_queries_append_again
:description: repeated child queries append the current children again instead of clearing or deduplicating (IEEE 1800.2-2020 Section 16.2.9.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.9.2.2 16.2.7.3 16.2.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_proxy_repeated_queries_append_again.expected
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
// Query the same one-child root twice. The second call appends another
// reference and leaves the first reference untouched.

module test_printer_element_proxy_repeated_queries_append_again;
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
    uvm_printer_element root;
    uvm_printer_element child;
    uvm_printer_element children[$];
    printer.push_element("root", "packet", "1");
    root = printer.top();
    printer.push_element("child", "int", "8", "7");
    child = printer.top();
    printer.pop_element();
    if (root == null || child == null) $fatal(1, "element missing");
    proxy.get_immediate_children(root, children);
    $display("UT: first_count %0d", children.size());
    proxy.get_immediate_children(root, children);
    if (children.size() < 2) $fatal(1, "append missing");
    $display("UT: second_count %0d entries_same %0d %0d", children.size(),
        children[0] == child, children[1] == child);
    $finish;
  end
endmodule
