/*
:name: test_report_catcher_generic_warning_helper_bypasses_both_catching_callbacks
:description: catcher helper reports bypass the complete callback chain (IEEE 1800.2-2020 Section 6.6.6.5)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.6.5 6.6.3.1 6.6 6.6.5 6.5.1.2.6 6.5.1.2.8 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_generic_warning_helper_bypasses_both_catching_callbacks.expected
*/
// Only the explicit reporter has these callbacks. All severities use DISPLAY.
// The visit guard bounds recursion if a helper incorrectly enters callbacks.
module test_report_catcher_generic_warning_helper_bypasses_both_catching_callbacks;
  import uvm_pkg::*;
  class issuing_catcher extends uvm_report_catcher;
    int visits = 0;
    bit clients_match = 1;
    uvm_report_object expected_client;
    function new(); super.new("issuer"); endfunction
    virtual function action_e catch();
      visits++;
      clients_match &= get_client() == expected_client;
      if (visits == 1) begin
        uvm_report(UVM_WARNING, "helper", "supplement", UVM_NONE);
      end
      return THROW;
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
    int before_info, before_error, before_warning, before_helper, before_outer;
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_ERROR, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    server = uvm_report_server::get_server();
    issuer.expected_client = reporter;
    uvm_report_cb::add(reporter, issuer);
    uvm_report_cb::add(reporter, tail);
    before_info = server.get_severity_count(UVM_INFO);
    before_error = server.get_severity_count(UVM_ERROR);
    before_warning = server.get_severity_count(UVM_WARNING);
    before_helper = server.get_id_count("helper");
    before_outer = server.get_id_count("outer");
    reporter.uvm_report_info("outer", "original", UVM_NONE);
    $display("UT: callbacks issuer %0d tail %0d client %0d", issuer.visits,
             tail.visits, issuer.clients_match);
    $display("UT: counts info %0d error %0d warning %0d helper %0d outer %0d",
             server.get_severity_count(UVM_INFO) - before_info,
             server.get_severity_count(UVM_ERROR) - before_error,
             server.get_severity_count(UVM_WARNING) - before_warning,
             server.get_id_count("helper") - before_helper,
             server.get_id_count("outer") - before_outer);
    uvm_report_cb::delete(reporter, issuer); uvm_report_cb::delete(reporter, tail);
    $finish;
  end
endmodule
