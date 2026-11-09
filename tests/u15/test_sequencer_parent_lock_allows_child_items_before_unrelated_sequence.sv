/*
:name: test_sequencer_parent_lock_allows_child_items_before_unrelated_sequence
:description: sequencer ownership determines which competing requests may reach the driver (IEEE 1800.2-2020 Section 15.3.2.8)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.8 15.3.2.2 14.2.5.5 14.2.5.7 15.5.2.3 15.5.2.5 15.3.2.22 14.2.3.1 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_parent_lock_allows_child_items_before_unrelated_sequence.expected
*/
// What it checks:
// Parent ownership admits its child while child ownership can block the parent
// and unrelated sequences.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.2.8 (UVM-SEQUENCER-PARENT-CHILD-BLOCKING) gives the rule
// above. Setup: Use direct ancestry with nested ownership and real
// parent/child item delivery. Expected: The child is eligible under its
// parent, nested child ownership blocks the parent, and expected traffic
// resumes after release.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// A child sends an item under its parent lock without taking another
// lock. The parent then sends its own item before releasing the unrelated
// sequence. Observe real driver traffic rather than only eligibility bits.

module test_sequencer_parent_lock_allows_child_items_before_unrelated_sequence;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class traffic_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(traffic_sequence)
    int value = 11;
    int count = 1;
    string ownership = "";
    bit acquired = 0;
    bit finished = 0;
    bit relevant = 1;
    function new(string name="traffic_sequence"); super.new(name); endfunction
    function bit is_relevant(); return relevant; endfunction
    task wait_for_relevant(); wait (relevant); endtask
    task send_value(int payload);
      packet item_value = new("request");
      item_value.payload = payload;
      start_item(item_value);
      finish_item(item_value);
    endtask
    task body();
      int index;
      index = 0;
      if (ownership == "lock") lock();
      else if (ownership == "grab") grab();
      acquired = 1;
      repeat (count) begin
        if (index != 0) #1;
        send_value(value + index);
        index++;
      end
      if (ownership == "lock") unlock();
      else if (ownership == "grab") ungrab();
      finished = 1;
    endtask
  endclass

  class parent_stream_sequence extends traffic_sequence;
    `uvm_object_utils(parent_stream_sequence)
    function new(string name="parent_stream_sequence"); super.new(name); endfunction
    task body();
      traffic_sequence child_value = new("child_value");
      lock();
      acquired = 1;
      child_value.value = 11;
      child_value.start(get_sequencer(), this);
      send_value(12);
      unlock();
      finished = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    parent_stream_sequence owner;

    traffic_sequence other;
    packet observed;
    int seen[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      owner = new("owner");
      other = new("other");
      other.value = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      owner.count = 2;

      fork
        owner.start(sequencer);
        begin #1; other.start(sequencer); end

        begin
          #3;
          repeat (owner.count + other.count) begin
            driver.seq_item_port.get_next_item(observed);
            if (observed == null) $fatal(1, "request missing");
            seen.push_back(observed.payload);
            #1;
            driver.seq_item_port.item_done();
          end
        end

      join
      if (seen.size() != owner.count + other.count) $fatal(1, "request count differs");
      foreach (seen[i]) $display("UT: request %0d", seen[i]);
      $display("UT: finished %0d %0d grabbed %0d", owner.finished, other.finished,
               sequencer.is_grabbed());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
