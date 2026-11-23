/*
:name: test_analysis_broadcast_consumers_drain_and_flush_their_own_backlogs_independently
:description: Flushing one analysis FIFO preserves its sibling backlog and subsequent broadcasts reach both (IEEE 1800.2-2020 Section 12.2.10.1.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.1.4 12.2.8.3 12.2.8.2.6 12.2.8.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_broadcast_consumers_drain_and_flush_their_own_backlogs_independently.expected
*/
// Connect two queues to one analysis port. Drain the first object on one
// subscriber only and flush its sibling while both still have entries.
// Broadcast a third object and the original handle again after changing its
// value. Check every remaining handle, payload, order and final occupancy. No
// subscriber modifies the object during write.

module test_analysis_broadcast_consumers_drain_and_flush_their_own_backlogs_independently;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    int value;
    function new(int initial_value);
      super.new("packet");
      value = initial_value;
    endfunction
  endclass
  typedef uvm_tlm_analysis_fifo #(packet) packet_fifo;

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port #(packet) source;
    packet_fifo left, right;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      source = new("source", this);
      left = new("left", this);
      right = new("right", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      source.connect(left.analysis_export);
      source.connect(right.analysis_export);
    endfunction
    function packet take(packet_fifo fifo);
      packet p;
      if (!fifo.try_get(p) || p == null) $fatal(1, "missing packet in %s", fifo.get_name());
      return p;
    endfunction
    task run_phase(uvm_phase phase);
      packet a = new(17);
      packet b = new(34);
      packet c = new(51);
      packet first, second, third;
      phase.raise_objection(this);
      source.write(a);
      source.write(b);
      first = take(left);
      $display("UT: before consumed %0d value %0d pending %0d %0d",
               first == a, first.value, left.used(), right.used());
      right.flush();
      $display("UT: flushed pending %0d %0d", left.used(), right.used());
      source.write(c);
      a.value = 68;
      source.write(a);
      first = take(left);
      second = take(left);
      third = take(left);
      $display("UT: left %0d %0d %0d values %0d %0d %0d",
               first == b, second == c, third == a, first.value, second.value, third.value);
      first = take(right);
      second = take(right);
      $display("UT: right %0d %0d values %0d %0d empty %0d %0d",
               first == c, second == a, first.value, second.value, left.used(), right.used());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
