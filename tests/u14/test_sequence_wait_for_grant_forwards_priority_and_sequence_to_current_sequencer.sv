/*
:name: test_sequence_wait_for_grant_forwards_priority_and_sequence_to_current_sequencer
:description: low-level grant forwards the explicit priority and originating sequence (IEEE 1800.2-2020 Section 14.2.6.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.6.4 15.3.2.6 14.2.6.5 14.2.6.6 15.3.2.20 15.3.2.22 1800-2023 6.21 18.6.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_wait_for_grant_forwards_priority_and_sequence_to_current_sequencer.expected
*/
// What it checks:
// Sequence grant waiting forwards its priority and originating sequence to the
// current sequencer.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.2.6.4 (UVM-SEQUENCE-GRANT-PRIORITY-ORIGIN-FORWARDING) gives
// the rule above. Setup: Request priority 123 on a bound sequence. Expected:
// The sequencer sees priority 123 and the exact origin; delivered context
// identifies that sequencer.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe the public sequencer API arguments in an override that delegates
// to the normal arbitration implementation. Deliver and acknowledge a real
// request, without substituting a mocked grant.

module test_sequence_wait_for_grant_forwards_priority_and_sequence_to_current_sequencer;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    rand int code;
    int randomizations = 0;
    constraint fixed_code { code == 91; }
    function new(string name="packet"); super.new(name); endfunction
    function void post_randomize(); randomizations++; endfunction
  endclass
  class grant_sequencer extends uvm_sequencer#(packet);
    `uvm_component_utils(grant_sequencer)
    int seen_priority = 0;
    bit seen_lock = 0;
    uvm_sequence_base seen_sequence;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual task wait_for_grant(uvm_sequence_base sequence_ptr, int item_priority=-1,
        bit lock_request=0);
      seen_priority = item_priority;
      seen_lock = lock_request;
      seen_sequence = sequence_ptr;
      super.wait_for_grant(sequence_ptr, item_priority, lock_request);
    endtask
  endclass
  class request_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(request_sequence)
    packet sent[$];
    int request_count = 1;
    int request_priority = -1;
    bit lock_request = 0;
    bit rerandomize_request = 0;
    bit use_default_send = 0;
    bit specific_completion = 0;
    int granted_count = 0;
    int completed_count = 0;
    bit done = 0;
    function new(string name="request_sequence"); super.new(name); endfunction
    task body();
      packet item;
      for (int i=0; i<request_count; i++) begin
        item = new("item");
        item.code = 37 + i;
        item.set_item_context(this, get_sequencer());
        item.set_transaction_id(50 + i);
        sent.push_back(item);
        wait_for_grant(request_priority, lock_request);
        granted_count++;
        if (use_default_send) send_request(item);
        else send_request(item, rerandomize_request);
        if (specific_completion) wait_for_item_done(item.get_transaction_id());
        else wait_for_item_done();
        completed_count++;
        if (lock_request) unlock();
      end
      done = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    grant_sequencer sequencer;
    uvm_driver#(packet) driver;
    request_sequence sequence_value;
    packet observed;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      driver = new("driver", this);
      sequence_value = new("sequence_value");
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      sequence_value.request_priority = 123;
      fork sequence_value.start(sequencer); join_none
      driver.seq_item_port.get_next_item(observed);
      $display("UT: priority %0d origin_same %0d sequencer_same %0d", sequencer.seen_priority,
               sequencer.seen_sequence == sequence_value, observed.get_sequencer() == sequencer);
      #1;
      driver.seq_item_port.item_done();
      wait (sequence_value.done);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
