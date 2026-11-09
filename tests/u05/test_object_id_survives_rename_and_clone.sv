/*
:name: test_object_id_survives_rename_and_clone
:description: renaming preserves an object ID and cloning creates a distinct live ID (IEEE 1800.2-2020 Section 5.3.4.4)
:tags: u05 uvm
:type: simulation
:lrm: 1800.2-2020 5.3.4.4 5.3.4.1 5.3.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_object_id_survives_rename_and_clone.expected
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
// An ID remains unique to its object throughout its lifetime. Hold both
// handles so ID reuse after garbage collection cannot affect this check.

module test_object_id_survives_rename_and_clone;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic item source = new("before");
    uvm_object duplicate;
    automatic int saved_id = source.get_inst_id();
    source.set_name("after");
    duplicate = source.clone();
    $display("UT: renamed stable %0d", source.get_inst_id() == saved_id);
    $display("UT: clone distinct %0d source stable %0d",
             duplicate.get_inst_id() != source.get_inst_id(), source.get_inst_id() == saved_id);
    $finish;
  end
endmodule
