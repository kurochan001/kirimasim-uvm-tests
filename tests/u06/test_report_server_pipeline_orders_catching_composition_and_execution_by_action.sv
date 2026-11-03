/*
:name: test_report_server_pipeline_orders_catching_composition_and_execution_by_action
:description: report server pipeline orders catching composition and execution by action
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.5.1.2.14 6.5.1.2.15 6.5.1.2.16 6.6.5 6.2 6.2.3.1 6.2.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_server_pipeline_orders_catching_composition_and_execution_by_action.expected
*/
module test_report_server_pipeline_orders_catching_composition_and_execution_by_action;
  import uvm_pkg::*;
  // Original format/action overrides observe framework dispatch only. No
  // default text format or unspecified no-compose string is prescribed.
  class audit_server extends uvm_default_report_server;
    string trace;
    int formats, executions;
    uvm_report_message formatted, executed;
    string received, name_argument;
    virtual function string compose_report_message(uvm_report_message report_message,
                                                  string report_object_name = "");
      trace = {trace, "F"}; formats++; formatted = report_message;
      name_argument = report_object_name;
      return {report_message.get_id(), ":", report_message.get_message()};
    endfunction
    virtual function void execute_report_message(uvm_report_message report_message,
                                                string composed_message);
      trace = {trace, "X"}; executions++; executed = report_message;
      received = composed_message;
    endfunction
  endclass
  class ordered_catcher extends uvm_report_catcher;
    audit_server target;
    virtual function action_e catch();
      target.trace = {target.trace, "C"};
      return get_id() == "caught" ? CAUGHT : THROW;
    endfunction
  endclass
  initial begin
    automatic audit_server server = new();
    automatic uvm_report_server base_view = server;
    automatic uvm_report_object reporter = new("reporter");
    automatic ordered_catcher catcher = new();
    automatic uvm_report_message msg = new("original");
    automatic uvm_action actions[6] = '{UVM_DISPLAY, UVM_NO_ACTION, UVM_DISPLAY,
                                       UVM_LOG, UVM_DISPLAY | UVM_LOG, UVM_COUNT};
    automatic string ids[6] = '{"caught", "none", "display", "log", "both", "count"};
    automatic uvm_report_server saved = uvm_report_server::get_server();
    string text;
    uvm_coreservice_t::get().set_report_server(server);
    catcher.target = server; uvm_report_cb::add(reporter, catcher);
    msg.set_report_object(reporter); msg.set_report_handler(reporter.get_report_handler());
    foreach (actions[i]) begin
      server.trace = ""; server.formats = 0; server.executions = 0;
      server.formatted = null; server.executed = null;
      msg.set_report_message(UVM_INFO, ids[i], "payload", UVM_NONE, "", 0, "");
      msg.set_action(actions[i]); base_view.process_report_message(msg);
      $display("UT: pipeline %s trace %s format %0d execute %0d", ids[i], server.trace,
               server.formats, server.executions);
      if (i >= 2 && i <= 4)
        $display("UT: formatted %s exact %0d/%0d text %0d default_name %0d", ids[i],
                 server.formatted == msg, server.executed == msg,
                 server.received == {ids[i], ":payload"}, server.name_argument == "");
    end
    text = base_view.compose_report_message(msg, "chosen");
    $display("UT: explicit_composition name %0d exact %0d text %0d",
             server.name_argument == "chosen", server.formatted == msg, text == "count:payload");
    uvm_report_cb::delete(reporter, catcher);
    uvm_coreservice_t::get().set_report_server(saved); $finish;
  end
endmodule
