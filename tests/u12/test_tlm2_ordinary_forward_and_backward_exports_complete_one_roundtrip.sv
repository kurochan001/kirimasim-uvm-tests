/*
:name: test_tlm2_ordinary_forward_and_backward_exports_complete_one_roundtrip
:description: separately connected ordinary exports preserve both directions of a nonblocking transaction (IEEE 1800.2-2020 Section 12.3.7.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.7.2 12.3.7.3 12.3.8.2 12.3.8.3 12.3.6.2 12.3.6.3 12.3.2.2.1 12.3.2.2.2 12.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_ordinary_forward_and_backward_exports_complete_one_roundtrip.expected
*/
// Send an accepted request through the forward export and return a later
// response through a separately connected backward export. Preserve shared
// handles and annotations without relying on socket connection side effects.

module test_tlm2_ordinary_forward_and_backward_exports_complete_one_roundtrip;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  class response_receiver extends uvm_component;
    `uvm_component_utils(response_receiver)
    uvm_tlm_nb_transport_bw_export#() export_value;
    uvm_tlm_nb_transport_bw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e, response_receiver) imp;
    uvm_tlm_generic_payload seen_payload;
    uvm_tlm_time seen_delay;
    bit phase_ok = 0;
    int calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
      imp = new("imp", this);
    endfunction
    function void connect_phase(uvm_phase phase); export_value.connect(imp); endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      real previous;
      seen_payload = t;
      seen_delay = delay;
      phase_ok = p == BEGIN_RESP;
      calls++;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 5.0, 1.0e-9);
      p = END_RESP;
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class request_receiver extends uvm_component;
    `uvm_component_utils(request_receiver)
    uvm_tlm_nb_transport_fw_export#() export_value;
    uvm_tlm_nb_transport_fw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e, request_receiver) imp;
    uvm_tlm_nb_transport_bw_port#() backward;
    uvm_tlm_generic_payload stored_payload;
    uvm_tlm_time stored_delay;
    bit phase_ok = 0;
    int calls = 0;
    uvm_tlm_sync_e response_result = UVM_TLM_ACCEPTED;
    uvm_tlm_phase_e response_phase = UNINITIALIZED_PHASE;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
      imp = new("imp", this);
      backward = new("backward", this);
    endfunction
    function void connect_phase(uvm_phase phase); export_value.connect(imp); endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      real previous;
      stored_payload = t;
      stored_delay = delay;
      phase_ok = p == BEGIN_REQ;
      calls++;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 3.0, 1.0e-9);
      return UVM_TLM_ACCEPTED;
    endfunction
    function void respond();
      response_phase = BEGIN_RESP;
      stored_payload.set_response_status(UVM_TLM_OK_RESPONSE);
      response_result = backward.nb_transport_bw(stored_payload, response_phase, stored_delay);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_nb_transport_fw_port#() forward;
    request_receiver target;
    response_receiver initiator;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      forward = new("forward", this);
      target = new("target", this);
      initiator = new("initiator", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      forward.connect(target.export_value);
      target.backward.connect(initiator.export_value);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay_value", 1.0e-12);
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      delay_value.set_abstime(2.0, 1.0e-9);
      phase_value = BEGIN_REQ;
      result = forward.nb_transport_fw(payload, phase_value, delay_value);
      $display("UT: accepted %0d request_phase %0d phase_kept %0d",
               result == UVM_TLM_ACCEPTED, target.phase_ok, phase_value == BEGIN_REQ);
      #1;
      target.respond();
      $display("UT: completed %0d response_phase %0d ended %0d calls %0d %0d",
               target.response_result == UVM_TLM_COMPLETED, initiator.phase_ok,
               target.response_phase == END_RESP, target.calls, initiator.calls);
      $display("UT: payload_same %0d delay_same %0d ok %0d annotation %0d",
               target.stored_payload == payload && initiator.seen_payload == payload,
               target.stored_delay == delay_value && initiator.seen_delay == delay_value,
               payload.is_response_ok(), annotation_is(delay_value, 10.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
