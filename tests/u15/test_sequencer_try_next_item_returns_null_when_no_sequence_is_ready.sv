/*
:name: test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready
:description: try_next_item returns null on repeated polls when there are no requesting sequences (IEEE 1800.2-2020 Section 15.5.2.4)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.5.2.4 15.4.1 15.3.3.1 15.5.2.2 15.3.2.22 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready.expected
*/
// What it checks:
// try_next_item returns a null request when no sequence can supply an item.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.5.2.4 (UVM-SEQUENCER-EMPTY-TRY) gives the rule above. Setup:
// An idle sequencer receives two nonblocking requests with no active producer.
// Expected: Both requests and the current item remain null; no request is
// generated.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Poll an idle connected sequencer twice, first with a non-null sentinel.
// A null result does not require an item_done acknowledgement.

module test_sequencer_try_next_item_returns_null_when_no_sequence_is_ready;
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
    packet observed;

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
      observed = new("sentinel");

      driver.seq_item_port.try_next_item(observed);
      $display("UT: first_null %0d", observed == null);
      driver.seq_item_port.try_next_item(observed);
      $display("UT: second_null %0d current_null %0d requests %0d", observed == null,
               sequencer.get_current_item() == null, sequencer.get_num_reqs_sent());

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
