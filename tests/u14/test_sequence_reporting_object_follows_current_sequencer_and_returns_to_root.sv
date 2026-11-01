/*
:name: test_sequence_reporting_object_follows_current_sequencer_and_returns_to_root
:description: sequence report object follows current sequencer and returns to root (IEEE 1800.2-2020 Section 14.1.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.1 14.1.2.6 14.1.2.8 14.1.2.14 F.4.1.4.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_reporting_object_follows_current_sequencer_and_returns_to_root.expected
*/
// Explicit reporting context only: no driver, item arbitration or report text
// formatting is assumed. Probe overrides are distinct from handler routing.
module test_sequence_reporting_object_follows_current_sequencer_and_returns_to_root;
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

    automatic uvm_sequence_item item = new("item");
    automatic empty_sequence sequence_value = new("sequence_value");


    $display("UT: unbound item_root %0d sequence_root %0d",
    item.uvm_get_report_object() == root_reporter,
    sequence_value.uvm_get_report_object() == root_reporter);
    item.set_sequencer(first); sequence_value.set_sequencer(peer);
    $display("UT: bound item_first %0d sequence_peer %0d", item.uvm_get_report_object() == first,
    sequence_value.uvm_get_report_object() == peer);
    item.set_sequencer(peer); sequence_value.set_sequencer(null);
    $display("UT: rebound item_peer %0d sequence_root %0d", item.uvm_get_report_object() == peer,
    sequence_value.uvm_get_report_object() == root_reporter);
    item.set_sequencer(null);
    $display("UT: cleared item_root %0d", item.uvm_get_report_object() == root_reporter);

    $finish;
  end

endmodule
