/*
:name: test_tlm2_nested_passthrough_targets_route_both_directions
:description: TLM 2 nonblocking pass-through sockets preserve forward and automatic backward routing (IEEE 1800.2-2020 Section 12.3.5.5.4)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.5.4 12.3.5.6.4 12.3.5.3.3 12.3.5.4.3 12.3.5.4.4 12.3.2.2.1 12.3.2.2.2 12.3.3.1 12.3.3.2 12.3.9 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_passthrough_targets_route_both_directions.expected
*/
// Use proper parent-port and child-export hierarchy and let socket
// connect methods wire the backward path. Transfer one IGNORE payload
// and one canonical delay handle; callbacks annotate time without
// waiting. Observe identity, status and phase-reference updates after
// normal binding resolution, without inspecting internal port storage.

module test_tlm2_nested_passthrough_targets_route_both_directions;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class nb_target extends uvm_component;
    `uvm_component_utils(nb_target)
    uvm_tlm_nb_target_socket#(nb_target) socket;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    uvm_tlm_generic_payload stored_payload;
    uvm_tlm_time stored_delay;
    int calls = 0;
    bit immediate = 0;
    bit identity_ok = 0;
    bit request_phase_ok = 0;
    uvm_tlm_sync_e response_result = UVM_TLM_ACCEPTED;
    uvm_tlm_phase_e response_phase = UNINITIALIZED_PHASE;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      real previous;
      calls++;
      identity_ok = t == expected_payload && delay == expected_delay;
      request_phase_ok = p == BEGIN_REQ;
      stored_payload = t;
      stored_delay = delay;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 3.0, 1.0e-9);
      if (immediate) begin
        t.set_response_status(UVM_TLM_OK_RESPONSE);
        return UVM_TLM_COMPLETED;
      end
      return UVM_TLM_ACCEPTED;
    endfunction
    function void respond();
      uvm_tlm_phase_e phase_value;
      real previous;
      if (stored_payload == null || stored_delay == null) $fatal(1, "forward request missing");
      phase_value = BEGIN_RESP;
      stored_payload.set_response_status(UVM_TLM_OK_RESPONSE);
      previous = stored_delay.get_abstime(1.0e-9);
      stored_delay.set_abstime(previous + 4.0, 1.0e-9);
      response_result = socket.nb_transport_bw(stored_payload, phase_value, stored_delay);
      response_phase = phase_value;
    endfunction
  endclass
  class nb_initiator extends uvm_component;
    `uvm_component_utils(nb_initiator)
    uvm_tlm_nb_initiator_socket#(nb_initiator) socket;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit updated = 0;
    bit identity_ok = 0;
    bit response_phase_ok = 0;
    bit annotation_ok = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      real previous;
      calls++;
      identity_ok = t == expected_payload && delay == expected_delay;
      response_phase_ok = p == BEGIN_RESP;
      previous = delay.get_abstime(1.0e-9);
      annotation_ok = previous > 8.999999 && previous < 9.000001;
      delay.set_abstime(previous + 1.0, 1.0e-9);
      p = END_RESP;
      if (updated) return UVM_TLM_UPDATED;
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class initiator_shell extends uvm_component;
    `uvm_component_utils(initiator_shell)
    uvm_tlm_nb_passthrough_initiator_socket#() socket;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this);
    endfunction
  endclass
  class target_shell extends uvm_component;
    `uvm_component_utils(target_shell)
    uvm_tlm_nb_passthrough_target_socket#() socket;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    nb_initiator initiator;
    nb_target target;
    initiator_shell left;
    initiator_shell inner_left;
    target_shell right;
    target_shell inner_right;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      right = new("right", this);
      inner_right = new("inner_right", right);
      initiator = new("initiator", this);
      target = new("target", inner_right);

    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.socket.connect(right.socket);
      right.socket.connect(inner_right.socket);
      inner_right.socket.connect(target.socket);

    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay", 1.0e-12);
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      real annotation;
      time before_time;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_data_length(0);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      delay_value.set_abstime(2.0, 1.0e-9);
      target.expected_payload = payload;
      target.expected_delay = delay_value;
      initiator.expected_payload = payload;
      initiator.expected_delay = delay_value;
      target.immediate = 0;
      initiator.updated = 0;

      phase_value = BEGIN_REQ;
      before_time = $time;

      result = initiator.socket.nb_transport_fw(payload, phase_value, delay_value);
      annotation = delay_value.get_abstime(1.0e-9);
      $display("UT: forward_identity %0d request_phase %0d calls %0d annotation %0d",
          target.identity_ok,
               target.request_phase_ok, target.calls,
                   annotation > 4.999999 && annotation < 5.000001);

      $display("UT: accepted %0d", result == UVM_TLM_ACCEPTED);
      target.respond();
      annotation = delay_value.get_abstime(1.0e-9);
      $display("UT: backward_identity %0d response_phase %0d calls %0d annotation %0d",
               initiator.identity_ok, initiator.response_phase_ok, initiator.calls,
                   initiator.annotation_ok);
      $display("UT: returned_status %0d end_response %0d final_annotation %0d ok %0d no_wait %0d",
               target.response_result == UVM_TLM_COMPLETED,
               target.response_phase == END_RESP, annotation > 9.999999 && annotation < 10.000001,
               payload.is_response_ok(), $time == before_time);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
