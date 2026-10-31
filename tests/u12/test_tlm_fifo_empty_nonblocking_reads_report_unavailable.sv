/*
:name: test_tlm_fifo_empty_nonblocking_reads_report_unavailable
:description: empty FIFO nonblocking read methods report unavailability without adding entries (IEEE 1800.2-2020 Section 12.2.4.2.6)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.4.2.6 12.2.4.2.7 12.2.4.2.8 12.2.4.2.9 12.2.8.2.3 12.2.8.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_empty_nonblocking_reads_report_unavailable.expected
*/
// Observe status and queue state only. Output-argument preservation
// on unavailable reads is outside this case and is not inferred from it.

module test_tlm_fifo_empty_nonblocking_reads_report_unavailable;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo");
    int value;
    bit get_ok;
    bit peek_ok;
    get_ok = fifo.try_get(value);
    peek_ok = fifo.try_peek(value);
    $display("UT: results get %0d peek %0d availability %0d %0d", get_ok, peek_ok,
        fifo.can_get(), fifo.can_peek());
    $display("UT: used %0d empty %0d can_put %0d", fifo.used(), fifo.is_empty(), fifo.can_put());
    $finish;
  end
endmodule
