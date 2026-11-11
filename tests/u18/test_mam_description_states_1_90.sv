/*
:name: test_mam_description_states_1_90
:description: mam description states 1 checks independently derived manager or printed backdoor contracts
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.12.6.1 18.12.5.1 18.12.5.3 18.12.5.4 18.12.6.2 18.12.7.2.1 18.12.7.2.2 18.12.7.2.5 1800-2023 6.21 8.20 20.6.1
:uvm: 2020.3.1
:files: helpers90_description/description_fixture90.svh
:incdirs: helpers90_description
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_mam_description_states_1_90.expected
*/
// What it checks:
// 1. The manager description method exposes the declared string result.
// 2. A description represents the selected current occupied-region states.
//
// Variant: Input 0 uses a memory at offset 0 with a width of one byte; input 1
// one at offset 64 with a width of two bytes.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.12.6.1 (UVM-MAM-DESCRIPTION-STRING-RESULT-90) gives rule 1
//    above. Setup: Two original managers use one/two-byte locations and
//    selected one-region,two-region and remaining-region occupied states.
//    Inspect the declared string result and compare nonempty/different
//    snapshots,while checking exact live endpoints and membership before
//    cleanup. Expected: The declared return type is string at the selected
//    public call site.
// 2. 1800.2-2020 18.12.6.1 (UVM-MAM-DESCRIPTION-OCCUPIED-STATES-90) gives rule
//    2 above. Setup: Two original managers use one/two-byte locations and
//    selected one-region,two-region and remaining-region occupied states.
//    Inspect the declared string result and compare nonempty/different
//    snapshots,while checking exact live endpoints and membership before
//    cleanup. Expected: Descriptions of selected occupied states are nonempty
//    and differ after adding/removing a disjoint region,with live reservations
//    unchanged by observation.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Qualified state-description observation: occupied-state strings are nonempty
// and change between selected allocation states; no spelling, layout or
// address parser is fixed.
module test_mam_description_states_1_90;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  localparam int MODE=1;
  localparam int LAYOUT=1;
  localparam string CASE_NAME="mam_description_states_1";
  `include "description_fixture90.svh"
  initial begin #5000; $fatal(1,"manager/backdoor90 watchdog"); end
endmodule
