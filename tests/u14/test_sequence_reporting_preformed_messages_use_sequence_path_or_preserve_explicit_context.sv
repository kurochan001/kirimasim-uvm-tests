/*
:name: test_sequence_reporting_preformed_messages_use_sequence_path_or_preserve_explicit_context
:description: preformed sequence reports select the current reporter and preserve explicit context (IEEE 1800.2-2020 Section 14.1.3.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.4 14.1.3.1 6.6.3.1 6.6.3.4 6.6.3.5 6.6.5 10.7.2.5 14.1.2.6 14.1.2.8 14.1.2.14 F.4.1.4.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_reporting_preformed_messages_use_sequence_path_or_preserve_explicit_context.expected
*/
// Explicit reporting context only: no driver, item arbitration or report text
// formatting is assumed. Probe overrides are distinct from handler routing.
module test_sequence_reporting_preformed_messages_use_sequence_path_or_preserve_explicit_context;
  import uvm_pkg::*;

  `include "uvm_macros.svh"
  class empty_sequence extends uvm_sequence#(uvm_sequence_item);
    function new(string name="sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  class message_probe extends uvm_sequence_item;
    uvm_report_message messages[$];
    function new(string name="probe"); super.new(name); endfunction
    virtual function void uvm_process_report_message(uvm_report_message report_message);
      messages.push_back(report_message);
    endfunction
  endclass
  class catcher extends uvm_report_catcher;
    int calls = 0;
    bit clients_match = 1;
    bit contexts_match = 1;
    uvm_report_object expected_client;
    string expected_context;
    function new(); super.new("catcher"); endfunction
    function action_e catch();
      if (get_id() == "ROUTE") begin
        calls++; clients_match &= get_client() == expected_client;
        contexts_match &= get_context() == expected_context;
        return CAUGHT;
      end
      return THROW;
    endfunction
  endclass

  initial begin
    automatic uvm_coreservice_t core = uvm_coreservice_t::get();
    automatic uvm_report_object root_reporter = core.get_root();
    automatic uvm_sequencer#(uvm_sequence_item) first = new("first", null);
    automatic uvm_sequencer#(uvm_sequence_item) peer = new("peer", null);

    automatic empty_sequence parent_sequence = new("parent_sequence");
    automatic uvm_sequence_item item = new("item");
    automatic uvm_report_message implicit_message = new("implicit_message");
    automatic uvm_report_message explicit_message = new("explicit_message");
    automatic uvm_report_message root_message = new("root_message");
    automatic catcher probe = new();


    item.set_parent_sequence(parent_sequence); item.set_sequencer(first);
    uvm_report_cb::add(null, probe);
    implicit_message.set_report_message(UVM_INFO, "ROUTE", "first", 0, "origin.sv", 17, "");
    probe.expected_client = first; probe.expected_context = "parent_sequence.item";
    item.uvm_process_report_message(implicit_message);
    item.set_sequencer(peer);
    explicit_message.set_report_message(UVM_INFO, "ROUTE", "second", 0, "origin.sv", 19, "manual");
    probe.expected_client = peer; probe.expected_context = "manual";
    item.uvm_process_report_message(explicit_message);
    item.set_sequencer(null);
    root_message.set_report_message(UVM_INFO, "ROUTE", "third", 0, "origin.sv", 23, "");
    probe.expected_client = root_reporter; probe.expected_context = "parent_sequence.item";
    item.uvm_process_report_message(root_message);
    $display("UT: routed %0d clients %0d contexts %0d", probe.calls, probe.clients_match,
    probe.contexts_match);
    $display("UT: message_contexts implicit %s explicit %s root %s",
    implicit_message.get_context(), explicit_message.get_context(), root_message.get_context());
    uvm_report_cb::delete(null, probe);

    $finish;
  end

endmodule
