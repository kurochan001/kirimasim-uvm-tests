/*
:name: test_sequence_finish_item_orders_mid_mutation_before_send_and_post_after_ack
:description: finish_item publishes mid_do mutation before submission and invokes post_do after acknowledgement (IEEE 1800.2-2020 Section 14.2.6.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.3 14.2.6.5 14.2.6.6 14.2.3.5 14.2.3.7 5.4.2.17 5.4.2.18 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_finish_item_orders_mid_mutation_before_send_and_post_after_ack.expected
*/
// What it checks:
// 1. finish_item invokes mid_do before request submission with the original
//    item.
// 2. finish_item invokes post_do after sequencer acknowledgement with the
//    original item.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.2.6.3 (UVM-SEQUENCE-FINISH-MID-BEFORE-SUBMISSION) gives
//    rule 1 above. Setup: Let mid_do mutate the request value from 17 to 55.
//    Expected: One mid hook has the original handle and both
//    submitted/delivered data are 55.
// 2. 1800.2-2020 14.2.6.3 (UVM-SEQUENCE-FINISH-POST-AFTER-ACKNOWLEDGEMENT)
//    gives rule 2 above. Setup: Acknowledge the driver item after positive
//    delay. Expected: One post hook receives the original handle and observes
//    acknowledgement already complete.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Mutate the request in mid_do, snapshot it at the public sequencer send
// API, and acknowledge after a positive delay. Inspect the exact hook
// arguments and post-do acknowledgement state without changing wait behavior.

module test_sequence_finish_item_orders_mid_mutation_before_send_and_post_after_ack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class audit;
    static bit mid_seen = 0;
    static bit acknowledged = 0;
  endclass
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int value = 17;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class observed_sequencer extends uvm_sequencer#(packet);
    `uvm_component_utils(observed_sequencer)
    int completion_ids[$];
    int sent_value = 0;
    bit mid_before_send = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void send_request(uvm_sequence_base sequence_ptr, uvm_sequence_item t,
        bit rerandomize=0);
      packet typed;
      if (!$cast(typed, t) || typed == null) $fatal(1, "wrong request type");
      sent_value = typed.value;
      mid_before_send = audit::mid_seen;
      super.send_request(sequence_ptr, t, rerandomize);
    endfunction
    task wait_for_item_done(uvm_sequence_base sequence_ptr, int transaction_id);
      completion_ids.push_back(transaction_id);
      super.wait_for_item_done(sequence_ptr, transaction_id);
    endtask
  endclass
  class producer extends uvm_sequence#(packet);
    `uvm_object_utils(producer)
    int ids[$] = '{33};
    packet items[$];
    int send_calls = 0;
    int wait_calls = 0;
    bit seen_rerandomize = 1;
    int seen_wait_id = -9;
    int mid_calls = 0;
    int post_calls = 0;
    packet mid_argument;
    packet post_argument;
    bit mutate_mid = 0;
    bit post_after_ack = 0;
    bit done = 0;
    function new(string name="producer"); super.new(name); endfunction
    function void send_request(uvm_sequence_item request, bit rerandomize=0);
      send_calls++;
      seen_rerandomize = rerandomize;
      super.send_request(request, rerandomize);
    endfunction
    task wait_for_item_done(int transaction_id=-1);
      wait_calls++;
      seen_wait_id = transaction_id;
      super.wait_for_item_done(transaction_id);
    endtask
    function void mid_do(uvm_sequence_item this_item);
      if (!$cast(mid_argument, this_item) || mid_argument == null) $fatal(1, "wrong mid argument");
      mid_calls++;
      audit::mid_seen = 1;
      if (mutate_mid) mid_argument.value = 55;
    endfunction
    function void post_do(uvm_sequence_item this_item);
      if (!$cast(post_argument, this_item) || post_argument == null) $fatal(1,
          "wrong post argument");
      post_calls++;
      post_after_ack = audit::acknowledged;
    endfunction
    task body();
      packet item;
      foreach (ids[i]) begin
        item = new("item");
        item.set_transaction_id(ids[i]);
        items.push_back(item);
        start_item(item);
        finish_item(item);
      end
      done = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    observed_sequencer sequencer;
    uvm_driver#(packet) driver;
    producer value;
    packet received;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      value = new("value");
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      value.mutate_mid = 1;
      fork value.start(sequencer); join_none
      repeat (value.ids.size()) begin
        driver.seq_item_port.get_next_item(received);
        #1;
        audit::acknowledged = 1;
        driver.seq_item_port.item_done();
      end
      wait (value.done);
      $display("UT: mid_before_send %0d submitted %0d received %0d", sequencer.mid_before_send,
               sequencer.sent_value, received.value);
      $display("UT: hooks %0d %0d same_arguments %0d %0d post_after_ack %0d", value.mid_calls,
               value.post_calls, value.mid_argument == received, value.post_argument == received,
               value.post_after_ack);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
