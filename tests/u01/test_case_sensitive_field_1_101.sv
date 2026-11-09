/*
:name: test_case_sensitive_field_1_101
:description: Selected UVM names differing only by case retain exact lookup and state under changed construction and lifecycle conditions
:tags: u01 uvm
:type: simulation
:lrm: 1800.2-2020 1.4 18.4.3.12 18.4.3.11 1.4.4 18.1.2.1 18.1.2.2 18.1.2.3 18.1.2.6 18.2.3.3 18.2.3.4 18.2.3.5 18.4.2.1 18.4.2.2 18.5.3.2 18.6.3.1 18.6.3.2 1800-2023 6.21 8.20 8.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers101_model/model101.svh
:expected_exit: 0
:expected_stdout: @test_case_sensitive_field_1_101.expected
*/
// What it checks:
// 1. Register field lookup distinguishes case-only names within each owning
//    register before and after model lock.
// 2. Case-distinct field names do not relax the explicit
//    least-to-most-significant field enumeration order.
//
// Variant: Inputs 0 and 1 create the objects whose names differ only by case
// in opposite orders.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 1.4 (UVM-CASE-SENSITIVE-FIELD-NAMES-101) gives rule 1 above.
//    Setup: Configure lane101/Lane101 at nonoverlapping positions in two
//    registers, reverse field construction order and query before and after
//    lock. Expected: Each exact field name returns the matching owner-specific
//    handle; an unmatched uppercase name returns null without leaking a peer
//    field.
// 2. 1800.2-2020 18.4.3.11 (UVM-REGISTER-CASE-FIELD-POSITION-ORDER-101) gives
//    rule 2 above. Setup: Configure two fields in opposite insertion orders at
//    LSB0/8 in two sixteen-bit registers and repeat before/after lock.
//    Expected: The returned queue has exactly two entries ordered by their
//    declared bit positions, with the exact corresponding handles.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_case_sensitive_field_1_101;
  import uvm_pkg::*;
  localparam int VARIANT101=1;
  localparam int FAMILY101=2;
  `include "model101.svh"
endmodule
