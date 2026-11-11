/*
:name: test_printer_file_receives_custom_emission
:description: object print writes the selected printer emission to its configured file (IEEE 1800.2-2020 Section 16.2.5.11)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.5.11 16.2.4.1 5.3.6.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_file_receives_custom_emission.expected
*/
// What it checks:
// The printer file setting selects where object print output is directed.
//
// How the expected output follows from the standard:
// 1800.2-2020 16.2.5.11 (UVM-PRINTER-OUTPUT-FILE) gives the rule above. Setup:
// Use an open file and a custom printer with deterministic complete emission
// text. Expected: The selected handle is retained and receives the custom
// emission.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A custom printer controls the complete emitted string. Check its file
// content without depending on any built-in printer layout.

module test_printer_file_receives_custom_emission;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class capturing_printer extends uvm_printer;
    `uvm_object_utils(capturing_printer)
    int observed = 0;
    function new(string name="capturing_printer"); super.new(name); endfunction
    function void print_field_int(string name, uvm_integral_t value, int size,
                                 uvm_radix_enum radix=UVM_NORADIX,
                                 byte scope_separator=".", string type_name="");
      observed = int'(value);
    endfunction
    function string emit();
      return $sformatf("payload=%0d\n", observed);
    endfunction
  endclass
  class printable extends uvm_object;
    `uvm_object_utils(printable)
    int payload = 0;
    function new(string name="printable"); super.new(name); endfunction
    function void do_print(uvm_printer printer);
      super.do_print(printer);
      printer.print_field_int("payload", payload, 32, UVM_DEC);
    endfunction
  endclass
  function automatic string read_first_line(string filename);
    int fd;
    int count;
    string line;
    fd = $fopen(filename, "r");
    if (!fd) $fatal(1, "cannot read printer output");
    count = $fgets(line, fd);
    $fclose(fd);
    if (!count) $fatal(1, "empty printer output");
    return line;
  endfunction

  initial begin
    automatic capturing_printer printer = new;
    automatic printable value = new;
    int fd;
    string line;
    fd = $fopen("printer-output.txt", "w");
    if (!fd) $fatal(1, "cannot open printer output");
    printer.set_file(fd);
    value.payload = 7;
    $display("UT: selected file %0d", printer.get_file() == fd);
    value.print(printer);
    $fclose(fd);
    line = read_first_line("printer-output.txt");
    $display("UT: file emission %0d", line == "payload=7\n");
    $finish;
  end
endmodule
