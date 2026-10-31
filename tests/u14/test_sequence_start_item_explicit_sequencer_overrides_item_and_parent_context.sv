/*
:name: test_sequence_start_item_explicit_sequencer_overrides_item_and_parent_context
:description: start_item explicit sequencer takes precedence over item and parent sequencers (IEEE 1800.2-2020 Section 14.2.6.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.2 14.2.6.3 14.1.2.2 14.1.2.5 14.1.2.7 14.2.5.1 15.3.2.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_start_item_explicit_sequencer_overrides_item_and_parent_context.expected
*/
// Provide three distinct sequencers and request through the explicit one.
// Observe normal arbitration, item context and pre/mid/post hooks; only the
// selected driver requests and acknowledges the transaction.

module test_sequence_start_item_explicit_sequencer_overrides_item_and_parent_context;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int value = 17;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class observed_sequencer extends uvm_sequencer#(packet);
    `uvm_component_utils(observed_sequencer)
    int grant_calls = 0;
    int seen_priority = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task wait_for_grant(uvm_sequence_base sequence_ptr, int item_priority=-1, bit lock_request=0);
      grant_calls++;
      seen_priority = item_priority;
      super.wait_for_grant(sequence_ptr, item_priority, lock_request);
    endtask
  endclass
  class producer extends uvm_sequence#(packet);
    `uvm_object_utils(producer)
    uvm_sequencer_base item_sequencer;
    uvm_sequencer_base explicit_sequencer;
    int requested_priority = -1;
    packet item;
    int pre_calls = 0;
    int mid_calls = 0;
    int post_calls = 0;
    bit pre_is_item = 0;
    bit done = 0;
    function new(string name="producer"); super.new(name); endfunction
    task pre_do(bit is_item); pre_calls++; pre_is_item = is_item; endtask
    function void mid_do(uvm_sequence_item this_item); mid_calls++; endfunction
    function void post_do(uvm_sequence_item this_item); post_calls++; endfunction
    task body();
      item = new("item");
      if (item_sequencer != null) item.set_sequencer(item_sequencer);
      start_item(item, requested_priority, explicit_sequencer);
      finish_item(item);
      done = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    observed_sequencer parent_sequencer;
    observed_sequencer item_sequencer;
    observed_sequencer explicit_sequencer;
    uvm_driver#(packet) parent_driver;
    uvm_driver#(packet) item_driver;
    uvm_driver#(packet) explicit_driver;
    producer sequence_value;
    packet received;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      parent_sequencer = new("parent_sequencer", this);
      item_sequencer = new("item_sequencer", this);
      explicit_sequencer = new("explicit_sequencer", this);
      parent_sequencer.disable_auto_item_recording();
      item_sequencer.disable_auto_item_recording();
      explicit_sequencer.disable_auto_item_recording();
      parent_driver = new("parent_driver", this);
      item_driver = new("item_driver", this);
      explicit_driver = new("explicit_driver", this);
      sequence_value = new("sequence_value");
    endfunction
    function void connect_phase(uvm_phase phase);
      parent_driver.seq_item_port.connect(parent_sequencer.seq_item_export);
      item_driver.seq_item_port.connect(item_sequencer.seq_item_export);
      explicit_driver.seq_item_port.connect(explicit_sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      sequence_value.item_sequencer = item_sequencer;
      sequence_value.explicit_sequencer = explicit_sequencer;
      fork sequence_value.start(parent_sequencer, null, 78); join_none
      explicit_driver.seq_item_port.get_next_item(received);
      $display("UT: selected %0d parent_same %0d priority %0d pre_calls %0d pre_is_item %0d",
               received.get_sequencer() == explicit_sequencer,
               received.get_parent_sequence() == sequence_value,
               explicit_sequencer.seen_priority, sequence_value.pre_calls,
                   sequence_value.pre_is_item);
      $display("UT: grants %0d %0d %0d", parent_sequencer.grant_calls,
               item_sequencer.grant_calls, explicit_sequencer.grant_calls);
      #1;
      explicit_driver.seq_item_port.item_done();
      wait (sequence_value.done);
      $display("UT: hooks %0d %0d %0d value %0d", sequence_value.pre_calls,
               sequence_value.mid_calls, sequence_value.post_calls, received.value);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
