/*
:name: test_convert2string_dispatches_through_base_handle
:description: a user-defined convert2string override is selected through a base object handle (IEEE 1800.2-2020 Section 5.3.6.4)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.6.4 5.3.4.1 5.3.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_convert2string_dispatches_through_base_handle.expected
*/
// The fixture defines its own text layout. A base handle observes the
// updated object fields through virtual dispatch without invoking a printer.

module test_convert2string_dispatches_through_base_handle;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class formatted_value extends uvm_object;
    `uvm_object_utils(formatted_value)
    int payload = 0;
    function new(string name="formatted_value"); super.new(name); endfunction
    function string convert2string();
      return $sformatf("name=%s payload=%0d", get_name(), payload);
    endfunction
  endclass
  initial begin
    automatic formatted_value value = new("original");
    automatic uvm_object base_handle = value;
    value.payload = 3;
    $display("UT: first %s", base_handle.convert2string());
    value.payload = 29;
    value.set_name("renamed");
    $display("UT: changed %s", base_handle.convert2string());
    $finish;
  end
endmodule
