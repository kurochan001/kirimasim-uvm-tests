/*
:name: test_tlm2_two_outstanding_socket_responses_keep_reversed_payloads_and_annotations_separate
:description: two outstanding socket transactions retain separate handles and annotations under reversed responses (IEEE 1800.2-2020 Section 12.3.2.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.2 12.3.2.2.1 12.3.3.1 12.3.3.2 12.3.5.3.3 12.3.5.4.3 12.3.5.4.4 12.3.5.5.4 12.3.5.6.4 12.3.9 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_two_outstanding_socket_responses_keep_reversed_payloads_and_annotations_separate.expected
*/
// What it checks:
// Backward socket forwarding preserves separately supplied transaction
// contexts when responses arrive in reverse order.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.2.2.2 (UVM-TLM2-REVERSED-RESPONSE-CONTEXT) gives the rule
// above. Setup: End each request phase before issuing the next, then respond
// to the second before the first. Expected: The observed response order is 42
// then 17, while each payload status and delay remains independent.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Testbench code drives selected protocol histories with positive delays.
// Socket forwarding is checked; UVM is not required to invent a scheduler,
// enforce every base-protocol rule or own outstanding-transaction state.
module test_tlm2_two_outstanding_socket_responses_keep_reversed_payloads_and_annotations_separate;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  function bit near(real value, real expected_value);
    return value > expected_value - 0.000001 && value < expected_value + 0.000001;
  endfunction
  class nb_target extends uvm_component;
    uvm_tlm_nb_target_socket#(nb_target) socket;
    uvm_tlm_generic_payload expected_payload[2];
    uvm_tlm_time expected_delay[2];
    uvm_tlm_generic_payload saved_payload[2];
    uvm_tlm_time saved_delay[2];
    bit done[2];
    int forward_calls = 0;
    bit identities = 1;
    bit updated_request = 0;
    uvm_tlm_phase_e returned_phase;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload payload,
        ref uvm_tlm_phase_e phase_value, input uvm_tlm_time delay_value);
      int index_value;
      index_value = payload == expected_payload[1] ? 1 : 0;
      identities &= payload == expected_payload[index_value] &&
                    delay_value == expected_delay[index_value];
      forward_calls++;
      delay_value.set_abstime(delay_value.get_abstime(1.0e-9) + 1.0, 1.0e-9);
      if (phase_value == BEGIN_REQ) begin
        saved_payload[index_value] = payload; saved_delay[index_value] = delay_value;
        done[index_value] = 0;
        if (updated_request) begin phase_value = END_REQ; return UVM_TLM_UPDATED; end
        return UVM_TLM_ACCEPTED;
      end
      if (phase_value != END_RESP) $fatal(1, "unexpected testbench forward phase");
      done[index_value] = 1;
      return UVM_TLM_COMPLETED;
    endfunction
    function uvm_tlm_sync_e send_backward(int index_value, uvm_tlm_phase_e selected_phase);
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      phase_value = selected_phase;
      if (saved_payload[index_value] == null || saved_delay[index_value] == null)
        $fatal(1, "testbench request context missing");
      if (selected_phase == BEGIN_RESP)
        saved_payload[index_value].set_response_status(UVM_TLM_OK_RESPONSE);
      result = socket.nb_transport_bw(saved_payload[index_value], phase_value,
                                      saved_delay[index_value]);
      returned_phase = phase_value;
      if (selected_phase == BEGIN_RESP && (result == UVM_TLM_COMPLETED ||
          (result == UVM_TLM_UPDATED && phase_value == END_RESP))) done[index_value] = 1;
      return result;
    endfunction
  endclass
  class nb_initiator extends uvm_component;
    uvm_tlm_nb_initiator_socket#(nb_initiator) socket;
    uvm_tlm_generic_payload expected_payload[2];
    uvm_tlm_time expected_delay[2];
    int backward_calls = 0;
    int end_requests = 0;
    int responses = 0;
    int response_mode = 0;
    bit identities = 1;
    uvm_reg_addr_t response_order[$];
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this, this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload payload,
        ref uvm_tlm_phase_e phase_value, input uvm_tlm_time delay_value);
      int index_value;
      index_value = payload == expected_payload[1] ? 1 : 0;
      identities &= payload == expected_payload[index_value] &&
                    delay_value == expected_delay[index_value];
      backward_calls++;
      delay_value.set_abstime(delay_value.get_abstime(1.0e-9) + 2.0, 1.0e-9);
      if (phase_value == END_REQ) begin end_requests++; return UVM_TLM_ACCEPTED; end
      if (phase_value != BEGIN_RESP) $fatal(1, "unexpected testbench backward phase");
      responses++; response_order.push_back(payload.get_address());
      if (response_mode == 1) begin phase_value = END_RESP; return UVM_TLM_UPDATED; end
      if (response_mode == 2) return UVM_TLM_COMPLETED;
      return UVM_TLM_ACCEPTED;
    endfunction
  endclass
  class initiator_shell extends uvm_component;
    uvm_tlm_nb_passthrough_initiator_socket#() socket;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this);
    endfunction
  endclass
  class target_shell extends uvm_component;
    uvm_tlm_nb_passthrough_target_socket#() socket;
    function new(string name, uvm_component parent);
      super.new(name, parent); socket = new("socket", this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    nb_initiator initiator;
    nb_target target;
    initiator_shell left;
    target_shell right;
    uvm_tlm_generic_payload payloads[2];
    uvm_tlm_time delays[2];
    bit calls_do_not_wait = 1;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      left = new("left", this); right = new("right", this);
      initiator = new("initiator", left); target = new("target", right);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.socket.connect(left.socket); left.socket.connect(right.socket);
      right.socket.connect(target.socket);
    endfunction
    function uvm_tlm_sync_e forward(int index_value, ref uvm_tlm_phase_e phase_value);
      time before_call;
      uvm_tlm_sync_e result;
      before_call = $time;
      result = initiator.socket.nb_transport_fw(payloads[index_value], phase_value,
                                                delays[index_value]);
      calls_do_not_wait &= $time == before_call;
      return result;
    endfunction
    function uvm_tlm_sync_e backward(int index_value, uvm_tlm_phase_e phase_value);
      time before_call;
      uvm_tlm_sync_e result;
      before_call = $time; result = target.send_backward(index_value, phase_value);
      calls_do_not_wait &= $time == before_call;
      return result;
    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_sync_e result;
      uvm_tlm_phase_e phase_value;
      phase.raise_objection(this);
      for (int index_value = 0; index_value < 2; index_value++) begin
        payloads[index_value] = new($sformatf("payload%0d", index_value));
        delays[index_value] = new($sformatf("delay%0d", index_value), 1.0e-12);
        payloads[index_value].set_command(UVM_TLM_IGNORE_COMMAND);
        payloads[index_value].set_data_length(0);
        payloads[index_value].set_address(index_value == 0 ? 17 : 42);
        payloads[index_value].set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
        delays[index_value].set_abstime(index_value == 0 ? 10.0 : 20.0, 1.0e-9);
        target.expected_payload[index_value] = payloads[index_value];
        target.expected_delay[index_value] = delays[index_value];
        initiator.expected_payload[index_value] = payloads[index_value];
        initiator.expected_delay[index_value] = delays[index_value];
      end

      initiator.response_mode = 2;
      phase_value = BEGIN_REQ; result = forward(0, phase_value);
      #1; result = backward(0, END_REQ);
      phase_value = BEGIN_REQ; result = forward(1, phase_value);
      #1; result = backward(1, END_REQ);
      $display("UT: pending both %0d end_requests %0d responses %0d",
               !target.done[0] && !target.done[1], initiator.end_requests, initiator.responses);
      #1; result = backward(1, BEGIN_RESP);
      $display("UT: second completed %0d first_pending %0d status_isolated %0d delays %0d/%0d",
               result == UVM_TLM_COMPLETED && target.done[1], !target.done[0],
               payloads[1].is_response_ok() &&
               payloads[0].get_response_status() == UVM_TLM_INCOMPLETE_RESPONSE,
               near(delays[0].get_abstime(1.0e-9), 13), near(delays[1].get_abstime(1.0e-9), 25));
      #1; result = backward(0, BEGIN_RESP);
      $display("UT: first completed %0d both_done %0d annotations %0d/%0d",
               result == UVM_TLM_COMPLETED, target.done[0] && target.done[1],
               near(delays[0].get_abstime(1.0e-9), 15), near(delays[1].get_abstime(1.0e-9), 25));
      $display("UT: response_order %0d %0d", initiator.response_order[0],
               initiator.response_order[1]);

      $display("UT: identity %0d no_wait %0d fw %0d bw %0d", target.identities &&
               initiator.identities, calls_do_not_wait, target.forward_calls,
               initiator.backward_calls);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "TLM 2 protocol-history watchdog expired"); end
endmodule
