/*
:name: test_pack_queue_1_95
:description: Collection macros preserve independently chosen values through a compatible paired operation and opaque typed state transfer without prescribing serialization
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.4.12 B.2.5.12 B.2.4 B.2.5 5.3.10.2 5.3.11.2 16.5.2.1 16.5.3.1 16.5.3.2 16.5.3.3 16.5.4.9 1800-2023 6.21 7.4.1 7.4.2 7.10 12.7.3 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers95_pair_pack/collection_pair_pack_fixture95.svh
:expected_exit: 0
:expected_stdout: @test_pack_queue_1_95.expected
*/
// What it checks:
// The selected packing macro preserves its integral collection as data
// recoverable by the corresponding macro with a compatible packer.
//
// Variant: Input 0 uses 2 elements of 13 bits; input 1 uses 4 elements of 97
// bits, with a different value pattern.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.4.12 (UVM-COLLECTION-MACRO-PACK-QUEUE-INTEROPERABILITY-95)
// gives the rule above. Setup: Use original do_pack/do_unpack overrides with a
// nonempty, pre-sized queue of two or four unsigned elements. Element width is
// inferred from 13-bit or 97-bit storage. Static-array cases use distinct
// nonzero ascending/descending index ranges. Packing-focused paired inputs
// decode on the same policy; unpacking-focused paired inputs transfer
// untouched get_packed_bits state into set_packed_bits of a fresh identically
// typed compatible policy. Separate static-array inputs also retain qualified
// one-way scalar-API probes. All inputs carry an independent seven-bit trailer
// and separate object/policy peers. Expected: Each restored element equals its
// independently chosen value and the pre-sized shape is retained. The selected
// trailer remains and is consumed independently; source values, unrelated
// fields and peer state remain intact. Opaque-state consumers do not consume
// the original source packer. Static one-way probes additionally compare the
// corresponding scalar API.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_pack_queue_1_95;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT95=1,BITS95=97,STORE95=97,COUNT95=4;
  localparam bit PACK95=1,EXPLICIT95=0;
  localparam string CASE95="pack_queue";
  `define DECLARE95 bit [STORE95-1:0] values[$];
  `define INITIALIZE95 for(int item=0;item<COUNT95;item++) values.push_back('0);
  `define COUNT_OF95(VAR) VAR.size()
  `define PACK_APPLY95(VAR) `uvm_pack_queue(VAR)
  `define UNPACK_APPLY95(VAR) `uvm_unpack_queue(VAR)
  `include "collection_pair_pack_fixture95.svh"
endmodule
