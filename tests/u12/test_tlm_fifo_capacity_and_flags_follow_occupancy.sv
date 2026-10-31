/*
:name: test_tlm_fifo_capacity_and_flags_follow_occupancy
:description: bounded FIFO capacity and occupancy flags track successful puts and gets (IEEE 1800.2-2020 Section 12.2.8.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.1 12.2.8.2.2 12.2.8.2.3 12.2.8.2.4 12.2.8.2.5 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_capacity_and_flags_follow_occupancy.expected
*/
// Use direct FIFO interface methods and observe state after each call.
// No transaction value is read after an unsuccessful get.

module test_tlm_fifo_capacity_and_flags_follow_occupancy;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo", null, 2);
    int value;
    bit ok;
    $display("UT: initial size %0d used %0d empty %0d full %0d", fifo.size(), fifo.used(),
        fifo.is_empty(), fifo.is_full());
    ok = fifo.try_put(11);
    $display("UT: first_put %0d used %0d can_put %0d", ok, fifo.used(), fifo.can_put());
    ok = fifo.try_put(22);
    $display("UT: second_put %0d used %0d full %0d can_put %0d", ok, fifo.used(),
        fifo.is_full(), fifo.can_put());
    ok = fifo.try_get(value);
    $display("UT: first_get %0d value %0d used %0d full %0d", ok, value, fifo.used(),
        fifo.is_full());
    ok = fifo.try_get(value);
    $display("UT: second_get %0d value %0d used %0d empty %0d", ok, value, fifo.used(),
        fifo.is_empty());
    $finish;
  end
endmodule
