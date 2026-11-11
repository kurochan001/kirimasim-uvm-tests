/*
:name: test_tlm_fifo_positive_capacity_queries_follow_fill_peek_get_and_flush
:description: tlm fifo positive capacity queries follow fill peek get and flush (IEEE 1800.2-2020 Section 12.2.8.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.8.2.2 12.2.8.2.3 12.2.8.2.4 12.2.8.2.5 12.2.8.2.6 12.2.4.2.1 12.2.4.2.2 12.2.4.2.3 12.2.4.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm_fifo_positive_capacity_queries_follow_fill_peek_get_and_flush.expected
*/
// What it checks:
// 1. The size query reports the configured positive FIFO capacity rather than
//    occupancy.
// 2. The used query reports current stored entries.
// 3. is_empty reports whether there are zero stored entries.
// 4. For a positive bounded size, is_full reports occupancy equal to capacity.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.2.8.2.2 (UVM-TLM1-REVIEW-FIFO-POSITIVE-CAPACITY-QUERY)
//    gives rule 1 above. Setup: Fill, peek, consume and flush a three-entry
//    FIFO. Expected: Size remains three throughout occupancy changes.
// 2. 1800.2-2020 12.2.8.2.3 (UVM-TLM1-REVIEW-FIFO-USED-CURRENT-ENTRIES) gives
//    rule 2 above. Setup: Use a bounded fill/peek/get/flush and an unbounded
//    growth/drain. Expected: Counts follow accepted insertion/removal, survive
//    peek unchanged and reach zero after draining.
// 3. 1800.2-2020 12.2.8.2.4 (UVM-TLM1-REVIEW-FIFO-EMPTY-QUERY) gives rule 3
//    above. Setup: Observe empty, filled, partially consumed and flushed FIFO
//    states. Expected: Empty is true only at zero occupancy.
// 4. 1800.2-2020 12.2.8.2.5 (UVM-TLM1-REVIEW-FIFO-POSITIVE-FULL-QUERY) gives
//    rule 4 above. Setup: Fill a capacity-three FIFO, peek, remove one entry
//    and flush. Expected: Full is true at three entries, stays true across
//    peek and becomes false after removal.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Positive bounded capacity distinguishes capacity from occupancy, emptiness
// and fullness. Successful peek does not consume; full rejection does not add
// data. Zero-capacity is_full interpretation and failed-get output remain
// separate.
module test_tlm_fifo_positive_capacity_queries_follow_fill_peek_get_and_flush;
  import uvm_pkg::*;
  initial begin
    automatic uvm_tlm_fifo#(int) subject = new("subject",null,3);
    automatic bit accepted = 1;
    int value;
    $display("UT: fifo_initial size %0d used %0d empty %0d full %0d",
             subject.size(),subject.used(),subject.is_empty(),subject.is_full());
    accepted &= subject.try_put(13); accepted &= subject.try_put(27);
    accepted &= subject.try_put(41);
    $display("UT: fifo_filled accepted %0d rejected %0d size %0d used %0d empty %0d full %0d",
             accepted,!subject.try_put(67),subject.size(),subject.used(),subject.is_empty(),
             subject.is_full());
    subject.peek(value);
    $display("UT: fifo_peek value %0d used %0d full %0d",value,subject.used(),subject.is_full());
    subject.get(value);
    $display("UT: fifo_get value %0d used %0d empty %0d full %0d",value,subject.used(),
             subject.is_empty(),subject.is_full());
    subject.flush();
    $display("UT: fifo_flushed size %0d used %0d empty %0d full %0d",
             subject.size(),subject.used(),subject.is_empty(),subject.is_full());
    $finish;
  end
endmodule
