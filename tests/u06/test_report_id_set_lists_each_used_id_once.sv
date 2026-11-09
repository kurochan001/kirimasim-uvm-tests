/*
:name: test_report_id_set_lists_each_used_id_once
:description: the report server ID set contains each used ID once after repeated reports (IEEE 1800.2-2020 Section 6.5.1.2.9)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.9 6.5.1.2.8 6.3.3.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_id_set_lists_each_used_id_once.expected
*/
// What it checks:
// get_id_set returns the set of IDs used by that server.
//
// How the expected output follows from the standard:
// 1800.2-2020 6.5.1.2.9 (UVM-REPORT-SERVER-ID-SET) gives the rule above.
// Setup: Report two IDs with repetition and provide an output queue containing
// a stale entry. Expected: The output has each used ID once, excludes the
// stale entry and leaves ID counts available.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use controlled report IDs and compare membership without assuming
// iteration order. The output queue replaces its earlier caller contents.

module test_report_id_set_lists_each_used_id_once;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server server = uvm_report_server::get_server();
    automatic string after_ids[$] = '{"stale"};
    string before_ids[$];
    automatic int alpha_seen = 0;
    automatic int beta_seen = 0;
    automatic int stale_seen = 0;
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    server.get_id_set(before_ids);
    reporter.uvm_report_info("M1_IDSET_ALPHA", "first", UVM_NONE);
    reporter.uvm_report_info("M1_IDSET_BETA", "second", UVM_NONE);
    reporter.uvm_report_info("M1_IDSET_ALPHA", "repeat", UVM_NONE);
    server.get_id_set(after_ids);
    foreach (after_ids[i]) begin
      if (after_ids[i] == "M1_IDSET_ALPHA") alpha_seen++;
      if (after_ids[i] == "M1_IDSET_BETA") beta_seen++;
      if (after_ids[i] == "stale") stale_seen++;
    end
    $display("UT: new_ids %0d alpha %0d beta %0d stale %0d", after_ids.size() - before_ids.size(),
             alpha_seen, beta_seen, stale_seen);
    $display("UT: counts alpha %0d beta %0d", server.get_id_count("M1_IDSET_ALPHA"),
             server.get_id_count("M1_IDSET_BETA"));
    $finish;
  end
endmodule
