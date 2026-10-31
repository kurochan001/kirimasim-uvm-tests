/*
:name: test_build_phase_visits_new_descendants
:description: children created during build participate in build at time zero (IEEE 1800.2-2020 Section 9.8.1)
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.8.1 9.8.1.1 9.7.2.2 13.1.4.1.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +UVM_TESTNAME=t
:expected_stdout: @test_build_phase_visits_new_descendants.expected
*/
// Build can create children which are then built. A single chain avoids
// any dependency on the order in which siblings are visited.

module test_build_phase_visits_new_descendants;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class leaf extends uvm_component;
    `uvm_component_utils(leaf)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    $display("UT: build leaf zero %0d", $time == 0);
  endfunction
endclass
class branch extends uvm_component;
    `uvm_component_utils(branch)
  leaf node;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    $display("UT: build branch zero %0d", $time == 0);
    node = new("node", this);
  endfunction
endclass
class t extends uvm_test;
  `uvm_component_utils(t)
  branch middle;
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  function void build_phase(uvm_phase phase);
    $display("UT: build test zero %0d", $time == 0);
    middle = new("middle", this);
  endfunction
endclass
initial run_test();
endmodule
