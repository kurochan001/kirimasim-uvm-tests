/*
:name: test_tlm2_blocking_socket_relays_forward_custom_transactions_until_target_completion
:description: tlm2 blocking socket relays forward custom transactions until target completion (IEEE 1800.2-2020 Section 12.3.5.7)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.5.7 12.3.5 12.3.5.7.1 12.3.5.8 12.3.5.8.1 12.3.5.2.4 12.3.2.2.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_blocking_socket_relays_forward_custom_transactions_until_target_completion.expected
*/
// What it checks:
// 1. Under the declared blocking-interface interpretation, the selected relay
//    forwards blocking calls until the target completes.
// 2. Under the declared blocking-interface interpretation, the selected relay
//    forwards blocking calls until the target completes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.5.7 (UVM-TLM2-TYPES-BLOCKING-INITIATOR-RELAY-COMPLETION)
//    gives rule 1 above. Setup: Reuse a custom transaction/delay through
//    actual blocking initiator and target relays and an original delayed
//    target. Expected: Two reused custom transactions return matching replies
//    after the selected two-unit target delay.
// 2. 1800.2-2020 12.3.5.8 (UVM-TLM2-TYPES-BLOCKING-TARGET-RELAY-COMPLETION)
//    gives rule 2 above. Setup: Reuse a custom transaction/delay through
//    actual blocking initiator and target relays and an original delayed
//    target. Expected: Two reused custom transactions return matching replies
//    after the selected two-unit target delay.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Operational blocking-path control using declared blocking IS-A interfaces.
// Actual relays preserve custom handles and wait for the original target body.
// This does not certify the conflicting printed nonblocking provider lists in
// 12.3.5.7.4/12.3.5.8.4; those have independent spec-listed acceptance probes.
module test_tlm2_blocking_socket_relays_forward_custom_transactions_until_target_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class message extends uvm_object;
    int request = 13,reply = 0;
    function new(); super.new("message"); endfunction
  endclass
  class target extends uvm_component;
    uvm_tlm_b_target_socket#(target,message) socket;
    message expected;
    uvm_tlm_time expected_delay;
    int calls = 0;
    bit identity = 1;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this);
    endfunction
    task b_transport(message value,uvm_tlm_time delay);
      calls++; identity &= value == expected && delay == expected_delay;
      #2; value.reply = value.request + 7;
      delay.set_abstime(delay.get_abstime(1.0e-9) + 3.0,1.0e-9);
    endtask
  endclass
  class caller extends uvm_component;
    uvm_tlm_b_initiator_socket#(message) socket;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this);
    endfunction
  endclass
  class source_shell extends uvm_component;
    uvm_tlm_b_passthrough_initiator_socket#(message) socket;
    caller endpoint;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this); endpoint = new("endpoint",this);
    endfunction
  endclass
  class target_shell extends uvm_component;
    uvm_tlm_b_passthrough_target_socket#(message) socket;
    target endpoint;
    function new(string name,uvm_component parent);
      super.new(name,parent); socket = new("socket",this); endpoint = new("endpoint",this);
    endfunction
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    source_shell source;
    target_shell destination;
    function new(string name,uvm_component parent); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); source = new("source",this); destination = new("destination",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      source.endpoint.socket.connect(source.socket); source.socket.connect(destination.socket);
      destination.socket.connect(destination.endpoint.socket);
    endfunction
    task run_phase(uvm_phase phase);
      message value = new();
      uvm_tlm_time delay = new("delay",1.0e-12);
      time before_time;
      real annotation;
      phase.raise_objection(this);
      destination.endpoint.expected = value; destination.endpoint.expected_delay = delay;
      delay.set_abstime(2.0,1.0e-9); before_time = $time;
      source.endpoint.socket.b_transport(value,delay);
      $display("UT: blocking_relays_first reply %0d delayed %0d calls %0d same %0d",
               value.reply,$time == before_time + 2,destination.endpoint.calls,
               destination.endpoint.identity);
      value.request = 27; before_time = $time; source.endpoint.socket.b_transport(value,delay);
      annotation = delay.get_abstime(1.0e-9);
      $display("UT: blocking_relays_reuse reply %0d delayed %0d calls %0d same %0d delay %0d",
               value.reply,$time == before_time + 2,destination.endpoint.calls,
               destination.endpoint.identity,annotation > 7.999999 && annotation < 8.000001);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #60; $fatal(1,"blocking relay watchdog expired"); end
endmodule
