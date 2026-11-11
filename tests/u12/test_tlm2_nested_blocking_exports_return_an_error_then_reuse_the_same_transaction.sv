/*
:name: test_tlm2_nested_blocking_exports_return_an_error_then_reuse_the_same_transaction
:description: Blocking TLM 2 nested exports return transaction status and support reuse after an error (IEEE 1800.2-2020 Section 12.3.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.3 12.3.6.1 12.3.7.1 12.3.8.1 12.3.4.2.36 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_blocking_exports_return_an_error_then_reuse_the_same_transaction.expected
*/
// What it checks:
// 1. A completed blocking transaction carries its execution status and can be
//    reused for a later call.
// 2. Compatible blocking transport exports forward through nested exports to
//    their implementation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.2.2.3 (UVM-TLM2-BLOCKING-ERROR-REUSE) gives rule 1
//    above. Setup: Reuse one payload/delay after an address error, correct the
//    address and retry through nested exports. Expected: Both calls block
//    until target completion; error then OK status and cumulative annotation
//    return on the original handles.
// 2. 1800.2-2020 12.3.7.1 (UVM-TLM2-BLOCKING-NESTED-EXPORT-TYPES) gives rule 2
//    above. Setup: Bind a port to outer/inner exports and an endpoint imp with
//    generic or custom transaction type. Expected: Callee observations and
//    completed caller results retain the original payload/delay identities
//    across the chain.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The target rejects the first address, then accepts a corrected retry.
// A blocking call returns no sync enum: status remains in the payload.

module test_tlm2_nested_blocking_exports_return_an_error_then_reuse_the_same_transaction;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_tlm_b_transport_imp#(uvm_tlm_generic_payload, endpoint) imp;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit same_handles = 1;
    bit entered = 0;
    bit completed = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    task b_transport(uvm_tlm_generic_payload payload, uvm_tlm_time delay);
      real previous;
      calls++;
      entered = 1;
      same_handles &= payload == expected_payload && delay == expected_delay;
      previous = delay.get_abstime(1.0e-9);
      #3;
      delay.set_abstime(previous + 4.0, 1.0e-9);
      if (payload.get_address() == 16) payload.set_response_status(UVM_TLM_OK_RESPONSE);
      else payload.set_response_status(UVM_TLM_ADDRESS_ERROR_RESPONSE);
      completed = 1;
    endtask
  endclass

  class relay extends uvm_component;
    `uvm_component_utils(relay)
    uvm_tlm_b_transport_export#(uvm_tlm_generic_payload) export_value;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_transport_port#() port_value;
    relay outer;
    relay inner;
    endpoint target;
    uvm_tlm_generic_payload payload;
    uvm_tlm_time delay_value;
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      outer = new("outer", this);
      inner = new("inner", outer);
      target = new("target", inner);
      payload = new("payload");
      delay_value = new("delay_value", 1.0e-12);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(outer.export_value);
      outer.export_value.connect(inner.export_value);
      inner.export_value.connect(target.imp);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_address(99);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      delay_value.set_abstime(2.0, 1.0e-9);
      target.expected_payload = payload;
      target.expected_delay = delay_value;
      fork
        begin port_value.b_transport(payload, delay_value); returned = 1; end
      join_none
      #1;
      $display("UT: error pending %0d entered %0d", !returned, target.entered);
      wait (returned);
      $display("UT: error completed %0d status %0d annotation %0d", target.completed,
               payload.get_response_status() == UVM_TLM_ADDRESS_ERROR_RESPONSE,
               annotation_is(delay_value, 6.0));
      returned = 0;
      target.entered = 0;
      target.completed = 0;
      payload.set_address(16);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      fork
        begin port_value.b_transport(payload, delay_value); returned = 1; end
      join_none
      #1;
      $display("UT: retry pending %0d entered %0d", !returned, target.entered);
      wait (returned);
      $display("UT: retry completed %0d ok %0d annotation %0d", target.completed,
               payload.is_response_ok(), annotation_is(delay_value, 10.0));
      $display("UT: reused handles %0d calls %0d", target.same_handles, target.calls);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
