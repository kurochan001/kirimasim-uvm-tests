/*
:name: test_report_catcher_warning_helper_preserves_origin_defaults_and_bypasses_both_callbacks
:description: report catcher warning helper preserves origin defaults and bypasses both callbacks
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.6.3 6.6.3.1 6.6.5 6.5.1.2.16 6.3.5.2 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_warning_helper_preserves_origin_defaults_and_bypasses_both_callbacks.expected
*/
module test_report_catcher_warning_helper_preserves_origin_defaults_and_bypasses_both_callbacks;
  import uvm_pkg::*;
  // The fatal helper uses DISPLAY alone, so no UVM_EXIT is requested.
  // A visit guard bounds recursion; the server captures the real message.
  class audit_server extends uvm_default_report_server;
    uvm_report_message helper;
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message);
      if (report_message.get_id() == "helper41") helper = report_message;
      super.execute_report_message(report_message, composed_message);
    endfunction
  endclass
  class issuing_catcher extends uvm_report_catcher;
    int visits = 0;
    uvm_report_object client;
    bit exact_client = 1;
    virtual function action_e catch();
      visits++; exact_client &= get_client() == client;
      if (visits == 1) uvm_report_warning("helper41", "supplement", UVM_NONE);
      return THROW;
    endfunction
  endclass
  class tail_catcher extends uvm_report_catcher;
    int visits = 0;
    virtual function action_e catch(); visits++; return THROW; endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("local_reporter");
    automatic issuing_catcher issuer = new();
    automatic tail_catcher tail = new();
    automatic audit_server server = new();
    automatic uvm_report_server saved = uvm_report_server::get_server();
    uvm_coreservice_t::get().set_report_server(server);
    reporter.set_report_severity_action(UVM_INFO, UVM_DISPLAY);
    reporter.set_report_severity_action(UVM_WARNING, UVM_DISPLAY);
    issuer.client = reporter;
    uvm_report_cb::add(reporter, issuer); uvm_report_cb::add(reporter, tail);
    reporter.uvm_report_info("outer41", "original", UVM_NONE);
    if (server.helper == null) $fatal(1, "helper did not reach real server");
    $display("UT: helper_callbacks issuer %0d tail %0d client %0d", issuer.visits,
             tail.visits, issuer.exact_client);
    $display("UT: helper_fields severity %0d origin %0d body %0d file %0d line %0d context %0d",
             server.helper.get_severity() == UVM_WARNING,
             server.helper.get_report_object() == reporter,
             server.helper.get_message() == "supplement", server.helper.get_filename() == "",
             server.helper.get_line() == 0, server.helper.get_context() == "");
    $display("UT: helper_counts selected %0d info %0d helper %0d outer %0d",
             server.get_severity_count(UVM_WARNING), server.get_severity_count(UVM_INFO),
             server.get_id_count("helper41"), server.get_id_count("outer41"));
    uvm_report_cb::delete(reporter, issuer); uvm_report_cb::delete(reporter, tail);
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
