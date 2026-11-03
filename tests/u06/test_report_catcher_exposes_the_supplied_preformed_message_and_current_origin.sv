/*
:name: test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin
:description: preformed report processing exposes the original message with its current report object (IEEE 1800.2-2020 Section 6.6.3.10)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.6.3.10 6.3.3.4 6.3.3.1 6.2.3.1 6.6.3.1 6.6.3.3 6.6.3.5 6.6.3.6 6.6.3.8 6.6.3.9 6.2.4.10 D.4.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin.expected
*/
// The caller supplies the message and an obsolete origin reference.
// The tail catches it before server emission; no formatted text is required.
// The pinned release omits required catcher get_report_message.
// Keep the public API and expected behavior without a private substitute.

module test_report_catcher_exposes_the_supplied_preformed_message_and_current_origin;
  import uvm_pkg::*;
  class probe_type extends uvm_report_catcher;
    uvm_report_message expected;
    uvm_report_object client;
    int visits = 0;
    bit same = 0, origin = 0, fields = 0;
    function new(); super.new("probe"); endfunction
    virtual function action_e catch();
      uvm_report_message current;
      current = get_report_message(); visits++;
      same = current == expected;
      origin = get_client() == client && current.get_report_object() == client;
      fields = get_id() == "original" && get_message() == "payload" &&
               get_context() == "input.ctx" && get_fname() == "input.sv" && get_line() == 41;
      return CAUGHT;
    endfunction
  endclass
  initial begin
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_object old_origin = new("old_origin");
    automatic uvm_report_message msg = uvm_report_message::new_report_message("input");
    automatic probe_type probe = new();
    msg.set_report_message(UVM_INFO, "original", "payload", UVM_LOW,
                           "input.sv", 41, "input.ctx");
    msg.set_report_object(old_origin);
    reporter.set_report_verbosity_level(UVM_DEBUG);
    probe.expected = msg; probe.client = reporter;
    uvm_report_cb::add(reporter, probe);
    reporter.uvm_process_report_message(msg);
    $display("UT: visits %0d same_message %0d current_origin %0d fields %0d",
             probe.visits, probe.same, probe.origin, probe.fields);
    $display("UT: caller_origin %0d report_object %0d", msg.get_report_object() == reporter,
             reporter.uvm_get_report_object() == reporter);
    uvm_report_cb::delete(reporter, probe); $finish;
  end
endmodule
