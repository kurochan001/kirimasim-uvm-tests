/*
:name: test_sequence_item_reporting_filters_each_severity_before_virtual_processing
:description: sequence item report methods gate every severity before virtual processing (IEEE 1800.2-2020 Section 14.1.3.3)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.1.3.3 14.1.3.2 14.1.3.1 14.1.3.4 14.1.2.6 6.3.4.3 6.2.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_item_reporting_filters_each_severity_before_virtual_processing.expected
*/
// What it checks:
// 1. Above-limit report-enabled queries return false for the selected severity
//    keys.
// 2. The sequence-item INFO method does nothing when report-enabled returns
//    zero.
// 3. The sequence-item INFO method creates a message at the enabled limit.
// 4. The sequence-item WARNING method does nothing when report-enabled returns
//    zero.
// 5. The sequence-item WARNING method creates a message at the enabled limit.
// 6. The sequence-item ERROR method does nothing when report-enabled returns
//    zero.
// 7. The sequence-item ERROR method creates a message at the enabled limit.
// 8. The sequence-item FATAL method does nothing when report-enabled returns
//    zero.
// 9. The sequence-item FATAL method creates a message at the enabled limit.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.1.3.2 (UVM-SEQ-REPORT-SEVERITY-ENABLED-QUERY) gives rule 1
//    above. Setup: A bound sequencer has maximum NONE and all four severities
//    are queried at HIGH. Expected: All four queries return zero.
// 2. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-ABOVE-LIMIT-INFO) gives rule 2
//    above. Setup: Default checked flag and HIGH verbosity are used against a
//    NONE limit. Expected: The virtual processing probe receives no INFO
//    message.
// 3. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-AT-LIMIT-INFO) gives rule 3 above.
//    Setup: Only fixture counters reset before the at-limit control, leaving
//    reporter settings intact. Expected: The virtual probe receives one INFO
//    message.
// 4. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-ABOVE-LIMIT-WARNING) gives rule 4
//    above. Setup: Default checked flag and HIGH verbosity are used against a
//    NONE limit. Expected: The virtual processing probe receives no WARNING
//    message.
// 5. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-AT-LIMIT-WARNING) gives rule 5
//    above. Setup: Only fixture counters reset before the at-limit control,
//    leaving reporter settings intact. Expected: The virtual probe receives
//    one WARNING message.
// 6. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-ABOVE-LIMIT-ERROR) gives rule 6
//    above. Setup: Default checked flag and HIGH verbosity are used against a
//    NONE limit. Expected: The virtual processing probe receives no ERROR
//    message.
// 7. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-AT-LIMIT-ERROR) gives rule 7 above.
//    Setup: Only fixture counters reset before the at-limit control, leaving
//    reporter settings intact. Expected: The virtual probe receives one ERROR
//    message.
// 8. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-ABOVE-LIMIT-FATAL) gives rule 8
//    above. Setup: Default checked flag and HIGH verbosity are used against a
//    NONE limit. Expected: The virtual processing probe receives no FATAL
//    message.
// 9. 1800.2-2020 14.1.3.3 (UVM-SEQ-REPORT-AT-LIMIT-FATAL) gives rule 9 above.
//    Setup: Only fixture counters reset before the at-limit control, leaving
//    reporter settings intact. Expected: The virtual probe receives one FATAL
//    message.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The sequence-item interface checks report_enabled before creating a
// message.
// A virtual processing probe captures admitted severities and never emits
// them.
// Report-object severity admission has its own separate fixture and rules.
// Retain the sequence-interface admission rule from 14.1.3.3. Reset only
// fixture counters before the at-limit control, isolating its observation.

module test_sequence_item_reporting_filters_each_severity_before_virtual_processing;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class item_probe extends uvm_sequence_item;
    `uvm_object_utils(item_probe)
    int infos = 0, warnings = 0, errors = 0, fatals = 0;
    function new(string name="item"); super.new(name); endfunction
    virtual function void uvm_process_report_message(uvm_report_message msg);
      case (msg.get_severity())
        UVM_INFO: infos++;
        UVM_WARNING: warnings++;
        UVM_ERROR: errors++;
        UVM_FATAL: fatals++;
      endcase
    endfunction
  endclass
  initial begin
    automatic uvm_sequencer#(uvm_sequence_item) sequencer = new("sequencer", null);
    automatic item_probe item = new();
    sequencer.set_report_verbosity_level(UVM_NONE); item.set_sequencer(sequencer);
    $display("UT: enabled high info %0d warning %0d error %0d fatal %0d",
             item.uvm_report_enabled(UVM_HIGH, UVM_INFO, "high"),
             item.uvm_report_enabled(UVM_HIGH, UVM_WARNING, "high"),
             item.uvm_report_enabled(UVM_HIGH, UVM_ERROR, "high"),
             item.uvm_report_enabled(UVM_HIGH, UVM_FATAL, "high"));
    item.uvm_report_info("high", "payload", UVM_HIGH);
    item.uvm_report_warning("high", "payload", UVM_HIGH);
    item.uvm_report_error("high", "payload", UVM_HIGH);
    item.uvm_report_fatal("high", "payload", UVM_HIGH);
    $display("UT: high info %0d warning %0d error %0d fatal %0d", item.infos,
             item.warnings, item.errors, item.fatals);
    item.infos = 0; item.warnings = 0; item.errors = 0; item.fatals = 0;
    item.uvm_report_info("low", "payload", UVM_NONE);
    item.uvm_report_warning("low", "payload", UVM_NONE);
    item.uvm_report_error("low", "payload", UVM_NONE);
    item.uvm_report_fatal("low", "payload", UVM_NONE);
    $display("UT: at_limit info %0d warning %0d error %0d fatal %0d", item.infos,
             item.warnings, item.errors, item.fatals);
    $finish;
  end
endmodule
