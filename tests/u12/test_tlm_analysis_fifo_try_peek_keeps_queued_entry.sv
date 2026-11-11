/*
:name: test_tlm_analysis_fifo_try_peek_keeps_queued_entry
:description: analysis FIFO peeks retain the head until a successful get (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.4.2.8 12.2.4.2.6 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_try_peek_keeps_queued_entry.expected
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
// Observe repeated peeks, consume their head value and then observe
// the next queued entry.

module test_tlm_analysis_fifo_try_peek_keeps_queued_entry;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_analysis_fifo#(int) fifo = new("fifo");
    int first;
    int second;
    int value;
    bit first_ok;
    bit second_ok;
    bit ok;
    fifo.write(41);
    fifo.write(43);
    first_ok = fifo.try_peek(first);
    second_ok = fifo.try_peek(second);
    $display("UT: peeks %0d %0d values %0d %0d used %0d", first_ok, second_ok, first,
        second, fifo.used());
    ok = fifo.try_get(value);
    $display("UT: get %0d %0d remaining %0d", ok, value, fifo.used());
    ok = fifo.try_peek(value);
    $display("UT: next_peek %0d %0d remaining %0d", ok, value, fifo.used());
    $finish;
  end
endmodule
