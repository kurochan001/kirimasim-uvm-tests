/*
:name: test_sequence_library_standard_selection_mode_defaults_to_rand
:description: standard selection mode getter defaults to RAND (IEEE 1800.2-2020 Section 14.4.4.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.1 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_standard_selection_mode_defaults_to_rand.expected
*/
// The pinned library lacks the standard accessor methods. Keep the
// required API spelling and its expectation as a spec-only build case.

module test_sequence_library_standard_selection_mode_defaults_to_rand;
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
    $display("UT: default_rand %0d", value.get_selection_mode() == UVM_SEQ_LIB_RAND);
    $finish;
  end
endmodule
