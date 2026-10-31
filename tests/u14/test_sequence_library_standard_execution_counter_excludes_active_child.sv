/*
:name: test_sequence_library_standard_execution_counter_excludes_active_child
:description: standard execution counter excludes the active child and counts completed children (IEEE 1800.2-2020 Section 14.4)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.4 14.4.4.4 14.4.4.5 14.4.4.6 14.4.5.3 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_library_standard_execution_counter_excludes_active_child.expected
*/
// The pinned library lacks the standard accessor methods. Keep the
// required API spelling and its expectation as a spec-only build case.
// Run only one registered type and sample inside its positive body delay.
// Observe two completed children after the library returns.

module test_sequence_library_standard_execution_counter_excludes_active_child;
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

  class t extends uvm_test;
    `uvm_component_utils(t)
    library_type value;
    uvm_sequencer#(packet) sequencer;
    bit done = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      value = new("value");
      value.add_sequence(alpha_sequence::get_type());
      value.sequence_count = 2;
      sequencer = new("sequencer", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fork
        begin value.start(sequencer); done = 1; end
      join_none
      wait (alpha_sequence::started == 1);
      #1;
      $display("UT: active_count %0d finished %0d", value.get_num_sequences_executed(),
               alpha_sequence::finished);
      wait (done);
      $display("UT: completed_count %0d finished %0d", value.get_num_sequences_executed(),
               alpha_sequence::finished);
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
