/*
:name: test_sequencer_has_do_available_tracks_relevance_eligibility
:description: has_do_available recognizes a pending request only when ownership and relevance allow it (IEEE 1800.2-2020 Section 15.3.2.17)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.17 15.3.2.8 15.3.2.10 15.3.2.12 14.2.5.3 14.2.5.4 14.2.6.2 14.2.6.3 15.5.2.3 15.5.2.5 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_has_do_available_tracks_relevance_eligibility.expected
*/
// Queue a request before the driver starts. Observe availability while
// it is ineligible and immediately after opening its gate. The driver
// then consumes the request, leaving no available work.

module test_sequencer_has_do_available_tracks_relevance_eligibility;
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

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    traffic_sequence worker;
    traffic_sequence owner;
    packet observed;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      worker = new("worker");
      worker.value = 22;
      owner = new("owner");
      owner.set_sequencer(sequencer);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      worker.relevant = 0;

      fork
        worker.start(sequencer);
        begin
          #1;
          $display("UT: gated_available %0d", sequencer.has_do_available());
          worker.relevant = 1;

          $display("UT: open_available %0d", sequencer.has_do_available());
        end
        begin
          #3;
          driver.seq_item_port.get_next_item(observed);
          if (observed == null) $fatal(1, "request missing");
          #1;
          driver.seq_item_port.item_done();
        end
      join
      $display("UT: payload %0d finished %0d idle_available %0d", observed.payload, worker.finished,
               sequencer.has_do_available());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
