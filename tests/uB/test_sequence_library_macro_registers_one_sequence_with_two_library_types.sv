/*
:name: test_sequence_library_macro_registers_one_sequence_with_two_library_types
:description: sequence library macros populate static membership through standard construction (IEEE 1800.2-2020 Section B.3.2.1)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.2.1 B.3.2.2 14.4 14.4.2 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_macro_registers_one_sequence_with_two_library_types.expected
*/
// What it checks:
// 1. Static sequence-library registration makes its member available in
//    instances of the selected library type.
// 2. The required library-utils invocation names each extension type and
//    enables its static member sequence list.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 B.3.2.1 (UVM-SEQUENCE-LIBRARY-STATIC-MEMBERSHIP) gives rule 1
//    above. Setup: Construct multiple libraries, two library types or a
//    subtype; add an instance-only member separately. Expected: Public
//    enumeration includes the static member in each applicable library while
//    local additions stay local.
// 2. 1800.2-2020 B.3.2.2 (UVM-SEQUENCER-AUDIT-LIBRARY-UTILS-STATIC) gives rule
//    2 above. Setup: Existing fixtures invoke uvm_sequence_library_utils with
//    the exact library type, including the derived subtype, and combine it
//    with the printed uvm_add_to_seq_lib macro; constructors only call
//    super.new. Expected: The existing public enumeration observations
//    preserve static membership across two instances/types and the selected
//    local-addition/subtype conditions.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register one sequence with two different library types using two macro
// invocations. Both library types must expose that member.
// Use the standard constructor pattern with super.new and the required
// macros. Do not invoke an additional library-specific initialization API.
// The pinned library does not populate this subtype membership; keep the
// required public enumeration as spec-only.

module test_sequence_library_macro_registers_one_sequence_with_two_library_types;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    function new(string name="packet"); super.new(name); endfunction
  endclass
  class alpha_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(alpha_sequence)
    static int calls = 0;
    function new(string name="alpha_sequence"); super.new(name); endfunction
    task body(); calls++; #1; endtask
  endclass
  class beta_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(beta_sequence)
    static int calls = 0;
    function new(string name="beta_sequence"); super.new(name); endfunction
    task body(); calls++; #1; endtask
  endclass
  function automatic int occurrences(uvm_object_wrapper entries[$], uvm_object_wrapper kind);
    int count = 0;
    foreach (entries[i]) if (entries[i] == kind) count++;
    return count;
  endfunction

  class first_library extends uvm_sequence_library#(packet);
    `uvm_object_utils(first_library)
    `uvm_sequence_library_utils(first_library)
    function new(string name="first_library"); super.new(name); endfunction
  endclass

  class second_library extends uvm_sequence_library#(packet);
    `uvm_object_utils(second_library)
    `uvm_sequence_library_utils(second_library)
    function new(string name="second_library"); super.new(name); endfunction
  endclass

  class member_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(member_sequence)
    `uvm_add_to_seq_lib(member_sequence, first_library)
    `uvm_add_to_seq_lib(member_sequence, second_library)
    function new(string name="member_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic first_library first = new("first");
    automatic second_library second = new("second");
    uvm_object_wrapper first_entries[$];
    uvm_object_wrapper second_entries[$];
    first.get_sequences(first_entries);
    second.get_sequences(second_entries);
    $display("UT: counts %0d %0d membership %0d %0d", first_entries.size(), second_entries.size(),
             occurrences(first_entries, member_sequence::get_type()),
             occurrences(second_entries, member_sequence::get_type()));
    $finish;
  end
endmodule
