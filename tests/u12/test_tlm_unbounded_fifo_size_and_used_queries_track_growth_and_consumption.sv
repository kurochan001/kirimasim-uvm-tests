/*
:name: test_tlm_unbounded_fifo_size_and_used_queries_track_growth_and_consumption
:description: tlm unbounded fifo size and used queries track growth and consumption (IEEE 1800.2-2020 Section 12.2.8.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.3 12.2.8.2.1 12.2.8.2.2 12.2.8.2.4 12.2.4.2.7 12.2.4.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_unbounded_fifo_size_and_used_queries_track_growth_and_consumption.expected
*/
// What it checks:
// 1. The used query reports current stored entries.
// 2. is_empty reports whether there are zero stored entries.
// 3. The size query returns zero for unbounded FIFO capacity.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.8.2.3 (UVM-TLM1-REVIEW-FIFO-USED-CURRENT-ENTRIES) gives
//    rule 1 above. Setup: Use a bounded fill/peek/get/flush and an unbounded
//    growth/drain. Expected: Counts follow accepted insertion/removal, survive
//    peek unchanged and reach zero after draining.
// 2. 1800.2-2020 12.2.8.2.4 (UVM-TLM1-REVIEW-FIFO-EMPTY-QUERY) gives rule 2
//    above. Setup: Observe empty, filled, partially consumed and flushed FIFO
//    states. Expected: Empty is true only at zero occupancy.
// 3. 1800.2-2020 12.2.8.2.2 (UVM-TLM1-REVIEW-FIFO-UNBOUNDED-SIZE-QUERY) gives
//    rule 3 above. Setup: Accept and consume five items in an explicitly
//    zero-sized FIFO. Expected: Size remains zero while occupancy grows to
//    five and drains to zero.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A zero size means unbounded capacity, while used counts current entries.
// Do not infer is_full's zero-capacity interpretation from the selected
// implementation; its literal equality wording and no-limit semantics need
// separate review. No false-get output is constrained.
module test_tlm_unbounded_fifo_size_and_used_queries_track_growth_and_consumption;
  import uvm_pkg::*;
  initial begin
    automatic uvm_tlm_fifo#(int) subject = new("subject",null,0);
    automatic bit accepted = 1;
    automatic int sum = 0;
    int value;
    for (int i = 0;i < 5;i++) accepted &= subject.try_put(13+i);
    $display("UT: fifo_unbounded size %0d used %0d empty %0d get %0d peek %0d accepted %0d",
             subject.size(),subject.used(),subject.is_empty(),subject.can_get(),
             subject.can_peek(),accepted);
    repeat (5) begin subject.get(value); sum += value; end
    $display("UT: fifo_unbounded_drained size %0d used %0d empty %0d sum %0d",
             subject.size(),subject.used(),subject.is_empty(),sum);
    $finish;
  end
endmodule
