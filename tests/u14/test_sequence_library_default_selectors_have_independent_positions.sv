/*
:name: test_sequence_library_default_selectors_have_independent_positions
:description: default selection positions are independent across sequence library instances (IEEE 1800.2-2020 Section 14.4.4.9)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.9 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_default_selectors_have_independent_positions.expected
*/
// Advance one selector while a second has not been used. Exercise a
// single-choice range on a third instance without changing any active range.

module test_sequence_library_default_selectors_have_independent_positions;
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
    automatic library_type singleton = new("singleton");
    int first_values[3];
    int second_value;
    int singleton_values[2];
    foreach (first_values[i]) first_values[i] = first.select_sequence(1);
    second_value = second.select_sequence(1);
    foreach (singleton_values[i]) singleton_values[i] = singleton.select_sequence(0);
    $display("UT: first %0d %0d %0d second %0d singleton %0d %0d", first_values[0],
             first_values[1], first_values[2], second_value, singleton_values[0],
                 singleton_values[1]);
    $finish;
  end
endmodule
