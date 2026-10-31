/*
:name: test_config_db_null_object_value_is_a_present_setting
:description: a null class value remains a present configuration entry (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 C.4.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_null_object_value_is_a_present_setting.expected
*/
// Entry presence is separate from the class handle value stored in it.
// Reading a configured null replaces the nonnull destination handle.

module test_config_db_null_object_value_is_a_present_setting;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item result = new("sentinel");
    bit found;
    uvm_config_db#(item)::set(null, "env", "packet", null);
    found = uvm_config_db#(item)::get(null, "env", "packet", result);
    $display("UT: exists %0d found %0d null_value %0d", uvm_config_db#(item)::exists(null,
        "env", "packet"),
             found, result == null);
    $finish;
  end
endmodule
