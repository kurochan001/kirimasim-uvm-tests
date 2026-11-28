/*
:name: test_sequencer_kill_of_gated_child_restores_parent_lock
:description: Killing a relevance-blocked child removes its grab and pending request while preserving the parent lock
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.16 14.2.5.11 14.2.5.3 14.2.5.4 14.2.3.1 15.3.2.8 15.3.2.9 15.3.2.10 15.3.2.11 15.3.2.12 15.3.2.17 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_kill_of_gated_child_restores_parent_lock.expected
*/
// What it checks:
// Killing the child that holds a nested grab restores the parent as owner.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.16 (UVM-SEQUENCER-GATED-CHILD-KILL-RESTORES-PARENT)
// identifies the current owner, and 14.2.5.11 removes
// the killed sequence's ownership and requests. A driver waits while the
// child is irrelevant under its grab. Killing the child allows the pending
// parent item through. Its peer remains blocked until the parent unlocks.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_kill_of_gated_child_restores_parent_lock;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    int payload;

    function new(string name = "packet");
      super.new(name);
    endfunction
  endclass

  class traffic extends uvm_sequence#(packet);
    int payload;
    bit pending;
    bit completed;

    function new(string name = "traffic");
      super.new(name);
    endfunction

    task send_payload();
      packet request;
      request = new("request");
      request.payload = payload;
      pending = 1;
      start_item(request);
      finish_item(request);
      completed = 1;
    endtask

    virtual task body();
      send_payload();
    endtask
  endclass

  class gated_child extends traffic;
    bit relevant;
    bit waiting_for_relevance;

    function new(string name = "child");
      super.new(name);
    endfunction

    virtual function bit is_relevant();
      return relevant;
    endfunction

    virtual task wait_for_relevant();
      waiting_for_relevance = 1;
      wait (relevant);
    endtask

    virtual task body();
      grab();
      send_payload();
      ungrab();
    endtask
  endclass

  class parent_traffic extends traffic;
    gated_child child_seq;
    bit child_returned;
    bit release_requested;
    bit released;

    function new(string name = "parent");
      super.new(name);
      child_seq = new();
      child_seq.payload = 99;
    endfunction

    virtual task body();
      lock();
      fork
        begin
          child_seq.start(get_sequencer(), this);
          child_returned = 1;
        end
        begin
          wait (child_seq.pending);
          send_payload();
          wait (release_requested);
          unlock();
          released = 1;
        end
      join
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    parent_traffic parent_seq;
    traffic peer;
    packet first_item;
    packet second_item;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      parent_seq = new();
      parent_seq.payload = 11;
      peer = new("peer");
      peer.payload = 22;
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      fork
        parent_seq.start(sequencer);
        begin
          wait (parent_seq.child_seq.pending);
          peer.start(sequencer);
        end
        begin
          wait (parent_seq.pending && peer.pending);
          // Give both requests time to enter the arbitration queue.
          #1;
          driver.seq_item_port.get_next_item(first_item);
          if (first_item == null) $fatal(1, "parent request missing");
          driver.seq_item_port.item_done();
        end
        begin
          wait (parent_seq.child_seq.waiting_for_relevance);
          $display("UT: held child %0d lock %0d parent_blocked %0d peer_blocked %0d ready %0d",
                   sequencer.current_grabber() == parent_seq.child_seq,
                   sequencer.has_lock(parent_seq), sequencer.is_blocked(parent_seq),
                   sequencer.is_blocked(peer), sequencer.has_do_available());

          parent_seq.child_seq.kill();
          wait (parent_seq.child_returned && parent_seq.completed);
          $display("UT: killed child_stopped %0d child_lock %0d child_completed %0d",
                   parent_seq.child_seq.get_sequence_state() == UVM_STOPPED,
                   sequencer.has_lock(parent_seq.child_seq), parent_seq.child_seq.completed);
          $display("UT: parent payload %0d owner %0d peer_blocked %0d available %0d",
                   first_item.payload, sequencer.current_grabber() == parent_seq,
                   sequencer.is_blocked(peer), sequencer.has_do_available());

          // Reopen the child's gate so a stale request would become eligible.
          parent_seq.child_seq.relevant = 1;
          parent_seq.release_requested = 1;
          wait (parent_seq.released);
          $display("UT: released owner_null %0d peer_blocked %0d available %0d",
                   sequencer.current_grabber() == null, sequencer.is_blocked(peer),
                   sequencer.has_do_available());
          driver.seq_item_port.get_next_item(second_item);
          if (second_item == null) $fatal(1, "peer request missing");
          $display("UT: peer payload %0d", second_item.payload);
          driver.seq_item_port.item_done();
        end
      join

      $display("UT: idle available %0d peer_completed %0d",
               sequencer.has_do_available(), peer.completed);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "nested ownership cancellation watchdog expired");
  end
endmodule
