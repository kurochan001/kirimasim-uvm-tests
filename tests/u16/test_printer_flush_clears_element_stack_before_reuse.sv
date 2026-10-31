/*
:name: test_printer_flush_clears_element_stack_before_reuse
:description: printer flush clears both stack endpoints before a new root is pushed (IEEE 1800.2-2020 Section 16.2.4.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.4.2 16.2.7.1 16.2.7.2 16.2.7.3 16.2.8.2.3 16.2.8.2.4 16.2.8.2.5 16.2.8.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_flush_clears_element_stack_before_reuse.expected
*/
// Do not inspect any element handle obtained before flush: the printer
// may recycle it. Inspect only the currently returned element after reuse.

module test_printer_flush_clears_element_stack_before_reuse;
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
    uvm_printer_element current;
    printer.push_element("old_root", "packet", "1", "old");
    printer.push_element("old_child", "int", "32", "7");
    printer.flush();
    $display("UT: flushed_empty %0d %0d", printer.top() == null, printer.bottom() == null);
    printer.push_element("fresh", "frame", "2", "new");
    current = printer.top();
    if (current == null) $fatal(1, "new element not created");
    $display("UT: fresh %s %s %s %s root_same %0d", current.get_element_name(),
        current.get_element_type_name(),
             current.get_element_size(), current.get_element_value(), current == printer.bottom());
    printer.flush();
    $display("UT: second_flush_empty %0d %0d", printer.top() == null, printer.bottom() == null);
    $finish;
  end
endmodule
