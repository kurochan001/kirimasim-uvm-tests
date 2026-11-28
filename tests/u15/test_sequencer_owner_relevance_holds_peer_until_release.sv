/*
:name: test_sequencer_owner_relevance_holds_peer_until_release
:description: Pending requests need both relevance and permission from the active lock or grab
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.17 15.3.2.8 15.3.2.9 15.3.2.10 15.3.2.11 15.3.2.12 15.3.2.13 15.3.2.16 14.2.5.3 14.2.5.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_owner_relevance_holds_peer_until_release.expected
*/
// What it checks:
// Availability requires a pending request that is unblocked and relevant.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.17 (UVM-SEQUENCER-ACTIVE-OWNER-RELEVANCE) gives the rule.
// Hold a lock or grab with a pending irrelevant owner and a pending relevant
// peer. After making the owner relevant, consume its item while it still owns
// the sequencer. The peer becomes available only after explicit release.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_owner_relevance_holds_peer_until_release;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    int payload;

    function new(string name = "packet");
      super.new(name);
    endfunction
  endclass

  class traffic extends uvm_sequence#(packet);
    bit owns_sequencer;
    bit use_grab;
    bit relevant = 1;
    bit acquired;
    bit requested;
    bit completed;
    bit release_requested;
    bit released;
    int payload;

    function new(string name = "traffic");
      super.new(name);
    endfunction

    virtual function bit is_relevant();
      return relevant;
    endfunction

    virtual task wait_for_relevant();
      wait (relevant);
    endtask

    virtual task body();
      packet item_value;

      if (owns_sequencer) begin
        if (use_grab) grab();
        else lock();
        acquired = 1;
      end

      item_value = new("request");
      item_value.payload = payload;
      requested = 1;
      start_item(item_value);
      finish_item(item_value);
      completed = 1;

      if (owns_sequencer) begin
        wait (release_requested);
        if (use_grab) ungrab();
        else unlock();
        released = 1;
      end
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

    task check_ownership(bit use_grab);
      traffic owner;
      traffic peer;
      packet received;
      string mode;

      mode = use_grab ? "grab" : "lock";
      owner = new("owner");
      owner.owns_sequencer = 1;
      owner.use_grab = use_grab;
      owner.relevant = 0;
      owner.payload = 11;
      peer = new("peer");
      peer.payload = 22;

      fork
        owner.start(sequencer);
        begin
          wait (owner.acquired);
          peer.start(sequencer);
        end
        begin
          wait (owner.requested && peer.requested);
          // Allow both start_item calls to reach their arbitration waits.
          #1;
          $display("UT: %s pending available %0d owner %0d owner_blocked %0d peer_blocked %0d",
                   mode, sequencer.has_do_available(), sequencer.current_grabber() == owner,
                   sequencer.is_blocked(owner), sequencer.is_blocked(peer));

          owner.relevant = 1;
          $display("UT: %s relevant available %0d peer_blocked %0d",
                   mode, sequencer.has_do_available(), sequencer.is_blocked(peer));
          driver.seq_item_port.get_next_item(received);
          if (received == null) $fatal(1, "owner request missing");
          $display("UT: %s first payload %0d", mode, received.payload);
          driver.seq_item_port.item_done();
          wait (owner.completed);

          $display("UT: %s completed available %0d owner %0d peer_blocked %0d",
                   mode, sequencer.has_do_available(), sequencer.has_lock(owner),
                   sequencer.is_blocked(peer));
          owner.release_requested = 1;
          wait (owner.released);

          $display("UT: %s released available %0d owner %0d peer_blocked %0d",
                   mode, sequencer.has_do_available(), sequencer.current_grabber() != null,
                   sequencer.is_blocked(peer));
          driver.seq_item_port.get_next_item(received);
          if (received == null) $fatal(1, "peer request missing");
          $display("UT: %s second payload %0d", mode, received.payload);
          driver.seq_item_port.item_done();
        end
      join

      $display("UT: %s idle available %0d peer_completed %0d",
               mode, sequencer.has_do_available(), peer.completed);
    endtask

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      check_ownership(0);
      check_ownership(1);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "ownership and relevance watchdog expired");
  end
endmodule
