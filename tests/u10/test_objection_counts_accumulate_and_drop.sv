/*
:name: test_objection_counts_accumulate_and_drop
:description: multiple objections keep run alive until their last drop (IEEE 1800.2-2020 Section 10.5.1.3.3)
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
:expected_stdout: @test_objection_counts_accumulate_and_drop.expected
*/
// Raising by a count increments the local and total objections. A partial
// drop retains the phase; extract starts only after the final drop.

module test_objection_counts_accumulate_and_drop;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

class t extends uvm_test;
  `uvm_component_utils(t)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    uvm_objection objections = phase.get_objection();
    phase.raise_objection(this, "two pending", 2);
    $display("UT: raised local %0d total %0d", objections.get_objection_count(this),
             objections.get_objection_total(this));
    #2;
    phase.drop_objection(this);
    $display("UT: partial local %0d total %0d", objections.get_objection_count(this),
             objections.get_objection_total(this));
    #3;
    phase.drop_objection(this);
  endtask
  function void extract_phase(uvm_phase phase);
    $display("UT: extract at five %0d", $time == 5);
  endfunction
endclass
initial run_test();
endmodule
