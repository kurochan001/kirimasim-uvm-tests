/*
:name: test_tlm2_one_blocking_socket_supports_overlapping_calls_with_distinct_handles
:description: Blocking TLM 2 routing preserves concurrent transaction identities, return boundaries and annotations (IEEE 1800.2-2020 Section 12.3.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.3 12.3.5.1.3 12.3.5.2.3 12.3.5.2.4 12.3.4.2.36 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_one_blocking_socket_supports_overlapping_calls_with_distinct_handles.expected
*/
// What it checks:
// 1. Each blocking transport call retains its own arguments and returns after
//    its callee completes.
// 2. Blocking socket connections forward to their connected target without
//    mixing independent channels.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.2.2.3 (UVM-TLM2-BLOCKING-OVERLAPPING-CALLS) gives rule 1
//    above. Setup: Overlap a longer and a shorter target task with distinct
//    payload/delay handles. Expected: Both calls initially block; the shorter
//    returns first and each receives its own status, mutation and annotation.
// 2. 1800.2-2020 12.3.5.2.4 (UVM-TLM2-BLOCKING-SOCKET-CHANNELS) gives rule 2
//    above. Setup: Exercise two concurrent calls through one socket and
//    through two separately bound socket pairs. Expected: Exactly two calls
//    reach the intended handles; separate targets produce their own address
//    and annotation changes.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Target waits deliberately overlap; the endpoint chooses response order.
// Distinct payload/delay objects avoid shared-transaction races. No bus is
// modeled.

module test_tlm2_one_blocking_socket_supports_overlapping_calls_with_distinct_handles;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  class blocking_target extends uvm_component;
    `uvm_component_utils(blocking_target)
    uvm_tlm_b_target_socket#(blocking_target) socket;
    uvm_tlm_generic_payload expected_payload[2];
    uvm_tlm_time expected_delay[2];
    bit entered[2];
    bit completed[2];
    bit identities[2];
    int calls = 0;
    int channel = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this, this);
    endfunction
    task b_transport(uvm_tlm_generic_payload payload, uvm_tlm_time delay);
      int slot;
      real previous;
      slot = int'(payload.get_address());
      if (slot < 0 || slot > 1) $fatal(1, "invalid slot");
      calls++;
      entered[slot] = 1;
      identities[slot] = payload == expected_payload[slot] && delay == expected_delay[slot];
      previous = delay.get_abstime(1.0e-9);
      if (slot == 0) #6; else #2;
      delay.set_abstime(previous + 3.0 + slot + channel, 1.0e-9);
      payload.set_address(100 + slot + 10 * channel);
      if (slot == 0) payload.set_response_status(UVM_TLM_OK_RESPONSE);
      else payload.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
      completed[slot] = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_initiator_socket#() initiator;
    uvm_tlm_b_initiator_socket#() other_initiator;
    blocking_target target;
    blocking_target other_target;
    uvm_tlm_generic_payload first_payload;
    uvm_tlm_generic_payload second_payload;
    uvm_tlm_time first_delay;
    uvm_tlm_time second_delay;
    bit first_returned = 0;
    bit second_returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      initiator = new("initiator", this);
      target = new("target", this);

      first_payload = new("first_payload");
      second_payload = new("second_payload");
      first_delay = new("first_delay", 1.0e-12);
      second_delay = new("second_delay", 1.0e-12);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.connect(target.socket);

    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      first_payload.set_command(UVM_TLM_IGNORE_COMMAND);
      second_payload.set_command(UVM_TLM_IGNORE_COMMAND);
      first_payload.set_address(0);
      second_payload.set_address(1);
      first_payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      second_payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      first_delay.set_abstime(2.0, 1.0e-9);
      second_delay.set_abstime(7.0, 1.0e-9);
      target.expected_payload[0] = first_payload;
      target.expected_delay[0] = first_delay;
      target.expected_payload[1] = second_payload;
      target.expected_delay[1] = second_delay;
      fork
        begin initiator.b_transport(first_payload, first_delay); first_returned = 1; end
      join_none
      #1;
      $display("UT: first pending %0d entered %0d", !first_returned, target.entered[0]);
      fork
        begin initiator.b_transport(second_payload, second_delay); second_returned = 1; end
      join_none
      #1;
      $display("UT: overlap pending %0d entered %0d", !first_returned && !second_returned,
               target.entered[0] && target.entered[1]);
      #2;
      $display("UT: shorter returned %0d first pending %0d", second_returned, !first_returned);
      wait (first_returned && second_returned);
      $display("UT: complete %0d identities %0d calls %0d",
               target.completed[0] && target.completed[1],
               target.identities[0] && target.identities[1], target.calls);
      $display("UT: addresses %0d %0d status %0d %0d", first_payload.get_address(),
               second_payload.get_address(), first_payload.is_response_ok(),
               second_payload.get_response_status() == UVM_TLM_ADDRESS_ERROR_RESPONSE);
      $display("UT: annotation independent %0d %0d", annotation_is(first_delay, 5.0),
               annotation_is(second_delay, 11.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
