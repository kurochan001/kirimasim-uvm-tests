/*
:name: test_tlm2_payload_streaming_width_and_dmi_hint_are_independent
:description: generic payload streaming widths and DMI hints retain independent assigned values (IEEE 1800.2-2020 Section 12.3.4.2.28)
:tags: u12 uvm
:type: simulation
:lrm: 1800.2-2020 12.3.4.2.28 12.3.4.2.29 12.3.4.2.34 12.3.4.2.35 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_tlm2_payload_streaming_width_and_dmi_hint_are_independent.expected
*/
// What it checks:
// 1. The streaming-width getter returns the latest assigned local width.
// 2. The DMI hint query reflects its assigned local enable bit.
// 3. The public setter specifies the selected payload streaming width.
// 4. The public setter specifies the selected payload DMI hint.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 12.3.4.2.28 (UVM-GP-STREAMING-WIDTH-CONTROL) gives rule 1
//    above. Setup: Set widths two/four on separate payloads then change only
//    the first to one. Expected: The first returns one while the second
//    retains four.
// 2. 1800.2-2020 12.3.4.2.35 (UVM-GP-DMI-HINT-CONTROL) gives rule 2 above.
//    Setup: Enable the first payload, disable the second and later clear the
//    first. Expected: Hint values reflect the local settings independently of
//    streaming widths.
// 3. 1800.2-2020 12.3.4.2.29 (UVM-PAYLOAD-SET-STREAMING-WIDTH-EXPLICIT-UPDATE)
//    gives rule 3 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: Widths
//    two/four and the subsequent one/four update are retained independently.
// 4. 1800.2-2020 12.3.4.2.34 (UVM-PAYLOAD-SET-DMI-HINT-EXPLICIT-UPDATE) gives
//    rule 4 above. Setup: An unchanged accessor fixture assigns explicit
//    values and reads them back through public methods. Expected: The first
//    hint is one, the peer hint zero, and disabling the first preserves the
//    peer width.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Inspect the configured fields on two payload instances. This case
// does not execute streaming accesses or grant a DMI mapping.

module test_tlm2_payload_streaming_width_and_dmi_hint_are_independent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_tlm_generic_payload first = new("first");
    automatic uvm_tlm_generic_payload second = new("second");
    first.set_streaming_width(2);
    first.set_dmi_allowed(1);
    second.set_streaming_width(4);
    second.set_dmi_allowed(0);
    $display("UT: first width %0d dmi %0d second width %0d dmi %0d",
        first.get_streaming_width(), first.is_dmi_allowed(),
             second.get_streaming_width(), second.is_dmi_allowed());
    first.set_streaming_width(1);
    first.set_dmi_allowed(0);
    $display("UT: updated width %0d dmi %0d retained_width %0d",
        first.get_streaming_width(), first.is_dmi_allowed(), second.get_streaming_width());
    $finish;
  end
endmodule
