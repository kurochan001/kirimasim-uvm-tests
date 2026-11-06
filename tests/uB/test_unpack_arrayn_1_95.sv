/*
:name: test_unpack_arrayn_1_95
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
:expected_stdout: @test_unpack_arrayn_1_95.expected
*/
module test_unpack_arrayn_1_95;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  localparam int VARIANT95=1,BITS95=97,STORE95=109,COUNT95=4;
  localparam bit PACK95=0,EXPLICIT95=1;
  localparam string CASE95="unpack_arrayn";
  `define DECLARE95 bit [STORE95-1:0] values[];
  `define INITIALIZE95 values=new[COUNT95];
  `define COUNT_OF95(VAR) VAR.size()
  `define PACK_APPLY95(VAR) `uvm_pack_arrayN(VAR,BITS95)
  `define UNPACK_APPLY95(VAR) `uvm_unpack_arrayN(VAR,BITS95)
  `include "collection_pair_unpack_fixture95.svh"
endmodule
