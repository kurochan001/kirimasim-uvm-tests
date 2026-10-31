/*
:name: test_printer_explicit_policy_supersedes_default
:description: an explicit object printer supersedes the installed default printer (IEEE 1800.2-2020 Section 16.2.2.2)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.2.2 16.2.2.3 16.2.5.11 5.3.6.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_explicit_policy_supersedes_default.expected
*/
// Send one print through the default and another through an explicit
// printer. Each emits its own payload into a separate controlled file.

module test_printer_explicit_policy_supersedes_default;
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
    automatic capturing_printer default_policy = new("default_policy");
    automatic capturing_printer explicit_policy = new("explicit_policy");
    automatic uvm_printer saved = uvm_printer::get_default();
    automatic printable value = new;
    int default_fd;
    int explicit_fd;
    string default_line;
    string explicit_line;
    default_fd = $fopen("printer-default.txt", "w");
    explicit_fd = $fopen("printer-explicit.txt", "w");
    if (!default_fd || !explicit_fd) $fatal(1, "cannot open printer output");
    default_policy.set_file(default_fd);
    explicit_policy.set_file(explicit_fd);
    uvm_printer::set_default(default_policy);
    value.payload = 7;
    value.print();
    value.payload = 11;
    value.print(explicit_policy);
    uvm_printer::set_default(saved);
    $fclose(default_fd);
    $fclose(explicit_fd);
    default_line = read_first_line("printer-default.txt");
    explicit_line = read_first_line("printer-explicit.txt");
    $display("UT: default emission %0d explicit emission %0d", default_line == "payload=7\n",
             explicit_line == "payload=11\n");
    $display("UT: restored default %0d", uvm_printer::get_default() == saved);
    $finish;
  end
endmodule
