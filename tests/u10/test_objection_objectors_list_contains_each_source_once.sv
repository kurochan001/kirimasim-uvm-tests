/*
:name: test_objection_objectors_list_contains_each_source_once
:description: the objector list has one entry per source regardless of count (IEEE 1800.2-2020 Section 10.5.1.5.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.1 10.5.1.3.3 10.5.1.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_objectors_list_contains_each_source_once.expected
*/
// What it checks:
// The objector list identifies each outstanding source once rather than once
// per objection.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.5.1 (UVM-OBJECTION-OBJECTOR-UNIQUENESS) gives the rule
// above. Setup: Two sources raise different counts, 2 and 1. Expected: The
// list has two distinct sources while local counts remain 2 and 1.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Two objects raise different counts. Check list membership without
// assuming the iteration order of an implementation associative array.

module test_objection_objectors_list_contains_each_source_once;
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
    automatic int first_seen = 0;
    automatic int second_seen = 0;
    objection.raise_objection(first, "first", 2);
    objection.raise_objection(second);
    objection.get_objectors(objectors);
    foreach (objectors[i]) begin
      if (objectors[i] == first) first_seen++;
      if (objectors[i] == second) second_seen++;
    end
    $display("UT: list %0d first %0d second %0d", objectors.size(), first_seen, second_seen);
    $display("UT: counts %0d %0d", objection.get_objection_count(first),
             objection.get_objection_count(second));
    objection.clear();
    $finish;
  end
endmodule
