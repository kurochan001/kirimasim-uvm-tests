/*
:name: test_report_handler_generated_dispatch_preserves_message_and_reporter
:description: report objects delegate actual messages to the selected public handler (IEEE 1800.2-2020 Section 6.4.7)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.7 6.3.3.4 6.3.3.3 6.3.8.1 6.3.8.2 6.2.3.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_generated_dispatch_preserves_message_and_reporter.expected
*/
// What it checks:
// 1. get_report_handler returns the installed processing handler.
// 2. An installed handler receives subsequent report processing.
// 3. process_report_message is the handler entry for delegated reporting.
// 4. The reporting API forwards its supplied severity field to processing.
// 5. The reporting API forwards its supplied id field to processing.
// 6. The reporting API forwards its supplied text field to processing.
// 7. The reporting API forwards its supplied verbosity field to processing.
// 8. The reporting API forwards its supplied filename field to processing.
// 9. The reporting API forwards its supplied line field to processing.
// 10. The reporting API forwards its supplied context field to processing.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.3.8.1 (UVM-HANDLER-SELECTED-GETTER) gives rule 1 above.
//    Setup: Local reporters install original handlers and dispatch real
//    messages. Expected: Queries match the handlers that receive the selected
//    messages.
// 2. 1800.2-2020 6.3.8.2 (UVM-HANDLER-ASSIGNMENT-DISPATCH) gives rule 2 above.
//    Setup: Preformed and generated reports use an explicit local handler.
//    Expected: Each message reaches that handler once.
// 3. 1800.2-2020 6.4.7 (UVM-HANDLER-PUBLIC-PROCESSING-HOOK) gives rule 3
//    above. Setup: An original handler overrides the public processing method.
//    Expected: The override receives each selected actual message.
// 4. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-SEVERITY) gives rule 4 above.
//    Setup: An INFO report is generated with all optional common fields
//    explicit and within its limit. Expected: The installed handler receives
//    INFO in the selected field.
// 5. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-ID) gives rule 5 above. Setup:
//    An INFO report is generated with all optional common fields explicit and
//    within its limit. Expected: The installed handler receives generated in
//    the selected field.
// 6. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-TEXT) gives rule 6 above.
//    Setup: An INFO report is generated with all optional common fields
//    explicit and within its limit. Expected: The installed handler receives
//    payload in the selected field.
// 7. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-VERBOSITY) gives rule 7 above.
//    Setup: An INFO report is generated with all optional common fields
//    explicit and within its limit. Expected: The installed handler receives
//    LOW in the selected field.
// 8. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-FILENAME) gives rule 8 above.
//    Setup: An INFO report is generated with all optional common fields
//    explicit and within its limit. Expected: The installed handler receives
//    generated.sv in the selected field.
// 9. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-LINE) gives rule 9 above.
//    Setup: An INFO report is generated with all optional common fields
//    explicit and within its limit. Expected: The installed handler receives
//    27 in the selected field.
// 10. 1800.2-2020 6.3.3.3 (UVM-HANDLER-GENERATED-CONTEXT) gives rule 10 above.
//     Setup: An INFO report is generated with all optional common fields
//     explicit and within its limit. Expected: The installed handler receives
//     ctx in the selected field.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An original handler override captures its public processing argument.
// It does not forward to the default server or use the missing catcher getter.
module test_report_handler_generated_dispatch_preserves_message_and_reporter;
  import uvm_pkg::*;
  class audit_handler extends uvm_report_handler;
    uvm_report_message messages[$];
    function new(string name="handler"); super.new(name); endfunction
    virtual function void process_report_message(uvm_report_message message);
      messages.push_back(message);
    endfunction
  endclass

  initial begin
    automatic uvm_report_object reporter = new("reporter");
      automatic audit_handler handler = new();
    reporter.set_report_handler(handler); reporter.set_report_verbosity_level(UVM_DEBUG);
      reporter.uvm_report_info("generated", "payload", UVM_LOW, "generated.sv", 27, "ctx");
      $display("UT: calls %0d selected_handler %0d origin %0d", handler.messages.size(),
               reporter.get_report_handler() == handler,
               handler.messages[0].get_report_object() == reporter);
      $display("UT: fields %0d", handler.messages[0].get_severity() == UVM_INFO &&
               handler.messages[0].get_id() == "generated" &&
               handler.messages[0].get_message() == "payload" &&
               handler.messages[0].get_verbosity() == UVM_LOW &&
               handler.messages[0].get_filename() == "generated.sv" &&
               handler.messages[0].get_line() == 27 && handler.messages[0].get_context() == "ctx");
    $finish;
  end
endmodule
