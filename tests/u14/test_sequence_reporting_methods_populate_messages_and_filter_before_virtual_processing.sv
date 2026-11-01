/*
:name: test_sequence_reporting_methods_populate_messages_and_filter_before_virtual_processing
:description: sequence reporting methods populate messages and filter before virtual processing (IEEE 1800.2-2020 Section 14.1.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.3 14.1.3.4 14.1.3.2 6.3.4.3 14.1.2.6 14.1.2.8 14.1.2.14 F.4.1.4.1 6.2.4.10 6.2.4.1 6.2.4.2 6.2.4.3 6.2.4.4 6.2.4.5 6.2.4.6 6.2.4.7 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_reporting_methods_populate_messages_and_filter_before_virtual_processing.expected
*/
// Explicit reporting context only: no driver, item arbitration or report text
// formatting is assumed. Probe overrides are distinct from handler routing.
module test_sequence_reporting_methods_populate_messages_and_filter_before_virtual_processing;
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

    automatic message_probe item = new();
    automatic bit arguments_match = 1;
    automatic bit severities_match = 1;


    item.set_sequencer(first); first.set_report_verbosity_level(100);
    item.uvm_report_info("ID", "payload", 50, "origin.sv", 17, "manual");
    item.uvm_report_warning("ID", "payload", 50, "origin.sv", 17, "manual");
    item.uvm_report_error("ID", "payload", 50, "origin.sv", 17, "manual");
    item.uvm_report_fatal("ID", "payload", 50, "origin.sv", 17, "manual");
    item.uvm_report(UVM_INFO, "ID", "payload", 50, "origin.sv", 17, "manual");
    item.uvm_report_info("FILTERED", "unobserved", 101);
    if (item.messages.size() != 5) $fatal(1, "wrong virtual dispatch count");
    foreach (item.messages[i]) begin
      arguments_match &= item.messages[i].get_id() == "ID" &&
      item.messages[i].get_message() == "payload" && item.messages[i].get_verbosity() == 50 &&
      item.messages[i].get_filename() == "origin.sv" && item.messages[i].get_line() == 17 &&
      item.messages[i].get_context() == "manual";
    end
    severities_match = item.messages[0].get_severity() == UVM_INFO &&
    item.messages[1].get_severity() == UVM_WARNING &&
    item.messages[2].get_severity() == UVM_ERROR && item.messages[3].get_severity() == UVM_FATAL &&
    item.messages[4].get_severity() == UVM_INFO;
    $display("UT: messages %0d arguments %0d severities %0d filtered %0d", item.messages.size(),
    arguments_match, severities_match, item.messages.size() == 5);

    $finish;
  end

endmodule
