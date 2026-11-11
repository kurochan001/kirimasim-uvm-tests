/*
:name: test_library_default_rand_1_92
:description: library default rand 1 checks selected mode effects through original public-API observations
:tags: uF uvm
:type: simulation
:lrm: 1800.2-2020 F.2.4.3 14.4 14.4.4.1 14.4.4.6 14.4.4.7 14.4.4.8 14.4.4.9 14.4.4.10 14.4.5.3 14.4.5.6 B.3.2.2 14.2.3.6 15.2.1.2.1 15.2.1.2.3 13.7 15.5 1800-2023 6.21 8.20 8.21 9.2 9.4 18.5 18.4.2
:uvm: 2020.3.1
:files: helpers92_library/library_fixture92.svh
:incdirs: helpers92_library
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_library_default_rand_1_92.expected
*/
// What it checks:
// UVM_SEQ_LIB_RAND selects child sequences using the constrained random index.
//
// Variant: Input 0 constrains the random selection to the first sequence and
// input 1 to the second; each input also reads back the entry with its own
// number.
//
// How the expected output follows from the standard:
// 1800.2-2020 F.2.4.3 (UVM-PKG-SEQUENCE-LIB-MODE-RAND-92) gives the rule
// above. Setup: Two registration/selection histories use two distinct original
// child sequence types,a real sequencer/driver pair and an idle peer. Standard
// inputs configure the named enum through the printed setter/getter;default
// RAND inputs keep the constructor mode and no mode accessor is replaced. The
// default legal budget10 is retained. Independent subtype constraints and
// original USER choices define the selected observations without fixing
// unspecified registration order. Expected: Ten completed child bodies match
// the wrapper selected by the independently constrained valid index;no
// user-selector hook or item transfer occurs.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original real child-sequence and item-driver observations. Standard API
// inputs retain missing-accessor failures; default RAND inputs never replace
// setters/getters. No fixed enum encoding, arbitrary random trace,
// registration order, stream layout or every library condition is claimed.
module test_library_default_rand_1_92;
  timeunit 1ns;
  timeprecision 1ps;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT=1;
  localparam int LIB_KIND=0;
  localparam uvm_sequence_lib_mode SELECT_MODE=UVM_SEQ_LIB_RAND;
  localparam string CASE_NAME="library_default_rand_1";
  `include "library_fixture92.svh"
  initial begin #5000; $fatal(1,"mode-window92 watchdog"); end
endmodule
