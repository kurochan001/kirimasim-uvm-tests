/*
:name: test_tlm_fifo_repeated_try_peek_does_not_consume
:description: repeated FIFO peeks return the same entry without consuming it (IEEE 1800.2-2020 Section 12.2.4.2.8)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.8 12.2.4.2.6 12.2.4.2.9 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_repeated_try_peek_does_not_consume.expected
*/
// What it checks:
// Nonblocking peek reports availability without consuming a successful head
// observation.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.4.2.8 (UVM-FIFO-NONBLOCKING-PEEK) gives the rule above.
// Setup: Use empty queues and repeated peeks before a get. Expected: Empty
// peeks return 0; successful repeated peeks retain the same head and
// occupancy.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Compare peeked values with the following get and inspect occupancy
// before and after consumption.

module test_tlm_fifo_repeated_try_peek_does_not_consume;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo", null, 2);
    int first;
    int second;
    int removed;
    bit first_ok;
    bit second_ok;
    bit get_ok;
    void'(fifo.try_put(11));
    void'(fifo.try_put(22));
    first_ok = fifo.try_peek(first);
    second_ok = fifo.try_peek(second);
    $display("UT: peeks %0d %0d values %0d %0d used %0d can_peek %0d", first_ok, second_ok,
             first, second, fifo.used(), fifo.can_peek());
    get_ok = fifo.try_get(removed);
    $display("UT: get %0d value %0d used %0d", get_ok, removed, fifo.used());
    $finish;
  end
endmodule
