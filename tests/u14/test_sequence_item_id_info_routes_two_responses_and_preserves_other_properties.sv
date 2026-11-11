/*
:name: test_sequence_item_id_info_routes_two_responses_and_preserves_other_properties
:description: set_id_info copies routing IDs without changing payload/name or aliasing transaction IDs (14.1.2.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.2.4 5.4.2.17 5.4.2.18 15.5.2.6 15.4.3.1 14.3.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_id_info_routes_two_responses_and_preserves_other_properties.expected
*/
// What it checks:
// 1. set_id_info copies the internal sequence identifier needed to route a
//    response to the requesting sequence.
// 2. set_id_info copies the transaction identifier value independently of
//    subsequent source changes.
// 3. ID information copying leaves unrelated response properties intact.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.2.4 (UVM-ITEM-ID-INFO-SEQUENCE-ROUTING) gives rule 1
//    above. Setup: Hold two sequences awaiting replies and deliver copied-ID
//    responses in reverse order. Expected: Each sequence receives its own
//    exact response object.
// 2. 1800.2-2020 14.1.2.4 (UVM-ITEM-ID-INFO-TRANSACTION-VALUE-COPY) gives rule
//    2 above. Setup: Copy IDs 11/22, then change source request transaction
//    IDs to 99 before delivering replies. Expected: Replies retain IDs 11/22
//    and targeted response waits succeed while source IDs are both 99.
// 3. 1800.2-2020 14.1.2.4 (UVM-ITEM-ID-INFO-PRESERVES-OTHER-PROPERTIES) gives
//    rule 3 above. Setup: Initialize reply payloads and names before copying
//    IDs. Expected: Reply payloads remain 901/902 and names remain
//    reply_one/reply_two.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequence_item_id_info_routes_two_responses_and_preserves_other_properties;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int owner;
    int payload;
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class producer extends uvm_sequence#(packet);
    int owner;
    int id_value;
    packet request_value, received;
    function new(string name); super.new(name); endfunction
    task body();
      request_value = new("request"); request_value.owner = owner;
      request_value.set_transaction_id(id_value);
      start_item(request_value); finish_item(request_value);
      get_response(received, id_value);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sqr;
    producer one, two;
    packet reply_one, reply_two;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); sqr = new("sqr", this);
      one = new("one"); one.owner = 1; one.id_value = 11;
      two = new("two"); two.owner = 2; two.id_value = 22;
      reply_one = new("reply_one"); reply_one.payload = 901;
      reply_two = new("reply_two"); reply_two.payload = 902;
    endfunction
    task run_phase(uvm_phase phase);
      packet request_value;
      phase.raise_objection(this); sqr.disable_auto_item_recording();
      fork
        one.start(sqr);
        two.start(sqr);
        begin
          repeat (2) begin
            sqr.get(request_value);
            if (request_value.owner == 1) reply_one.set_id_info(request_value);
            else if (request_value.owner == 2) reply_two.set_id_info(request_value);
            else $fatal(1, "unexpected request owner");
            request_value.set_transaction_id(99);
          end
          sqr.rsp_export.write(reply_two); sqr.rsp_export.write(reply_one);
        end
      join
      $display("UT: routing %0d %0d copied_ids %0d %0d source_ids %0d %0d",
               one.received == reply_one, two.received == reply_two,
               reply_one.get_transaction_id(), reply_two.get_transaction_id(),
               one.request_value.get_transaction_id(), two.request_value.get_transaction_id());
      $display("UT: payloads %0d %0d names %s %s", reply_one.payload, reply_two.payload,
               reply_one.get_name(), reply_two.get_name());
      phase.drop_objection(this);
    endtask
  endclass
  initial run_test("t");
  initial begin #100; $fatal(1, "ID routing watchdog expired"); end
endmodule
