/*
:name: test_objection_clear_argument_does_not_limit_reset
:description: the clear argument has no functional effect and the objection can be reused (IEEE 1800.2-2020 Section 10.5.1.3.5)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.5 10.5.1.3.3 10.5.1.5.3 10.5.1.5.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_objection_clear_argument_does_not_limit_reset.expected
*/
// Passing one source to clear still resets every source. A subsequent
// raise starts a fresh count without inheriting any cleared total.

module test_objection_clear_argument_does_not_limit_reset;
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
    objection.raise_objection(first, "first", 2);
    objection.raise_objection(second, "second", 3);
    objection.clear(first);
    $display("UT: after clear %0d %0d total %0d", objection.get_objection_count(first),
             objection.get_objection_count(second), objection.get_objection_total());
    objection.raise_objection(second);
    $display("UT: reused %0d %0d total %0d", objection.get_objection_count(first),
             objection.get_objection_count(second), objection.get_objection_total());
    objection.clear();
    $finish;
  end
endmodule
