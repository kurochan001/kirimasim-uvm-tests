/*
:name: test_default_convert2string_is_empty_with_field_macros
:description: the default convert2string remains empty when fields use automation macros (IEEE 1800.2-2020 Section 5.3.6.4)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.6.4 B.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_convert2string_is_empty_with_field_macros.expected
*/
// What it checks:
// The unextended convert2string hook returns an empty string.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.6.4 (UVM-OBJECT-STRING-DEFAULT) gives the rule above. Setup:
// Change fields and name of an object using field macros without overriding
// the hook. Expected: The returned string remains empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Field automation does not replace the default virtual string hook.
// Change both payload and name and check the default return value again.

module test_default_convert2string_is_empty_with_field_macros;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    int payload = 17;
    `uvm_object_utils_begin(item)
      `uvm_field_int(payload, UVM_DEFAULT)
    `uvm_object_utils_end
    function new(string name="item"); super.new(name); endfunction
  endclass
  initial begin
    automatic item value = new("original");
    $display("UT: initial empty %0d", value.convert2string() == "");
    value.payload = 99;
    value.set_name("renamed");
    $display("UT: changed empty %0d", value.convert2string() == "");
    $finish;
  end
endmodule
