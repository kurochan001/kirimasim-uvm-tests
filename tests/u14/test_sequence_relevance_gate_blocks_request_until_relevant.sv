/*
:name: test_sequence_relevance_gate_blocks_request_until_relevant
:description: a sequence request is not granted until is_relevant becomes true (IEEE 1800.2-2020 Section 14.2.5.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.3 14.2.5.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.5.2.2 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_relevance_gate_blocks_request_until_relevant.expected
*/
// What it checks:
// An irrelevant requesting sequence is withheld until relevance becomes true.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.5.3 (UVM-SEQUENCE-RELEVANCE-GATED-REQUEST) gives the rule
// above. Setup: Start a request with a custom relevance wait and open the gate
// after a positive delay. Expected: Driver receives nothing before opening and
// later receives payload 42 with completion.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A custom wait_for_relevant waits on a shared class flag. The driver
// waits for a request while a positive-delay observer opens that gate.
// Do not assert internal polling or callback counts.

module test_sequence_relevance_gate_blocks_request_until_relevant;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class gated_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(gated_sequence)
    bit relevant = 0;
    bit finished = 0;
    packet sent;
    function new(string name="gated_sequence"); super.new(name); endfunction
    function bit is_relevant(); return relevant; endfunction
    task wait_for_relevant(); wait (relevant); endtask
    task body();
      sent = new("request");
      sent.payload = 42;
      start_item(sent);
      finish_item(sent);
      finished = 1;
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    gated_sequence sequence_value;
    packet observed;
    bit driver_received = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      sequence_value = new("sequence_value");
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        sequence_value.start(sequencer);
        begin
          driver.seq_item_port.get_next_item(observed);
          driver_received = 1;
          #1;
          driver.seq_item_port.item_done();
        end
        begin
          #1;
          $display("UT: before_open received %0d relevant %0d", driver_received,
              sequence_value.relevant);
          sequence_value.relevant = 1;
        end
      join
      if (observed == null) $fatal(1, "request missing");
      $display("UT: after_open received %0d payload %0d finished %0d", driver_received,
               observed.payload, sequence_value.finished);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
