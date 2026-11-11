/*
:name: test_objection_totals_propagate_to_parent
:description: child objections contribute to ancestor totals without local ancestor counts (IEEE 1800.2-2020 Section 10.5.1.3.3)
:tags: u10 uvm
:type: simulation
:lrm: 1800.2-2020 10.5.1.3.3 10.5.1.3.4 10.5.1.5.3 10.5.1.5.4 9.6
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_objection_totals_propagate_to_parent.expected
*/
// What it checks:
// Raising an objection increases the source count and propagated totals of its
// ancestors.
//
// How the expected output follows from the standard:
// 1800.2-2020 10.5.1.3.3 (UVM-OBJECTION-PROPAGATE) gives the rule above.
// Setup: A child raises one objection under a parent with no local objection.
// Expected: Child count is 1, parent local count is 0 and parent total is 1.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A child owns the local objection. Its parent sees the propagated total
// while the child waits, and extraction follows the child final drop.

module test_objection_totals_propagate_to_parent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class worker extends uvm_component;
    `uvm_component_utils(worker)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    uvm_objection objections = phase.get_objection();
    phase.raise_objection(this);
    $display("UT: child %0d parent local %0d total %0d",
             objections.get_objection_count(this), objections.get_objection_count(get_parent()),
             objections.get_objection_total(get_parent()));
    #4;
    phase.drop_objection(this);
  endtask
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  worker child;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase); child = new("child", this); endfunction
  function void extract_phase(uvm_phase phase);
    $display("UT: extract at four %0d", $time == 4);
  endfunction
endclass
initial run_test();
endmodule
