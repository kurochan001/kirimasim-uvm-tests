/*
:name: test_map_direct_translation_little_fifo_populated_107
:description: direct physical-address translation checks little_fifo_populated full-beat widths, data order and reused result arrays (IEEE 1800.2-2020 Section 18.2.4.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.16 17.2.2.4 18.2.4.5 18.2.4.6 18.2.4.4 18.2.4.1 18.2.4.3 18.1.2.3 18.1.2.6 18.1.2.1 18.1.2.2 18.2.3.2 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_direct_translation_little_fifo_populated_107.expected
:files: helpers107_map_translation/translation107.svh
*/
// What it checks:
// Physical-address translation returns addresses in least-significant-data
// order with the transfer width.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.2.4.16 (UVM-MAP-DATA-ORDER-PHYSICAL-ADDRESSES) gives the rule
// above. Setup: Use a wide big-endian register and a word-addressed register.
// Also call the map translator directly in empty/populated flat normal maps,
// two opposite hierarchical-width shapes and flat FIFO maps; reuse an
// initially nonempty dynamic result array across changing query lengths.
// Expected: The big-endian address list descends by two; word addressing
// advances one unit per four-byte transfer. Full integral accesses return the
// effective transfer width and the exact least-significant-data-first address
// list in the declared address units. Normal maps advance by the transfer
// width in those units; FIFO beats repeat one address. Each call supplies only
// its current list, and repeating the original query restores that list.
// Partial probes constrain the list, not the ambiguous returned partial width.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expectations are frozen from the cited standard before measurement.
// Empty and populated shapes have the same API obligations; added registers
// are unrelated setup controls, not an invented translation prerequisite.
// Full-beat return widths are checked independently of address enumeration.
// Partial return widths, when printed as DIAG107, are not an oracle.
module test_map_direct_translation_little_fifo_populated_107;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "translation107.svh"
  initial begin
    exercise107(4, 4, UVM_LITTLE_FIFO, 1,
                0, 1, 1, 0);
    $finish;
  end
endmodule
