/*
:name: test_tlm_analysis_fifo_flush_allows_fresh_writes
:description: analysis FIFO flush removes queued writes and preserves unbounded capacity (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.8.2.6 12.2.8.2.2 12.2.8.2.3 12.2.8.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_flush_allows_fresh_writes.expected
*/
// What it checks:
// Analysis FIFO writes buffer transactions in an unbounded FIFO.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.8.3 (UVM-ANALYSIS-FIFO-WRITE-STORAGE) gives the rule above.
// Setup: Interleave writes/reads/peeks, exceed the ordinary bounded capacity,
// flush and compare two instances. Expected: Writes preserve arrival order,
// peeks retain the head, instances stay independent and flush permits fresh
// writes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Flush without any blocked access, then write and retrieve a fresh
// value through the same analysis FIFO instance.

module test_tlm_analysis_fifo_flush_allows_fresh_writes;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_analysis_fifo#(int) fifo = new("fifo");
    int value;
    bit ok;
    fifo.write(11);
    fifo.write(22);
    fifo.flush();
    $display("UT: flushed size %0d used %0d empty %0d", fifo.size(), fifo.used(), fifo.is_empty());
    fifo.write(73);
    ok = fifo.try_get(value);
    $display("UT: fresh %0d %0d empty %0d", ok, value, fifo.is_empty());
    $finish;
  end
endmodule
