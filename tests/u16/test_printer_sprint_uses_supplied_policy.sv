/*
:name: test_printer_sprint_uses_supplied_policy
:description: sprint passes the object field to the supplied printer (IEEE 1800.2-2020 Section 16.2.3.9)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.3.1 16.2.3.9 16.2.4.1 5.3.6.2 5.3.6.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_sprint_uses_supplied_policy.expected
*/
// A custom printer captures the inputs instead of relying on a built-in
// text layout. sprint returns the string produced by that printer.

module test_printer_sprint_uses_supplied_policy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class capturing_printer extends uvm_printer;
    `uvm_object_utils(capturing_printer)
  string field_name;
  uvm_integral_t field_value;
  int field_size;
    int calls = 0;
    function new(string name="capture"); super.new(name); endfunction
  function void print_field_int(string name, uvm_integral_t value, int size,
                               uvm_radix_enum radix=UVM_NORADIX,
                               byte scope_separator=".", string type_name="");
    field_name = name;
    field_value = value;
    field_size = size;
    calls++;
  endfunction
  function string emit(); return "captured"; endfunction
endclass
class printable extends uvm_object;
    `uvm_object_utils(printable)
  int payload;
    function new(string name="printable"); super.new(name); endfunction
  function void do_print(uvm_printer printer);
    printer.print_field_int("payload", payload, 32, UVM_DEC);
  endfunction
endclass

initial begin
  printable item = new;
  capturing_printer printer = new;
  string text;
  item.payload = 46;
  text = item.sprint(printer);
  $display("UT: field %s value %0d size %0d", printer.field_name,
           printer.field_value, printer.field_size);
  $display("UT: calls %0d text %s", printer.calls, text);
  $finish;
end
endmodule
