/*
:name: test_report_handler_print_uses_supplied_policy_for_current_configuration
:description: report handler print uses supplied policy for current configuration
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.2.2 6.4.3.2 6.4.3.3 5.3.6.1 5.3.6.2 5.3.6.3 16.2.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_print_uses_supplied_policy_for_current_configuration.expected
*/
// What it checks:
// 1. A report handler supplies its selected current verbosity configuration to
//    the printing policy.
// 2. A repeated handler print reflects the changed general threshold while
//    retaining the configured ID threshold.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.2.2 (UVM-PRINTER-AUDIT-HANDLER-CURRENT-CONFIG) gives rule
//    1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The supplied
//    observer sees the selected original field/configuration values and sprint
//    returns its custom emission marker; the second print has current values
//    without the stale selected value.
// 2. 1800.2-2020 6.4.2.2 (UVM-PRINTER-AUDIT-HANDLER-UPDATED-CONFIG) gives rule
//    2 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The supplied
//    observer sees the selected original field/configuration values and sprint
//    returns its custom emission marker; the second print has current values
//    without the stale selected value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_handler_print_uses_supplied_policy_for_current_configuration;
  import uvm_pkg::*;
  // Inspect supplied policy inputs, not implementation field names or a
  // built-in text layout. Original capture formatting is setup only.
  class capture_printer extends uvm_printer;
    string texts[$];
    uvm_bitstream_t numbers[$];
    virtual function void flush();
      super.flush(); texts.delete(); numbers.delete();
    endfunction
    virtual function void push_element(string name, string type_name, string size, string value="");
      texts.push_back(name); texts.push_back(value); super.push_element(name,type_name,size,value);
    endfunction
    virtual function void print_string(string name, string value, byte scope_separator=".");
      texts.push_back(value); super.print_string(name,value,scope_separator);
    endfunction
    virtual function void print_field_int(string name, uvm_integral_t value, int size,
         uvm_radix_enum radix=UVM_NORADIX, byte scope_separator=".", string type_name="");
      numbers.push_back(value);
      super.print_field_int(name,value,size,radix,scope_separator,type_name);
    endfunction
    virtual function void print_field(string name, uvm_bitstream_t value, int size,
         uvm_radix_enum radix=UVM_NORADIX, byte scope_separator=".", string type_name="");
      numbers.push_back(value); super.print_field(name,value,size,radix,scope_separator,type_name);
    endfunction
    virtual function string emit(); return "captured"; endfunction
    function bit has_text(string token);
      foreach (texts[k])
        for (int i=0; i+token.len()<=texts[k].len(); i++)
          if (texts[k].substr(i,i+token.len()-1)==token) return 1;
      return 0;
    endfunction
    function bit has_number(uvm_bitstream_t token);
      uvm_bitstream_t parsed;
      foreach (numbers[i]) if (numbers[i]==token) return 1;
      // Generic fields may already carry a decimal string representation.
      foreach (texts[i])
        if ($sscanf(texts[i],"%d",parsed)==1 && parsed==token) return 1;
      return 0;
    endfunction
  endclass
  initial begin
    automatic uvm_report_handler handler = new("handler");
    automatic capture_printer printer = new();
    string text;
    handler.set_verbosity_level(137); handler.set_id_verbosity("selected42",73);
    text = handler.sprint(printer);
    $display("UT: handler_print_first general %0d id %0d threshold %0d text %0d",
             printer.has_number(137),printer.has_text("selected42"),printer.has_number(73),
             text=="captured");
    handler.set_verbosity_level(419); text = handler.sprint(printer);
    $display("UT: handler_print_next general %0d old %0d id %0d threshold %0d text %0d",
             printer.has_number(419),printer.has_number(137),printer.has_text("selected42"),
             printer.has_number(73),text=="captured");
    $finish;
  end
endmodule
