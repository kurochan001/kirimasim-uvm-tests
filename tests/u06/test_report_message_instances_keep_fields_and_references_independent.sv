/*
:name: test_report_message_instances_keep_fields_and_references_independent
:description: message instances retain independent common fields actions and infrastructure references (IEEE 1800.2-2020 Section 6.2.2.1)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.2.2.1 6.2.3.1 6.2.3.2 6.2.3.3 6.2.4.8 6.2.4.9 6.2.4.10 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_message_instances_keep_fields_and_references_independent.expected
*/
// What it checks:
// 1. Constructing report messages creates separate objects with independent
//    message fields.
// 2. The message reporter accessor stores and returns its specified reference.
// 3. The message handler accessor stores and returns its specified reference.
// 4. The message server accessor stores and returns its specified reference.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.2.2.1 (UVM-REPORT-MESSAGE-CREATE) gives rule 1 above.
//    Setup: Assign all observed fields/references explicitly, then mutate only
//    one message. Expected: The other message retains its own name, fields and
//    infrastructure handles.
// 2. 1800.2-2020 6.2.3.1 (UVM-REPORT-MESSAGE-REPORTER) gives rule 2 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// 3. 1800.2-2020 6.2.3.2 (UVM-REPORT-MESSAGE-HANDLER) gives rule 3 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// 4. 1800.2-2020 6.2.3.3 (UVM-REPORT-MESSAGE-SERVER) gives rule 4 above.
//    Setup: Set, replace and clear infrastructure handles without executing a
//    report. Expected: The selected reference changes while other
//    references/messages retain their handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Assign every observed field before comparing two messages. Changing
// one message does not mutate the other message or shared referenced objects.

module test_report_message_instances_keep_fields_and_references_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_report_message first = new("first");
    automatic uvm_report_message second = new("second");
    automatic uvm_report_object reporter = new("reporter");
    automatic uvm_report_handler handler = new("handler");
    automatic uvm_default_report_server server = new;
    first.set_report_message(UVM_INFO, "A", "alpha", UVM_LOW, "a.sv", 1, "a.ctx");
    second.set_report_message(UVM_WARNING, "B", "beta", UVM_HIGH, "b.sv", 2, "b.ctx");
    first.set_action(UVM_DISPLAY);
    second.set_action(UVM_NO_ACTION);
    first.set_file(0);
    second.set_file(0);
    first.set_report_object(reporter);
    first.set_report_handler(handler);
    first.set_report_server(server);
    second.set_report_object(reporter);
    second.set_report_handler(handler);
    second.set_report_server(server);
    first.set_report_message(UVM_ERROR, "C", "changed", UVM_NONE, "c.sv", 3, "c.ctx");
    first.set_action(UVM_LOG);
    first.set_report_object(null);
    first.set_report_handler(null);
    first.set_report_server(null);
    $display("UT: distinct %0d second_name %s id %s text %s", first != second,
             second.get_name(), second.get_id(), second.get_message());
    $display("UT: second warning %0d high %0d source %s line %0d context %s",
        second.get_severity() == UVM_WARNING,
             second.get_verbosity() == UVM_HIGH, second.get_filename(), second.get_line(),
                 second.get_context());
    $display("UT: second action %0d file %0d reporter %0d handler %0d server %0d",
             second.get_action() == UVM_NO_ACTION, second.get_file() == 0,
             second.get_report_object() == reporter, second.get_report_handler() == handler,
             second.get_report_server() == server);
    $finish;
  end
endmodule
