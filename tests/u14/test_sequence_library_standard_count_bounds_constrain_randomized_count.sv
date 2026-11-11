/*
:name: test_sequence_library_standard_count_bounds_constrain_randomized_count
:description: standard count-bound setters constrain count locally to a singleton range (IEEE 1800.2-2020 Section 14.4.4.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.2 14.4.4.3 14.4.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_standard_count_bounds_constrain_randomized_count.expected
*/
// What it checks:
// Standard count setters constrain the receiver count without changing its
// peer.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.4.2 (UVM-LIBRARY-SINGLETON-RANDOM-COUNT-BOUNDS) gives the
// rule above. Setup: Set minimum/maximum to three and randomize with one
// registered type. Expected: Randomization succeeds with count/min/max three,
// and the peer bounds remain ten.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library lacks the standard accessor methods. Keep the
// required API spelling and its expectation as a spec-only build case.
// Use a singleton legal range so no selected random value is assumed.

module test_sequence_library_standard_count_bounds_constrain_randomized_count;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class alpha_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(alpha_sequence)
    static int started = 0;
    static int finished = 0;
    function new(string name="alpha_sequence"); super.new(name); endfunction
    task body();
      started++;
      #3;
      finished++;
    endtask
  endclass
  class beta_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(beta_sequence)
    function new(string name="beta_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  class prefix_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(prefix_sequence)
    function new(string name="prefix_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass
  typedef uvm_sequence_library#(packet) library_type;
  function automatic int occurrences(uvm_object_wrapper entries[$], uvm_object_wrapper kind);
    int count = 0;
    foreach (entries[i]) if (entries[i] == kind) count++;
    return count;
  endfunction

  initial begin
    automatic library_type first = new("first");
    automatic library_type second = new("second");
    bit randomized;
    first.add_sequence(alpha_sequence::get_type());
    first.set_min_random_count(3);
    first.set_max_random_count(3);
    randomized = first.randomize();
    $display("UT: randomized %0d count %0d min %0d max %0d", randomized, first.sequence_count,
             first.get_min_random_count(), first.get_max_random_count());
    $display("UT: untouched_min %0d untouched_max %0d", second.get_min_random_count(),
             second.get_max_random_count());
    $finish;
  end
endmodule
