/*
:name: test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance
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
:expected_stdout: @test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance.expected
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
// Statically register two members, then add a third only to one instance.
// Observe membership counts without imposing a registration order.
// Use the standard constructor pattern with super.new and the required
// macros. Do not invoke an additional library-specific initialization API.
// The pinned library does not populate this subtype membership; keep the
// required public enumeration as spec-only.

module test_sequence_library_macro_membership_combines_with_local_addition_only_on_one_instance;
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

  class library_type extends uvm_sequence_library#(packet);
    `uvm_object_utils(library_type)
    `uvm_sequence_library_utils(library_type)
    function new(string name="library_type"); super.new(name); endfunction
  endclass

  class first_member extends uvm_sequence#(packet);
    `uvm_object_utils(first_member)
    `uvm_add_to_seq_lib(first_member, library_type)
    function new(string name="first_member"); super.new(name); endfunction
    task body(); endtask
  endclass

  class second_member extends uvm_sequence#(packet);
    `uvm_object_utils(second_member)
    `uvm_add_to_seq_lib(second_member, library_type)
    function new(string name="second_member"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic library_type first = new("first");
    automatic library_type second = new("second");
    uvm_object_wrapper first_entries[$];
    uvm_object_wrapper second_entries[$];
    first.add_sequence(alpha_sequence::get_type());
    first.get_sequences(first_entries);
    second.get_sequences(second_entries);
    $display("UT: counts %0d %0d first_static %0d %0d local %0d other_local %0d",
             first_entries.size(), second_entries.size(), occurrences(first_entries,
                 first_member::get_type()),
             occurrences(first_entries, second_member::get_type()),
             occurrences(first_entries, alpha_sequence::get_type()),
             occurrences(second_entries, alpha_sequence::get_type()));
    $finish;
  end
endmodule
