/*
:name: test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering
:description: reporting shared reset restores all threshold keys before live filtering
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.3 6.3.4.1 6.3.4.2 6.3.4.3 6.3.4.4 6.3.3.2 6.4.3.1 6.4.3.2 6.4.3.3 6.3.5.1 6.3.6.1 6.3.8.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering.expected
*/
// What it checks:
// 1. Resetting a report handler restores default settings and clears severity
//    overrides.
// 2. The public effective-verbosity query delegates to the selected handler
//    and its most specific key.
// 3. The report object exposes the configured maximum verbosity.
// 4. The public general-verbosity setter updates the underlying shared
//    handler.
// 5. The public ID verbosity setting is shared through the underlying handler.
// 6. The public severity/ID verbosity setting takes precedence for that pair.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.3.8.3 (UVM-REPORT-HANDLER-RESET) gives rule 1 above. Setup:
//    Configure shared ID action/verbosity/file settings and a severity/ID
//    override, then reset. Expected: Saved defaults return and the previously
//    overridden report uses its original severity.
// 2. 1800.2-2020 6.3.4.1 (UVM-REPORT-AUDIT-VERBOSITY-QUERY) gives rule 2
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: The shared reporter sees general 11, pair
//    7, ID 5 and maximum 11; the handler identity is shared.
// 3. 1800.2-2020 6.3.4.2 (UVM-REPORT-AUDIT-MAX-VERBOSITY-QUERY) gives rule 3
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: The shared reporter sees general 11, pair
//    7, ID 5 and maximum 11; the handler identity is shared.
// 4. 1800.2-2020 6.3.4.3 (UVM-REPORT-AUDIT-GENERAL-VERBOSITY-SET) gives rule 4
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: The shared reporter sees general 11, pair
//    7, ID 5 and maximum 11; the handler identity is shared.
// 5. 1800.2-2020 6.3.4.4 (UVM-REPORT-AUDIT-ID-VERBOSITY-SET) gives rule 5
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: The shared reporter sees general 11, pair
//    7, ID 5 and maximum 11; the handler identity is shared.
// 6. 1800.2-2020 6.3.4.4 (UVM-REPORT-AUDIT-PAIR-VERBOSITY-SET) gives rule 6
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: The shared reporter sees general 11, pair
//    7, ID 5 and maximum 11; the handler identity is shared.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_reporting_shared_reset_restores_all_threshold_keys_before_live_filtering;
  import uvm_pkg::*;
  initial begin
    automatic uvm_report_object first = new("first");
    automatic uvm_report_object peer = new("peer");
    automatic uvm_report_object fresh = new("fresh");
    automatic uvm_report_handler shared = new("shared");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic int fd = $fopen("reset-config.txt", "w");
    automatic int initial_count = server.get_id_count("selected41");
    int baseline;
    if (!fd) $fatal(1, "cannot open original file");
    first.set_report_handler(shared); peer.set_report_handler(shared);
    baseline = fresh.get_report_verbosity_level();
    first.set_report_verbosity_level(11);
    first.set_report_id_verbosity("selected41", 5);
    first.set_report_severity_id_verbosity(UVM_INFO, "selected41", 7);
    first.set_report_id_file("selected41", fd);
    $display("UT: threshold_keys general %0d pair %0d id %0d max %0d shared %0d",
             peer.get_report_verbosity_level(UVM_INFO, "other") == 11,
             peer.get_report_verbosity_level(UVM_INFO, "selected41") == 7,
             peer.get_report_verbosity_level(UVM_WARNING, "selected41") == 5,
             peer.get_report_max_verbosity_level() == 11,
             peer.get_report_handler() == first.get_report_handler());
    peer.uvm_report_info("selected41", "accepted", 7);
    peer.uvm_report_info("selected41", "filtered", 8);
    first.set_report_id_action("selected41", UVM_NO_ACTION);
    peer.uvm_report_info("selected41", "suppressed", 7);
    first.reset_report_handler();
    $display("UT: reset_keys general %0d pair %0d id %0d action %0d file %0d peer %0d",
             peer.get_report_verbosity_level(UVM_INFO, "other") == baseline,
             peer.get_report_verbosity_level(UVM_INFO, "selected41") == baseline,
             peer.get_report_verbosity_level(UVM_WARNING, "selected41") == baseline,
             peer.get_report_action(UVM_INFO, "selected41") == UVM_DISPLAY,
             peer.get_report_file_handle(UVM_INFO, "selected41") == 0,
             fresh.get_report_verbosity_level() == baseline);
    peer.uvm_report_info("selected41", "reset accepted", baseline);
    peer.uvm_report_info("selected41", "reset filtered", baseline + 1);
    $display("UT: reset_delivery count %0d boundary %0d over %0d",
             server.get_id_count("selected41") - initial_count,
             peer.uvm_report_enabled(baseline), peer.uvm_report_enabled(baseline + 1));
    $fclose(fd); $finish;
  end
endmodule
