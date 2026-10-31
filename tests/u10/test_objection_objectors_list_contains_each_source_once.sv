/*
:name: test_objection_objectors_list_contains_each_source_once
:description: the objector list has one entry per source regardless of count (IEEE 1800.2-2020 Section 10.5.1.5.1)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.5.1 10.5.1.3.3 10.5.1.5.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_objectors_list_contains_each_source_once.expected
*/
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
    uvm_objection objection = new("objection");
    item first = new("first");
    item second = new("second");
    uvm_object objectors[$];
    int first_seen = 0;
    int second_seen = 0;
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
