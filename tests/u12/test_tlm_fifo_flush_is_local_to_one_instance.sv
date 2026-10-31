/*
:name: test_tlm_fifo_flush_is_local_to_one_instance
:description: flushing one FIFO leaves another FIFO capacity and entries intact (IEEE 1800.2-2020 Section 12.2.8.2.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.6 12.2.8.2.2 12.2.8.2.3 12.2.4.2.4 12.2.4.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_flush_is_local_to_one_instance.expected
*/
// Populate two independent FIFOs, flush one and drain the other.
// No conclusion depends on internal mailbox representation.

module test_tlm_fifo_flush_is_local_to_one_instance;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) first = new("first", null, 2);
    automatic uvm_tlm_fifo#(int) second = new("second", null, 3);
    int value;
    bit ok;
    void'(first.try_put(11));
    void'(second.try_put(22));
    void'(second.try_put(33));
    first.flush();
    $display("UT: states first %0d %0d second %0d %0d", first.size(), first.used(),
        second.size(), second.used());
    ok = second.try_get(value);
    $display("UT: second_head %0d %0d", ok, value);
    ok = second.try_get(value);
    $display("UT: second_tail %0d %0d empty %0d", ok, value, second.is_empty());
    $finish;
  end
endmodule
