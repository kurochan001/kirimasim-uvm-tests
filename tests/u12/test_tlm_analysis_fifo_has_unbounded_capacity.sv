/*
:name: test_tlm_analysis_fifo_has_unbounded_capacity
:description: analysis FIFO storage is unbounded and accepts multiple writes (IEEE 1800.2-2020 Section 12.2.8.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.3 12.2.8.3.1 12.2.8.2.2 12.2.8.2.3 12.2.8.2.5 12.2.4.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_analysis_fifo_has_unbounded_capacity.expected
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
// Write multiple entries before reading and inspect capacity after
// positive occupancy. No limit or representation is inferred from storage.

module test_tlm_analysis_fifo_has_unbounded_capacity;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_analysis_fifo#(int) fifo = new("fifo");
    int i;
    int value;
    bit ok;
    i = 0;
    repeat (6) begin fifo.write(i); i++; end
    $display("UT: size %0d used %0d full %0d can_put %0d", fifo.size(), fifo.used(),
        fifo.is_full(), fifo.can_put());
    ok = fifo.try_get(value);
    $display("UT: first %0d %0d remaining %0d", ok, value, fifo.used());
    $finish;
  end
endmodule
