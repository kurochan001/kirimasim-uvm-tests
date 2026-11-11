/*
:name: test_packer_round_trips_successive_strings
:description: successive strings retain their boundaries when unpacked (IEEE 1800.2-2020 Section 16.5.4.5)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.5 16.5.4.13 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_round_trips_successive_strings.expected
*/
// What it checks:
// 1. Pack preserves the selected string values in stream field order.
// 2. Unpack preserves the selected string values in stream field order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.5 (UVM-PACKER-STRING-PACK) gives rule 1 above. Setup:
//    Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// 2. 1800.2-2020 16.5.4.13 (UVM-PACKER-STRING-UNPACK) gives rule 2 above.
//    Setup: Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Packing followed by unpacking preserves both string values and their
// order. Do not prescribe the packed stream representation or terminator.

module test_packer_round_trips_successive_strings;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    string first;
    string second;
    packer.pack_string("oak");
    packer.pack_string("pine");
    first = packer.unpack_string();
    second = packer.unpack_string();
    $display("UT: strings [%s] [%s]", first, second);
    $finish;
  end
endmodule
