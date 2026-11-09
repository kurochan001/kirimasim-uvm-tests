/*
:name: test_report_server_repeated_copy_merges_ids_and_overwrites_severity_with_zero
:description: repeated server copy keeps destination-only IDs while replacing severity counts (IEEE 1800.2-2020 Section 6.5.1.2.13)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.13 6.5.1.2.6 6.5.1.2.7 6.5.1.2.8 6.5.1.2.16 6.2.4.10 6.2.4.8 5.3.8.1
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_repeated_copy_merges_ids_and_overwrites_severity_with_zero.expected
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
// Explicit public setters establish both nonzero and zero source severity
// entries. A zero count is still a value to copy, not an absent entry.
module test_report_server_repeated_copy_merges_ids_and_overwrites_severity_with_zero;
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
    source = new("source");
    destination = new("destination");
    record_id(source, "source_only", 1);
    record_id(destination, "destination_only", 2);
    source.set_severity_count(UVM_WARNING, 2);
    source.set_severity_count(UVM_ERROR, 0);
    destination.set_severity_count(UVM_WARNING, 7);
    destination.set_severity_count(UVM_ERROR, 4);
    destination.copy(source);
    $display("UT: severities warning %0d error %0d", destination.get_severity_count(UVM_WARNING),
             destination.get_severity_count(UVM_ERROR));
    record_id(source, "later", 3);
    source.set_severity_count(UVM_WARNING, 5);
    destination.copy(source);
    $display("UT: repeated warning %0d source %0d destination %0d later %0d",
             destination.get_severity_count(UVM_WARNING), destination.get_id_count("source_only"),
             destination.get_id_count("destination_only"), destination.get_id_count("later"));
    $finish;
  end
endmodule
