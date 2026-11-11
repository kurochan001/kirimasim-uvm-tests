/*
:name: test_sequence_library_remove_static_type_updates_all_existing_instances
:description: removing a statically registered type updates every library instance (IEEE 1800.2-2020 Section 14.4.5.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.5 14.4.5.1 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_remove_static_type_updates_all_existing_instances.expected
*/
// What it checks:
// Removing a statically registered wrapper updates all existing library
// instances.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.5 (UVM-LIBRARY-STATIC-REMOVAL-ALL-INSTANCES) gives the
// rule above. Setup: Construct two libraries after typewide alpha registration
// and remove through one. Expected: Both existing libraries become empty.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct two libraries after typewide registration and remove through
// one instance. The required removal from the other instance is spec-only;
// the pinned library changes only the receiving instance.

module test_sequence_library_remove_static_type_updates_all_existing_instances;
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
    library_type first;
    library_type second;
    uvm_object_wrapper first_entries[$];
    uvm_object_wrapper second_entries[$];
    library_type::add_typewide_sequence(alpha_sequence::get_type());
    first = new("first");
    second = new("second");
    first.remove_sequence(alpha_sequence::get_type());
    first.get_sequences(first_entries);
    second.get_sequences(second_entries);
    $display("UT: first_count %0d second_count %0d", first_entries.size(), second_entries.size());
    $finish;
  end
endmodule
