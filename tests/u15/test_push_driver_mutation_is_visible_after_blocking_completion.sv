/*
:name: test_push_driver_mutation_is_visible_after_blocking_completion
:description: push sequencer and driver obey blocking request and response contracts (IEEE 1800.2-2020 Section 15.6.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.6.1 15.6.2 15.6.3.3 13.8.2.1 14.2.6.3 12.2.2.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_push_driver_mutation_is_visible_after_blocking_completion.expected
*/
// What it checks:
// Push sequencing completes finish_item only after the driver blocking put
// returns.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.6.3.3 (UVM-PUSH-SEQUENCER-BLOCKING-COMPLETION) gives the rule
// above. Setup: Delay inside driver put and optionally modify the original
// request before returning. Expected: The producer is pending during put and
// observes completed driver work and the original mutated request afterwards.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Mutate the request inside put before returning. The producer must see
// the same handle and the completed mutation when finish_item returns.

module test_push_driver_mutation_is_visible_after_blocking_completion;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class request_item extends uvm_sequence_item;
    `uvm_object_utils(request_item)
    int value = 0;
    function new(string name="request_item"); super.new(name); endfunction
  endclass
  class response_item extends uvm_sequence_item;
    `uvm_object_utils(response_item)
    int value = 0;
    function new(string name="response_item"); super.new(name); endfunction
  endclass
  class sink_driver extends uvm_push_driver#(request_item, response_item);
    `uvm_component_utils(sink_driver)
    request_item received[$];
    int entered = 0;
    int completed = 0;
    bit reply = 0;
    bit mutate = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    virtual task put(request_item item);
      response_item response;
      received.push_back(item);
      entered++;
      #3;
      if (mutate) item.value += 100;
      completed++;
      if (reply) begin
        response = new("response");
        response.set_id_info(item);
        response.value = item.value + 1000;
        rsp_port.write(response);
      end
    endtask
  endclass
  class producer extends uvm_sequence#(request_item, response_item);
    `uvm_object_utils(producer)
    int values[$] = '{7};
    request_item sent[$];
    response_item replies[$];
    bit expect_reply = 0;
    bit done = 0;
    int handled = 0;
    int handled_value = 0;
    function new(string name="producer"); super.new(name); endfunction
    virtual function void response_handler(uvm_sequence_item response);
      response_item typed;
      if (!$cast(typed, response) || typed == null) $fatal(1, "wrong response type");
      handled++;
      handled_value = typed.value;
    endfunction
    virtual task body();
      request_item item;
      response_item response;
      foreach (values[i]) begin
        item = new("request");
        item.value = values[i];
        item.set_transaction_id(40 + i);
        sent.push_back(item);
        start_item(item);
        finish_item(item);
        if (expect_reply) begin
          get_response(response, item.get_transaction_id());
          replies.push_back(response);
        end
      end
      done = 1;
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_push_sequencer#(request_item, response_item) sequencer;
    sink_driver driver;
    producer sequence_value;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      driver = new("driver", this);
      sequence_value = new("sequence_value");
    endfunction
    function void connect_phase(uvm_phase phase);
      sequencer.req_port.connect(driver.req_export);
      driver.rsp_port.connect(sequencer.rsp_export);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      driver.mutate = 1;
      sequence_value.start(sequencer);
      $display("UT: same_handle %0d completed_value %0d puts %0d",
               driver.received[0] == sequence_value.sent[0], sequence_value.sent[0].value,
               driver.completed);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
