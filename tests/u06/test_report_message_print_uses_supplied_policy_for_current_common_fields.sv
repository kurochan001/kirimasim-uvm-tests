/*
:name: test_report_message_print_uses_supplied_policy_for_current_common_fields
:description: report message print uses supplied policy for current common fields
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.2.3 6.2.4.10 5.3.6.1 5.3.6.2 5.3.6.3 16.2.4.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_print_uses_supplied_policy_for_current_common_fields.expected
*/
module test_report_message_print_uses_supplied_policy_for_current_common_fields;
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
      foreach (numbers[i]) if (numbers[i]==token) return 1;
      return 0;
    endfunction
  endclass
  initial begin
    automatic uvm_report_message msg = new("message");
    automatic capture_printer printer = new();
    string text;
    msg.set_report_message(UVM_WARNING,"idFirst42","bodyFirst42",17,"fileFirst42.sv",41,
                           "contextFirst42");
    text = msg.sprint(printer);
    $display("UT: message_print_first id %0d body %0d file %0d context %0d line %0d text %0d",
             printer.has_text("idFirst42"),printer.has_text("bodyFirst42"),
             printer.has_text("fileFirst42.sv"),printer.has_text("contextFirst42"),
             printer.has_number(41),text=="captured");
    msg.set_report_message(UVM_ERROR,"idNext42","bodyNext42",23,"fileNext42.sv",93,
                           "contextNext42");
    text = msg.sprint(printer);
    $display("UT: message_print_next id %0d body %0d line %0d old_id %0d old_body %0d text %0d",
             printer.has_text("idNext42"),printer.has_text("bodyNext42"),printer.has_number(93),
             printer.has_text("idFirst42"),printer.has_text("bodyFirst42"),text=="captured");
    $finish;
  end
endmodule
