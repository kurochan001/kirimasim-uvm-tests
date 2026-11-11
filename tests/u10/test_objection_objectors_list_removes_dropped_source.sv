/*
:name: test_objection_objectors_list_removes_dropped_source
:description: dropping a source to zero removes it from the current objector list (IEEE 1800.2-2020 Section 10.5.1.5.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.1 10.5.1.3.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_objectors_list_removes_dropped_source.expected
*/
// What it checks:
// The objector list contains sources with outstanding local objections.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.5.1 (UVM-OBJECTION-OBJECTORS) gives the rule above.
// Setup: Two sources raise; the first drops its last objection. Expected: The
// list shrinks from two to one, retaining only the second source.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect source membership after one source drops its complete count.
// No expectation depends on asynchronous ancestor drain propagation.
// The pinned library retains the zero-count source until drain cleanup.
// Keep the immediate current-list expectation as a spec-only case.

module test_objection_objectors_list_removes_dropped_source;
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
    objection.raise_objection(first);
    objection.raise_objection(second);
    objection.get_objectors(objectors);
    $display("UT: before %0d", objectors.size());
    objection.drop_objection(first);
    objection.get_objectors(objectors);
    $display("UT: after %0d only_second %0d first_count %0d", objectors.size(),
             objectors.size() == 1 && objectors[0] == second,
             objection.get_objection_count(first));
    objection.clear();
    $finish;
  end
endmodule
