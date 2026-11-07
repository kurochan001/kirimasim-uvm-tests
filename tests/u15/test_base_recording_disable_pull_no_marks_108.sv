/*
:name: test_base_recording_disable_pull_no_marks_108
:description: base recording disable preserves actual pull_no_marks traffic and selected driver-owned transaction marks (IEEE 1800.2-2020 Section 15.3.2.22)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.22 15.3.1 5.4.2.13 5.4.2.16 10.2.2.3 10.7.2.3.1 14.2.6.2 14.2.6.3 14.2.3.1 15.2.1 15.2.1.2.1 15.2.1.2.3 15.2.2.1 15.5.1 1800-2023 6.21 8.20 8.21 9.4.1 9.4.3
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_base_recording_disable_pull_no_marks_108.expected
:files: helpers108_recording/recording108.svh
*/
// Base disable precedes both worker starts and the first pull-driver request.
// The selected driver alone optionally calls component begin_tr/end_tr.
// Peer automatic event counts are DIAG108 only, not a default-policy oracle.
// No alias substitutes for the separately known printed base query API.
module test_base_recording_disable_pull_no_marks_108;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam bit PUSH108=0, MANUAL108=0;
  `include "recording108.svh"
  initial run_test("t");
  initial begin #80; $fatal(1,"recording108 traffic watchdog expired"); end
endmodule
