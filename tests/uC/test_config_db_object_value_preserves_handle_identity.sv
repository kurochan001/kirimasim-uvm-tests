/*
:name: test_config_db_object_value_preserves_handle_identity
:description: a configured object value is retrieved as the same handle (IEEE 1800.2-2020 Section C.4.2.2.1)
:tags: uC uvm
:type: simulation
:lrm: 1800.2-2020 C.4.2.2.1 C.4.2.2.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_config_db_object_value_preserves_handle_identity.expected
*/
// What it checks:
// Getting a class-valued configuration returns its stored handle value.
//
// How the expected output follows from the standard:
// 1800.2-2020 C.4.2.2.2 (UVM-CONFIG-OBJECT-HANDLE) gives the rule above.
// Setup: Read a shared object, replace its setting, or configure a null
// handle. Expected: Identity and mutations are visible through the retrieved
// handle; cached old handles remain valid after replacement.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Setting a class value stores its handle. A later mutation of the
// original object is visible through a handle read from the configuration.

module test_config_db_object_value_preserves_handle_identity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    int payload = 0;
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item source = new("source");
    uvm_object result;
    item typed_result;
    bit found;
    source.payload = 7;
    uvm_config_db#(uvm_object)::set(null, "env", "packet", source);
    found = uvm_config_db#(uvm_object)::get(null, "env", "packet", result);
    if (!$cast(typed_result, result)) $fatal(1, "configured object type");
    source.payload = 29;
    $display("UT: found %0d same_handle %0d payload %0d", found, result == source,
        typed_result.payload);
    $finish;
  end
endmodule
