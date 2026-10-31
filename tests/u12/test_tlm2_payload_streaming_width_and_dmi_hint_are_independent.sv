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
