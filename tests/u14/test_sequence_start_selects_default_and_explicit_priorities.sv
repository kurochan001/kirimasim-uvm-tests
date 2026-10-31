/*
:name: test_sequence_start_selects_default_and_explicit_priorities
:description: root sequence start selects priority 100 by default or an explicit priority (IEEE 1800.2-2020 Section 14.2.3.1)
:tags: u14 uvm
:type: simulation
:lrm: 1800.2-2020 14.2.3.1 14.2.5.1 14.2.5.2 1800-2023 6.21
:uvm: 2020.3.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_sequence_start_selects_default_and_explicit_priorities.expected
*/
// Observe priority while the body is executing, then update the
// completed sequence explicitly. No arbitration or random selection occurs.

module test_sequence_start_selects_default_and_explicit_priorities;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class priority_sequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(priority_sequence)
    function new(string name="priority_sequence"); super.new(name); endfunction
    task body(); $display("UT: body_priority %0d", get_priority()); endtask
  endclass
  initial begin
    automatic priority_sequence first = new("first");
    automatic priority_sequence second = new("second");
    first.start(null);
    second.start(null, null, 23);
    second.set_priority(7);
    $display("UT: updated_priority %0d", second.get_priority());
    $finish;
  end
endmodule
