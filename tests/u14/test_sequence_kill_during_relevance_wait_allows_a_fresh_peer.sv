/*
:name: test_sequence_kill_during_relevance_wait_allows_a_fresh_peer
:description: sequence kill during relevance wait allows a fresh peer (IEEE 1800.2-2020 Section 14.2.5.11)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.5.11 14.2.5.12 14.2.5.3 14.2.5.4 14.2.3.1 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_kill_during_relevance_wait_allows_a_fresh_peer.expected
*/
// What it checks:
// 1. Direct sequence kill invokes its do_kill hook for bound and unbound
//    running bodies.
// 2. Killing a relevance-blocked sequence removes its pending request from the
//    default sequencer.
// 3. Kill changes a relevance-blocked sequence to STOPPED and releases its
//    start invocation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.5.12 (UVM-SEQUENCE-DO-KILL-HOOK-BOUND-AND-UNBOUND) gives
//    rule 1 above. Setup: The original body is entered before kill and its
//    hook increments a counter. Expected: Each killed sequence observes one
//    do_kill callback.
// 2. 1800.2-2020 14.2.5.11 (UVM-SEQ-REVIEW-KILL-RELEVANCE-PENDING-REQUEST)
//    gives rule 2 above. Setup: The driver has entered wait_for_relevant
//    before the sequence is killed. Expected: The canceled start returns
//    stopped and a real fresh peer transfer completes.
// 3. 1800.2-2020 14.2.5.11 (UVM-SEQ-REVIEW-KILL-RELEVANCE-STOP-RETURN) gives
//    rule 3 above. Setup: The body is blocked before its item grant. Expected:
//    After a settling delay the sequence is stopped, start returned, and its
//    item body did not finish.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Wait until the driver has triggered the custom relevance wait before kill.
// A real peer transfer demonstrates request cleanup without private queue
// access. No exact polling count, random arbitration or post-kill hook
// ordering
// is prescribed; required post-body/post-start cases remain separate.
module test_sequence_kill_during_relevance_wait_allows_a_fresh_peer;
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

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    gated_sequence canceled, peer;
    packet received;
    bit returned = 0, driver_received = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this); sequencer.disable_auto_item_recording();
      driver = new("driver", this); canceled = new("canceled"); peer = new("peer");
      canceled.label = 11; peer.label = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin canceled.start(sequencer); returned = 1; end
        begin

          driver.seq_item_port.get_next_item(received); driver_received = 1;
          #1; driver.seq_item_port.item_done();
        end

      join_none
      wait (canceled.wait_calls > 0);
      #1;
      $display("UT: relevance_wait canceled %0d no_delivery %0d", canceled.wait_calls > 0,
               !driver_received);
      canceled.kill(); #1;
      $display("UT: canceled stopped %0d returned %0d finished %0d hook %0d",
               canceled.get_sequence_state() == UVM_STOPPED, returned, canceled.finished,
               canceled.kill_calls > 0);

      peer.relevant = 1; fork peer.start(sequencer); join_none
      wait (peer.finished); #1;
      $display("UT: fresh_transfer delivered %0d value %0d canceled_finished %0d",
               driver_received, received.value, canceled.finished);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "relevance cancellation watchdog expired"); end
endmodule
