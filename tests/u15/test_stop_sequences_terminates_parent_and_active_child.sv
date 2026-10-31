/*
:name: test_stop_sequences_terminates_parent_and_active_child
:description: sequencer stop terminates the selected active hierarchy and cleans up its ownership (IEEE 1800.2-2020 Section 15.3.2.14)
:tags: u15 uvm
:type: simulation
:lrm: 1800.2-2020 15.3.2.14 14.2.5.11 14.2.5.12 14.2.3.1 14.2.2.4 F.2.4.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_stop_sequences_terminates_parent_and_active_child.expected
*/
// Start a child through its active parent on the same sequencer. Stop
// only after both bodies enter, then sample state and kill hooks after
// settling and delayed writes after their original deadlines.

module test_stop_sequences_terminates_parent_and_active_child;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class stop_node extends uvm_sequence#(packet);
    `uvm_object_utils(stop_node)
    stop_node first_child;
    stop_node second_child;
    bit entered = 0;
    bit late_write = 0;
    bit take_lock = 0;
    bit take_grab = 0;
    int kills = 0;
    function new(string name="stop_node"); super.new(name); endfunction
    function void do_kill(); kills++; endfunction
    task body();
      if (take_lock) lock();
      if (take_grab) grab();
      entered = 1;
      if (first_child != null && second_child != null) begin
        fork
          first_child.start(get_sequencer(), this);
          second_child.start(get_sequencer(), this);
        join
      end
      else if (first_child != null) first_child.start(get_sequencer(), this);
      #20;
      late_write = 1;
      if (take_grab) ungrab();
      if (take_lock) unlock();
    endtask
  endclass

  class t extends uvm_test;
    `uvm_component_utils(t)
    uvm_sequencer#(packet) sequencer;
    uvm_sequencer#(packet) other_sequencer;
    stop_node parent_value;
    stop_node child_value;
    stop_node extra_value;
    bit parent_returned = 0;
    bit extra_returned = 0;
    uvm_phase schedule;
    uvm_phase node;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sequencer = new("sequencer", this);
      sequencer.disable_auto_item_recording();
      other_sequencer = new("other_sequencer", this);
      other_sequencer.disable_auto_item_recording();
      parent_value = new("parent_value");
      child_value = new("child_value");
      extra_value = new("extra_value");
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      parent_value.first_child = child_value;

      fork
        begin parent_value.start(sequencer); parent_returned = 1; end

        begin
          wait (parent_value.entered && child_value.entered);
          #1;

          sequencer.stop_sequences();
          #1;

          $display("UT: stopped %0d %0d kills %0d %0d returned %0d",
                   parent_value.get_sequence_state() == UVM_STOPPED,
                   child_value.get_sequence_state() == UVM_STOPPED,
                   parent_value.kills, child_value.kills, parent_returned);

          #21;

          $display("UT: late_writes %0d %0d", parent_value.late_write, child_value.late_write);

        end
      join
      phase.drop_objection(this);
    endtask
  endclass

  initial run_test("t");
  initial begin
    #100;
    $fatal(1, "test watchdog expired");
  end
endmodule
