/*
:name: test_tlm_fifo_blocking_get_waits_until_put
:description: a blocking FIFO get waits for an entry then consumes it (IEEE 1800.2-2020 Section 12.2.4.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.1 12.2.4.2.2 12.2.8.2 12.2.8.2.3 12.2.8.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_blocking_get_waits_until_put.expected
*/
// What it checks:
// Blocking get waits for an available transaction and consumes it.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.4.2.2 (UVM-FIFO-BLOCKING-GET) gives the rule above. Setup:
// Start get on an empty FIFO, then put value 7 after a positive delay.
// Expected: Get blocks initially, then returns 7 and leaves the FIFO empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Keep shared state in the test object. A producer waits a positive
// delay before observing the blocked reader and providing one entry.

module test_tlm_fifo_blocking_get_waits_until_put;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_fifo#(int) fifo;
    int value = 0;
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      fifo = new("fifo", this, 1);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin fifo.get(value); returned = 1; end
        begin
          #1;
          $display("UT: waiting returned %0d used %0d", returned, fifo.used());
          fifo.put(7);
        end
      join
      $display("UT: completed returned %0d value %0d empty %0d", returned, value, fifo.is_empty());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
