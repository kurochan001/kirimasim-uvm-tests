/*
:name: test_tlm2_custom_transaction_blocking_socket_uses_explicit_implementation
:description: blocking socket transports a custom transaction through its explicit implementation (IEEE 1800.2-2020 Section 12.3.5.1.3)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.1.3 12.3.5.1.1 12.3.5.2.1 12.3.5.2.4 12.3.2.2.3 12.3.9 5.6.2.8 5.6.2.9 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_custom_transaction_blocking_socket_uses_explicit_implementation.expected
*/
// What it checks:
// A blocking target socket delivers custom-transaction calls to its explicit
// implementation.
//
// How the expected output follows from the standard:
// 1800.2-2020 12.3.5.1.3 (UVM-TLM2-CUSTOM-BLOCKING-EXPLICIT-IMPLEMENTATION)
// gives the rule above. Setup: Bind one custom-typed initiator socket to a
// target; supply a separate child implementation handle. Expected: One call
// preserves transaction/delay identity, returns reply 42 and completion,
// waits, and leaves annotation 5 ns.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a transaction unrelated to the generic payload and a standard delay.
// The implementation completes after positive delay and annotates separately.
module test_tlm2_custom_transaction_blocking_socket_uses_explicit_implementation;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class custom_transaction extends uvm_object;
    int request = 0;
    int reply = 0;
    bit complete = 0;
    function new(string name="custom"); super.new(name); endfunction
  endclass

  class worker extends uvm_component;

    custom_transaction expected;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit same_handles = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    task b_transport(custom_transaction t, uvm_tlm_time delay);
      calls++;
      same_handles = t == expected && delay == expected_delay;
      #2;
      t.reply = t.request + 7;
      t.complete = 1;
      delay.set_abstime(delay.get_abstime(1.0e-9) + 3.0, 1.0e-9);
    endtask
  endclass

  class target_shell extends uvm_component;
    uvm_tlm_b_target_socket#(worker, custom_transaction) socket;
    worker implementation;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      implementation = new("implementation", this);
      socket = new("socket", this, implementation);
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_b_initiator_socket#(custom_transaction) socket;
    target_shell target;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      socket = new("socket", this); target = new("target", this);
    endfunction
    function void connect_phase(uvm_phase phase); socket.connect(target.socket); endfunction
    task run_phase(uvm_phase phase);
      custom_transaction item = new();
      uvm_tlm_time delay_value = new("delay", 1.0e-12);
      time before_time;
      real annotation;
      phase.raise_objection(this);
      item.request = 35; delay_value.set_abstime(2.0, 1.0e-9);
      target.implementation.expected = item; target.implementation.expected_delay = delay_value;
      before_time = $time;
      socket.b_transport(item, delay_value);
      annotation = delay_value.get_abstime(1.0e-9);
      $display("UT: calls %0d identity %0d reply %0d complete %0d", target.implementation.calls,
      target.implementation.same_handles, item.reply, item.complete);
      $display("UT: waited %0d annotation %0d", $time > before_time, annotation > 4.999999 &&
      annotation < 5.000001);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #80; $fatal(1, "transport watchdog expired"); end

endmodule
