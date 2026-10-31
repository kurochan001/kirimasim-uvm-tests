/*
:name: test_child_sequence_inherits_priority_from_running_parent
:description: a child sequence started with default priority inherits its running parent priority (IEEE 1800.2-2020 Section 14.2.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.1 14.2.5.1 14.1.2.7 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_child_sequence_inherits_priority_from_running_parent.expected
*/
// Start a parent at explicit priority 37 and let its body start a child
// with the default priority argument. Observe the live parent link.

module test_child_sequence_inherits_priority_from_running_parent;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class packet extends uvm_sequence_item;
    `uvm_object_utils(packet)
    int payload = 0;
    function new(string name="packet"); super.new(name); endfunction
  endclass

  class child_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(child_sequence)
    uvm_sequence_base expected_parent;
    bit finished = 0;
    function new(string name="child_sequence"); super.new(name); endfunction
    task body();
      $display("UT: child priority %0d parent_same %0d", get_priority(),
               get_parent_sequence() == expected_parent);
      finished = 1;
    endtask
  endclass
  class parent_sequence extends uvm_sequence#(packet);
    `uvm_object_utils(parent_sequence)
    function new(string name="parent_sequence"); super.new(name); endfunction
    task body();
      child_sequence child_value = new("child_value");
      $display("UT: parent priority %0d", get_priority());
      child_value.expected_parent = this;
      child_value.start(null, this);
      $display("UT: child_finished %0d", child_value.finished);
    endtask
  endclass
  initial begin
    automatic parent_sequence value = new("value");
    value.start(null, null, 37);
    $finish;
  end
  initial begin
    #80;
    $fatal(1, "test watchdog expired");
  end
endmodule
