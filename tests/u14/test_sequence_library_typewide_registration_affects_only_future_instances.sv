/*
:name: test_sequence_library_typewide_registration_affects_only_future_instances
:description: typewide registration applies to future instances and silently ignores duplicates (IEEE 1800.2-2020 Section 14.4.5.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.1 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_typewide_registration_affects_only_future_instances.expected
*/
// What it checks:
// Typewide registration applies to future instances and ignores duplicates.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.1 (UVM-LIBRARY-TYPEWIDE-FUTURE-INSTANCES) gives the rule
// above. Setup: Construct one library, register alpha twice and construct a
// second. Expected: The existing instance stays empty and the future instance
// contains alpha once.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Construct a library before typewide registration and another afterwards.
// Check duplicate suppression and that the existing instance is unchanged.

module test_sequence_library_typewide_registration_affects_only_future_instances;
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
    automatic library_type existing = new("existing");
    library_type future;
    uvm_object_wrapper old_entries[$];
    uvm_object_wrapper new_entries[$];
    library_type::add_typewide_sequence(alpha_sequence::get_type());
    library_type::add_typewide_sequence(alpha_sequence::get_type());
    future = new("future");
    existing.get_sequences(old_entries);
    future.get_sequences(new_entries);
    $display("UT: existing_count %0d future_count %0d alpha %0d", old_entries.size(),
             new_entries.size(), occurrences(new_entries, alpha_sequence::get_type()));
    $finish;
  end
endmodule
