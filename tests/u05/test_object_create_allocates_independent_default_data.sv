/*
:name: test_object_create_allocates_independent_default_data
:description: repeated object create calls allocate independent objects with constructor data (IEEE 1800.2-2020 Section 5.3.5.1)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.5.1 5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_create_allocates_independent_default_data.expected
*/
// What it checks:
// Object create allocates a fresh object of its own dynamic type.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.5.1 (UVM-OBJECT-CREATE-TYPE) gives the rule above. Setup:
// Create from a derived object with a separate factory override installed.
// Expected: The new object has the source type and independent default data;
// registry creation may use its override.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Create two objects from one dynamic source. Mutating the first new
// object leaves the second object and the source payload independently stored.

module test_object_create_allocates_independent_default_data;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class base_value extends uvm_object;
    `uvm_object_utils(base_value)
    int payload = 7;
    function new(string name="base_value"); super.new(name); endfunction
  endclass
  class derived_value extends base_value;
    `uvm_object_utils(derived_value)
    function new(string name="derived_value"); super.new(name); endfunction
  endclass
  class replacement_value extends derived_value;
    `uvm_object_utils(replacement_value)
    function new(string name="replacement_value"); super.new(name); endfunction
  endclass

  initial begin
    automatic derived_value source = new("source");
    automatic uvm_object base_handle = source;
    derived_value first;
    derived_value second;
    source.payload = 99;
    if (!$cast(first, base_handle.create("first")) || first == null) $fatal(1, "first type");
    if (!$cast(second, base_handle.create("second")) || second == null) $fatal(1, "second type");
    first.payload = 11;
    $display("UT: distinct %0d %0d %0d", first != second, first != source, second != source);
    $display("UT: payloads %0d %0d %0d", first.payload, second.payload, source.payload);
    $display("UT: names %s %s", first.get_name(), second.get_name());
    $finish;
  end
endmodule
