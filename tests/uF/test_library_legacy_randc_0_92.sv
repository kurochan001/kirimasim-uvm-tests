/*
:name: test_library_legacy_randc_0_92
:description: library standard randc 0 checks selected mode effects through original public-API observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.3 14.4 14.4.4.1 14.4.4.6 14.4.4.7 14.4.4.8 14.4.4.9 14.4.4.10 14.4.5.3 14.4.5.6 B.3.2.2 14.2.3.6 15.2.1.2.1 15.2.1.2.3 13.7 15.5 1800-2023 6.21 8.20 8.21 9.2 9.4 18.5 18.4.2
:uvm: 2020.3.1
:files: helpers92_library/library_fixture92.svh
:incdirs: helpers92_library
:defines: LEGACY_MODE92
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_library_legacy_randc_0_92.expected
*/
// Additional-premise control using the diagnosed nonstandard public field.
// Original real child-sequence and item-driver observations. Standard API
// inputs retain missing-accessor failures; default RAND inputs never replace
// setters/getters. No fixed enum encoding, arbitrary random trace,
// registration order, stream layout or every library condition is claimed.
module test_library_legacy_randc_0_92;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=0;
  localparam int LIB_KIND=1;
  localparam uvm_sequence_lib_mode SELECT_MODE=UVM_SEQ_LIB_RANDC;
  localparam string CASE_NAME="library_legacy_randc_0";
  `include "library_fixture92.svh"
  initial begin #5000; $fatal(1,"mode-window92 watchdog"); end
endmodule
