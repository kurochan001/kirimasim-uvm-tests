/*
:name: test_sequence_library_macro_subtype_inherits_base_static_membership
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
:expected_stdout: @test_sequence_library_macro_subtype_inherits_base_static_membership.expected
*/
// Register on a base library and construct both base and derived libraries.
// The subtype utilities must retain base membership without queue inspection.
// Use the standard constructor pattern with super.new and the required
// macros. Do not invoke an additional library-specific initialization API.
// The pinned library does not populate this subtype membership; keep the
// required public enumeration as spec-only.

module test_sequence_library_macro_subtype_inherits_base_static_membership;
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

  class base_library extends uvm_sequence_library#(packet);
    `uvm_object_utils(base_library)
    `uvm_sequence_library_utils(base_library)
    function new(string name="base_library"); super.new(name); endfunction
  endclass

  class derived_library extends base_library;
    `uvm_object_utils(derived_library)
    `uvm_sequence_library_utils(derived_library)
    function new(string name="derived_library"); super.new(name); endfunction
  endclass

  class member_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(member_sequence)
    `uvm_add_to_seq_lib(member_sequence, base_library)
    function new(string name="member_sequence"); super.new(name); endfunction
    task body(); endtask
  endclass

  initial begin
    automatic base_library first = new("first");
    automatic derived_library second = new("second");
    uvm_object_wrapper first_entries[$];
    uvm_object_wrapper second_entries[$];
    first.get_sequences(first_entries);
    second.get_sequences(second_entries);
    $display("UT: counts %0d %0d inherited %0d", first_entries.size(), second_entries.size(),
             occurrences(second_entries, member_sequence::get_type()));
    $finish;
  end
endmodule
