/*
:name: test_analysis_port_broadcast_preserves_object_handle_value
:description: analysis port broadcasts the same object handle value to both receivers (IEEE 1800.2-2020 Section 12.2.10.1.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.10.1.4 12.2.4.2.12 12.2.8.3.1 12.2.8.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_analysis_port_broadcast_preserves_object_handle_value.expected
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
// Subscribers retain the received handle without modifying its object.
// Inspect identity after write returns, without depending on call order.

module test_analysis_port_broadcast_preserves_object_handle_value;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_object;
    `uvm_object_utils(packet)
    int payload = 17;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_analysis_port#(packet) ap;
    uvm_tlm_analysis_fifo#(packet) left;
    uvm_tlm_analysis_fifo#(packet) right;
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
      packet sent = new("sent");
      packet left_value;
      packet right_value;
      phase.raise_objection(this);
      ap.write(sent);
      if (!left.try_get(left_value) || !right.try_get(right_value)) $fatal(1, "delivery missing");
      if (left_value == null || right_value == null) $fatal(1, "null delivery");
      $display("UT: handles_same %0d %0d payloads %0d %0d", left_value == sent, right_value == sent,
               left_value.payload, right_value.payload);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #30;
    $fatal(1, "test watchdog expired");
  end
endmodule
