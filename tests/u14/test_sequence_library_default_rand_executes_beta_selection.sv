/*
:name: test_sequence_library_default_rand_executes_beta_selection
:description: default RAND sequence library executes its legal ten-iteration budget (IEEE 1800.2-2020 Section 14.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4 14.4.4.1 14.4.4.6 14.4.4.7 14.4.5.3 B.3.2.2 1800-2023 6.21 18.5
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_default_rand_executes_beta_selection.expected
*/
// What it checks:
// 1. RAND selection uses the constrained public selection index.
// 2. Default RAND library selection creates and executes the registered type
//    selected by its constrained index.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 14.4.4.7 (UVM-LIBRARY-RAND-CONSTRAINED-MEMBER-SELECTION)
//    gives rule 1 above. Setup: Find each wrapper index through enumeration
//    and constrain alpha or beta selection. Expected: The selected member runs
//    ten times while the other does not run.
// 2. 1800.2-2020 14.4 (UVM-SEQ-REVIEW-DEFAULT-RAND-DISPATCH) gives rule 2
//    above. Setup: Two unchanged fixtures constrain the public selection index
//    to the publicly enumerated alpha or beta type. Expected: Only the
//    selected registered type executes its ten child bodies.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Register members through the instance API and keep the default legal
// ten-iteration count. Constrain the public selection variable to the
// index found by public enumeration; no registration order is assumed.
// This does not call or replace the missing standard counter/control APIs.

module test_sequence_library_default_rand_executes_beta_selection;
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

  class selected_library extends uvm_sequence_library#(packet);
    `uvm_object_utils(selected_library)
    `uvm_sequence_library_utils(selected_library)
    int wanted_index = -1;
    constraint chosen_index { select_rand == wanted_index; }
    function new(string name="selected_library"); super.new(name); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    selected_library value;
    uvm_sequencer#(packet) sequencer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      value = new("value");
      sequencer = new("sequencer", this);
      value.add_sequence(alpha_sequence::get_type());
      value.add_sequence(beta_sequence::get_type());

      begin
        uvm_object_wrapper entries[$];
        value.get_sequences(entries);
        foreach (entries[i]) if (entries[i] == beta_sequence::get_type()) value.wanted_index = i;
        if (value.wanted_index < 0) $fatal(1, "registered type not found");
      end
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      value.start(sequencer);
      $display("UT: alpha %0d beta %0d", alpha_sequence::calls, beta_sequence::calls);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
