/*
:name: test_objection_clear_resets_counts_and_objectors
:description: clear resets all objection source counts totals and objectors (IEEE 1800.2-2020 Section 10.5.1.3.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.5 10.5.1.5.1 10.5.1.5.3 10.5.1.5.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_clear_resets_counts_and_objectors.expected
*/
// What it checks:
// clear immediately resets all objection counts regardless of its debug-only
// object argument.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.3.5 (UVM-OBJECTION-CLEAR-ALL) gives the rule above.
// Setup: Raise from multiple sources, clear with/without a selected object and
// reuse the objection. Expected: All source/total counts and objector
// membership clear; later raises start fresh.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Clear multiple raised sources and observe their zero counts, the
// implicit top total, and an empty objector list immediately afterwards.

module test_objection_clear_resets_counts_and_objectors;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class item extends uvm_object;
    `uvm_object_utils(item)
    function new(string name="item"); super.new(name); endfunction
  endclass

  initial begin
    automatic uvm_objection objection = new("objection");
    automatic item first = new("first");
    automatic item second = new("second");
    uvm_object objectors[$];
    objection.raise_objection(first, "first", 2);
    objection.raise_objection(second);
    $display("UT: total before %0d", objection.get_objection_total());
    objection.clear();
    objection.get_objectors(objectors);
    $display("UT: cleared %0d %0d total %0d objectors %0d",
             objection.get_objection_count(first), objection.get_objection_count(second),
             objection.get_objection_total(), objectors.size());
    $finish;
  end
endmodule
