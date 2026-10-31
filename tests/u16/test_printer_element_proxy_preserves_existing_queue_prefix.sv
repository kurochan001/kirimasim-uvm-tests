/*
:name: test_printer_element_proxy_preserves_existing_queue_prefix
:description: printer element proxy appends children without changing an existing queue prefix (IEEE 1800.2-2020 Section 16.2.9.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.9.2.2 16.2.9.2.1 16.2.7.3 16.2.7.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_proxy_preserves_existing_queue_prefix.expected
*/
// Prefill the queue with duplicate sentinel handles. Existing values
// remain in place and both immediate children are appended in any order.

module test_printer_element_proxy_preserves_existing_queue_prefix;
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
    uvm_printer_element root;
    uvm_printer_element first;
    uvm_printer_element second;
    uvm_printer_element children[$];
    int first_count;
    int second_count;
    printer.push_element("root", "packet", "2");
    root = printer.top();
    printer.push_element("first", "int", "8", "1");
    first = printer.top();
    printer.pop_element();
    printer.push_element("second", "int", "8", "2");
    second = printer.top();
    printer.pop_element();
    if (root == null || first == null || second == null) $fatal(1, "element missing");
    children.push_back(sentinel);
    children.push_back(sentinel);
    proxy.get_immediate_children(root, children);
    if (children.size() < 2) $fatal(1, "queue prefix lost");
    first_count = 0;
    second_count = 0;
    foreach (children[i]) if (i >= 2) begin
      if (children[i] == first) first_count++;
      if (children[i] == second) second_count++;
    end
    $display("UT: default_name_empty %0d count %0d prefix %0d %0d appended %0d %0d",
        proxy.get_name() == "",
             children.size(), children[0] == sentinel, children[1] == sentinel,
                 first_count, second_count);
    $finish;
  end
endmodule
