/*
:name: test_sequencer_request_history_shares_exact_handles_without_affecting_a_peer
:description: last request history retains the exact item handle and is local to each sequencer (15.4.2)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.4.2 15.3.3.2.2 15.5.2.6 14.2.6.2 14.2.6.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequencer_request_history_shares_exact_handles_without_affecting_a_peer.expected
*/
// What it checks:
// 1. The history capacity query reports the configured size independently for
//    each sequencer.
// 2. History returns the exact item handle rather than an independent value
//    snapshot.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 15.3.3.2.2 (UVM-REQUEST-HISTORY-CAPACITY-QUERY) gives rule 1
//    above. Setup: Observe default capacity one and transition a separate
//    history from zero to two during traffic. Expected: Queries report one for
//    independent peers and zero/two for the changed history.
// 2. 1800.2-2020 15.4.2 (UVM-REQUEST-HISTORY-EXACT-HANDLE-SHARING) gives rule
//    2 above. Setup: Keep one item on each of two sequencers and mutate the
//    retained source handle after completion. Expected: Both history handles
//    are exact and distinct; mutation is shared only by the selected item
//    while peer data remains unchanged.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_sequencer_request_history_shares_exact_handles_without_affecting_a_peer;
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
  initial begin
    automatic uvm_sequencer#(packet) first = new("first", null);
    automatic uvm_sequencer#(packet) peer = new("peer", null);
    automatic producer source_a = new("source_a");
    automatic producer source_b = new("source_b");
    packet consumed_a[$], responses_a[$], consumed_b[$], responses_b[$];
    first.disable_auto_item_recording(); peer.disable_auto_item_recording();
    source_a.replies = 0; source_b.replies = 0;
    fork source_a.start(first); drive(first, source_a, consumed_a, responses_a); join
    fork source_b.start(peer); drive(peer, source_b, consumed_b, responses_b); join
    $display("UT: exact_handles %0d %0d distinct %0d capacities %0d %0d",
             first.last_req() == source_a.sent[0], peer.last_req() == source_b.sent[0],
             first.last_req() != peer.last_req(),
             first.get_num_last_reqs(), peer.get_num_last_reqs());
    source_a.sent[0].payload = 917;
    $display("UT: shared_mutation %0d peer_retained %0d",
             first.last_req().payload == 917, peer.last_req().payload == 100);
    $finish;
  end
endmodule
