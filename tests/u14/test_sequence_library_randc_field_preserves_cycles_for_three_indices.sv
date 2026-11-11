/*
:name: test_sequence_library_randc_field_preserves_cycles_for_three_indices
:description: sequence library randc field preserves cycles for three indices (IEEE 1800.2-2020 Section 14.4.4.8)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4.4.8 14.4.4.6 14.4.4.7 14.4.5.3 14.4.5.6 B.3.2.2 B.2.1.2 1800-2023 6.21 18.5 18.4
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_randc_field_preserves_cycles_for_three_indices.expected
*/
// What it checks:
// 1. The standard select_randc field has sixteen bits.
// 2. The randomized select_randc value remains a valid registered-sequence
//    index.
// 3. The cyclic selection field visits each legal value before repeating
//    within a complete selected cycle.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.4.8 (UVM-SEQ-REVIEW-RANDC-FIELD-WIDTH) gives rule 1
//    above. Setup: Inspect the public field in singleton, three-index and
//    subset configurations. Expected: Each declaration reports width sixteen.
// 2. 1800.2-2020 14.4.4.8 (UVM-SEQ-REVIEW-RANDC-VALID-REGISTERED-INDEX) gives
//    rule 2 above. Setup: Register one or three original member types and
//    randomize only this field. Expected: Every sampled draw succeeds and
//    remains in its registered index range.
// 3. 1800.2-2020 14.4.4.8 (UVM-SEQ-REVIEW-RANDC-NONREPEATING-CYCLES) gives
//    rule 3 above. Setup: Three registered indices are drawn in two successive
//    groups of three. Expected: Each group contains each legal index exactly
//    once, without fixing order.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Randomize the standard public randc field directly against registered type
// indices. Check membership/frequency within two cycles without fixing random
// order. No legacy selection_mode member is used; RANDC library execution via
// the missing standard mode accessor remains a separate obligation.
module test_sequence_library_randc_field_preserves_cycles_for_three_indices;
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
      repeat (3) begin
        success &= value.draw_index();
        index_value = value.select_randc;
        if (index_value < 3) counts[index_value]++;
        else legal = 0;
      end
      $display("UT: cycle %0d randomize %0d legal %0d distribution %0d", cycle, success, legal,
               counts[0] == 1 && counts[1] == 1 && counts[2] == 1);
    end
    $finish;
  end
endmodule
