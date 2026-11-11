/*
:name: test_analysis_port_without_subscribers_accepts_write
:description: analysis port permits zero subscribers and a write with no recipients (IEEE 1800.2-2020 Section 12.2.10.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.1.3 12.2.10.1.4 5.5.2.6 5.5.2.7 5.5.2.12 6.5.1.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_port_without_subscribers_accepts_write.expected
*/
// What it checks:
// The analysis port permits zero receivers with an unbounded maximum.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.10.1.3 (UVM-TLM1-ANALYSIS-ZERO-SUBSCRIBERS) gives the rule
// above. Setup: Construct an unconnected analysis port and write after
// elaboration. Expected: Bounds are zero/minimum zero/maximum minus one and
// write returns without a new error.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect the constructor-defined connection bounds after elaboration.
// A write with no subscribers must return without a delivery error.

module test_analysis_port_without_subscribers_accepts_write;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(int) ap;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_report_server server = uvm_report_server::get_server();
      int errors;
      phase.raise_objection(this);
      $display("UT: bindings %0d minimum %0d maximum %0d", ap.size(), ap.min_size(), ap.max_size());
      errors = server.get_severity_count(UVM_ERROR);
      ap.write(17);
      $display("UT: write_returned 1 error_delta %0d",
          server.get_severity_count(UVM_ERROR) - errors);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
