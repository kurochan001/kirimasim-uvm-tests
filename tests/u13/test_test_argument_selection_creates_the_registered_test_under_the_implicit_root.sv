/*
:name: test_test_argument_selection_creates_the_registered_test_under_the_implicit_root
:description: test argument selection creates the registered test under the implicit root
:tags: u13 uvm
:type: simulation
:lrm: 1800.2-2020 13.2 F.7.3.1 13.2.1 13.2.2 13.1.2.1 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_test_argument_selection_creates_the_registered_test_under_the_implicit_root.expected
*/
// What it checks:
// A registered test selected by the run_test argument is instantiated as the
// root child uvm_test_top and executes its selected subtype.
//
// How the expected output follows from the standard:
// 1800.2-2020 13.2 (UVM-COMPONENT-EXT-TEST-ARGUMENT-SELECTION) gives the rule
// above. Setup: Use the linked original fixtures and their explicit public
// phase, factory or hierarchy calls. Preserve the declared original types,
// scope, arguments and expected observations; no private implementation state
// supplies an oracle. Expected: A registered test selected by the run_test
// argument is instantiated as the root child uvm_test_top and executes its
// selected subtype.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_test_argument_selection_creates_the_registered_test_under_the_implicit_root;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class selected_test47 extends uvm_test;
    `uvm_component_utils(selected_test47)
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    virtual task run_phase(uvm_phase phase);
      uvm_coreservice_t service;
      selected_test47 selected;
      phase.raise_objection(this); service=uvm_coreservice_t::get();
      $display("UT: argument_test name %0d parent %0d registered %0d selected_type %0d",
               get_name()=="uvm_test_top",get_parent()==service.get_root(),
               service.get_root().get_child("uvm_test_top")==this,
               $cast(selected,service.get_root().get_child("uvm_test_top")));
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("selected_test47");
  initial begin #100; $fatal(1,"test argument selection watchdog"); end
endmodule
