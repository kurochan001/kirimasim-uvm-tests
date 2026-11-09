/*
:name: test_report_server_global_wrappers_copy_statistics_and_preserve_destination_only_ids
:description: report server global wrappers copy statistics and preserve destination only ids
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.19 6.5.1.2.18 6.5.1.2.13 6.5.1.2.6 6.5.1.2.8 F.4.1.4.4 F.4.1.4.5 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_global_wrappers_copy_statistics_and_preserve_destination_only_ids.expected
*/
// What it checks:
// 1. The report-server getter returns the same selected global instance as the
//    core service.
// 2. Replacing the global server copies existing severity and ID statistics to
//    its destination.
// 3. Global server replacement preserves destination-only IDs and overwrites
//    overlapping counts from the current server.
// 4. Copied global-server statistics do not alias the previous server
//    counters.
// 5. A second global replacement copies the latest statistics and retains its
//    own destination-only ID.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1.2.18 (UVM-REPORT-AUDIT-GLOBAL-GETTER-DELEGATION) gives
//    rule 1 above. Setup: Use the selected original reporting fixtures and
//    explicit object, severity, ID and action configuration described by their
//    observation anchors. Expected: The static getter and core agree after
//    replacement and the saved server is restored exactly.
// 2. 1800.2-2020 6.5.1.2.19 (UVM-REPORT-AUDIT-GLOBAL-SET-COUNTS) gives rule 2
//    above. Setup: Prime three actual default servers under temporarily
//    selected global setup, with disjoint/overlapping IDs and explicitly set
//    severity counters; use the public wrapper for both measured replacements.
//    Expected: Selected severity/ID values match the current server snapshot;
//    destination-only IDs remain and later source changes do not change the
//    copied destination.
// 3. 1800.2-2020 6.5.1.2.19 (UVM-REPORT-AUDIT-GLOBAL-SET-CUMULATIVE-IDS) gives
//    rule 3 above. Setup: Prime three actual default servers under temporarily
//    selected global setup, with disjoint/overlapping IDs and explicitly set
//    severity counters; use the public wrapper for both measured replacements.
//    Expected: Selected severity/ID values match the current server snapshot;
//    destination-only IDs remain and later source changes do not change the
//    copied destination.
// 4. 1800.2-2020 6.5.1.2.19 (UVM-REPORT-AUDIT-GLOBAL-SET-SNAPSHOT) gives rule
//    4 above. Setup: Prime three actual default servers under temporarily
//    selected global setup, with disjoint/overlapping IDs and explicitly set
//    severity counters; use the public wrapper for both measured replacements.
//    Expected: Selected severity/ID values match the current server snapshot;
//    destination-only IDs remain and later source changes do not change the
//    copied destination.
// 5. 1800.2-2020 6.5.1.2.19 (UVM-REPORT-AUDIT-GLOBAL-SET-REPEATED) gives rule
//    5 above. Setup: Prime three actual default servers under temporarily
//    selected global setup, with disjoint/overlapping IDs and explicitly set
//    severity counters; use the public wrapper for both measured replacements.
//    Expected: Selected severity/ID values match the current server snapshot;
//    destination-only IDs remain and later source changes do not change the
//    copied destination.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_report_server_global_wrappers_copy_statistics_and_preserve_destination_only_ids;
  import uvm_pkg::*;
  function automatic void issue_to(uvm_report_server server, uvm_report_object reporter, string id);
    uvm_report_message msg = new();
    uvm_report_server prior = uvm_report_server::get_server();
    uvm_coreservice_t::get().set_report_server(server);
    msg.set_report_message(UVM_INFO, id, "original", UVM_NONE, "", 0, "");
    msg.set_report_object(reporter); msg.set_report_handler(reporter.get_report_handler());
    msg.set_action(UVM_DISPLAY); server.process_report_message(msg);
    uvm_coreservice_t::get().set_report_server(prior);
  endfunction
  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_report_server saved = core.get_report_server();
    automatic uvm_default_report_server selected = new();
    automatic uvm_default_report_server third = new();
    automatic uvm_report_object reporter = new("reporter");
    issue_to(saved, reporter, "old41"); issue_to(saved, reporter, "old41");
    issue_to(saved, reporter, "shared41");
    issue_to(selected, reporter, "new41"); issue_to(selected, reporter, "new41");
    issue_to(selected, reporter, "new41");
    issue_to(selected, reporter, "shared41"); issue_to(selected, reporter, "shared41");
    issue_to(third, reporter, "third41");
    saved.set_severity_count(UVM_INFO, 7); saved.set_severity_count(UVM_WARNING, 5);
    selected.set_severity_count(UVM_INFO, 31); selected.set_severity_count(UVM_WARNING, 99);
    uvm_report_server::set_server(selected);
    $display("UT: global_selected wrapper %0d core %0d severity %0d/%0d ids %0d/%0d/%0d",
             uvm_report_server::get_server() == selected, core.get_report_server() == selected,
             selected.get_severity_count(UVM_INFO), selected.get_severity_count(UVM_WARNING),
             selected.get_id_count("old41"), selected.get_id_count("shared41"),
             selected.get_id_count("new41"));
    selected.set_severity_count(UVM_INFO, 8);
    $display("UT: source_retained severity %0d ids %0d/%0d", saved.get_severity_count(UVM_INFO),
             saved.get_id_count("old41"), saved.get_id_count("shared41"));
    uvm_report_server::set_server(third); selected.set_severity_count(UVM_INFO, 9);
    $display("UT: global_repeated exact %0d severity %0d ids %0d/%0d/%0d/%0d",
             uvm_report_server::get_server() == third, third.get_severity_count(UVM_INFO),
             third.get_id_count("old41"), third.get_id_count("shared41"),
             third.get_id_count("new41"), third.get_id_count("third41"));
    core.set_report_server(saved);
    $display("UT: global_restored %0d", uvm_report_server::get_server() == saved);
    $finish;
  end
endmodule
