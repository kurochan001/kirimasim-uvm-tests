/*
:name: test_nonblocking_transport_nonblocking_port_returns_analysis_generated_response
:description: nonblocking transport reports immediate completion through standard public channel interfaces (IEEE 1800.2-2020 Section 12.2.9.2.2)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.2.9.2.2 12.2.9.2.1 12.2.4.2.11 12.2.5.1 12.2.9.1.7 12.2.9.1.6 12.2.9.1.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_nonblocking_transport_nonblocking_port_returns_analysis_generated_response.expected
*/
// Accepted request analysis synchronously invokes one responder, which
// computes and returns a reply through the public response put port. The
// request is retired through its public get export after transport returns.

module test_nonblocking_transport_nonblocking_port_returns_analysis_generated_response;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class immediate_target extends uvm_subscriber#(int);
    `uvm_component_utils(immediate_target)
    uvm_nonblocking_put_port#(string) response_tx;
    bit enabled = 1;
    int offset = 0;
    int calls = 0;
    bit replies_accepted = 1;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      response_tx = new("response_tx", this);
    endfunction
    function void write(int t);
      bit accepted;
      if (!enabled) return;
      calls++;
      accepted = response_tx.try_put($sformatf("reply_%0d", t + offset));
      if (!accepted) replies_accepted = 0;
    endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_tlm_transport_channel#(int, string) channel_value;
    uvm_nonblocking_transport_port#(int, string) initiator;

    uvm_nonblocking_get_port#(int) request_rx;
    immediate_target target_value;
    bit completed = 0;
    bit accepted = 0;
    bit retired = 0;
    int request_value = 0;
    string response_value = "";

    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      channel_value = new("channel_value", this);
      initiator = new("initiator", this);
      request_rx = new("request_rx", this);
      target_value = new("target_value", this);

    endfunction
    function void connect_phase(uvm_phase phase);
      initiator.connect(channel_value.transport_export);
      request_rx.connect(channel_value.get_peek_request_export);
      channel_value.request_ap.connect(target_value.analysis_export);
      target_value.response_tx.connect(channel_value.put_response_export);

    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      completed = initiator.nb_transport(42, response_value);
      $display("UT: completed %0d response %s", completed, response_value);
      retired = request_rx.try_get(request_value);
      $display("UT: retired %0d request %0d calls %0d replies_accepted %0d", retired, request_value,
               target_value.calls, target_value.replies_accepted);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
