/*
:name: test_sequencer_stop_sequences_discards_held_request_and_accepts_fresh_item
:description: stop_sequences clears an unacknowledged request so a new sequence can use the sequencer (IEEE 1800.2-2020 Section 15.3.2.14)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.14 14.2.5.11 14.2.5.12 15.4.1 15.5.2.3 15.5.2.5 14.2.6.2 14.2.6.3 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_stop_sequences_discards_held_request_and_accepts_fresh_item.expected
*/
// Stop while the driver holds the old request. Do not acknowledge that
// flushed item; instead retrieve and acknowledge a newly started request
// through the same port. Shared fork state belongs to the test object.

module test_sequencer_stop_sequences_discards_held_request_and_accepts_fresh_item;
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

  class old_sequence extends traffic_sequence;
    `uvm_object_utils(old_sequence)
    int kills = 0;
    function new(string name="old_sequence"); super.new(name); endfunction
    function void do_kill(); kills++; endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    old_sequence first;
    traffic_sequence fresh;
    packet old_request;
    packet new_request;
    bit holding = 0;
    bit stopped = 0;
    bit first_returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      first = new("first");
      first.value = 11;
      fresh = new("fresh");
      fresh.value = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin first.start(sequencer); first_returned = 1; end
        begin
          driver.seq_item_port.get_next_item(old_request);
          if (old_request == null) $fatal(1, "old request missing");
          holding = 1;
          wait (stopped);
          driver.seq_item_port.get_next_item(new_request);
          if (new_request == null) $fatal(1, "new request missing");
          #1;
          driver.seq_item_port.item_done();
        end
        begin
          wait (holding);
          #1;
          sequencer.stop_sequences();
          stopped = 1;
          fresh.start(sequencer);
        end
      join
      $display("UT: payloads %0d %0d stopped %0d kills %0d returned %0d fresh_finished %0d",
               old_request.payload, new_request.payload, first.get_sequence_state() == UVM_STOPPED,
               first.kills, first_returned, fresh.finished);
      $display("UT: current_null %0d", sequencer.get_current_item() == null);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
