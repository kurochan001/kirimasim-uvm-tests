/*
:name: test_vreg_callback_field_cb_pre_read_path_86
:description: Virtual callback field_cb_pre_read_path checks actual public dispatch and preserved modeled storage
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.10.6.2.3 18.9.1.4.1 18.9.1.4.2 18.9.1.4.3 18.9.1.4.4 18.9.2.2.1 18.9.2.2.2 18.9.2.2.3 18.9.2.2.4 18.10.5.1 18.10.5.2 18.10.5.3 18.10.5.4 18.10.6.2.1 18.10.6.2.2 18.10.6.2.4 18.9.1.1.2 18.10.2.1 18.10.2.2 18.9.1.3.1 18.9.1.3.2 18.10.4.1 18.10.4.2 18.6.9.1 18.6.9.2 18.6.9.3 18.6.9.4 18.6.6.2 18.6.7.2 19.4.2.2.1 19.4.2.3 19.5.2.6 19.5.2.7 D.4.5.9 D.4.5.11 10.7.2.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:files: helpers86/callback_fixture86.svh
:incdirs: helpers86
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:args: +UVM_TESTNAME=test86
:expected_exit: 0
:expected_stdout: @test_vreg_callback_field_cb_pre_read_path_86.expected
*/
// What it checks:
// A registered virtual-field pre_read callback can change the path used for
// the actual containing-register read.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.10.6.2.3 (UVM-VREG-CALLBACK-FIELD-CB-PRE-READ-PATH-86) gives
// the rule above. Setup: Original 16-bit memory-backed virtual registers have
// one 4-bit field at LSB4 and selected indices0/2 of a static three-element
// array. Two healthy map-specific original frontdoors and one original user
// backdoor contain different independently seeded16-bit words. Each index
// first reads all three routes with edits disabled. Actual virtual/registered
// callbacks then edit one selected data/path/map/status or record first/last
// events for the selected read/write kind. Memory callbacks of the other kind
// are outside those ordering predicates. Parent-register and standalone-field
// calls are distinct inputs. No real HDL, bus driver or protocol
// implementation is involved. Expected: A registered virtual-field pre_read
// callback can change the path used for the actual containing-register read.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original banks provide distinct healthy routes without a physical bus or HDL.
// Literal pre-read order probes keep the incompatible clause readings separate.
module test_vreg_callback_field_cb_pre_read_path_86;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int MODE=10;
  localparam string CASE_NAME="field_cb_pre_read_path";
  `include "callback_fixture86.svh"
  initial run_test("test86");
  initial begin #5000; $fatal(1,"virtual callback86 watchdog"); end
endmodule
