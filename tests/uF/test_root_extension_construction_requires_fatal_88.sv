/*
:name: test_root_extension_construction_requires_fatal_88
:description: root extension construction requires fatal checks independently derived public observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.7.2.1 F.7.2.2 6.6.5 6.6.3.2 1800-2023 6.21 8.18 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_root_extension_construction_requires_fatal_88.expected
*/
// What it checks:
// It is a control: it supports the setup or conditions of this duty, which
// other tests check directly:
// Constructing a root extension after the singleton exists generates a fatal.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.7.2.1 (UVM-ROOT-EXTENSION-FATAL-88) gives the rule above.
// Setup: Use the supplied non-public root constructor from an external scope
// or from a minimal original subtype after obtaining the singleton. A global
// fatal observer returns THROW. A positive-time extension control observes
// fatal production/termination without requiring absence of same-time
// constructor return; the stricter original return probe is control-only.
// Expected: An attempted extension produces fatal and does not reach later
// positive-time activity.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_root_extension_construction_requires_fatal_88;
  timeunit 1ns; timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam string CASE_NAME="root_extension_construction_requires_fatal";
  bit attempted=0,fatal_seen=0,returned=0;
  uvm_root existing;
  class original_extension88 extends uvm_root;
    function new(); super.new(); endfunction
  endclass
  class observer88 extends uvm_report_catcher;
    function new(); super.new("observer88"); endfunction
    virtual function action_e catch();
      if (get_severity()==UVM_FATAL) begin
        fatal_seen=1;
        $display("UT: ctor88 extension_fatal attempted %0d existing_root %0d",
          attempted,existing!=null);
      end
      return THROW;
    endfunction
  endclass
  initial begin
    automatic observer88 observer=new();
    original_extension88 extension_handle;
    existing=uvm_root::get(); uvm_report_cb::add(null,observer);
    $display("UT: ctor88 ready %0d",existing!=null);
    attempted=1; extension_handle=new(); returned=1;
    $finish;
  end
  final $display("UT: ctor88 final fatal %0d returned %0d",fatal_seen,returned);
  initial begin #5000; $fatal(1,"root or predictor88 watchdog"); end
endmodule
