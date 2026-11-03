/*
:name: test_object_do_print_virtual_hook_uses_each_supplied_policy_without_stale_state
:description: the virtual print hook reaches the current object and supplied policy (IEEE 1800.2-2020 Section 5.3.6.3)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.6.3 5.3.4.7 16.2.3.9 16.2.4.1 B.2.1.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_do_print_virtual_hook_uses_each_supplied_policy_without_stale_state.expected
*/
// Call the virtual UVM hook through a base-typed handle. The original
// printer captures public arguments; no formatted output or outer-print
// lifecycle
// is inferred from direct hook invocation.
module test_object_do_print_virtual_hook_uses_each_supplied_policy_without_stale_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class capture_printer extends uvm_printer;
    `uvm_object_utils(capture_printer)
    int calls = 0;
    uvm_integral_t value;
    int size;
    string field;
    function new(string name="printer"); super.new(name); endfunction
    virtual function void print_field_int(string name, uvm_integral_t datum, int width,
        uvm_radix_enum radix=UVM_NORADIX, byte scope_separator=".", string type_name="");
      calls++; value = datum; size = width; field = name;
    endfunction
    virtual function string emit(); return "unused"; endfunction
  endclass
  class printable extends uvm_object;
    `uvm_object_utils(printable)
    int payload;
    int hooks = 0;
    uvm_printer seen;
    function new(string name="item"); super.new(name); endfunction
    virtual function void do_print(uvm_printer printer);
      hooks++; seen = printer; printer.print_field_int("payload", payload, 8, UVM_HEX);
    endfunction
  endclass
  initial begin
    automatic printable item = new();
    automatic uvm_object base_handle = item;
    automatic capture_printer first = new("first");
    automatic capture_printer second = new("second");
    item.payload = 'h3c; base_handle.do_print(first);
    $display("UT: first hooks %0d calls %0d policy %0d value %0h size %0d field %s",
             item.hooks, first.calls, item.seen == first, first.value, first.size, first.field);
    item.payload = 'hc3; base_handle.do_print(second);
    $display("UT: second hooks %0d calls %0d policy %0d value %0h first_unchanged %0d",
             item.hooks, second.calls, item.seen == second, second.value,
             first.calls == 1 && first.value == 'h3c);
    $finish;
  end
endmodule
