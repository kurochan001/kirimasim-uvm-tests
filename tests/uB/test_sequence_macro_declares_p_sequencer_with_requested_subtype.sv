/*
:name: test_sequence_macro_declares_p_sequencer_with_requested_subtype
:description: typed sequencer macro declares a variable supporting subtype member access (IEEE 1800.2-2020 Section B.3.3)
:tags: uB uvm
:type: simulation
:lrm: 1800.2-2020 B.3.3 14.1.2.5 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_macro_declares_p_sequencer_with_requested_subtype.expected
*/
// Explicitly cast the current sequencer into the declared variable and
// access a member of the requested subtype. No automatic initialization
// policy for p_sequencer is assumed by this declaration-focused case.

module test_sequence_macro_declares_p_sequencer_with_requested_subtype;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class audit;
    static string trace = "";
    static function void append(string event_name);
      if (trace == "") trace = event_name;
      else trace = {trace, ",", event_name};
    endfunction
  endclass
  class action_item extends uvm_sequence_item;
    `uvm_object_utils(action_item)
    rand int code;
    int randomizations = 0;
    bit watch = 0;
    function new(string name="action_item"); super.new(name); endfunction
    function void pre_randomize(); if (watch) audit::append("pre_randomize"); endfunction
    function void post_randomize();
      randomizations++;
      if (watch) audit::append("post_randomize");
    endfunction
  endclass
  class replacement_item extends action_item;
    `uvm_object_utils(replacement_item)
    function new(string name="replacement_item"); super.new(name); endfunction
  endclass
  class child_sequence extends uvm_sequence#(action_item);
    `uvm_object_utils(child_sequence)
    rand int code;
    int randomizations = 0;
    int pre_calls = 0;
    int body_calls = 0;
    int post_calls = 0;
    function new(string name="child_sequence"); super.new(name); endfunction
    function void post_randomize(); randomizations++; endfunction
    task pre_body(); pre_calls++; endtask
    task body(); body_calls++; endtask
    task post_body(); post_calls++; endtask
  endclass
  class replacement_sequence extends child_sequence;
    `uvm_object_utils(replacement_sequence)
    function new(string name="replacement_sequence"); super.new(name); endfunction
  endclass
  class typed_sequencer extends uvm_sequencer#(action_item);
    `uvm_component_utils(typed_sequencer)
    int marker = 73;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
  endclass
  class action_driver extends uvm_driver#(action_item);
    `uvm_component_utils(action_driver)
    action_item seen;
    bit watch = 0;
    int count = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
      forever begin
        seq_item_port.get_next_item(seen);
        count++;
        if (watch) audit::append("driver");
        seq_item_port.item_done();
      end
    endtask
  endclass

  class parent_sequence extends uvm_sequence#(action_item);
    `uvm_object_utils(parent_sequence)
    uvm_sequencer_base alternate;
    action_item item;
    child_sequence child;
    bit watch = 0;
    `uvm_declare_p_sequencer(typed_sequencer)
    function new(string name="parent_sequence"); super.new(name); endfunction
    task pre_do(bit is_item);
      if (watch) audit::append(is_item ? "pre_do_item" : "pre_do_sequence");
    endtask
    function void mid_do(uvm_sequence_item this_item);
      if (watch) audit::append("mid_do");
    endfunction
    function void post_do(uvm_sequence_item this_item);
      if (watch) audit::append("post_do");
    endfunction
    task body();
      if (!$cast(p_sequencer, get_sequencer()) || p_sequencer == null)
        $fatal(1, "typed sequencer context missing");
      $display("UT: typed_same %0d marker %0d", p_sequencer == get_sequencer(), p_sequencer.marker);
    endtask
  endclass
  class t extends uvm_test;
    `uvm_component_utils(t)
    typed_sequencer sequencer;
    typed_sequencer alternate;
    action_driver driver;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      alternate = new("alternate", this);
      driver = new("driver", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
    task run_phase(uvm_phase phase);
      parent_sequence sequence_value;
      phase.raise_objection(this);
      sequence_value = new("sequence_value");
      sequence_value.alternate = alternate;

      sequence_value.start(sequencer);

      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
