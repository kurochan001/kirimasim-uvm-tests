/*
:name: test_tlm2_nonblocking_round_trip_returns_backward_phase_update
:description: TLM 2 nonblocking forward acceptance is completed through a backward response with a phase update (IEEE 1800.2-2020 Section 12.3.2.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.1 12.3.2.2.2 12.3.6.2 12.3.6.3 12.3.8.2 12.3.8.3 12.3.3.1 12.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_round_trip_returns_backward_phase_update.expected
*/
// Perform one forward request and one backward response using public
// ports and imps. The same payload and delay handles travel both paths.

module test_tlm2_nonblocking_round_trip_returns_backward_phase_update;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class round_trip_target extends uvm_component;
    `uvm_component_utils(round_trip_target)
    uvm_tlm_nb_transport_fw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e,
        round_trip_target) forward_imp;
    uvm_tlm_nb_transport_bw_port#() backward_port;
    uvm_tlm_generic_payload stored_payload;
    uvm_tlm_time stored_delay;
    uvm_tlm_sync_e response_result = UVM_TLM_ACCEPTED;
    uvm_tlm_phase_e response_phase = UNINITIALIZED_PHASE;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      forward_imp = new("forward_imp", this);
      backward_port = new("backward_port", this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      stored_payload = t;
      stored_delay = delay;
      return UVM_TLM_ACCEPTED;
    endfunction
    function void respond();
      uvm_tlm_phase_e phase_value;
      if (stored_payload == null || stored_delay == null) $fatal(1, "forward request missing");
      phase_value = BEGIN_RESP;
      stored_payload.set_response_status(UVM_TLM_OK_RESPONSE);
      response_result = backward_port.nb_transport_bw(stored_payload, phase_value, stored_delay);
      response_phase = phase_value;
    endfunction
  endclass
  class round_trip_initiator extends uvm_component;
    `uvm_component_utils(round_trip_initiator)
    uvm_tlm_nb_transport_fw_port#() forward_port;
    uvm_tlm_nb_transport_bw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e,
        round_trip_initiator) backward_imp;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    int backward_calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      forward_port = new("forward_port", this);
      backward_imp = new("backward_imp", this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      backward_calls++;
      $display("UT: backward payload_same %0d delay_same %0d begin_resp %0d", t == expected_payload,
               delay == expected_delay, p == BEGIN_RESP);
      p = END_RESP;
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    round_trip_target target;
    round_trip_initiator initiator;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      target = new("target", this);
      initiator = new("initiator", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.forward_port.connect(target.forward_imp);
      target.backward_port.connect(initiator.backward_imp);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay_value");
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_data_length(0);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      initiator.expected_payload = payload;
      initiator.expected_delay = delay_value;
      phase_value = BEGIN_REQ;
      result = initiator.forward_port.nb_transport_fw(payload, phase_value, delay_value);
      $display("UT: accepted %0d stored_payload %0d stored_delay %0d", result == UVM_TLM_ACCEPTED,
               target.stored_payload == payload, target.stored_delay == delay_value);
      target.respond();
      $display("UT: completed %0d end_response %0d ok %0d callbacks %0d",
          target.response_result == UVM_TLM_COMPLETED,
               target.response_phase == END_RESP, payload.is_response_ok(),
                   initiator.backward_calls);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
