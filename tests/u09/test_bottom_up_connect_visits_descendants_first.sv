/*
:name: test_bottom_up_connect_visits_descendants_first
:description: a bottom-up connect phase visits a three-level chain from leaf to root (IEEE 1800.2-2020 Section 9.5)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.5 9.8.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_bottom_up_connect_visits_descendants_first.expected
*/
// What it checks:
// 1. Bottom-up function phases visit descendants before their ancestors.
// 2. Common phases preceding run execute at simulation time zero.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 9.5 (UVM-PHASE-BOTTOM-UP) gives rule 1 above. Setup: Use a
//    single component chain and inspect connect/common bottom-up callbacks.
//    Expected: Leaf/child callbacks precede their parent callbacks without
//    fixing sibling ordering.
// 2. 1800.2-2020 9.8.1 (UVM-PHASE-PRE-RUN-ZERO-TIME) gives rule 2 above.
//    Setup: Observe build and connect callbacks along a component chain.
//    Expected: Every selected callback reports time zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A bottom-up function phase runs on descendants before their ancestors.
// Each callback records its place in a chain and that time has not advanced.

module test_bottom_up_connect_visits_descendants_first;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class node extends uvm_component;
    `uvm_component_utils(node)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void connect_phase(uvm_phase phase);
    $display("UT: connect %s zero %0d", get_name(), $time == 0);
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  node middle;
  node last;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    middle = new("middle", this);
    last = new("last", middle);
  endfunction
  function void connect_phase(uvm_phase phase);
    $display("UT: connect test zero %0d", $time == 0);
  endfunction
endclass
initial run_test();
endmodule
