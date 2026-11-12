/*
:name: test_report_handler_preformed_dispatch_preserves_message_and_reporter
:description: report objects delegate actual messages to the selected public handler (IEEE 1800.2-2020 Section 6.3.3.4)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.3.4 6.3.3.3 6.3.8.1 6.3.8.2 6.4.7 6.2.3.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_preformed_dispatch_preserves_message_and_reporter.expected
*/
// What it checks:
// 1. get_report_handler returns the installed processing handler.
// 2. An installed handler receives subsequent report processing.
// 3. process_report_message is the handler entry for delegated reporting.
// 4. uvm_process_report_message passes the supplied preformed object to its
//    handler.
// 5. Preformed processing binds the message to the processing report object.
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
// 4. 1800.2-2020 6.3.3.4 (UVM-HANDLER-PREFORMED-ARGUMENT-IDENTITY) gives rule
//    4 above. Setup: The caller retains handles before direct processing and
//    replacement routing. Expected: Captured arguments equal the
//    caller-provided handles.
// 5. 1800.2-2020 6.3.3.4 (UVM-HANDLER-PREFORMED-ORIGIN-REBINDING) gives rule 5
//    above. Setup: The supplied message initially has a different origin
//    reference. Expected: The received/caller message origin becomes the
//    actual reporter.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// An original handler override captures its public processing argument.
// It does not forward to the default server or use the missing catcher getter.
module test_report_handler_preformed_dispatch_preserves_message_and_reporter;
  import uvm_pkg::*;
  class audit_handler extends uvm_report_handler;
    uvm_report_message messages[$];
    function new(string name="handler"); super.new(name); endfunction
    virtual function void process_report_message(uvm_report_message report_message);
      messages.push_back(report_message);
    endfunction
  endclass

  initial begin
    automatic uvm_report_object reporter = new("reporter");
      automatic uvm_report_object old_origin = new("old");
      automatic audit_handler handler = new();
      automatic uvm_report_message msg = uvm_report_message::new_report_message("input");
    reporter.set_report_handler(handler);
      msg.set_report_message(UVM_INFO, "input", "payload", UVM_LOW, "input.sv", 41, "ctx");
      msg.set_report_object(old_origin);
      reporter.uvm_process_report_message(msg);
      $display("UT: calls %0d selected_handler %0d exact_message %0d origin %0d",
               handler.messages.size(), reporter.get_report_handler() == handler,
               handler.messages[0] == msg, msg.get_report_object() == reporter);
      $display("UT: content %0d", handler.messages[0].get_id() == "input" &&
               handler.messages[0].get_message() == "payload" &&
               handler.messages[0].get_filename() == "input.sv" &&
               handler.messages[0].get_line() == 41 && handler.messages[0].get_context() == "ctx");
    $finish;
  end
endmodule
