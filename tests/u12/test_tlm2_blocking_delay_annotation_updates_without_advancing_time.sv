/*
:name: test_tlm2_blocking_delay_annotation_updates_without_advancing_time
:description: blocking TLM delay annotations remain shared canonical time objects without consuming simulation time (IEEE 1800.2-2020 Section 12.3.9)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.9 5.6.2.8 5.6.2.9 12.3.2.2.3 12.3.5.1.3 12.3.5.2.3 12.3.5.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_delay_annotation_updates_without_advancing_time.expected
*/
// Pass one delay through normal blocking sockets. The target adds an
// absolute annotation and completes an IGNORE transaction without waiting.
// Observe the returned annotation, identity and unchanged simulation time.

module test_tlm2_blocking_delay_annotation_updates_without_advancing_time;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class annotation_target extends uvm_component;
    `uvm_component_utils(annotation_target)
    uvm_tlm_b_target_socket#(annotation_target) socket;
    uvm_tlm_time seen_delay;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      socket = new("socket", this, this);
    endfunction
    task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time delay);
      real previous;
      seen_delay = delay;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 5.0, 1.0e-9);
      t.set_response_status(UVM_TLM_OK_RESPONSE);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    annotation_target target;
    uvm_tlm_b_initiator_socket#() initiator;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      target = new("target", this);
      initiator = new("initiator", this);
    endfunction
    function void connect_phase(uvm_phase phase); initiator.connect(target.socket); endfunction
    task run_phase(uvm_phase phase);
      uvm_tlm_generic_payload payload = new("payload");
      uvm_tlm_time delay_value = new("delay", 1.0e-12);
      time before_time;
      real annotation;
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_data_length(0);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      delay_value.set_abstime(2.0, 1.0e-9);
      before_time = $time;
      initiator.b_transport(payload, delay_value);
      annotation = delay_value.get_abstime(1.0e-9);
      $display("UT: annotation %0d same_delay %0d no_wait %0d ok %0d",
               annotation > 6.999999 && annotation < 7.000001,
               target.seen_delay == delay_value, $time == before_time, payload.is_response_ok());
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
