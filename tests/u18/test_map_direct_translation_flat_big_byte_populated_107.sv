/*
:name: test_map_direct_translation_flat_big_byte_populated_107
:description: direct physical-address translation checks flat_big_byte_populated full-beat widths, data order and reused result arrays (IEEE 1800.2-2020 Section 18.2.4.16)
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.2.4.16 17.2.2.4 18.2.4.5 18.2.4.6 18.2.4.4 18.2.4.1 18.2.4.3 18.1.2.3 18.1.2.6 18.1.2.1 18.1.2.2 18.2.3.2 18.2.3.3 18.4.2.1 18.4.2.2 18.5.3.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_map_direct_translation_flat_big_byte_populated_107.expected
:files: helpers107_map_translation/translation107.svh
*/
// What it checks:
// 1. Physical-address translation returns addresses in least-significant-data
//    order with the transfer width.
// 2. The direct physical-address translator interprets mem_offset as a
//    memory-entry index rather than a byte or bus-beat offset.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.2.4.16 (UVM-MAP-DATA-ORDER-PHYSICAL-ADDRESSES) gives rule
//    1 above. Setup: Use a wide big-endian register and a word-addressed
//    register. Also call the map translator directly in empty/populated flat
//    normal maps, two opposite hierarchical-width shapes and flat FIFO maps;
//    reuse an initially nonempty dynamic result array across changing query
//    lengths. Expected: The big-endian address list descends by two; word
//    addressing advances one unit per four-byte transfer. Full integral
//    accesses return the effective transfer width and the exact
//    least-significant-data-first address list in the declared address units.
//    Normal maps advance by the transfer width in those units; FIFO beats
//    repeat one address. Each call supplies only its current list, and
//    repeating the original query restores that list. Partial probes constrain
//    the list, not the ambiguous returned partial width.
// 2. 1800.2-2020 18.2.4.16 (UVM-MAP-TRANSLATOR-MEMORY-INDEX-107) gives rule 2
//    above. Setup: Query non-FIFO maps at entry1 for an entry of two local-bus
//    widths and entry3 for an entry of one local-bus width. Use flat byte/word
//    units with either normal endian order, and two byte-addressed
//    little-endian hierarchy-width shapes, each empty and independently
//    populated. Each query describes its own entry width through n_bytes; no
//    registered memory changes size. Expected: The entry origin is the
//    external map base plus the local memory base and index times the entry
//    width, expressed in address units. The resulting list covers the entry in
//    least-significant-data order; index1 of a double-width entry and index3
//    of a single-width entry have independently computed origins.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Expectations are frozen from the cited standard before measurement.
// Empty and populated shapes have the same API obligations; added registers
// are unrelated setup controls, not an invented translation prerequisite.
// Full-beat return widths are checked independently of address enumeration.
// Partial return widths, when printed as DIAG107, are not an oracle.
module test_map_direct_translation_flat_big_byte_populated_107;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "translation107.svh"
  initial begin
    exercise107(4, 4, UVM_BIG_ENDIAN, 1,
                0, 1, 0, 0);
    $finish;
  end
endmodule
