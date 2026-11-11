/*
:name: test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling
:description: printer integral values use selected radix prefix and honor prefix disabling
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.2.3.8 16.2.3.9 16.2.5.5 16.2.5.6 16.2.5.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling.expected
*/
// What it checks:
// 1. The wide integral print path preserves the selected 65-bit value.
// 2. The integral-int print path uses the explicitly selected binary radix.
// 3. An omitted integral radix uses the changed default radix.
// 4. Disabling radix emission omits the configured radix prefix.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.2.3.8 (UVM-PRINTER-AUDIT-WIDE-FIELD-RADIX-VALUE) gives
//    rule 1 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The custom
//    prefix is selected appropriately and the numeric payload round-trips
//    where asserted; the disabled case has no configured prefix.
// 2. 1800.2-2020 16.2.3.9 (UVM-PRINTER-AUDIT-FIELD-INT-EXPLICIT-RADIX) gives
//    rule 2 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The custom
//    prefix is selected appropriately and the numeric payload round-trips
//    where asserted; the disabled case has no configured prefix.
// 3. 1800.2-2020 16.2.5.7 (UVM-PRINTER-AUDIT-DEFAULT-RADIX-EMISSION) gives
//    rule 3 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The custom
//    prefix is selected appropriately and the numeric payload round-trips
//    where asserted; the disabled case has no configured prefix.
// 4. 1800.2-2020 16.2.5.5 (UVM-PRINTER-AUDIT-DISABLED-RADIX-EMISSION) gives
//    rule 4 above. Setup: Use the original selected fixtures and explicit API
//    arguments represented by the observation anchors. Expected: The custom
//    prefix is selected appropriately and the numeric payload round-trips
//    where asserted; the disabled case has no configured prefix.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_printer_integral_values_use_selected_radix_prefix_and_honor_prefix_disabling;
  import uvm_pkg::*;
  class stack_printer extends uvm_printer;
    int pushes=0,pops=0;
    uvm_printer_element latest;
    function uvm_printer_element top(); return get_top_element(); endfunction
    function uvm_printer_element bottom(); return get_bottom_element(); endfunction
    virtual function void push_element(string name,string type_name,string size,string value="");
      pushes++; super.push_element(name,type_name,size,value); latest=get_top_element();
    endfunction
    virtual function void pop_element(); pops++; super.pop_element(); endfunction
    virtual function string emit(); return ""; endfunction
  endclass
  function automatic bit starts(string text,string prefix);
    return text.len()>=prefix.len() && text.substr(0,prefix.len()-1)==prefix;
  endfunction
  initial begin
    automatic stack_printer printer=new();
    automatic uvm_bitstream_t wide='0;
    uvm_bitstream_t parsed;
    string value;
    int scanned;
    wide[64]=1; wide[7:0]='h2a;
    printer.push_element("root","object","","");
    printer.set_radix_string(UVM_HEX,"HEX42:"); printer.set_radix_string(UVM_BIN,"BIN42:");
    printer.set_radix_string(UVM_DEC,"DEC42:"); printer.set_default_radix(UVM_HEX);
    printer.print_field("wide",wide,65); value=printer.latest.get_element_value();
    parsed='0; scanned=$sscanf(value.substr(6,value.len()-1),"%h",parsed);
    $display("UT: radix_wide prefix %0d value %0d",starts(value,"HEX42:"),
             scanned==1 && parsed==wide);
    printer.print_field_int("narrow",42,8,UVM_BIN); value=printer.latest.get_element_value();
    parsed='0; scanned=$sscanf(value.substr(6,value.len()-1),"%b",parsed);
    $display("UT: radix_explicit prefix %0d value %0d",starts(value,"BIN42:"),
             scanned==1 && parsed==42);
    printer.set_default_radix(UVM_DEC); printer.print_field_int("default",42,8);
    value=printer.latest.get_element_value(); parsed='0;
    scanned=$sscanf(value.substr(6,value.len()-1),"%d",parsed);
    $display("UT: radix_changed_default prefix %0d value %0d",starts(value,"DEC42:"),
             scanned==1 && parsed==42);
    printer.set_radix_enabled(0); printer.print_field_int("disabled",42,8,UVM_HEX);
    value=printer.latest.get_element_value();
    $display("UT: radix_disabled prefix_absent %0d nonempty %0d",!starts(value,"HEX42:"),value!="");
    $finish;
  end
endmodule
