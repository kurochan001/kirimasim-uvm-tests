/*
:name: test_sequence_library_randc_field_preserves_cycles_for_subset
:description: sequence library randc field preserves cycles for subset (IEEE 1800.2-2020 Section 14.4.4.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.8 14.4.4.6 14.4.4.7 14.4.5.3 14.4.5.6 B.3.2.2 B.2.1.2 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_randc_field_preserves_cycles_for_subset.expected
*/
// What it checks:
// 1. The standard select_randc field has sixteen bits.
// 2. An extension can constrain the cyclic selector to a legal subset of
//    registered indices.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.4.8 (UVM-SEQ-REVIEW-RANDC-FIELD-WIDTH) gives rule 1
//    above. Setup: Inspect the public field in singleton, three-index and
//    subset configurations. Expected: Each declaration reports width sixteen.
// 2. 1800.2-2020 14.4.4.8 (UVM-SEQ-REVIEW-RANDC-EXTENSION-CONSTRAINT) gives
//    rule 2 above. Setup: A subtype adds the subset {0,2} within three
//    registered indices. Expected: Each two-draw cycle includes zero and two
//    once, excluding one.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Randomize the standard public randc field directly against registered type
// indices. Check membership/frequency within two cycles without fixing random
// order. No legacy selection_mode member is used; RANDC library execution via
// the missing standard mode accessor remains a separate obligation.
module test_sequence_library_randc_field_preserves_cycles_for_subset;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  class alpha extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(alpha)
    function new(string name="alpha"); super.new(name); endfunction
    task body(); endtask
  endclass
  class beta extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(beta)
    function new(string name="beta"); super.new(name); endfunction
    task body(); endtask
  endclass
  class gamma extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(gamma)
    function new(string name="gamma"); super.new(name); endfunction
    task body(); endtask
  endclass
  class observed_library extends uvm_sequence_library#(uvm_sequence_item);
    `uvm_object_utils(observed_library)
    `uvm_sequence_library_utils(observed_library)
    constraint chosen_subset { select_randc inside {0,2}; }
    function new(string name="library"); super.new(name); endfunction
    function bit draw_index(); return randomize(select_randc); endfunction
  endclass
  initial begin
    automatic observed_library value = new();
    uvm_object_wrapper entries[$];
    int counts[3];
    bit success, legal;
    int unsigned index_value;
    value.add_sequence(alpha::get_type());
    value.add_sequence(beta::get_type()); value.add_sequence(gamma::get_type());
    value.get_sequences(entries);
    $display("UT: randc_width %0d registered %0d", $bits(value.select_randc), entries.size());
    for (int cycle = 0; cycle < 2; cycle++) begin
      foreach (counts[i]) counts[i] = 0;
      success = 1; legal = 1;
      repeat (2) begin
        success &= value.draw_index();
        index_value = value.select_randc;
        if (index_value < 3) counts[index_value]++;
        else legal = 0;
      end
      $display("UT: cycle %0d randomize %0d legal %0d distribution %0d", cycle, success, legal,
               counts[0] == 1 && counts[1] == 0 && counts[2] == 1);
    end
    $finish;
  end
endmodule
