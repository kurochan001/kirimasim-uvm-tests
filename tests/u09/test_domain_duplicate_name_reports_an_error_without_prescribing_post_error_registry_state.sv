/*
:name: test_domain_duplicate_name_reports_an_error_without_prescribing_post_error_registry_state
:description: domain duplicate name reports an error without prescribing post error registry state
:tags: u09 uvm
:type: simulation
:lrm: 1800.2-2020 9.4.2.1 6.6.3.2 6.6.5 1800-2023 6.21 8.20 8.21 13.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_domain_duplicate_name_reports_an_error_without_prescribing_post_error_registry_state.expected
*/
// What it checks:
// Constructing a duplicate domain name reports an error.
//
// How the expected output follows from the standard:
// 1800.2-2020 9.4.2.1 (UVM-PHASE-CONTRACT-DOMAIN-DUPLICATE-ERROR) gives the
// rule above. Setup: A report catcher observes creation of a second domain
// with an already registered name. Expected: At least one ERROR is observed.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Do not require an exact diagnostic count, text or duplicate post-state.
module test_domain_duplicate_name_reports_an_error_without_prescribing_post_error_registry_state;
  import uvm_pkg::*;
  class report_probe extends uvm_report_catcher;
    int errors=0;
    virtual function action_e catch();
      if (get_severity()==UVM_ERROR) errors++;
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_domain first=new("duplicate_domain53");
    automatic report_probe probe=new();
    uvm_domain duplicate;
    uvm_report_cb::add(null,probe);duplicate=new("duplicate_domain53");
    $display("UT: domain_duplicate error_reported %0d",probe.errors>0);
    $finish;
  end
endmodule
