/*
:name: test_tlm_fifo_rejected_put_keeps_existing_entry
:description: a full FIFO rejects a new transaction without replacing its existing entry (IEEE 1800.2-2020 Section 12.2.4.2.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 12.2.4.2.8 12.2.8.2.1 12.2.8.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_rejected_put_keeps_existing_entry.expected
*/
// Use the constructor default capacity of one, attempt a second put,
// and inspect the retained head through peek and get.

module test_tlm_fifo_rejected_put_keeps_existing_entry;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo");
    int value;
    bit accepted;
    bit rejected;
    bit ok;
    accepted = fifo.try_put(11);
    rejected = fifo.try_put(99);
    $display("UT: capacity %0d put_results %0d %0d full %0d", fifo.size(), accepted,
        rejected, fifo.is_full());
    ok = fifo.try_peek(value);
    $display("UT: peek %0d value %0d used %0d", ok, value, fifo.used());
    ok = fifo.try_get(value);
    $display("UT: get %0d value %0d empty %0d", ok, value, fifo.is_empty());
    $finish;
  end
endmodule
