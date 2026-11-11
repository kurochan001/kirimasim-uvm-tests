/*
:name: test_sequence_library_standard_count_bounds_default_to_ten
:description: standard count-bound getters and the initial sequence count default to ten (IEEE 1800.2-2020 Section 14.4.4.2)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.2 14.4.4.3 14.4.4.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_standard_count_bounds_default_to_ten.expected
*/
// What it checks:
// 1. The standard minimum count defaults to ten.
// 2. The standard maximum count defaults to ten.
// 3. The initial sequence_count is ten.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.4.2 (UVM-LIBRARY-MINIMUM-COUNT-DEFAULT) gives rule 1
//    above. Setup: Query a fresh library through the standard minimum getter.
//    Expected: The minimum getter returns ten.
// 2. 1800.2-2020 14.4.4.3 (UVM-LIBRARY-MAXIMUM-COUNT-DEFAULT) gives rule 2
//    above. Setup: Query a fresh library through the standard maximum getter.
//    Expected: The maximum getter returns ten.
// 3. 1800.2-2020 14.4.4.6 (UVM-LIBRARY-INITIAL-SEQUENCE-COUNT) gives rule 3
//    above. Setup: Inspect a fresh library sequence_count. Expected: The
//    public count field is ten.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The pinned library lacks the standard accessor methods. Keep the
// required API spelling and its expectation as a spec-only build case.

module test_sequence_library_standard_count_bounds_default_to_ten;
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
    automatic library_type value = new("value");
    $display("UT: min %0d max %0d count %0d", value.get_min_random_count(),
             value.get_max_random_count(), value.sequence_count);
    $finish;
  end
endmodule
