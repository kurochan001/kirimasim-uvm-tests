/*
:name: test_sequencer_user_arbitration_can_prefer_later_lower_priority_request
:description: sequencer arbitration selects among two pending requests according to its configured mode (IEEE 1800.2-2020 Section 15.3.2.19)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.19 F.2.4.1 15.5.2.3 15.5.2.5 14.2.3.1 14.2.6.2 14.2.6.3 15.3.2.22 15.3.2.3 15.3.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_user_arbitration_can_prefer_later_lower_priority_request.expected
*/
// Separate request arrival times by one time unit and start the driver
// after both requests have waited. Compare only the order prescribed by
// the selected mode; random-mode output reports membership instead.
// USER cases require a callback with two candidates, not one-candidate
// behavior.

module test_sequencer_user_arbitration_can_prefer_later_lower_priority_request;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class request_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(request_sequence)
    int value = 0;
    bit finished = 0;
    function new(string name="request_sequence"); super.new(name); endfunction
    task body();
      packet item_value = new("request");
      item_value.payload = value;
      start_item(item_value);
      finish_item(item_value);
      finished = 1;
    endtask
  endclass

  class user_sequencer extends uvm_sequencer#(packet);
    `uvm_component_utils(user_sequencer)
    uvm_sequence_base preferred;
    bit competing_call = 0;
    bit candidates_valid = 1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function int user_priority_arbitration(int avail_sequences[$]);
      uvm_sequence_base candidate;
      int choice;
      if (avail_sequences.size() == 0) $fatal(1, "missing candidate");
      choice = avail_sequences[0];
      if (avail_sequences.size() > 1) competing_call = 1;
      foreach (avail_sequences[i]) begin
        candidate = get_arbitration_sequence(avail_sequences[i]);
        if (candidate == null) candidates_valid = 0;
        if (candidate == preferred) choice = avail_sequences[i];
      end
      return choice;
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    user_sequencer sequencer;

    uvm_driver#(packet) driver;
    request_sequence first;
    request_sequence second;
    packet observed;
    int seen[$];
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      first = new("first");
      second = new("second");
      first.value = 11;
      second.value = 22;
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      sequencer.set_arbitration(UVM_SEQ_ARB_USER);
      sequencer.preferred = second;

      fork
        begin
          first.start(sequencer, null, 80);

        end
        begin
          #1; second.start(sequencer, null, 10);

        end
        begin
          #3;
          repeat (2) begin
            driver.seq_item_port.get_next_item(observed);
            if (observed == null) $fatal(1, "request missing");
            seen.push_back(observed.payload);
            #1;
            driver.seq_item_port.item_done();
          end
        end
      join

      if (seen.size() != 2) $fatal(1, "request count differs");
      $display("UT: order %0d %0d", seen[0], seen[1]);

      $display("UT: competing_callback %0d valid_candidates %0d", sequencer.competing_call,
               sequencer.candidates_valid);
      $display("UT: finished %0d %0d", first.finished, second.finished);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
