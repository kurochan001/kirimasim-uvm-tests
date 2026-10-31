/*
:name: test_tlm_fifo_zero_capacity_is_unbounded
:description: a zero-sized FIFO accepts multiple entries without a capacity limit (IEEE 1800.2-2020 Section 12.2.8.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.1 12.2.8.2.2 12.2.8.2.3 12.2.8.2.4 12.2.8.2.5 12.2.4.2.4 12.2.4.2.5 12.2.4.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_zero_capacity_is_unbounded.expected
*/
// A size of zero selects unbounded storage. Inspect full only after
// entries have been written, avoiding an empty size-equality observation.

module test_tlm_fifo_zero_capacity_is_unbounded;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_fifo#(int) fifo = new("fifo", null, 0);
    int i;
    int value;
    bit ok;
    i = 0;
    repeat (4) begin
      ok = fifo.try_put(10 + i);
      if (!ok) $fatal(1, "unbounded put rejected");
      i++;
    end
    $display("UT: size %0d used %0d full %0d can_put %0d", fifo.size(), fifo.used(),
        fifo.is_full(), fifo.can_put());
    ok = fifo.try_get(value);
    $display("UT: first_get %0d value %0d remaining %0d", ok, value, fifo.used());
    $finish;
  end
endmodule
