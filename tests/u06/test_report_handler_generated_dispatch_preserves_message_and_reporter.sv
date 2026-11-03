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
