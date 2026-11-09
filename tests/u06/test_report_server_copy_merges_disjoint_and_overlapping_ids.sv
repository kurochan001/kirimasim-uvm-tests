/*
:name: test_report_server_copy_merges_disjoint_and_overlapping_ids
:description: statistic copy preserves destination-only IDs and replaces shared counts (IEEE 1800.2-2020 Section 6.5.1.2.13)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.13 6.5.1.2.8 6.5.1.2.9 6.5.1.2.16 6.2.4.10 6.2.4.8 5.3.8.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_copy_merges_disjoint_and_overlapping_ids.expected
*/
// What it checks:
// Server statistic copying preserves destination-only IDs and replaces
// overlapping counts with source values.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.13 (UVM-REPORT-SERVER-COPY-MERGE) gives the rule above.
// Setup: Source and destination have disjoint IDs and an overlapping ID with
// unequal counts. Expected: Destination-only entries survive, source-only
// entries appear and overlapping counts equal the source.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Direct public message execution populates independent servers without
// installing either as the global server or copying during setup.
module test_report_server_copy_merges_disjoint_and_overlapping_ids;
  import uvm_pkg::*;

  function automatic void record_id(uvm_report_server server, string id, int count);
    uvm_report_message message;
    message = new("message");
    message.set_report_message(UVM_INFO, id, "fixture", UVM_NONE, "", 0, "");
    message.set_action(UVM_DISPLAY);
    repeat (count) server.execute_report_message(message, "fixture");
  endfunction

  initial begin
    uvm_default_report_server source;
    uvm_default_report_server destination;
    string ids[$];
    int shared_seen;
    int source_seen;
    int destination_seen;
    source = new("source");
    destination = new("destination");
    record_id(source, "shared", 2);
    record_id(source, "source_only", 1);
    record_id(destination, "shared", 5);
    record_id(destination, "destination_only", 3);
    destination.copy(source);
    $display("UT: merged shared %0d source %0d destination %0d",
             destination.get_id_count("shared"), destination.get_id_count("source_only"),
             destination.get_id_count("destination_only"));
    destination.get_id_set(ids);
    shared_seen = 0;
    source_seen = 0;
    destination_seen = 0;
    foreach (ids[i]) begin
      if (ids[i] == "shared") shared_seen++;
      if (ids[i] == "source_only") source_seen++;
      if (ids[i] == "destination_only") destination_seen++;
    end
    $display("UT: membership %0d %0d %0d size %0d", shared_seen, source_seen,
             destination_seen, ids.size());
    record_id(source, "shared", 1);
    $display("UT: independent source %0d destination %0d", source.get_id_count("shared"),
             destination.get_id_count("shared"));
    $finish;
  end
endmodule
