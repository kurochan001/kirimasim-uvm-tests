/*
:name: test_report_catcher_issue_counts_the_current_message_before_it_is_caught
:description: immediate issue and callback disposition have distinct report counts (IEEE 1800.2-2020 Section 6.6.6.6)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.6.6 6.6.4.3 6.6 6.6.5 6.5.1.2.6 6.5.1.2.8 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_issue_counts_the_current_message_before_it_is_caught.expected
*/
// Issue observes the changed current ID. CAUGHT suppresses normal emission;
// THROW also permits normal emission after the tail callback.
module test_report_catcher_issue_counts_the_current_message_before_it_is_caught;
  import uvm_pkg::*;
  class issuing_catcher extends uvm_report_catcher;
    int visits = 0;
    function new(); super.new("issuer"); endfunction
    virtual function action_e catch();
      visits++;
      set_id("issued");
      issue();
      return CAUGHT;
    endfunction
  endclass
  class tail_catcher extends uvm_report_catcher;
    int visits = 0;
    function new(); super.new("tail"); endfunction
    virtual function action_e catch(); visits++; return THROW; endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("local_reporter");
    automatic issuing_catcher issuer = new();
    automatic tail_catcher tail = new();
    uvm_report_server server;
    int before_info, before_issued, before_original;
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    server = uvm_report_server::get_server();
    uvm_report_cb::add(reporter, issuer); uvm_report_cb::add(reporter, tail);
    before_info = server.get_severity_count(UVM_INFO);
    before_issued = server.get_id_count("issued");
    before_original = server.get_id_count("original");
    reporter.uvm_report_info("original", "payload", UVM_NONE);
    $display("UT: callbacks issuer %0d tail %0d", issuer.visits, tail.visits);
    $display("UT: counts info %0d issued %0d original %0d",
             server.get_severity_count(UVM_INFO) - before_info,
             server.get_id_count("issued") - before_issued,
             server.get_id_count("original") - before_original);
    uvm_report_cb::delete(reporter, issuer); uvm_report_cb::delete(reporter, tail);
    $finish;
  end
endmodule
