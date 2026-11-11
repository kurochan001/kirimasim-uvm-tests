/*
:name: test_analysis_port_broadcasts_each_write_to_all_receivers
:description: analysis port writes reach both connected receivers once in source order (IEEE 1800.2-2020 Section 12.2.10.1.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.1.4 12.2.10.1.3 12.2.8.3.1 12.2.8.3 5.5.2.12 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_port_broadcasts_each_write_to_all_receivers.expected
*/
// What it checks:
// Analysis write sends the supplied value to every connected receiver.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.2.10.1.4 (UVM-TLM1-ANALYSIS-BOUND-BROADCAST) gives the rule
// above. Setup: Connect two FIFO receivers and write ordered scalar values or
// one object handle. Expected: Both receivers see every value in source order
// and the original object handle without modification.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Resolve bindings through normal UVM elaboration. Receiver queues
// are read after write returns, without assuming subscriber call order.

module test_analysis_port_broadcasts_each_write_to_all_receivers;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(int) ap;
    uvm_tlm_analysis_fifo#(int) left;
    uvm_tlm_analysis_fifo#(int) right;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap = new("ap", this);
      left = new("left", this);
      right = new("right", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      ap.connect(left.analysis_export);
      ap.connect(right.analysis_export);
    endfunction
    task run_phase(uvm_phase phase);
      int first;
      int second;
      phase.raise_objection(this);
      ap.write(81);
      ap.write(13);
      $display("UT: bindings %0d queued %0d %0d", ap.size(), left.used(), right.used());
      if (!left.try_get(first)) $fatal(1, "left delivery missing");
      if (!left.try_get(second)) $fatal(1, "left delivery missing");
      $display("UT: left %0d %0d remaining %0d", first, second, left.used());
      if (!right.try_get(first)) $fatal(1, "right delivery missing");
      if (!right.try_get(second)) $fatal(1, "right delivery missing");
      $display("UT: right %0d %0d remaining %0d", first, second, right.used());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
