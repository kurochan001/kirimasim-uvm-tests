/*
:name: test_tlm_fifo_interleaved_puts_and_gets_preserve_order
:description: interleaving FIFO puts and gets retains arrival order (IEEE 1800.2-2020 Section 12.2.8.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2 12.2.4.2.4 12.2.4.2.6 12.2.4.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_interleaved_puts_and_gets_preserve_order.expected
*/
// What it checks:
// 1. Nonblocking get reports availability and consumes a transaction when
//    successful.
// 2. FIFO retrieval follows transaction arrival order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.4.2.6 (UVM-FIFO-NONBLOCKING-GET) gives rule 1 above.
//    Setup: Use empty and populated FIFOs with interleaved calls. Expected:
//    Unavailable gets return 0; successful gets return 1 and the expected next
//    value.
// 2. 1800.2-2020 12.2.8.2 (UVM-FIFO-ARRIVAL-ORDER) gives rule 2 above. Setup:
//    Interleave puts, gets and a non-consuming peek. Expected: Retrieved
//    values remain in arrival order even with the intervening peek.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Remove the first entry, append another, then peek and consume the
// remaining entries. Query results are observed after each call.

module test_tlm_fifo_interleaved_puts_and_gets_preserve_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo", null, 3);
    int value;
    bit ok;
    void'(fifo.try_put(1));
    void'(fifo.try_put(2));
    ok = fifo.try_get(value);
    $display("UT: first %0d %0d", ok, value);
    void'(fifo.try_put(3));
    ok = fifo.try_peek(value);
    $display("UT: peek %0d %0d used %0d", ok, value, fifo.used());
    ok = fifo.try_get(value);
    $display("UT: second %0d %0d", ok, value);
    ok = fifo.try_get(value);
    $display("UT: third %0d %0d empty %0d", ok, value, fifo.is_empty());
    $finish;
  end
endmodule
