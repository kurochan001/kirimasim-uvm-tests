/*
:name: test_vreg_callback_field_pre_read_method_order_literal_86
:description: Virtual callback field_pre_read_method_order_literal checks actual public dispatch and preserved modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.5.3 18.9.1.4.1 18.9.1.4.2 18.9.1.4.3 18.9.1.4.4 18.9.2.2.1 18.9.2.2.2 18.9.2.2.3 18.9.2.2.4 18.10.5.1 18.10.5.2 18.10.5.4 18.10.6.2.1 18.10.6.2.2 18.10.6.2.3 18.10.6.2.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.9.1.3.1 18.9.1.3.2 18.10.4.1 18.10.4.2 18.6.9.1 18.6.9.2 18.6.9.3 18.6.9.4 18.6.6.2 18.6.7.2 19.4.2.2.1 19.4.2.3 19.5.2.6 19.5.2.7 D.4.5.9 D.4.5.11 10.7.2.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers86/callback_fixture86.svh
:incdirs: helpers86
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test86
:expected_exit: 0
:expected_stdout: @test_vreg_callback_field_pre_read_method_order_literal_86.expected
*/
// What it checks:
// 1. Virtual-register post-read hooks follow memory post-read, run registered
//    callbacks before their method, and precede field post-read hooks.
// 2. Under the literal field-method grouping, the field pre_read method
//    follows containing-register hooks and precedes its registered field
//    callback and memory pre-read.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.9.1.4.4 (UVM-VREG-CALLBACK-REG-POST-READ-ORDER-86) gives
//    rule 1 above. Setup: Original 16-bit memory-backed virtual registers have
//    one 4-bit field at LSB4 and selected indices0/2 of a static three-element
//    array. Two healthy map-specific original frontdoors and one original user
//    backdoor contain different independently seeded16-bit words. Each index
//    first reads all three routes with edits disabled. Actual
//    virtual/registered callbacks then edit one selected data/path/map/status
//    or record first/last events for the selected read/write kind. Memory
//    callbacks of the other kind are outside those ordering predicates.
//    Parent-register and standalone-field calls are distinct inputs. No real
//    HDL, bus driver or protocol implementation is involved. Expected:
//    Virtual-register post-read hooks follow memory post-read, run registered
//    callbacks before their method, and precede field post-read hooks.
// 2. 1800.2-2020 18.10.5.3 (UVM-VREG-CALLBACK-FIELD-PRE-READ-ORDER-LITERAL-86)
//    gives rule 2 above. Setup: Original 16-bit memory-backed virtual
//    registers have one 4-bit field at LSB4 and selected indices0/2 of a
//    static three-element array. Two healthy map-specific original frontdoors
//    and one original user backdoor contain different independently
//    seeded16-bit words. Each index first reads all three routes with edits
//    disabled. Actual virtual/registered callbacks then edit one selected
//    data/path/map/status or record first/last events for the selected
//    read/write kind. Memory callbacks of the other kind are outside those
//    ordering predicates. Parent-register and standalone-field calls are
//    distinct inputs. No real HDL, bus driver or protocol implementation is
//    involved. Expected: Under the literal field-method grouping, the field
//    pre_read method follows containing-register hooks and precedes its
//    registered field callback and memory pre-read.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original banks provide distinct healthy routes without a physical bus or HDL.
// Literal pre-read order probes keep the incompatible clause readings separate.
module test_vreg_callback_field_pre_read_method_order_literal_86;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=13;
  localparam string CASE_NAME="field_pre_read_method_order_literal";
  `include "callback_fixture86.svh"
  initial run_test("test86");
  initial begin #5000; $fatal(1,"virtual callback86 watchdog"); end
endmodule
