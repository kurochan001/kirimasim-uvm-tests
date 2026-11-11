/*
:name: test_tlm2_blocking_export_routes_distinct_payloads_on_repeated_calls
:description: blocking TLM 2 export reuses its resolved binding for distinct payloads (IEEE 1800.2-2020 Section 12.3.7.1)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.7.1 12.3.6.1 12.3.8.1 12.3.2.2.3 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_export_routes_distinct_payloads_on_repeated_calls.expected
*/
// What it checks:
// Repeated blocking-export calls route each supplied transaction
// independently.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.7.1 (UVM-TLM2-BLOCKING-EXPORT-REPEATED) gives the rule
// above. Setup: Send distinct payloads at addresses 101/202 and reuse the
// delay handle. Expected: Two calls see ordered addresses, the final exact
// payload, both OK and accumulated annotation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Send two payloads through one export and reuse the delay handle. Observe
// ordered addresses, the final payload identity and accumulated annotation.

module test_tlm2_blocking_export_routes_distinct_payloads_on_repeated_calls;
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
    uvm_tlm_b_transport_imp#(uvm_tlm_generic_payload, blocking_target) imp;
    uvm_tlm_generic_payload seen_payload;
    uvm_tlm_time seen_delay;
    longint unsigned addresses[$];
    int calls = 0;
    bit entered = 0;
    bit completed = 0;
    bit consume_time = 1;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    task b_transport(uvm_tlm_generic_payload t, uvm_tlm_time delay);
      real previous;
      seen_payload = t;
      seen_delay = delay;
      addresses.push_back(t.get_address());
      calls++;
      entered = 1;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 4.0, 1.0e-9);
      if (consume_time) #3;
      t.set_response_status(UVM_TLM_OK_RESPONSE);
      completed = 1;
    endtask
  endclass
  class blocking_relay extends uvm_component;
    `uvm_component_utils(blocking_relay)
    uvm_tlm_b_transport_export#() export_value;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_transport_port#() port_value;
    blocking_relay outer;
    blocking_relay inner;
    blocking_target target;
    uvm_tlm_generic_payload payload;
    uvm_tlm_generic_payload other_payload;
    uvm_tlm_time delay_value;
    bit returned = 0;
    time before_time;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      outer = new("outer", this);
      target = new("target", outer);

      payload = new("payload");
      other_payload = new("other_payload");
      delay_value = new("delay_value", 1.0e-12);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(outer.export_value);
      outer.export_value.connect(target.imp);

    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      payload.set_command(UVM_TLM_IGNORE_COMMAND);
      payload.set_address(101);
      payload.set_response_status(UVM_TLM_INCOMPLETE_RESPONSE);
      other_payload.set_command(UVM_TLM_IGNORE_COMMAND);
      other_payload.set_address(202);
      delay_value.set_abstime(2.0, 1.0e-9);
      port_value.b_transport(payload, delay_value);
      port_value.b_transport(other_payload, delay_value);
      $display("UT: calls %0d addresses %0d %0d final_same %0d both_ok %0d annotation %0d",
               target.calls, target.addresses[0], target.addresses[1],
               target.seen_payload == other_payload,
               payload.is_response_ok() && other_payload.is_response_ok(),
                   annotation_is(delay_value, 10.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
