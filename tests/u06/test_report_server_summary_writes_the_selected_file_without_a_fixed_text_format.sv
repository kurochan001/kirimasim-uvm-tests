/*
:name: test_report_server_summary_writes_the_selected_file_without_a_fixed_text_format
:description: report server summary writes the selected file without a fixed text format
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.17 6.5.2 6.5.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_summary_writes_the_selected_file_without_a_fixed_text_format.expected
*/
// What it checks:
// 1. Before an explicit replacement, UVM uses the default-report-server
//    implementation as its global report server.
// 2. The selected default report server emits summary output to the explicit
//    file.
// 3. The selected default report server emits summary output to the explicit
//    file.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1 (UVM-REPORT-AUDIT-DEFAULT-GLOBAL-SERVER) gives rule 1
//    above. Setup: Retrieve the global server in a fresh fixture before
//    selecting any replacement and require its exact default-server base type.
//    Expected: The current global handle casts to uvm_default_report_server
//    and preserves the same object identity.
// 2. 1800.2-2020 6.5.1.2.17 (UVM-REPORT-AUDIT-SUMMARY-ACTUAL-DESTINATION)
//    gives rule 2 above. Setup: Use the selected original reporting fixtures
//    and explicit object, severity, ID and action configuration described by
//    their observation anchors. Expected: After actual reports, the supplied
//    file has output while an independent peer file stays empty.
// 3. 1800.2-2020 6.5.2 (UVM-REPORT-AUDIT-DEFAULT-SERVER-SUMMARY) gives rule 3
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: After actual reports, the supplied file
//    has output while an independent peer file stays empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_server_summary_writes_the_selected_file_without_a_fixed_text_format;
  import uvm_pkg::*;
  // Observe output destination and existence only. Statistical formatting
  // and which categories/labels appear are not specified by this oracle.
  initial begin
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic uvm_report_object reporter = new("reporter");
    automatic int selected = $fopen("summary-selected.txt", "w");
    automatic int peer = $fopen("summary-peer.txt", "w");
    automatic int selected_chars = 0, peer_chars = 0;
    uvm_default_report_server concrete;
    string line;
    if (!selected || !peer) $fatal(1, "cannot open original summary files");
    reporter.uvm_report_info("summary41", "first", UVM_NONE);
    reporter.uvm_report_info("summary41", "second", UVM_NONE);
    if (!$cast(concrete, server)) $fatal(1, "global server is not the default implementation");
    server.report_summarize(selected);
    $fclose(selected); $fclose(peer);
    selected = $fopen("summary-selected.txt", "r"); peer = $fopen("summary-peer.txt", "r");
    while ($fgets(line, selected)) selected_chars += line.len();
    while ($fgets(line, peer)) peer_chars += line.len();
    $fclose(selected); $fclose(peer);
    $display("UT: default_server_type exact %0d", concrete == server);
    $display("UT: summary_destination selected_nonempty %0d peer_empty %0d",
             selected_chars > 0, peer_chars == 0);
    $finish;
  end
endmodule
