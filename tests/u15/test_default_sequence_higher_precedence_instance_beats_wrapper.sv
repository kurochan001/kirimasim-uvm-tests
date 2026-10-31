/*
:name: test_default_sequence_higher_precedence_instance_beats_wrapper
:description: default sequence resource selection filters types and preserves precedence and queue priority (IEEE 1800.2-2020 Section 15.3.5)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.5 C.4.2.2.1 C.2.4.4.1 C.2.4.4.2 1800-2023 6.21 18.6.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_sequence_higher_precedence_instance_beats_wrapper.expected
*/
// Use the inverse typed-resource ordering: a root-context instance
// outranks the test-context wrapper. Keep its configured randomization
// disabled and prove that exact object ran.

module test_default_sequence_higher_precedence_instance_beats_wrapper;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class selection_probe extends uvm_sequence#(packet);
    `uvm_object_utils(selection_probe)
    static int runs = 0;
    static int pre_calls = 0;
    static int post_calls = 0;
    static uvm_sequence_base last_instance;
    static int last_marker = 0;
    int marker = 11;
    int ran = 0;
    function new(string name="selection_probe"); super.new(name); endfunction
    function void pre_randomize(); super.pre_randomize(); pre_calls++; endfunction
    function void post_randomize(); super.post_randomize(); post_calls++; endfunction
    task body();
      runs++;
      ran++;
      last_instance = this;
      last_marker = marker;
      #1;
    endtask
  endclass
  class wrapper_probe extends selection_probe;
    `uvm_object_utils(wrapper_probe)
    function new(string name="wrapper_probe"); super.new(name); marker = 22; endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    selection_probe instance_value;
    uvm_resource_pool pool;
    uvm_resource#(uvm_sequence_base) instance_resource;
    uvm_resource#(uvm_object_wrapper) wrapper_resource;
    uvm_resource#(int) ignored_resource;
    string scope_name = "uvm_test_top.sequencer.main_phase";
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      instance_value = new("instance_value");
      instance_value.set_randomize_enabled(0);
      pool = uvm_resource_pool::get();

      uvm_config_db#(uvm_object_wrapper)::set(this, "sequencer.main_phase", "default_sequence",
                                           wrapper_probe::get_type());

      uvm_config_db#(uvm_sequence_base)::set(null, scope_name, "default_sequence", instance_value);

    endfunction
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #5;
      phase.drop_objection(this);
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #10;
      phase.drop_objection(this);
    endtask
    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      $display("UT: runs %0d marker %0d instance_runs %0d same_instance %0d", selection_probe::runs,
               selection_probe::last_marker, instance_value.ran,
               selection_probe::last_instance == instance_value);
      $display("UT: randomization_hooks %0d %0d", selection_probe::pre_calls,
          selection_probe::post_calls);
    endfunction
  endclass

  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "test watchdog expired");
  end
endmodule
