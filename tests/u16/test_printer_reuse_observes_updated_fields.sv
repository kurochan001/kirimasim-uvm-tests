/*
:name: test_printer_reuse_observes_updated_fields
:description: successive sprint operations observe current object values (IEEE 1800.2-2020 Section 16.2.3.9)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.3.1 16.2.3.9 16.2.4.1 5.3.6.2 5.3.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_reuse_observes_updated_fields.expected
*/
// Reusing an explicit printer must dispatch the object print hook on
// each call. The second operation observes the updated payload.

module test_printer_reuse_observes_updated_fields;
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
  automatic printable item = new;
  automatic capturing_printer printer = new;
  string text;
  item.payload = 11;
  text = item.sprint(printer);
  $display("UT: first %0d calls %0d", printer.field_value, printer.calls);
  item.payload = 72;
  text = item.sprint(printer);
  $display("UT: second %0d calls %0d", printer.field_value, printer.calls);
  $finish;
end
endmodule
