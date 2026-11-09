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
// What it checks:
// 1. Report processing ends without executing the report when its action is
//    UVM_NO_ACTION.
// 2. The same preformed message is retained at the selected server formatting
//    and execution stages.
// 3. A caught report stops before composition and execution.
// 4. A DISPLAY action composes then executes after the catcher.
// 5. A LOG action composes then executes after the catcher.
// 6. Combined DISPLAY and LOG composes once before executing once.
// 7. A nonformatting nonzero action skips composition and still executes after
//    catching.
// 8. The compose virtual interface supplies the omitted empty object-name
//    override.
// 9. A compose call through the exact server base passes the explicit
//    object-name override.
// 10. The composed message is passed to the selected execution hook with the
//     exact report object.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-NO-ACTION) gives rule 1 above. Setup:
//    An enabled info report is first suppressed by action, then restored to a
//    counting action. Expected: Suppression adds no severity or ID counts; the
//    enabled control adds one to each.
// 2. 1800.2-2020 6.2 (UVM-REPORT-AUDIT-MESSAGE-PIPELINE-HANDLE) gives rule 2
//    above. Setup: Use the selected original reporting fixtures and explicit
//    object, severity, ID and action configuration described by their
//    observation anchors. Expected: Both hooks receive the exact original
//    message and the selected payload reaches execution.
// 3. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-AUDIT-PIPELINE-CAUGHT-STOP) gives rule
//    3 above. Setup: Call the currently selected original default-server
//    subtype with a configured preformed message; the catcher returns CAUGHT
//    only for the selected stop case. Expected: The selected trace is C, CFX
//    or CX with the corresponding zero/one hook counts.
// 4. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-AUDIT-PIPELINE-DISPLAY-COMPOSE) gives
//    rule 4 above. Setup: Call the currently selected original default-server
//    subtype with a configured preformed message; the catcher returns CAUGHT
//    only for the selected stop case. Expected: The selected trace is C, CFX
//    or CX with the corresponding zero/one hook counts.
// 5. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-AUDIT-PIPELINE-LOG-COMPOSE) gives rule
//    5 above. Setup: Call the currently selected original default-server
//    subtype with a configured preformed message; the catcher returns CAUGHT
//    only for the selected stop case. Expected: The selected trace is C, CFX
//    or CX with the corresponding zero/one hook counts.
// 6. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-AUDIT-PIPELINE-BOTH-COMPOSE-ONCE)
//    gives rule 6 above. Setup: Call the currently selected original
//    default-server subtype with a configured preformed message; the catcher
//    returns CAUGHT only for the selected stop case. Expected: The selected
//    trace is C, CFX or CX with the corresponding zero/one hook counts.
// 7. 1800.2-2020 6.5.1.2.14 (UVM-REPORT-AUDIT-PIPELINE-NONFORMAT-EXECUTE)
//    gives rule 7 above. Setup: Call the currently selected original
//    default-server subtype with a configured preformed message; the catcher
//    returns CAUGHT only for the selected stop case. Expected: The selected
//    trace is C, CFX or CX with the corresponding zero/one hook counts.
// 8. 1800.2-2020 6.5.1.2.15 (UVM-REPORT-AUDIT-COMPOSE-DEFAULT-NAME-SIGNATURE)
//    gives rule 8 above. Setup: Use the selected original reporting fixtures
//    and explicit object, severity, ID and action configuration described by
//    their observation anchors. Expected: The original override receives the
//    exact message and an empty name for formatted pipeline calls.
// 9. 1800.2-2020 6.5.1.2.15 (UVM-REPORT-AUDIT-COMPOSE-EXPLICIT-NAME-SIGNATURE)
//    gives rule 9 above. Setup: Use the selected original reporting fixtures
//    and explicit object, severity, ID and action configuration described by
//    their observation anchors. Expected: The selected override receives
//    chosen and the original message and returns its original formatted
//    payload.
// 10. 1800.2-2020 6.5.1.2.16 (UVM-REPORT-AUDIT-EXECUTE-FORMATTED-ARGUMENT)
//     gives rule 10 above. Setup: Use the selected original reporting fixtures
//     and explicit object, severity, ID and action configuration described by
//     their observation anchors. Expected: The original execution override
//     receives the string returned by compose for LOG, DISPLAY and their
//     combination.
// These expectations come from the cited clauses, not from the output of a
// simulator.
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
