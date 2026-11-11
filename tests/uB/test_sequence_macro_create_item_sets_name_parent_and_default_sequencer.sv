/*
:name: test_sequence_macro_create_item_sets_name_parent_and_default_sequencer
:description: sequence action macro applies the prescribed creation execution and randomization steps (IEEE 1800.2-2020 Section B.3.1.1)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.1.1 14.2.6.1 14.1.2.7 14.1.2.5 1800-2023 6.21 18.6.2 18.7
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_macro_create_item_sets_name_parent_and_default_sequencer.expected
*/
// What it checks:
// The create action initializes the named child through create_item with the
// selected sequencer.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.3.1.1 (UVM-SEQUENCE-MACRO-CREATE-CONTEXT) gives the rule
// above. Setup: Create either an item with the default sequencer or a sequence
// with an alternate sequencer. Expected: Name, parent and sequencer agree;
// creation alone does not execute or randomize the child.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Create an item without sending or randomizing it. Check the macro
// argument name, parent sequence and default sequencer context.

module test_sequence_macro_create_item_sets_name_parent_and_default_sequencer;
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
      $display("UT: name %s parent_same %0d sequencer_same %0d randomizations %0d",
               item.get_name(), item.get_parent_sequence() == this,
               item.get_sequencer() == get_sequencer(), item.randomizations);
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
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
