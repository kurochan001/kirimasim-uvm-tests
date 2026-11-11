/*
:name: test_sequence_macro_send_item_preserves_manual_value_without_randomizing
:description: sequence action macro applies the prescribed creation execution and randomization steps (IEEE 1800.2-2020 Section B.3.1.1)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.1 B.3.1.2 14.2.6.2 14.2.6.3 1800-2023 6.21 18.6.2 18.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_macro_send_item_preserves_manual_value_without_randomizing.expected
*/
// What it checks:
// The send action processes an item through start_item then finish_item
// without randomizing it.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.3.1.2 (UVM-SEQUENCE-MACRO-SEND-ITEM) gives the rule above.
// Setup: Send a pre-created item with a manual value and trace parent/driver
// hooks. Expected: The same item reaches the driver; execution hooks run
// without randomization hooks.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Assign a value after creation and send the item. The action must use
// start_item and finish_item without calling randomize.

module test_sequence_macro_send_item_preserves_manual_value_without_randomizing;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class action_item extends uvm_sequence_item;
    `uvm_object_utils(action_item)
    rand int code;
    int randomizations = 0;
    function new(string name="action_item"); super.new(name); endfunction
    function void post_randomize(); randomizations++; endfunction
  endclass
  class child_sequence extends uvm_sequence#(action_item);
    `uvm_object_utils(child_sequence)
    rand int code;
    int randomizations = 0;
    int pre_calls = 0;
    int body_calls = 0;
    int post_calls = 0;
    function new(string name="child_sequence"); super.new(name); endfunction
    function void post_randomize(); randomizations++; endfunction
    task pre_body(); pre_calls++; endtask
    task body(); body_calls++; endtask
    task post_body(); post_calls++; endtask
  endclass
  class action_driver extends uvm_driver#(action_item);
    `uvm_component_utils(action_driver)
    action_item seen;
    int count = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(seen);
        count++;
        seq_item_port.item_done();
      end
    endtask
  endclass

  class parent_sequence extends uvm_sequence#(action_item);
    `uvm_object_utils(parent_sequence)
    uvm_sequencer_base alternate;
    action_item item;
    child_sequence child;
    function new(string name="parent_sequence"); super.new(name); endfunction
    task body();
      `uvm_create(item)
      item.code = 23;
      `uvm_send(item)
      $display("UT: code %0d randomizations %0d parent_same %0d", item.code,
               item.randomizations, item.get_parent_sequence() == this);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(action_item) sequencer;
    uvm_sequencer#(action_item) alternate;
    action_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      alternate = new("alternate", this);
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      parent_sequence sequence_value;
      phase.raise_objection(this);
      sequence_value = new("sequence_value");
      sequence_value.alternate = alternate;
      sequence_value.start(sequencer);
      $display("UT: delivered %0d same_handle %0d", driver.count,
               driver.seen == sequence_value.item);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
