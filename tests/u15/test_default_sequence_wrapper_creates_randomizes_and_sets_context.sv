/*
:name: test_default_sequence_wrapper_creates_randomizes_and_sets_context
:description: default phase sequence selection follows resource type scope creation and lifecycle rules (IEEE 1800.2-2020 Section 15.3.5)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.5 14.2.2.2 14.2.2.3 14.2.4.1 14.1.2.5 C.4.2.2.1 8.3.1.5 8.3.2.2.3 1800-2023 6.21 18.6.2
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_default_sequence_wrapper_creates_randomizes_and_sets_context.expected
*/
// Supply a sequence wrapper and leave randomization enabled. Count the
// standard pre/post-randomize hooks, not random values, and inspect the
// created object after the phase has completed.

module test_default_sequence_wrapper_creates_randomizes_and_sets_context;
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
                                           default_probe::get_type());

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

      if (!$cast(created, default_probe::last_instance) || created == null)
        $fatal(1, "created sequence missing");
      if (created.seen_phase == null) $fatal(1, "starting phase missing");

      $display("UT: ran %0d finished %0d sequencer_same %0d phase %s", created.ran,
          created.finished,
               created.seen_sequencer == sequencer, created.seen_phase.get_name());
      $display("UT: randomization_hooks %0d %0d", default_probe::pre_calls,
          default_probe::post_calls);

    endfunction
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
