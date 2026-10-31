/*
:name: test_report_server_copy_takes_an_independent_count_snapshot
:description: copying report statistics creates a snapshot and later copies overwrite existing counts (IEEE 1800.2-2020 Section 6.5.1.2.13)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.13 6.5.1.2.9 6.5.1.2.8 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_copy_takes_an_independent_count_snapshot.expected
*/
// Populate the source through standard report calls. A separate server
// receives snapshots, without relying on implementation-only counter setters.

module test_report_server_copy_takes_an_independent_count_snapshot;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_server source = uvm_report_server::get_server();
    automatic uvm_default_report_server snapshot = new("snapshot");
    string ids[$];
    automatic int alpha_seen = 0;
    automatic int beta_seen = 0;
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.uvm_report_info("M1_COPY_ALPHA", "first", UVM_NONE);
    reporter.uvm_report_info("M1_COPY_ALPHA", "repeat", UVM_NONE);
    snapshot.copy(source);
    reporter.uvm_report_info("M1_COPY_BETA", "later", UVM_NONE);
    $display("UT: independent alpha %0d beta %0d source_beta %0d",
        snapshot.get_id_count("M1_COPY_ALPHA"),
             snapshot.get_id_count("M1_COPY_BETA"), source.get_id_count("M1_COPY_BETA"));
    snapshot.copy(source);
    snapshot.get_id_set(ids);
    foreach (ids[i]) begin
      if (ids[i] == "M1_COPY_ALPHA") alpha_seen++;
      if (ids[i] == "M1_COPY_BETA") beta_seen++;
    end
    $display("UT: recopied alpha %0d beta %0d membership %0d %0d",
        snapshot.get_id_count("M1_COPY_ALPHA"),
             snapshot.get_id_count("M1_COPY_BETA"), alpha_seen, beta_seen);
    $finish;
  end
endmodule
