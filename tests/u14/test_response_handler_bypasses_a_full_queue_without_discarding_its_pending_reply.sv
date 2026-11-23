/*
:name: test_response_handler_bypasses_a_full_queue_without_discarding_its_pending_reply
:description: Switching to a handler with a full response queue preserves the queued reply and permits reuse (IEEE 1800.2-2020 Section 14.2.7.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.7.1 14.2.7.3 14.2.7.6 14.2.7.7 14.3.3.3 15.5.2.9 14.1.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_response_handler_bypasses_a_full_queue_without_discarding_its_pending_reply.expected
*/
// Keep one live sequence and route three distinct responses for its request.
// Fill a one-entry queue, switch to handler delivery for the second response,
// and switch back before consuming the first. After that slot is freed the
// third response must arrive through the queue. Check callback count,
// identities and values, and bound blocking reads with a watchdog.

module test_response_handler_bypasses_a_full_queue_without_discarding_its_pending_reply;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    int value;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class client extends uvm_sequence #(packet);
    bit allow_first, first_drained;
    packet first, third, handled;
    int callbacks = 0;
    function void response_handler(uvm_sequence_item response);
      if (!$cast(handled, response) || handled == null) $fatal(1, "unexpected response type");
      callbacks++;
    endfunction
    task body();
      packet request_item = new("request_item");
      start_item(request_item);
      finish_item(request_item);
      wait (allow_first);
      get_response(first);
      first_drained = 1;
      get_response(third);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer #(packet) sqr;
    uvm_driver #(packet) driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = new("sqr", this);
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sqr.seq_item_export);
    endfunction
    function packet reply(packet req, int value);
      packet result = new("reply");
      result.set_id_info(req);
      result.value = value;
      return result;
    endfunction
    task run_phase(uvm_phase phase);
      client seq_value = new;
      packet req, a, b, c;
      phase.raise_objection(this);
      seq_value.set_response_queue_depth(1);
      fork
        seq_value.start(sqr);
        begin
          driver.seq_item_port.get_next_item(req);
          a = reply(req, 11);
          b = reply(req, 22);
          c = reply(req, 33);
          driver.seq_item_port.item_done();
          sqr.put_response(a);
          seq_value.use_response_handler(1);
          sqr.put_response(b);
          seq_value.use_response_handler(0);
          seq_value.allow_first = 1;
          wait (seq_value.first_drained);
          sqr.put_response(c);
        end
      join
      if (seq_value.handled == null || seq_value.first == null || seq_value.third == null)
        $fatal(1, "incomplete response delivery");
      $display("UT: handled %0d identity %0d value %0d",
               seq_value.callbacks, seq_value.handled == b, seq_value.handled.value);
      $display("UT: first identity %0d value %0d", seq_value.first == a, seq_value.first.value);
      $display("UT: third identity %0d value %0d depth %0d",
               seq_value.third == c, seq_value.third.value, seq_value.get_response_queue_depth());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "response watchdog expired");
  end
endmodule
