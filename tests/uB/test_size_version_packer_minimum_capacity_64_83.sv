/*
:name: test_size_version_packer_minimum_capacity_64_83
:description: The unmodified packer retains the default minimum through repeated nonuniform scalar fields
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.6.3 16.5.2.1 16.5.2.2 16.5.3.3 16.5.4.9 16.5.4.17 1800-2023 6.21 6.20 6.16 7.4 13.5.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_size_version_packer_minimum_capacity_64_83.expected
*/
// What it checks:
// The default packer implementation can store at least the default minimum
// number of bits.
//
// Variant: The number, 8 or 64, is the width in bits of each packed element;
// the element count is chosen so that both inputs fill the same minimum packer
// capacity.
//
// How the expected output follows from the standard:
// 1800.2-2020 B.6.3 (UVM-SIZE-VERSION-PACKER-MINIMUM-RETENTION) gives the rule
// above. Setup: Unmodified public UVM types/macros and default packer
// implementation. Flag overrides use the actual reserved-count parameter
// plus17 or129,without fixing its implementation-dependent value. Capacity
// inputs explicitly flush and retain32768 bits via independent
// original8/64-bit payload patterns. Version inputs use public
// package/preprocessor access;the illegal parameter assignment has no runtime.
// Expected: Separate8-bit and64-bit histories each retain32768 nonuniform
// payload bits;every decoded value and remaining-bit count matches through
// complete consumption.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Original observations derived from IEEE.
// No implementation-specific lower-bit layout or version text is assumed.
`include "uvm_macros.svh"
module test_size_version_packer_minimum_capacity_64_83;
  import uvm_pkg::*;
  localparam int WIDTH83=64;
  localparam int COUNT83=512;
  typedef bit [WIDTH83-1:0] word83;
  function automatic word83 pattern83(input int index);
    return word83'((64'h9e3779b97f4a7c15*(index+1)) ^
                  (64'ha53c96f087d21be4 >> (index%17)));
  endfunction
  initial begin
    automatic uvm_packer packer=new();
    automatic bit values_ok=1;
    automatic bit sizes_ok=1;
    word83 expected[COUNT83];
    uvm_integral_t got;
    packer.flush();
    for (int i=0;i<COUNT83;i++) begin
      expected[i]=pattern83(i); packer.pack_field_int(expected[i],WIDTH83);
    end
    $display("UT: size83 capacity64 available %0d",packer.get_packed_size()==32768);
    for (int i=0;i<COUNT83;i++) begin
      got=packer.unpack_field_int(WIDTH83);
      values_ok &= got[WIDTH83-1:0]==expected[i];
      sizes_ok &= packer.get_packed_size()==32768-(i+1)*WIDTH83;
    end
    $display("UT: size83 capacity64 values %0d remaining %0d consumed %0d",
      values_ok,sizes_ok,packer.get_packed_size()==0);
    $finish;
  end
endmodule
