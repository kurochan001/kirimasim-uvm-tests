/*
:name: test_report_handler_replacement_dispatch_preserves_message_and_reporter
:description: report objects delegate actual messages to the selected public handler (IEEE 1800.2-2020 Section 6.3.8.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.3.8.1 6.3.3.4 6.3.3.3 6.3.8.2 6.4.7 6.2.3.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_replacement_dispatch_preserves_message_and_reporter.expected
*/
// An original handler override captures its public processing argument.
// It does not forward to the default server or use the missing catcher getter.
module test_report_handler_replacement_dispatch_preserves_message_and_reporter;
  import uvm_pkg::*;
  class audit_handler extends uvm_report_handler;
    uvm_report_message messages[$];
    function new(string name="handler"); super.new(name); endfunction
    virtual function void process_report_message(uvm_report_message message);
      messages.push_back(message);
    endfunction
  endclass

  initial begin
    automatic uvm_report_object first = new("first");
      automatic uvm_report_object second = new("second");
      automatic audit_handler shared = new("shared");
      automatic audit_handler replacement = new("replacement");
      automatic uvm_report_message a = uvm_report_message::new_report_message("a");
      automatic uvm_report_message b = uvm_report_message::new_report_message("b");
      automatic uvm_report_message c = uvm_report_message::new_report_message("c");
    first.set_report_handler(shared); second.set_report_handler(shared);
      a.set_report_message(UVM_INFO, "A", "one", UVM_NONE, "", 0, "ctx");
      b.set_report_message(UVM_INFO, "B", "two", UVM_NONE, "", 0, "ctx");
      c.set_report_message(UVM_INFO, "C", "three", UVM_NONE, "", 0, "ctx");
      first.uvm_process_report_message(a);
      second.set_report_handler(replacement);
      second.uvm_process_report_message(b); first.uvm_process_report_message(c);
      $display("UT: shared_calls %0d replacement_calls %0d selected %0d",
               shared.messages.size(), replacement.messages.size(),
               first.get_report_handler() == shared && second.get_report_handler() == replacement);
      $display("UT: routing %0d origins %0d", shared.messages[0] == a &&
               shared.messages[1] == c && replacement.messages[0] == b,
               a.get_report_object() == first && b.get_report_object() == second &&
               c.get_report_object() == first);
    $finish;
  end
endmodule
