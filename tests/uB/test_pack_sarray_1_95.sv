/*
:name: test_pack_sarray_1_95
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
:expected_stdout: @test_pack_sarray_1_95.expected
*/
module test_pack_sarray_1_95;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT95=1,BITS95=97,STORE95=97,COUNT95=4;
  localparam bit PACK95=1,EXPLICIT95=0;
  localparam string CASE95="pack_sarray";
  `define DECLARE95 bit [STORE95-1:0] values [7:4];
  `define INITIALIZE95
  `define COUNT_OF95(VAR) $size(VAR)
  `define METHOD95 do_pack
  `define APPLY95(VAR) `uvm_pack_sarray(VAR)
  `include "collection_pack_fixture95.svh"
endmodule
