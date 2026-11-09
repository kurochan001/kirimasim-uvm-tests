/*
:name: test_command_default_sequence_runs_on_the_named_sequencer_and_phase
:description: command default sequence runs on the named sequencer and phase (IEEE 1800.2-2020 Section G.2.9)
:tags: uG uvm
:type: simulation
:lrm: 1800.2-2020 G.2.9 15.3.2.22 14.2.3.1 B.2.1.2 B.2.1.3 1800-2023 6.21
:uvm: 2020.3.1
:uvm_dpi: yes
:uvm_cmdline_backend: vpi
:uvm_cmdline_oracle: verilator@5.052
:uvm_defines: UVM_HDL_NO_DPI
:dpi_c: @../../tools/cmdline_backend/uvm_cmdline_vpi.cpp
:files: ../../tools/cmdline_backend/uvm_cmdline_regex.cpp ../../tools/cmdline_backend/malloc.h
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:args: +uvm_set_default_sequence=uvm_test_top.sequencer,main_phase,configured_sequence
:expected_stdout: @test_command_default_sequence_runs_on_the_named_sequencer_and_phase.expected
*/
// What it checks:
// 1. The default-sequence option selects the named sequence wrapper for its
//    phase scope.
// 2. The command-line selected default sequence executes on its named
//    sequencer.
//
// How the expected output follows from the standard:
// 1. 1800.2-2020 G.2.9 (UVM-CMDLINE-DEFAULT-SEQUENCE-WRAPPER-SELECTION) gives
//    rule 1 above. Setup: A registered sequence type is supplied for the
//    selected sequencer main_phase. Expected: That sequence body runs once
//    under the selected phase condition.
// 2. 1800.2-2020 G.2.9 (UVM-CMDLINE-DEFAULT-SEQUENCE-CONTEXT) gives rule 2
//    above. Setup: A peer sequencer has no default option while the target
//    does. Expected: The single execution observes the exact target sequencer
//    handle.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// Observe command-line wrapper selection and actual sequence execution on the
// named sequencer in main_phase. No item traffic, randomization content or
// other default-resource precedence is inferred.
module test_command_default_sequence_runs_on_the_named_sequencer_and_phase;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  uvm_sequencer_base expected_sequencer;
  class configured_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(configured_sequence)
    static int runs = 0;
    static bit selected_context = 0;
    function new(string name="configured_sequence"); super.new(name); endfunction
    task body(); runs++; selected_context = get_sequencer() == expected_sequencer; endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(uvm_sequence_item) sequencer, peer;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase); sequencer = new("sequencer", this); peer = new("peer", this);
      sequencer.disable_auto_item_recording(); peer.disable_auto_item_recording();
      expected_sequencer = sequencer;
    endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this); #2;
      $display("UT: default_sequence runs %0d context %0d", configured_sequence::runs,
               configured_sequence::selected_context);
      phase.drop_objection(this);
    endtask
  endclass
  initial begin
    automatic uvm_object_wrapper wrapper = configured_sequence::get_type();
    run_test("t");
  end
  initial begin #100; $fatal(1, "default-sequence watchdog expired"); end
endmodule
