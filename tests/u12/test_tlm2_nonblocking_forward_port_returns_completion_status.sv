/*
:name: test_tlm2_nonblocking_forward_port_returns_completion_status
:description: TLM 2 nonblocking forward port preserves transaction and delay identity and returns target completion (IEEE 1800.2-2020 Section 12.3.2.2.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.1 12.3.6.2 12.3.8.2 12.3.3.1 12.3.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_forward_port_returns_completion_status.expected
*/
// What it checks:
// A forward transport port propagates completion status and transaction
// changes.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.2.2.1 (UVM-TLM2-FORWARD-PORT-COMPLETION) gives the rule
// above. Setup: Send an IGNORE payload through a normal forward port.
// Expected: Exact handles and BEGIN_REQ reach the target; COMPLETED, retained
// phase and OK return.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use an IGNORE transaction with no data transfer. The target completes
// the request in the function call; no timing annotation is interpreted.

module test_tlm2_nonblocking_forward_port_returns_completion_status;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class forward_target extends uvm_component;
    `uvm_component_utils(forward_target)
    uvm_tlm_nb_transport_fw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e, forward_target) imp;
    uvm_tlm_generic_payload expected_payload;
    uvm_tlm_time expected_delay;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      $display("UT: forward payload_same %0d delay_same %0d begin_req %0d", t == expected_payload,
               delay == expected_delay, p == BEGIN_REQ);
      t.set_response_status(UVM_TLM_OK_RESPONSE);
      return UVM_TLM_COMPLETED;
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_nb_transport_fw_port#() port_value;
    forward_target target;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      target = new("target", this);
    endfunction
    function void connect_phase(uvm_phase phase); port_value.connect(target.imp); endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay_value");
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_data_length(0);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      target.expected_payload = payload;
      target.expected_delay = delay_value;
      phase_value = BEGIN_REQ;
      result = port_value.nb_transport_fw(payload, phase_value, delay_value);
      $display("UT: completed %0d phase_kept %0d ok %0d", result == UVM_TLM_COMPLETED,
               phase_value == BEGIN_REQ, payload.is_response_ok());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #40;
    $fatal(1, "test watchdog expired");
  end
endmodule
