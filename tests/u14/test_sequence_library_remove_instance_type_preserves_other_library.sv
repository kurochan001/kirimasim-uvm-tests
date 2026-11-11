/*
:name: test_sequence_library_remove_instance_type_preserves_other_library
:description: instance registration removal leaves another library instance unchanged (IEEE 1800.2-2020 Section 14.4.5.5)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.5 14.4.5.3 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_remove_instance_type_preserves_other_library.expected
*/
// What it checks:
// Removing an instance-registered wrapper leaves independently registered
// peers unchanged.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.5 (UVM-LIBRARY-INSTANCE-REMOVAL-ISOLATION) gives the rule
// above. Setup: Register alpha on two libraries and remove it on one.
// Expected: The receiving library becomes empty and its peer retains one
// alpha.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register the same wrapper independently on two libraries and remove it
// from one. Observe membership through public enumeration, not internal queues.

module test_sequence_library_remove_instance_type_preserves_other_library;
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
    uvm_object_wrapper first_entries[$];
    uvm_object_wrapper second_entries[$];
    first.add_sequence(alpha_sequence::get_type());
    second.add_sequence(alpha_sequence::get_type());
    first.remove_sequence(alpha_sequence::get_type());
    first.get_sequences(first_entries);
    second.get_sequences(second_entries);
    $display("UT: removed_count %0d other_count %0d other_alpha %0d", first_entries.size(),
             second_entries.size(), occurrences(second_entries, alpha_sequence::get_type()));
    $finish;
  end
endmodule
