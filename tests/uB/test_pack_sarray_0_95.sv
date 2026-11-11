/*
:name: test_pack_sarray_0_95
:description: Selected uvm_pack_sarray element-stream interoperability preserves ordered integral values, pre-sized shape and a seven-bit trailer
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.2.4.10 B.2.4 5.3.10.2 5.3.11.2 16.5.2.1 16.5.3.3 16.5.4.8 16.5.4.9 16.5.4.16 16.5.4.17 1800-2023 6.21 7.4.1 7.4.2 7.10 12.7.3 8.20 8.21 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: helpers95_pack/collection_pack_fixture95.svh
:expected_exit: 0
:expected_stdout: @test_pack_sarray_0_95.expected
*/
// What it checks:
// The selected packing macro preserves its integral collection as data
// recoverable by the corresponding macro with a compatible packer.
//
// Variant: Input 0 uses a static array declared [3:4] with 13-bit elements;
// input 1 one declared [7:4] with 97-bit elements, with a different value
// pattern.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.2.4.10 (UVM-COLLECTION-MACRO-PACK-SARRAY-INTEROPERABILITY-95)
// gives the rule above. Setup: Use original do_pack/do_unpack overrides with a
// nonempty, pre-sized sarray of two or four unsigned elements. Element width
// is inferred from 13-bit or 97-bit storage. Static-array cases use distinct
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
module test_pack_sarray_0_95;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT95=0,BITS95=13,STORE95=13,COUNT95=2;
  localparam bit PACK95=1,EXPLICIT95=0;
  localparam string CASE95="pack_sarray";
  `define DECLARE95 bit [STORE95-1:0] values [3:4];
  `define INITIALIZE95
  `define COUNT_OF95(VAR) $size(VAR)
  `define METHOD95 do_pack
  `define APPLY95(VAR) `uvm_pack_sarray(VAR)
  `include "collection_pack_fixture95.svh"
endmodule
