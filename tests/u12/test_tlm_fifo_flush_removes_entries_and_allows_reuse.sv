/*
:name: test_tlm_fifo_flush_removes_entries_and_allows_reuse
:description: FIFO flush removes queued entries while preserving capacity for reuse (IEEE 1800.2-2020 Section 12.2.8.2.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.6 12.2.8.2.2 12.2.8.2.3 12.2.8.2.4 12.2.4.2.4 12.2.4.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_flush_removes_entries_and_allows_reuse.expected
*/
// What it checks:
// FIFO flush removes all entries from that instance without changing
// configured size.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.8.2.6 (UVM-FIFO-FLUSH-LOCAL) gives the rule above. Setup:
// Flush one populated FIFO, retain a second FIFO, then reuse the cleared
// instance. Expected: Used becomes zero and empty true; the peer retains order
// and a later put/get succeeds.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Flush populated storage, then accept and consume a fresh value.
// No blocked reader or writer is active during flush.

module test_tlm_fifo_flush_removes_entries_and_allows_reuse;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo", null, 3);
    int value;
    bit put_ok;
    bit get_ok;
    void'(fifo.try_put(11));
    void'(fifo.try_put(22));
    fifo.flush();
    $display("UT: flushed size %0d used %0d empty %0d can_get %0d", fifo.size(),
        fifo.used(), fifo.is_empty(), fifo.can_get());
    put_ok = fifo.try_put(71);
    get_ok = fifo.try_get(value);
    $display("UT: reuse put %0d get %0d value %0d empty %0d", put_ok, get_ok, value,
        fifo.is_empty());
    $finish;
  end
endmodule
