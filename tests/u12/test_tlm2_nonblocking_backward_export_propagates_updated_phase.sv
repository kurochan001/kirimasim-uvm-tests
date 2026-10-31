/*
:name: test_tlm2_nonblocking_backward_export_propagates_updated_phase
:description: ordinary nonblocking export propagates updated phase status and shared handles (IEEE 1800.2-2020 Section 12.3.7.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.7.3 12.3.6.3 12.3.8.3 12.3.2.2.2 12.3.3.2 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nonblocking_backward_export_propagates_updated_phase.expected
*/
// Bind a nonblocking port through an ordinary export to its implementation.
// The implementation updates the phase by reference and annotates the same
// delay object. No automatic socket backward connection is involved.

module test_tlm2_nonblocking_backward_export_propagates_updated_phase;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  class receiving_endpoint extends uvm_component;
    `uvm_component_utils(receiving_endpoint)
    uvm_tlm_nb_transport_bw_imp#(uvm_tlm_generic_payload, uvm_tlm_phase_e,
        receiving_endpoint) imp;
    uvm_tlm_generic_payload seen_payload;
    uvm_tlm_time seen_delay;
    bit input_phase_ok = 0;
    int calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    function uvm_tlm_sync_e nb_transport_bw(uvm_tlm_generic_payload t,
        ref uvm_tlm_phase_e p, input uvm_tlm_time delay);
      real previous;
      seen_payload = t;
      seen_delay = delay;
      input_phase_ok = p == BEGIN_RESP;
      calls++;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 5.0, 1.0e-9);
      p = END_RESP;
      return UVM_TLM_UPDATED;
    endfunction
  endclass
  class relay_node extends uvm_component;
    `uvm_component_utils(relay_node)
    uvm_tlm_nb_transport_bw_export#() export_value;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_nb_transport_bw_port#() port_value;
    relay_node relay;
    receiving_endpoint endpoint;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      relay = new("relay", this);
      endpoint = new("endpoint", relay);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(relay.export_value);
      relay.export_value.connect(endpoint.imp);
    endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay_value", 1.0e-12);
      uvm_tlm_phase_e phase_value;
      uvm_tlm_sync_e result;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_response_status(UVM_TLM_OK_RESPONSE);
      delay_value.set_abstime(2.0, 1.0e-9);
      phase_value = BEGIN_RESP;
      result = port_value.nb_transport_bw(payload, phase_value, delay_value);
      $display("UT: updated %0d input_phase %0d output_phase %0d calls %0d",
               result == UVM_TLM_UPDATED, endpoint.input_phase_ok, phase_value == END_RESP,
               endpoint.calls);
      $display("UT: payload_same %0d delay_same %0d annotation %0d",
               endpoint.seen_payload == payload, endpoint.seen_delay == delay_value,
               annotation_is(delay_value, 7.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
