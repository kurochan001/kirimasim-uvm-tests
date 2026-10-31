/*
:name: test_sequence_library_default_selector_increments_and_wraps_at_inclusive_max
:description: default user selection visits zero through the inclusive maximum then wraps (IEEE 1800.2-2020 Section 14.4.4.9)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_default_selector_increments_and_wraps_at_inclusive_max.expected
*/
// Call the default selection hook directly with a stable maximum. Store
// results before printing so side effects have an explicit execution order.

module test_sequence_library_default_selector_increments_and_wraps_at_inclusive_max;
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
    int selected[4];
    foreach (selected[i]) selected[i] = value.select_sequence(2);
    $display("UT: selected %0d %0d %0d %0d", selected[0], selected[1], selected[2], selected[3]);
    $finish;
  end
endmodule
