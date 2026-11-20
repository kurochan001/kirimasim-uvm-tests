/*
:name: test_report_handler_direct_verbosity_settings_follow_pair_then_id_then_maximum
:description: a report handler returns the verbosity of a severity-id pair before that of an id, and that of an id before its maximum, when configured directly (IEEE 1800.2-2020 Section 6.4.3.3)
:tags: u06 uvm
:type: simulation
:lrm: 1800.2-2020 6.4.3.3 6.4.3.1 6.4.3.2 6.3.8.1 F.2.2.4 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_report_handler_direct_verbosity_settings_follow_pair_then_id_then_maximum.expected
*/
// What it checks:
// 1. A verbosity set for a severity-id pair is returned before one set for the
//    id alone, and one set for an id before the handler's maximum.
// 2. get_verbosity_level takes UVM_INFO as its severity and the empty string
//    as its id when they are omitted.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 6.4.3.3 (UVM-HANDLER-DIRECT-VERBOSITY-PRECEDENCE) gives rule
//    1. Setup: take the handler of a report object with get_report_handler
//    (6.3.8.1), set the maximum to UVM_LOW (6.4.3.2), id ID_A to UVM_HIGH, the
//    pair UVM_WARNING and ID_A to UVM_DEBUG and the pair UVM_INFO and ID_B to
//    UVM_FULL. Expected: UVM_INFO with ID_A gives UVM_HIGH, UVM_WARNING with
//    ID_A gives UVM_DEBUG, and UVM_ERROR with ID_B, which has no setting of its
//    own, gives UVM_LOW.
// 2. 1800.2-2020 6.4.3.1 (UVM-HANDLER-DIRECT-VERBOSITY-DEFAULTS) gives rule 2.
//    Expected: the call with only ID_B gives the UVM_INFO pair's UVM_FULL, and
//    the call without arguments gives the maximum, UVM_LOW.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The handler is configured directly; uvm_report_object's set_report_*
// methods are not called.
module test_report_handler_direct_verbosity_settings_follow_pair_then_id_then_maximum;
  import uvm_pkg::*;

  initial begin
    automatic uvm_report_object subject = new("subject");
    automatic uvm_report_handler handler = subject.get_report_handler();
    handler.set_verbosity_level(UVM_LOW);
    handler.set_id_verbosity("ID_A", UVM_HIGH);
    handler.set_severity_id_verbosity(UVM_WARNING, "ID_A", UVM_DEBUG);
    handler.set_severity_id_verbosity(UVM_INFO, "ID_B", UVM_FULL);
    $display("UT: id %0d pair %0d maximum %0d",
             handler.get_verbosity_level(UVM_INFO, "ID_A") == UVM_HIGH,
             handler.get_verbosity_level(UVM_WARNING, "ID_A") == UVM_DEBUG,
             handler.get_verbosity_level(UVM_ERROR, "ID_B") == UVM_LOW);
    $display("UT: default_severity %0d no_arguments %0d",
             handler.get_verbosity_level(.id("ID_B")) == UVM_FULL,
             handler.get_verbosity_level() == UVM_LOW);
    $finish;
  end
endmodule
