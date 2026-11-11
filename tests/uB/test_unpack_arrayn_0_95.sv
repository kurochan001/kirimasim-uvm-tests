/*
:name: test_unpack_arrayn_0_95
:description: Collection macros preserve independently chosen values through a compatible paired operation and opaque typed state transfer without prescribing serialization
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.5.4 B.2.4.4 B.2.4 B.2.5 5.3.10.2 5.3.11.2 16.5.2.1 16.5.3.1 16.5.3.2 16.5.3.3 16.5.4.9 1800-2023 6.21 7.4.1 7.4.2 7.10 12.7.3 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers95_pair_unpack/collection_pair_unpack_fixture95.svh
:expected_exit: 0
:expected_stdout: @test_unpack_arrayn_0_95.expected
*/
// What it checks:
// The selected unpacking macro restores the independently chosen integral
// values packed by its corresponding macro using a compatible packer.
//
// Variant: Input 0 uses 2 elements of 9-bit values in 109-bit storage; input 1
// uses 4 elements of 97-bit values in the same storage, with a different value
// pattern.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.5.4 (UVM-COLLECTION-MACRO-UNPACK-ARRAYN-INTEROPERABILITY-95)
// gives the rule above. Setup: Use original do_pack/do_unpack overrides with a
// nonempty, pre-sized array of two or four unsigned elements. N is a positive
// constant 9 or 97 with 109-bit storage and an independently set high bit
// outside the selected width. Static-array cases use distinct nonzero
// ascending/descending index ranges. Packing-focused paired inputs decode on
// the same policy; unpacking-focused paired inputs transfer untouched
// get_packed_bits state into set_packed_bits of a fresh identically typed
// compatible policy. Separate static-array inputs also retain qualified
// one-way scalar-API probes. All inputs carry an independent seven-bit trailer
// and separate object/policy peers. Expected: Each restored element equals its
// independently chosen value and the pre-sized shape is retained. The selected
// trailer remains and is consumed independently; source values, unrelated
// fields and peer state remain intact. Opaque-state consumers do not consume
// the original source packer. Static one-way probes additionally compare the
// corresponding scalar API.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_unpack_arrayn_0_95;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT95=0,BITS95=9,STORE95=109,COUNT95=2;
  localparam bit PACK95=0,EXPLICIT95=1;
  localparam string CASE95="unpack_arrayn";
  `define DECLARE95 bit [STORE95-1:0] values[];
  `define INITIALIZE95 values=new[COUNT95];
  `define COUNT_OF95(VAR) VAR.size()
  `define PACK_APPLY95(VAR) `uvm_pack_arrayN(VAR,BITS95)
  `define UNPACK_APPLY95(VAR) `uvm_unpack_arrayN(VAR,BITS95)
  `include "collection_pair_unpack_fixture95.svh"
endmodule
