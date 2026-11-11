/*
:name: test_sequence_item_reporting_reused_context_uses_current_state
:description: sequence item reporting follows live reporter configuration and context (IEEE 1800.2-2020 Section 14.1.3.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.4 14.1.3.1 14.1.3.2 14.1.3.3 14.1.2.6 14.1.2.8 14.1.2.14 5.3.4.1 6.3.8.1 6.3.8.2 6.4.3.2 6.4.7 6.2.3.1 6.2.4.7 6.2.4.10 F.4.1.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_reporting_reused_context_uses_current_state.expected
*/
// What it checks:
// 1. Nonempty preformed context survives reporter and path changes.
// 2. Clearing a reused preformed context causes refill from the current path.
// 3. Default preformed processing forwards the same message handle on each
//    selected call.
// 4. Reused preformed message origin is populated for the currently selected
//    reporter.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-REUSED-CONTEXT-PRESERVED) gives rule
//    1 above. Setup: The first call fills an empty context; the same message
//    is reused after rename/rebinding. Expected: Both entry snapshots retain
//    parent.item.
// 2. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-EMPTY-CONTEXT-REFILL) gives rule 2
//    above. Setup: After a preserved reuse, the caller sets context to empty
//    before processing again. Expected: Handler and caller then see
//    changed.child.
// 3. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-REUSED-HANDLE-IDENTITY) gives rule 3
//    above. Setup: One message is processed three times through two sequencer
//    handlers. Expected: Every captured argument equals the caller handle.
// 4. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-REUSED-ORIGIN-REBINDING) gives rule
//    4 above. Setup: The item rebinds from first to second while retaining the
//    same message. Expected: Entry origins change to second and the caller
//    retains that current origin.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Public handler arguments capture identity and context at entry.
// The root handler is restored. No arbitration, catcher getter, server
// formatting
// or concurrent mutation is part of this reporting-only fixture.
module test_sequence_item_reporting_reused_context_uses_current_state;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class audit_handler extends uvm_report_handler;
    `uvm_object_utils(audit_handler)
    uvm_report_message messages[$];
    uvm_report_object origins[$];
    string contexts[$];
    function new(string name="handler"); super.new(name); endfunction
    virtual function void process_report_message(uvm_report_message message);
      messages.push_back(message); origins.push_back(message.get_report_object());
      contexts.push_back(message.get_context());
    endfunction
  endclass
  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(empty_sequence)
    function new(string name="parent"); super.new(name); endfunction
    virtual task body(); endtask
  endclass
  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_report_object root_reporter = core.get_root();
    automatic uvm_report_handler saved_root = root_reporter.get_report_handler();
    automatic uvm_sequencer#(uvm_sequence_item) first = new("first", null);
    automatic uvm_sequencer#(uvm_sequence_item) second = new("second", null);
    automatic audit_handler original = new("original");
    automatic audit_handler replacement = new("replacement");
    automatic audit_handler root_handler = new("root_handler");
    automatic empty_sequence parent_seq = new("parent");
    automatic uvm_sequence_item item = new("item");
    automatic uvm_sequence_item peer = new("peer");
    uvm_report_message msg;
    first.set_report_handler(original); second.set_report_handler(replacement);
    item.set_parent_sequence(parent_seq); item.set_sequencer(first);
    msg = uvm_report_message::new_report_message("message");
    msg.set_report_message(UVM_INFO, "reuse", "payload", UVM_NONE, "", 0, "");
    item.uvm_process_report_message(msg);
    parent_seq.set_name("changed"); item.set_name("child"); item.set_sequencer(second);
    item.uvm_process_report_message(msg);
    $display("UT: reuse origins %0d contexts %s %s", original.origins[0] == first &&
             replacement.origins[0] == second, original.contexts[0], replacement.contexts[0]);
    msg.set_context(""); item.uvm_process_report_message(msg);
    $display("UT: cleared context %s caller %s", replacement.contexts[1], msg.get_context());
    $display("UT: same_handle %0d current_origin %0d", original.messages[0] == msg &&
             replacement.messages[0] == msg && replacement.messages[1] == msg,
             msg.get_report_object() == second);
    root_reporter.set_report_handler(saved_root); $finish;
  end
endmodule
