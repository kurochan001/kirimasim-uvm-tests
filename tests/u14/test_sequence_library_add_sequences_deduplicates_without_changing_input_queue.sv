/*
:name: test_sequence_library_add_sequences_deduplicates_without_changing_input_queue
:description: bulk instance registration ignores duplicate types and preserves its input queue (IEEE 1800.2-2020 Section 14.4.5.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.5.4 14.4.5.6 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_add_sequences_deduplicates_without_changing_input_queue.expected
*/
// What it checks:
// Bulk instance registration deduplicates wrappers and preserves the caller
// queue.
//
// How the expected output follows from the standard:
// 1800.2-2020 14.4.5.4 (UVM-LIBRARY-BULK-INSTANCE-REGISTRATION) gives the rule
// above. Setup: Supply alpha/beta/alpha as a three-entry queue. Expected:
// Membership contains alpha/beta once each and the supplied queue still has
// three entries with the repeated wrapper.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Supply a queue containing a repeated wrapper. Check the resulting set
// and verify that registration leaves the caller queue intact.

module test_sequence_library_add_sequences_deduplicates_without_changing_input_queue;
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
    uvm_object_wrapper supplied[$];
    uvm_object_wrapper entries[$];
    supplied = '{alpha_sequence::get_type(), beta_sequence::get_type(), alpha_sequence::get_type()};
    value.add_sequences(supplied);
    value.get_sequences(entries);
    $display("UT: count %0d alpha %0d beta %0d supplied_count %0d supplied_repeat %0d",
             entries.size(), occurrences(entries, alpha_sequence::get_type()),
             occurrences(entries, beta_sequence::get_type()), supplied.size(),
                 supplied[0] == supplied[2]);
    $finish;
  end
endmodule
