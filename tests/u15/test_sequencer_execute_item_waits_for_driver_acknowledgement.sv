/*
:name: test_sequencer_execute_item_waits_for_driver_acknowledgement
:description: execute_item delivers the given transaction and waits for its driver acknowledgement (IEEE 1800.2-2020 Section 15.3.2.5)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.5 15.5.2.3 15.5.2.5 15.5.2.2 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_execute_item_waits_for_driver_acknowledgement.expected
*/
// Submit a packet directly with execute_item. Observe the same handle and
// blocked caller before item_done, without inspecting its synthetic parent.

module test_sequencer_execute_item_waits_for_driver_acknowledgement;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_driver#(packet) driver;
    packet submitted;
    packet observed;
    bit returned = 0;

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      submitted = new("submitted");
      submitted.payload = 77;
      submitted.set_transaction_id(777);

      fork
        begin
          sequencer.execute_item(submitted);
          returned = 1;
        end
        begin
          driver.seq_item_port.get_next_item(observed);
          if (observed == null) $fatal(1, "request missing");
          #1;
          $display("UT: payload %0d same %0d returned_before_ack %0d", observed.payload,
                   observed == submitted, returned);
          driver.seq_item_port.item_done();
        end
      join

      $display("UT: returned_after_ack %0d", returned);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
