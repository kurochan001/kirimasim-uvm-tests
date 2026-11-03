/*
:name: test_sequencer_zero_response_history_keeps_delivery_and_can_be_reenabled
:description: zero response history capacity preserves traffic and later configured history (15.3.4.2.1)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.4.2.1 15.3.4.2.2 15.4.3.2 15.3.4.1 15.4.3.1 15.5.2.6 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_zero_response_history_keeps_delivery_and_can_be_reenabled.expected
*/
module test_sequencer_zero_response_history_keeps_delivery_and_can_be_reenabled;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    int count = 1;
    bit replies = 0;
    packet sent[$];
    packet received[$];
    function new(string name); super.new(name); endfunction
    task body();
      repeat (count) begin
        packet req_value = new("request");
        packet rsp_value;
        req_value.payload = 100 + sent.size();
        req_value.set_transaction_id(200 + sent.size());
        sent.push_back(req_value);
        start_item(req_value); finish_item(req_value);
        if (replies) begin get_response(rsp_value); received.push_back(rsp_value); end
      end
    endtask
  endclass
  task automatic drive(uvm_sequencer#(packet) sqr, producer source,
                       ref packet consumed[$], ref packet responses[$]);
    repeat (source.count) begin
      packet req_value;
      packet rsp_value;
      sqr.get(req_value);
      consumed.push_back(req_value);
      if (source.replies) begin
        rsp_value = new("response");
        rsp_value.set_id_info(req_value); rsp_value.payload = 300 + responses.size();
        responses.push_back(rsp_value);
        sqr.rsp_export.write(rsp_value);
      end
    end
  endtask
  initial begin #100; $fatal(1, "history test watchdog expired"); end
  // Let normal UVM build/connect resolve the response export before traffic.
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sqr;
    producer source;
    packet consumed[$], responses[$];
    bit delivery;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sqr = new("sqr", this);
      source = new("source");
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      sqr.disable_auto_item_recording(); source.replies = 1;
      sqr.set_num_last_rsps(0); source.count = 2;
      fork source.start(sqr); drive(sqr, source, consumed, responses); join
      delivery = consumed.size() == 2;
      foreach (consumed[i]) delivery &= consumed[i] == source.sent[i];
      $display("UT: disabled capacity %0d count %0d beyond_null %0d delivery %0d",
               sqr.get_num_last_rsps(), sqr.get_num_rsps_received(),
               sqr.last_rsp(1) == null, delivery);
      sqr.set_num_last_rsps(2); source.count = 3;
      fork source.start(sqr); drive(sqr, source, consumed, responses); join
      $display("UT: enabled capacity %0d count %0d newest %0d previous %0d beyond_null %0d",
               sqr.get_num_last_rsps(), sqr.get_num_rsps_received(),
               sqr.last_rsp() == responses[4], sqr.last_rsp(1) == responses[3],
               sqr.last_rsp(3) == null);
      delivery = source.received.size() == 5;
      foreach (source.received[i]) delivery &= source.received[i] == responses[i];
      $display("UT: exact_reply_delivery %0d", delivery);
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
endmodule
