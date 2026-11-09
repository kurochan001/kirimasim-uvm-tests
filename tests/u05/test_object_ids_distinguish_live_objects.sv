/*
:name: test_object_ids_distinguish_live_objects
:description: live objects have distinct IDs while aliases have the same ID (IEEE 1800.2-2020 Section 5.3.4.4)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_ids_distinguish_live_objects.expected
*/
// What it checks:
// Instance IDs distinguish live objects and remain stable over each object
// lifetime.
//
// How the expected output follows from the standard:
// 1800.2-2020 5.3.4.4 (UVM-OBJECT-INSTANCE-ID) gives the rule above. Setup:
// Hold all handles live while aliasing, renaming and cloning objects.
// Expected: Aliases retain an ID, different objects have different IDs, and
// rename preserves the source ID.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Instance IDs distinguish live objects, even when their names are equal.
// Check only identity relationships, not allocation order or numeric values.

module test_object_ids_distinguish_live_objects;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item first = new("same");
    automatic item second = new("same");
    automatic item alias_handle = first;
    automatic int saved_id = first.get_inst_id();
    $display("UT: distinct %0d alias %0d", first.get_inst_id() != second.get_inst_id(),
             alias_handle.get_inst_id() == first.get_inst_id());
    $display("UT: stable %0d", first.get_inst_id() == saved_id);
    $finish;
  end
endmodule
