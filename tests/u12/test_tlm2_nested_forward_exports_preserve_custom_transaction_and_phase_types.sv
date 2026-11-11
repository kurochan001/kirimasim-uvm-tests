/*
:name: test_tlm2_nested_forward_exports_preserve_custom_transaction_and_phase_types
:description: nested ordinary exports preserve custom transaction and phase type parameters (IEEE 1800.2-2020 Section 12.3.7.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.7.2 12.3.6.2 12.3.8.2 12.3.2.1 12.3.2.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_forward_exports_preserve_custom_transaction_and_phase_types.expected
*/
// What it checks:
// Nested forward exports preserve custom transaction and phase
// specializations.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.7.2 (UVM-TLM2-CUSTOM-FORWARD-EXPORT-TYPES) gives the rule
// above. Setup: Send a custom value-nine message through two exports and
// update it to thirteen. Expected: One call returns UPDATED, the custom output
// phase, exact handles and the updated annotation/value.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a custom transaction and phase enum through two hierarchical
// exports. Observe the typed reference update and handle identity; this is
// a generic transport binding check, not a base-protocol phase sequence.

module test_tlm2_nested_forward_exports_preserve_custom_transaction_and_phase_types;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  typedef enum {CUSTOM_START, CUSTOM_FINISH} custom_phase;
  class message extends uvm_object;
    `uvm_object_utils(message)
    int value = 9;
    function new(string name="message"); super.new(name); endfunction
  endclass
  class custom_receiver extends uvm_component;
    `uvm_component_utils(custom_receiver)
    uvm_tlm_nb_transport_fw_imp#(message, custom_phase, custom_receiver) imp;
    message seen_message;
    uvm_tlm_time seen_delay;
    bit phase_ok = 0;
    int calls = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    function uvm_tlm_sync_e nb_transport_fw(message t, ref custom_phase p,
        input uvm_tlm_time delay);
      real previous;
      seen_message = t;
      seen_delay = delay;
      calls++;
      phase_ok = p == CUSTOM_START;
      t.value += 4;
      p = CUSTOM_FINISH;
      previous = delay.get_abstime(1.0e-9);
      delay.set_abstime(previous + 6.0, 1.0e-9);
      return UVM_TLM_UPDATED;
    endfunction
  endclass
  class custom_relay extends uvm_component;
    `uvm_component_utils(custom_relay)
    uvm_tlm_nb_transport_fw_export#(message, custom_phase) export_value;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_nb_transport_fw_port#(message, custom_phase) port_value;
    custom_relay outer;
    custom_relay inner;
    custom_receiver receiver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      outer = new("outer", this);
      inner = new("inner", outer);
      receiver = new("receiver", inner);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(outer.export_value);
      outer.export_value.connect(inner.export_value);
      inner.export_value.connect(receiver.imp);
    endfunction
    task run_phase(uvm_phase phase);
      message transaction = new("transaction");
      uvm_tlm_time delay_value = new("delay_value", 1.0e-12);
      custom_phase phase_value;
      uvm_tlm_sync_e result;
      phase.raise_objection(this);
      delay_value.set_abstime(2.0, 1.0e-9);
      phase_value = CUSTOM_START;
      result = port_value.nb_transport_fw(transaction, phase_value, delay_value);
      $display("UT: updated %0d input_phase %0d output_phase %0d value %0d calls %0d",
               result == UVM_TLM_UPDATED, receiver.phase_ok, phase_value == CUSTOM_FINISH,
               transaction.value, receiver.calls);
      $display("UT: message_same %0d delay_same %0d annotation %0d",
               receiver.seen_message == transaction, receiver.seen_delay == delay_value,
               annotation_is(delay_value, 8.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
