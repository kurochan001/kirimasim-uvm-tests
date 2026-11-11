/*
:name: test_memory_hdl_concatenations_keep_slice_coordinates_and_duplicate_implementations
:description: Memory concatenations preserve original slice coordinates and first starts a duplicate implementation
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.7.4 18.6.7.5 18.6.7.7 18.6.3.2 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_hdl_concatenations_keep_slice_coordinates_and_duplicate_implementations.expected
*/
// What it checks:
// 1. Adding a memory HDL concatenation retains its path/offset/size slices.
// 2. The first flag starts a duplicate memory HDL implementation.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 18.6.7.4 (UVM-MEMORY-AUDIT-CONCAT-SLICES) gives rule 1 above.
//    Setup: Add a two-slice RTL concatenation, then a whole-variable slice
//    with first explicitly true. Expected: The two-slice local path retains
//    high56 at 8/8 and low56 at 0/8.
// 2. 1800.2-2020 18.6.7.5 (UVM-MEMORY-AUDIT-DUPLICATE-SLICE) gives rule 2
//    above. Setup: Add a two-slice RTL concatenation, then a whole-variable
//    slice with first explicitly true. Expected: A whole-variable copy56 with
//    -1/-1 coordinates is a second concatenation rather than a third slice in
//    the first.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// HDL path metadata only; physical array access is measured separately.
module test_memory_hdl_concatenations_keep_slice_coordinates_and_duplicate_implementations;
  import uvm_pkg::*;

  class block_type extends uvm_reg_block;
    function new(string name="owner56"); super.new(name,UVM_NO_COVERAGE); endfunction
  endclass

  initial begin
    automatic block_type owner=new();
    automatic uvm_mem memory=new("memory56",4,16);
    uvm_hdl_path_slice slices[]; uvm_hdl_path_concat paths[$];
    automatic bit primary=0,duplicate_copy=0;
    owner.configure(); memory.configure(owner);
    slices=new[2];
    slices[0].path="high56"; slices[0].offset=8; slices[0].size=8;
    slices[1].path="low56"; slices[1].offset=0; slices[1].size=8;
    memory.add_hdl_path(slices);
    memory.add_hdl_path_slice("copy56",-1,-1,1);
    memory.get_hdl_path(paths);
    foreach (paths[i]) begin
      if (paths[i].slices.size()==2)
        primary |= paths[i].slices[0].path=="high56" && paths[i].slices[0].offset==8 &&
          paths[i].slices[0].size==8 && paths[i].slices[1].path=="low56" &&
          paths[i].slices[1].offset==0 && paths[i].slices[1].size==8;
      if (paths[i].slices.size()==1)
        duplicate_copy |= paths[i].slices[0].path=="copy56" &&
          paths[i].slices[0].offset==-1 && paths[i].slices[0].size==-1;
    end
    $display("UT: concatenations paths %0d coordinates %0d duplicate %0d",
      paths.size(),primary,duplicate_copy);
    $finish;
  end
endmodule
