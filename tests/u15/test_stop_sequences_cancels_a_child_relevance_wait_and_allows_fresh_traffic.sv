/*
:name: test_stop_sequences_cancels_a_child_relevance_wait_and_allows_fresh_traffic
:description: stop sequences cancels a child relevance wait and allows fresh traffic (IEEE 1800.2-2020 Section 15.3.2.14)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.14 14.1.2.7 14.2.3.1 14.2.5.3 14.2.5.4 14.2.5.11 14.2.5.12 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_stop_sequences_cancels_a_child_relevance_wait_and_allows_fresh_traffic.expected
*/
// What it checks:
// 1. Stopping includes active child sequences throughout the selected
//    hierarchy.
// 2. Sequencer stop invokes do_kill on each selected active sequence.
// 3. Sequencer stop clears a relevance-blocked child request together with its
//    active parent.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.3.2.14 (UVM-SEQUENCER-STOP-ACTIVE-DESCENDANTS) gives rule
//    1 above. Setup: Exercise parent/child, three-level and sibling-child
//    active trees. Expected: Every observed node is STOPPED with one kill and
//    no late write; parent start returns.
// 2. 1800.2-2020 14.2.5.12 (UVM-SEQUENCE-DO-KILL-HOOK-SEQUENCER-STOP) gives
//    rule 2 above. Setup: Two original sequence bodies are active on the same
//    sequencer before stop_sequences. Expected: Both active sequences observe
//    one do_kill callback.
// 3. 1800.2-2020 15.3.2.14 (UVM-SEQ-REVIEW-STOP-CHILD-RELEVANCE-REQUEST) gives
//    rule 3 above. Setup: The driver waits for an item from a child whose
//    parent is executing start. Expected: Both parent and child stop and fresh
//    traffic completes without the old child resuming.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A parent runs a child whose real item request is held by relevance. Stop
// through the public sequencer API, observe both states and hooks, and then
// complete actual fresh traffic. No private request list or exact hook count
// is used; the standard post-body/post-start observations remain separate.
module test_stop_sequences_cancels_a_child_relevance_wait_and_allows_fresh_traffic;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    int value;
    function new(); super.new("packet"); endfunction
  endclass
  class gated_sequence extends uvm_sequence#(packet);
    bit relevant = 0, finished = 0;
    int label, wait_calls = 0, kill_calls = 0;
    function new(string name="gated"); super.new(name); endfunction
    function bit is_relevant(); return relevant; endfunction
    task wait_for_relevant(); wait_calls++; wait (relevant); endtask
    function void do_kill(); kill_calls++; endfunction
    task body();
      automatic packet item = new();
      item.value = label; start_item(item); finish_item(item); finished = 1;
    endtask
  endclass

  class parent_sequence extends uvm_sequence#(packet);
    gated_sequence child;
    bit after_child = 0;
    int kill_calls = 0;
    function new(string name="parent"); super.new(name); endfunction
    function void do_kill(); kill_calls++; endfunction
    task body(); child.start(get_sequencer(), this); after_child = 1; endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    parent_sequence parent;
    gated_sequence child, fresh;
    packet received;
    bit returned = 0, driver_received = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this); sequencer.disable_auto_item_recording();
      driver = new("driver", this); parent = new(); child = new("child");
      fresh = new("fresh"); parent.child = child; fresh.relevant = 1; fresh.label = 99;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin parent.start(sequencer); returned = 1; end
        begin
          driver.seq_item_port.get_next_item(received); driver_received = 1;
          #1; driver.seq_item_port.item_done();
        end
      join_none
      wait (child.wait_calls > 0); #1;
      $display("UT: child_wait parent %0d child %0d parent_context %0d no_delivery %0d",
               parent.get_sequence_state() == UVM_BODY, child.get_sequence_state() == UVM_BODY,
               child.get_parent_sequence() == parent, !driver_received);
      sequencer.stop_sequences(); #1;
      $display("UT: stopped parent %0d child %0d returned %0d hooks %0d",
               parent.get_sequence_state() == UVM_STOPPED,
               child.get_sequence_state() == UVM_STOPPED, returned,
               parent.kill_calls > 0 && child.kill_calls > 0);
      fresh.start(sequencer); #1;
      $display(
      "UT: after_stop delivered %0d value %0d fresh %0d child_finished %0d parent_after %0d",
               driver_received, received.value, fresh.finished, child.finished, parent.after_child);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "nested stop watchdog expired"); end
endmodule
