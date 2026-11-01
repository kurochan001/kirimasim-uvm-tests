/*
:name: test_tlm2_nested_blocking_exports_forward_a_custom_transaction_and_its_completion
:description: Blocking TLM 2 exports support a custom transaction type and caller-visible completion (IEEE 1800.2-2020 Section 12.3.2.2.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.2.2.3 12.3.6.1 12.3.7.1 12.3.8.1 5.6.2.8 5.6.2.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_nested_blocking_exports_forward_a_custom_transaction_and_its_completion.expected
*/
// Custom fields/status belong to the transaction type, not generic payload.
// The implementation supplies the work and wait; exports must forward both.

module test_tlm2_nested_blocking_exports_forward_a_custom_transaction_and_its_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  function automatic bit annotation_is(uvm_tlm_time value, real wanted);
    real difference;
    difference = value.get_abstime(1.0e-9) - wanted;
    if (difference < 0.0) difference = -difference;
    return difference < 1.0e-9;
  endfunction

  typedef enum { FRESH, SUCCESS } custom_status;
  class custom_transaction extends uvm_object;
    int request;
    int reply;
    custom_status status = FRESH;
    function new(string name = "custom_transaction"); super.new(name); endfunction
  endclass
  class endpoint extends uvm_component;
    `uvm_component_utils(endpoint)
    uvm_tlm_b_transport_imp#(custom_transaction, endpoint) imp;
    custom_transaction seen_payload;
    uvm_tlm_time seen_delay;
    int calls = 0;
    bit completed = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
    endfunction
    task b_transport(custom_transaction payload, uvm_tlm_time delay);
      real previous;
      calls++;
      seen_payload = payload;
      seen_delay = delay;
      previous = delay.get_abstime(1.0e-9);
      #3;
      payload.reply = payload.request + 1;
      payload.status = SUCCESS;
      delay.set_abstime(previous + 4.0, 1.0e-9);
      completed = 1;
    endtask
  endclass

  class relay extends uvm_component;
    `uvm_component_utils(relay)
    uvm_tlm_b_transport_export#(custom_transaction) export_value;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      export_value = new("export_value", this);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_transport_port#(custom_transaction) port_value;
    relay outer;
    relay inner;
    endpoint target;
    custom_transaction payload;
    uvm_tlm_time delay_value;
    bit returned = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      port_value = new("port_value", this);
      outer = new("outer", this);
      inner = new("inner", outer);
      target = new("target", inner);
      payload = new("payload");
      delay_value = new("delay_value", 1.0e-12);
    endfunction
    function void connect_phase(uvm_phase phase);
      port_value.connect(outer.export_value);
      outer.export_value.connect(inner.export_value);
      inner.export_value.connect(target.imp);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      payload.request = 41;
      delay_value.set_abstime(2.0, 1.0e-9);
      fork
        begin port_value.b_transport(payload, delay_value); returned = 1; end
      join_none
      #1;
      $display("UT: pending %0d calls %0d fresh %0d", !returned, target.calls,
               payload.status == FRESH);
      wait (returned);
      $display("UT: completed %0d success %0d reply %0d", target.completed,
               payload.status == SUCCESS, payload.reply);
      $display("UT: handles %0d %0d annotation %0d", target.seen_payload == payload,
               target.seen_delay == delay_value, annotation_is(delay_value, 6.0));
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
