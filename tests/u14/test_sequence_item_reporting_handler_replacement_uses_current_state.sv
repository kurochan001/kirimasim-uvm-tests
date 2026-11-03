/*
:name: test_sequence_item_reporting_handler_replacement_uses_current_state
:description: sequence item reporting follows live reporter configuration and context (IEEE 1800.2-2020 Section 14.1.3.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.2 14.1.3.1 14.1.3.3 14.1.3.4 14.1.2.6 14.1.2.8 14.1.2.14 5.3.4.1 6.3.8.1 6.3.8.2 6.4.3.2 6.4.7 6.2.3.1 6.2.4.7 6.2.4.10 F.4.1.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_reporting_handler_replacement_uses_current_state.expected
*/
// Public handler arguments capture identity and context at entry.
// The root handler is restored. No arbitration, catcher getter, server
// formatting
// or concurrent mutation is part of this reporting-only fixture.
module test_sequence_item_reporting_handler_replacement_uses_current_state;
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
    original.set_verbosity_level(UVM_LOW); replacement.set_verbosity_level(UVM_NONE);
    first.set_report_handler(original); second.set_report_handler(original);
    item.set_sequencer(first); peer.set_sequencer(second);
    item.uvm_report_info("before", "payload", UVM_LOW);
    first.set_report_handler(replacement);
    item.uvm_report_info("hidden", "payload", UVM_LOW);
    $display("UT: filtered old %0d replacement %0d enabled %0d", original.messages.size(),
             replacement.messages.size(), item.uvm_report_enabled(UVM_LOW));
    item.uvm_report_info("visible", "payload", UVM_NONE);
    peer.uvm_report_info("peer", "payload", UVM_LOW);
    $display("UT: final old %0d replacement %0d peer_enabled %0d", original.messages.size(),
             replacement.messages.size(), peer.uvm_report_enabled(UVM_LOW));
    $display("UT: routing %0d origins %0d", original.messages[0].get_id() == "before" &&
             original.messages[1].get_id() == "peer" &&
             replacement.messages[0].get_id() == "visible",
             original.origins[0] == first && original.origins[1] == second &&
             replacement.origins[0] == first);
    root_reporter.set_report_handler(saved_root); $finish;
  end
endmodule
