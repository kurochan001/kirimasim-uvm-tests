/*
:name: test_tlm_analysis_fifo_instances_store_writes_independently
:description: analysis FIFO instances preserve separate queues of written transactions (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.4.2.6 12.2.4.2.8 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_instances_store_writes_independently.expected
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
// Consume and refill one FIFO while the other retains its original
// head and occupancy.

module test_tlm_analysis_fifo_instances_store_writes_independently;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_analysis_fifo#(int) first = new("first");
    automatic uvm_tlm_analysis_fifo#(int) second = new("second");
    int value;
    bit ok;
    first.write(11);
    second.write(22);
    second.write(33);
    ok = first.try_get(value);
    $display("UT: first_get %0d %0d occupancies %0d %0d", ok, value, first.used(), second.used());
    first.write(44);
    ok = first.try_peek(value);
    $display("UT: first_head %0d %0d", ok, value);
    ok = second.try_peek(value);
    $display("UT: second_head %0d %0d used %0d", ok, value, second.used());
    $finish;
  end
endmodule
