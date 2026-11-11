/*
:name: test_tlm2_custom_transaction_passthrough_initiator_routes_both_directions
:description: nonblocking pass-through initiator routes a custom transaction in both directions (IEEE 1800.2-2020 Section 12.3.5.5.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.5.4 12.3.5.3.1 12.3.5.4.1 12.3.5.4.4 12.3.2.2.1 12.3.2.2.2 12.3.3.1 12.3.3.2 12.3.9 5.6.2.8 5.6.2.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_custom_transaction_passthrough_initiator_routes_both_directions.expected
*/
// What it checks:
// 1. A custom-typed pass-through initiator socket routes the forward call.
// 2. Pass-through connect automatically wires the custom-transaction backward
//    route.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5.5.4 (UVM-TLM2-CUSTOM-INITIATOR-FORWARD-ROUTE) gives
//    rule 1 above. Setup: Resolve normal hierarchy bindings and call BEGIN_REQ
//    with one custom object. Expected: The endpoint receives the original
//    handles/phase once, writes reply 42 and returns ACCEPTED.
// 2. 1800.2-2020 12.3.5.5.4 (UVM-TLM2-CUSTOM-INITIATOR-BACKWARD-ROUTE) gives
//    rule 2 above. Setup: Send BEGIN_RESP from the bound target after the
//    accepted request. Expected: The original caller receives the original
//    handles once; COMPLETED, END_RESP, completion and a 9 ns annotation
//    return without waiting.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a custom object transaction with the standard phase enumeration.
// One pass-through node must also establish the automatic backward route.
// This is an interface-routing probe, not a full timed base-protocol model.
module test_tlm2_custom_transaction_passthrough_initiator_routes_both_directions;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class custom_transaction extends uvm_object;
    int request = 0;
    int reply = 0;
    bit complete = 0;
    function new(string name="custom"); super.new(name); endfunction
  endclass

  class endpoint extends uvm_component;
    uvm_tlm_nb_target_socket#(endpoint, custom_transaction) socket;
    custom_transaction stored;
    uvm_tlm_time stored_delay;
    int calls = 0;
    uvm_tlm_sync_e backward_result;
    uvm_tlm_phase_e backward_phase;
    bit request_phase = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(custom_transaction t, ref uvm_tlm_phase_e p,
    input uvm_tlm_time delay);
      calls++; stored = t; stored_delay = delay; request_phase = p == BEGIN_REQ;
      t.reply = t.request + 7;
      delay.set_abstime(delay.get_abstime(1.0e-9) + 3.0, 1.0e-9);
      return UVM_TLM_ACCEPTED;
    endfunction
    function void respond();
      uvm_tlm_phase_e p = BEGIN_RESP;
      stored.complete = 1;
      backward_result = socket.nb_transport_bw(stored, p, stored_delay);
      backward_phase = p;
    endfunction
  endclass
  class caller extends uvm_component;
    uvm_tlm_nb_initiator_socket#(caller, custom_transaction) socket;
    custom_transaction expected;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit same_handles = 0;
    bit response_phase = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(custom_transaction t, ref uvm_tlm_phase_e p,
    input uvm_tlm_time delay);
      calls++; same_handles = t == expected && delay == expected_delay;
      response_phase = p == BEGIN_RESP;
      p = END_RESP; delay.set_abstime(delay.get_abstime(1.0e-9) + 4.0, 1.0e-9);
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class shell extends uvm_component;
    uvm_tlm_nb_passthrough_initiator_socket#(custom_transaction) socket;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    caller initiator;
    endpoint target;
    shell relay;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      relay = new("relay", this);
      initiator = new("initiator", relay);
      target = new("target", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.socket.connect(relay.socket); relay.socket.connect(target.socket);
    endfunction
    task run_phase(uvm_phase phase);
      custom_transaction item = new();
      uvm_tlm_time delay_value = new("delay", 1.0e-12);
      uvm_tlm_phase_e phase_value = BEGIN_REQ;
      uvm_tlm_sync_e result;
      time before_time;
      real annotation;
      phase.raise_objection(this);
      item.request = 35; delay_value.set_abstime(2.0, 1.0e-9);
      initiator.expected = item; initiator.expected_delay = delay_value;
      before_time = $time;
      result = initiator.socket.nb_transport_fw(item, phase_value, delay_value);
      $display("UT: forward accepted %0d calls %0d phase %0d identity %0d reply %0d",
      result == UVM_TLM_ACCEPTED, target.calls, target.request_phase, target.stored == item &&
      target.stored_delay == delay_value, item.reply);
      target.respond(); annotation = delay_value.get_abstime(1.0e-9);
      $display("UT: backward completed %0d calls %0d phase %0d identity %0d end %0d",
      target.backward_result == UVM_TLM_COMPLETED, initiator.calls, initiator.response_phase,
      initiator.same_handles, target.backward_phase == END_RESP);
      $display("UT: transaction complete %0d annotation %0d no_wait %0d", item.complete,
      annotation > 8.999999 && annotation < 9.000001, $time == before_time);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "transport watchdog expired"); end

endmodule
