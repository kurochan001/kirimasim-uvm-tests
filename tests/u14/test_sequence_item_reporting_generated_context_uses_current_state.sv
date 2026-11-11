/*
:name: test_sequence_item_reporting_generated_context_uses_current_state
:description: sequence item reporting follows live reporter configuration and context (IEEE 1800.2-2020 Section 14.1.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.3 14.1.3.1 14.1.3.2 14.1.3.4 14.1.2.6 14.1.2.8 14.1.2.14 5.3.4.1 6.3.8.1 6.3.8.2 6.4.3.2 6.4.7 6.2.3.1 6.2.4.7 6.2.4.10 F.4.1.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_reporting_generated_context_uses_current_state.expected
*/
// What it checks:
// 1. The selected report object follows the current sequencer or root
//    fallback.
// 2. Separately generated item messages retain their own populated contexts.
// 3. An empty generated context is filled from the current sequence path.
// 4. Explicit generated context is retained during root-fallback reporting.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.3.1 (UVM-SEQ-REPORT-CURRENT-REPORTER) gives rule 1
//    above. Setup: Generated reports bind to first, then second, then clear
//    the item sequencer. Expected: Captured origins identify first, second and
//    the root respectively.
// 2. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-GENERATED-CONTEXT-SNAPSHOT) gives
//    rule 2 above. Setup: Parent/item names and reporter change between
//    generated messages. Expected: Earlier message contexts retain their prior
//    strings.
// 3. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-GENERATED-EMPTY-CONTEXT-FILL) gives
//    rule 3 above. Setup: Parent/item names change from parent/item to
//    changed/child before the next report. Expected: Contexts are parent.item
//    then changed.child.
// 4. 1800.2-2020 14.1.3.4 (UVM-SEQ-REPORT-GENERATED-EXPLICIT-CONTEXT) gives
//    rule 4 above. Setup: After clearing the sequencer, the report explicitly
//    supplies manual. Expected: The root-routed message keeps manual.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Public handler arguments capture identity and context at entry.
// The root handler is restored. No arbitration, catcher getter, server
// formatting
// or concurrent mutation is part of this reporting-only fixture.
module test_sequence_item_reporting_generated_context_uses_current_state;
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
    root_reporter.set_report_handler(root_handler);
    item.set_parent_sequence(parent_seq); item.set_sequencer(first);
    item.uvm_report_info("A", "payload", UVM_NONE);
    parent_seq.set_name("changed"); item.set_name("child"); item.set_sequencer(second);
    item.uvm_report_info("B", "payload", UVM_NONE);
    item.set_sequencer(null);
    item.uvm_report_info("C", "payload", UVM_NONE, "", 0, "manual");
    $display("UT: counts %0d %0d %0d origins %0d", original.messages.size(),
             replacement.messages.size(), root_handler.messages.size(),
             original.origins[0] == first && replacement.origins[0] == second &&
             root_handler.origins[0] == root_reporter);
    $display("UT: contexts %s %s %s", original.contexts[0], replacement.contexts[0],
             root_handler.contexts[0]);
    $display("UT: message_snapshots %0d", original.messages[0].get_context() == "parent.item" &&
             replacement.messages[0].get_context() == "changed.child" &&
             root_handler.messages[0].get_context() == "manual");
    root_reporter.set_report_handler(saved_root); $finish;
  end
endmodule
