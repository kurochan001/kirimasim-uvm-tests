/*
:name: test_default_sequence_rejects_sequence_item_wrapper_with_required_error
:description: default phase sequence selection follows resource type scope creation and lifecycle rules (IEEE 1800.2-2020 Section 15.3.5)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.5 14.2.2.2 14.2.2.3 14.2.4.1 14.1.2.5 C.4.2.2.1 8.3.1.5 6.5.1.2.6 1800-2023 6.21 18.6.2
:uvm: 2020.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_sequence_rejects_sequence_item_wrapper_with_required_error.expected
*/
// What it checks:
// A wrapper producing a nonsequence reports an error without starting a
// default.
//
// How the expected output follows from the standard:
// 1800.2-2020 15.3.5 (UVM-DEFAULT-SEQUENCE-INVALID-WRAPPER-ERROR) gives the
// rule above. Setup: Configure a plain-object or sequence-item wrapper.
// Expected: An ERROR is added and no default body starts.
// These expectations come from the cited clauses, not from the output of a
// simulator.
// The configured wrapper creates an object that is not a sequence.
// The standard requires an error and no default start. The pinned library
// only warns; preserve the required error count as spec-only.

module test_default_sequence_rejects_sequence_item_wrapper_with_required_error;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class default_probe extends uvm_sequence#(packet);
    `uvm_object_utils(default_probe)
    static int runs = 0;
    static int pre_calls = 0;
    static int post_calls = 0;
    static uvm_sequence_base last_instance;
    int ran = 0;
    int duration = 1;
    int kills = 0;
    bit finished = 0;
    uvm_sequencer_base seen_sequencer;
    uvm_phase seen_phase;
    function new(string name="default_probe"); super.new(name); endfunction
    function void pre_randomize(); super.pre_randomize(); pre_calls++; endfunction
    function void post_randomize(); super.post_randomize(); post_calls++; endfunction
    function void do_kill(); kills++; endfunction
    task body();
      runs++;
      ran++;
      last_instance = this;
      seen_sequencer = get_sequencer();
      seen_phase = get_starting_phase();
      #duration;
      finished = 1;
    endtask
  endclass
  class override_probe extends default_probe;
    `uvm_object_utils(override_probe)
    static int derived_runs = 0;
    function new(string name="override_probe"); super.new(name); endfunction
    task body(); derived_runs++; super.body(); endtask
  endclass
  class plain_object extends uvm_object;
    `uvm_object_utils(plain_object)
    function new(string name="plain_object"); super.new(name); endfunction
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    default_probe first;
    default_probe second;
    default_probe created;
    override_probe derived;
    uvm_report_server report_server;
    int error_before = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      first = new("first");
      second = new("second");
      report_server = uvm_report_server::get_server();
      uvm_config_db#(uvm_object_wrapper)::set(this, "sequencer.main_phase", "default_sequence",
                                             packet::get_type());

      error_before = report_server.get_severity_count(UVM_ERROR);
    endfunction
    task pre_reset_phase(uvm_phase phase);
      phase.raise_objection(this);
      #3;
      phase.drop_objection(this);
    endtask
    task main_phase(uvm_phase phase);
      phase.raise_objection(this);
      #5;
      phase.drop_objection(this);
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #30;
      phase.drop_objection(this);
    endtask
    function void check_phase(uvm_phase phase);
      super.check_phase(phase);

      $display("UT: invalid_default_error %0d starts %0d",
               report_server.get_severity_count(UVM_ERROR) > error_before, default_probe::runs);

    endfunction
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
