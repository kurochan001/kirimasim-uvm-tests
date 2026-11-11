/*
:name: test_memory_maximum_width_tracks_all_constructed_memories_without_shrinking
:description: Memory global maximum counts bits per location and never assumes an initially empty library
:tags: u18 uvm
:type: simulation
:lrm: 1800.2-2020 18.6.4.10 18.6.3.1 1800-2023 6.21 8.20
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_memory_maximum_width_tracks_all_constructed_memories_without_shrinking.expected
*/
// What it checks:
// The static memory maximum is the maximum location width in bits.
//
// How the expected output follows from the standard:
// 1800.2-2020 18.6.4.10 (UVM-MEMORY-AUDIT-MAXIMUM-WIDTH) gives the rule above.
// Setup: Capture the existing maximum before constructing widths 13, 57 and 9
// with location counts 100, 1 and 200. Expected: After every construction the
// maximum equals max(saved maximum, widths constructed so far); a later larger
// location count does not shrink or replace the width maximum.
// These expectations come from the cited clauses, not from the output of a
// simulator.
module test_memory_maximum_width_tracks_all_constructed_memories_without_shrinking;
  import uvm_pkg::*;
  initial begin
    automatic int unsigned saved_max=uvm_mem::get_max_size();
    uvm_mem narrow_mem,wide,later;
    int unsigned expected_max;
    narrow_mem=new("small56",100,13); expected_max=saved_max>13 ? saved_max : 13;
    $display("UT: maximum first %0d",uvm_mem::get_max_size()==expected_max);
    wide=new("wide56",1,57); expected_max=expected_max>57 ? expected_max : 57;
    $display("UT: maximum wide %0d",uvm_mem::get_max_size()==expected_max);
    later=new("later56",200,9);
    $display("UT: maximum later %0d width_not_locations %0d",
      uvm_mem::get_max_size()==expected_max,later.get_size()==200 && later.get_n_bits()==9);
    $finish;
  end
endmodule
