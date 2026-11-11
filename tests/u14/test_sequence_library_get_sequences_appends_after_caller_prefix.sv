/*
:name: test_sequence_library_get_sequences_appends_after_caller_prefix
:description: registered sequence enumeration appends to an existing caller queue (IEEE 1800.2-2020 Section 14.4.5.6)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.6 14.4.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_get_sequences_appends_after_caller_prefix.expected
*/
// What it checks:
// Sequence enumeration appends the registered list without replacing the
// caller prefix.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.6 (UVM-LIBRARY-ENUMERATION-APPENDS-CALLER-QUEUE) gives
// the rule above. Setup: Start with an unrelated prefix and enumerate
// alpha/beta twice. Expected: The queue has five entries, retains the prefix
// and contains alpha/beta twice each.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Begin enumeration with an unrelated prefix and call twice. Preserve that
// prefix and append a fresh copy of the registered list on each call.

module test_sequence_library_get_sequences_appends_after_caller_prefix;
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
    uvm_object_wrapper entries[$];
    entries.push_back(prefix_sequence::get_type());
    value.add_sequence(alpha_sequence::get_type());
    value.add_sequence(beta_sequence::get_type());
    value.get_sequences(entries);
    value.get_sequences(entries);
    $display("UT: count %0d prefix_same %0d alpha %0d beta %0d", entries.size(),
             entries[0] == prefix_sequence::get_type(), occurrences(entries,
                 alpha_sequence::get_type()),
             occurrences(entries, beta_sequence::get_type()));
    $finish;
  end
endmodule
