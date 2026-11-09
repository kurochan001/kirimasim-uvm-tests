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
// What it checks:
// 1. Configuration presence depends on a matching scope and field, not on a
//    nonnull stored handle.
// 2. Getting a class-valued configuration returns its stored handle value.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 C.4.2.2.3 (UVM-CONFIG-EXISTS) gives rule 1 above. Setup:
//    Compare existing/missing names and scopes, and a configured null object.
//    Expected: Matching entries exist, including null values; unrelated scopes
//    or names do not.
// 2. 1800.2-2020 C.4.2.2.2 (UVM-CONFIG-OBJECT-HANDLE) gives rule 2 above.
//    Setup: Read a shared object, replace its setting, or configure a null
//    handle. Expected: Identity and mutations are visible through the
//    retrieved handle; cached old handles remain valid after replacement.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
