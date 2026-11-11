/*
:name: test_printer_element_stack_restores_parent_and_keeps_root
:description: printer element pop restores the parent and ignores a pop of the root element (IEEE 1800.2-2020 Section 16.2.7.1)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.7.1 16.2.7.2 16.2.7.3 16.2.7.4 16.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_element_stack_restores_parent_and_keeps_root.expected
*/
// What it checks:
// 1. Pushing an element makes it the top and creates a child of the previous
//    top when present.
// 2. Popping an element restores its parent, but popping the root is ignored.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.7.3 (UVM-PRINTER-ELEMENT-PUSH) gives rule 1 above.
//    Setup: Push root then child while exposing protected top/bottom queries.
//    Expected: The root remains bottom while the child becomes a distinct top.
// 2. 1800.2-2020 16.2.7.4 (UVM-PRINTER-ELEMENT-POP) gives rule 2 above. Setup:
//    Pop a child and then attempt to pop the root. Expected: The parent
//    returns as top and the root remains after the final ignored pop.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expose the protected top and bottom accessors through a test printer.
// Compare stack handles without depending on internal child representation.

module test_printer_element_stack_restores_parent_and_keeps_root;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class stack_printer extends uvm_printer;
    `uvm_object_utils(stack_printer)
    function new(string name="stack_printer"); super.new(name); endfunction
    function uvm_printer_element top(); return get_top_element(); endfunction
    function uvm_printer_element bottom(); return get_bottom_element(); endfunction
    function string emit(); return ""; endfunction
  endclass

  initial begin
    automatic stack_printer printer = new;
    uvm_printer_element root_element;
    $display("UT: initially_empty %0d %0d", printer.top() == null, printer.bottom() == null);
    printer.push_element("root", "packet", "1", "v");
    root_element = printer.top();
    if (root_element == null) $fatal(1, "root element not created");
    $display("UT: root_same %0d name %s", printer.bottom() == root_element,
        root_element.get_element_name());
    printer.push_element("child", "int", "32", "7");
    $display("UT: child_distinct %0d bottom_root %0d", printer.top() != root_element,
        printer.bottom() == root_element);
    printer.pop_element();
    $display("UT: parent_restored %0d", printer.top() == root_element);
    printer.pop_element();
    $display("UT: root_pop_ignored %0d %0d", printer.top() == root_element,
        printer.bottom() == root_element);
    $finish;
  end
endmodule
