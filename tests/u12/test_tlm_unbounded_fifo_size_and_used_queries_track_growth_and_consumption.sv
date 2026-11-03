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
