/*
:name: test_tlm_analysis_fifo_write_preserves_arrival_order
:description: analysis FIFO writes are retrieved in their arrival order (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.8.3.2 12.2.4.2.6 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_write_preserves_arrival_order.expected
*/
// Use the nonblocking write interface and retrieve entries through
// the inherited FIFO get interface.

module test_tlm_analysis_fifo_write_preserves_arrival_order;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_analysis_fifo#(int) fifo = new("fifo");
    int value;
    bit ok;
    fifo.write(5);
    fifo.write(7);
    fifo.write(9);
    $display("UT: written %0d", fifo.used());
    ok = fifo.try_get(value);
    $display("UT: first %0d %0d", ok, value);
    ok = fifo.try_get(value);
    $display("UT: second %0d %0d", ok, value);
    ok = fifo.try_get(value);
    $display("UT: third %0d %0d empty %0d", ok, value, fifo.is_empty());
    $finish;
  end
endmodule
