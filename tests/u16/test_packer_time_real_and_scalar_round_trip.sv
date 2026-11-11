/*
:name: test_packer_time_real_and_scalar_round_trip
:description: mixed time real and scalar fields unpack in their packed order (IEEE 1800.2-2020 Section 16.5.4.6)
:tags: u16 uvm
:type: simulation
:lrm: 1800.2-2020 16.5.4.6 16.5.4.7 16.5.4.14 16.5.4.15 16.5.4.9 16.5.4.17 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_packer_time_real_and_scalar_round_trip.expected
*/
// What it checks:
// 1. Pack preserves the selected time values in stream field order.
// 2. Unpack preserves the selected time values in stream field order.
// 3. Pack preserves the selected real values in stream field order.
// 4. Unpack preserves the selected real values in stream field order.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 16.5.4.6 (UVM-PACKER-TIME-PACK) gives rule 1 above. Setup:
//    Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// 2. 1800.2-2020 16.5.4.14 (UVM-PACKER-TIME-UNPACK) gives rule 2 above. Setup:
//    Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// 3. 1800.2-2020 16.5.4.7 (UVM-PACKER-REAL-PACK) gives rule 3 above. Setup:
//    Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// 4. 1800.2-2020 16.5.4.15 (UVM-PACKER-REAL-UNPACK) gives rule 4 above. Setup:
//    Mix typed fields using matching pack/unpack methods, including
//    empty/zero/negative cases as applicable. Expected: Decoded values and
//    following fields match their inputs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Use a full-width time payload and an exactly representable real value.
// Check round-trip values without observing their packed representation.

module test_packer_time_real_and_scalar_round_trip;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  initial begin
    automatic uvm_packer packer = new;
    time time_value;
    real real_value;
    int trailer;
    packer.pack_time(64'hfedcba9876543210);
    packer.pack_real(1.5);
    packer.pack_field_int(7, 4);
    time_value = packer.unpack_time();
    real_value = packer.unpack_real();
    trailer = int'(packer.unpack_field_int(4));
    $display("UT: time %016h real_equal %0d trailer %0d", time_value, real_value == 1.5, trailer);
    $finish;
  end
endmodule
